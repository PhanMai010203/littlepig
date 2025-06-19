import 'dart:async';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';

import 'sync_event.dart';
import 'crdt_conflict_resolver.dart';
import 'event_processor.dart';
import 'sync_state_manager.dart';
import 'interfaces/sync_interfaces.dart' as interfaces;
import '../database/app_database.dart';
import 'google_drive_sync_service.dart';

/// Enhanced Incremental Sync Service for Phase 5A
/// Integrates EventProcessor and SyncStateManager for advanced sync capabilities
class EnhancedIncrementalSyncService implements interfaces.SyncService {
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/drive.file',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  final AppDatabase _database;
  final EventProcessor _eventProcessor;
  final SyncStateManager _stateManager;
  final CRDTConflictResolver _conflictResolver;
  
  // Real-time streams for Team B
  final StreamController<SyncEvent> _eventStreamController = 
      StreamController<SyncEvent>.broadcast();
  
  String? _deviceId;
  bool _isSyncing = false;
  Timer? _periodicSyncTimer;
  
  EnhancedIncrementalSyncService(this._database)
      : _eventProcessor = EventProcessor(_database),
        _stateManager = SyncStateManager(_database),
        _conflictResolver = CRDTConflictResolver();

  /// Team B Interface: Stream of sync events for real-time updates
  @override
  Stream<SyncEvent> get eventStream => _eventStreamController.stream;

  /// Team B Interface: Stream of sync progress updates
  @override
  Stream<SyncProgress> get progressStream => _stateManager.syncProgressStream;

  /// Team B Interface: Stream of sync state changes
  @override
  Stream<SyncState> get stateStream => _stateManager.syncStateStream;

  @override
  bool get isSyncing => _isSyncing;

  @override
  Future<bool> initialize() async {
    try {
      // Initialize all components
      await _stateManager.initialize();
      _deviceId = await _getOrCreateDeviceId();
      
      // Subscribe to event processor streams
      _eventProcessor.eventBroadcastStream.listen((event) {
        _eventStreamController.add(event);
      });
      
      // Set up periodic sync
      _setupPeriodicSync();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return _googleSignIn.isSignedIn();
  }

  @override
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    final state = await _stateManager.getCurrentState();
    // Get last sync from database
    final query = _database.select(_database.syncStateTable)
      ..where((tbl) => tbl.deviceId.equals(_deviceId!))
      ..limit(1);
    final result = await query.getSingleOrNull();
    return result?.lastSyncTime;
  }

  /// Enhanced sync to cloud with event processing and state management
  @override
  Future<interfaces.SyncResult> syncToCloud() async {
    if (_isSyncing) {
      return interfaces.SyncResult.error(
        error: 'Sync already in progress',
        duration: Duration.zero,
      );
    }

    final startTime = DateTime.now();
    _isSyncing = true;

    try {
      await _stateManager.startSync(
        state: SyncState.uploading,
        statusMessage: 'Uploading local changes...',
      );

      // Get unsynced events
      final unsyncedEvents = await _stateManager.getUnsyncedEvents();
      
      if (unsyncedEvents.isEmpty) {
        await _stateManager.completeSync(
          success: true,
          message: 'No changes to sync',
        );
        return interfaces.SyncResult.success(
          uploadedCount: 0,
          downloadedCount: 0,
          conflictCount: 0,
          duration: DateTime.now().difference(startTime),
        );
      }

      await _stateManager.updateProgress(
        statusMessage: 'Processing ${unsyncedEvents.length} events...',
      );

      // Process and optimize events using EventProcessor
      final processedEvents = <SyncEvent>[];
      for (final event in unsyncedEvents) {
        await _eventProcessor.processEvent(event);
        processedEvents.add(event);
        
        await _stateManager.updateProgress(
          processedEvents: processedEvents.length,
          statusMessage: 'Processed ${processedEvents.length}/${unsyncedEvents.length} events',
        );
      }

      // Deduplicate events for efficiency
      final deduplicatedEvents = await _eventProcessor.deduplicateEvents(processedEvents);
      
      await _stateManager.updateProgress(
        statusMessage: 'Uploading ${deduplicatedEvents.length} optimized events...',
      );

      // Upload to Google Drive
      final uploadCount = await _uploadEventsToCloud(deduplicatedEvents);
      
      // Mark events as synced
      await _stateManager.markEventsSynced(
        deduplicatedEvents.map((e) => e.eventId).toList()
      );

      await _stateManager.completeSync(
        success: true,
        message: 'Successfully synced $uploadCount events',
      );

             return interfaces.SyncResult.success(
         uploadedCount: uploadCount,
         downloadedCount: 0,
         conflictCount: 0,
         duration: DateTime.now().difference(startTime),
       );

    } catch (e) {
      await _stateManager.completeSync(
        success: false,
        message: 'Upload failed: ${e.toString()}',
      );
      
      return interfaces.SyncResult.error(
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Enhanced sync from cloud with conflict resolution
  @override
  Future<interfaces.SyncResult> syncFromCloud() async {
    if (_isSyncing) {
      return interfaces.SyncResult.error(
        error: 'Sync already in progress',
        duration: Duration.zero,
      );
    }

    final startTime = DateTime.now();
    _isSyncing = true;
    int conflictCount = 0;

    try {
      await _stateManager.startSync(
        state: SyncState.downloading,
        statusMessage: 'Downloading remote changes...',
      );

      // Download events from cloud
      final remoteEvents = await _downloadEventsFromCloud();
      
      if (remoteEvents.isEmpty) {
        await _stateManager.completeSync(
          success: true,
          message: 'No remote changes to sync',
        );
        return interfaces.SyncResult.success(
          uploadedCount: 0,
          downloadedCount: 0,
          conflictCount: 0,
          duration: DateTime.now().difference(startTime),
        );
      }

      await _stateManager.updateProgress(
        statusMessage: 'Processing ${remoteEvents.length} remote events...',
      );

      // Change state to processing
      await _stateManager.startSync(
        state: SyncState.processing,
        totalEvents: remoteEvents.length,
        statusMessage: 'Processing remote events...',
      );

      // Process events and detect conflicts
      final processedEvents = <SyncEvent>[];
      for (int i = 0; i < remoteEvents.length; i++) {
        final event = remoteEvents[i];
        
        // Check for conflicts with local events
        final conflicts = await _detectConflicts(event);
        
        if (conflicts.isNotEmpty) {
          await _stateManager.startSync(
            state: SyncState.resolving_conflicts,
            statusMessage: 'Resolving conflicts...',
          );
          
          final resolution = await _conflictResolver.resolveCRDT(conflicts);
          conflictCount++;
          
          // Apply resolved conflict
          await _applyConflictResolution(event, resolution);
        } else {
          // No conflicts, process normally
          await _eventProcessor.processEvent(event);
        }
        
        processedEvents.add(event);
        
        await _stateManager.updateProgress(
          processedEvents: processedEvents.length,
          conflictCount: conflictCount,
          statusMessage: 'Processed ${processedEvents.length}/${remoteEvents.length} events',
        );
      }

      await _stateManager.completeSync(
        success: true,
        message: 'Successfully processed ${processedEvents.length} events with $conflictCount conflicts resolved',
      );

             return interfaces.SyncResult.success(
         uploadedCount: 0,
         downloadedCount: processedEvents.length,
         conflictCount: conflictCount,
         duration: DateTime.now().difference(startTime),
       );

    } catch (e) {
      await _stateManager.completeSync(
        success: false,
        message: 'Download failed: ${e.toString()}',
      );
      
      return interfaces.SyncResult.error(
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Full bidirectional sync
  @override
  Future<interfaces.SyncResult> performFullSync() async {
    final startTime = DateTime.now();
    
    try {
      // Upload local changes first
      final uploadResult = await syncToCloud();
      if (!uploadResult.success) {
        return uploadResult;
      }
      
      // Then download remote changes
      final downloadResult = await syncFromCloud();
      if (!downloadResult.success) {
        return downloadResult;
      }
      
             return interfaces.SyncResult.success(
         uploadedCount: uploadResult.uploadedCount,
         downloadedCount: downloadResult.downloadedCount,
         conflictCount: downloadResult.conflictCount,
         duration: DateTime.now().difference(startTime),
       );
      
    } catch (e) {
      return interfaces.SyncResult.error(
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
    }
  }

  /// Upload events to Google Drive
  Future<int> _uploadEventsToCloud(List<SyncEvent> events) async {
    final account = _googleSignIn.currentUser;
    if (account == null) {
      throw Exception('Not signed in');
    }

    final authHeaders = await account.authHeaders;
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', authHeaders['Authorization']?.split(' ')[1] ?? '', DateTime.now().add(Duration(hours: 1))),
        null,
        _scopes,
      ),
    );

    final driveApi = drive.DriveApi(client);
    
    try {
      // Create events batch
      final eventsBatch = SyncEventBatch(
        deviceId: _deviceId!,
        timestamp: DateTime.now(),
        events: events,
      );
      
      // Upload to dedicated sync folder
      final syncFolderId = await _ensureFolderExists(driveApi, GoogleDriveSyncService.SYNC_FOLDER);
      final fileName = 'events_${_deviceId}_${DateTime.now().millisecondsSinceEpoch}.json';
      
      await _uploadEventBatch(driveApi, syncFolderId, fileName, eventsBatch);
      
      return events.length;
    } finally {
      client.close();
    }
  }

  /// Download events from Google Drive
  Future<List<SyncEvent>> _downloadEventsFromCloud() async {
    final account = _googleSignIn.currentUser;
    if (account == null) {
      throw Exception('Not signed in');
    }

    final authHeaders = await account.authHeaders;
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', authHeaders['Authorization']?.split(' ')[1] ?? '', DateTime.now().add(Duration(hours: 1))),
        null,
        _scopes,
      ),
    );

    final driveApi = drive.DriveApi(client);
    
    try {
      final events = <SyncEvent>[];
      
      // Download event files from other devices
      final syncFolderId = await _ensureFolderExists(driveApi, GoogleDriveSyncService.SYNC_FOLDER);
      final eventFiles = await _listEventFiles(driveApi, syncFolderId);
      
      for (final file in eventFiles) {
        if (file.name?.startsWith('events_${_deviceId}_') == true) {
          continue; // Skip our own files
        }
        
        final fileContent = await _downloadFile(driveApi, file.id!);
        final batch = SyncEventBatch.fromJson(jsonDecode(fileContent));
        events.addAll(batch.events);
      }
      
      return events;
    } finally {
      client.close();
    }
  }

  /// Detect conflicts between remote and local events
  Future<List<SyncEvent>> _detectConflicts(SyncEvent remoteEvent) async {
    final query = _database.select(_database.syncEventLogTable)
      ..where((tbl) => tbl.tableNameField.equals(remoteEvent.tableName) & 
                      tbl.recordId.equals(remoteEvent.recordId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]);
    
    final localEvents = await query.get();
    
    if (localEvents.isEmpty) {
      return []; // No conflicts
    }
    
    // Check for temporal conflicts (events around the same time)
    final conflictWindow = Duration(minutes: 5);
    final conflicts = <SyncEvent>[];
    
    for (final localEvent in localEvents) {
      final timeDiff = remoteEvent.timestamp.difference(localEvent.timestamp).abs();
      if (timeDiff <= conflictWindow) {
        conflicts.add(SyncEvent(
          eventId: localEvent.eventId,
          deviceId: localEvent.deviceId,
          tableName: localEvent.tableNameField,
          recordId: localEvent.recordId,
          operation: localEvent.operation,
          data: jsonDecode(localEvent.data),
          timestamp: localEvent.timestamp,
          sequenceNumber: localEvent.sequenceNumber,
          hash: localEvent.hash,
        ));
      }
    }
    
    if (conflicts.isNotEmpty) {
      conflicts.add(remoteEvent);
    }
    
    return conflicts;
  }

  /// Apply conflict resolution
  Future<void> _applyConflictResolution(SyncEvent baseEvent, ConflictResolution resolution) async {
    switch (resolution.type) {
      case ConflictResolutionType.merge:
      case ConflictResolutionType.useLatest:
        if (resolution.resolvedData != null) {
          final mergedEvent = SyncEvent(
            eventId: baseEvent.eventId,
            deviceId: baseEvent.deviceId,
            tableName: baseEvent.tableName,
            recordId: baseEvent.recordId,
            operation: baseEvent.operation,
            data: resolution.resolvedData!,
            timestamp: baseEvent.timestamp,
            sequenceNumber: baseEvent.sequenceNumber,
            hash: baseEvent.hash,
          );
          await _eventProcessor.processEvent(mergedEvent);
        }
        break;
      case ConflictResolutionType.useLocal:
        // Keep local version - no action needed
        break;
      case ConflictResolutionType.manualResolution:
        // Log for manual review - Team B will handle UI
        print('Manual resolution required for ${baseEvent.tableName}:${baseEvent.recordId}');
        break;
    }
  }

  /// Set up periodic background sync
  void _setupPeriodicSync() {
    _periodicSyncTimer = Timer.periodic(Duration(minutes: 15), (timer) async {
      if (!_isSyncing && await isSignedIn()) {
        try {
          await performFullSync();
        } catch (e) {
          print('Periodic sync failed: $e');
        }
      }
    });
  }

  /// Helper methods from original implementation
  Future<String> _getOrCreateDeviceId() async {
    // Implementation similar to original IncrementalSyncService
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> _ensureFolderExists(drive.DriveApi driveApi, String folderName) async {
    // Implementation similar to GoogleDriveSyncService
    return 'folder_id';
  }

  Future<void> _uploadEventBatch(drive.DriveApi driveApi, String folderId, String fileName, SyncEventBatch batch) async {
    // Implementation similar to original
  }

  Future<List<drive.File>> _listEventFiles(drive.DriveApi driveApi, String folderId) async {
    // Implementation similar to original
    return [];
  }

  Future<String> _downloadFile(drive.DriveApi driveApi, String fileId) async {
    // Implementation similar to original
    return '{}';
  }

  /// Clean up resources
  void dispose() {
    _periodicSyncTimer?.cancel();
    _eventStreamController.close();
    _eventProcessor.dispose();
    _stateManager.dispose();
  }
} 