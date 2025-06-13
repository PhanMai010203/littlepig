import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as flutter_colorpicker;
import 'package:easy_localization/easy_localization.dart';

import '../bloc/settings_bloc.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/material_you.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/language_selector.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: AppText(
          'settings.title'.tr(),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [              // Theme Section
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
              _buildDivider(),
              
              // Data & Privacy Section
              _buildSectionHeader('Data & Privacy'),
              SwitchListTile(
                secondary: Icon(Icons.analytics),
                title: Text('Analytics'),
                subtitle: Text('Help improve the app with usage data'),
                value: state.analyticsEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(
                    SettingsEvent.analyticsToggled(value),
                  );
                },
              ),
              SwitchListTile(
                secondary: Icon(Icons.backup),
                title: Text('Auto Backup'),
                subtitle: Text('Automatically backup your data'),
                value: state.autoBackupEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(
                    SettingsEvent.autoBackupToggled(value),
                  );
                },
              ),
              _buildDivider(),
              
              // Notifications Section
              _buildSectionHeader('Notifications'),
              SwitchListTile(
                secondary: Icon(Icons.notifications),
                title: Text('Push Notifications'),
                subtitle: Text('Receive important updates'),
                value: state.notificationsEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(
                    SettingsEvent.notificationsToggled(value),
                  );
                },
              ),
              _buildDivider(),
              
              // App Info Section
              _buildSectionHeader('App Info'),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('App Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
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
          foregroundColor: isSelected
              ? Colors.white
              : getColor(context, 'text'),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            AppText(
              label,
              fontSize: 12,
              textColor: isSelected
                  ? Colors.white
                  : getColor(context, 'text'),
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
            runSpacing: 8,            children: colors.map((color) {
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
                    boxShadow: [                      BoxShadow(
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
    final isEnabled = AppSettings.getWithDefault<bool>('increaseTextContrast', false);

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
    final isEnabled = AppSettings.getWithDefault<bool>('reduceAnimations', false);

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

  Widget _buildAboutTile() {
    return ListTile(
      title: const AppText(
        'About Boilerplate App',
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      subtitle: const AppText(
        'A production-ready Flutter app with advanced theming',
        fontSize: 12,
        colorName: 'textLight',
      ),
      trailing: const Icon(Icons.info_outline),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'Boilerplate App',
          applicationVersion: '1.0.0',
          applicationLegalese: '© 2025 Boilerplate Team',
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: AppText(
                'Built with Flutter and advanced theming capabilities including Material You support, custom fonts, and accessibility features.',
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showColorPicker() async {
    Color selectedColor = AppSettings.accentColor;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Color'),
        content: SingleChildScrollView(
          child: flutter_colorpicker.ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await AppTheme.setAccentColor(selectedColor);
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Select'),
          ),
        ],
      ),    );
  }
}