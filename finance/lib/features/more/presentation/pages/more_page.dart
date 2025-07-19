import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/sync_status_compact_widget.dart';
import '../widgets/sheep_premium_banner.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('navigation.more'.tr()),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              // Premium Banner at top
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: SheepPremiumBanner(),
              ),
              
              const _SectionHeader(title: 'more.sections.account'),
              _MenuItem(
                icon: Icons.person,
                title: 'more.items.profile',
                subtitle: 'more.items.profile_subtitle',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('more.actions.profile_tapped'.tr())),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.settings,
                title: 'more.items.settings',
                subtitle: 'more.items.settings_subtitle',
                onTap: () {
                  context.push('/settings');
                },
              ),

              const _SectionHeader(title: 'more.sections.data_sync'),
              _SyncMenuItem(
                onTap: () {
                  context.push('/sync');
                },
              ),
              // Security & Biometrics Section
              const _SectionHeader(title: 'more.sections.security'),
              _buildBiometricSettings(state),

              // Data Export Section
              const _SectionHeader(title: 'more.sections.data_export'),
              _buildExportSection(state),

            ],
          );
        },
      ),
    );
  }

  /// Biometric Authentication Settings
  Widget _buildBiometricSettings(SettingsState state) {
    return Column(
      children: [
        // Biometric Authentication Toggle
        FutureBuilder<bool>(
          future: _checkBiometricAvailability(),
          builder: (context, snapshot) {
            final isAvailable = snapshot.data ?? false;
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            
            return Column(
              children: [
                SwitchListTile(
                  secondary: state.isBiometricAuthenticating
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              getColor(context, 'primary'),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.fingerprint,
                          color: isAvailable 
                              ? getColor(context, 'primary')
                              : getColor(context, 'textLight'),
                        ),
                  title: Text('more.biometric.title'.tr()),
                  subtitle: Text(
                    state.isBiometricAuthenticating
                        ? 'more.biometric.authenticating'.tr()
                        : isLoading 
                            ? 'more.biometric.checking_availability'.tr()
                            : isAvailable 
                                ? 'more.biometric.use_biometric_security'.tr()
                                : 'more.biometric.not_available_device'.tr(),
                  ),
                  value: isAvailable ? state.biometricEnabled : false,
                  onChanged: (isAvailable && !state.isBiometricAuthenticating) ? (value) {
                    context.read<SettingsBloc>().add(
                      SettingsEvent.biometricToggled(value),
                    );
                  } : null,
                ),
                
                // Show authentication error if any
                if (state.biometricAuthError != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: getColor(context, 'error').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: getColor(context, 'error').withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 20,
                          color: getColor(context, 'error'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.biometricAuthError!,
                            style: TextStyle(
                              color: getColor(context, 'error'),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        
        // App Lock Toggle (only show if biometric is enabled)
        if (state.biometricEnabled)
          SwitchListTile(
            secondary: Icon(
              Icons.lock,
              color: getColor(context, 'primary'),
            ),
            title: Text('more.biometric.app_lock'.tr()),
            subtitle: Text('more.biometric.app_lock_subtitle'.tr()),
            value: state.biometricAppLockEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(
                SettingsEvent.biometricAppLockToggled(value),
              );
            },
          ),
        
        // Biometric Info Card (only show if biometric is enabled)
        if (state.biometricEnabled)
          FutureBuilder<String>(
            future: _getBiometricDescription(),
            builder: (context, snapshot) {
              final description = snapshot.data ?? 'more.biometric.loading'.tr();
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: getColor(context, 'surfaceContainer'),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: getColor(context, 'primary').withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: getColor(context, 'primary'),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'more.biometric.available_biometrics'.tr(),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: getColor(context, 'primary'),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: getColor(context, 'textLight'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildExportSection(SettingsState state) {
    return Column(
      children: [
        if (state.isExporting)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  state.exportStatus ?? 'more.export.exporting'.tr(),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          )
        else if (state.exportStatus != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.exportStatus!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          )
        else if (state.exportError != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.exportError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text('more.export.export_settings'.tr()),
          subtitle: Text('more.export.export_settings_subtitle'.tr()),
          trailing: const Icon(Icons.download),
          onTap: state.isExporting ? null : () {
            context.read<SettingsBloc>().add(
              const SettingsEvent.exportSettings(),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.all_inclusive),
          title: Text('more.export.export_all_data'.tr()),
          subtitle: Text('more.export.export_all_data_subtitle'.tr()),
          trailing: const Icon(Icons.download),
          onTap: state.isExporting ? null : () {
            context.read<SettingsBloc>().add(
              const SettingsEvent.exportAllData(),
            );
          },
        ),
        ExpansionTile(
          leading: const Icon(Icons.more_horiz),
          title: Text('more.export.individual_data_export'.tr()),
          subtitle: Text('more.export.individual_data_export_subtitle'.tr()),
          children: [
            ListTile(
              leading: const Icon(Icons.receipt),
              title: Text('more.export.export_transactions'.tr()),
              subtitle: Text('more.export.export_transactions_subtitle'.tr()),
              trailing: const Icon(Icons.download),
              onTap: state.isExporting ? null : () {
                context.read<SettingsBloc>().add(
                  const SettingsEvent.exportTransactions(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: Text('more.export.export_accounts'.tr()),
              subtitle: Text('more.export.export_accounts_subtitle'.tr()),
              trailing: const Icon(Icons.download),
              onTap: state.isExporting ? null : () {
                context.read<SettingsBloc>().add(
                  const SettingsEvent.exportAccounts(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: Text('more.export.export_categories'.tr()),
              subtitle: Text('more.export.export_categories_subtitle'.tr()),
              trailing: const Icon(Icons.download),
              onTap: state.isExporting ? null : () {
                context.read<SettingsBloc>().add(
                  const SettingsEvent.exportCategories(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart),
              title: Text('more.export.export_budgets'.tr()),
              subtitle: Text('more.export.export_budgets_subtitle'.tr()),
              trailing: const Icon(Icons.download),
              onTap: state.isExporting ? null : () {
                context.read<SettingsBloc>().add(
                  const SettingsEvent.exportBudgets(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Check if biometric authentication is available
  Future<bool> _checkBiometricAvailability() async {
    try {
      final biometricService = getIt<BiometricAuthService>();
      return await biometricService.isBiometricAvailable();
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get biometric description
  Future<String> _getBiometricDescription() async {
    try {
      final biometricService = getIt<BiometricAuthService>();
      return await biometricService.getBiometricDescription();
    } catch (e) {
      debugPrint('Error getting biometric description: $e');
      return 'more.biometric.unable_to_get_info'.tr();
    }
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
        title.tr(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(title.tr()),
      subtitle: Text(subtitle.tr()),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _SyncMenuItem extends StatelessWidget {
  const _SyncMenuItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.sync,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text('more.items.sync'.tr()),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('more.items.sync_subtitle'.tr()),
          const SizedBox(height: 4),
          const SyncStatusCompactWidget(),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
