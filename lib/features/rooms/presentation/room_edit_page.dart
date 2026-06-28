import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoomEditPage extends StatelessWidget {
  const RoomEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oda Düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/rooms'),
        ),
      ),
      body: const Center(child: Text('Oda Ekleme / Düzenleme Alanı')),
    );
  }
}
