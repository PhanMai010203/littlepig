import 'package:equatable/equatable.dart';

enum AttachmentType { image, document, other }

class Attachment extends Equatable {
  final int? id;
  final int transactionId;
  final String fileName;
  final String? filePath; // Local file path
  final String? googleDriveFileId; // Google Drive file ID
  final String? googleDriveLink; // Google Drive shareable link
  final AttachmentType type;
  final String? mimeType;
  final int? fileSizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isUploaded;
  final bool isDeleted;
  final bool isCapturedFromCamera; // For cache management
  final DateTime? localCacheExpiry; // When local cache expires (30 days for camera images)
  final String deviceId;
  final bool isSynced;
  final DateTime? lastSyncAt;
  final String syncId;
  final int version;

  const Attachment({
    this.id,
    required this.transactionId,
    required this.fileName,
    this.filePath,
    this.googleDriveFileId,
    this.googleDriveLink,
    required this.type,
    this.mimeType,
    this.fileSizeBytes,
    required this.createdAt,
    required this.updatedAt,
    required this.isUploaded,
    required this.isDeleted,
    required this.isCapturedFromCamera,
    this.localCacheExpiry,
    required this.deviceId,
    required this.isSynced,
    this.lastSyncAt,
    required this.syncId,
    required this.version,
  });
  Attachment copyWith({
    int? id,
    int? transactionId,
    String? fileName,
    String? filePath,
    String? googleDriveFileId,
    String? googleDriveLink,
    AttachmentType? type,
    String? mimeType,
    int? fileSizeBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isUploaded,
    bool? isDeleted,
    bool? isCapturedFromCamera,
    DateTime? localCacheExpiry,
    String? deviceId,
    bool? isSynced,
    DateTime? lastSyncAt,
    String? syncId,
    int? version,
  }) {
    return Attachment(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      googleDriveFileId: googleDriveFileId ?? this.googleDriveFileId,
      googleDriveLink: googleDriveLink ?? this.googleDriveLink,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isUploaded: isUploaded ?? this.isUploaded,
      isDeleted: isDeleted ?? this.isDeleted,
      isCapturedFromCamera: isCapturedFromCamera ?? this.isCapturedFromCamera,
      localCacheExpiry: localCacheExpiry ?? this.localCacheExpiry,
      deviceId: deviceId ?? this.deviceId,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncId: syncId ?? this.syncId,
      version: version ?? this.version,
    );
  }

  bool get isImage => type == AttachmentType.image;
  bool get isDocument => type == AttachmentType.document;
  bool get isAvailable => !isDeleted && isUploaded && googleDriveLink != null;
  
  // Check if local file should be cached (only camera-captured images for 30 days)
  bool get shouldCacheLocally => isCapturedFromCamera && isImage;
  
  // Check if local cache is still valid
  bool get isLocalCacheValid => localCacheExpiry != null && DateTime.now().isBefore(localCacheExpiry!);

  @override
  List<Object?> get props => [
        id,
        transactionId,
        fileName,
        filePath,
        googleDriveFileId,
        googleDriveLink,
        type,
        mimeType,
        fileSizeBytes,
        createdAt,        updatedAt,
        isUploaded,
        isDeleted,
        isCapturedFromCamera,
        localCacheExpiry,
        deviceId,
        isSynced,
        lastSyncAt,
        syncId,
        version,
      ];
}