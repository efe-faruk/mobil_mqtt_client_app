import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/providers/app_providers.dart';
import '../models/broker_config.dart';
import 'foreground_message_models.dart';

class BrokerConfigApplyException implements Exception {
  final String message;

  const BrokerConfigApplyException(this.message);

  @override
  String toString() => message;
}

class IsolateCommunicator {
  final Ref ref;
  final Map<String, Completer<void>> _pendingBrokerUpdates = {};
  final Map<String, Completer<int>> _pendingServiceInfoRequests = {};

  IsolateCommunicator(this.ref) {
    FlutterForegroundTask.addTaskDataCallback(_onDataReceived);
  }

  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onDataReceived);
    for (final completer in _pendingBrokerUpdates.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          const BrokerConfigApplyException(
            'Broker güncellemesi tamamlanmadan iletişim kapatıldı.',
          ),
        );
      }
    }
    _pendingBrokerUpdates.clear();

    for (final completer in _pendingServiceInfoRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          const BrokerConfigApplyException(
            'Foreground servis kontrolü tamamlanamadı.',
          ),
        );
      }
    }
    _pendingServiceInfoRequests.clear();
  }

  Future<void> ensureCompatibleService() async {
    if (!await FlutterForegroundTask.isRunningService) {
      throw const BrokerConfigApplyException(
        'Foreground MQTT servisi çalışmıyor.',
      );
    }

    if (await _hasCompatibleService()) return;

    // Çalışan isolate eski uygulama kodunu kullanıyor olabilir. Restart,
    // güncel startCallback/TaskHandler kodunu yükler.
    await FlutterForegroundTask.restartService();

    for (var attempt = 0; attempt < 5; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (await _hasCompatibleService(
        timeout: const Duration(milliseconds: 500),
      )) {
        return;
      }
    }

    throw const BrokerConfigApplyException(
      'Foreground MQTT servisi güncel handler ile başlatılamadı.',
    );
  }

  Future<void> updateBrokerConfig(
    BrokerConfig config, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    await ensureCompatibleService();

    final requestId = const Uuid().v4();
    final completer = Completer<void>();
    _pendingBrokerUpdates[requestId] = completer;

    final message = UiToServiceMessage(
      command: UiToServiceCommand.updateBrokerConfig,
      payload: {
        ...config.toMap(),
        'requestId': requestId,
      },
    );

    try {
      FlutterForegroundTask.sendDataToTask(message.toMap());
      await completer.future.timeout(timeout);
    } on BrokerConfigApplyException {
      rethrow;
    } on TimeoutException {
      throw const BrokerConfigApplyException(
        'Broker servisi zamanında yanıt vermedi.',
      );
    } catch (e) {
      throw BrokerConfigApplyException(
        'Broker ayarları servise gönderilemedi: $e',
      );
    } finally {
      if (identical(_pendingBrokerUpdates[requestId], completer)) {
        _pendingBrokerUpdates.remove(requestId);
      }
    }
  }

  void _onDataReceived(Object data) {
    if (data is Map) {
      try {
        final message = ServiceToUiMessage.fromMap(
          Map<String, dynamic>.from(data),
        );

        switch (message.event) {
          case ServiceToUiEvent.serviceInfo:
            _completeServiceInfoRequest(message.payload);
            break;
          case ServiceToUiEvent.connectionStatusChanged:
            final status =
                message.payload?['status'] as String? ?? 'disconnected';
            ref.read(mqttConnectionStatusProvider.notifier).setStatus(status);
            break;
          case ServiceToUiEvent.brokerConfigUpdateResult:
            _completeBrokerConfigUpdate(message.payload);
            break;
          case ServiceToUiEvent.mqttMessageReceived:
            final topic = message.payload?['topic'] as String?;
            final payload = message.payload?['payload'] as String?;
            if (topic != null && payload != null) {
              _processIncomingMqttMessage(topic, payload);
            }
            break;
          case ServiceToUiEvent.error:
            debugPrint(
              'Foreground service hatası: ${message.payload?['error']}',
            );
            break;
          case ServiceToUiEvent.log:
            debugPrint('Foreground service: ${message.payload?['message']}');
            break;
        }
      } catch (e) {
        debugPrint('Isolate verisi okunurken hata: $e');
      }
    }
  }

  Future<bool> _hasCompatibleService({
    Duration timeout = const Duration(milliseconds: 750),
  }) async {
    final requestId = const Uuid().v4();
    final completer = Completer<int>();
    _pendingServiceInfoRequests[requestId] = completer;

    final message = UiToServiceMessage(
      command: UiToServiceCommand.getServiceInfo,
      payload: {'requestId': requestId},
    );

    try {
      FlutterForegroundTask.sendDataToTask(message.toMap());
      final version = await completer.future.timeout(timeout);
      return version == foregroundServiceProtocolVersion;
    } catch (_) {
      return false;
    } finally {
      if (identical(_pendingServiceInfoRequests[requestId], completer)) {
        _pendingServiceInfoRequests.remove(requestId);
      }
    }
  }

  void _completeServiceInfoRequest(Map<String, dynamic>? payload) {
    final requestId = payload?['requestId'] as String?;
    final version = payload?['protocolVersion'] as int?;
    if (requestId == null || version == null) return;

    final completer = _pendingServiceInfoRequests.remove(requestId);
    if (completer == null || completer.isCompleted) return;
    completer.complete(version);
  }

  void _completeBrokerConfigUpdate(Map<String, dynamic>? payload) {
    final requestId = payload?['requestId'] as String?;
    if (requestId == null) return;

    final completer = _pendingBrokerUpdates.remove(requestId);
    if (completer == null || completer.isCompleted) return;

    if (payload?['success'] == true) {
      completer.complete();
      return;
    }

    completer.completeError(
      BrokerConfigApplyException(
        payload?['error'] as String? ?? 'Broker bağlantısı kurulamadı.',
      ),
    );
  }

  Future<void> _processIncomingMqttMessage(
      String topic, String rawPayload) async {
    final cleanTopic = topic.trim();
    final cleanPayload = rawPayload.trim().toUpperCase();

    debugPrint(
      "MQTT mesajı geldi: topic='$cleanTopic', payload='$cleanPayload'",
    );

    final deviceRepo = ref.read(deviceRepositoryProvider);

    try {
      final devices = await deviceRepo.getAllDevices();

      // 2. Veritabanındaki topic ile gelen topic'i güvenli bir şekilde eşleştiriyoruz
      final device =
          devices.firstWhere((d) => d.topicState.trim() == cleanTopic);

      // 3. Switch veya Sensör ayrımını yapıp veritabanını güncelliyoruz
      if (cleanPayload == 'ON' || cleanPayload == 'OFF') {
        await deviceRepo.updateSwitchState(device.id, cleanPayload == 'ON');
        debugPrint(
          '${device.name} durumu $cleanPayload olarak güncellendi.',
        );
      } else {
        await deviceRepo.updateDeviceLastValue(device.id, cleanPayload);
        debugPrint(
          '${device.name} sensör verisi $cleanPayload olarak güncellendi.',
        );
      }
    } catch (e) {
      debugPrint(
        "Gelen topic '$cleanTopic' veritabanında bulunamadı: $e",
      );
    }
  }
}
