import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeviceAddPage extends StatelessWidget {
  const DeviceAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz Ekle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/devices'),
        ),
      ),
      body: const Center(child: Text('Yeni MQTT Cihaz Tanımlama Ekranı')),
    );
  }
}
