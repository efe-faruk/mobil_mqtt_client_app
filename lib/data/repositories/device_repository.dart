import 'package:drift/drift.dart';
import '../db/app_database.dart';

class DeviceRepository {
  final AppDatabase _db;

  DeviceRepository(this._db);

  /// Tüm cihazları anlık (reactive) olarak dinler.
  Stream<List<Device>> watchDevices() {
    return _db.select(_db.devices).watch();
  }

  /// Sadece belirli bir odaya ait cihazları anlık olarak dinler.
  Stream<List<Device>> watchDevicesByRoom(String roomId) {
    return (_db.select(_db.devices)..where((tbl) => tbl.roomId.equals(roomId)))
        .watch();
  }

  /// Tüm cihazları tek seferlik getirir.
  Future<List<Device>> getAllDevices() {
    return _db.select(_db.devices).get();
  }

  /// Yeni bir cihaz ekler.
  Future<int> addDevice(DevicesCompanion device) {
    return _db.into(_db.devices).insert(device);
  }

  /// Mevcut bir cihazı tüm özellikleriyle günceller.
  Future<bool> updateDevice(DevicesCompanion device) {
    return _db.update(_db.devices).replace(device);
  }

  /// ID'sine göre bir cihazı siler.
  Future<int> deleteDevice(String id) {
    return (_db.delete(_db.devices)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Kısmi Güncelleme: Bir sensörün veya cihazın son değerini günceller (Örn: 24.6).
  Future<int> updateDeviceLastValue(String deviceId, String lastValue) {
    return (_db.update(_db.devices)..where((tbl) => tbl.id.equals(deviceId)))
        .write(DevicesCompanion(lastValue: Value(lastValue)));
  }

  /// Kısmi Güncelleme: Bir switch cihazının açık/kapalı durumunu günceller.
  Future<int> updateSwitchState(String deviceId, bool isOn) {
    return (_db.update(_db.devices)..where((tbl) => tbl.id.equals(deviceId)))
        .write(DevicesCompanion(isOn: Value(isOn)));
  }
}
