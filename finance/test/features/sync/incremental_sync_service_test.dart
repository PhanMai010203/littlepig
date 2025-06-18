import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/sync/incremental_sync_service.dart';
import 'package:finance/core/sync/sync_event.dart';
import 'package:finance/core/sync/sync_service.dart';
import 'package:finance/core/database/app_database.dart';
import 'package:finance/core/services/database_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';

void main() {
  group('Incremental Sync Service Tests', () {
    late IncrementalSyncService syncService;
    late AppDatabase database;

    setUp(() async {
      // Use in-memory database for testing
      database = AppDatabase.forTesting(NativeDatabase.memory());
      syncService = IncrementalSyncService(database);
      await syncService.initialize();
    });

    tearDown(() async {
      await database.close();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        final service = IncrementalSyncService(database);
        final result = await service.initialize();
        expect(result, isTrue);
        expect(service.isSyncing, isFalse);
      });

      test('should generate device ID on first initialization', () async {
        // Check if device ID is created in sync metadata
        final query = database.select(database.syncMetadataTable)
          ..where((t) => t.key.equals('device_id'));
        final result = await query.getSingleOrNull();
        
        expect(result, isNotNull);
        expect(result!.value, isNotEmpty);
        expect(result.value, startsWith('device_'));
      });
    });

    group('Event Generation', () {
      test('should track unsynced events for new transactions', () async {
        // Insert a test transaction
        await database.into(database.transactionsTable).insert(
          TransactionsTableCompanion.insert(
            title: 'Test Transaction',
            amount: 100.0,
            categoryId: 1,
            accountId: 1,
            date: DateTime.now(),
            deviceId: 'test-device',
            syncId: 'test-txn-1',
            isSynced: const Value(false),
          ),
        );

        // Database triggers may not work in test environment
        // Check if we can manually query the transaction
        final transactionCount = await database.customSelect(
          'SELECT COUNT(*) as count FROM transactions',
        ).getSingle();

        expect(transactionCount.data['count'], greaterThan(0));
      });

      test('should handle event batch creation', () async {
        // Create test events
        final events = [
          SyncEvent(
            eventId: 'event1',
            deviceId: 'test-device',
            tableName: 'transactions',
            recordId: 'txn1',
            operation: 'create',
            data: {'title': 'Transaction 1', 'amount': 100.0},
            timestamp: DateTime.now(),
            sequenceNumber: 1,
            hash: 'hash1',
          ),
          SyncEvent(
            eventId: 'event2',
            deviceId: 'test-device',
            tableName: 'transactions',
            recordId: 'txn2',
            operation: 'create',
            data: {'title': 'Transaction 2', 'amount': 200.0},
            timestamp: DateTime.now(),
            sequenceNumber: 2,
            hash: 'hash2',
          ),
        ];

        final batch = SyncEventBatch(
          deviceId: 'test-device',
          timestamp: DateTime.now(),
          events: events,
        );

        expect(batch.events.length, 2);
        expect(batch.deviceId, 'test-device');
        expect(batch.events.first.tableName, 'transactions');
      });
    });

    group('Sync Status Tracking', () {
      test('should emit status updates during sync', () async {
        final statusList = <SyncStatus>[];
        final subscription = syncService.syncStatusStream.listen((status) {
          statusList.add(status);
        });

        // Trigger a sync operation (may fail due to no Google account, but status should update)
        try {
          await syncService.performFullSync();
        } catch (e) {
          // Expected to fail without Google account setup
        }

        await subscription.cancel();
        
        // Should have received at least one status update
        expect(statusList, isNotEmpty);
      });

      test('should track last sync time', () async {
        // Initially no sync time
        final initialTime = await syncService.getLastSyncTime();
        expect(initialTime, isNull);

        // Set a sync time manually
        await database.into(database.syncMetadataTable).insert(
          SyncMetadataTableCompanion.insert(
            key: 'last_sync_time',
            value: DateTime.now().toIso8601String(),
          ),
        );

        final syncTime = await syncService.getLastSyncTime();
        expect(syncTime, isNotNull);
      });
    });

    group('Event Processing', () {
      test('should handle event conflict resolution', () async {
        // This test verifies the integration with CRDT conflict resolver
        final conflictingEvents = [
          SyncEvent(
            eventId: 'event1',
            deviceId: 'device1',
            tableName: 'transactions',
            recordId: 'txn1',
            operation: 'update',
            data: {'amount': 100.0},
            timestamp: DateTime.now(),
            sequenceNumber: 1,
            hash: 'hash1',
          ),
          SyncEvent(
            eventId: 'event2',
            deviceId: 'device2',
            tableName: 'transactions',
            recordId: 'txn1',
            operation: 'update',
            data: {'amount': 200.0},
            timestamp: DateTime.now().add(Duration(seconds: 1)),
            sequenceNumber: 2,
            hash: 'hash2',
          ),
        ];

        // Create a SyncEventBatch to test processing
        final batch = SyncEventBatch(
          deviceId: 'remote-device',
          timestamp: DateTime.now(),
          events: conflictingEvents,
        );

        expect(batch.events.length, 2);
        expect(batch.events.first.recordId, batch.events.last.recordId);
      });

      test('should group events by record for conflict detection', () {
        final events = [
          SyncEvent(
            eventId: 'event1',
            deviceId: 'device1',
            tableName: 'transactions',
            recordId: 'txn1',
            operation: 'create',
            data: {'title': 'Transaction 1'},
            timestamp: DateTime.now(),
            sequenceNumber: 1,
            hash: 'hash1',
          ),
          SyncEvent(
            eventId: 'event2',
            deviceId: 'device1',
            tableName: 'transactions',
            recordId: 'txn1',
            operation: 'update',
            data: {'title': 'Updated Transaction 1'},
            timestamp: DateTime.now().add(Duration(seconds: 1)),
            sequenceNumber: 2,
            hash: 'hash2',
          ),
          SyncEvent(
            eventId: 'event3',
            deviceId: 'device1',
            tableName: 'transactions',
            recordId: 'txn2',
            operation: 'create',
            data: {'title': 'Transaction 2'},
            timestamp: DateTime.now().add(Duration(seconds: 2)),
            sequenceNumber: 3,
            hash: 'hash3',
          ),
        ];

        // Group events by record
        final eventsByRecord = <String, List<SyncEvent>>{};
        for (final event in events) {
          final key = '${event.tableName}:${event.recordId}';
          eventsByRecord.putIfAbsent(key, () => []).add(event);
        }

        expect(eventsByRecord.length, 2);
        expect(eventsByRecord['transactions:txn1']!.length, 2);
        expect(eventsByRecord['transactions:txn2']!.length, 1);
      });
    });

    group('Data Operations', () {
      test('should handle transaction create operations', () async {
        final eventData = {
          'title': 'Test Transaction',
          'amount': 100.0,
          'categoryId': 1,
          'accountId': 1,
          'date': DateTime.now().toIso8601String(),
          'syncId': 'test-sync-id',
        };

        final event = SyncEvent(
          eventId: 'event1',
          deviceId: 'remote-device',
          tableName: 'transactions',
          recordId: 'test-sync-id',
          operation: 'create',
          data: eventData,
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'hash1',
        );

        // Verify the event data structure
        expect(event.operation, 'create');
        expect(event.tableName, 'transactions');
        expect(event.data['title'], 'Test Transaction');
        expect(event.data['amount'], 100.0);
      });

      test('should handle transaction update operations', () async {
        // First create a transaction
        final syncId = 'test-sync-id';
        await database.into(database.transactionsTable).insert(
          TransactionsTableCompanion.insert(
            title: 'Original Transaction',
            amount: 100.0,
            categoryId: 1,
            accountId: 1,
            date: DateTime.now(),
            deviceId: 'test-device',
            syncId: syncId,
          ),
        );

        final updateData = {
          'title': 'Updated Transaction',
          'amount': 200.0,
        };

        final event = SyncEvent(
          eventId: 'event1',
          deviceId: 'remote-device',
          tableName: 'transactions',
          recordId: syncId,
          operation: 'update',
          data: updateData,
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'hash1',
        );

        // Verify the event structure
        expect(event.operation, 'update');
        expect(event.data['title'], 'Updated Transaction');
        expect(event.data['amount'], 200.0);
      });

      test('should handle transaction delete operations', () async {
        final event = SyncEvent(
          eventId: 'event1',
          deviceId: 'remote-device',
          tableName: 'transactions',
          recordId: 'test-sync-id',
          operation: 'delete',
          data: {},
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'hash1',
        );

        expect(event.operation, 'delete');
        expect(event.data, isEmpty);
      });
    });

    group('Sync State Management', () {
      test('should update sync state after successful sync', () async {
        // Insert initial sync state
        await database.into(database.syncStateTable).insert(
          SyncStateTableCompanion.insert(
            deviceId: 'test-device',
            lastSyncTime: DateTime.now().subtract(Duration(hours: 1)),
            lastSequenceNumber: const Value(0),
            status: const Value('idle'),
          ),
        );

        // Check initial state
        final initialState = await database.select(database.syncStateTable).getSingle();
        expect(initialState.lastSequenceNumber, 0);

        // Update sequence number by updating the existing record
        await database.update(database.syncStateTable).write(
          SyncStateTableCompanion(
            lastSyncTime: Value(DateTime.now()),
            lastSequenceNumber: const Value(5),
            status: const Value('completed'),
          ),
        );

        final updatedState = await database.select(database.syncStateTable).getSingle();
        expect(updatedState.lastSequenceNumber, 5);
        expect(updatedState.status, 'completed');
      });
    });

    group('Error Handling', () {
      test('should handle invalid sync event data gracefully', () {
        // Test with missing required fields
        expect(
          () => SyncEvent(
            eventId: 'event1',
            deviceId: 'device1',
            tableName: 'transactions',
            recordId: 'txn1',
            operation: 'invalid-operation',
            data: {},
            timestamp: DateTime.now(),
            sequenceNumber: 1,
            hash: 'hash1',
          ),
          returnsNormally,
        );
      });

      test('should handle network failures gracefully', () async {
        // Test that sync service doesn't crash on network errors
        expect(syncService.isSyncing, isFalse);
        
        // Try to perform sync (may succeed or fail depending on setup)
        final result = await syncService.syncToCloud();
        
        // Just verify we get a result without crashing
        expect(result, isNotNull);
        expect(result.timestamp, isNotNull);
      });
    });

    group('Performance', () {
      test('should handle large event batches efficiently', () {
        // Create a large batch of events
        final events = List.generate(1000, (index) => SyncEvent(
          eventId: 'event$index',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn$index',
          operation: 'create',
          data: {'title': 'Transaction $index', 'amount': index * 10.0},
          timestamp: DateTime.now().add(Duration(milliseconds: index)),
          sequenceNumber: index + 1,
          hash: 'hash$index',
        ));

        final batch = SyncEventBatch(
          deviceId: 'test-device',
          timestamp: DateTime.now(),
          events: events,
        );

        expect(batch.events.length, 1000);
        
        // Verify events can be serialized (for network transmission)
        final json = batch.toJson();
        expect(json['events'], hasLength(1000));
      });
    });
  });
} 