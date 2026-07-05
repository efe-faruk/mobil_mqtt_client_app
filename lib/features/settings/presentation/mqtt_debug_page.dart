import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../mqtt/mqtt_service.dart';
import '../../../models/broker_config.dart';

// ==========================================
// LOKAL DEBUG PROVIDER'LARI (Sadece bu sayfada yaşarlar)
// ==========================================
// Bu provider'lar autoDispose olduğu için sayfa kapandığında bellekten uçarlar.
final debugStatusProvider =
    StreamProvider.autoDispose<MqttConnectionStatus>((ref) {
  final service = ref.watch(debugMqttServiceProvider);
  return service.connectionStatus;
});

final debugMessagesProvider = StreamProvider.autoDispose<MqttMessage>((ref) {
  final service = ref.watch(debugMqttServiceProvider);
  return service.messages;
});

class MqttDebugPage extends ConsumerStatefulWidget {
  const MqttDebugPage({super.key});

  @override
  ConsumerState<MqttDebugPage> createState() => _MqttDebugPageState();
}

class _MqttDebugPageState extends ConsumerState<MqttDebugPage> {
  final _subTopicCtrl = TextEditingController();
  final _pubTopicCtrl = TextEditingController();
  final _pubPayloadCtrl = TextEditingController();

  bool _retain = false;
  final List<MqttMessage> _messages = [];

  @override
  void dispose() {
    _subTopicCtrl.dispose();
    _pubTopicCtrl.dispose();
    _pubPayloadCtrl.dispose();
    super.dispose();
  }

  void _connect() {
    // Global broker ayarlarını alıyoruz
    final globalConfig = ref.read(brokerConfigProvider);

    // ÇAKIŞMAYI ÖNLEMEK İÇİN: Sadece bu sayfaya özel yeni bir config oluşturuyoruz
    // ve orijinal clientId'nin sonuna '_debug' ekliyoruz.
    final debugConfig = BrokerConfig(
      host: globalConfig.host,
      port: globalConfig.port,
      clientId: '${globalConfig.clientId}_debug', // <-- KRİTİK DEĞİŞİKLİK
      keepAliveSeconds: globalConfig.keepAliveSeconds,
      useAuth: globalConfig.useAuth,
      username: globalConfig.username,
      password: globalConfig.password,
    );

    final mqttService = ref.read(debugMqttServiceProvider);

    // Orijinal globalConfig yerine, ismini değiştirdiğimiz debugConfig ile bağlanıyoruz
    mqttService.connect(debugConfig);
  }

  void _disconnect() {
    final mqttService = ref.read(debugMqttServiceProvider);
    mqttService.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    // Ana uygulamanın durumunu değil, lokal debug servisin durumunu dinliyoruz
    final connectionStatusAsync = ref.watch(debugStatusProvider);
    final status =
        connectionStatusAsync.value ?? MqttConnectionStatus.disconnected;

    // Hata durumunu yönetme
    ref.listen<AsyncValue<MqttConnectionStatus>>(
      debugStatusProvider,
      (previous, next) {
        next.whenData((newStatus) {
          if (newStatus == MqttConnectionStatus.fault) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Bağlantı başarısız! Broker ayarlarınızı kontrol edin.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      },
    );

    // Gelen lokal mesajları listeye ekleme
    ref.listen<AsyncValue<MqttMessage>>(
      debugMessagesProvider,
      (previous, next) {
        next.whenData((msg) {
          if (mounted) {
            setState(() {
              _messages.insert(0, msg);
            });
          }
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusSection(status),
            const Divider(),
            _buildSubscribeSection(status),
            const Divider(),
            _buildPublishSection(status),
            const Divider(),
            const Text('Gelen Mesajlar',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildMessagesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(MqttConnectionStatus status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.circle,
              color: status == MqttConnectionStatus.connected
                  ? Colors.green
                  : (status == MqttConnectionStatus.connecting
                      ? Colors.orange
                      : Colors.red),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              status.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed:
                  status != MqttConnectionStatus.connected ? _connect : null,
              child: const Text('Connect'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed:
                  status == MqttConnectionStatus.connected ? _disconnect : null,
              child: const Text('Disconnect'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSubscribeSection(MqttConnectionStatus status) {
    final isConnected = status == MqttConnectionStatus.connected;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _subTopicCtrl,
            enabled: isConnected,
            decoration: const InputDecoration(
              labelText: 'Subscribe Topic',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: isConnected
              ? () {
                  if (_subTopicCtrl.text.isNotEmpty) {
                    ref
                        .read(debugMqttServiceProvider)
                        .subscribe(_subTopicCtrl.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('${_subTopicCtrl.text} abonesi olundu')),
                    );
                  }
                }
              : null,
          child: const Text('Sub'),
        ),
      ],
    );
  }

  Widget _buildPublishSection(MqttConnectionStatus status) {
    final isConnected = status == MqttConnectionStatus.connected;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pubTopicCtrl,
                enabled: isConnected,
                decoration: const InputDecoration(
                  labelText: 'Publish Topic',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _pubPayloadCtrl,
                enabled: isConnected,
                decoration: const InputDecoration(
                  labelText: 'Payload',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Switch(
                  value: _retain,
                  onChanged: isConnected
                      ? (val) => setState(() => _retain = val)
                      : null,
                ),
                const Text('Retain'),
              ],
            ),
            FilledButton.icon(
              onPressed: isConnected
                  ? () {
                      if (_pubTopicCtrl.text.isNotEmpty &&
                          _pubPayloadCtrl.text.isNotEmpty) {
                        ref.read(debugMqttServiceProvider).publish(
                              _pubTopicCtrl.text,
                              _pubPayloadCtrl.text,
                              retain: _retain,
                            );
                      }
                    }
                  : null,
              icon: const Icon(Icons.send),
              label: const Text('Publish'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMessagesList() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: _messages.isEmpty
            ? const Center(child: Text('Henüz mesaj yok'))
            : ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return ListTile(
                    title: Text(msg.payload,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text(msg.topic, style: const TextStyle(fontSize: 12)),
                    dense: true,
                  );
                },
              ),
      ),
    );
  }
}
