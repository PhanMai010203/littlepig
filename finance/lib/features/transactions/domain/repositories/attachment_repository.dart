import '../entities/attachment.dart';

abstract class AttachmentRepository {
  // Basic CRUD operations
  Future<Attachment> createAttachment(Attachment attachment);
  Future<Attachment?> getAttachmentById(int id);
  Future<List<Attachment>> getAttachmentsByTransaction(int transactionId);
  Future<List<Attachment>> getAllAttachments();
  Future<Attachment> updateAttachment(Attachment attachment);
  Future<void> deleteAttachment(int id);
  Future<void> markAsDeleted(int id);

  // Google Drive specific operations
  Future<void> uploadToGoogleDrive(Attachment attachment);
  Future<void> deleteFromGoogleDrive(String googleDriveFileId);
  Future<String?> getGoogleDriveDownloadLink(String googleDriveFileId);

  // Sync operations
  Future<List<Attachment>> getUnsyncedAttachments();
  Future<void> markAsSynced(String syncId, DateTime syncTime);
  Future<void> insertOrUpdateFromSync(Attachment attachment);

  // File operations
  Future<Attachment> compressAndStoreFile(String filePath, int transactionId, String fileName, {bool isCapturedFromCamera = false});
  Future<bool> isFileExists(String filePath);
  Future<void> deleteLocalFile(String filePath);
  
  // Cache management operations
  Future<void> cleanExpiredCache();
  Future<List<Attachment>> getExpiredCacheAttachments();
  Future<String?> getLocalFilePath(Attachment attachment);
  Future<void> downloadFromGoogleDrive(Attachment attachment);
}