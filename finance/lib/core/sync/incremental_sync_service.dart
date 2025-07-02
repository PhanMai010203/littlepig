import 'dart:async';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';

import 'sync_service.dart';
import 'sync_event.dart';
import 'crdt_conflict_resolver.dart';
import '../database/app_database.dart';
import 'google_drive_sync_service.dart';

/// Incremental sync service using event sourcing
/// This implements Phase 3 of the sync upgrade - real-time event-driven sync
class IncrementalSyncService implements SyncService {
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/drive.file',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  final AppDatabase _database;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  final CRDTConflictResolver _conflictResolver = CRDTConflictResolver();

  String? _deviceId;
  bool _isSyncing = false;

  IncrementalSyncService(this._database);

  @override
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  @override
  bool get isSyncing => _isSyncing;

  @override
  Future<bool> initialize() async {
    try {
      _deviceId = await _getOrCreateDeviceId();
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
  Future<String?> getCurrentUserEmail() async {
    final account = _googleSignIn.currentUser;
    return account?.email;
  }

  @override
  Future<SyncResult> syncToCloud() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        error: 'Sync already in progress',
        uploadedCount: 0,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    }

    _isSyncing = true;
    _statusController.add(SyncStatus.uploading);

    try {
      // Get unsynced events since last sync
      final unsyncedEvents = await _getUnsyncedEvents();

      if (unsyncedEvents.isEmpty) {
        _statusController.add(SyncStatus.completed);
        return SyncResult(
          success: true,
          uploadedCount: 0,
          downloadedCount: 0,
          timestamp: DateTime.now(),
        );
      }

      final account = _googleSignIn.currentUser;
      if (account == null) {
        throw Exception('Not signed in');
      }

      final authHeaders = await account.authHeaders;
      final client = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
              'Bearer',
              authHeaders['Authorization']?.split(' ')[1] ?? '',
              DateTime.now().add(const Duration(hours: 1))),
          null,
          _scopes,
        ),
      );

      final driveApi = drive.DriveApi(client);

      // Create events batch (much smaller than entire database!)
      final eventsBatch = SyncEventBatch(
        deviceId: _deviceId!,
        timestamp: DateTime.now(),
        events: unsyncedEvents.map(SyncEvent.fromEventLog).toList(),
      );

      // Upload to dedicated sync folder
      final syncFolderId = await _ensureFolderExists(
          driveApi, GoogleDriveSyncService.SYNC_FOLDER);
      final fileName =
          'events_${_deviceId}_${DateTime.now().millisecondsSinceEpoch}.json';

      await _uploadEventBatch(driveApi, syncFolderId, fileName, eventsBatch);

      // Mark events as synced
      await _markEventsAsSynced(unsyncedEvents);

      // Update sync state
      await _updateSyncState();

      client.close();
      _statusController.add(SyncStatus.completed);

      return SyncResult(
        success: true,
        uploadedCount: unsyncedEvents.length,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _statusController.add(SyncStatus.error);
      return SyncResult(
        success: false,
        error: e.toString(),
        uploadedCount: 0,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    } finally {
      _isSyncing = false;
      _statusController.add(SyncStatus.idle);
    }
  }

  @override
  Future<SyncResult> syncFromCloud() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        error: 'Sync already in progress',
        uploadedCount: 0,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    }

    _isSyncing = true;
    _statusController.add(SyncStatus.downloading);

    try {
      final account = _googleSignIn.currentUser;
      if (account == null) {
        throw Exception('Not signed in');
      }

      final authHeaders = await account.authHeaders;
      final client = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
              'Bearer',
              authHeaders['Authorization']?.split(' ')[1] ?? '',
              DateTime.now().add(const Duration(hours: 1))),
          null,
          _scopes,
        ),
      );

      final driveApi = drive.DriveApi(client);

      // Download event files from other devices
      final syncFolderId = await _ensureFolderExists(
          driveApi, GoogleDriveSyncService.SYNC_FOLDER);
      final eventFiles =
          await _getEventFilesFromOtherDevices(driveApi, syncFolderId);

      int appliedEvents = 0;

      if (eventFiles.isNotEmpty) {
        _statusController.add(SyncStatus.merging);

        for (final file in eventFiles) {
          final eventBatch = await _downloadAndParseEventBatch(driveApi, file);
          final applied = await _applyEventBatch(eventBatch);
          appliedEvents += applied;

          // Clean up processed event file
          await _cleanupProcessedEventFile(driveApi, file);
        }
      }

      client.close();

      // Update last sync time
      await _updateLastSyncTime(DateTime.now());

      _statusController.add(SyncStatus.completed);

      return SyncResult(
        success: true,
        uploadedCount: 0,
        downloadedCount: appliedEvents,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _statusController.add(SyncStatus.error);
      return SyncResult(
        success: false,
        error: e.toString(),
        uploadedCount: 0,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    } finally {
      _isSyncing = false;
      _statusController.add(SyncStatus.idle);
    }
  }

  @override
  Future<SyncResult> performFullSync() async {
    // First sync to cloud, then sync from cloud
    final uploadResult = await syncToCloud();
    if (!uploadResult.success) return uploadResult;

    final downloadResult = await syncFromCloud();

    return SyncResult(
      success: downloadResult.success,
      error: downloadResult.error,
      uploadedCount: uploadResult.uploadedCount,
      downloadedCount: downloadResult.downloadedCount,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    final query = _database.select(_database.syncMetadataTable)
      ..where((t) => t.key.equals('last_sync_time'));
    final result = await query.getSingleOrNull();
    if (result != null) {
      return DateTime.parse(result.value);
    }
    return null;
  }

  // ============ PRIVATE METHODS ============

  Future<String> _getOrCreateDeviceId() async {
    final query = _database.select(_database.syncMetadataTable)
      ..where((t) => t.key.equals('device_id'));
    final result = await query.getSingleOrNull();

    if (result != null) {
      return result.value;
    }

    // Create new device ID
    final deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
    await _database.into(_database.syncMetadataTable).insert(
          SyncMetadataTableCompanion.insert(
            key: 'device_id',
            value: deviceId,
          ),
        );

    return deviceId;
  }

  Future<List<SyncEventLogData>> _getUnsyncedEvents() async {
    return await (_database.select(_database.syncEventLogTable)
          ..where((t) => t.isSynced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sequenceNumber)]))
        .get();
  }

  Future<String> _ensureFolderExists(
      drive.DriveApi driveApi, String folderPath) async {
    final pathParts = folderPath.split('/');
    String currentParent = 'appDataFolder';

    for (final folderName in pathParts) {
      final existingFolders = await driveApi.files.list(
        q: "name='$folderName' and '$currentParent' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false",
      );

      if (existingFolders.files?.isNotEmpty == true) {
        currentParent = existingFolders.files!.first.id!;
      } else {
        // Create new folder
        final newFolder = await driveApi.files.create(
          drive.File()
            ..name = folderName
            ..mimeType = 'application/vnd.google-apps.folder'
            ..parents = [currentParent],
        );
        currentParent = newFolder.id!;
      }
    }

    return currentParent;
  }

  Future<void> _uploadEventBatch(
    drive.DriveApi driveApi,
    String folderId,
    String fileName,
    SyncEventBatch eventBatch,
  ) async {
    final content = jsonEncode(eventBatch.toJson());
    final bytes = utf8.encode(content);

    await driveApi.files.create(
      drive.File()
        ..name = fileName
        ..parents = [folderId],
      uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
    );
  }

  Future<void> _markEventsAsSynced(List<SyncEventLogData> events) async {
    if (events.isEmpty) return;

    final now = DateTime.now();

    try {
      // ✅ PHASE 4.4: Enhanced batch operation using event IDs for better control
      final eventIds = events.map((e) => e.eventId).toList();
      final placeholders = eventIds.map((_) => '?').join(', ');

      await _database.customStatement(
        'UPDATE sync_event_log SET is_synced = true WHERE event_id IN ($placeholders)',
        eventIds,
      );

      print('✅ PHASE 4.4: Batch marked ${events.length} events as synced');
    } catch (e) {
      // ✅ PHASE 4.4: Enhanced fallback strategy with detailed error handling
      print('Warning: Batch update failed, trying individual updates: $e');

      int successCount = 0;
      for (final event in events) {
        try {
          final rowsAffected =
              await (_database.update(_database.syncEventLogTable)
                    ..where((t) => t.eventId.equals(event.eventId)))
                  .write(const SyncEventLogTableCompanion(
            isSynced: Value(true),
          ));

          if (rowsAffected > 0) {
            successCount++;
          }
        } catch (individualError) {
          print(
              'Failed to mark event ${event.eventId} as synced: $individualError');
        }
      }

      print(
          '✅ PHASE 4.4: Individual fallback completed: $successCount/${events.length} events marked');
    }
  }

  Future<void> _updateSyncState() async {
    final now = DateTime.now();
    final lastSequence = await _getLastSequenceNumber();

    await _database.into(_database.syncStateTable).insertOnConflictUpdate(
          SyncStateTableCompanion.insert(
            deviceId: _deviceId!,
            lastSyncTime: now,
            lastSequenceNumber: Value(lastSequence),
            status: const Value('idle'),
          ),
        );
  }

  Future<int> _getLastSequenceNumber() async {
    final query = _database.select(_database.syncEventLogTable)
      ..where((t) => t.deviceId.equals(_deviceId!))
      ..orderBy([(t) => OrderingTerm.desc(t.sequenceNumber)])
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.sequenceNumber ?? 0;
  }

  Future<List<drive.File>> _getEventFilesFromOtherDevices(
    drive.DriveApi driveApi,
    String syncFolderId,
  ) async {
    final eventFiles = await driveApi.files.list(
      q: "name contains 'events_' and name contains '.json' and '$syncFolderId' in parents and trashed=false",
    );

    // Filter out our own device's files
    return eventFiles.files
            ?.where((file) => !file.name!.startsWith('events_$_deviceId'))
            .toList() ??
        [];
  }

  Future<SyncEventBatch> _downloadAndParseEventBatch(
    drive.DriveApi driveApi,
    drive.File file,
  ) async {
    final media = await driveApi.files.get(
      file.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }

    final content = utf8.decode(bytes);
    final json = jsonDecode(content);

    return SyncEventBatch.fromJson(json);
  }

  Future<int> _applyEventBatch(SyncEventBatch eventBatch) async {
    int appliedEvents = 0;

    // Group events by record to handle conflicts
    final eventsByRecord = <String, List<SyncEvent>>{};

    for (final event in eventBatch.events) {
      final key = '${event.tableName}:${event.recordId}';
      eventsByRecord.putIfAbsent(key, () => []).add(event);
    }

    // Process each record's events
    for (final entry in eventsByRecord.entries) {
      final events = entry.value;
      events.sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));

      // Check for conflicts
      if (events.length > 1) {
        final resolution = await _conflictResolver.resolveCRDT(events);
        final success =
            await _applyConflictResolution(events.first, resolution);
        if (success) appliedEvents += events.length;
      } else {
        final success = await _applySingleEvent(events.first);
        if (success) appliedEvents++;
      }
    }

    return appliedEvents;
  }

  Future<bool> _applySingleEvent(SyncEvent event) async {
    try {
      switch (event.operation) {
        case 'create':
          return await _handleCreateEvent(event);
        case 'update':
          return await _handleUpdateEvent(event);
        case 'delete':
          return await _handleDeleteEvent(event);
        default:
          return false;
      }
    } catch (e) {
      // Log error but don't fail the entire sync
      print('Failed to apply event ${event.eventId}: $e');
      return false;
    }
  }

  Future<bool> _applyConflictResolution(
      SyncEvent baseEvent, ConflictResolution resolution) async {
    switch (resolution.type) {
      case ConflictResolutionType.merge:
      case ConflictResolutionType.useLatest:
        if (resolution.resolvedData != null) {
          final mergedEvent =
              baseEvent.copyWith(data: resolution.resolvedData!);
          return await _handleUpdateEvent(mergedEvent);
        }
        return false;
      case ConflictResolutionType.useLocal:
        // Keep local version - no action needed
        return true;
      case ConflictResolutionType.manualResolution:
        // Log for manual review
        print(
            'Manual resolution required for ${baseEvent.tableName}:${baseEvent.recordId} - ${resolution.reason}');
        return false;
    }
  }

  Future<bool> _handleCreateEvent(SyncEvent event) async {
    switch (event.tableName) {
      case 'transactions':
        return await _createTransaction(event.data);
      case 'categories':
        return await _createCategory(event.data);
      case 'accounts':
        return await _createAccount(event.data);
      case 'budgets':
        return await _createBudget(event.data);
      case 'attachments':
        return await _createAttachment(event.data);
      default:
        return false;
    }
  }

  Future<bool> _handleUpdateEvent(SyncEvent event) async {
    switch (event.tableName) {
      case 'transactions':
        return await _updateTransaction(event.recordId, event.data);
      case 'categories':
        return await _updateCategory(event.recordId, event.data);
      case 'accounts':
        return await _updateAccount(event.recordId, event.data);
      case 'budgets':
        return await _updateBudget(event.recordId, event.data);
      case 'attachments':
        return await _updateAttachment(event.recordId, event.data);
      default:
        return false;
    }
  }

  Future<bool> _handleDeleteEvent(SyncEvent event) async {
    switch (event.tableName) {
      case 'transactions':
        return await _deleteTransaction(event.recordId);
      case 'categories':
        return await _deleteCategory(event.recordId);
      case 'accounts':
        return await _deleteAccount(event.recordId);
      case 'budgets':
        return await _deleteBudget(event.recordId);
      case 'attachments':
        return await _deleteAttachment(event.recordId);
      default:
        return false;
    }
  }

  // Create operations
  Future<bool> _createTransaction(Map<String, dynamic> data) async {
    try {
      await _database.into(_database.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              title: data['title'],
              note: Value(data['note']),
              amount: data['amount'],
              categoryId: data['categoryId'],
              accountId: data['accountId'],
              date: DateTime.parse(data['date']),
              syncId: data['syncId'],
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _createCategory(Map<String, dynamic> data) async {
    try {
      await _database.into(_database.categoriesTable).insert(
            CategoriesTableCompanion.insert(
              name: data['name'],
              icon: data['icon'],
              color: data['color'],
              isExpense: data['isExpense'],
              syncId: data['syncId'],
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _createAccount(Map<String, dynamic> data) async {
    try {
      await _database.into(_database.accountsTable).insert(
            AccountsTableCompanion.insert(
              name: data['name'],
              syncId: data['syncId'],
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _createBudget(Map<String, dynamic> data) async {
    try {
      await _database.into(_database.budgetsTable).insert(
            BudgetsTableCompanion.insert(
              name: data['name'],
              amount: data['amount'],
              period: data['period'],
              periodAmount: Value(data['periodAmount'] ?? 1),
              startDate: DateTime.parse(data['startDate']),
              endDate: DateTime.parse(data['endDate']),
              syncId: data['syncId'],
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _createAttachment(Map<String, dynamic> data) async {
    try {
      await _database.into(_database.attachmentsTable).insert(
            AttachmentsTableCompanion.insert(
              transactionId: data['transactionId'],
              fileName: data['fileName'],
              type: data['type'],
              syncId: data['syncId'],
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update operations
  Future<bool> _updateTransaction(
      String syncId, Map<String, dynamic> data) async {
    try {
      await (_database.update(_database.transactionsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .write(TransactionsTableCompanion(
        title: Value(data['title']),
        note: Value(data['note']),
        amount: Value(data['amount']),
        categoryId: Value(data['categoryId']),
        accountId: Value(data['accountId']),
        date: Value(DateTime.parse(data['date'])),
        updatedAt: Value(DateTime.now()),
      ));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateCategory(String syncId, Map<String, dynamic> data) async {
    try {
      await (_database.update(_database.categoriesTable)
            ..where((t) => t.syncId.equals(syncId)))
          .write(CategoriesTableCompanion(
        name: Value(data['name']),
        icon: Value(data['icon']),
        color: Value(data['color']),
        isExpense: Value(data['isExpense']),
        updatedAt: Value(DateTime.now()),
      ));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateAccount(String syncId, Map<String, dynamic> data) async {
    try {
      await (_database.update(_database.accountsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .write(AccountsTableCompanion(
        name: Value(data['name']),
        updatedAt: Value(DateTime.now()),
      ));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateBudget(String syncId, Map<String, dynamic> data) async {
    try {
      await (_database.update(_database.budgetsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .write(BudgetsTableCompanion(
        name: Value(data['name']),
        amount: Value(data['amount']),
        period: Value(data['period']),
        periodAmount: Value(data['periodAmount'] ?? 1),
        startDate: Value(DateTime.parse(data['startDate'])),
        endDate: Value(DateTime.parse(data['endDate'])),
        updatedAt: Value(DateTime.now()),
      ));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateAttachment(
      String syncId, Map<String, dynamic> data) async {
    try {
      await (_database.update(_database.attachmentsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .write(AttachmentsTableCompanion(
        fileName: Value(data['fileName']),
        updatedAt: Value(DateTime.now()),
      ));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete operations
  Future<bool> _deleteTransaction(String syncId) async {
    try {
      await (_database.delete(_database.transactionsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .go();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteCategory(String syncId) async {
    try {
      await (_database.delete(_database.categoriesTable)
            ..where((t) => t.syncId.equals(syncId)))
          .go();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteAccount(String syncId) async {
    try {
      await (_database.delete(_database.accountsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .go();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteBudget(String syncId) async {
    try {
      await (_database.delete(_database.budgetsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .go();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteAttachment(String syncId) async {
    try {
      await (_database.delete(_database.attachmentsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .go();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _cleanupProcessedEventFile(
      drive.DriveApi driveApi, drive.File file) async {
    try {
      // Move to trash instead of permanent deletion
      await driveApi.files.update(
        drive.File()..trashed = true,
        file.id!,
      );
    } catch (e) {
      // Non-critical - log but don't fail sync
      print('Failed to cleanup event file ${file.name}: $e');
    }
  }

  Future<void> _updateLastSyncTime(DateTime time) async {
    await _database.into(_database.syncMetadataTable).insertOnConflictUpdate(
          SyncMetadataTableCompanion.insert(
            key: 'last_sync_time',
            value: time.toIso8601String(),
          ),
        );
  }
}
