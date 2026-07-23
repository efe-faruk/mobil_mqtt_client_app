import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../mqtt/mqtt_service.dart';
import '../models/broker_config.dart';
import 'foreground_message_models.dart';

/// Foreground service başlatıldığında tetiklenecek top-level (global) fonksiyon.
/// Tree-shaking'den etkilenmemesi için @pragma anotasyonu eklenmelidir.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  final MqttService _mqttService = MqttService();

  StreamSubscription<MqttConnectionStatus>? _statusSubscription;
  StreamSubscription<MqttMessage>? _messageSubscription;
  Future<void> _commandQueue = Future<void>.value();
  String? _brokerEndpoint;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // 1. MQTT Durum değişikliklerini dinle ve UI'a aktar
    _statusSubscription = _mqttService.connectionStatus.listen((status) {
      _handleConnectionStatusChange(status);
    });

    // 2. MQTT'den gelen mesajları dinle ve UI'a aktar
    _messageSubscription = _mqttService.messages.listen((mqttMessage) {
      _handleIncomingMqttMessage(mqttMessage);
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // eventAction olarak ayarladığımız interval süresince periyodik tetiklenir.
    // MQTT'nin kendi ping/keepAlive mekanizması olduğu için burada
    // ekstra bir ağ kontrolü yapmamıza gerek yok.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // Servis durdurulduğunda (veya timeout olduğunda) abonelikleri temizle
    await _statusSubscription?.cancel();
    await _messageSubscription?.cancel();
    _mqttService.disconnect();
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map) {
      try {
        final message = UiToServiceMessage.fromMap(
          Map<String, dynamic>.from(data),
        );

        // Uyumluluk kontrolü MQTT bağlantı kuyruğunu beklememelidir.
        if (message.command == UiToServiceCommand.getServiceInfo) {
          _sendServiceInfo(message.payload);
          return;
        }

        _commandQueue = _commandQueue.then((_) => _runUiCommand(message));
      } catch (e) {
        _sendErrorToUi("Gelen UI mesajı parse edilemedi: $e");
      }
    }
  }

  // --- UI KOMUTLARINI İŞLEME (COMMAND PATTERN) ---

  Future<void> _runUiCommand(UiToServiceMessage message) async {
    try {
      await _processUiCommand(message);
    } catch (e) {
      _sendErrorToUi('Komut işlenirken hata oluştu: $e');
    }
  }

  Future<void> _processUiCommand(UiToServiceMessage message) async {
    switch (message.command) {
      case UiToServiceCommand.getServiceInfo:
        _sendServiceInfo(message.payload);
        break;
      case UiToServiceCommand.startMqtt:
        await _startMqtt(message.payload);
        break;
      case UiToServiceCommand.stopMqtt:
        _mqttService.disconnect();
        break;
      case UiToServiceCommand.publish:
        _publishMqtt(message.payload);
        break;
      case UiToServiceCommand.subscribeAllDevices:
        _subscribeToTopics(message.payload);
        break;
      case UiToServiceCommand.updateBrokerConfig:
        await _updateBrokerConfig(message.payload);
        break;
      case UiToServiceCommand.updateDeviceList:
        // Cihaz listesi değiştiğinde yeni topic'lere abone ol
        _subscribeToTopics(message.payload);
        break;
    }
  }

  // --- MQTT KONTROL METOTLARI ---

  Future<void> _startMqtt(Map<String, dynamic>? payload) async {
    if (payload == null) {
      _sendErrorToUi("startMqtt için BrokerConfig payload'ı eksik.");
      return;
    }

    try {
      final config = BrokerConfig.fromMap(payload);
      _brokerEndpoint = '${config.host}:${config.port}';
      await _mqttService.connect(config);
    } catch (e) {
      _sendErrorToUi("BrokerConfig oluşturulurken hata: $e");
    }
  }

  Future<void> _updateBrokerConfig(Map<String, dynamic>? payload) async {
    final requestId = payload?['requestId'] as String?;
    if (requestId == null) {
      _sendErrorToUi(
        "updateBrokerConfig için requestId veya payload eksik.",
      );
      return;
    }

    try {
      final config = BrokerConfig.fromMap(payload!);
      _brokerEndpoint = '${config.host}:${config.port}';
      _sendLogToUi('Broker güncellemesi alındı: $_brokerEndpoint');

      _mqttService.disconnect();
      final result = await _mqttService.connect(config);

      _sendBrokerConfigUpdateResult(
        requestId: requestId,
        success: result.isConnected,
        error: result.error,
        appliedConfig: result.isConnected ? config : null,
      );
    } catch (e) {
      _sendBrokerConfigUpdateResult(
        requestId: requestId,
        success: false,
        error: 'Broker ayarları servise uygulanamadı: $e',
      );
    }
  }

  void _publishMqtt(Map<String, dynamic>? payload) {
    if (payload == null ||
        !payload.containsKey('topic') ||
        !payload.containsKey('payload')) {
      _sendErrorToUi("Publish için topic veya payload eksik.");
      return;
    }

    final String topic = payload['topic'];
    final String data = payload['payload'];
    final bool retain = payload['retain'] ?? false;

    _mqttService.publish(topic, data, retain: retain);
  }

  void _subscribeToTopics(Map<String, dynamic>? payload) {
    if (payload == null || !payload.containsKey('topics')) return;

    final List<dynamic> topics = payload['topics'];
    for (var topic in topics) {
      _mqttService.subscribe(topic.toString());
    }
  }

  // --- UI'A BİLGİ GÖNDERME METOTLARI (EVENTS) ---

  void _handleConnectionStatusChange(MqttConnectionStatus status) {
    String notificationTitle = 'Akıllı Ev MQTT';
    String notificationText = 'Bağlantı durumu bilinmiyor.';

    // Notification metinlerini duruma göre ayarla
    switch (status) {
      case MqttConnectionStatus.connected:
        notificationTitle = 'Akıllı Ev: Bağlı';
        notificationText = _brokerEndpoint == null
            ? 'Broker ile iletişim aktif.'
            : '$_brokerEndpoint ile iletişim aktif.';
        break;
      case MqttConnectionStatus.connecting:
        notificationTitle = 'Akıllı Ev: Bağlanıyor...';
        notificationText = _brokerEndpoint == null
            ? 'MQTT Broker\'a bağlanılıyor.'
            : '$_brokerEndpoint adresine bağlanılıyor.';
        break;
      case MqttConnectionStatus.disconnected:
        notificationTitle = 'Akıllı Ev: Çevrimdışı';
        notificationText = 'Bağlantı kesildi.';
        break;
      case MqttConnectionStatus.fault:
        notificationTitle = 'Akıllı Ev: Hata';
        notificationText = _brokerEndpoint == null
            ? 'Bağlantı hatası oluştu!'
            : '$_brokerEndpoint bağlantısı kurulamadı.';
        break;
    }

    // Android/iOS bildirimini güncelle
    FlutterForegroundTask.updateService(
      notificationTitle: notificationTitle,
      notificationText: notificationText,
    );

    // UI tarafına bağlantı durumunu fırlat
    final msg = ServiceToUiMessage(
      event: ServiceToUiEvent.connectionStatusChanged,
      payload: {'status': status.name}, // Enum ismini string olarak yolla
    );
    FlutterForegroundTask.sendDataToMain(msg.toMap());
  }

  void _handleIncomingMqttMessage(MqttMessage mqttMessage) {
    final msg = ServiceToUiMessage(
      event: ServiceToUiEvent.mqttMessageReceived,
      payload: {
        'topic': mqttMessage.topic,
        'payload': mqttMessage.payload,
      },
    );
    FlutterForegroundTask.sendDataToMain(msg.toMap());
  }

  void _sendErrorToUi(String errorDescription) {
    final msg = ServiceToUiMessage(
      event: ServiceToUiEvent.error,
      payload: {'error': errorDescription},
    );
    FlutterForegroundTask.sendDataToMain(msg.toMap());
  }

  void _sendServiceInfo(Map<String, dynamic>? payload) {
    final requestId = payload?['requestId'] as String?;
    if (requestId == null) return;

    final activeConfig = _mqttService.activeConfig;
    final msg = ServiceToUiMessage(
      event: ServiceToUiEvent.serviceInfo,
      payload: {
        'requestId': requestId,
        'protocolVersion': foregroundServiceProtocolVersion,
        if (activeConfig != null)
          'activeBroker': {
            'host': activeConfig.host,
            'port': activeConfig.port,
            'clientId': activeConfig.clientId,
            'keepAliveSeconds': activeConfig.keepAliveSeconds,
            'useAuth': activeConfig.useAuth,
          },
      },
    );
    FlutterForegroundTask.sendDataToMain(msg.toMap());
  }

  void _sendBrokerConfigUpdateResult({
    required String requestId,
    required bool success,
    String? error,
    BrokerConfig? appliedConfig,
  }) {
    final msg = ServiceToUiMessage(
      event: ServiceToUiEvent.brokerConfigUpdateResult,
      payload: {
        'requestId': requestId,
        'success': success,
        if (error != null) 'error': error,
        if (appliedConfig != null)
          'appliedBroker': {
            'host': appliedConfig.host,
            'port': appliedConfig.port,
            'clientId': appliedConfig.clientId,
          },
      },
    );
    FlutterForegroundTask.sendDataToMain(msg.toMap());
  }

  void _sendLogToUi(String message) {
    final msg = ServiceToUiMessage(
      event: ServiceToUiEvent.log,
      payload: {'message': message},
    );
    FlutterForegroundTask.sendDataToMain(msg.toMap());
  }
}
