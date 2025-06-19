import 'package:drift/drift.dart';

class SyncMetadataTable extends Table {
  @override
  String get tableName => 'sync_metadata';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get key => text().unique()(); // 'last_sync', 'device_id', etc.
  TextColumn get value => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
