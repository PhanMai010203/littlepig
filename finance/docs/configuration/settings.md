# Settings Management

Comprehensive guide for managing user preferences, app settings, and configuration persistence using SharedPreferences and secure storage.

## 📋 Table of Contents

- [SharedPreferences Setup](#sharedpreferences-setup)
- [Settings Service Architecture](#settings-service-architecture)
- [User Preference Categories](#user-preference-categories)
- [Secure Storage](#secure-storage)
- [Settings UI Components](#settings-ui-components)
- [State Management Integration](#state-management-integration)
- [Data Migration](#data-migration)
- [Best Practices](#best-practices)

## 📦 SharedPreferences Setup

### Installation and Configuration

```yaml
# pubspec.yaml
dependencies:
  shared_preferences: ^2.2.2
  local_auth: ^2.2.0  # For biometric authentication
  # Note: flutter_secure_storage is not currently used in this project
```

### Current Implementation

The project currently uses a custom `AppSettings` class for settings management:

```dart
// lib/core/settings/app_settings.dart
class AppSettings {
  static Map<String, dynamic> _settings = {};
  static SharedPreferences? _prefs;
  
  /// Initialize the settings system - call this in main()
  static Future<bool> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    return true;
  }

  /// Get a setting value with type safety
  static T? get<T>(String key) {
    return _settings[key] as T?;
  }

  /// Get a setting value with a default fallback
  static T getWithDefault<T>(String key, T defaultValue) {
    return _settings[key] as T? ?? defaultValue;
  }

  /// Update a setting and persist it
  static Future<bool> set(String key, dynamic value, {
    bool notifyListeners = true,
  }) async {
    bool isChanged = _settings[key] != value;
    _settings[key] = value;
    
    await _saveSettings();
    
    if (isChanged && notifyListeners) {
      // Trigger app rebuild for theme changes
      _notifyAppStateChange();
    }
    
    return true;
  }
}
```

### Service Registration

```dart
// lib/core/di/injection.dart
Future<void> configureDependencies() async {
  // Initialize injectable dependencies FIRST (for existing BLoCs)
  getIt.init();
  
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  }
  
  // AppSettings is initialized separately in main()
  await AppSettings.initialize();
}
```

## 🏗️ Settings Service Architecture

### Current Settings Implementation

The project currently uses `AppSettings` class with predefined settings:

```dart
// lib/core/settings/app_settings.dart
static Map<String, dynamic> _getDefaultSettings() {
  return {
    // Theme settings
    'themeMode': 'system', // 'light', 'dark', 'system'
    'materialYou': false,   // User can enable if supported
    'useSystemAccent': false, // User can enable if supported
    'accentColor': '0xFF2196F3', // Default blue fallback
    
    // Text settings
    'font': 'Avenir', // 'system', 'Avenir', 'Inter', 'DMSans', etc.
    'fontSize': 16.0,
    'increaseTextContrast': false,
    
    // Localization
    'locale': 'system', // 'system' or locale code like 'en', 'es'
    
    // Accessibility
    'reduceAnimations': false,
    'highContrast': false,
    
    // App behavior
    'firstLaunch': true,
    'lastVersion': '1.0.0',
  };
}

  // Theme Settings
  ThemeMode get themeMode {
    final themeName = StorageService.preferences.getString(_themeKey);
    if (themeName == null) return ThemeMode.system;
    
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == themeName,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await StorageService.preferences.setString(_themeKey, mode.name);
  }

  // Language Settings
  Locale? get locale {
    final languageCode = StorageService.preferences.getString(_languageKey);
    return languageCode != null ? Locale(languageCode) : null;
  }

  Future<void> setLocale(Locale locale) async {
    await StorageService.preferences.setString(_languageKey, locale.languageCode);
  }

  // Notification Settings
  bool get notificationsEnabled {
    return StorageService.preferences.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await StorageService.preferences.setBool(_notificationsKey, enabled);
  }

  // Analytics Settings
  bool get analyticsEnabled {
    return StorageService.preferences.getBool(_analyticsKey) ?? false;
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    await StorageService.preferences.setBool(_analyticsKey, enabled);
  }

  // First Launch
  bool get isFirstLaunch {
    return StorageService.preferences.getBool(_firstLaunchKey) ?? true;
  }

  Future<void> markFirstLaunchComplete() async {
    await StorageService.preferences.setBool(_firstLaunchKey, false);
  }

  // Last Sync
  DateTime? get lastSyncTime {
    final timestamp = StorageService.preferences.getInt(_lastSyncKey);
    return timestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<void> updateLastSyncTime([DateTime? time]) async {
    final syncTime = time ?? DateTime.now();
    await StorageService.preferences.setInt(
      _lastSyncKey, 
      syncTime.millisecondsSinceEpoch,
    );
  }

  // Biometric Settings (Secure Storage)
  Future<bool> get biometricsEnabled async {
    final value = await StorageService.secureStorage.read(key: _biometricsKey);
    return value == 'true';
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await StorageService.secureStorage.write(
      key: _biometricsKey,
      value: enabled.toString(),
    );
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    await StorageService.preferences.clear();
    await StorageService.secureStorage.deleteAll();
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    final prefs = StorageService.preferences;
    final keys = prefs.getKeys();
    
    return {
      for (String key in keys)
        key: prefs.get(key),
    };
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    final prefs = StorageService.preferences;
    
    for (final entry in settings.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      }
    }
  }
}
```

## 🎨 User Preference Categories

### Theme Preferences

```dart
// lib/core/services/theme_settings_service.dart
class ThemeSettingsService {
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';
  static const String _useMaterialYouKey = 'use_material_you';
  static const String _customColorsKey = 'custom_colors';

  // Theme Mode
  ThemeMode get themeMode {
    final themeName = StorageService.preferences.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == themeName,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await StorageService.preferences.setString(_themeModeKey, mode.name);
  }

  // Primary Color
  Color? get primaryColor {
    final colorValue = StorageService.preferences.getInt(_primaryColorKey);
    return colorValue != null ? Color(colorValue) : null;
  }

  Future<void> setPrimaryColor(Color color) async {
    await StorageService.preferences.setInt(_primaryColorKey, color.value);
  }

  // Material You
  bool get useMaterialYou {
    return StorageService.preferences.getBool(_useMaterialYouKey) ?? true;
  }

  Future<void> setUseMaterialYou(bool enabled) async {
    await StorageService.preferences.setBool(_useMaterialYouKey, enabled);
  }

  // Custom Colors
  Map<String, Color> get customColors {
    final colorsJson = StorageService.preferences.getString(_customColorsKey);
    if (colorsJson == null) return {};

    final Map<String, dynamic> colorsMap = json.decode(colorsJson);
    return colorsMap.map((key, value) => MapEntry(key, Color(value as int)));
  }

  Future<void> setCustomColors(Map<String, Color> colors) async {
    final colorsMap = colors.map((key, value) => MapEntry(key, value.value));
    await StorageService.preferences.setString(
      _customColorsKey,
      json.encode(colorsMap),
    );
  }
}
```

### Notification Preferences

```dart
// lib/core/services/notification_settings_service.dart
class NotificationSettingsService {
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _budgetAlertsKey = 'budget_alerts_enabled';
  static const String _transactionAlertsKey = 'transaction_alerts_enabled';
  static const String _reminderAlertsKey = 'reminder_alerts_enabled';
  static const String _quietHoursStartKey = 'quiet_hours_start';
  static const String _quietHoursEndKey = 'quiet_hours_end';
  static const String _notificationSoundKey = 'notification_sound';

  // General Notifications
  bool get notificationsEnabled {
    return StorageService.preferences.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await StorageService.preferences.setBool(_notificationsEnabledKey, enabled);
  }

  // Budget Alerts
  bool get budgetAlertsEnabled {
    return StorageService.preferences.getBool(_budgetAlertsKey) ?? true;
  }

  Future<void> setBudgetAlertsEnabled(bool enabled) async {
    await StorageService.preferences.setBool(_budgetAlertsKey, enabled);
  }

  // Transaction Alerts
  bool get transactionAlertsEnabled {
    return StorageService.preferences.getBool(_transactionAlertsKey) ?? true;
  }

  Future<void> setTransactionAlertsEnabled(bool enabled) async {
    await StorageService.preferences.setBool(_transactionAlertsKey, enabled);
  }

  // Reminder Alerts
  bool get reminderAlertsEnabled {
    return StorageService.preferences.getBool(_reminderAlertsKey) ?? true;
  }

  Future<void> setReminderAlertsEnabled(bool enabled) async {
    await StorageService.preferences.setBool(_reminderAlertsKey, enabled);
  }

  // Quiet Hours
  TimeOfDay? get quietHoursStart {
    final timeString = StorageService.preferences.getString(_quietHoursStartKey);
    if (timeString == null) return null;
    
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> setQuietHoursStart(TimeOfDay? time) async {
    if (time == null) {
      await StorageService.preferences.remove(_quietHoursStartKey);
    } else {
      await StorageService.preferences.setString(
        _quietHoursStartKey,
        '${time.hour}:${time.minute}',
      );
    }
  }

  TimeOfDay? get quietHoursEnd {
    final timeString = StorageService.preferences.getString(_quietHoursEndKey);
    if (timeString == null) return null;
    
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> setQuietHoursEnd(TimeOfDay? time) async {
    if (time == null) {
      await StorageService.preferences.remove(_quietHoursEndKey);
    } else {
      await StorageService.preferences.setString(
        _quietHoursEndKey,
        '${time.hour}:${time.minute}',
      );
    }
  }

  // Notification Sound
  String get notificationSound {
    return StorageService.preferences.getString(_notificationSoundKey) ?? 'default';
  }

  Future<void> setNotificationSound(String sound) async {
    await StorageService.preferences.setString(_notificationSoundKey, sound);
  }
}
```

### Privacy & Security Settings

```dart
// lib/core/services/privacy_settings_service.dart
class PrivacySettingsService {
  static const String _analyticsKey = 'analytics_enabled';
  static const String _crashReportingKey = 'crash_reporting_enabled';
  static const String _dataCollectionKey = 'data_collection_enabled';
  static const String _biometricsKey = 'biometrics_enabled';
  static const String _autoLockKey = 'auto_lock_enabled';
  static const String _autoLockTimeoutKey = 'auto_lock_timeout_minutes';

  // Analytics
  bool get analyticsEnabled {
    return StorageService.preferences.getBool(_analyticsKey) ?? false;
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    await StorageService.preferences.setBool(_analyticsKey, enabled);
  }

  // Crash Reporting
  bool get crashReportingEnabled {
    return StorageService.preferences.getBool(_crashReportingKey) ?? true;
  }

  Future<void> setCrashReportingEnabled(bool enabled) async {
    await StorageService.preferences.setBool(_crashReportingKey, enabled);
  }

  // Data Collection
  bool get dataCollectionEnabled {
    return StorageService.preferences.getBool(_dataCollectionKey) ?? false;
  }

  Future<void> setDataCollectionEnabled(bool enabled) async {
    await StorageService.preferences.setBool(_dataCollectionKey, enabled);
  }

  // Biometrics (Secure Storage)
  Future<bool> get biometricsEnabled async {
    final value = await StorageService.secureStorage.read(key: _biometricsKey);
    return value == 'true';
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await StorageService.secureStorage.write(
      key: _biometricsKey,
      value: enabled.toString(),
    );
  }

  // Auto Lock
  bool get autoLockEnabled {
    return StorageService.preferences.getBool(_autoLockKey) ?? false;
  }

  Future<void> setAutoLockEnabled(bool enabled) async {
    await StorageService.preferences.setBool(_autoLockKey, enabled);
  }

  // Auto Lock Timeout
  int get autoLockTimeoutMinutes {
    return StorageService.preferences.getInt(_autoLockTimeoutKey) ?? 5;
  }

  Future<void> setAutoLockTimeoutMinutes(int minutes) async {
    await StorageService.preferences.setInt(_autoLockTimeoutKey, minutes);
  }
}
```

## 🔐 Biometric Authentication

### Current Biometric Implementation

The project currently implements biometric authentication for budget access:

```dart
// lib/features/budgets/data/services/budget_auth_service.dart
class BudgetAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  Future<bool> authenticateForBudgetAccess() async {
    try {
      // Check if biometric authentication is available
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!isAvailable || !isDeviceSupported) {
        return false; // Fallback to no authentication if not available
      }
      
      // Get available biometric types
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        return false; // No biometric methods available
      }
      
      // Attempt authentication
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access sensitive budget information',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('Biometric authentication error: $e');
      return false; // Fallback to no authentication on error
    }
  }

  // Authentication Tokens
  static Future<void> storeAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> clearAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Refresh Tokens
  static Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  // PIN/Password
  static Future<void> storePIN(String pin) async {
    // Hash the PIN before storing
    final hashedPin = _hashPin(pin);
    await _storage.write(key: 'user_pin', value: hashedPin);
  }

  static Future<bool> verifyPIN(String pin) async {
    final storedPin = await _storage.read(key: 'user_pin');
    if (storedPin == null) return false;
    
    final hashedPin = _hashPin(pin);
    return hashedPin == storedPin;
  }

  static Future<void> clearPIN() async {
    await _storage.delete(key: 'user_pin');
  }

  // Biometric Settings
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  // User Credentials (if needed)
  static Future<void> storeCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  static Future<Map<String, String?>> getCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    
    return {
      'username': username,
      'password': password,
    };
  }

  // Clear all secure data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if storage is available
  static Future<bool> isAvailable() async {
    try {
      await _storage.containsKey(key: 'test');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Private helper methods
  static String _hashPin(String pin) {
    // Use a proper hashing algorithm in production
    return pin.hashCode.toString();
  }
}
```

## 🎛️ Settings UI Components

### Current Settings Screen

```dart
// lib/features/settings/presentation/pages/settings_page.dart
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
          _buildSection(
            context,
            title: 'Notifications',
            children: [
              _buildNotificationSettings(context),
            ],
          ),
          _buildSection(
            context,
            title: 'Privacy & Security',
            children: [
              _buildPrivacySettings(context),
              _buildSecuritySettings(context),
            ],
          ),
          _buildSection(
            context,
            title: 'Data',
            children: [
              _buildDataSettings(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('Theme'),
          subtitle: Text(_getThemeModeText(state.themeMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(context),
        );
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: Text(state.locale?.languageCode ?? 'System'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(context),
        );
      },
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          subtitle: const Text('Receive app notifications'),
          value: state.notificationsEnabled,
          onChanged: (value) {
            context.read<SettingsBloc>().add(
              SettingsNotificationsToggled(value),
            );
          },
        );
      },
    );
  }

  Widget _buildPrivacySettings(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          secondary: const Icon(Icons.analytics),
          title: const Text('Analytics'),
          subtitle: const Text('Help improve the app'),
          value: state.analyticsEnabled,
          onChanged: (value) {
            context.read<SettingsBloc>().add(
              SettingsAnalyticsToggled(value),
            );
          },
        );
      },
    );
  }

  Widget _buildSecuritySettings(BuildContext context) {
    return FutureBuilder<bool>(
      future: LocalAuthentication().canCheckBiometrics,
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometric Authentication'),
              subtitle: const Text('Use fingerprint or face ID'),
              value: state.biometricsEnabled,
              onChanged: (value) {
                context.read<SettingsBloc>().add(
                  SettingsBiometricsToggled(value),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDataSettings(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Export Data'),
          subtitle: const Text('Download your data'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _exportData(context),
        ),
        ListTile(
          leading: const Icon(Icons.upload),
          title: const Text('Import Data'),
          subtitle: const Text('Import previously exported data'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _importData(context),
        ),
        ListTile(
          leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          title: Text(
            'Clear All Data',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          subtitle: const Text('This action cannot be undone'),
          onTap: () => _showClearDataDialog(context),
        ),
      ],
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ThemeSelectionDialog(),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectionDialog(),
    );
  }

  void _exportData(BuildContext context) {
    context.read<SettingsBloc>().add(SettingsExportRequested());
  }

  void _importData(BuildContext context) {
    context.read<SettingsBloc>().add(SettingsImportRequested());
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your data including settings, '
          'transactions, and user preferences. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SettingsBloc>().add(SettingsClearAllRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
```

### Theme Selection Dialog

```dart
// lib/features/settings/widgets/theme_selection_dialog.dart
class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: state.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsBloc>().add(
                      SettingsThemeModeChanged(value),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: state.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsBloc>().add(
                      SettingsThemeModeChanged(value),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                value: ThemeMode.system,
                groupValue: state.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsBloc>().add(
                      SettingsThemeModeChanged(value),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
```

## 🔄 State Management Integration

### Current Settings Bloc

```dart
// lib/features/settings/presentation/bloc/settings_bloc.dart
@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState(
    themeMode: ThemeMode.system,
    analyticsEnabled: true,
    autoBackupEnabled: false,
    notificationsEnabled: true,
  )) {
    on<SettingsLoaded>(_onSettingsLoaded);
    on<SettingsThemeModeChanged>(_onThemeModeChanged);
    on<SettingsLocaleChanged>(_onLocaleChanged);
    on<SettingsNotificationsToggled>(_onNotificationsToggled);
    on<SettingsAnalyticsToggled>(_onAnalyticsToggled);
    on<SettingsBiometricsToggled>(_onBiometricsToggled);
    on<SettingsExportRequested>(_onExportRequested);
    on<SettingsImportRequested>(_onImportRequested);
    on<SettingsClearAllRequested>(_onClearAllRequested);
  }

  Future<void> _onSettingsLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final themeMode = _settingsService.themeMode;
      final locale = _settingsService.locale;
      final notificationsEnabled = _settingsService.notificationsEnabled;
      final analyticsEnabled = _settingsService.analyticsEnabled;
      final biometricsEnabled = await _settingsService.biometricsEnabled;

      emit(state.copyWith(
        themeMode: themeMode,
        locale: locale,
        notificationsEnabled: notificationsEnabled,
        analyticsEnabled: analyticsEnabled,
        biometricsEnabled: biometricsEnabled,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onThemeModeChanged(
    SettingsThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsService.setThemeMode(event.themeMode);
      emit(state.copyWith(themeMode: event.themeMode));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLocaleChanged(
    SettingsLocaleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsService.setLocale(event.locale);
      emit(state.copyWith(locale: event.locale));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onNotificationsToggled(
    SettingsNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsService.setNotificationsEnabled(event.enabled);
      emit(state.copyWith(notificationsEnabled: event.enabled));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAnalyticsToggled(
    SettingsAnalyticsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsService.setAnalyticsEnabled(event.enabled);
      emit(state.copyWith(analyticsEnabled: event.enabled));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onBiometricsToggled(
    SettingsBiometricsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsService.setBiometricsEnabled(event.enabled);
      emit(state.copyWith(biometricsEnabled: event.enabled));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onExportRequested(
    SettingsExportRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      final settings = _settingsService.exportSettings();
      // Implement export logic (e.g., save to file, share)
      
      emit(state.copyWith(
        isLoading: false,
        message: 'Settings exported successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onImportRequested(
    SettingsImportRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      // Implement import logic (e.g., file picker, parse data)
      // await _settingsService.importSettings(importedSettings);
      
      emit(state.copyWith(
        isLoading: false,
        message: 'Settings imported successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onClearAllRequested(
    SettingsClearAllRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      await _settingsService.clearAllSettings();
      
      emit(SettingsState.initial());
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}
```

## 📱 Current Project Status

### What's Implemented

1. **AppSettings Class** - Central settings management with JSON persistence
2. **SettingsBloc** - BLoC pattern for reactive settings updates  
3. **Settings Page** - Full featured settings UI with theme, language, and color options
4. **Biometric Auth** - Budget-specific biometric authentication
5. **Localization** - Multi-language support with easy_localization
6. **Theme Management** - Dynamic theme switching with Material You support

### What's Missing (Compared to Documentation)

1. **Secure Storage** - flutter_secure_storage not implemented
2. **Comprehensive Settings Service** - Using AppSettings instead
3. **Migration System** - No formal migration system
4. **Privacy Settings** - Limited privacy/security settings
5. **Export/Import** - No data export/import functionality

## 🔄 Data Migration

### Potential Migration Service

```dart
// Future implementation - lib/core/services/settings_migration_service.dart
class SettingsMigrationService {
  static const String _versionKey = 'settings_version';
  static const int _currentVersion = 3;

  static Future<void> migrateIfNeeded() async {
    final currentVersion = StorageService.preferences.getInt(_versionKey) ?? 1;
    
    if (currentVersion < _currentVersion) {
      await _performMigration(currentVersion, _currentVersion);
      await StorageService.preferences.setInt(_versionKey, _currentVersion);
    }
  }

  static Future<void> _performMigration(int fromVersion, int toVersion) async {
    for (int version = fromVersion; version < toVersion; version++) {
      switch (version) {
        case 1:
          await _migrateToV2();
          break;
        case 2:
          await _migrateToV3();
          break;
      }
    }
  }

  static Future<void> _migrateToV2() async {
    // Example: Migrate old boolean theme setting to new enum
    final oldTheme = StorageService.preferences.getBool('dark_theme');
    if (oldTheme != null) {
      final newTheme = oldTheme ? ThemeMode.dark : ThemeMode.light;
      await StorageService.preferences.setString('theme_mode', newTheme.name);
      await StorageService.preferences.remove('dark_theme');
    }
  }

  static Future<void> _migrateToV3() async {
    // Example: Move sensitive settings to secure storage
    final pin = StorageService.preferences.getString('user_pin');
    if (pin != null) {
      await StorageService.secureStorage.write(key: 'user_pin', value: pin);
      await StorageService.preferences.remove('user_pin');
    }
  }
}
```

## ✅ Best Practices (Current & Recommended)

### 1. Current Implementation Strengths
- **Unified Settings Management**: AppSettings provides centralized control
- **Type Safety**: Generic get/set methods with type checking
- **Default Handling**: Automatic merge with defaults for new settings
- **State Notification**: Built-in callback system for UI updates
- **JSON Persistence**: Human-readable settings storage

### 2. Recommended Improvements
- **Add Secure Storage**: Implement flutter_secure_storage for sensitive data
- **Validation Layer**: Add input validation for all setting values
- **Migration System**: Implement proper versioning and migration
- **Error Handling**: Better error recovery and user feedback
- **Settings Categories**: Organize settings into logical groups

### 3. Security Considerations
- **Biometric Integration**: Already implemented for budget access
- **Local Authentication**: Available through local_auth package
- **Sensitive Data**: Consider secure storage for future user credentials
- **Validation**: Always validate user inputs before saving

### 4. User Experience
- **Immediate Feedback**: Settings changes apply immediately
- **Visual Indicators**: Clear indication of current settings
- **Accessibility**: Support for screen readers and contrast
- **Localization**: Full internationalization support implemented

### 5. Maintenance
- **Modular Design**: Settings organized by feature area
- **Documentation**: Keep settings documentation updated
- **Testing**: Test settings persistence and state management
- **Backward Compatibility**: Consider upgrade paths for existing users

## 📚 Related Documentation

- [Environment Setup](environment.md) - Environment-specific settings
- [App Configuration](app-config.md) - Global configuration management
- [Secure Storage](../advanced/security.md) - Security best practices
- [State Management](../advanced/architecture.md) - BLoC pattern implementation

## 🔗 Quick Links

- [← Configuration Overview](README.md)
- [→ Environment Setup](environment.md)
- [🏠 Documentation Home](../README.md)
