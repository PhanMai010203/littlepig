import 'package:drift/drift.dart';

// ✅ PHASE 2: Event Sourcing Tables

@DataClassName('SyncEventLogData')
class SyncEventLogTable extends Table {
  @override
  String get tableName => 'sync_event_log';

  IntColumn get id =>
      integer().autoIncrement()(); // Use auto-increment as primary key
  TextColumn get eventId => text().unique()(); // UUID for event identification
  TextColumn get deviceId => text()();
  TextColumn get tableNameField => text()(); // 'transactions', 'budgets', etc.
  TextColumn get recordId => text()(); // Record's syncId
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get data => text()(); // JSON payload
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get sequenceNumber => integer()(); // Per-device ordering
  TextColumn get hash => text()(); // Content hash for deduplication
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
