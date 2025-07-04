import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/sync/sync_service.dart';

class SyncConflictWidget extends StatelessWidget {
  final List<SyncConflict> conflicts;
  final VoidCallback? onResolveAll;
  final void Function(SyncConflict)? onResolveConflict;

  const SyncConflictWidget({
    super.key,
    required this.conflicts,
    this.onResolveAll,
    this.onResolveConflict,
  });

  @override
  Widget build(BuildContext context) {
    if (conflicts.isEmpty) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'sync.conflicts_detected'.tr(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'sync.conflicts_count'.tr(args: [conflicts.length.toString()]),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...conflicts.take(3).map((conflict) => _buildConflictItem(context, conflict)),
            if (conflicts.length > 3) ...[
              const SizedBox(height: 8),
              Text(
                'sync.more_conflicts'.tr(args: [(conflicts.length - 3).toString()]),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showConflictDetails(context),
                    child: Text('sync.view_details'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onResolveAll,
                    child: Text('sync.resolve_all'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictItem(BuildContext context, SyncConflict conflict) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getConflictTitle(conflict),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getConflictDescription(context, conflict),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onResolveConflict?.call(conflict),
            icon: const Icon(Icons.edit),
            iconSize: 16,
            tooltip: 'sync.resolve_conflict'.tr(),
          ),
        ],
      ),
    );
  }

  String _getConflictTitle(SyncConflict conflict) {
    switch (conflict.table) {
      case 'transactions':
        return 'Transaction ${conflict.syncId}';
      case 'budgets':
        return 'Budget ${conflict.syncId}';
      case 'accounts':
        return 'Account ${conflict.syncId}';
      case 'categories':
        return 'Category ${conflict.syncId}';
      default:
        return '${conflict.table} ${conflict.syncId}';
    }
  }

  String _getConflictDescription(BuildContext context, SyncConflict conflict) {
    final localTime = DateFormat.yMMMd().add_jm().format(conflict.localTimestamp);
    final remoteTime = DateFormat.yMMMd().add_jm().format(conflict.remoteTimestamp);
    return 'sync.conflict_description'.tr(args: [localTime, remoteTime]);
  }

  void _showConflictDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'sync.conflict_details'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: conflicts.length,
                  itemBuilder: (context, index) {
                    final conflict = conflicts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getConflictTitle(conflict),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getConflictDescription(context, conflict),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('sync.keep_local'.tr()),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('sync.use_remote'.tr()),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}