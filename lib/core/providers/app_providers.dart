import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/device_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../models/broker_config.dart';

// ==========================================
// 1. Core & Dependency Providers
// ==========================================

/// SharedPreferences nesnesi asenkron başlatıldığı için main.dart içinde override edilmelidir.
/// Örnek: ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], ...)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main.dart');
});

/// Drift veritabanı instance'ını sağlar.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  // Uygulama kapandığında veritabanı bağlantısını güvenli bir şekilde kapatır.
  ref.onDispose(() {
    db.close();
  });

  return db;
});

// ==========================================
// 2. Repository Providers
// ==========================================

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RoomRepository(db);
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DeviceRepository(db);
});

// ==========================================
// 3. Data (Stream) Providers
// ==========================================

/// Drift veritabanındaki odaları anlık (reactive) olarak dinler.
final roomsProvider = StreamProvider<List<Room>>((ref) {
  final roomRepo = ref.watch(roomRepositoryProvider);
  return roomRepo.watchRooms();
});

/// Drift veritabanındaki cihazları anlık (reactive) olarak dinler.
final devicesProvider = StreamProvider<List<Device>>((ref) {
  final deviceRepo = ref.watch(deviceRepositoryProvider);
  return deviceRepo.watchDevices();
});

// ==========================================
// 4. State & Config Providers
// ==========================================

/// Broker ayarlarını yöneten ve UI'ı güncelleyen Notifier.
class BrokerConfigNotifier extends Notifier<BrokerConfig> {
  @override
  BrokerConfig build() {
    // Uygulama açıldığında kayıtlı ayarları yükle
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.loadBrokerConfig();
  }

  /// Yeni ayarları hem cihaza kaydeder hem de Riverpod state'ini günceller.
  Future<void> updateConfig(BrokerConfig newConfig) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveBrokerConfig(newConfig);
    state =
        newConfig; // Bu atama, bu provider'ı dinleyen tüm UI bileşenlerini yeniden çizer.
  }

  /// Ayarları varsayılana sıfırlar.
  Future<void> resetConfig() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.clearBrokerConfig();
    state = repository.loadBrokerConfig(); // Varsayılan ayarlara dön
  }
}

final brokerConfigProvider =
    NotifierProvider<BrokerConfigNotifier, BrokerConfig>(() {
  return BrokerConfigNotifier();
});
