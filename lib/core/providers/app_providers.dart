import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/device_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../data/repositories/settings_repository.dart';
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
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.loadBrokerConfig();
  }

  Future<void> updateConfig(BrokerConfig newConfig) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveBrokerConfig(newConfig);
    state = newConfig;
  }

  Future<void> resetConfig() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.clearBrokerConfig();
    state = repository.loadBrokerConfig();
  }
}

final brokerConfigProvider =
    NotifierProvider<BrokerConfigNotifier, BrokerConfig>(() {
  return BrokerConfigNotifier();
});

// ==========================================
// 5. MQTT Providers (Foreground Hazırlıklı Yapı)
// ==========================================

final mqttServiceProvider = Provider<MqttService>((ref) {
  final service = MqttService();
  ref.onDispose(() {
    service.disconnect();
  });
  return service;
});

final mqttConnectionStatusProvider =
    StreamProvider<MqttConnectionStatus>((ref) {
  final mqttService = ref.watch(mqttServiceProvider);
  return mqttService.connectionStatus;
});

final mqttMessagesProvider = StreamProvider<MqttMessage>((ref) {
  final mqttService = ref.watch(mqttServiceProvider);
  return mqttService.messages;
});

final mqttDeviceControllerProvider = Provider<MqttDeviceController>((ref) {
  final mqttService = ref.watch(mqttServiceProvider);
  final deviceRepo = ref.watch(deviceRepositoryProvider);

  final controller = MqttDeviceController(
    mqttService: mqttService,
    deviceRepository: deviceRepo,
  );

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});

/// Bağlantı durumunu dinleyip Controller'ı otomatik ayağa kaldıran Orkestratör.
final mqttOrchestratorProvider = Provider<void>((ref) {
  final statusAsync = ref.watch(mqttConnectionStatusProvider);

  statusAsync.whenData((status) {
    if (status == MqttConnectionStatus.connected) {
      // Bağlantı kurulduğunda cihazları çek ve subscribe ol
      ref.read(mqttDeviceControllerProvider).initialize();
    }
  });
});
