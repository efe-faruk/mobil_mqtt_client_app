import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/rooms_table.dart';
import 'tables/devices_table.dart';

// Bu dosya build_runner tarafından üretilecek
part 'app_database.g.dart';

@DriftDatabase(tables: [Rooms, Devices])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  // Veritabanı dosyasının cihazda saklanacağı konumu belirliyoruz.
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'smart_home.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
