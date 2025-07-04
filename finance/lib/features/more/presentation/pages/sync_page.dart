import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/sync/sync_service.dart';
import '../bloc/sync_bloc.dart';
import '../bloc/sync_event.dart';
import '../bloc/sync_state.dart';
import '../widgets/sync_status_widget.dart';
import '../widgets/sync_progress_widget.dart';
import '../widgets/sync_conflict_widget.dart';

class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SyncBloc(),
      child: const _SyncPageContent(),
    );
  }
}

class _SyncPageContent extends StatelessWidget {
  const _SyncPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sync.title'.tr()),
        actions: [
          BlocBuilder<SyncBloc, SyncBlocState>(
            builder: (context, state) {
              return IconButton(
                onPressed: state is SyncLoadingState
                    ? null
                    : () => context.read<SyncBloc>().add(const SyncRefreshEvent()),
                icon: const Icon(Icons.refresh),
                tooltip: 'sync.refresh'.tr(),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<SyncBloc, SyncBlocState>(
        listener: (context, state) {
          if (state is SyncErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                action: state.details != null
                    ? SnackBarAction(
                        label: 'sync.show_details'.tr(),
                        onPressed: () => _showErrorDetails(context, state.details!),
                      )
                    : null,
              ),
            );
          } else if (state is SyncLoadedState && state.lastResult != null) {
            if (state.lastResult!.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('sync.sync_completed_successfully'.tr()),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is SyncLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SyncErrorState) {
            return _buildErrorView(context, state);
          }

          if (state is SyncAuthenticationState) {
            return _buildAuthenticationView(context, state);
          }

          if (state is SyncLoadedState) {
            return _buildSyncView(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, SyncErrorState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (state.details != null) ...[
              const SizedBox(height: 8),
              Text(
                state.details!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.read<SyncBloc>().add(const SyncInitializeEvent()),
              child: Text('sync.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationView(BuildContext context, SyncAuthenticationState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.isSigningIn) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'sync.signing_in'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ] else ...[
              Icon(
                Icons.account_circle_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'sync.authentication_required'.tr(),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSyncView(BuildContext context, SyncLoadedState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SyncBloc>().add(const SyncRefreshEvent());
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Sync Status Card
          SyncStatusWidget(
            status: state.status,
            lastSyncTime: state.lastSyncTime,
            userEmail: state.userEmail,
            isSignedIn: state.isSignedIn,
            onTap: state.isSignedIn ? null : () => _showSignInDialog(context),
          ),

          // Progress Widget (shown during sync)
          SyncProgressWidget(
            status: state.status,
            progress: state.progress,
            uploadedCount: state.uploadedCount,
            downloadedCount: state.downloadedCount,
            currentOperation: state.currentOperation,
          ),

          // Conflicts Widget
          SyncConflictWidget(
            conflicts: state.conflicts,
            onResolveAll: () => context.read<SyncBloc>().add(
                  const SyncResolveAllConflictsEvent(
                    defaultResolution: ConflictResolution.merge,
                  ),
                ),
            onResolveConflict: (conflict) => context.read<SyncBloc>().add(
                  SyncResolveConflictEvent(
                    conflict: conflict,
                    resolution: ConflictResolution.merge,
                  ),
                ),
          ),

          // Account Management Section
          if (state.isSignedIn) ...[
            const _SectionHeader(title: 'Account'),
            _AccountInfoCard(
              email: state.userEmail ?? 'Unknown',
              onSignOut: () => _showSignOutDialog(context),
            ),
          ] else ...[
            const _SectionHeader(title: 'Account'),
            _SignInCard(
              onSignIn: () => context.read<SyncBloc>().add(const SyncSignInEvent()),
            ),
          ],

          // Sync Controls Section
          if (state.isSignedIn) ...[
            const _SectionHeader(title: 'Sync Controls'),
            _SyncControlsCard(
              issyncing: state.status != SyncStatus.idle && state.status != SyncStatus.completed,
              onFullSync: () => context.read<SyncBloc>().add(
                    const SyncManualTriggerEvent(type: SyncTriggerType.full),
                  ),
              onUploadOnly: () => context.read<SyncBloc>().add(
                    const SyncManualTriggerEvent(type: SyncTriggerType.uploadOnly),
                  ),
              onDownloadOnly: () => context.read<SyncBloc>().add(
                    const SyncManualTriggerEvent(type: SyncTriggerType.downloadOnly),
                  ),
              onCancel: state.status != SyncStatus.idle && state.status != SyncStatus.completed
                  ? () => context.read<SyncBloc>().add(const SyncCancelEvent())
                  : null,
            ),
          ],

          // Sync History Section
          if (state.lastResult != null) ...[
            const _SectionHeader(title: 'Last Sync Result'),
            _SyncHistoryCard(result: state.lastResult!),
          ],

          // Settings and Information
          const _SectionHeader(title: 'Information'),
          _SyncInfoCard(),
        ],
      ),
    );
  }

  void _showErrorDetails(BuildContext context, String details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('sync.error_details'.tr()),
        content: SingleChildScrollView(
          child: Text(details),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.close'.tr()),
          ),
        ],
      ),
    );
  }

  void _showSignInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('sync.sign_in_to_google'.tr()),
        content: Text('sync.sign_in_description'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SyncBloc>().add(const SyncSignInEvent());
            },
            child: Text('sync.sign_in'.tr()),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('sync.sign_out'.tr()),
        content: Text('sync.sign_out_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SyncBloc>().add(const SyncSignOutEvent());
            },
            child: Text('sync.sign_out'.tr()),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  const _AccountInfoCard({
    required this.email,
    required this.onSignOut,
  });

  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.account_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text('sync.signed_in_as'.tr()),
        subtitle: Text(email),
        trailing: TextButton(
          onPressed: onSignOut,
          child: Text('sync.sign_out'.tr()),
        ),
      ),
    );
  }
}

class _SignInCard extends StatelessWidget {
  const _SignInCard({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.cloud_off,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'sync.not_signed_in'.tr(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'sync.sign_in_to_enable_sync'.tr(),
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
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSignIn,
                child: Text('sync.sign_in_to_google'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncControlsCard extends StatelessWidget {
  const _SyncControlsCard({
    required this.issyncing,
    required this.onFullSync,
    required this.onUploadOnly,
    required this.onDownloadOnly,
    this.onCancel,
  });

  final bool issyncing;
  final VoidCallback onFullSync;
  final VoidCallback onUploadOnly;
  final VoidCallback onDownloadOnly;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'sync.manual_sync'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: issyncing ? null : onFullSync,
                    icon: const Icon(Icons.sync),
                    label: Text('sync.full_sync'.tr()),
                  ),
                ),
                if (onCancel != null) ...[
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel),
                    label: Text('sync.cancel'.tr()),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: issyncing ? null : onUploadOnly,
                    icon: const Icon(Icons.upload),
                    label: Text('sync.upload_only'.tr()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: issyncing ? null : onDownloadOnly,
                    icon: const Icon(Icons.download),
                    label: Text('sync.download_only'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncHistoryCard extends StatelessWidget {
  const _SyncHistoryCard({required this.result});

  final SyncResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.success ? Icons.check_circle : Icons.error,
                  color: result.success
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  result.success ? 'sync.success'.tr() : 'sync.failed'.tr(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: result.success
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMd().add_jm().format(result.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (result.success) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('sync.uploaded'.tr()),
                  const SizedBox(width: 4),
                  Text(
                    result.uploadedCount.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 16),
                  Text('sync.downloaded'.tr()),
                  const SizedBox(width: 4),
                  Text(
                    result.downloadedCount.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
            if (!result.success && result.error != null) ...[
              const SizedBox(height: 8),
              Text(
                result.error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SyncInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'sync.about_sync'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.cloud,
              title: 'sync.cloud_storage'.tr(),
              subtitle: 'sync.google_drive_integration'.tr(),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.security,
              title: 'sync.data_security'.tr(),
              subtitle: 'sync.encrypted_transmission'.tr(),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.devices,
              title: 'sync.multi_device'.tr(),
              subtitle: 'sync.sync_across_devices'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}