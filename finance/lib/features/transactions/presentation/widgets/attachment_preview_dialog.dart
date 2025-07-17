import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../domain/entities/attachment.dart';

class AttachmentPreviewDialog extends StatefulWidget {
  final Attachment attachment;

  const AttachmentPreviewDialog({
    super.key,
    required this.attachment,
  });

  @override
  State<AttachmentPreviewDialog> createState() => _AttachmentPreviewDialogState();
}

class _AttachmentPreviewDialogState extends State<AttachmentPreviewDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: AppText(
            widget.attachment.fileName,
            textColor: Colors.white,
            fontSize: 16,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              onPressed: _isLoading ? null : () => _downloadFile(),
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.download),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: _buildPreviewContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    debugPrint('📖 [AttachmentPreview] Building preview for: ${widget.attachment.fileName}');
    debugPrint('📖 [AttachmentPreview] isAvailable: ${widget.attachment.isAvailable}');
    debugPrint('📖 [AttachmentPreview] isImage: ${widget.attachment.isImage}');
    debugPrint('📖 [AttachmentPreview] filePath: ${widget.attachment.filePath}');
    debugPrint('📖 [AttachmentPreview] googleDriveLink: ${widget.attachment.googleDriveLink}');
    debugPrint('📖 [AttachmentPreview] googleDriveFileId: ${widget.attachment.googleDriveFileId}');
    debugPrint('📖 [AttachmentPreview] mimeType: ${widget.attachment.mimeType}');
    debugPrint('📖 [AttachmentPreview] fileSizeBytes: ${widget.attachment.fileSizeBytes}');
    
    if (!widget.attachment.isAvailable) {
      debugPrint('❌ [AttachmentPreview] Attachment not available, showing error state');
      return _buildErrorState();
    }

    if (widget.attachment.isImage) {
      debugPrint('🖼️ [AttachmentPreview] Building image preview');
      return _buildImagePreview();
    } else {
      debugPrint('📄 [AttachmentPreview] Building document preview');
      return _buildDocumentPreview();
    }
  }

  Widget _buildImagePreview() {
    debugPrint('🖼️ [AttachmentPreview] Building image preview');
    debugPrint('🖼️ [AttachmentPreview] googleDriveLink: ${widget.attachment.googleDriveLink}');
    
    return InteractiveViewer(
      minScale: 0.1,
      maxScale: 5.0,
      child: widget.attachment.googleDriveLink != null
          ? Image.network(
              widget.attachment.googleDriveLink!,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  debugPrint('✅ [AttachmentPreview] Image loaded successfully');
                  return child;
                }
                debugPrint('⏳ [AttachmentPreview] Loading image... Progress: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}');
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('❌ [AttachmentPreview] Image load error: $error');
                debugPrint('❌ [AttachmentPreview] StackTrace: $stackTrace');
                return _buildErrorState();
              },
            )
          : _buildErrorState(),
    );
  }

  Widget _buildDocumentPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.description,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        AppText(
          widget.attachment.fileName,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          textColor: Colors.white,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (widget.attachment.mimeType != null)
          AppText(
            widget.attachment.mimeType!,
            fontSize: 14,
            textColor: Colors.grey[400],
          ),
        const SizedBox(height: 16),
        if (widget.attachment.fileSizeBytes != null)
          AppText(
            _formatFileSize(widget.attachment.fileSizeBytes!),
            fontSize: 14,
            textColor: Colors.grey[400],
          ),
        const SizedBox(height: 32),
        TappableWidget(
          onTap: _downloadFile,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download, color: Colors.white),
                const SizedBox(width: 8),
                const AppText(
                  'Download',
                  textColor: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        AppText(
          'Preview not available',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          textColor: Colors.white,
        ),
        const SizedBox(height: 8),
        AppText(
          'File may be corrupted or not accessible',
          fontSize: 14,
          textColor: Colors.grey[400],
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TappableWidget(
          onTap: _downloadFile,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download, color: Colors.white),
                const SizedBox(width: 8),
                const AppText(
                  'Try Download',
                  textColor: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  Future<void> _downloadFile() async {
    if (widget.attachment.googleDriveLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download link not available')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Show feedback to user
      HapticFeedback.lightImpact();
      
      // For now, we'll just copy the link to clipboard
      // In a real app, you might want to use url_launcher to open the link
      await Clipboard.setData(ClipboardData(text: widget.attachment.googleDriveLink!));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download link copied to clipboard')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}