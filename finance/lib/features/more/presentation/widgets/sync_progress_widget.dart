import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/sync/sync_service.dart';

class SyncProgressWidget extends StatelessWidget {
  final SyncStatus status;
  final double? progress;
  final int uploadedCount;
  final int downloadedCount;
  final String? currentOperation;

  const SyncProgressWidget({
    super.key,
    required this.status,
    this.progress,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.currentOperation,
  });

  @override
  Widget build(BuildContext context) {
    if (status == SyncStatus.idle || status == SyncStatus.completed) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: progress,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getProgressTitle(context),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (progress != null)
                  Text(
                    '${(progress! * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            if (currentOperation != null) ...[
              const SizedBox(height: 8),
              Text(
                currentOperation!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            if (uploadedCount > 0 || downloadedCount > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (uploadedCount > 0) ...[
                    Icon(
                      Icons.upload,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'sync.uploaded_count'.tr(args: [uploadedCount.toString()]),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (uploadedCount > 0 && downloadedCount > 0) ...[
                    const SizedBox(width: 16),
                    Container(
                      width: 1,
                      height: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (downloadedCount > 0) ...[
                    Icon(
                      Icons.download,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'sync.downloaded_count'.tr(args: [downloadedCount.toString()]),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getProgressTitle(BuildContext context) {
    switch (status) {
      case SyncStatus.uploading:
        return 'sync.uploading_progress'.tr();
      case SyncStatus.downloading:
        return 'sync.downloading_progress'.tr();
      case SyncStatus.merging:
        return 'sync.merging_progress'.tr();
      case SyncStatus.error:
        return 'sync.sync_failed'.tr();
      default:
        return 'sync.syncing'.tr();
    }
  }
}