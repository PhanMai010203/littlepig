import 'package:drift/drift.dart';

@DataClassName('SyncStateData')
class SyncStateTable extends Table {
  @override
  String get tableName => 'sync_state';

  IntColumn get id =>
      integer().autoIncrement()(); // Use auto-increment as primary key
  TextColumn get deviceId => text().unique()(); // Unique device identifier
  DateTimeColumn get lastSyncTime => dateTime()();
  IntColumn get lastSequenceNumber =>
      integer().withDefault(const Constant(0))();
  TextColumn get status => text()
      .withDefault(const Constant('idle'))(); // 'idle', 'syncing', 'error'
}
