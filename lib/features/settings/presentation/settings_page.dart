import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.router_outlined),
            title: const Text('MQTT Broker Ayarları'),
            subtitle: const Text('Sunucu, port ve kimlik doğrulama'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/settings/broker');
            },
          ),
          const Divider(),
          // BÖCEK İKONLU DEBUG GEÇİŞİ :)
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('MQTT Debug'),
            subtitle: const Text('Geliştirici test sayfası'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/settings/mqtt-debug');
            },
          ),
        ],
      ),
    );
  }
}
