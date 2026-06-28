import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/db/app_database.dart'; // Device ve Room modelleri için

class DevicesPage extends ConsumerWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsyncValue = ref.watch(devicesProvider);
    final roomsAsyncValue = ref.watch(roomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihazlar'),
      ),
      body: devicesAsyncValue.when(
        data: (devices) {
          if (devices.isEmpty) {
            return _buildEmptyState(context);
          }

          // Odalar yüklenmişse id'ye göre mapleyelim (hızlı erişim için)
          final Map<String, String> roomNames = {};
          if (roomsAsyncValue.hasValue) {
            for (var room in roomsAsyncValue.value!) {
              roomNames[room.id] = room.name;
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              final roomName = roomNames[device.roomId] ?? 'Bilinmeyen Oda';

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    child: Icon(IconData(device.iconCodePoint,
                        fontFamily: 'MaterialIcons')),
                  ),
                  title: Text(
                    device.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      '$roomName • ${device.type == 'switch' ? 'Anahtar' : 'Sensör'}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.go('/devices/edit/${device.id}');
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, ref, device);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 8),
                            Text('Sil',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Cihazlar yüklenirken hata oluştu:\n$error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/devices/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.developer_board_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz cihaz eklemediniz.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Sağ alt köşedeki butona tıklayarak\ncihaz kurulumu yapabilirsiniz.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref, Device device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cihazı Sil'),
        content: Text(
            '"${device.name}" adlı cihazı silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(deviceRepositoryProvider).deleteDevice(device.id);
    }
  }
}
