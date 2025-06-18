# Configuration System

Complete configuration management system for app settings, environment variables, and user preferences.

## 📚 Configuration Guides

### ⚙️ [Settings Management](settings.md)
User preferences, app settings, and configuration persistence with SharedPreferences and secure storage.

### 🌍 [Environment Setup](environment.md)
Environment-specific configurations, build variants, and deployment settings for development, staging, and production.

### 📱 [App Configuration](app-config.md)
Global app configuration, feature flags, remote config, and runtime configuration management.

## 🎯 Quick Start

### Basic Settings Setup

```dart
// 1. Install dependencies
flutter pub add shared_preferences
flutter pub add flutter_secure_storage

// 2. Create settings service
class SettingsService {
  static const String _themeKey = 'theme_mode';
  
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }
  
  Future<void> setThemeMode(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }
}

// 3. Use in app
final settingsService = SettingsService();
final themeMode = await settingsService.getThemeMode();
```

### Environment Configuration

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isProduction => _environment == 'production';
  
  static String get apiBaseUrl {
    switch (_environment) {
      case 'production':
        return 'https://api.myapp.com';
      case 'staging':
        return 'https://staging-api.myapp.com';
      default:
        return 'https://dev-api.myapp.com';
    }
  }
}
```

## 🎨 Configuration Patterns

### Settings Screen

```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Choose app theme'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeSelector(context),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('Change app language'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageSelector(context),
          ),
        ],
      ),
    );
  }
}
```

### Feature Flags

```dart
class FeatureFlags {
  static const bool enableBiometrics = bool.fromEnvironment(
    'ENABLE_BIOMETRICS',
    defaultValue: true,
  );
  
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );
  
  static bool get isNewFeatureEnabled {
    return RemoteConfig.getBool('new_feature_enabled');
  }
}
```

## 🔐 Secure Configuration

### Sensitive Data Storage

```dart
class SecureStorage {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

### API Keys Management

```dart
class ApiKeys {
  static const String googleMapsKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
  
  static const String firebaseKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );
  
  static void validateKeys() {
    assert(googleMapsKey.isNotEmpty, 'Google Maps API key is required');
    assert(firebaseKey.isNotEmpty, 'Firebase API key is required');
  }
}
```

## 🌍 Multi-Environment Support

### Build Configuration

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/config/
    - assets/config/dev/
    - assets/config/prod/
```

```dart
// lib/core/config/environment_config.dart
class EnvironmentConfig {
  static late Map<String, dynamic> _config;
  
  static Future<void> load() async {
    final env = AppConfig.environment;
    final configFile = 'assets/config/$env/config.json';
    
    final configString = await rootBundle.loadString(configFile);
    _config = json.decode(configString);
  }
  
  static String get apiUrl => _config['api_url'];
  static bool get enableLogging => _config['enable_logging'] ?? false;
  static Map<String, dynamic> get features => _config['features'] ?? {};
}
```

## 📱 User Preferences

### Theme Preferences

```dart
class ThemePreferences {
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';
  
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeModeKey) ?? 'system';
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == themeName,
      orElse: () => ThemeMode.system,
    );
  }
  
  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }
  
  static Future<Color?> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_primaryColorKey);
    return colorValue != null ? Color(colorValue) : null;
  }
  
  static Future<void> setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
  }
}
```

### Language Preferences

```dart
class LanguagePreferences {
  static const String _languageKey = 'language_code';
  
  static Future<Locale?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    return languageCode != null ? Locale(languageCode) : null;
  }
  
  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }
}
```

## 🔧 Configuration Services

### Settings Service

```dart
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();
  
  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage();
  }
  
  // Theme settings
  ThemeMode get themeMode {
    final themeName = _prefs.getString('theme_mode') ?? 'system';
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == themeName,
      orElse: () => ThemeMode.system,
    );
  }
  
  set themeMode(ThemeMode mode) {
    _prefs.setString('theme_mode', mode.name);
  }
  
  // Notification settings
  bool get notificationsEnabled => _prefs.getBool('notifications_enabled') ?? true;
  set notificationsEnabled(bool enabled) => _prefs.setBool('notifications_enabled', enabled);
  
  // Privacy settings
  bool get analyticsEnabled => _prefs.getBool('analytics_enabled') ?? false;
  set analyticsEnabled(bool enabled) => _prefs.setBool('analytics_enabled', enabled);
  
  // Security settings
  Future<bool> get biometricsEnabled async {
    final value = await _secureStorage.read(key: 'biometrics_enabled');
    return value == 'true';
  }
  
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _secureStorage.write(key: 'biometrics_enabled', value: enabled.toString());
  }
}
```

## 🎛️ Runtime Configuration

### Remote Config

```dart
class RemoteConfigService {
  static FirebaseRemoteConfig? _remoteConfig;
  
  static Future<void> init() async {
    _remoteConfig = FirebaseRemoteConfig.instance;
    
    await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    
    await _remoteConfig!.setDefaults({
      'feature_new_ui': false,
      'max_file_size': 10485760, // 10MB
      'supported_file_types': 'jpg,png,pdf',
    });
    
    await _remoteConfig!.fetchAndActivate();
  }
  
  static bool getBool(String key) {
    return _remoteConfig?.getBool(key) ?? false;
  }
  
  static int getInt(String key) {
    return _remoteConfig?.getInt(key) ?? 0;
  }
  
  static String getString(String key) {
    return _remoteConfig?.getString(key) ?? '';
  }
}
```

## ⚡ Performance Optimization

### Configuration Caching

```dart
class ConfigCache {
  static final Map<String, dynamic> _cache = {};
  static Timer? _refreshTimer;
  
  static void set(String key, dynamic value, {Duration? ttl}) {
    _cache[key] = {
      'value': value,
      'expires': ttl != null ? DateTime.now().add(ttl) : null,
    };
  }
  
  static T? get<T>(String key) {
    final cached = _cache[key];
    if (cached == null) return null;
    
    final expires = cached['expires'] as DateTime?;
    if (expires != null && DateTime.now().isAfter(expires)) {
      _cache.remove(key);
      return null;
    }
    
    return cached['value'] as T?;
  }
  
  static void startRefreshTimer(Duration interval) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) => _cleanExpired());
  }
  
  static void _cleanExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) {
      final expires = value['expires'] as DateTime?;
      return expires != null && now.isAfter(expires);
    });
  }
}
```

## ✅ Best Practices

### 1. Security
- Store sensitive data in secure storage
- Validate configuration values
- Use environment variables for secrets
- Implement proper key rotation

### 2. Performance
- Cache frequently accessed settings
- Lazy load configuration
- Minimize I/O operations
- Use efficient storage formats

### 3. Maintainability
- Organize settings by category
- Use type-safe access methods
- Document configuration options
- Implement configuration validation

### 4. User Experience
- Provide sensible defaults
- Make settings discoverable
- Implement real-time updates
- Support configuration export/import

## 🔧 Troubleshooting

### Common Issues

**Settings not persisting**
- Check SharedPreferences initialization
- Verify write permissions
- Ensure proper async handling

**Environment variables not loading**
- Check build configuration
- Verify environment setup
- Test with different build modes

**Secure storage issues**
- Check platform permissions
- Verify keychain/keystore access
- Handle biometric authentication

## 📚 Related Documentation

- [Getting Started](../getting-started/README.md) - Initial setup
- [Advanced Topics](../advanced/README.md) - Security and performance
- [API Reference](../api/README.md) - Configuration APIs
- [Navigation](../navigation/README.md) - Navigation settings

## 🔗 Quick Links

- [⚙️ Settings Management](settings.md) - User preferences
- [🌍 Environment Setup](environment.md) - Environment config
- [📱 App Configuration](app-config.md) - Global settings
- [🏠 Documentation Home](../README.md)
