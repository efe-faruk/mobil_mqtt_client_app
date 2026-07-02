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
    // UI'dan (Main Isolate) gelen mesajları yakala
    if (data is Map<String, dynamic>) {
      try {
        final message = UiToServiceMessage.fromMap(data);
        _processUiCommand(message);
      } catch (e) {
        _sendErrorToUi("Gelen UI mesajı parse edilemedi: $e");
      }
    }
  }

  // --- UI KOMUTLARINI İŞLEME (COMMAND PATTERN) ---

  void _processUiCommand(UiToServiceMessage message) {
    switch (message.command) {
      case UiToServiceCommand.startMqtt:
        _startMqtt(message.payload);
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
        _mqttService.disconnect();
        _startMqtt(message.payload); // Yeni ayarlarla tekrar bağlan
        break;
      case UiToServiceCommand.updateDeviceList:
        // Cihaz listesi değiştiğinde yeni topic'lere abone ol
        _subscribeToTopics(message.payload);
        break;
    }
  }

  // --- MQTT KONTROL METOTLARI ---

  void _startMqtt(Map<String, dynamic>? payload) {
    if (payload == null) {
      _sendErrorToUi("startMqtt için BrokerConfig payload'ı eksik.");
      return;
    }

    try {
      // Map'ten BrokerConfig oluştur (Güvenli parse)
      final config = BrokerConfig(
        host: payload['host'] ?? '',
        port: payload['port'] ?? 1883,
        clientId: payload['clientId'] ?? 'flutter_smart_home',
        keepAliveSeconds: payload['keepAliveSeconds'] ?? 60,
        useAuth: payload['useAuth'] ?? false,
        username: payload['username'] ?? '',
        password: payload['password'] ?? '',
      );

      _mqttService.connect(config);
    } catch (e) {
      _sendErrorToUi("BrokerConfig oluşturulurken hata: $e");
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
        notificationText = 'Broker ile iletişim aktif.';
        break;
      case MqttConnectionStatus.connecting:
        notificationTitle = 'Akıllı Ev: Bağlanıyor...';
        notificationText = 'MQTT Broker\'a bağlanılıyor.';
        break;
      case MqttConnectionStatus.disconnected:
        notificationTitle = 'Akıllı Ev: Çevrimdışı';
        notificationText = 'Bağlantı kesildi.';
        break;
      case MqttConnectionStatus.fault:
        notificationTitle = 'Akıllı Ev: Hata';
        notificationText = 'Bağlantı hatası oluştu!';
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
}
