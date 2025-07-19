import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../../../../shared/widgets/app_text.dart';
import '../../domain/entities/attachment.dart';

class AttachmentThumbnail extends StatelessWidget {
  final Attachment attachment;
  final double size;

  const AttachmentThumbnail({
    super.key,
    required this.attachment,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (attachment.isImage) {
      return _buildImageThumbnail();
    } else {
      return _buildDocumentThumbnail();
    }
  }

  Widget _buildImageThumbnail() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: _buildImageWidget(),
      ),
    );
  }

  Widget _buildImageWidget() {
    debugPrint('🖼️ [AttachmentThumbnail] Building image widget for: ${attachment.fileName}');
    debugPrint('🖼️ [AttachmentThumbnail] filePath: ${attachment.filePath}');
    debugPrint('🖼️ [AttachmentThumbnail] googleDriveLink: ${attachment.googleDriveLink}');
    debugPrint('🖼️ [AttachmentThumbnail] googleDriveFileId: ${attachment.googleDriveFileId}');
    
    // Try to load from local file first
    if (attachment.filePath != null) {
      final file = File(attachment.filePath!);
      debugPrint('🖼️ [AttachmentThumbnail] Checking local file exists: ${file.existsSync()}');
      if (file.existsSync()) {
        debugPrint('🖼️ [AttachmentThumbnail] Loading from local file: ${attachment.filePath}');
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ [AttachmentThumbnail] Local file load error: $error');
            return _buildImageFromDrive();
          },
        );
      } else {
        debugPrint('⚠️ [AttachmentThumbnail] Local file does not exist, falling back to Drive');
      }
    } else {
      debugPrint('⚠️ [AttachmentThumbnail] No local file path, falling back to Drive');
    }

    // Fallback to Google Drive image
    return _buildImageFromDrive();
  }

  Widget _buildImageFromDrive() {
    debugPrint('☁️ [AttachmentThumbnail] Building image from Drive');
    if (attachment.googleDriveLink != null) {
      debugPrint('☁️ [AttachmentThumbnail] Loading from Google Drive: ${attachment.googleDriveLink}');
      return Image.network(
        attachment.googleDriveLink!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ [AttachmentThumbnail] Google Drive load error: $error');
          return _buildImagePlaceholder();
        },
      );
    }

    debugPrint('⚠️ [AttachmentThumbnail] No Google Drive link, showing placeholder');
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildDocumentThumbnail() {
    final extension = path.extension(attachment.fileName).toLowerCase();
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getDocumentColor(extension),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getDocumentIcon(extension),
              size: size * 0.5,
              color: Colors.white,
            ),
            if (size > 40) ...[
              const SizedBox(height: 2),
              AppText(
                extension.replaceAll('.', '').toUpperCase(),
                fontSize: 8,
                fontWeight: FontWeight.bold,
                textColor: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDocumentColor(String extension) {
    switch (extension) {
      case '.pdf':
        return Colors.red;
      case '.doc':
      case '.docx':
        return Colors.blue;
      case '.xls':
      case '.xlsx':
        return Colors.green;
      case '.ppt':
      case '.pptx':
        return Colors.orange;
      case '.txt':
        return Colors.grey;
      case '.zip':
      case '.rar':
        return Colors.purple;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getDocumentIcon(String extension) {
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow;
      case '.txt':
        return Icons.article;
      case '.zip':
      case '.rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }
}