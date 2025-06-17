import 'dart:async';
import 'dart:io';
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
      
      // Export database to temporary file
      final dbFile = await _exportDatabase();
      final fileName = 'sync-$_deviceId.sqlite';
      
      // Check if file already exists
      final existingFiles = await driveApi.files.list(
        q: "name='$fileName' and trashed=false",
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
        // Create new file
        await driveApi.files.create(
          drive.File()
            ..name = fileName
            ..parents = ['appDataFolder'],
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
      
      // Get list of sync files from other devices
      final syncFiles = await driveApi.files.list(
        q: "name contains 'sync-' and name contains '.sqlite' and trashed=false",
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
      
      // Merge transactions
      for (final remoteTxn in remoteTxns) {
        final localTxn = await (_database.select(_database.transactionsTable)
          ..where((tbl) => tbl.syncId.equals(remoteTxn.syncId)))
          .getSingleOrNull();
          if (localTxn == null) {
          // Insert new transaction
          await _database.into(_database.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              title: remoteTxn.title,
              note: Value(remoteTxn.note),
              amount: remoteTxn.amount,
              categoryId: remoteTxn.categoryId,
              accountId: remoteTxn.accountId,
              date: remoteTxn.date,
              createdAt: Value(remoteTxn.createdAt),
              updatedAt: Value(remoteTxn.updatedAt),
              deviceId: remoteTxn.deviceId,
              isSynced: const Value(true),
              lastSyncAt: Value(remoteTxn.lastSyncAt),
              syncId: remoteTxn.syncId,
              version: Value(remoteTxn.version),
            ),
          );
        } else if (remoteTxn.version > localTxn.version || 
                  (remoteTxn.version == localTxn.version && remoteTxn.updatedAt.isAfter(localTxn.updatedAt))) {
          // Update with newer version
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
              isSynced: const Value(true),
              lastSyncAt: Value(remoteTxn.lastSyncAt),
              version: Value(remoteTxn.version),
            ));
        }
      }
      
      // Merge categories
      for (final remoteCategory in remoteCategories) {
        final localCategory = await (_database.select(_database.categoriesTable)
          ..where((tbl) => tbl.syncId.equals(remoteCategory.syncId)))
          .getSingleOrNull();
        
        if (localCategory == null) {
          await _database.into(_database.categoriesTable).insert(
            CategoriesTableCompanion.insert(
              name: remoteCategory.name,
              icon: remoteCategory.icon,
              color: remoteCategory.color,
              isExpense: remoteCategory.isExpense,
              isDefault: Value(remoteCategory.isDefault),
              createdAt: Value(remoteCategory.createdAt),
              updatedAt: Value(remoteCategory.updatedAt),
              deviceId: remoteCategory.deviceId,
              isSynced: const Value(true),
              lastSyncAt: Value(remoteCategory.lastSyncAt),
              syncId: remoteCategory.syncId,
              version: Value(remoteCategory.version),
            ),
          );
        } else if (remoteCategory.version > localCategory.version || 
                  (remoteCategory.version == localCategory.version && remoteCategory.updatedAt.isAfter(localCategory.updatedAt))) {
          await (_database.update(_database.categoriesTable)
            ..where((tbl) => tbl.syncId.equals(remoteCategory.syncId)))
            .write(CategoriesTableCompanion(
              name: Value(remoteCategory.name),
              icon: Value(remoteCategory.icon),
              color: Value(remoteCategory.color),
              isExpense: Value(remoteCategory.isExpense),
              isDefault: Value(remoteCategory.isDefault),
              updatedAt: Value(remoteCategory.updatedAt),
              isSynced: const Value(true),
              lastSyncAt: Value(remoteCategory.lastSyncAt),
              version: Value(remoteCategory.version),
            ));
        }
      }
      
      // Merge accounts
      for (final remoteAccount in remoteAccounts) {
        final localAccount = await (_database.select(_database.accountsTable)
          ..where((tbl) => tbl.syncId.equals(remoteAccount.syncId)))
          .getSingleOrNull();
        
        if (localAccount == null) {
          await _database.into(_database.accountsTable).insert(
            AccountsTableCompanion.insert(
              name: remoteAccount.name,
              deviceId: remoteAccount.deviceId,
              syncId: remoteAccount.syncId,
              balance: Value(remoteAccount.balance),
              currency: Value(remoteAccount.currency),
              isDefault: Value(remoteAccount.isDefault),
              createdAt: Value(remoteAccount.createdAt),
              updatedAt: Value(remoteAccount.updatedAt),
              isSynced: const Value(true),
              lastSyncAt: Value(remoteAccount.lastSyncAt),
              version: Value(remoteAccount.version),
            ),
          );
        } else if (remoteAccount.version > localAccount.version || 
                  (remoteAccount.version == localAccount.version && remoteAccount.updatedAt.isAfter(localAccount.updatedAt))) {
          await (_database.update(_database.accountsTable)
            ..where((tbl) => tbl.syncId.equals(remoteAccount.syncId)))
            .write(AccountsTableCompanion(
              name: Value(remoteAccount.name),
              balance: Value(remoteAccount.balance),
              currency: Value(remoteAccount.currency),
              isDefault: Value(remoteAccount.isDefault),
              updatedAt: Value(remoteAccount.updatedAt),
              isSynced: const Value(true),
              lastSyncAt: Value(remoteAccount.lastSyncAt),
              version: Value(remoteAccount.version),
            ));
        }
      }
      
      // Merge budgets
      for (final remoteBudget in remoteBudgets) {
        final localBudget = await (_database.select(_database.budgetsTable)
          ..where((tbl) => tbl.syncId.equals(remoteBudget.syncId)))
          .getSingleOrNull();
        
        if (localBudget == null) {
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
              deviceId: remoteBudget.deviceId,
              isSynced: const Value(true),
              lastSyncAt: Value(remoteBudget.lastSyncAt),
              syncId: remoteBudget.syncId,
              version: Value(remoteBudget.version),
            ),
          );
        } else if (remoteBudget.version > localBudget.version || 
                  (remoteBudget.version == localBudget.version && remoteBudget.updatedAt.isAfter(localBudget.updatedAt))) {
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
              isSynced: const Value(true),
              lastSyncAt: Value(remoteBudget.lastSyncAt),
              version: Value(remoteBudget.version),
            ));
        }
      }
      
      // Merge attachments - only sync the metadata, not the actual files
      for (final remoteAttachment in remoteAttachments) {
        final localAttachment = await (_database.select(_database.attachmentsTable)
          ..where((tbl) => tbl.syncId.equals(remoteAttachment.syncId)))
          .getSingleOrNull();
        
        if (localAttachment == null) {
          // Insert new attachment (only metadata - files remain on individual devices or Google Drive)
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
              deviceId: remoteAttachment.deviceId,
              isSynced: const Value(true),
              lastSyncAt: Value(remoteAttachment.lastSyncAt),
              syncId: remoteAttachment.syncId,
              version: Value(remoteAttachment.version),
            ),
          );
        } else if (remoteAttachment.version > localAttachment.version || 
                  (remoteAttachment.version == localAttachment.version && remoteAttachment.updatedAt.isAfter(localAttachment.updatedAt))) {
          // Update with newer version (preserve local file path and cache expiry)
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
              isSynced: const Value(true),
              lastSyncAt: Value(remoteAttachment.lastSyncAt),
              version: Value(remoteAttachment.version),
            ));
        }
      }
    } finally {
      // Clean up temporary file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
  Future<void> _markAllAsSynced() async {
    final now = DateTime.now();
    
    // Mark transactions as synced
    await _database.update(_database.transactionsTable).write(
      TransactionsTableCompanion(
        isSynced: const Value(true),
        lastSyncAt: Value(now),
      ),
    );
    
    // Mark categories as synced
    await _database.update(_database.categoriesTable).write(
      CategoriesTableCompanion(
        isSynced: const Value(true),
        lastSyncAt: Value(now),
      ),
    );
    
    // Mark accounts as synced
    await _database.update(_database.accountsTable).write(
      AccountsTableCompanion(
        isSynced: const Value(true),
        lastSyncAt: Value(now),
      ),
    );
    
    // Mark budgets as synced
    await _database.update(_database.budgetsTable).write(
      BudgetsTableCompanion(
        isSynced: const Value(true),
        lastSyncAt: Value(now),
      ),
    );
    
    // Mark attachments as synced
    await _database.update(_database.attachmentsTable).write(
      AttachmentsTableCompanion(
        isSynced: const Value(true),
        lastSyncAt: Value(now),
      ),
    );
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
