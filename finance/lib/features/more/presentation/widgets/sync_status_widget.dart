import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/sync/sync_service.dart';

class SyncStatusWidget extends StatelessWidget {
  final SyncStatus status;
  final DateTime? lastSyncTime;
  final String? userEmail;
  final bool isSignedIn;
  final VoidCallback? onTap;

  const SyncStatusWidget({
    super.key,
    required this.status,
    this.lastSyncTime,
    this.userEmail,
    required this.isSignedIn,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusTitle(context),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusSubtitle(context),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null) const Icon(Icons.chevron_right),
                ],
              ),
              if (status == SyncStatus.uploading ||
                  status == SyncStatus.downloading ||
                  status == SyncStatus.merging)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
              if (lastSyncTime != null && isSignedIn)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'sync.last_sync'.tr(args: [_formatLastSync(context)]),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case SyncStatus.idle:
        color = isSignedIn 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.onSurfaceVariant;
        icon = isSignedIn ? Icons.cloud_done : Icons.cloud_off;
        break;
      case SyncStatus.uploading:
        color = Theme.of(context).colorScheme.primary;
        icon = Icons.cloud_upload;
        break;
      case SyncStatus.downloading:
        color = Theme.of(context).colorScheme.primary;
        icon = Icons.cloud_download;
        break;
      case SyncStatus.merging:
        color = Theme.of(context).colorScheme.primary;
        icon = Icons.merge_type;
        break;
      case SyncStatus.completed:
        color = Theme.of(context).colorScheme.primary;
        icon = Icons.cloud_done;
        break;
      case SyncStatus.error:
        color = Theme.of(context).colorScheme.error;
        icon = Icons.cloud_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  String _getStatusTitle(BuildContext context) {
    if (!isSignedIn) {
      return 'sync.not_signed_in'.tr();
    }

    switch (status) {
      case SyncStatus.idle:
        return 'sync.ready'.tr();
      case SyncStatus.uploading:
        return 'sync.uploading'.tr();
      case SyncStatus.downloading:
        return 'sync.downloading'.tr();
      case SyncStatus.merging:
        return 'sync.merging'.tr();
      case SyncStatus.completed:
        return 'sync.completed'.tr();
      case SyncStatus.error:
        return 'sync.error'.tr();
    }
  }

  String _getStatusSubtitle(BuildContext context) {
    if (!isSignedIn) {
      return 'sync.sign_in_required'.tr();
    }

    switch (status) {
      case SyncStatus.idle:
        return userEmail ?? 'sync.connected_to_drive'.tr();
      case SyncStatus.uploading:
        return 'sync.uploading_changes'.tr();
      case SyncStatus.downloading:
        return 'sync.downloading_changes'.tr();
      case SyncStatus.merging:
        return 'sync.merging_changes'.tr();
      case SyncStatus.completed:
        return 'sync.sync_successful'.tr();
      case SyncStatus.error:
        return 'sync.sync_failed'.tr();
    }
  }

  String _formatLastSync(BuildContext context) {
    if (lastSyncTime == null) return 'sync.never'.tr();

    final now = DateTime.now();
    final difference = now.difference(lastSyncTime!);

    if (difference.inMinutes < 1) {
      return 'sync.just_now'.tr();
    } else if (difference.inMinutes < 60) {
      return 'sync.minutes_ago'.tr(args: [difference.inMinutes.toString()]);
    } else if (difference.inHours < 24) {
      return 'sync.hours_ago'.tr(args: [difference.inHours.toString()]);
    } else if (difference.inDays < 7) {
      return 'sync.days_ago'.tr(args: [difference.inDays.toString()]);
    } else {
      return DateFormat.yMMMd().format(lastSyncTime!);
    }
  }
}