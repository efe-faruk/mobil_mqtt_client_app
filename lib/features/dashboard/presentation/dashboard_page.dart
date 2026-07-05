import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/db/app_database.dart';
import 'widgets/connection_status_card.dart';
import 'widgets/device_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    final devicesAsync = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ev Özeti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {}, // İleride eklenebilir
          ),
        ],
      ),
      // Hata kontrolü, yükleme kontrolü ve içerik gösterimi
      body: _buildBody(context, roomsAsync, devicesAsync),
    );
  }

  // Okunabilirliği artırmak için gövdeyi dışarı çıkardık
  Widget _buildBody(
    BuildContext context,
    AsyncValue<List<Room>> roomsAsync,
    AsyncValue<List<Device>> devicesAsync,
  ) {
    // 1. Herhangi bir provider'da hata varsa hata ekranı göster
    if (roomsAsync.hasError || devicesAsync.hasError) {
      return Center(
        child: Text(
          'Veriler yüklenirken hata oluştu!',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    // 2. İlk yüklenme aşamasındaysa spinner göster
    // (isLoading, veri varken true dönmez, bu sayede sensör güncellenirken ekran titremez)
    if (roomsAsync.isLoading || devicesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 3. Veriler başarıyla geldiyse ana içeriği çiz
    return _buildDashboardContent(
        context, roomsAsync.value, devicesAsync.value);
  }

  Widget _buildDashboardContent(
      BuildContext context, List<Room>? rooms, List<Device>? devices) {
    // Güvenlik kontrolleri
    final safeRooms = rooms ?? [];
    final safeDevices = devices ?? [];

    if (safeRooms.isEmpty && safeDevices.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // En Üstte Bağlantı Durumu
        const ConnectionStatusCard(),

        // Odalara Göre Cihazları Gruplama
        ...safeRooms.map((room) {
          // Bu odaya ait cihazları filtrele
          final roomDevices =
              safeDevices.where((d) => d.roomId == room.id).toList();

          // Eğer odada cihaz yoksa bu bloğu çizme
          if (roomDevices.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Oda Başlığı
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Icon(
                      IconData(room.iconCodePoint, fontFamily: 'MaterialIcons'),
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      room.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

              // Cihaz Grid'i (2 Sütunlu)
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Scroll yetkisini ListView'a bırak
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1, // Kartların en-boy oranı
                ),
                itemCount: roomDevices.length,
                itemBuilder: (context, index) {
                  return DeviceCard(device: roomDevices[index]);
                },
              ),
              const SizedBox(height: 24), // Odalar arası boşluk
            ],
          );
        }), // map().toList() yerine spread operator (...) kullandık
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Ev tamamen boş',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Odalar ve Cihazlar sekmelerinden\nyeni kurulumlar yapabilirsiniz.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
