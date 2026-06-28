import 'package:drift/drift.dart';
import '../db/app_database.dart';

class RoomRepository {
  final AppDatabase _db;

  RoomRepository(this._db);

  /// Tüm odaları anlık (reactive) olarak dinler. SortOrder'a göre sıralar.
  Stream<List<Room>> watchRooms() {
    return (_db.select(_db.rooms)
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  /// Tüm odaları tek seferlik (Future) getirir.
  Future<List<Room>> getAllRooms() {
    return (_db.select(_db.rooms)
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  /// Yeni bir oda ekler.
  Future<int> addRoom(RoomsCompanion room) {
    return _db.into(_db.rooms).insert(room);
  }

  /// Mevcut bir odayı günceller.
  Future<bool> updateRoom(RoomsCompanion room) {
    return _db.update(_db.rooms).replace(room);
  }

  /// ID'sine göre bir odayı siler.
  Future<int> deleteRoom(String id) {
    return (_db.delete(_db.rooms)..where((tbl) => tbl.id.equals(id))).go();
  }
}
