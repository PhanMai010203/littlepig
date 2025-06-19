import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'sync_event.dart';

/// Represents the current state of synchronization
enum SyncState {
  idle,
  initializing,
  uploading,
  downloading,
  processing,
  resolving_conflicts,
  completed,
  error,
  offline
}

/// Sync progress information
class SyncProgress {
  final SyncState state;
  final int totalEvents;
  final int processedEvents;
  final int conflictCount;
  final double progressPercentage;
  final String? statusMessage;
  final DateTime timestamp;

  const SyncProgress({
    required this.state,
    required this.totalEvents,
    required this.processedEvents,
    required this.conflictCount,
    required this.progressPercentage,
    this.statusMessage,
    required this.timestamp,
  });

  SyncProgress copyWith({
    SyncState? state,
    int? totalEvents,
    int? processedEvents,
    int? conflictCount,
    double? progressPercentage,
    String? statusMessage,
    DateTime? timestamp,
  }) {
    return SyncProgress(
      state: state ?? this.state,
      totalEvents: totalEvents ?? this.totalEvents,
      processedEvents: processedEvents ?? this.processedEvents,
      conflictCount: conflictCount ?? this.conflictCount,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      statusMessage: statusMessage ?? this.statusMessage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Sync metrics for monitoring and analytics
class SyncMetrics {
  final int totalEventsSynced;
  final int conflictsResolved;
  final Duration averageSyncTime;
  final DateTime lastSuccessfulSync;
  final int deviceCount;
  final Map<String, int> eventsByTable;
  final double syncEfficiency;

  const SyncMetrics({
    required this.totalEventsSynced,
    required this.conflictsResolved,
    required this.averageSyncTime,
    required this.lastSuccessfulSync,
    required this.deviceCount,
    required this.eventsByTable,
    required this.syncEfficiency,
  });
}

/// Device synchronization information
class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String platform;
  final DateTime lastSyncTime;
  final int lastSequenceNumber;
  final SyncState status;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.lastSyncTime,
    required this.lastSequenceNumber,
    required this.status,
  });
}

/// Manages sync state, progress tracking, and device coordination
class SyncStateManager {
  final AppDatabase _database;
  final StreamController<SyncProgress> _progressController =
      StreamController<SyncProgress>.broadcast();
  final StreamController<SyncState> _stateController =
      StreamController<SyncState>.broadcast();

  String? _currentDeviceId;
  SyncState _currentState = SyncState.idle;
  SyncProgress _currentProgress = SyncProgress(
    state: SyncState.idle,
    totalEvents: 0,
    processedEvents: 0,
    conflictCount: 0,
    progressPercentage: 0.0,
    timestamp: DateTime.now(),
  );

  SyncStateManager(this._database);

  /// Stream for Team B to monitor sync progress
  Stream<SyncProgress> get syncProgressStream => _progressController.stream;

  /// Stream for Team B to monitor sync state changes
  Stream<SyncState> get syncStateStream => _stateController.stream;

  /// Initialize the sync state manager
  Future<void> initialize() async {
    _currentDeviceId = await _getOrCreateDeviceId();
    await _initializeDeviceState();
  }

  /// Get current sync state
  Future<SyncState> getCurrentState() async {
    return _currentState;
  }

  /// Update sync progress for a device
  Future<void> updateSyncProgress(String deviceId, int sequenceNumber) async {
    await _database.into(_database.syncStateTable).insert(
          SyncStateTableCompanion.insert(
            deviceId: deviceId,
            lastSyncTime: DateTime.now(),
            lastSequenceNumber: Value(sequenceNumber),
            status: Value(_currentState.name),
          ),
          mode: InsertMode.insertOrReplace,
        );

    // Update progress if this is the current device
    if (deviceId == _currentDeviceId) {
      await _updateCurrentProgress();
    }
  }

  /// Get list of all active devices
  Future<List<String>> getActiveDevices() async {
    final cutoffTime = DateTime.now().subtract(Duration(days: 30));

    final query = _database.select(_database.syncStateTable)
      ..where((tbl) => tbl.lastSyncTime.isBiggerThanValue(cutoffTime));

    final devices = await query.get();
    return devices.map((d) => d.deviceId).toList();
  }

  /// Get detailed device information
  Future<List<DeviceInfo>> getDeviceInfoList() async {
    final cutoffTime = DateTime.now().subtract(Duration(days: 30));

    final query = _database.select(_database.syncStateTable)
      ..where((tbl) => tbl.lastSyncTime.isBiggerThanValue(cutoffTime))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.lastSyncTime)]);

    final devices = await query.get();

    return devices.map((device) {
      return DeviceInfo(
        deviceId: device.deviceId,
        deviceName: _getDeviceName(device.deviceId),
        platform: _getPlatformName(device.deviceId),
        lastSyncTime: device.lastSyncTime,
        lastSequenceNumber: device.lastSequenceNumber,
        status: _parseState(device.status),
      );
    }).toList();
  }

  /// Get comprehensive sync metrics
  Future<SyncMetrics> getSyncMetrics() async {
    final now = DateTime.now();
    final last30Days = now.subtract(Duration(days: 30));

    // Get total events synced in last 30 days
    final totalEventsQuery = _database.select(_database.syncEventLogTable)
      ..where((tbl) =>
          tbl.timestamp.isBiggerThanValue(last30Days) &
          tbl.isSynced.equals(true));
    final totalEvents = await totalEventsQuery.get();

    // Calculate events by table
    final eventsByTable = <String, int>{};
    for (final event in totalEvents) {
      eventsByTable[event.tableNameField] =
          (eventsByTable[event.tableNameField] ?? 0) + 1;
    }

    // Get conflict resolution data
    final conflictEvents =
        totalEvents.where((e) => e.data.contains('conflict_resolved')).length;

    // Calculate average sync time (mock for now)
    final averageSyncTime = Duration(seconds: 5);

    // Get last successful sync
    final lastSyncQuery = _database.select(_database.syncStateTable)
      ..where((tbl) => tbl.deviceId.equals(_currentDeviceId!))
      ..limit(1);
    final lastSync = await lastSyncQuery.getSingleOrNull();

    // Calculate sync efficiency - get ALL events (synced and unsynced) in last 30 days
    final allEventsQuery = _database.select(_database.syncEventLogTable)
      ..where((tbl) => tbl.timestamp.isBiggerThanValue(last30Days));
    final allEvents = await allEventsQuery.get();

    final totalEventsCount = allEvents.length;
    final syncedEventsCount = allEvents.where((e) => e.isSynced).length;
    final efficiency =
        totalEventsCount > 0 ? syncedEventsCount / totalEventsCount : 1.0;

    return SyncMetrics(
      totalEventsSynced: totalEvents.length,
      conflictsResolved: conflictEvents,
      averageSyncTime: averageSyncTime,
      lastSuccessfulSync: lastSync?.lastSyncTime ?? DateTime.now(),
      deviceCount: (await getActiveDevices()).length,
      eventsByTable: eventsByTable,
      syncEfficiency: efficiency,
    );
  }

  /// Start a sync operation
  Future<void> startSync({
    required SyncState state,
    int totalEvents = 0,
    String? statusMessage,
  }) async {
    _currentState = state;
    _currentProgress = SyncProgress(
      state: state,
      totalEvents: totalEvents,
      processedEvents: 0,
      conflictCount: 0,
      progressPercentage: 0.0,
      statusMessage: statusMessage,
      timestamp: DateTime.now(),
    );

    _stateController.add(_currentState);
    _progressController.add(_currentProgress);

    await _updateDeviceState(state);
  }

  /// Update sync progress during operation
  Future<void> updateProgress({
    int? processedEvents,
    int? conflictCount,
    String? statusMessage,
  }) async {
    final newProcessedEvents =
        processedEvents ?? _currentProgress.processedEvents;
    final newConflictCount = conflictCount ?? _currentProgress.conflictCount;

    final progressPercentage = _currentProgress.totalEvents > 0
        ? (newProcessedEvents / _currentProgress.totalEvents) * 100
        : 0.0;

    _currentProgress = _currentProgress.copyWith(
      processedEvents: newProcessedEvents,
      conflictCount: newConflictCount,
      progressPercentage: progressPercentage,
      statusMessage: statusMessage,
      timestamp: DateTime.now(),
    );

    _progressController.add(_currentProgress);
  }

  /// Complete sync operation
  Future<void> completeSync({
    required bool success,
    String? message,
  }) async {
    final finalState = success ? SyncState.completed : SyncState.error;

    _currentState = finalState;
    _currentProgress = _currentProgress.copyWith(
      state: finalState,
      progressPercentage: success ? 100.0 : _currentProgress.progressPercentage,
      statusMessage: message,
      timestamp: DateTime.now(),
    );

    _stateController.add(_currentState);
    _progressController.add(_currentProgress);

    await _updateDeviceState(finalState);

    // Reset to idle after a delay
    Timer(Duration(seconds: 3), () async {
      if (!_stateController.isClosed) {
        _currentState = SyncState.idle;
        _stateController.add(_currentState);
        await _updateDeviceState(SyncState.idle);
      }
    });
  }

  /// Get events that need to be synced
  Future<List<SyncEvent>> getUnsyncedEvents() async {
    final query = _database.select(_database.syncEventLogTable)
      ..where((tbl) => tbl.isSynced.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.sequenceNumber)]);

    final events = await query.get();

    return events.map((event) {
      return SyncEvent(
        eventId: event.eventId,
        deviceId: event.deviceId,
        tableName: event.tableNameField,
        recordId: event.recordId,
        operation: event.operation,
        data: jsonDecode(event.data),
        timestamp: event.timestamp,
        sequenceNumber: event.sequenceNumber,
        hash: event.hash,
      );
    }).toList();
  }

  /// Mark events as synced
  Future<void> markEventsSynced(List<String> eventIds) async {
    await _database.batch((batch) {
      for (final eventId in eventIds) {
        batch.update(
          _database.syncEventLogTable,
          SyncEventLogTableCompanion(isSynced: Value(true)),
          where: (tbl) => tbl.eventId.equals(eventId),
        );
      }
    });
  }

  /// Get sync conflicts that need resolution
  Future<List<Map<String, dynamic>>> getPendingConflicts() async {
    // This would integrate with the CRDT conflict resolver
    // For now, return empty list as conflicts are auto-resolved
    return [];
  }

  /// Clean up old sync data
  Future<void> cleanupOldSyncData() async {
    final cutoffTime = DateTime.now().subtract(Duration(days: 90));

    // Delete old synced events
    await (_database.delete(_database.syncEventLogTable)
          ..where((tbl) =>
              tbl.timestamp.isSmallerThanValue(cutoffTime) &
              tbl.isSynced.equals(true)))
        .go();

    // Delete inactive device states
    await (_database.delete(_database.syncStateTable)
          ..where((tbl) => tbl.lastSyncTime.isSmallerThanValue(cutoffTime)))
        .go();
  }

  /// Get or create unique device ID
  Future<String> _getOrCreateDeviceId() async {
    // Try to get existing device ID from sync state
    final existingState = await (_database.select(_database.syncStateTable)
          ..limit(1))
        .getSingleOrNull();

    if (existingState != null) {
      return existingState.deviceId;
    }

    // Generate new device ID
    final deviceInfo = DeviceInfoPlugin();
    String deviceId;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = 'android_${androidInfo.id}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = 'ios_${iosInfo.identifierForVendor}';
    } else {
      // Fallback for other platforms
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
    }

    return deviceId;
  }

  /// Initialize device state in database
  Future<void> _initializeDeviceState() async {
    if (_currentDeviceId == null) return;

    await _database.into(_database.syncStateTable).insert(
          SyncStateTableCompanion.insert(
            deviceId: _currentDeviceId!,
            lastSyncTime: DateTime.now(),
            lastSequenceNumber: Value(0),
            status: Value(SyncState.idle.name),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Update device sync state
  Future<void> _updateDeviceState(SyncState state) async {
    if (_currentDeviceId == null) return;

    await (_database.update(_database.syncStateTable)
          ..where((tbl) => tbl.deviceId.equals(_currentDeviceId!)))
        .write(SyncStateTableCompanion(
      lastSyncTime: Value(DateTime.now()),
      status: Value(state.name),
    ));
  }

  /// Update current progress from database
  Future<void> _updateCurrentProgress() async {
    final unsyncedEvents = await getUnsyncedEvents();
    final totalEvents = unsyncedEvents.length;

    // This is a simplified progress calculation
    // In a real implementation, you'd track more detailed progress
    _currentProgress = _currentProgress.copyWith(
      totalEvents: totalEvents,
      timestamp: DateTime.now(),
    );

    _progressController.add(_currentProgress);
  }

  /// Get human-readable device name
  String _getDeviceName(String deviceId) {
    if (deviceId.startsWith('android_')) {
      return 'Android Device';
    } else if (deviceId.startsWith('ios_')) {
      return 'iOS Device';
    } else {
      return 'Unknown Device';
    }
  }

  /// Get platform name from device ID
  String _getPlatformName(String deviceId) {
    if (deviceId.startsWith('android_')) {
      return 'Android';
    } else if (deviceId.startsWith('ios_')) {
      return 'iOS';
    } else {
      return 'Unknown';
    }
  }

  /// Parse sync state from string
  SyncState _parseState(String stateString) {
    try {
      return SyncState.values.firstWhere(
        (state) => state.name == stateString,
        orElse: () => SyncState.idle,
      );
    } catch (e) {
      return SyncState.idle;
    }
  }

  /// Clean up resources
  void dispose() {
    _progressController.close();
    _stateController.close();
  }
}
