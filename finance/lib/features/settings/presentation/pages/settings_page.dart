import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
    as flutter_colorpicker;
import 'package:easy_localization/easy_localization.dart';

import '../bloc/settings_bloc.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/material_you.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/language_selector.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/animation_performance_service.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/widgets/animations/animation_performance_monitor.dart';
import '../../../../shared/widgets/animations/animation_utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          'settings.title'.tr(),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              // Theme Section
              _buildSectionHeader('settings.theme'.tr()),
              _buildThemeModeSetting(),
              _buildDivider(),

              // Language Section
              _buildSectionHeader('settings.localization'.tr()),
              const LanguageSelector(),
              _buildDivider(),

              // Colors Section
              _buildSectionHeader('settings.colors'.tr()),
              _buildAccentColorSelector(),
              _buildCustomColorPicker(),
              _buildMaterialYouSettings(),
              _buildDivider(),

              // Text Section
              _buildSectionHeader('Text'),
              _buildFontSelector(),
              _buildContrastSetting(),
              _buildDivider(),

              // Accessibility Section
              _buildSectionHeader('Accessibility'),
              _buildReduceAnimationsSetting(),
              _buildHapticFeedbackSetting(),
              _buildDivider(),

              // Animation Framework Section (Phase 6.1)
              _buildSectionHeader('Animations'),
              _buildAnimationFrameworkSettings(),
              _buildDivider(),

              // Data & Privacy Section
              _buildSectionHeader('Data & Privacy'),
              SwitchListTile(
                secondary: const Icon(Icons.analytics),
                title: const Text('Analytics'),
                subtitle: const Text('Help improve the app with usage data'),
                value: state.analyticsEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(
                        SettingsEvent.analyticsToggled(value),
                      );
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.backup),
                title: const Text('Auto Backup'),
                subtitle: const Text('Automatically backup your data'),
                value: state.autoBackupEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(
                        SettingsEvent.autoBackupToggled(value),
                      );
                },
              ),
              _buildDivider(),

              // Data Export Section
              _buildSectionHeader('Data Export'),
              _buildExportSection(state),
              _buildDivider(),

              // Notifications Section
              _buildSectionHeader('Notifications'),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive important updates'),
                value: state.notificationsEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(
                        SettingsEvent.notificationsToggled(value),
                      );
                },
              ),
              _buildDivider(),

              // Debug Section (Phase 6.2)
              _buildSectionHeader('Debug & Performance'),
              _buildPerformanceMonitorTile(),
              _buildPerformanceMetricsTile(),
              _buildResetMetricsTile(),
              _buildDivider(),

              // App Info Section
              _buildSectionHeader('App Info'),
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('App Version'),
                subtitle: Text('1.0.0'),
              ),
              const ListTile(
                leading: Icon(Icons.code),
                title: Text('Build Number'),
                subtitle: Text('1'),
              ),
              _buildAboutTile(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: AppText(
        title,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        colorName: 'primary',
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: getColor(context, 'divider'),
    );
  }

  Widget _buildThemeModeSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'App Theme',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildThemeModeButton(
                'Light',
                Icons.light_mode,
                ThemeMode.light,
                AppTheme.themeMode == ThemeMode.light,
              ),
              const SizedBox(width: 8),
              _buildThemeModeButton(
                'Dark',
                Icons.dark_mode,
                ThemeMode.dark,
                AppTheme.themeMode == ThemeMode.dark,
              ),
              const SizedBox(width: 8),
              _buildThemeModeButton(
                'System',
                Icons.brightness_auto,
                ThemeMode.system,
                AppTheme.themeMode == ThemeMode.system,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeButton(
    String label,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
  ) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          await AppTheme.setThemeMode(mode);
          // Update BLoC as well for consistency
          context.read<SettingsBloc>().add(
                SettingsEvent.themeModeChanged(mode),
              );
          setState(() {});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? getColor(context, 'primary')
              : getColor(context, 'surfaceContainer'),
          foregroundColor:
              isSelected ? Colors.white : getColor(context, 'text'),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            AppText(
              label,
              fontSize: 12,
              textColor: isSelected ? Colors.white : getColor(context, 'text'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentColorSelector() {
    final colors = getSelectableColors();
    final currentColor = AppSettings.accentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Accent Color',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((color) {
              final isSelected = color.toARGB32() == currentColor.toARGB32();
              return GestureDetector(
                onTap: () async {
                  await AppTheme.setAccentColor(color);
                  setState(() {});
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? getColor(context, 'text')
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomColorPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Custom Color',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showColorPicker(),
            child: const AppText(
              'Pick Custom Color',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialYouSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Material You & Platform Colors',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),

          // Material You toggle
          SwitchListTile(
            title: const AppText('Material You'),
            subtitle: AppText(
              MaterialYouManager.getStatusMessage(),
              fontSize: 12,
              colorName: 'textLight',
            ),
            value: AppSettings.getWithDefault<bool>('materialYou', false),
            onChanged: MaterialYouManager.isSupported()
                ? (value) async {
                    await AppSettings.set('materialYou', value);
                    setState(() {});
                  }
                : null,
            contentPadding: EdgeInsets.zero,
          ),

          // System accent toggle
          SwitchListTile(
            title: const AppText('Use System Accent'),
            subtitle: AppText(
              MaterialYouManager.supportsPlatformColors()
                  ? 'Use system accent color when available'
                  : 'Platform doesn\'t support system colors',
              fontSize: 12,
              colorName: 'textLight',
            ),
            value: AppSettings.getWithDefault<bool>('useSystemAccent', false),
            onChanged: MaterialYouManager.supportsPlatformColors()
                ? (value) async {
                    await AppSettings.set('useSystemAccent', value);
                    setState(() {});
                  }
                : null,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildFontSelector() {
    final fonts = ['Inter', 'Avenir', 'DMSans', 'system'];
    final currentFont = AppSettings.getWithDefault<String>('font', 'Inter');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Font Family',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: currentFont,
            isExpanded: true,
            items: fonts.map((font) {
              return DropdownMenuItem(
                value: font,
                child: AppText(font),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                await AppSettings.set('font', value);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContrastSetting() {
    final isEnabled =
        AppSettings.getWithDefault<bool>('increaseTextContrast', false);

    return SwitchListTile(
      title: const AppText(
        'Enhanced Text Contrast',
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      subtitle: const AppText(
        'Increases contrast for better readability',
        fontSize: 12,
        colorName: 'textLight',
      ),
      value: isEnabled,
      onChanged: (value) async {
        await AppSettings.set('increaseTextContrast', value);
        setState(() {});
      },
      activeColor: getColor(context, 'primary'),
    );
  }

  Widget _buildReduceAnimationsSetting() {
    final isEnabled =
        AppSettings.getWithDefault<bool>('reduceAnimations', false);

    return SwitchListTile(
      title: const AppText(
        'Reduce Animations',
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      subtitle: const AppText(
        'Minimizes motion effects throughout the app',
        fontSize: 12,
        colorName: 'textLight',
      ),
      value: isEnabled,
      onChanged: (value) async {
        await AppSettings.set('reduceAnimations', value);
        setState(() {});
      },
      activeColor: getColor(context, 'primary'),
    );
  }

  Widget _buildHapticFeedbackSetting() {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: const AppText(
            'Haptic Feedback',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          subtitle: const AppText(
            'Enable touch vibrations and haptic responses',
            fontSize: 12,
            colorName: 'textLight',
          ),
          value: state.hapticFeedbackEnabled,
          onChanged: (value) {
            context.read<SettingsBloc>().add(
                  SettingsEvent.hapticFeedbackToggled(value),
                );
          },
          activeColor: getColor(context, 'primary'),
          secondary: Icon(
            Icons.vibration,
            color: getColor(context, 'textLight'),
          ),
        );
      },
    );
  }

  /// Phase 6.1: Enhanced Animation Framework Settings
  Widget _buildAnimationFrameworkSettings() {
    final appAnimations =
        AppSettings.getWithDefault<bool>('appAnimations', true);
    final batterySaver =
        AppSettings.getWithDefault<bool>('batterySaver', false);
    final animationLevel =
        AppSettings.getWithDefault<String>('animationLevel', 'normal');
    final outlinedIcons =
        AppSettings.getWithDefault<bool>('outlinedIcons', false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master animation toggle
          SwitchListTile(
            title: const AppText(
              'App Animations',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            subtitle: const AppText(
              'Enable smooth animations throughout the app',
              fontSize: 12,
              colorName: 'textLight',
            ),
            value: appAnimations,
            onChanged: (value) async {
              await AppSettings.set('appAnimations', value);
              setState(() {});
            },
            activeColor: getColor(context, 'primary'),
            contentPadding: EdgeInsets.zero,
          ),

          // Animation level selector
          if (appAnimations) ...[
            const SizedBox(height: 12),
            const AppText(
              'Animation Level',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              colorName: 'text',
            ),
            const SizedBox(height: 8),
            _buildAnimationLevelSelector(animationLevel),
          ],

          const SizedBox(height: 12),

          // Battery saver mode
          SwitchListTile(
            title: const AppText(
              'Battery Saver',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            subtitle: const AppText(
              'Reduces animations to save battery life',
              fontSize: 12,
              colorName: 'textLight',
            ),
            value: batterySaver,
            onChanged: (value) async {
              await AppSettings.set('batterySaver', value);
              setState(() {});
            },
            activeColor: getColor(context, 'primary'),
            contentPadding: EdgeInsets.zero,
          ),

          // Outlined icons toggle
          SwitchListTile(
            title: const AppText(
              'Outlined Icons',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            subtitle: const AppText(
              'Use outlined icon style instead of filled',
              fontSize: 12,
              colorName: 'textLight',
            ),
            value: outlinedIcons,
            onChanged: (value) async {
              await AppSettings.set('outlinedIcons', value);
              setState(() {});
            },
            activeColor: getColor(context, 'primary'),
            contentPadding: EdgeInsets.zero,
          ),

          // Performance info (when relevant)
          if (batterySaver ||
              !appAnimations ||
              animationLevel == 'reduced') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getColor(context, 'surfaceContainer'),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: getColor(context, 'primary'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      _getPerformanceInfo(),
                      fontSize: 12,
                      colorName: 'text',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimationLevelSelector(String currentLevel) {
    final levels = [
      {'value': 'none', 'label': 'None', 'description': 'No animations'},
      {
        'value': 'reduced',
        'label': 'Reduced',
        'description': 'Minimal animations'
      },
      {
        'value': 'normal',
        'label': 'Normal',
        'description': 'Standard animations'
      },
      {
        'value': 'enhanced',
        'label': 'Enhanced',
        'description': 'Rich animations'
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: levels.map((level) {
        final isSelected = level['value'] == currentLevel;
        return TappableWidget(
          onTap: () async {
            await AppSettings.set('animationLevel', level['value']!);
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? getColor(context, 'primary')
                  : getColor(context, 'surfaceContainer'),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? getColor(context, 'primary')
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  level['label']!,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  textColor:
                      isSelected ? Colors.white : getColor(context, 'text'),
                ),
                const SizedBox(height: 2),
                AppText(
                  level['description']!,
                  fontSize: 10,
                  textColor: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : getColor(context, 'textLight'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getPerformanceInfo() {
    final profile = AnimationPerformanceService.getPerformanceProfile();

    if (!profile['appAnimations']) {
      return 'All animations disabled for maximum performance';
    } else if (profile['batterySaver']) {
      return 'Battery saver active: Reduced animations and effects';
    } else if (profile['animationLevel'] == 'reduced') {
      return 'Reduced animations: ${profile['maxSimultaneousAnimations']} max concurrent';
    } else if (profile['animationLevel'] == 'enhanced') {
      return 'Enhanced animations: Full effects and transitions enabled';
    }

    return 'Normal animation level: Balanced performance and experience';
  }

  Widget _buildAboutTile() {
    return ListTile(
      title: const AppText(
        'About Finance App',
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      subtitle: const AppText(
        'A personal finance management app with advanced features',
        fontSize: 12,
        colorName: 'textLight',
      ),
      trailing: const Icon(Icons.info_outline),
      onTap: () => _showAboutDialog(),
    );
  }

  /// Phase 6.2: Performance monitor tile
  Widget _buildPerformanceMonitorTile() {
    return ListTile(
      leading: const Icon(Icons.monitor),
      title: const AppText(
        'Performance Monitor',
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      subtitle: const AppText(
        'Show real-time animation performance information',
        fontSize: 12,
        colorName: 'textLight',
      ),
      trailing: const Icon(Icons.visibility),
      onTap: () => _showPerformanceMonitor(),
    );
  }

  /// Phase 6.2: Performance metrics tile
  Widget _buildPerformanceMetricsTile() {
    return ListTile(
      leading: const Icon(Icons.analytics),
      title: const AppText(
        'Performance Metrics',
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      subtitle: const AppText(
        'View detailed animation performance statistics',
        fontSize: 12,
        colorName: 'textLight',
      ),
      trailing: const Icon(Icons.bar_chart),
      onTap: () => _showPerformanceMetrics(),
    );
  }

  /// Phase 6.2: Reset metrics tile
  Widget _buildResetMetricsTile() {
    return ListTile(
      leading: const Icon(Icons.refresh),
      title: const AppText(
        'Reset Performance Metrics',
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      subtitle: const AppText(
        'Clear all animation performance tracking data',
        fontSize: 12,
        colorName: 'textLight',
      ),
      trailing: const Icon(Icons.clear_all),
      onTap: () => _resetPerformanceMetrics(),
    );
  }

  /// Phase 6.2: Show performance monitor dialog
  void _showPerformanceMonitor() {
    DialogService.showPopup<void>(
      context,
      const AnimationPerformanceMonitor(
        showFullDetails: true,
        refreshInterval: Duration(milliseconds: 250),
      ),
      title: 'Real-time Performance Monitor',
      subtitle: 'Live animation performance data',
      icon: Icons.monitor,
      showCloseButton: true,
      barrierDismissible: true,
      animationType: DialogService.defaultPopupAnimation,
    );
  }

  /// Phase 6.2: Show performance metrics dialog
  void _showPerformanceMetrics() {
    final metrics = AnimationUtils.getPerformanceMetrics();
    final debugInfo = AnimationUtils.getAnimationDebugInfo();

    DialogService.showPopup<void>(
      context,
      SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Performance
            const AppText(
              'Current Performance:',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              colorName: 'text',
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getColor(context, 'surfaceContainer'),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildMetricRow(
                      'Active Animations', '${metrics['activeAnimations']}'),
                  _buildMetricRow('Max Simultaneous',
                      '${metrics['maxSimultaneousAnimations']}'),
                  _buildMetricRow(
                      'Performance Status',
                      metrics['performanceProfile']['performanceMetrics']
                              ['isPerformanceGood']
                          ? 'Good'
                          : 'Degraded'),
                  _buildMetricRow('Frame Time',
                      '${metrics['performanceProfile']['performanceMetrics']['averageFrameTimeMs']}ms'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings Summary
            const AppText(
              'Animation Settings:',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              colorName: 'text',
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getColor(context, 'surfaceContainer'),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildMetricRow(
                      'Animation Level', '${debugInfo['animationLevel']}'),
                  _buildMetricRow(
                      'App Animations', '${debugInfo['appAnimations']}'),
                  _buildMetricRow(
                      'Battery Saver', '${debugInfo['batterySaver']}'),
                  _buildMetricRow('Complex Animations',
                      '${debugInfo['shouldUseComplexAnimations']}'),
                  _buildMetricRow('Staggered Animations',
                      '${debugInfo['shouldUseStaggeredAnimations']}'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const AppText(
                  'Close',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  textColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      title: 'Performance Metrics',
      subtitle: 'Animation performance statistics',
      icon: Icons.analytics,
      showCloseButton: true,
      barrierDismissible: true,
      animationType: DialogService.defaultPopupAnimation,
    );
  }

  /// Helper method to build metric rows
  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            fontSize: 12,
            colorName: 'textLight',
          ),
          AppText(
            value,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            colorName: 'text',
          ),
        ],
      ),
    );
  }

  /// Phase 6.2: Reset performance metrics
  void _resetPerformanceMetrics() {
    AnimationUtils.resetPerformanceMetrics();
    AnimationPerformanceService.resetPerformanceMetrics();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const AppText(
          'Performance metrics have been reset',
          fontSize: 14,
          textColor: Colors.white,
        ),
        backgroundColor: getColor(context, 'primary'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Phase 6.1: Enhanced About dialog with PopupFramework
  void _showAboutDialog() {
    DialogService.showPopup<void>(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App description
          const AppText(
            'Built with Flutter and featuring advanced theming capabilities including Material You support, comprehensive animation framework, custom fonts, and accessibility features.',
            fontSize: 14,
            colorName: 'text',
          ),
          const SizedBox(height: 16),

          // Features list
          const AppText(
            'Key Features:',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            colorName: 'text',
          ),
          const SizedBox(height: 8),

          ...[
            'Multi-currency support',
            'Cloud synchronization',
            'Budget tracking',
            'Advanced animations',
            'Material You theming',
            'Accessibility support'
          ].map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: getColor(context, 'primary'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        feature,
                        fontSize: 13,
                        colorName: 'text',
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 16),

          // Legal and version info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: getColor(context, 'surfaceContainer'),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      'Version',
                      fontSize: 12,
                      colorName: 'textLight',
                    ),
                    AppText(
                      '1.0.0',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      colorName: 'text',
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      'Build',
                      fontSize: 12,
                      colorName: 'textLight',
                    ),
                    AppText(
                      '1',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      colorName: 'text',
                    ),
                  ],
                ),
                Divider(height: 16),
                AppText(
                  '© 2025 Finance App Team',
                  fontSize: 11,
                  colorName: 'textLight',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Close button
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const AppText(
                'Close',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                textColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      title: 'About Finance App',
      subtitle: 'App information and details',
      icon: Icons.info,
      showCloseButton: true,
      barrierDismissible: true,
      animationType: DialogService.defaultPopupAnimation,
    );
  }

  void _showColorPicker() async {
    Color selectedColor = AppSettings.accentColor;

    // Phase 6.1: Replace standard showDialog with PopupFramework
    await DialogService.showPopup<void>(
      context,
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color picker content
              SizedBox(
                width: 280,
                height: 300,
                child: SingleChildScrollView(
                  child: flutter_colorpicker.ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    enableAlpha: false,
                    displayThumbColor: true,
                    showLabel: true,
                    paletteType: flutter_colorpicker.PaletteType.hslWithHue,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const AppText(
                      'Cancel',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      await AppTheme.setAccentColor(selectedColor);
                      this.setState(() {}); // Update parent widget
                      Navigator.of(context).pop();
                    },
                    child: const AppText(
                      'Select',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      title: 'settings.color_picker_title'.tr(),
      subtitle: 'settings.color_picker_subtitle'.tr(),
      icon: Icons.palette,
      showCloseButton: true,
      barrierDismissible: true,
      animationType: DialogService.defaultPopupAnimation,
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
                  state.exportStatus ?? 'Exporting...',
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
          title: const Text('Export Settings'),
          subtitle: const Text('Export app settings and preferences'),
          trailing: const Icon(Icons.download),
          onTap: state.isExporting ? null : () {
            context.read<SettingsBloc>().add(
              const SettingsEvent.exportSettings(),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.all_inclusive),
          title: const Text('Export All Data'),
          subtitle: const Text('Export all app data (settings, transactions, etc.)'),
          trailing: const Icon(Icons.download),
          onTap: state.isExporting ? null : () {
            context.read<SettingsBloc>().add(
              const SettingsEvent.exportAllData(),
            );
          },
        ),
        ExpansionTile(
          leading: const Icon(Icons.more_horiz),
          title: const Text('Individual Data Export'),
          subtitle: const Text('Export specific data types'),
          children: [
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Transactions'),
              subtitle: const Text('Export transaction history'),
              trailing: const Icon(Icons.download),
              onTap: state.isExporting ? null : () {
                context.read<SettingsBloc>().add(
                  const SettingsEvent.exportTransactions(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Accounts'),
              subtitle: const Text('Export account information'),
              trailing: const Icon(Icons.download),
              onTap: state.isExporting ? null : () {
                context.read<SettingsBloc>().add(
                  const SettingsEvent.exportAccounts(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              subtitle: const Text('Export category data'),
              trailing: const Icon(Icons.download),
              onTap: state.isExporting ? null : () {
                context.read<SettingsBloc>().add(
                  const SettingsEvent.exportCategories(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Budgets'),
              subtitle: const Text('Export budget information'),
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
}
