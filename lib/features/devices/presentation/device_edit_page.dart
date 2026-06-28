import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeviceEditPage extends StatelessWidget {
  final String deviceId;

  const DeviceEditPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihazı Düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/devices'),
        ),
      ),
      body: Center(
        child: Text('Düzenlenen Cihaz Benzersiz ID Bilgisi: $deviceId'),
      ),
    );
  }
}
