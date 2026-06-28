import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cihazlar')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go('/devices/add'),
              icon: const Icon(Icons.add),
              label: const Text('Yeni Cihaz Ekle'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/devices/edit/esp32_relay_01'),
              icon: const Icon(Icons.settings_remote),
              label: const Text(
                  'ESP32 Röle Cihazını Düzenle (ID: esp32_relay_01)'),
            ),
          ],
        ),
      ),
    );
  }
}
