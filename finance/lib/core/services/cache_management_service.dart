import 'dart:async';

import '../../features/transactions/domain/repositories/attachment_repository.dart';

/// Service responsible for managing local file cache
///
/// This service handles:
/// - Cleaning expired cache files (camera-captured images after 30 days)
/// - Managing storage space
/// - Background cache maintenance
class CacheManagementService {
  final AttachmentRepository _attachmentRepository;
  Timer? _cleanupTimer;

  CacheManagementService(this._attachmentRepository);

  /// Start periodic cache cleanup (runs every 24 hours)
  void startPeriodicCleanup() {
    // Run cleanup every 24 hours
    _cleanupTimer = Timer.periodic(const Duration(hours: 24), (_) async {
      await cleanExpiredCache();
    });
  }

  /// Stop periodic cache cleanup
  void stopPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Clean expired cache files
  ///
  /// This removes:
  /// - Camera-captured images older than 30 days
  /// - Local files that are no longer accessible
  Future<void> cleanExpiredCache() async {
    try {
      await _attachmentRepository.cleanExpiredCache();
    } catch (e) {
      // Log error but don't throw - cache cleanup should be non-critical
      print('Cache cleanup failed: $e');
    }
  }

  /// Get cache statistics
  Future<CacheStats> getCacheStats() async {
    final expiredAttachments =
        await _attachmentRepository.getExpiredCacheAttachments();
    final allAttachments = await _attachmentRepository.getAllAttachments();

    int cachedFiles = 0;
    int totalCacheSize = 0;
    int expiredFiles = expiredAttachments.length;
    int expiredSize = 0;

    for (final attachment in allAttachments) {
      if (attachment.filePath != null &&
          await _attachmentRepository.isFileExists(attachment.filePath!)) {
        cachedFiles++;
        if (attachment.fileSizeBytes != null) {
          totalCacheSize += attachment.fileSizeBytes!;
        }
      }
    }

    for (final attachment in expiredAttachments) {
      if (attachment.fileSizeBytes != null) {
        expiredSize += attachment.fileSizeBytes!;
      }
    }

    return CacheStats(
      cachedFiles: cachedFiles,
      totalCacheSize: totalCacheSize,
      expiredFiles: expiredFiles,
      expiredSize: expiredSize,
    );
  }

  /// Force cleanup of all cache files (for troubleshooting or storage management)
  Future<void> clearAllCache() async {
    final allAttachments = await _attachmentRepository.getAllAttachments();

    for (final attachment in allAttachments) {
      if (attachment.filePath != null &&
          await _attachmentRepository.isFileExists(attachment.filePath!)) {
        await _attachmentRepository.deleteLocalFile(attachment.filePath!);

        // Update attachment to remove local file path
        final updatedAttachment = attachment.copyWith(
          filePath: null,
          localCacheExpiry: null,
        );
        await _attachmentRepository.updateAttachment(updatedAttachment);
      }
    }
  }

  /// Clean cache for a specific attachment
  Future<void> clearAttachmentCache(int attachmentId) async {
    final attachment =
        await _attachmentRepository.getAttachmentById(attachmentId);
    if (attachment == null) return;

    if (attachment.filePath != null &&
        await _attachmentRepository.isFileExists(attachment.filePath!)) {
      await _attachmentRepository.deleteLocalFile(attachment.filePath!);

      // Update attachment to remove local file path
      final updatedAttachment = attachment.copyWith(
        filePath: null,
        localCacheExpiry: null,
      );
      await _attachmentRepository.updateAttachment(updatedAttachment);
    }
  }
}

class CacheStats {
  final int cachedFiles;
  final int totalCacheSize;
  final int expiredFiles;
  final int expiredSize;

  CacheStats({
    required this.cachedFiles,
    required this.totalCacheSize,
    required this.expiredFiles,
    required this.expiredSize,
  });

  String get formattedTotalSize => _formatBytes(totalCacheSize);
  String get formattedExpiredSize => _formatBytes(expiredSize);

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}
