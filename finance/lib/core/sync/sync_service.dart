abstract class SyncService {
  /// Initialize sync service with authentication
  Future<bool> initialize();

  /// Check if user is signed in to Google
  Future<bool> isSignedIn();

  /// Sign in to Google and get Drive access
  Future<bool> signIn();

  /// Sign out from Google
  Future<void> signOut();

  /// Get current user's email
  Future<String?> getCurrentUserEmail();

  /// Sync local changes to Google Drive
  Future<SyncResult> syncToCloud();

  /// Download and merge changes from Google Drive
  Future<SyncResult> syncFromCloud();

  /// Full bidirectional sync
  Future<SyncResult> performFullSync();

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime();

  /// Check if sync is in progress
  bool get isSyncing;

  /// Stream of sync status updates
  Stream<SyncStatus> get syncStatusStream;
}

class SyncResult {
  final bool success;
  final String? error;
  final int uploadedCount;
  final int downloadedCount;
  final DateTime timestamp;

  SyncResult({
    required this.success,
    this.error,
    required this.uploadedCount,
    required this.downloadedCount,
    required this.timestamp,
  });
}

enum SyncStatus {
  idle,
  uploading,
  downloading,
  merging,
  completed,
  error,
}

class SyncConflict {
  final String table;
  final String syncId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime localTimestamp;
  final DateTime remoteTimestamp;

  SyncConflict({
    required this.table,
    required this.syncId,
    required this.localData,
    required this.remoteData,
    required this.localTimestamp,
    required this.remoteTimestamp,
  });
}
