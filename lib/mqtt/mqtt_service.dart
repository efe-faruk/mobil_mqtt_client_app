import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';

// İlgili modellerin mevcut projenden import edildiği varsayılmıştır.
// Eğer henüz yoksa, projenin modellerine uygun olarak bunları kullanabilirsin.
import '../models/broker_config.dart';

enum MqttConnectionStatus { disconnected, connecting, connected, fault }

class MqttMessage {
  final String topic;
  final String payload;

  MqttMessage({required this.topic, required this.payload});
}

class MqttService {
  MqttServerClient? _client;
  final Set<String> _subscribedTopics = {};

  // Stream Controllers
  final _connectionStatusController =
      StreamController<MqttConnectionStatus>.broadcast();
  final _messagesController = StreamController<MqttMessage>.broadcast();

  // Public Streams
  Stream<MqttConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;
  Stream<MqttMessage> get messages => _messagesController.stream;

  /// Broker'a bağlanır ve gerekli callback'leri ayarlar.
  Future<void> connect(BrokerConfig config) async {
    _connectionStatusController.add(MqttConnectionStatus.connecting);

    // Client ayarları
    _client = MqttServerClient(config.host, config.clientId)
      ..port = config.port
      ..logging(on: false)
      ..keepAlivePeriod = 60
      ..autoReconnect = true // Otomatik reconnect mantığı aktif
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onAutoReconnected = _onAutoReconnected;

    // Bağlantı mesajı kurulumu
    final connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(config.clientId)
        .startClean() // Foreground service olduğu için clean session genelde daha sağlıklıdır
        .withWillQos(mqtt.MqttQos.atLeastOnce);

    _client!.connectionMessage = connMess;

    try {
      await _client!.connect(config.username, config.password);
    } catch (e) {
      _client?.disconnect();
      _connectionStatusController.add(MqttConnectionStatus.fault);
      return;
    }

    if (_client!.connectionStatus!.state ==
        mqtt.MqttConnectionState.connected) {
      _connectionStatusController.add(MqttConnectionStatus.connected);
      _setupMessageListener();
    } else {
      _client?.disconnect();
      _connectionStatusController.add(MqttConnectionStatus.fault);
    }
  }

  /// Bağlantıyı sonlandırır ve stream'leri günceller.
  void disconnect() {
    _client?.autoReconnect = false; // Kasıtlı çıkışta reconnect'i engelle
    _client?.disconnect();
    _connectionStatusController.add(MqttConnectionStatus.disconnected);
  }

  /// Belirtilen topic'e abone olur ve listeye ekler.
  void subscribe(String topic) {
    if (_client?.connectionStatus?.state ==
        mqtt.MqttConnectionState.connected) {
      _client!.subscribe(topic, mqtt.MqttQos.atLeastOnce);
    }
    _subscribedTopics.add(topic);
  }

  /// Belirtilen topic aboneliğini iptal eder ve listeden çıkarır.
  void unsubscribe(String topic) {
    if (_client?.connectionStatus?.state ==
        mqtt.MqttConnectionState.connected) {
      _client!.unsubscribe(topic);
    }
    _subscribedTopics.remove(topic);
  }

  /// Belirtilen topic'e payload yayınlar.
  void publish(String topic, String payload, {bool retain = false}) {
    if (_client?.connectionStatus?.state !=
        mqtt.MqttConnectionState.connected) {
      return; // Bağlı değilse mesajı yollama
    }

    final builder = mqtt.MqttClientPayloadBuilder();
    builder.addString(payload);

    _client!.publishMessage(
      topic,
      mqtt.MqttQos.atLeastOnce,
      builder.payload!,
      retain: retain,
    );
  }

  /// Retain bayrağı ile payload yayınlar.
  void publishRetained(String topic, String payload) {
    publish(topic, payload, retain: true);
  }

  // --- PRIVATE METHODS & CALLBACKS ---

  /// Gelen mesajları dinleyip Stream'e aktarır.
  void _setupMessageListener() {
    _client!.updates
        ?.listen((List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> c) {
      final mqtt.MqttPublishMessage recMess =
          c[0].payload as mqtt.MqttPublishMessage;
      final String payload = mqtt.MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message);

      _messagesController.add(MqttMessage(topic: c[0].topic, payload: payload));
    });
  }

  /// İlk kez bağlandığında tetiklenir.
  void _onConnected() {
    _connectionStatusController.add(MqttConnectionStatus.connected);
    _resubscribeToTopics();
  }

  /// Bağlantı koptuğunda tetiklenir.
  void _onDisconnected() {
    _connectionStatusController.add(MqttConnectionStatus.disconnected);
  }

  /// Otomatik reconnect başarılı olduğunda tetiklenir.
  void _onAutoReconnected() {
    _connectionStatusController.add(MqttConnectionStatus.connected);
    _resubscribeToTopics();
  }

  /// Bağlantı kurulduğunda önceden kayıtlı topic'lere tekrar abone olur.
  void _resubscribeToTopics() {
    for (var topic in _subscribedTopics) {
      _client?.subscribe(topic, mqtt.MqttQos.atLeastOnce);
    }
  }
}
