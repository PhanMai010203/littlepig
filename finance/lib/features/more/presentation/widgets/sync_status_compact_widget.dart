import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/di/injection.dart';

/// A compact sync status widget that can be displayed on the More page
class SyncStatusCompactWidget extends StatelessWidget {
  const SyncStatusCompactWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: getIt<SyncService>().syncStatusStream,
      builder: (context, statusSnapshot) {
        return FutureBuilder<bool>(
          future: getIt<SyncService>().isSignedIn(),
          builder: (context, signedInSnapshot) {
            final isSignedIn = signedInSnapshot.data ?? false;
            final status = statusSnapshot.data ?? SyncStatus.idle;
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusIcon(context, status, isSignedIn),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(context, status, isSignedIn),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(context, status, isSignedIn),
                      ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusIcon(BuildContext context, SyncStatus status, bool isSignedIn) {
    IconData icon;
    Color color;

    if (!isSignedIn) {
      icon = Icons.cloud_off;
      color = Theme.of(context).colorScheme.onSurfaceVariant;
    } else {
      switch (status) {
        case SyncStatus.idle:
        case SyncStatus.completed:
          icon = Icons.cloud_done;
          color = Theme.of(context).colorScheme.primary;
          break;
        case SyncStatus.uploading:
        case SyncStatus.downloading:
        case SyncStatus.merging:
          icon = Icons.sync;
          color = Theme.of(context).colorScheme.primary;
          break;
        case SyncStatus.error:
          icon = Icons.cloud_off;
          color = Theme.of(context).colorScheme.error;
          break;
      }
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }

  String _getStatusText(BuildContext context, SyncStatus status, bool isSignedIn) {
    if (!isSignedIn) {
      return 'sync.not_signed_in'.tr();
    }

    switch (status) {
      case SyncStatus.idle:
      case SyncStatus.completed:
        return 'sync.ready'.tr();
      case SyncStatus.uploading:
      case SyncStatus.downloading:
      case SyncStatus.merging:
        return 'sync.syncing'.tr();
      case SyncStatus.error:
        return 'sync.error'.tr();
    }
  }

  Color _getStatusColor(BuildContext context, SyncStatus status, bool isSignedIn) {
    if (!isSignedIn) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }

    switch (status) {
      case SyncStatus.idle:
      case SyncStatus.completed:
      case SyncStatus.uploading:
      case SyncStatus.downloading:
      case SyncStatus.merging:
        return Theme.of(context).colorScheme.primary;
      case SyncStatus.error:
        return Theme.of(context).colorScheme.error;
    }
  }
}