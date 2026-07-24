import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../foreground/isolate_communicator.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/device_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/storage/secure_settings_storage.dart';
import '../../models/broker_config.dart';
import '../../mqtt/mqtt_service.dart';
import '../../mqtt/mqtt_device_controller.dart';

// ==========================================
// 1. Core & Dependency Providers
// ==========================================

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main.dart');
});

final secureSettingsStorageProvider = Provider<SecureSettingsStorage>((ref) {
  return const FlutterSecureSettingsStorage();
});

final initialBrokerConfigProvider = Provider<BrokerConfig>((ref) {
  throw UnimplementedError(
      'initialBrokerConfigProvider must be overridden in main.dart');
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
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
  final secureStorage = ref.watch(secureSettingsStorageProvider);
  return SettingsRepository(prefs, secureStorage);
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

final roomsProvider = StreamProvider<List<Room>>((ref) {
  final roomRepo = ref.watch(roomRepositoryProvider);
  return roomRepo.watchRooms();
});

final devicesProvider = StreamProvider<List<Device>>((ref) {
  final deviceRepo = ref.watch(deviceRepositoryProvider);
  return deviceRepo.watchDevices();
});

// ==========================================
// 4. State & Config Providers
// ==========================================

class BrokerConfigNotifier extends Notifier<BrokerConfig> {
  @override
  BrokerConfig build() {
    return ref.watch(initialBrokerConfigProvider);
  }

  Future<void> updateConfig(BrokerConfig newConfig) async {
    final repository = ref.read(settingsRepositoryProvider);

    // Tek kaydetme işleminin sırası:
    // 1. Kalıcılaştır, 2. Riverpod durumunu güncelle,
    // 3. Foreground servise uygulat ve o isteğin bağlantı sonucunu bekle.
    await repository.saveBrokerConfig(newConfig);
    state = newConfig;
    await ref
        .read(isolateCommunicatorProvider)
        .updateBrokerConfig(newConfig);
  }

  Future<void> resetConfig() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.clearBrokerConfig();
    state = await repository.loadBrokerConfig();
  }
}

final brokerConfigProvider =
    NotifierProvider<BrokerConfigNotifier, BrokerConfig>(() {
  return BrokerConfigNotifier();
});

// ==========================================
// 5. Isolate & Foreground Communication Providers
// ==========================================

// UI, bağlantı durumunu doğrudan servisten değil, Notifier'dan okur.
class MqttConnectionStatusNotifier extends Notifier<String> {
  @override
  String build() => 'disconnected';

  void setStatus(String newStatus) {
    state = newStatus;
  }
}

final mqttConnectionStatusProvider =
    NotifierProvider<MqttConnectionStatusNotifier, String>(() {
  return MqttConnectionStatusNotifier();
});

// UI'dan arka plana komut göndermek için kullanılacak aracı.
final isolateCommunicatorProvider = Provider<IsolateCommunicator>((ref) {
  final communicator = IsolateCommunicator(ref);
  ref.onDispose(() => communicator.dispose());
  return communicator;
});

// Cihazları yönetecek ve komutları arka plana iletecek Controller
final mqttDeviceControllerProvider = Provider<MqttDeviceController>((ref) {
  final deviceRepo = ref.watch(deviceRepositoryProvider);

  // DİKKAT: Birazdan mqtt_device_controller.dart dosyasını bu yapıya göre güncelleyeceğiz.
  return MqttDeviceController(
    ref: ref,
    deviceRepository: deviceRepo,
  );
});

// app_router.dart'ın hata vermemesi için Orkestratörü geri ekliyoruz
final mqttOrchestratorProvider = Provider<void>((ref) {
  final status = ref.watch(mqttConnectionStatusProvider);

  if (status == 'connected') {
    // Bağlantı kurulduğunda cihazları çek ve abone ol işlemleri burada tetiklenebilir
    ref.read(mqttDeviceControllerProvider).initialize();
  }
});

// ==========================================
// 6. DEBUG EKRANI İÇİN BAĞIMSIZ PROVIDER
// ==========================================
// autoDispose sayesinde bu provider sadece Debug ekranında (dinlendiği sürece) yaşar.
// Ekrandan çıkıldığı an (dinleyici kalmadığında) onDispose tetiklenir ve istemci çökertilir.
final debugMqttServiceProvider = Provider.autoDispose<MqttService>((ref) {
  final service = MqttService();

  ref.onDispose(() {
    service.disconnect(); // Ekrandan çıkınca bağlantıyı kopart ve yok et
  });

  return service;
});
