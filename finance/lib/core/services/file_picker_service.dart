import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/transactions/domain/entities/attachment.dart';
import '../../features/transactions/domain/repositories/attachment_repository.dart';

enum AttachmentSourceType { camera, gallery, file }

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();
  final AttachmentRepository _attachmentRepository;
  final GoogleSignIn _googleSignIn;

  FilePickerService(this._attachmentRepository, this._googleSignIn);

  /// Main entry point for adding attachments according to the specified flow
  Future<List<Attachment>> addAttachments(int transactionId) async {
    // Check if user is signed in to Google Drive
    if (!await _googleSignIn.isSignedIn()) {
      // Authorize Google Drive access
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google Drive authorization required to add attachments');
      }
    }

    // Show attachment options and let user choose
    final attachmentSource = await _showAttachmentOptions();
    if (attachmentSource == null) return [];

    List<File> selectedFiles = [];

    try {
      switch (attachmentSource) {
        case AttachmentSourceType.camera:
          final file = await _takePhoto();
          if (file != null) selectedFiles.add(file);
          break;

        case AttachmentSourceType.gallery:
          final files = await _selectFromGallery();
          selectedFiles.addAll(files);
          break;

        case AttachmentSourceType.file:
          final files = await _selectFiles();
          selectedFiles.addAll(files);
          break;
      }

      if (selectedFiles.isEmpty) return [];

      // Process each file according to the flow
      final attachments = <Attachment>[];
      for (final file in selectedFiles) {
        final attachment = await _processFile(file, transactionId);
        attachments.add(attachment);
      }

      return attachments;
    } catch (e) {
      throw Exception('Failed to add attachments: $e');
    }
  }

  /// Take photo using built-in camera
  Future<File?> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      return image != null ? File(image.path) : null;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  /// Select photos from gallery (multiple selection)
  Future<List<File>> _selectFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      throw Exception('Failed to select from gallery: $e');
    }
  }

  /// Select files using file picker
  Future<List<File>> _selectFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: false, // We only need file paths
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to select files: $e');
    }
  }

  /// Process file according to the flow: compress if image, upload to Google Drive
  Future<Attachment> _processFile(File file, int transactionId) async {
    try {
      // Step 1: Compress and store file (handles image compression)
      final attachment = await _attachmentRepository.compressAndStoreFile(
        file.path,
        transactionId,
        _getFileName(file.path),
      );

      // Step 2: Create attachment record in database
      final createdAttachment = await _attachmentRepository.createAttachment(attachment);

      // Step 3: Upload to Google Drive
      await _attachmentRepository.uploadToGoogleDrive(createdAttachment);

      // Step 4: Generate Google Drive link and update attachment
      final updatedAttachment = await _attachmentRepository.getAttachmentById(createdAttachment.id!);
      if (updatedAttachment?.googleDriveFileId != null) {
        final googleDriveLink = await _attachmentRepository.getGoogleDriveDownloadLink(
          updatedAttachment!.googleDriveFileId!,
        );
        
        if (googleDriveLink != null) {
          final finalAttachment = updatedAttachment.copyWith(
            googleDriveLink: googleDriveLink,
          );
          await _attachmentRepository.updateAttachment(finalAttachment);
          return finalAttachment;
        }
      }

      return updatedAttachment ?? createdAttachment;
    } catch (e) {
      throw Exception('Failed to process file ${file.path}: $e');
    }
  }

  /// Delete attachment and move file to Google Drive trash
  Future<void> deleteAttachment(int attachmentId) async {
    final attachment = await _attachmentRepository.getAttachmentById(attachmentId);
    if (attachment == null) return;

    try {
      // Mark attachment as deleted in database
      await _attachmentRepository.markAsDeleted(attachmentId);

      // Move file to Google Drive trash if it exists
      if (attachment.googleDriveFileId != null) {
        await _attachmentRepository.deleteFromGoogleDrive(attachment.googleDriveFileId!);
      }

      // Delete local file if it exists
      if (attachment.filePath != null) {
        await _attachmentRepository.deleteLocalFile(attachment.filePath!);
      }
    } catch (e) {
      throw Exception('Failed to delete attachment: $e');
    }
  }

  /// Check if user can add attachments (Google Drive authorization)
  Future<bool> canAddAttachments() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Request Google Drive authorization
  Future<bool> requestGoogleDriveAuthorization() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null;
    } catch (e) {
      return false;
    }
  }

  /// Mock method to show attachment options (in real implementation, this would show a dialog)
  /// Returns the selected attachment source type
  Future<AttachmentSourceType?> _showAttachmentOptions() async {
    // In a real implementation, this would show a bottom sheet or dialog
    // with options: "Take Photo", "Select Photo", "Select File"
    // For now, we'll return camera as default
    // This should be implemented in the presentation layer
    return AttachmentSourceType.camera;
  }

  /// Extract filename from file path
  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  /// Get file extension
  String _getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Check if file is an image
  bool _isImageFile(String filePath) {
    final extension = _getFileExtension(filePath);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// Check if file is a document
  bool _isDocumentFile(String filePath) {
    final extension = _getFileExtension(filePath);
    return ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'].contains(extension);
  }
} 