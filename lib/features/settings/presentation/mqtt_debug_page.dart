import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../mqtt/mqtt_service.dart';

class MqttDebugPage extends ConsumerStatefulWidget {
  const MqttDebugPage({super.key});

  @override
  ConsumerState<MqttDebugPage> createState() => _MqttDebugPageState();
}

class _MqttDebugPageState extends ConsumerState<MqttDebugPage> {
  final MqttService _mqttService = MqttService();

  // Controllers
  final _subTopicCtrl = TextEditingController();
  final _pubTopicCtrl = TextEditingController();
  final _pubPayloadCtrl = TextEditingController();

  // State
  bool _retain = false;
  MqttConnectionStatus _status = MqttConnectionStatus.disconnected;
  final List<MqttMessage> _messages = [];

  StreamSubscription? _statusSub;
  StreamSubscription? _msgSub;

  @override
  void initState() {
    super.initState();
    _listenToMqtt();
  }

  void _listenToMqtt() {
    _statusSub = _mqttService.connectionStatus.listen((status) {
      if (mounted) setState(() => _status = status);
    });

    _msgSub = _mqttService.messages.listen((msg) {
      if (mounted) {
        setState(() {
          _messages.insert(0, msg); // Yeni mesajlar en üste eklensin
        });
      }
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _msgSub?.cancel();
    _subTopicCtrl.dispose();
    _pubTopicCtrl.dispose();
    _pubPayloadCtrl.dispose();
    _mqttService.disconnect(); // Sayfa kapanınca test bağlantısını kes
    super.dispose();
  }

  void _connect() {
    // app_providers.dart içindeki notifer'dan mevcut broker ayarlarını alıyoruz
    final config = ref.read(brokerConfigProvider);
    _mqttService.connect(config);
  }

  void _disconnect() {
    _mqttService.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusSection(),
            const Divider(),
            _buildSubscribeSection(),
            const Divider(),
            _buildPublishSection(),
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

  Widget _buildStatusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.circle,
              color: _status == MqttConnectionStatus.connected
                  ? Colors.green
                  : (_status == MqttConnectionStatus.connecting
                      ? Colors.orange
                      : Colors.red),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _status.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed:
                  _status != MqttConnectionStatus.connected ? _connect : null,
              child: const Text('Connect'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _status == MqttConnectionStatus.connected
                  ? _disconnect
                  : null,
              child: const Text('Disconnect'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSubscribeSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _subTopicCtrl,
            decoration: const InputDecoration(
              labelText: 'Subscribe Topic',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () {
            if (_subTopicCtrl.text.isNotEmpty) {
              _mqttService.subscribe(_subTopicCtrl.text);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${_subTopicCtrl.text} abonesi olundu')),
              );
            }
          },
          child: const Text('Sub'),
        ),
      ],
    );
  }

  Widget _buildPublishSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pubTopicCtrl,
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
                  onChanged: (val) => setState(() => _retain = val),
                ),
                const Text('Retain'),
              ],
            ),
            FilledButton.icon(
              onPressed: () {
                if (_pubTopicCtrl.text.isNotEmpty &&
                    _pubPayloadCtrl.text.isNotEmpty) {
                  _mqttService.publish(
                    _pubTopicCtrl.text,
                    _pubPayloadCtrl.text,
                    retain: _retain,
                  );
                }
              },
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
