import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/sync/sync_state_manager.dart';
import '../../../lib/core/sync/sync_event.dart';
import '../../../lib/core/database/app_database.dart';
import 'package:drift/drift.dart';
import '../../helpers/test_database_setup.dart';
import '../../helpers/event_sourcing_helpers.dart';

void main() {
  group('SyncStateManager Tests - Phase 5A', () {
    late AppDatabase database;
    late SyncStateManager stateManager;

    setUp(() async {
      database = await TestDatabaseSetup.createCleanTestDatabase();
      stateManager = SyncStateManager(database);
      await stateManager.initialize();
    });

    tearDown(() async {
      stateManager.dispose();
      await database.close();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        final newStateManager = SyncStateManager(database);
        await newStateManager.initialize();
        // Initialization should complete without throwing
        expect(true, isTrue);
        newStateManager.dispose();
      });

      test('should create device state in database', () async {
        final states = await database.select(database.syncStateTable).get();
        expect(states.length, equals(1));
        expect(states.first.deviceId, isNotEmpty);
        expect(states.first.status, equals('idle'));
      });
    });

    group('Sync State Management', () {
      test('should start sync with correct state', () async {
        final states = <SyncState>[];
        stateManager.syncStateStream.listen(states.add);

        await stateManager.startSync(
          state: SyncState.uploading,
          totalEvents: 10,
          statusMessage: 'Starting upload...',
        );

        await Future.delayed(Duration(milliseconds: 10));

        expect(states.isNotEmpty, isTrue);
        expect(states.last, equals(SyncState.uploading));
      });

      test('should update progress correctly', () async {
        final progressUpdates = <SyncProgress>[];
        stateManager.syncProgressStream.listen(progressUpdates.add);

        await stateManager.startSync(
          state: SyncState.processing,
          totalEvents: 100,
          statusMessage: 'Processing events...',
        );

        await stateManager.updateProgress(
          processedEvents: 50,
          statusMessage: 'Half way done...',
        );

        await Future.delayed(Duration(milliseconds: 10));

        expect(progressUpdates.length, greaterThan(1));
        final lastProgress = progressUpdates.last;
        expect(lastProgress.processedEvents, equals(50));
        expect(lastProgress.progressPercentage, equals(50.0));
        expect(lastProgress.statusMessage, equals('Half way done...'));
      });

      test('should complete sync with success', () async {
        final states = <SyncState>[];
        stateManager.syncStateStream.listen(states.add);

        await stateManager.startSync(
          state: SyncState.uploading,
          totalEvents: 10,
        );

        await stateManager.completeSync(
          success: true,
          message: 'Sync completed successfully',
        );

        await Future.delayed(Duration(milliseconds: 10));

        expect(states.contains(SyncState.completed), isTrue);
      });

      test('should complete sync with error', () async {
        final progressUpdates = <SyncProgress>[];
        stateManager.syncProgressStream.listen(progressUpdates.add);

        await stateManager.startSync(
          state: SyncState.uploading,
          totalEvents: 10,
        );

        await stateManager.completeSync(
          success: false,
          message: 'Sync failed with error',
        );

        await Future.delayed(Duration(milliseconds: 10));

        final lastProgress = progressUpdates.last;
        expect(lastProgress.state, equals(SyncState.error));
        expect(lastProgress.statusMessage, equals('Sync failed with error'));
      });
    });

    group('Device Management', () {
      test('should track device sync progress', () async {
        final deviceId = 'test-device-123';
        final sequenceNumber = 42;

        await stateManager.updateSyncProgress(deviceId, sequenceNumber);

        final devices = await stateManager.getActiveDevices();
        expect(devices, contains(deviceId));
      });

      test('should get device information list', () async {
        // Add some test devices
        await database.into(database.syncStateTable).insert(
              SyncStateTableCompanion.insert(
                deviceId: 'android_device_1',
                lastSyncTime: DateTime.now(),
                lastSequenceNumber: const Value(10),
                status: const Value('idle'),
              ),
            );

        await database.into(database.syncStateTable).insert(
              SyncStateTableCompanion.insert(
                deviceId: 'ios_device_2',
                lastSyncTime: DateTime.now().subtract(Duration(hours: 1)),
                lastSequenceNumber: const Value(5),
                status: const Value('completed'),
              ),
            );

        final deviceInfos = await stateManager.getDeviceInfoList();

        expect(deviceInfos.length, greaterThanOrEqualTo(2));

        final androidDevice = deviceInfos.firstWhere(
          (d) => d.deviceId == 'android_device_1',
        );
        expect(androidDevice.deviceName, equals('Android Device'));
        expect(androidDevice.platform, equals('Android'));
        expect(androidDevice.lastSequenceNumber, equals(10));
      });

      test('should filter out old devices', () async {
        // Add an old device (over 30 days)
        await database.into(database.syncStateTable).insert(
              SyncStateTableCompanion.insert(
                deviceId: 'old_device',
                lastSyncTime: DateTime.now().subtract(Duration(days: 35)),
                lastSequenceNumber: const Value(1),
                status: const Value('idle'),
              ),
            );

        final activeDevices = await stateManager.getActiveDevices();
        expect(activeDevices, isNot(contains('old_device')));
      });
    });

    group('Event Management', () {
      test('should get unsynced events', () async {
        // Clean up any existing events first
        await database.delete(database.syncEventLogTable).go();

        // Create some test events
        final events = [
          EventSourcingTestHelpers.createTestEvent(
            operation: 'create',
            tableName: 'transactions',
            recordId: 'txn-1',
            data: {'amount': 100.0},
            isSynced: false,
          ),
          EventSourcingTestHelpers.createTestEvent(
            operation: 'update',
            tableName: 'transactions',
            recordId: 'txn-2',
            data: {'amount': 200.0},
            isSynced: true, // This one is synced
          ),
          EventSourcingTestHelpers.createTestEvent(
            operation: 'create',
            tableName: 'budgets',
            recordId: 'budget-1',
            data: {'limit': 1000.0},
            isSynced: false,
          ),
        ];

        for (final event in events) {
          await database.into(database.syncEventLogTable).insert(event);
        }

        final unsyncedEvents = await stateManager.getUnsyncedEvents();

        expect(unsyncedEvents.length, equals(2)); // Only unsynced events
        expect(unsyncedEvents[0].tableName, equals('transactions'));
        expect(unsyncedEvents[1].tableName, equals('budgets'));
      });

      test('should mark events as synced', () async {
        // Clean up any existing events first
        await database.delete(database.syncEventLogTable).go();

        // Create test events
        final eventIds = ['event-1', 'event-2', 'event-3'];
        for (final eventId in eventIds) {
          final testEvent = EventSourcingTestHelpers.createTestEvent(
            operation: 'create',
            tableName: 'transactions',
            recordId: 'txn-$eventId',
            data: {'amount': 100.0},
            isSynced: false,
          );
          await database.into(database.syncEventLogTable).insert(
                testEvent.copyWith(eventId: Value(eventId)),
              );
        }

        // Mark first two as synced
        await stateManager.markEventsSynced(['event-1', 'event-2']);

        // Check results
        final syncedEvents = await (database.select(database.syncEventLogTable)
              ..where((tbl) => tbl.isSynced.equals(true)))
            .get();
        final unsyncedEvents =
            await (database.select(database.syncEventLogTable)
                  ..where((tbl) => tbl.isSynced.equals(false)))
                .get();

        expect(syncedEvents.length, equals(2));
        expect(unsyncedEvents.length, equals(1));
        expect(unsyncedEvents.first.eventId, equals('event-3'));
      });
    });

    group('Sync Metrics', () {
      test('should calculate comprehensive sync metrics', () async {
        // Clean up any existing events first
        await database.delete(database.syncEventLogTable).go();

        // Add some test events
        final now = DateTime.now();
        final events = [
          EventSourcingTestHelpers.createTestEvent(
            operation: 'create',
            tableName: 'transactions',
            recordId: 'txn-1',
            data: {'amount': 100.0},
            timestamp: now.subtract(Duration(days: 1)),
            isSynced: true,
          ),
          EventSourcingTestHelpers.createTestEvent(
            operation: 'update',
            tableName: 'budgets',
            recordId: 'budget-1',
            data: {'limit': 1000.0},
            timestamp: now.subtract(Duration(days: 5)),
            isSynced: true,
          ),
          EventSourcingTestHelpers.createTestEvent(
            operation: 'create',
            tableName: 'transactions',
            recordId: 'txn-2',
            data: {'amount': 200.0},
            timestamp:
                now.subtract(Duration(days: 40)), // Outside 30-day window
            isSynced: true,
          ),
        ];

        for (final event in events) {
          await database.into(database.syncEventLogTable).insert(event);
        }

        final metrics = await stateManager.getSyncMetrics();

        expect(
            metrics.totalEventsSynced, equals(2)); // Only events within 30 days
        expect(metrics.eventsByTable['transactions'], equals(1));
        expect(metrics.eventsByTable['budgets'], equals(1));
        expect(metrics.syncEfficiency, equals(1.0)); // All events synced
        expect(metrics.deviceCount, greaterThanOrEqualTo(1));
      });

      test('should calculate sync efficiency correctly', () async {
        // Clean up any existing events first
        await database.delete(database.syncEventLogTable).go();

        // Add mixed synced/unsynced events
        final events = [
          // Synced events
          EventSourcingTestHelpers.createTestEvent(
            operation: 'create',
            tableName: 'transactions',
            recordId: 'txn-1',
            isSynced: true,
          ),
          EventSourcingTestHelpers.createTestEvent(
            operation: 'create',
            tableName: 'transactions',
            recordId: 'txn-2',
            isSynced: true,
          ),
          // Unsynced event
          EventSourcingTestHelpers.createTestEvent(
            operation: 'create',
            tableName: 'transactions',
            recordId: 'txn-3',
            isSynced: false,
          ),
        ];

        for (final event in events) {
          await database.into(database.syncEventLogTable).insert(event);
        }

        final metrics = await stateManager.getSyncMetrics();

        // 2 out of 3 events synced = 66.7% efficiency
        expect(metrics.syncEfficiency, closeTo(0.67, 0.01));
      });
    });

    group('Data Cleanup', () {
      test('should clean up old sync data', () async {
        final oldDate = DateTime.now().subtract(Duration(days: 100));

        // Add old synced event
        await database.into(database.syncEventLogTable).insert(
              EventSourcingTestHelpers.createTestEvent(
                operation: 'create',
                tableName: 'transactions',
                recordId: 'old-txn',
                timestamp: oldDate,
                isSynced: true,
              ),
            );

        // Add old device state
        await database.into(database.syncStateTable).insert(
              SyncStateTableCompanion.insert(
                deviceId: 'old-device',
                lastSyncTime: oldDate,
                lastSequenceNumber: const Value(1),
                status: const Value('idle'),
              ),
            );

        // Add recent data that should not be deleted
        await database.into(database.syncEventLogTable).insert(
              EventSourcingTestHelpers.createTestEvent(
                operation: 'create',
                tableName: 'transactions',
                recordId: 'recent-txn',
                timestamp: DateTime.now(),
                isSynced: true,
              ),
            );

        await stateManager.cleanupOldSyncData();

        // Check that old data was removed
        final events = await database.select(database.syncEventLogTable).get();
        final deviceStates =
            await database.select(database.syncStateTable).get();

        expect(events.any((e) => e.recordId == 'old-txn'), isFalse);
        expect(events.any((e) => e.recordId == 'recent-txn'), isTrue);
        expect(deviceStates.any((d) => d.deviceId == 'old-device'), isFalse);
      });
    });

    group('Progress Tracking', () {
      test('should update progress percentage correctly', () async {
        final progressUpdates = <SyncProgress>[];
        stateManager.syncProgressStream.listen(progressUpdates.add);

        await stateManager.startSync(
          state: SyncState.processing,
          totalEvents: 200,
        );

        await stateManager.updateProgress(processedEvents: 50);
        await stateManager.updateProgress(processedEvents: 100);
        await stateManager.updateProgress(processedEvents: 200);

        await Future.delayed(Duration(milliseconds: 10));

        expect(progressUpdates.length, greaterThanOrEqualTo(4));

        // Check percentage calculations
        final percentages =
            progressUpdates.map((p) => p.progressPercentage).toList();
        expect(percentages, contains(25.0)); // 50/200
        expect(percentages, contains(50.0)); // 100/200
        expect(percentages, contains(100.0)); // 200/200
      });

      test('should track conflict count in progress', () async {
        final progressUpdates = <SyncProgress>[];
        stateManager.syncProgressStream.listen(progressUpdates.add);

        await stateManager.startSync(
          state: SyncState.resolving_conflicts,
          totalEvents: 10,
        );

        await stateManager.updateProgress(
          processedEvents: 5,
          conflictCount: 2,
          statusMessage: 'Resolving conflicts...',
        );

        await Future.delayed(Duration(milliseconds: 10));

        final lastProgress = progressUpdates.last;
        expect(lastProgress.conflictCount, equals(2));
        expect(lastProgress.statusMessage, equals('Resolving conflicts...'));
      });
    });

    group('State Transitions', () {
      test('should transition through sync states correctly', () async {
        final states = <SyncState>[];
        stateManager.syncStateStream.listen(states.add);

        // Upload phase
        await stateManager.startSync(state: SyncState.uploading);
        await Future.delayed(Duration(milliseconds: 5));

        // Download phase
        await stateManager.startSync(state: SyncState.downloading);
        await Future.delayed(Duration(milliseconds: 5));

        // Processing phase
        await stateManager.startSync(state: SyncState.processing);
        await Future.delayed(Duration(milliseconds: 5));

        // Conflict resolution
        await stateManager.startSync(state: SyncState.resolving_conflicts);
        await Future.delayed(Duration(milliseconds: 5));

        // Completion
        await stateManager.completeSync(success: true);
        await Future.delayed(Duration(milliseconds: 5));

        expect(states, contains(SyncState.uploading));
        expect(states, contains(SyncState.downloading));
        expect(states, contains(SyncState.processing));
        expect(states, contains(SyncState.resolving_conflicts));
        expect(states, contains(SyncState.completed));
      });

      test('should reset to idle after completion', () async {
        final states = <SyncState>[];
        stateManager.syncStateStream.listen(states.add);

        await stateManager.startSync(state: SyncState.uploading);
        await stateManager.completeSync(success: true);

        // Wait for auto-reset to idle
        await Future.delayed(Duration(seconds: 4));

        expect(states.last, equals(SyncState.idle));
      });
    });

    group('Error Handling', () {
      test('should handle sync errors gracefully', () async {
        final progressUpdates = <SyncProgress>[];
        stateManager.syncProgressStream.listen(progressUpdates.add);

        await stateManager.startSync(
          state: SyncState.uploading,
          totalEvents: 10,
        );

        await stateManager.completeSync(
          success: false,
          message: 'Network connection failed',
        );

        await Future.delayed(Duration(milliseconds: 10));

        final errorProgress = progressUpdates.last;
        expect(errorProgress.state, equals(SyncState.error));
        expect(
            errorProgress.statusMessage, equals('Network connection failed'));
      });
    });

    group('Stream Management', () {
      test('should close streams properly on dispose', () async {
        final testStateManager = SyncStateManager(database);
        await testStateManager.initialize();

        var progressStreamClosed = false;
        var stateStreamClosed = false;

        testStateManager.syncProgressStream.listen(
          (_) {},
          onDone: () => progressStreamClosed = true,
        );

        testStateManager.syncStateStream.listen(
          (_) {},
          onDone: () => stateStreamClosed = true,
        );

        testStateManager.dispose();

        // Give streams time to close
        await Future.delayed(Duration(milliseconds: 10));

        expect(progressStreamClosed, isTrue);
        expect(stateStreamClosed, isTrue);
      });
    });
  });
}
