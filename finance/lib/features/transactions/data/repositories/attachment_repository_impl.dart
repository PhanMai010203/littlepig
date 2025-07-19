import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/attachment.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/sync/google_drive_sync_service.dart';
import '../../../../core/repositories/cacheable_repository_mixin.dart';

@LazySingleton(as: AttachmentRepository)
class AttachmentRepositoryImpl
    with CacheableRepositoryMixin
    implements AttachmentRepository {
  final AppDatabase _database;
  final GoogleSignIn _googleSignIn;
  final Uuid _uuid = const Uuid();

  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/drive.file',
  ];

  AttachmentRepositoryImpl(this._database, this._googleSignIn);

  // ✅ PHASE 1 FIX 1: Organized attachment path structure
  String _getAttachmentPath(DateTime date, String transactionSyncId) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    return '${GoogleDriveSyncService.ATTACHMENTS_FOLDER}/$year/$month/$transactionSyncId/';
  }

  @override
  Future<Attachment> createAttachment(Attachment attachment) async {
    final now = DateTime.now();
    final syncId = attachment.syncId.isEmpty ? _uuid.v4() : attachment.syncId;

    final companion = AttachmentsTableCompanion.insert(
      transactionId: attachment.transactionId,
      fileName: attachment.fileName,
      filePath: Value(attachment.filePath),
      googleDriveFileId: Value(attachment.googleDriveFileId),
      googleDriveLink: Value(attachment.googleDriveLink),
      type: attachment.type.index,
      mimeType: Value(attachment.mimeType),
      fileSizeBytes: Value(attachment.fileSizeBytes),
      createdAt: Value(attachment.createdAt),
      updatedAt: Value(now),
      isUploaded: Value(attachment.isUploaded),
      isDeleted: Value(attachment.isDeleted),
      isCapturedFromCamera: Value(attachment.isCapturedFromCamera),
      localCacheExpiry: Value(attachment.localCacheExpiry),
      syncId: syncId,
    );

    final id =
        await _database.into(_database.attachmentsTable).insert(companion);

    await invalidateEntityCache('attachment');

    return attachment.copyWith(
      id: id,
      syncId: syncId,
      updatedAt: now,
    );
  }

  @override
  Future<Attachment?> getAttachmentById(int id) async {
    return cacheReadSingle(
      'getAttachmentById',
      () async {
        final query = _database.select(_database.attachmentsTable)
          ..where((table) => table.id.equals(id));

        final row = await query.getSingleOrNull();
        return row != null ? _mapRowToAttachment(row) : null;
      },
      params: {'id': id},
    );
  }

  @override
  Future<List<Attachment>> getAttachmentsByTransaction(
      int transactionId) async {
    return cacheRead(
      'getAttachmentsByTransaction',
      () async {
        final query = _database.select(_database.attachmentsTable)
          ..where((table) =>
              table.transactionId.equals(transactionId) &
              table.isDeleted.equals(false))
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);

        final rows = await query.get();
        return rows.map(_mapRowToAttachment).toList();
      },
      params: {'transactionId': transactionId},
    );
  }

  @override
  Future<List<Attachment>> getAllAttachments() async {
    return cacheRead('getAllAttachments', () async {
      final query = _database.select(_database.attachmentsTable)
        ..where((table) => table.isDeleted.equals(false))
        ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);

      final rows = await query.get();
      return rows.map(_mapRowToAttachment).toList();
    });
  }

  @override
  Future<Attachment> updateAttachment(Attachment attachment) async {
    final now = DateTime.now();
    final companion = AttachmentsTableCompanion(
      id: Value(attachment.id!),
      transactionId: Value(attachment.transactionId),
      fileName: Value(attachment.fileName),
      filePath: Value(attachment.filePath),
      googleDriveFileId: Value(attachment.googleDriveFileId),
      googleDriveLink: Value(attachment.googleDriveLink),
      type: Value(attachment.type.index),
      mimeType: Value(attachment.mimeType),
      fileSizeBytes: Value(attachment.fileSizeBytes),
      updatedAt: Value(now),
      isUploaded: Value(attachment.isUploaded),
      isDeleted: Value(attachment.isDeleted),
      isCapturedFromCamera: Value(attachment.isCapturedFromCamera),
      localCacheExpiry: Value(attachment.localCacheExpiry),
    );

    await (_database.update(_database.attachmentsTable)
          ..where((table) => table.id.equals(attachment.id!)))
        .write(companion);

    await invalidateEntityCache('attachment');

    return attachment.copyWith(updatedAt: now);
  }

  @override
  Future<void> deleteAttachment(int id) async {
    await (_database.delete(_database.attachmentsTable)
          ..where((table) => table.id.equals(id)))
        .go();
    await invalidateEntityCache('attachment');
  }

  @override
  Future<void> markAsDeleted(int id) async {
    final update = _database.update(_database.attachmentsTable)
      ..where((table) => table.id.equals(id));

    await update.write(AttachmentsTableCompanion(
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
    await invalidateEntityCache('attachment');
  }

  @override
  Future<void> uploadToGoogleDrive(Attachment attachment) async {
    debugPrint('☁️ [AttachmentRepository] uploadToGoogleDrive called');
    debugPrint('☁️ [AttachmentRepository] attachment.id: ${attachment.id}');
    debugPrint('☁️ [AttachmentRepository] attachment.fileName: ${attachment.fileName}');
    debugPrint('☁️ [AttachmentRepository] attachment.filePath: ${attachment.filePath}');
    debugPrint('☁️ [AttachmentRepository] attachment.syncId: ${attachment.syncId}');
    
    if (attachment.filePath == null) {
      debugPrint('❌ [AttachmentRepository] File path is null');
      throw Exception('File path is null');
    }

    final account = _googleSignIn.currentUser;
    if (account == null) {
      debugPrint('❌ [AttachmentRepository] Not signed in to Google');
      throw Exception('Not signed in to Google');
    }

    final file = File(attachment.filePath!);
    final fileExists = await file.exists();
    debugPrint('☁️ [AttachmentRepository] File exists: $fileExists');
    if (!fileExists) {
      debugPrint('❌ [AttachmentRepository] File does not exist: ${attachment.filePath}');
      throw Exception('File does not exist');
    }

    final authHeaders = await account.authHeaders;
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', authHeaders['Authorization']?.split(' ')[1] ?? '',
            DateTime.now().add(const Duration(hours: 1))),
        null,
        _scopes,
      ),
    );

    final driveApi = drive.DriveApi(client);

    try {
      // ✅ PHASE 1 FIX 1: Get transaction for organized folder structure
      final transaction = await _getTransactionForAttachment(attachment);
      final folderPath =
          _getAttachmentPath(transaction.date, transaction.syncId);

      // ✅ PHASE 1 FIX 1: Create organized folder hierarchy
      final folderId = await _ensureFolderExists(driveApi, folderPath);

      // ✅ PHASE 1 FIX 1: Check for duplicates using file hash
      final fileHash = await _calculateFileHash(file);
      final existingFile =
          await _findExistingFile(driveApi, fileHash, folderId);

      if (existingFile != null) {
        // File already exists - just update metadata
        await _updateAttachmentWithDriveInfo(attachment, existingFile);
        return;
      }

      // ✅ PHASE 1 FIX 1: Generate collision-safe filename
      final safeFileName = await _generateUniqueFileName(
          driveApi, attachment.fileName, folderId);

      final driveFile = drive.File()
        ..name = safeFileName
        ..parents = [folderId] // ✅ Upload to organized folder structure
        ..appProperties = {
          'fileHash': fileHash, // ✅ For deduplication
          'originalName': attachment.fileName,
          'capturedFromCamera': attachment.isCapturedFromCamera.toString(),
          'uploadedAt': DateTime.now().toIso8601String(),
        };

      final media = drive.Media(file.openRead(), file.lengthSync());

      debugPrint('☁️ [AttachmentRepository] Uploading file to Google Drive...');
      final uploadedFile = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );

      debugPrint('✅ [AttachmentRepository] File uploaded successfully');
      debugPrint('✅ [AttachmentRepository] Google Drive file ID: ${uploadedFile.id}');

      // Generate Google Drive link
      final googleDriveLink = uploadedFile.id != null 
          ? 'https://drive.google.com/file/d/${uploadedFile.id}/view'
          : null;
      
      debugPrint('✅ [AttachmentRepository] Generated Google Drive link: $googleDriveLink');

      // Update attachment with Google Drive info
      final updatedAttachment = attachment.copyWith(
        googleDriveFileId: uploadedFile.id,
        googleDriveLink: googleDriveLink,
        isUploaded: true,
        updatedAt: DateTime.now(),
      );

      debugPrint('✅ [AttachmentRepository] Updating attachment with Google Drive info...');
      await updateAttachment(updatedAttachment);
      debugPrint('✅ [AttachmentRepository] Attachment updated successfully');
    } finally {
      client.close();
    }
  }

  @override
  Future<void> deleteFromGoogleDrive(String googleDriveFileId) async {
    final account = _googleSignIn.currentUser;
    if (account == null) {
      throw Exception('Not signed in to Google');
    }

    final authHeaders = await account.authHeaders;
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', authHeaders['Authorization']?.split(' ')[1] ?? '',
            DateTime.now().add(const Duration(hours: 1))),
        null,
        _scopes,
      ),
    );

    final driveApi = drive.DriveApi(client);

    try {
      // Move file to trash instead of permanent deletion
      await driveApi.files.update(
        drive.File()..trashed = true,
        googleDriveFileId,
      );
    } finally {
      client.close();
    }
  }

  @override
  Future<String?> getGoogleDriveDownloadLink(String googleDriveFileId) async {
    final account = _googleSignIn.currentUser;
    if (account == null) {
      throw Exception('Not signed in to Google');
    }

    final authHeaders = await account.authHeaders;
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', authHeaders['Authorization']?.split(' ')[1] ?? '',
            DateTime.now().add(const Duration(hours: 1))),
        null,
        _scopes,
      ),
    );

    final driveApi = drive.DriveApi(client);

    try {
      final file = await driveApi.files.get(
        googleDriveFileId,
        $fields: 'webViewLink',
      ) as drive.File;

      return file.webViewLink;
    } catch (e) {
      return null;
    } finally {
      client.close();
    }
  }

  @override
  Future<List<Attachment>> getUnsyncedAttachments() async {
    // ✅ PHASE 4: With event sourcing, use event log to determine unsynced items
    // For now, return all non-deleted attachments since individual table sync is replaced by event sourcing
    final query = _database.select(_database.attachmentsTable)
      ..where((table) => table.isDeleted.equals(false))
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);

    final rows = await query.get();
    return rows.map(_mapRowToAttachment).toList();
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    // ✅ PHASE 4: No-op since sync fields removed from table
    // Event sourcing tracks sync status in sync_event_log table
    // This method kept for backward compatibility
  }

  @override
  Future<void> insertOrUpdateFromSync(Attachment attachment) async {
    final existingAttachment =
        await (_database.select(_database.attachmentsTable)
              ..where((table) => table.syncId.equals(attachment.syncId)))
            .getSingleOrNull();

    if (existingAttachment == null) {
      await createAttachment(attachment);
    } else {
      await updateAttachment(attachment.copyWith(id: existingAttachment.id));
    }
  }

  @override
  Future<Attachment> compressAndStoreFile(
      String filePath, int transactionId, String fileName,
      {bool isCapturedFromCamera = false}) async {
    debugPrint('🔄 [AttachmentRepository] compressAndStoreFile called');
    debugPrint('🔄 [AttachmentRepository] filePath: $filePath');
    debugPrint('🔄 [AttachmentRepository] transactionId: $transactionId');
    debugPrint('🔄 [AttachmentRepository] fileName: $fileName');
    debugPrint('🔄 [AttachmentRepository] isCapturedFromCamera: $isCapturedFromCamera');
    
    File file = File(filePath);
    debugPrint('🔄 [AttachmentRepository] Original file exists: ${await file.exists()}');

    // Compress if it's an image captured from camera
    if (isCapturedFromCamera && _isImageFile(fileName)) {
      debugPrint('🔄 [AttachmentRepository] Compressing image...');
      file = await _compressImage(file);
      debugPrint('🔄 [AttachmentRepository] Compressed file path: ${file.path}');
      debugPrint('🔄 [AttachmentRepository] Compressed file exists: ${await file.exists()}');
    }

    final fileStats = await file.stat();
    final mimeType = mime(fileName);
    final deviceId = await _getDeviceId();

    debugPrint('🔄 [AttachmentRepository] File stats - size: ${fileStats.size}, mimeType: $mimeType');

    final attachment = Attachment(
      transactionId: transactionId,
      fileName: fileName,
      filePath: file.path,
      type: _getAttachmentType(mimeType),
      mimeType: mimeType,
      fileSizeBytes: fileStats.size,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isUploaded: false,
      isDeleted: false,
      isCapturedFromCamera: isCapturedFromCamera,
      localCacheExpiry: isCapturedFromCamera
          ? DateTime.now().add(const Duration(days: 30))
          : null,
      syncId: _uuid.v4(),
    );

    debugPrint('🔄 [AttachmentRepository] Created attachment with syncId: ${attachment.syncId}');
    return attachment;
  }

  @override
  Future<bool> isFileExists(String filePath) async {
    return await File(filePath).exists();
  }

  @override
  Future<void> deleteLocalFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> cleanExpiredCache() async {
    final expiredAttachments = await getExpiredCacheAttachments();

    for (final attachment in expiredAttachments) {
      if (attachment.filePath != null) {
        await deleteLocalFile(attachment.filePath!);

        // Update attachment to remove local file path
        final updatedAttachment = attachment.copyWith(
          filePath: null,
          localCacheExpiry: null,
        );
        await updateAttachment(updatedAttachment);
      }
    }
  }

  @override
  Future<List<Attachment>> getExpiredCacheAttachments() async {
    final now = DateTime.now();
    final query = _database.select(_database.attachmentsTable)
      ..where((table) =>
          table.isCapturedFromCamera.equals(true) &
          table.localCacheExpiry.isNotNull() &
          table.localCacheExpiry.isSmallerThanValue(now) &
          table.filePath.isNotNull() &
          table.isDeleted.equals(false));

    final rows = await query.get();
    return rows.map(_mapRowToAttachment).toList();
  }

  @override
  Future<String?> getLocalFilePath(Attachment attachment) async {
    // Check if file exists locally and cache is still valid
    if (attachment.filePath != null &&
        await isFileExists(attachment.filePath!) &&
        attachment.isLocalCacheValid) {
      return attachment.filePath;
    }

    // If local file doesn't exist or cache expired, try to download from Google Drive
    if (attachment.googleDriveFileId != null && attachment.isUploaded) {
      await downloadFromGoogleDrive(attachment);

      // Return the new local path after download
      final updatedAttachment = await getAttachmentById(attachment.id!);
      return updatedAttachment?.filePath;
    }

    return null;
  }

  @override
  Future<void> downloadFromGoogleDrive(Attachment attachment) async {
    if (attachment.googleDriveFileId == null) {
      throw Exception('No Google Drive file ID available');
    }

    final account = _googleSignIn.currentUser;
    if (account == null) {
      throw Exception('Not signed in to Google');
    }

    final authHeaders = await account.authHeaders;
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', authHeaders['Authorization']?.split(' ')[1] ?? '',
            DateTime.now().add(const Duration(hours: 1))),
        null,
        _scopes,
      ),
    );

    final driveApi = drive.DriveApi(client);

    try {
      // Download file content
      final media = await driveApi.files.get(
        attachment.googleDriveFileId!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // Create local file path
      final tempDir = await getTemporaryDirectory();
      final localFilePath =
          p.join(tempDir.path, 'cache_${attachment.id}_${attachment.fileName}');
      final localFile = File(localFilePath);

      // Write downloaded content to local file
      final sink = localFile.openWrite();
      await media.stream.forEach(sink.add);
      await sink.close();

      // Update attachment with new local path
      // Only set cache expiry for camera-captured images
      DateTime? cacheExpiry;
      if (attachment.shouldCacheLocally) {
        cacheExpiry = DateTime.now().add(const Duration(days: 30));
      }

      final updatedAttachment = attachment.copyWith(
        filePath: localFilePath,
        localCacheExpiry: cacheExpiry,
      );

      await updateAttachment(updatedAttachment);
    } finally {
      client.close();
    }
  }

  // ✅ PHASE 1 HELPER METHODS

  Future<TransactionsTableData> _getTransactionForAttachment(
      Attachment attachment) async {
    final transaction = await (_database.select(_database.transactionsTable)
          ..where((t) => t.id.equals(attachment.transactionId)))
        .getSingle();
    return transaction;
  }

  Future<String> _ensureFolderExists(
      drive.DriveApi driveApi, String folderPath) async {
    final pathParts = folderPath.split('/');
    String currentParent = 'appDataFolder';

    for (final folderName in pathParts) {
      if (folderName.isEmpty) continue;

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

  Future<String> _calculateFileHash(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  Future<drive.File?> _findExistingFile(
      drive.DriveApi driveApi, String fileHash, String folderId) async {
    final existingFiles = await driveApi.files.list(
      q: "appProperties has { key='fileHash' and value='$fileHash' } and '$folderId' in parents and trashed=false",
    );

    return existingFiles.files?.isNotEmpty == true
        ? existingFiles.files!.first
        : null;
  }

  Future<String> _generateUniqueFileName(
      drive.DriveApi driveApi, String fileName, String folderId) async {
    String baseName = p.basenameWithoutExtension(fileName);
    String extension = p.extension(fileName);
    String candidateName = fileName;
    int counter = 1;

    while (true) {
      final existingFiles = await driveApi.files.list(
        q: "name='$candidateName' and '$folderId' in parents and trashed=false",
      );

      if (existingFiles.files?.isEmpty == true) {
        return candidateName;
      }

      candidateName = '${baseName}_$counter$extension';
      counter++;
    }
  }

  Future<void> _updateAttachmentWithDriveInfo(
      Attachment attachment, drive.File driveFile) async {
    final googleDriveLink = driveFile.id != null 
        ? 'https://drive.google.com/file/d/${driveFile.id}/view'
        : null;
    
    debugPrint('✅ [AttachmentRepository] Updating with existing Drive file: ${driveFile.id}');
    debugPrint('✅ [AttachmentRepository] Generated Google Drive link: $googleDriveLink');
    
    final updatedAttachment = attachment.copyWith(
      googleDriveFileId: driveFile.id,
      googleDriveLink: googleDriveLink,
      isUploaded: true,
      updatedAt: DateTime.now(),
    );
    await updateAttachment(updatedAttachment);
  }

  // EXISTING HELPER METHODS

  Future<File> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        p.join(tempDir.path, 'compressed_${p.basename(file.path)}');

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 85,
      minWidth: 1920,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    return compressedFile != null ? File(compressedFile.path) : file;
  }

  bool _isImageFile(String fileName) {
    final extension = p.extension(fileName).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension);
  }

  Future<String> _getDeviceId() async {
    // This should match the device ID logic from GoogleDriveSyncService
    // For now, return a simple UUID
    return _uuid.v4();
  }

  Attachment _mapRowToAttachment(AttachmentsTableData row) {
    return Attachment(
      id: row.id,
      transactionId: row.transactionId,
      fileName: row.fileName,
      filePath: row.filePath,
      googleDriveFileId: row.googleDriveFileId,
      googleDriveLink: row.googleDriveLink,
      type: AttachmentType.values[row.type],
      mimeType: row.mimeType,
      fileSizeBytes: row.fileSizeBytes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isUploaded: row.isUploaded,
      isDeleted: row.isDeleted,
      isCapturedFromCamera: row.isCapturedFromCamera,
      localCacheExpiry: row.localCacheExpiry,
      syncId: row.syncId,
    );
  }

  AttachmentType _getAttachmentType(String? mimeType) {
    if (mimeType == null) return AttachmentType.other;

    if (mimeType.startsWith('image/')) {
      return AttachmentType.image;
    } else if (mimeType.contains('pdf') ||
        mimeType.contains('document') ||
        mimeType.contains('text')) {
      return AttachmentType.document;
    }

    return AttachmentType.other;
  }
}
