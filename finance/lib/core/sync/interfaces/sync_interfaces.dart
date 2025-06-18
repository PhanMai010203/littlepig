import 'dart:async';
import '../sync_event.dart';
import '../sync_state_manager.dart';

/// Main sync service interface that Team A implements and Team B consumes
abstract class SyncService {
  /// Stream of sync events for real-time updates (Team B consumes this)
  Stream<SyncEvent> get eventStream;
  
  /// Stream of sync progress updates (Team B displays this)
  Stream<SyncProgress> get progressStream;
  
  /// Stream of sync state changes (Team B monitors this)
  Stream<SyncState> get stateStream;
  
  /// Sync local changes to cloud (Team A implements)
  Future<SyncResult> syncToCloud();
  
  /// Download and apply changes from cloud (Team A implements)
  Future<SyncResult> syncFromCloud();
  
  /// Full bidirectional sync operation (Team A implements)
  Future<SyncResult> performFullSync();
  
  /// Initialize sync service (Team A implements)
  Future<bool> initialize();
  
  /// Check if user is authenticated (Team A implements)
  Future<bool> isSignedIn();
  
  /// Sign in to cloud service (Team A implements)
  Future<bool> signIn();
  
  /// Sign out from cloud service (Team A implements)
  Future<void> signOut();
  
  /// Check if sync is currently in progress
  bool get isSyncing;
  
  /// Get last successful sync timestamp
  Future<DateTime?> getLastSyncTime();
}

/// Interface for real-time sync capabilities that Team B implements
abstract class RealtimeCapable {
  /// Broadcast an event to other devices (Team B implements)
  Future<void> broadcastEvent(SyncEvent event);
  
  /// Handle incoming real-time event (Team B implements)
  Future<void> handleIncomingEvent(SyncEvent event);
  
  /// Subscribe to real-time updates (Team B implements)
  Future<void> subscribeToRealTimeUpdates();
  
  /// Unsubscribe from real-time updates (Team B implements)
  Future<void> unsubscribeFromRealTimeUpdates();
  
  /// Stream of incoming real-time events
  Stream<SyncEvent> get incomingEventStream;
  
  /// Connection status for real-time sync
  Stream<ConnectionStatus> get connectionStatusStream;
}

/// Conflict resolution interface that spans both teams
abstract class ConflictResolver {
  /// Automatically resolve conflicts using CRDT logic (Team A implements)
  Future<ConflictResolution> resolveAutomatically(List<SyncEvent> conflicts);
  
  /// Request user decision for manual conflict resolution (Team B implements)
  Future<UserDecision> requestUserDecision(ConflictScenario scenario);
  
  /// Stream of conflicts that need user attention
  Stream<ConflictScenario> get conflictStream;
}

/// Sync state provider interface for monitoring
abstract class SyncStateProvider {
  /// Stream of sync progress updates (Team A provides)
  Stream<SyncProgress> get progressStream;
  
  /// Stream of sync state changes (Team A provides)
  Stream<SyncState> get stateStream;
  
  /// Stream of sync metrics (Team A provides)
  Stream<SyncMetrics> get metricsStream;
  
  /// Get current sync metrics
  Future<SyncMetrics> getCurrentMetrics();
  
  /// Get list of active devices
  Future<List<DeviceInfo>> getActiveDevices();
}

/// User notification interface for Team B
abstract class UserNotificationProvider {
  /// Stream of user notifications (Team B displays)
  Stream<UserNotification> get notificationStream;
  
  /// Show sync completion notification
  Future<void> showSyncCompletedNotification(SyncResult result);
  
  /// Show conflict resolution notification
  Future<void> showConflictNotification(ConflictScenario conflict);
  
  /// Show sync error notification
  Future<void> showSyncErrorNotification(String error);
}

/// Sync result class for operation outcomes
class SyncResult {
  final bool success;
  final String? error;
  final int uploadedCount;
  final int downloadedCount;
  final int conflictCount;
  final DateTime timestamp;
  final Duration duration;

  const SyncResult({
    required this.success,
    this.error,
    required this.uploadedCount,
    required this.downloadedCount,
    required this.conflictCount,
    required this.timestamp,
    required this.duration,
  });

  factory SyncResult.success({
    required int uploadedCount,
    required int downloadedCount,
    required int conflictCount,
    required Duration duration,
  }) {
    return SyncResult(
      success: true,
      uploadedCount: uploadedCount,
      downloadedCount: downloadedCount,
      conflictCount: conflictCount,
      timestamp: DateTime.now(),
      duration: duration,
    );
  }

  factory SyncResult.error({
    required String error,
    required Duration duration,
  }) {
    return SyncResult(
      success: false,
      error: error,
      uploadedCount: 0,
      downloadedCount: 0,
      conflictCount: 0,
      timestamp: DateTime.now(),
      duration: duration,
    );
  }
}

/// Connection status for real-time sync
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error
}

/// User decision for conflict resolution
class UserDecision {
  final ConflictResolutionAction action;
  final Map<String, dynamic>? customData;
  final String? reason;

  const UserDecision({
    required this.action,
    this.customData,
    this.reason,
  });
}

/// Actions user can take for conflict resolution
enum ConflictResolutionAction {
  useLocal,
  useRemote,
  merge,
  skip,
  custom
}

/// Conflict scenario for user resolution
class ConflictScenario {
  final String conflictId;
  final String tableName;
  final String recordId;
  final List<SyncEvent> conflictingEvents;
  final ConflictType type;
  final String description;
  final DateTime timestamp;

  const ConflictScenario({
    required this.conflictId,
    required this.tableName,
    required this.recordId,
    required this.conflictingEvents,
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

/// Types of conflicts that can occur
enum ConflictType {
  updateUpdate,    // Two updates to same record
  updateDelete,    // Update vs delete
  deleteDelete,    // Multiple deletes
  createCreate,    // Duplicate creates
  complexMerge     // Complex multi-field conflicts
}

/// User notification for sync events
class UserNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final NotificationPriority priority;

  const UserNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.data,
    required this.priority,
  });

  factory UserNotification.syncCompleted(SyncResult result) {
    return UserNotification(
      id: 'sync_completed_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.syncCompleted,
      title: 'Sync Completed',
      message: 'Synced ${result.uploadedCount} uploads, ${result.downloadedCount} downloads',
      timestamp: DateTime.now(),
      data: {
        'uploadedCount': result.uploadedCount,
        'downloadedCount': result.downloadedCount,
        'conflictCount': result.conflictCount,
      },
      priority: NotificationPriority.normal,
    );
  }

  factory UserNotification.conflictDetected(ConflictScenario conflict) {
    return UserNotification(
      id: 'conflict_${conflict.conflictId}',
      type: NotificationType.conflictDetected,
      title: 'Sync Conflict',
      message: conflict.description,
      timestamp: DateTime.now(),
      data: {
        'conflictId': conflict.conflictId,
        'tableName': conflict.tableName,
        'recordId': conflict.recordId,
      },
      priority: NotificationPriority.high,
    );
  }

  factory UserNotification.syncError(String error) {
    return UserNotification(
      id: 'sync_error_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.syncError,
      title: 'Sync Error',
      message: error,
      timestamp: DateTime.now(),
      priority: NotificationPriority.high,
    );
  }
}

/// Types of user notifications
enum NotificationType {
  syncStarted,
  syncCompleted,
  syncError,
  conflictDetected,
  conflictResolved,
  connectionLost,
  connectionRestored
}

/// Priority levels for notifications
enum NotificationPriority {
  low,
  normal,
  high,
  critical
} 