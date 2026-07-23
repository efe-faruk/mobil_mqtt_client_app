import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';

// İlgili modellerin mevcut projenden import edildiği varsayılmıştır.
// Eğer henüz yoksa, projenin modellerine uygun olarak bunları kullanabilirsin.
import '../models/broker_config.dart';

enum MqttConnectionStatus { disconnected, connecting, connected, fault }

class MqttConnectionResult {
  final MqttConnectionStatus status;
  final String? error;

  const MqttConnectionResult({
    required this.status,
    this.error,
  });

  bool get isConnected => status == MqttConnectionStatus.connected;
}

class MqttMessage {
  final String topic;
  final String payload;

  MqttMessage({required this.topic, required this.payload});
}

class MqttService {
  MqttServerClient? _client;
  BrokerConfig? _activeConfig;
  final Set<String> _subscribedTopics = {};

  // Stream Controllers
  final _connectionStatusController =
      StreamController<MqttConnectionStatus>.broadcast();
  final _messagesController = StreamController<MqttMessage>.broadcast();

  // Public Streams
  Stream<MqttConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;
  Stream<MqttMessage> get messages => _messagesController.stream;
  BrokerConfig? get activeConfig => _activeConfig;

  /// Broker'a bağlanır ve gerekli callback'leri ayarlar.
  Future<MqttConnectionResult> connect(BrokerConfig config) async {
    if (_client != null &&
        _client!.connectionStatus?.state ==
            mqtt.MqttConnectionState.connected &&
        _activeConfig == config) {
      _connectionStatusController.add(MqttConnectionStatus.connected);
      return const MqttConnectionResult(
        status: MqttConnectionStatus.connected,
      );
    }

    final previousClient = _client;
    _client = null;
    _activeConfig = null;
    if (previousClient != null) {
      previousClient.autoReconnect = false;
      previousClient.disconnect();
    }

    _connectionStatusController.add(MqttConnectionStatus.connecting);

    final client = MqttServerClient(config.host, config.clientId)
      ..port = config.port
      ..logging(on: false)
      ..keepAlivePeriod = config.keepAliveSeconds
      ..autoReconnect = true;

    client.onDisconnected = () {
      _onDisconnected(client);
    };
    client.onConnected = () {
      _onConnected(client);
    };
    client.onAutoReconnected = () {
      _onAutoReconnected(client);
    };

    _client = client;

    final connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(config.clientId)
        .startClean()
        .withWillQos(mqtt.MqttQos.atLeastOnce);

    client.connectionMessage = connMess;

    try {
      await client.connect(
        config.useAuth ? config.username : null,
        config.useAuth ? config.password : null,
      );
    } catch (e) {
      _discardClient(client);
      _connectionStatusController.add(MqttConnectionStatus.fault);
      return MqttConnectionResult(
        status: MqttConnectionStatus.fault,
        error: 'Broker bağlantısı kurulamadı: $e',
      );
    }

    if (identical(_client, client) &&
        client.connectionStatus?.state ==
        mqtt.MqttConnectionState.connected) {
      _activeConfig = config;
      _connectionStatusController.add(MqttConnectionStatus.connected);
      _setupMessageListener(client);
      return const MqttConnectionResult(
        status: MqttConnectionStatus.connected,
      );
    } else {
      final returnCode = client.connectionStatus?.returnCode;
      _discardClient(client);
      _connectionStatusController.add(MqttConnectionStatus.fault);
      return MqttConnectionResult(
        status: MqttConnectionStatus.fault,
        error: returnCode == null
            ? 'Broker bağlantısı kurulamadı.'
            : 'Broker bağlantısı reddedildi: $returnCode',
      );
    }
  }

  /// Bağlantıyı sonlandırır ve stream'leri günceller.
  void disconnect() {
    final client = _client;
    _client = null;
    _activeConfig = null;
    client?.autoReconnect = false;
    client?.disconnect();
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
  void _setupMessageListener(MqttServerClient client) {
    client.updates
        ?.listen((List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> c) {
      if (!identical(_client, client)) return;

      final mqtt.MqttPublishMessage recMess =
          c[0].payload as mqtt.MqttPublishMessage;
      final String payload = mqtt.MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message);

      _messagesController.add(MqttMessage(topic: c[0].topic, payload: payload));
    });
  }

  void _onConnected(MqttServerClient client) {
    if (!identical(_client, client)) return;
    _connectionStatusController.add(MqttConnectionStatus.connected);
    _resubscribeToTopics();
  }

  void _onDisconnected(MqttServerClient client) {
    if (!identical(_client, client)) return;
    _connectionStatusController.add(MqttConnectionStatus.disconnected);
  }

  void _onAutoReconnected(MqttServerClient client) {
    if (!identical(_client, client)) return;
    _connectionStatusController.add(MqttConnectionStatus.connected);
    _resubscribeToTopics();
  }

  /// Bağlantı kurulduğunda önceden kayıtlı topic'lere tekrar abone olur.
  void _resubscribeToTopics() {
    for (var topic in _subscribedTopics) {
      _client?.subscribe(topic, mqtt.MqttQos.atLeastOnce);
    }
  }

  void _discardClient(MqttServerClient client) {
    if (identical(_client, client)) {
      _client = null;
      _activeConfig = null;
    }
    client.autoReconnect = false;
    client.disconnect();
  }
}
