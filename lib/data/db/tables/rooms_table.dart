import 'package:drift/drift.dart';

class Rooms extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
