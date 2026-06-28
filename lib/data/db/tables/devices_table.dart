import 'package:drift/drift.dart';

class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get roomId => text()(); // Rooms tablosundaki id ile eşleşecek
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'switch' veya 'sensor'
  TextColumn get topicSet => text().nullable()();
  TextColumn get topicState => text()();
  TextColumn get lastValue => text().nullable()();
  BoolColumn get isOn => boolean().nullable()();
  IntColumn get iconCodePoint => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
