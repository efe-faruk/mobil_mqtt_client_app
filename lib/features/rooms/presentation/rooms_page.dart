import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/db/app_database.dart'; // Room modeli için

class RoomsPage extends ConsumerWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Odaları veritabanından anlık (reactive) olarak dinliyoruz
    final roomsAsyncValue = ref.watch(roomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Odalar'),
      ),
      body: roomsAsyncValue.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildRoomsList(context, ref, rooms);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Odalar yüklenirken hata oluştu:\n$error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/rooms/edit'), // Yeni oda ekleme modu
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
            Icons.meeting_room_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz hiç oda eklemediniz.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Sağ alt köşedeki butona tıklayarak\nyeni bir oda oluşturabilirsiniz.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsList(
      BuildContext context, WidgetRef ref, List<Room> rooms) {
    return ListView.builder(
      padding:
          const EdgeInsets.all(16.0).copyWith(bottom: 80), // FAB için boşluk
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              // Kaydedilmiş iconCodePoint değerini tekrar Icon'a çeviriyoruz
              child: Icon(
                  IconData(room.iconCodePoint, fontFamily: 'MaterialIcons')),
            ),
            title: Text(
              room.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Sıra: ${room.sortOrder}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  // Odayı düzenlemek için extra parametresi ile yolluyoruz
                  context.go('/rooms/edit', extra: room);
                } else if (value == 'delete') {
                  _showDeleteDialog(context, ref, room);
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
                          size: 20, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Text('Sil',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref, Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odayı Sil'),
        content:
            Text('"${room.name}" odasını silmek istediğinize emin misiniz? '
                'Bu işlem geri alınamaz.'),
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
      // Repository üzerinden odayı siliyoruz
      await ref.read(roomRepositoryProvider).deleteRoom(room.id);
    }
  }
}
