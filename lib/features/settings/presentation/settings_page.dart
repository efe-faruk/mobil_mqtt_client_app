import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => context.go('/settings/broker'),
          icon: const Icon(Icons.router),
          label: const Text('MQTT Broker Ayarlarına Git'),
        ),
      ),
    );
  }
}
