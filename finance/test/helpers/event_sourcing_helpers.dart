import 'dart:convert';
import 'package:drift/drift.dart';
import '../../lib/core/database/app_database.dart';
import '../../lib/core/sync/sync_event.dart';

/// ✅ PHASE 4.3: Event Sourcing Test Helpers
///
/// Provides utilities for testing event sourcing functionality in Phase 4.
/// Creates test events, batches, and validates event sourcing infrastructure.
class EventSourcingTestHelpers {
  /// Creates a test sync event log entry
  static SyncEventLogTableCompanion createTestEvent({
    required String operation,
    required String tableName,
    required String recordId,
    Map<String, dynamic>? data,
    String? deviceId,
    int sequenceNumber = 1,
    DateTime? timestamp,
    bool isSynced = false,
  }) {
    final eventData = data ?? {};
    final now = timestamp ?? DateTime.now();

    return SyncEventLogTableCompanion.insert(
      eventId: 'event-${now.millisecondsSinceEpoch}-${recordId}',
      deviceId: deviceId ?? 'test-device',
      tableNameField: tableName,
      recordId: recordId,
      operation: operation,
      data: jsonEncode(eventData),
      timestamp: now,
      sequenceNumber: sequenceNumber,
      hash: _generateTestHash(eventData),
      isSynced: Value(isSynced),
    );
  }

  /// Creates a SyncEvent object for testing CRDT conflict resolution
  static SyncEvent createSyncEvent({
    required String operation,
    required String tableName,
    required String recordId,
    Map<String, dynamic>? data,
    String? deviceId,
    int sequenceNumber = 1,
    DateTime? timestamp,
  }) {
    final eventData = data ?? {};
    final now = timestamp ?? DateTime.now();

    return SyncEvent(
      eventId: 'event-${now.millisecondsSinceEpoch}-${recordId}',
      deviceId: deviceId ?? 'test-device',
      tableName: tableName,
      recordId: recordId,
      operation: operation,
      data: eventData,
      timestamp: now,
      sequenceNumber: sequenceNumber,
      hash: _generateTestHash(eventData),
    );
  }

  /// Creates a batch of test events for the same record (for conflict testing)
  static List<SyncEvent> createConflictingEvents({
    required String recordId,
    required String tableName,
    List<String> deviceIds = const ['device1', 'device2'],
    Map<String, dynamic>? baseData,
  }) {
    final events = <SyncEvent>[];
    final base = baseData ?? {};
    final baseTime = DateTime.now();

    for (int i = 0; i < deviceIds.length; i++) {
      final deviceId = deviceIds[i];
      final eventData = Map<String, dynamic>.from(base);
      eventData['modified_by'] = deviceId;
      eventData['modification_time'] =
          baseTime.add(Duration(milliseconds: i * 100)).toIso8601String();

      events.add(createSyncEvent(
        operation: 'update',
        tableName: tableName,
        recordId: recordId,
        data: eventData,
        deviceId: deviceId,
        sequenceNumber: i + 1,
        timestamp: baseTime.add(Duration(milliseconds: i * 100)),
      ));
    }

    return events;
  }

  /// Creates test events for a transaction lifecycle (create -> update -> delete)
  static List<SyncEvent> createTransactionLifecycleEvents({
    required String syncId,
    String deviceId = 'test-device',
  }) {
    final baseTime = DateTime.now();

    return [
      // Create event
      createSyncEvent(
        operation: 'create',
        tableName: 'transactions',
        recordId: syncId,
        data: {
          'title': 'Test Transaction',
          'amount': 100.0,
          'category_id': 1,
          'account_id': 1,
          'sync_id': syncId,
        },
        deviceId: deviceId,
        sequenceNumber: 1,
        timestamp: baseTime,
      ),

      // Update event
      createSyncEvent(
        operation: 'update',
        tableName: 'transactions',
        recordId: syncId,
        data: {
          'title': 'Updated Transaction',
          'amount': 150.0,
          'category_id': 1,
          'account_id': 1,
          'sync_id': syncId,
        },
        deviceId: deviceId,
        sequenceNumber: 2,
        timestamp: baseTime.add(const Duration(minutes: 1)),
      ),

      // Delete event
      createSyncEvent(
        operation: 'delete',
        tableName: 'transactions',
        recordId: syncId,
        data: {'sync_id': syncId},
        deviceId: deviceId,
        sequenceNumber: 3,
        timestamp: baseTime.add(const Duration(minutes: 2)),
      ),
    ];
  }

  /// Inserts a batch of test events into the database
  static Future<void> insertTestEventBatch(
    AppDatabase database,
    List<SyncEventLogTableCompanion> events,
  ) async {
    for (final event in events) {
      await database.into(database.syncEventLogTable).insert(event);
    }
  }

  /// Creates and inserts sync state for testing
  static Future<void> createTestSyncState(
    AppDatabase database, {
    String deviceId = 'test-device',
    DateTime? lastSyncTime,
    int lastSequenceNumber = 0,
    String status = 'idle',
  }) async {
    await database.into(database.syncStateTable).insert(
          SyncStateTableCompanion.insert(
            deviceId: deviceId,
            lastSyncTime: lastSyncTime ?? DateTime.now(),
            lastSequenceNumber: Value(lastSequenceNumber),
            status: Value(status),
          ),
        );
  }

  /// Creates test events for multiple tables to test cross-table syncing
  static List<SyncEvent> createMultiTableEvents({
    String deviceId = 'test-device',
    DateTime? baseTime,
  }) {
    final base = baseTime ?? DateTime.now();

    return [
      // Account creation
      createSyncEvent(
        operation: 'create',
        tableName: 'accounts',
        recordId: 'test-acc-1',
        data: {
          'name': 'Test Account',
          'balance': 1000.0,
          'currency': 'USD',
          'sync_id': 'test-acc-1',
        },
        deviceId: deviceId,
        sequenceNumber: 1,
        timestamp: base,
      ),

      // Category creation
      createSyncEvent(
        operation: 'create',
        tableName: 'categories',
        recordId: 'test-cat-1',
        data: {
          'name': 'Test Category',
          'icon': '🛒',
          'color': 0xFF2196F3,
          'is_expense': true,
          'sync_id': 'test-cat-1',
        },
        deviceId: deviceId,
        sequenceNumber: 2,
        timestamp: base.add(const Duration(seconds: 1)),
      ),

      // Transaction creation (depends on account and category)
      createSyncEvent(
        operation: 'create',
        tableName: 'transactions',
        recordId: 'test-txn-1',
        data: {
          'title': 'Test Transaction',
          'amount': -50.0,
          'category_id': 1,
          'account_id': 1,
          'sync_id': 'test-txn-1',
        },
        deviceId: deviceId,
        sequenceNumber: 3,
        timestamp: base.add(const Duration(seconds: 2)),
      ),

      // Budget creation
      createSyncEvent(
        operation: 'create',
        tableName: 'budgets',
        recordId: 'test-budget-1',
        data: {
          'name': 'Test Budget',
          'amount': 500.0,
          'spent': 50.0,
          'period': 'monthly',
          'sync_id': 'test-budget-1',
        },
        deviceId: deviceId,
        sequenceNumber: 4,
        timestamp: base.add(const Duration(seconds: 3)),
      ),
    ];
  }

  /// Creates a SyncEventBatch for testing batch processing
  static SyncEventBatch createTestEventBatch({
    String deviceId = 'test-device',
    List<SyncEvent>? events,
    DateTime? timestamp,
  }) {
    return SyncEventBatch(
      deviceId: deviceId,
      timestamp: timestamp ?? DateTime.now(),
      events: events ?? createMultiTableEvents(deviceId: deviceId),
    );
  }

  /// Validates that events were created correctly by database triggers
  static Future<bool> validateTriggersCreatedEvents(
    AppDatabase database, {
    required String tableName,
    required String operation,
    String? recordId,
  }) async {
    final query = database.select(database.syncEventLogTable)
      ..where((t) => t.tableNameField.equals(tableName))
      ..where((t) => t.operation.equals(operation));

    if (recordId != null) {
      query.where((t) => t.recordId.equals(recordId));
    }

    final events = await query.get();
    return events.isNotEmpty;
  }

  /// Gets unsynced events from the database for testing
  static Future<List<SyncEventLogData>> getUnsyncedEvents(
    AppDatabase database, {
    String? deviceId,
    String? tableName,
  }) async {
    final query = database.select(database.syncEventLogTable)
      ..where((t) => t.isSynced.equals(false));

    if (deviceId != null) {
      query.where((t) => t.deviceId.equals(deviceId));
    }

    if (tableName != null) {
      query.where((t) => t.tableNameField.equals(tableName));
    }

    query.orderBy([(t) => OrderingTerm.asc(t.sequenceNumber)]);

    return await query.get();
  }

  /// Marks test events as synced
  static Future<void> markEventsAsSynced(
    AppDatabase database,
    List<String> eventIds,
  ) async {
    for (final eventId in eventIds) {
      await (database.update(database.syncEventLogTable)
            ..where((t) => t.eventId.equals(eventId)))
          .write(const SyncEventLogTableCompanion(
        isSynced: Value(true),
      ));
    }
  }

  /// Cleans up test events from database
  static Future<void> cleanupTestEvents(
    AppDatabase database, {
    String? deviceId,
  }) async {
    if (deviceId != null) {
      // Delete specific device events
      await (database.delete(database.syncEventLogTable)
            ..where((t) => t.deviceId.equals(deviceId)))
          .go();

      await (database.delete(database.syncStateTable)
            ..where((t) => t.deviceId.equals(deviceId)))
          .go();
    } else {
      // Delete all test events by using custom statement for pattern matching
      await database.customStatement(
          "DELETE FROM sync_event_log WHERE device_id LIKE 'test-%'");
      await database.customStatement(
          "DELETE FROM sync_state WHERE device_id LIKE 'test-%'");
    }
  }

  /// Generates a simple test hash for event data
  static String _generateTestHash(Map<String, dynamic> data) {
    // Remove sync metadata before hashing
    final cleanData = Map<String, dynamic>.from(data);
    cleanData.removeWhere((key, value) => [
          'sync_id',
          'created_at',
          'updated_at',
          'device_id',
          'is_synced',
          'last_sync_at',
          'version'
        ].contains(key));

    final sortedData = Map.fromEntries(
        cleanData.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

    return 'hash-${jsonEncode(sortedData).hashCode}';
  }

  /// Creates test events for performance testing
  static List<SyncEvent> createLargeEventBatch({
    int count = 1000,
    String deviceId = 'test-device',
    String tableName = 'transactions',
  }) {
    final events = <SyncEvent>[];
    final baseTime = DateTime.now();

    for (int i = 0; i < count; i++) {
      events.add(createSyncEvent(
        operation: 'create',
        tableName: tableName,
        recordId: 'test-record-$i',
        data: {
          'title': 'Test Transaction $i',
          'amount': i * 10.0,
          'category_id': 1,
          'account_id': 1,
          'sync_id': 'test-record-$i',
        },
        deviceId: deviceId,
        sequenceNumber: i + 1,
        timestamp: baseTime.add(Duration(milliseconds: i)),
      ));
    }

    return events;
  }
}

/// ✅ PHASE 4.3: Sync Event Batch
///
/// Represents a batch of sync events for testing batch operations
class SyncEventBatch {
  final String deviceId;
  final DateTime timestamp;
  final List<SyncEvent> events;

  const SyncEventBatch({
    required this.deviceId,
    required this.timestamp,
    required this.events,
  });

  /// Gets events grouped by table name
  Map<String, List<SyncEvent>> get eventsByTable {
    final grouped = <String, List<SyncEvent>>{};
    for (final event in events) {
      grouped.putIfAbsent(event.tableName, () => []).add(event);
    }
    return grouped;
  }

  /// Gets events grouped by record ID (for conflict detection)
  Map<String, List<SyncEvent>> get eventsByRecord {
    final grouped = <String, List<SyncEvent>>{};
    for (final event in events) {
      final key = '${event.tableName}:${event.recordId}';
      grouped.putIfAbsent(key, () => []).add(event);
    }
    return grouped;
  }

  /// Checks if this batch contains conflicts (multiple events for same record)
  bool get hasConflicts {
    return eventsByRecord.values.any((events) => events.length > 1);
  }
}
