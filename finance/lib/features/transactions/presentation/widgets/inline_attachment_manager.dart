import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/attachment.dart';
import '../bloc/transaction_detail_bloc.dart';
import '../bloc/transaction_detail_event.dart';
import 'attachment_preview_dialog.dart';
import 'attachment_thumbnail.dart';

class InlineAttachmentManager extends StatelessWidget {
  final int transactionId;
  final List<Attachment> attachments;
  final bool isLoading;
  final bool isGoogleDriveAuthenticated;
  final bool isAuthenticating;

  const InlineAttachmentManager({
    super.key,
    required this.transactionId,
    required this.attachments,
    this.isLoading = false,
    this.isGoogleDriveAuthenticated = false,
    this.isAuthenticating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Attachments',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          if (attachments.isNotEmpty) ...[
            ...attachments.map((attachment) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: getColor(context, "border")),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: AppText(attachment.fileName),
                subtitle: attachment.isCapturedFromCamera
                    ? AppText(
                        'Captured from camera',
                        fontSize: 12,
                        textColor: getColor(context, "textSecondary"),
                      )
                    : null,
                leading: AttachmentThumbnail(attachment: attachment),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: getColor(context, "error")),
                  onPressed: () => _showDeleteConfirmation(context, attachment),
                ),
                onTap: () => _showAttachmentPreview(context, attachment),
              ),
            )),
          ],
          _buildAttachmentButtons(context),
        ],
      ),
    );
  }

  Widget _buildAttachmentButtons(BuildContext context) {
    // Show authentication message if not authenticated
    if (!isGoogleDriveAuthenticated) {
      return Column(
        children: [
          if (isAuthenticating) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                AppText(
                  'Connecting to Google Drive...',
                  fontSize: 14,
                  textColor: Colors.grey[600],
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Google Drive Required',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          textColor: Colors.blue,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          'Connect to Google Drive to add attachments',
                          fontSize: 12,
                          textColor: Colors.blue[700],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _authenticateGoogleDrive(context),
                icon: const Icon(Icons.cloud),
                label: const AppText('Connect Google Drive'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Show attachment buttons if authenticated
    return Column(
      children: [
        if (isLoading) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              AppText(
                'Adding attachment...',
                fontSize: 14,
                textColor: Colors.grey[600],
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImageFromCamera(context),
                icon: const Icon(Icons.camera_alt),
                label: const AppText('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: getColor(context, "primary"),
                  foregroundColor: getColor(context, "white"),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImageFromGallery(context),
                icon: const Icon(Icons.photo_library),
                label: const AppText('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: getColor(context, "secondary"),
                  foregroundColor: getColor(context, "white"),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickFiles(context),
                icon: const Icon(Icons.attach_file),
                label: const AppText('Files'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: getColor(context, "tertiary"),
                  foregroundColor: getColor(context, "white"),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _authenticateGoogleDrive(BuildContext context) {
    context.read<TransactionDetailBloc>().add(const AuthenticateGoogleDrive());
  }

  void _pickImageFromCamera(BuildContext context) {
    context.read<TransactionDetailBloc>().add(AddAttachmentFromCamera(transactionId));
  }

  void _pickImageFromGallery(BuildContext context) {
    context.read<TransactionDetailBloc>().add(AddAttachmentFromGallery(transactionId));
  }

  void _pickFiles(BuildContext context) {
    context.read<TransactionDetailBloc>().add(AddAttachmentFromFiles(transactionId));
  }

  void _showAttachmentPreview(BuildContext context, Attachment attachment) {
    showDialog(
      context: context,
      builder: (context) => AttachmentPreviewDialog(attachment: attachment),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Attachment attachment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('Delete Attachment'),
        content: AppText('Are you sure you want to delete "${attachment.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (attachment.id != null) {
                context.read<TransactionDetailBloc>().add(DeleteAttachment(attachment.id!));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const AppText('Delete'),
          ),
        ],
      ),
    );
  }
}