import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Odalar')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => context.go('/rooms/edit'),
          icon: const Icon(Icons.edit),
          label: const Text('Oda Düzenleme Sayfasına Git'),
        ),
      ),
    );
  }
}
