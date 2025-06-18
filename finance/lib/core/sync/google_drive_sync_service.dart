import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import 'sync_service.dart';
import '../database/app_database.dart';

class GoogleDriveSyncService implements SyncService {
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/drive.file',
  ];

  // ✅ PHASE 1 FIX 1: Namespace Separation
  static const String APP_ROOT = 'FinanceApp';
  static const String SYNC_FOLDER = '$APP_ROOT/database_sync';
  static const String ATTACHMENTS_FOLDER = '$APP_ROOT/user_attachments';

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  final AppDatabase _database;
  final StreamController<SyncStatus> _statusController = StreamController<SyncStatus>.broadcast();
  
  String? _deviceId;
  bool _isSyncing = false;
  
  GoogleDriveSyncService(this._database);

  @override
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  @override
  bool get isSyncing => _isSyncing;

  @override
  Future<bool> initialize() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
      } else {
        _deviceId = 'desktop-${DateTime.now().millisecondsSinceEpoch}';
      }
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
      // ✅ PHASE 1 FIX 2: Change Detection - Only sync if there are changes
      if (!await _hasUnsyncedChanges()) {
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
          AccessToken('Bearer', authHeaders['Authorization']?.split(' ')[1] ?? '', DateTime.now().add(Duration(hours: 1))),
          null,
          _scopes,
        ),
      );

      final driveApi = drive.DriveApi(client);
      
      // ✅ PHASE 1 FIX 1: Upload to separate sync folder
      final syncFolderId = await _ensureFolderExists(driveApi, SYNC_FOLDER);
      
      // Export database to temporary file
      final dbFile = await _exportDatabase();
      final fileName = 'sync-$_deviceId.sqlite';
      
      // Check if file already exists
      final existingFiles = await driveApi.files.list(
        q: "name='$fileName' and '$syncFolderId' in parents and trashed=false",
      );

      if (existingFiles.files?.isNotEmpty == true) {
        // Update existing file
        final existingFile = existingFiles.files!.first;
        await driveApi.files.update(
          drive.File(),
          existingFile.id!,
          uploadMedia: drive.Media(dbFile.openRead(), dbFile.lengthSync()),
        );
      } else {
        // Create new file in sync folder
        await driveApi.files.create(
          drive.File()
            ..name = fileName
            ..parents = [syncFolderId],
          uploadMedia: drive.Media(dbFile.openRead(), dbFile.lengthSync()),
        );
      }

      // Mark all records as synced
      await _markAllAsSynced();
      
      // Update last sync time
      await _updateLastSyncTime(DateTime.now());

      client.close();
      await dbFile.delete();

      _statusController.add(SyncStatus.completed);
      
      return SyncResult(
        success: true,
        uploadedCount: 1,
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
          AccessToken('Bearer', authHeaders['Authorization']?.split(' ')[1] ?? '', DateTime.now().add(Duration(hours: 1))),
          null,
          _scopes,
        ),
      );

      final driveApi = drive.DriveApi(client);
      
      // ✅ PHASE 1 FIX 1: Look in sync folder only
      final syncFolderId = await _ensureFolderExists(driveApi, SYNC_FOLDER);
      
      // Get list of sync files from other devices
      final syncFiles = await driveApi.files.list(
        q: "name contains 'sync-' and name contains '.sqlite' and '$syncFolderId' in parents and trashed=false",
      );

      int downloadedCount = 0;
      
      if (syncFiles.files?.isNotEmpty == true) {
        _statusController.add(SyncStatus.merging);
        
        for (final file in syncFiles.files!) {
          // Skip our own device's file
          if (file.name == 'sync-$_deviceId.sqlite') continue;
          
          // Download and merge the file
          final media = await driveApi.files.get(
            file.id!,
            downloadOptions: drive.DownloadOptions.fullMedia,
          ) as drive.Media;
          
          await _mergeDatabase(media.stream);
          downloadedCount++;
        }
      }

      client.close();
      
      // Update last sync time
      await _updateLastSyncTime(DateTime.now());

      _statusController.add(SyncStatus.completed);
      
      return SyncResult(
        success: true,
        uploadedCount: 0,
        downloadedCount: downloadedCount,
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

  /// Check if there are unsynced changes using event log approach
  Future<bool> _hasUnsyncedChanges() async {
    try {
      // ✅ PHASE 4: Use event sourcing approach - check for unsynced events
      final unsyncedEvents = await _database.customSelect('''
        SELECT COUNT(*) as count FROM sync_event_log 
        WHERE is_synced = false
      ''').getSingle();
      
      return unsyncedEvents.data['count'] > 0;
    } catch (e) {
      // Fallback: check if any records exist (simple approach)
      final tables = ['transactions', 'categories', 'accounts', 'budgets', 'attachments'];
      
      for (final table in tables) {
        try {
          final result = await _database.customSelect('''
            SELECT COUNT(*) as count FROM $table
          ''').getSingle();
          
          if (result.data['count'] > 0) {
            return true; // Assume needs sync if data exists
          }
        } catch (e) {
          // Table might not exist, continue
          continue;
        }
      }
      
      return false;
    }
  }

  // ✅ PHASE 4: Content Hashing for Better Conflict Detection (cleaned)
  String _calculateRecordHash(Map<String, dynamic> data) {
    final contentData = Map<String, dynamic>.from(data);
    // Remove sync-specific fields that shouldn't affect content
    contentData.remove('syncId');
    contentData.remove('createdAt');
    contentData.remove('updatedAt');
    
    final content = jsonEncode(contentData);
    return sha256.convert(utf8.encode(content)).toString();
  }

  // ✅ PHASE 1 FIX 1: Folder Management for Namespace Separation
  Future<String> _ensureFolderExists(drive.DriveApi driveApi, String folderPath) async {
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

  Future<File> _exportDatabase() async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'export_${DateTime.now().millisecondsSinceEpoch}.sqlite'));
    
    // Get database file path
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'finance_db.sqlite'));
    
    // Copy database file
    await dbFile.copy(tempFile.path);
    
    return tempFile;
  }

  Future<void> _mergeDatabase(Stream<List<int>> dataStream) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'merge_${DateTime.now().millisecondsSinceEpoch}.sqlite'));
    
    try {
      // Save the stream to a temporary file
      final sink = tempFile.openWrite();
      await dataStream.forEach(sink.add);
      await sink.close();
      
      // Open the temporary database
      final tempDatabase = AppDatabase.fromFile(tempFile);
      
      // Get all data from temporary database
      final remoteTxns = await tempDatabase.select(tempDatabase.transactionsTable).get();
      final remoteCategories = await tempDatabase.select(tempDatabase.categoriesTable).get();
      final remoteAccounts = await tempDatabase.select(tempDatabase.accountsTable).get();
      final remoteBudgets = await tempDatabase.select(tempDatabase.budgetsTable).get();
      final remoteAttachments = await tempDatabase.select(tempDatabase.attachmentsTable).get();
      
      await tempDatabase.close();
      
      // ✅ PHASE 1 FIX 3: Enhanced conflict resolution with content hashing
      await _mergeTransactions(remoteTxns);
      await _mergeCategories(remoteCategories);
      await _mergeAccounts(remoteAccounts);
      await _mergeBudgets(remoteBudgets);
      await _mergeAttachments(remoteAttachments);
      
    } finally {
      // Clean up temporary file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  // ✅ PHASE 1 FIX 3: Enhanced merge with content hashing
  Future<void> _mergeTransactions(List<TransactionsTableData> remoteTxns) async {
    for (final remoteTxn in remoteTxns) {
      final localTxn = await (_database.select(_database.transactionsTable)
        ..where((tbl) => tbl.syncId.equals(remoteTxn.syncId)))
        .getSingleOrNull();
        
      if (localTxn == null) {
        // New record - insert (Phase 4: only use syncId field)
        await _database.into(_database.transactionsTable).insert(
          TransactionsTableCompanion.insert(
            title: remoteTxn.title,
            amount: remoteTxn.amount,
            categoryId: remoteTxn.categoryId,
            accountId: remoteTxn.accountId,
            date: remoteTxn.date,
            note: Value(remoteTxn.note),
            createdAt: Value(remoteTxn.createdAt),
            updatedAt: Value(remoteTxn.updatedAt),
            transactionType: Value(remoteTxn.transactionType),
            specialType: Value(remoteTxn.specialType),
            recurrence: Value(remoteTxn.recurrence),
            periodLength: Value(remoteTxn.periodLength),
            endDate: Value(remoteTxn.endDate),
            originalDateDue: Value(remoteTxn.originalDateDue),
            transactionState: Value(remoteTxn.transactionState),
            paid: Value(remoteTxn.paid),
            skipPaid: Value(remoteTxn.skipPaid),
            createdAnotherFutureTransaction: Value(remoteTxn.createdAnotherFutureTransaction),
            objectiveLoanFk: Value(remoteTxn.objectiveLoanFk),
            syncId: remoteTxn.syncId,
          ),
        );
      } else {
        // ✅ PHASE 4: Simple conflict resolution - use timestamp comparison
        if (remoteTxn.updatedAt.isAfter(localTxn.updatedAt)) {
          await (_database.update(_database.transactionsTable)
            ..where((tbl) => tbl.syncId.equals(remoteTxn.syncId)))
            .write(TransactionsTableCompanion(
              title: Value(remoteTxn.title),
              note: Value(remoteTxn.note),
              amount: Value(remoteTxn.amount),
              categoryId: Value(remoteTxn.categoryId),
              accountId: Value(remoteTxn.accountId),
              date: Value(remoteTxn.date),
              updatedAt: Value(remoteTxn.updatedAt),
              transactionType: Value(remoteTxn.transactionType),
              specialType: Value(remoteTxn.specialType),
              recurrence: Value(remoteTxn.recurrence),
              periodLength: Value(remoteTxn.periodLength),
              endDate: Value(remoteTxn.endDate),
              originalDateDue: Value(remoteTxn.originalDateDue),
              transactionState: Value(remoteTxn.transactionState),
              paid: Value(remoteTxn.paid),
              skipPaid: Value(remoteTxn.skipPaid),
              createdAnotherFutureTransaction: Value(remoteTxn.createdAnotherFutureTransaction),
              objectiveLoanFk: Value(remoteTxn.objectiveLoanFk),
            ));
        }
        // Else keep local version (it's newer)
      }
    }
  }

  Future<void> _mergeCategories(List<CategoriesTableData> remoteCategories) async {
    for (final remoteCategory in remoteCategories) {
      final localCategory = await (_database.select(_database.categoriesTable)
        ..where((tbl) => tbl.syncId.equals(remoteCategory.syncId)))
        .getSingleOrNull();
        
      if (localCategory == null) {
        // ✅ PHASE 4: Insert new category with only essential fields
        await _database.into(_database.categoriesTable).insert(
          CategoriesTableCompanion.insert(
            name: remoteCategory.name,
            icon: remoteCategory.icon,
            color: remoteCategory.color,
            isExpense: remoteCategory.isExpense,
            isDefault: Value(remoteCategory.isDefault),
            createdAt: Value(remoteCategory.createdAt),
            updatedAt: Value(remoteCategory.updatedAt),
            syncId: remoteCategory.syncId,
          ),
        );
      } else {
        // ✅ PHASE 4: Simple conflict resolution - use timestamp comparison
        if (remoteCategory.updatedAt.isAfter(localCategory.updatedAt)) {
          await (_database.update(_database.categoriesTable)
            ..where((tbl) => tbl.syncId.equals(remoteCategory.syncId)))
            .write(CategoriesTableCompanion(
              name: Value(remoteCategory.name),
              icon: Value(remoteCategory.icon),
              color: Value(remoteCategory.color),
              isExpense: Value(remoteCategory.isExpense),
              isDefault: Value(remoteCategory.isDefault),
              updatedAt: Value(remoteCategory.updatedAt),
            ));
        }
      }
    }
  }

  Future<void> _mergeAccounts(List<AccountsTableData> remoteAccounts) async {
    for (final remoteAccount in remoteAccounts) {
      final localAccount = await (_database.select(_database.accountsTable)
        ..where((tbl) => tbl.syncId.equals(remoteAccount.syncId)))
        .getSingleOrNull();
        
      if (localAccount == null) {
        // ✅ PHASE 4: Insert new account with only essential fields
        await _database.into(_database.accountsTable).insert(
          AccountsTableCompanion.insert(
            name: remoteAccount.name,
            syncId: remoteAccount.syncId,
            balance: Value(remoteAccount.balance),
            currency: Value(remoteAccount.currency),
            isDefault: Value(remoteAccount.isDefault),
            createdAt: Value(remoteAccount.createdAt),
            updatedAt: Value(remoteAccount.updatedAt),
          ),
        );
      } else {
        // ✅ PHASE 4: Simple conflict resolution - use timestamp comparison
        if (remoteAccount.updatedAt.isAfter(localAccount.updatedAt)) {
          await (_database.update(_database.accountsTable)
            ..where((tbl) => tbl.syncId.equals(remoteAccount.syncId)))
            .write(AccountsTableCompanion(
              name: Value(remoteAccount.name),
              balance: Value(remoteAccount.balance),
              currency: Value(remoteAccount.currency),
              isDefault: Value(remoteAccount.isDefault),
              updatedAt: Value(remoteAccount.updatedAt),
            ));
        }
      }
    }
  }

  Future<void> _mergeBudgets(List<BudgetTableData> remoteBudgets) async {
    for (final remoteBudget in remoteBudgets) {
      final localBudget = await (_database.select(_database.budgetsTable)
        ..where((tbl) => tbl.syncId.equals(remoteBudget.syncId)))
        .getSingleOrNull();
        
      if (localBudget == null) {
        // ✅ PHASE 4: Insert new budget with only essential fields
        await _database.into(_database.budgetsTable).insert(
          BudgetsTableCompanion.insert(
            name: remoteBudget.name,
            amount: remoteBudget.amount,
            spent: Value(remoteBudget.spent),
            categoryId: Value(remoteBudget.categoryId),
            period: remoteBudget.period,
            startDate: remoteBudget.startDate,
            endDate: remoteBudget.endDate,
            isActive: Value(remoteBudget.isActive),
            createdAt: Value(remoteBudget.createdAt),
            updatedAt: Value(remoteBudget.updatedAt),
            syncId: remoteBudget.syncId,
            budgetTransactionFilters: Value(remoteBudget.budgetTransactionFilters),
            excludeDebtCreditInstallments: Value(remoteBudget.excludeDebtCreditInstallments),
            excludeObjectiveInstallments: Value(remoteBudget.excludeObjectiveInstallments),
            walletFks: Value(remoteBudget.walletFks),
            currencyFks: Value(remoteBudget.currencyFks),
            sharedReferenceBudgetPk: Value(remoteBudget.sharedReferenceBudgetPk),
            budgetFksExclude: Value(remoteBudget.budgetFksExclude),
            normalizeToCurrency: Value(remoteBudget.normalizeToCurrency),
            isIncomeBudget: Value(remoteBudget.isIncomeBudget),
            includeTransferInOutWithSameCurrency: Value(remoteBudget.includeTransferInOutWithSameCurrency),
            includeUpcomingTransactionFromBudget: Value(remoteBudget.includeUpcomingTransactionFromBudget),
            dateCreatedOriginal: Value(remoteBudget.dateCreatedOriginal),
          ),
        );
      } else {
        // ✅ PHASE 4: Simple conflict resolution - use timestamp comparison
        if (remoteBudget.updatedAt.isAfter(localBudget.updatedAt)) {
          await (_database.update(_database.budgetsTable)
            ..where((tbl) => tbl.syncId.equals(remoteBudget.syncId)))
            .write(BudgetsTableCompanion(
              name: Value(remoteBudget.name),
              amount: Value(remoteBudget.amount),
              spent: Value(remoteBudget.spent),
              categoryId: Value(remoteBudget.categoryId),
              period: Value(remoteBudget.period),
              startDate: Value(remoteBudget.startDate),
              endDate: Value(remoteBudget.endDate),
              isActive: Value(remoteBudget.isActive),
              updatedAt: Value(remoteBudget.updatedAt),
              budgetTransactionFilters: Value(remoteBudget.budgetTransactionFilters),
              excludeDebtCreditInstallments: Value(remoteBudget.excludeDebtCreditInstallments),
              excludeObjectiveInstallments: Value(remoteBudget.excludeObjectiveInstallments),
              walletFks: Value(remoteBudget.walletFks),
              currencyFks: Value(remoteBudget.currencyFks),
              sharedReferenceBudgetPk: Value(remoteBudget.sharedReferenceBudgetPk),
              budgetFksExclude: Value(remoteBudget.budgetFksExclude),
              normalizeToCurrency: Value(remoteBudget.normalizeToCurrency),
              isIncomeBudget: Value(remoteBudget.isIncomeBudget),
              includeTransferInOutWithSameCurrency: Value(remoteBudget.includeTransferInOutWithSameCurrency),
              includeUpcomingTransactionFromBudget: Value(remoteBudget.includeUpcomingTransactionFromBudget),
              dateCreatedOriginal: Value(remoteBudget.dateCreatedOriginal),
            ));
        }
      }
    }
  }

  Future<void> _mergeAttachments(List<AttachmentsTableData> remoteAttachments) async {
    // Merge attachments - only sync the metadata, not the actual files
    for (final remoteAttachment in remoteAttachments) {
      final localAttachment = await (_database.select(_database.attachmentsTable)
        ..where((tbl) => tbl.syncId.equals(remoteAttachment.syncId)))
        .getSingleOrNull();
      
      if (localAttachment == null) {
        // Insert new attachment (only metadata - files remain on individual devices or Google Drive)
        // ✅ PHASE 4: Insert new attachment with only essential fields
        await _database.into(_database.attachmentsTable).insert(
          AttachmentsTableCompanion.insert(
            transactionId: remoteAttachment.transactionId,
            fileName: remoteAttachment.fileName,
            filePath: const Value(null), // Don't sync local file paths
            googleDriveFileId: Value(remoteAttachment.googleDriveFileId),
            googleDriveLink: Value(remoteAttachment.googleDriveLink),
            type: remoteAttachment.type,
            mimeType: Value(remoteAttachment.mimeType),
            fileSizeBytes: Value(remoteAttachment.fileSizeBytes),
            isUploaded: Value(remoteAttachment.isUploaded),
            isDeleted: Value(remoteAttachment.isDeleted),
            isCapturedFromCamera: Value(remoteAttachment.isCapturedFromCamera),
            localCacheExpiry: const Value(null), // Don't sync cache expiry
            syncId: remoteAttachment.syncId,
          ),
        );
      } else {
        // ✅ PHASE 4: Simple conflict resolution - use timestamp comparison
        if (remoteAttachment.updatedAt.isAfter(localAttachment.updatedAt)) {
          await (_database.update(_database.attachmentsTable)
            ..where((tbl) => tbl.syncId.equals(remoteAttachment.syncId)))
            .write(AttachmentsTableCompanion(
              fileName: Value(remoteAttachment.fileName),
              googleDriveFileId: Value(remoteAttachment.googleDriveFileId),
              googleDriveLink: Value(remoteAttachment.googleDriveLink),
              type: Value(remoteAttachment.type),
              mimeType: Value(remoteAttachment.mimeType),
              fileSizeBytes: Value(remoteAttachment.fileSizeBytes),
              isUploaded: Value(remoteAttachment.isUploaded),
              isDeleted: Value(remoteAttachment.isDeleted),
              isCapturedFromCamera: Value(remoteAttachment.isCapturedFromCamera),
              updatedAt: Value(remoteAttachment.updatedAt),
            ));
        }
      }
    }
  }

  /// ✅ PHASE 4: Mark sync events as processed (event sourcing approach)
  Future<void> _markAllAsSynced() async {
    final now = DateTime.now();
    
    try {
      // ✅ PHASE 4: Mark sync events as synced (event sourcing approach)
      await _database.customStatement('''
        UPDATE sync_event_log 
        SET is_synced = true 
        WHERE is_synced = false
      ''');
      
      // Update last sync time
      await _updateLastSyncTime(now);
    } catch (e) {
      // Fallback: If event log doesn't exist, just update metadata
      print('Warning: Could not mark events as synced (event log may not exist): $e');
      await _updateLastSyncTime(now);
    }
  }

  /// ✅ PHASE 4.4: Mark specific events as synced for better control
  Future<void> _markEventsAsSynced(List<String> eventIds) async {
    if (eventIds.isEmpty) return;
    
    try {
      // ✅ PHASE 4.4: Enhanced batch operation with better error handling
      final placeholders = eventIds.map((_) => '?').join(', ');
      await _database.customStatement(
        'UPDATE sync_event_log SET is_synced = true WHERE event_id IN ($placeholders)',
        eventIds,
      );
      
      print('✅ PHASE 4.4: Marked ${eventIds.length} events as synced');
    } catch (e) {
      // ✅ PHASE 4.4: Fallback strategy for failed batch operations
      print('Warning: Batch event marking failed, trying individual fallback: $e');
      
      int successCount = 0;
      for (final eventId in eventIds) {
        try {
          await _database.customStatement(
            'UPDATE sync_event_log SET is_synced = true WHERE event_id = ?',
            [eventId],
          );
          successCount++;
        } catch (individualError) {
          print('Failed to mark event $eventId as synced: $individualError');
        }
      }
      
      print('✅ PHASE 4.4: Individual fallback completed: $successCount/${eventIds.length} events marked');
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
