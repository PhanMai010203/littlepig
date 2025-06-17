import 'dart:io';
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

import '../../domain/entities/attachment.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../../../core/database/app_database.dart';

class AttachmentRepositoryImpl implements AttachmentRepository {
  final AppDatabase _database;
  final GoogleSignIn _googleSignIn;
  final Uuid _uuid = const Uuid();

  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/drive.file',
  ];

  AttachmentRepositoryImpl(this._database, this._googleSignIn);
  @override
  Future<Attachment> createAttachment(Attachment attachment) async {
    final companion = AttachmentsTableCompanion.insert(
      transactionId: attachment.transactionId,
      fileName: attachment.fileName,
      filePath: Value(attachment.filePath),
      googleDriveFileId: Value(attachment.googleDriveFileId),
      googleDriveLink: Value(attachment.googleDriveLink),
      type: attachment.type.index,
      mimeType: Value(attachment.mimeType),
      fileSizeBytes: Value(attachment.fileSizeBytes),
      isUploaded: Value(attachment.isUploaded),
      isDeleted: Value(attachment.isDeleted),
      isCapturedFromCamera: Value(attachment.isCapturedFromCamera),
      localCacheExpiry: Value(attachment.localCacheExpiry),
      deviceId: attachment.deviceId,
      isSynced: Value(attachment.isSynced),
      lastSyncAt: Value(attachment.lastSyncAt),
      syncId: attachment.syncId,
      version: Value(attachment.version),
    );

    final id = await _database.into(_database.attachmentsTable).insert(companion);
    return attachment.copyWith(id: id);
  }

  @override
  Future<Attachment?> getAttachmentById(int id) async {
    final query = _database.select(_database.attachmentsTable)
      ..where((table) => table.id.equals(id));
    
    final row = await query.getSingleOrNull();
    return row != null ? _mapRowToAttachment(row) : null;
  }

  @override
  Future<List<Attachment>> getAttachmentsByTransaction(int transactionId) async {
    final query = _database.select(_database.attachmentsTable)
      ..where((table) => table.transactionId.equals(transactionId) & table.isDeleted.equals(false))
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    
    final rows = await query.get();
    return rows.map(_mapRowToAttachment).toList();
  }

  @override
  Future<List<Attachment>> getAllAttachments() async {
    final query = _database.select(_database.attachmentsTable)
      ..where((table) => table.isDeleted.equals(false))
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    
    final rows = await query.get();
    return rows.map(_mapRowToAttachment).toList();
  }
  @override
  Future<Attachment> updateAttachment(Attachment attachment) async {
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
      updatedAt: Value(DateTime.now()),
      isUploaded: Value(attachment.isUploaded),
      isDeleted: Value(attachment.isDeleted),
      isCapturedFromCamera: Value(attachment.isCapturedFromCamera),
      localCacheExpiry: Value(attachment.localCacheExpiry),
      deviceId: Value(attachment.deviceId),
      isSynced: Value(attachment.isSynced),
      lastSyncAt: Value(attachment.lastSyncAt),
      syncId: Value(attachment.syncId),
      version: Value(attachment.version + 1),
    );

    await _database.update(_database.attachmentsTable).replace(companion);
    return attachment.copyWith(
      updatedAt: DateTime.now(),
      version: attachment.version + 1,
    );
  }
  @override
  Future<void> deleteAttachment(int id) async {
    await (_database.delete(_database.attachmentsTable)
      ..where((table) => table.id.equals(id))).go();
  }

  @override
  Future<void> markAsDeleted(int id) async {
    final update = _database.update(_database.attachmentsTable)
      ..where((table) => table.id.equals(id));
    
    await update.write(AttachmentsTableCompanion(
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> uploadToGoogleDrive(Attachment attachment) async {
    if (attachment.filePath == null) {
      throw Exception('File path is null');
    }

    final account = _googleSignIn.currentUser;
    if (account == null) {
      throw Exception('Not signed in to Google');
    }

    final file = File(attachment.filePath!);
    if (!await file.exists()) {
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
    
    final driveFile = drive.File()
      ..name = attachment.fileName
      ..parents = ['appDataFolder'];

    final media = drive.Media(file.openRead(), file.lengthSync());
    
    final uploadedFile = await driveApi.files.create(
      driveFile,
      uploadMedia: media,
    );

    client.close();

    // Update attachment with Google Drive info
    final updatedAttachment = attachment.copyWith(
      googleDriveFileId: uploadedFile.id,
      isUploaded: true,
      updatedAt: DateTime.now(),
    );

    await updateAttachment(updatedAttachment);
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
    
    // Move file to trash instead of permanent deletion
    await driveApi.files.update(
      drive.File()..trashed = true,
      googleDriveFileId,
    );

    client.close();
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
      
      client.close();
      return file.webViewLink;
    } catch (e) {
      client.close();
      return null;
    }
  }

  @override
  Future<List<Attachment>> getUnsyncedAttachments() async {
    final query = _database.select(_database.attachmentsTable)
      ..where((table) => table.isSynced.equals(false) & table.isDeleted.equals(false))
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    
    final rows = await query.get();
    return rows.map(_mapRowToAttachment).toList();
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    final update = _database.update(_database.attachmentsTable)
      ..where((table) => table.syncId.equals(syncId));
    
    await update.write(AttachmentsTableCompanion(
      isSynced: const Value(true),
      lastSyncAt: Value(syncTime),
    ));
  }

  @override
  Future<void> insertOrUpdateFromSync(Attachment attachment) async {
    final query = _database.select(_database.attachmentsTable)
      ..where((table) => table.syncId.equals(attachment.syncId));
    
    final existing = await query.getSingleOrNull();

    if (existing != null) {
      // Update existing if version is newer
      if (attachment.version > existing.version) {
        await updateAttachment(attachment.copyWith(id: existing.id));
      }
    } else {
      // Insert new
      await createAttachment(attachment);
    }
  }
  @override
  Future<Attachment> compressAndStoreFile(String filePath, int transactionId, String fileName, {bool isCapturedFromCamera = false}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist');
    }

    final mimeType = mime(filePath);
    final isImage = mimeType?.startsWith('image/') == true;
    
    File processedFile = file;
    
    if (isImage) {
      // Compress image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        '${filePath}_compressed.jpg',
        quality: 70,
        minWidth: 1920,
        minHeight: 1080,
      );
      
      if (compressedFile != null) {
        processedFile = File(compressedFile.path);
      }
    }

    final fileStats = await processedFile.stat();
    final syncId = _uuid.v4();
    
    // Set cache expiry for camera-captured images (30 days)
    DateTime? cacheExpiry;
    if (isCapturedFromCamera && isImage) {
      cacheExpiry = DateTime.now().add(const Duration(days: 30));
    }
    
    return Attachment(
      transactionId: transactionId,
      fileName: fileName,
      filePath: processedFile.path,
      type: _getAttachmentType(mimeType),
      mimeType: mimeType,
      fileSizeBytes: fileStats.size,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isUploaded: false,
      isDeleted: false,
      isCapturedFromCamera: isCapturedFromCamera,
      localCacheExpiry: cacheExpiry,
      deviceId: 'current-device-id', // TODO: Get actual device ID
      isSynced: false,
      syncId: syncId,
      version: 1,
    );
  }

  @override
  Future<bool> isFileExists(String filePath) async {
    return File(filePath).exists();
  }

  @override
  Future<void> deleteLocalFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Cache management operations
  @override
  Future<void> cleanExpiredCache() async {
    final expiredAttachments = await getExpiredCacheAttachments();
    
    for (final attachment in expiredAttachments) {
      if (attachment.filePath != null && await isFileExists(attachment.filePath!)) {
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
        table.isDeleted.equals(false)
      );
    
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
      final localFilePath = p.join(tempDir.path, 'cache_${attachment.id}_${attachment.fileName}');
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
      deviceId: row.deviceId,
      isSynced: row.isSynced,
      lastSyncAt: row.lastSyncAt,
      syncId: row.syncId,
      version: row.version,
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