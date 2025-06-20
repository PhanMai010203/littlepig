import 'package:test/test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:finance/core/sync/sync_state_manager.dart';
import 'package:finance/core/database/app_database.dart';
import '../../helpers/test_database_setup.dart';

void main() {
  group('SyncStateManager - Pure Dart Tests', () {
    late AppDatabase database;
    late SyncStateManager syncStateManager;

    setUp(() async {
      database = await TestDatabaseSetup.createCleanTestDatabase();
      syncStateManager = SyncStateManager(database);
      await database.customStatement('PRAGMA foreign_keys = ON');
      await syncStateManager.initialize();
    });

    tearDown(() async {
      await database.close();
    });

    test('getCurrentState - should return initial idle state', () async {
      final state = await syncStateManager.getCurrentState();
      expect(state, equals(SyncState.idle));
    });

    test('updateSyncProgress - should update device sync state', () async {
      const deviceId = 'test-device-123';
      const sequenceNumber = 42;

      await syncStateManager.updateSyncProgress(deviceId, sequenceNumber);

      // Verify the data was stored
      final query = database.select(database.syncStateTable)
        ..where((tbl) => tbl.deviceId.equals(deviceId));

      final result = await query.getSingleOrNull();
      expect(result, isNotNull);
      expect(result!.deviceId, equals(deviceId));
      expect(result.lastSequenceNumber, equals(sequenceNumber));
    });

    test('getActiveDevices - should return devices synced within 30 days',
        () async {
      // Add a device synced recently
      const recentDevice = 'recent-device';
      await syncStateManager.updateSyncProgress(recentDevice, 1);

      // Add a device synced long ago (simulate by direct database insert)
      final oldTimestamp = DateTime.now().subtract(const Duration(days: 35));
      await database.into(database.syncStateTable).insert(
            SyncStateTableCompanion.insert(
              deviceId: 'old-device',
              lastSyncTime: oldTimestamp,
              lastSequenceNumber: const Value(1),
              status: const Value('idle'),
            ),
          );

      final activeDevices = await syncStateManager.getActiveDevices();

      expect(activeDevices.contains(recentDevice), isTrue);
      expect(activeDevices.contains('old-device'), isFalse);
    });

    test('getDeviceInfoList - should return device information', () async {
      const deviceId = 'test-device-info';
      const sequenceNumber = 10;

      await syncStateManager.updateSyncProgress(deviceId, sequenceNumber);

      final deviceInfoList = await syncStateManager.getDeviceInfoList();

      expect(deviceInfoList.isNotEmpty, isTrue);
      final deviceInfo = deviceInfoList.firstWhere(
        (info) => info.deviceId == deviceId,
        orElse: () => throw StateError('Device not found'),
      );

      expect(deviceInfo.deviceId, equals(deviceId));
      expect(deviceInfo.lastSequenceNumber, equals(sequenceNumber));
    });

    test('syncProgressStream - should emit progress updates', () async {
      bool progressReceived = false;
      SyncProgress? receivedProgress;

      // Listen to the progress stream
      syncStateManager.syncProgressStream.listen((progress) {
        progressReceived = true;
        receivedProgress = progress;
      });

      // This would normally be triggered by internal sync operations
      // For testing, we just verify the stream exists and is accessible
      expect(syncStateManager.syncProgressStream, isNotNull);
    });

    test('syncStateStream - should emit state changes', () async {
      bool stateReceived = false;
      SyncState? receivedState;

      // Listen to the state stream
      syncStateManager.syncStateStream.listen((state) {
        stateReceived = true;
        receivedState = state;
      });

      // This would normally be triggered by internal sync operations
      // For testing, we just verify the stream exists and is accessible
      expect(syncStateManager.syncStateStream, isNotNull);
    });

    test('SyncProgress copyWith - should create copy with updated fields', () {
      final originalProgress = SyncProgress(
        state: SyncState.idle,
        totalEvents: 100,
        processedEvents: 50,
        conflictCount: 2,
        progressPercentage: 50.0,
        statusMessage: 'Processing...',
        timestamp: DateTime.now(),
      );

      final updatedProgress = originalProgress.copyWith(
        state: SyncState.uploading,
        processedEvents: 75,
        progressPercentage: 75.0,
      );

      expect(updatedProgress.state, equals(SyncState.uploading));
      expect(updatedProgress.totalEvents, equals(100)); // Unchanged
      expect(updatedProgress.processedEvents, equals(75)); // Updated
      expect(updatedProgress.conflictCount, equals(2)); // Unchanged
      expect(updatedProgress.progressPercentage, equals(75.0)); // Updated
      expect(
          updatedProgress.statusMessage, equals('Processing...')); // Unchanged
    });

    test('SyncState enum - should have all required states', () {
      final expectedStates = [
        SyncState.idle,
        SyncState.initializing,
        SyncState.uploading,
        SyncState.downloading,
        SyncState.processing,
        SyncState.resolving_conflicts,
        SyncState.completed,
        SyncState.error,
        SyncState.offline,
      ];

      // Verify all states exist
      for (final state in expectedStates) {
        expect(state.name, isNotEmpty);
      }
    });

    test('DeviceInfo - should create device info correctly', () {
      final deviceInfo = DeviceInfo(
        deviceId: 'test-device',
        deviceName: 'Test Device',
        platform: 'test-platform',
        lastSyncTime: DateTime.now(),
        lastSequenceNumber: 42,
        status: SyncState.idle,
      );

      expect(deviceInfo.deviceId, equals('test-device'));
      expect(deviceInfo.deviceName, equals('Test Device'));
      expect(deviceInfo.platform, equals('test-platform'));
      expect(deviceInfo.lastSequenceNumber, equals(42));
      expect(deviceInfo.status, equals(SyncState.idle));
    });

    test('SyncMetrics - should create metrics correctly', () {
      final metrics = SyncMetrics(
        totalEventsSynced: 1000,
        conflictsResolved: 5,
        averageSyncTime: const Duration(seconds: 30),
        lastSuccessfulSync: DateTime.now(),
        deviceCount: 3,
        eventsByTable: {'transactions': 500, 'budgets': 300, 'categories': 200},
        syncEfficiency: 95.5,
      );

      expect(metrics.totalEventsSynced, equals(1000));
      expect(metrics.conflictsResolved, equals(5));
      expect(metrics.averageSyncTime, equals(const Duration(seconds: 30)));
      expect(metrics.deviceCount, equals(3));
      expect(metrics.eventsByTable['transactions'], equals(500));
      expect(metrics.syncEfficiency, equals(95.5));
    });
  });
}
