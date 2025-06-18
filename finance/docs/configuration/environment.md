# Environment Setup

Comprehensive guide for managing environment-specific configurations, build variants, and deployment settings across development, staging, and production environments.

## 📋 Table of Contents

- [Environment Architecture](#environment-architecture)
- [Build Variants Setup](#build-variants-setup)
- [Configuration Files](#configuration-files)
- [Environment Variables](#environment-variables)
- [Platform-Specific Setup](#platform-specific-setup)
- [Build Scripts](#build-scripts)
- [CI/CD Integration](#cicd-integration)
- [Best Practices](#best-practices)

## 🏗️ Environment Architecture

### Environment Types

```dart
// lib/core/config/environment.dart
enum Environment {
  development,
  staging,
  production;
  
  static Environment get current {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    return Environment.values.firstWhere(
      (e) => e.name == env,
      orElse: () => Environment.development,
    );
  }
  
  bool get isDevelopment => this == Environment.development;
  bool get isStaging => this == Environment.staging;
  bool get isProduction => this == Environment.production;
  
  String get displayName {
    switch (this) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }
  
  String get apiBaseUrl {
    switch (this) {
      case Environment.development:
        return 'https://dev-api.budgetbuddy.com';
      case Environment.staging:
        return 'https://staging-api.budgetbuddy.com';
      case Environment.production:
        return 'https://api.budgetbuddy.com';
    }
  }
  
  String get websocketUrl {
    switch (this) {
      case Environment.development:
        return 'wss://dev-ws.budgetbuddy.com';
      case Environment.staging:
        return 'wss://staging-ws.budgetbuddy.com';
      case Environment.production:
        return 'wss://ws.budgetbuddy.com';
    }
  }
  
  Duration get httpTimeout {
    switch (this) {
      case Environment.development:
        return const Duration(seconds: 30);
      case Environment.staging:
        return const Duration(seconds: 20);
      case Environment.production:
        return const Duration(seconds: 15);
    }
  }
  
  Level get logLevel {
    switch (this) {
      case Environment.development:
        return Level.ALL;
      case Environment.staging:
        return Level.INFO;
      case Environment.production:
        return Level.WARNING;
    }
  }
}
```

### App Configuration

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static Environment get environment => Environment.current;
  
  // API Configuration
  static String get apiBaseUrl => environment.apiBaseUrl;
  static String get websocketUrl => environment.websocketUrl;
  static Duration get httpTimeout => environment.httpTimeout;
  
  // Feature Flags
  static bool get enableLogging => environment.isDevelopment || environment.isStaging;
  static bool get enableDebugMode => environment.isDevelopment;
  static bool get enableCrashlytics => environment.isProduction;
  static bool get enableAnalytics => environment.isProduction;
  
  // App Metadata
  static String get appName {
    switch (environment) {
      case Environment.development:
        return 'Budget Buddy Dev';
      case Environment.staging:
        return 'Budget Buddy Staging';
      case Environment.production:
        return 'Budget Buddy';
    }
  }
  
  static String get bundleId {
    switch (environment) {
      case Environment.development:
        return 'com.budgetbuddy.app.dev';
      case Environment.staging:
        return 'com.budgetbuddy.app.staging';
      case Environment.production:
        return 'com.budgetbuddy.app';
    }
  }
  
  // Database Configuration
  static String get databaseName {
    switch (environment) {
      case Environment.development:
        return 'budget_buddy_dev.db';
      case Environment.staging:
        return 'budget_buddy_staging.db';
      case Environment.production:
        return 'budget_buddy.db';
    }
  }
  
  // Cache Configuration
  static Duration get cacheTimeout {
    switch (environment) {
      case Environment.development:
        return const Duration(minutes: 5);
      case Environment.staging:
        return const Duration(minutes: 15);
      case Environment.production:
        return const Duration(hours: 1);
    }
  }
  
  // Security Configuration
  static bool get enableSSLPinning => environment.isProduction;
  static bool get allowSelfSignedCertificates => environment.isDevelopment;
  
  // Validation
  static void validate() {
    assert(apiBaseUrl.isNotEmpty, 'API base URL cannot be empty');
    assert(websocketUrl.isNotEmpty, 'WebSocket URL cannot be empty');
    assert(bundleId.isNotEmpty, 'Bundle ID cannot be empty');
  }
}
```

## 🔧 Build Variants Setup

### Android Configuration

```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.budgetbuddy.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
    
    buildTypes {
        debug {
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            manifestPlaceholders = [
                appName: "Budget Buddy Dev",
                appIcon: "@mipmap/ic_launcher_dev"
            ]
            buildConfigField "String", "ENVIRONMENT", '"development"'
            buildConfigField "String", "API_BASE_URL", '"https://dev-api.budgetbuddy.com"'
            buildConfigField "boolean", "ENABLE_LOGGING", "true"
        }
        
        staging {
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            manifestPlaceholders = [
                appName: "Budget Buddy Staging",
                appIcon: "@mipmap/ic_launcher_staging"
            ]
            buildConfigField "String", "ENVIRONMENT", '"staging"'
            buildConfigField "String", "API_BASE_URL", '"https://staging-api.budgetbuddy.com"'
            buildConfigField "boolean", "ENABLE_LOGGING", "true"
            signingConfig signingConfigs.debug
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        
        release {
            manifestPlaceholders = [
                appName: "Budget Buddy",
                appIcon: "@mipmap/ic_launcher"
            ]
            buildConfigField "String", "ENVIRONMENT", '"production"'
            buildConfigField "String", "API_BASE_URL", '"https://api.budgetbuddy.com"'
            buildConfigField "boolean", "ENABLE_LOGGING", "false"
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    flavorDimensions "environment"
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
        }
        
        prod {
            dimension "environment"
        }
    }
}
```

### Android Manifest Configuration

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="${appName}"
        android:icon="${appIcon}"
        android:name="${applicationName}">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
              
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <!-- Environment-specific configurations -->
        <meta-data
            android:name="com.budgetbuddy.ENVIRONMENT"
            android:value="${environment}" />
            
        <meta-data
            android:name="com.budgetbuddy.API_BASE_URL"
            android:value="${apiBaseUrl}" />
    </application>
</manifest>
```

### iOS Configuration

```swift
// ios/Runner/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$(APP_NAME)</string>
    
    <key>CFBundleIdentifier</key>
    <string>$(BUNDLE_ID)</string>
    
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    
    <!-- Environment Configuration -->
    <key>ENVIRONMENT</key>
    <string>$(ENVIRONMENT)</string>
    
    <key>API_BASE_URL</key>
    <string>$(API_BASE_URL)</string>
    
    <!-- URL Schemes -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>$(URL_SCHEME)</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>$(URL_SCHEME)</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

```xcconfig
// ios/Runner/Debug.xcconfig
#include "Generated.xcconfig"

APP_NAME = Budget Buddy Dev
BUNDLE_ID = com.budgetbuddy.app.dev
ENVIRONMENT = development
API_BASE_URL = https://dev-api.budgetbuddy.com
URL_SCHEME = budgetbuddy-dev
```

```xcconfig
// ios/Runner/Staging.xcconfig
#include "Generated.xcconfig"

APP_NAME = Budget Buddy Staging
BUNDLE_ID = com.budgetbuddy.app.staging
ENVIRONMENT = staging
API_BASE_URL = https://staging-api.budgetbuddy.com
URL_SCHEME = budgetbuddy-staging
```

```xcconfig
// ios/Runner/Release.xcconfig
#include "Generated.xcconfig"

APP_NAME = Budget Buddy
BUNDLE_ID = com.budgetbuddy.app
ENVIRONMENT = production
API_BASE_URL = https://api.budgetbuddy.com
URL_SCHEME = budgetbuddy
```

## 📁 Configuration Files

### JSON Configuration Files

```json
// assets/config/development/config.json
{
  "environment": "development",
  "api": {
    "baseUrl": "https://dev-api.budgetbuddy.com",
    "timeout": 30000,
    "retryAttempts": 3
  },
  "features": {
    "enableBiometrics": true,
    "enableAnalytics": false,
    "enableCrashReporting": false,
    "enableLogging": true,
    "enableDebugMode": true
  },
  "database": {
    "name": "budget_buddy_dev.db",
    "version": 1
  },
  "cache": {
    "timeout": 300000,
    "maxSize": 50
  },
  "security": {
    "enableSSLPinning": false,
    "allowSelfSignedCertificates": true
  }
}
```

```json
// assets/config/staging/config.json
{
  "environment": "staging",
  "api": {
    "baseUrl": "https://staging-api.budgetbuddy.com",
    "timeout": 20000,
    "retryAttempts": 2
  },
  "features": {
    "enableBiometrics": true,
    "enableAnalytics": true,
    "enableCrashReporting": true,
    "enableLogging": true,
    "enableDebugMode": false
  },
  "database": {
    "name": "budget_buddy_staging.db",
    "version": 1
  },
  "cache": {
    "timeout": 900000,
    "maxSize": 100
  },
  "security": {
    "enableSSLPinning": true,
    "allowSelfSignedCertificates": false
  }
}
```

```json
// assets/config/production/config.json
{
  "environment": "production",
  "api": {
    "baseUrl": "https://api.budgetbuddy.com",
    "timeout": 15000,
    "retryAttempts": 1
  },
  "features": {
    "enableBiometrics": true,
    "enableAnalytics": true,
    "enableCrashReporting": true,
    "enableLogging": false,
    "enableDebugMode": false
  },
  "database": {
    "name": "budget_buddy.db",
    "version": 1
  },
  "cache": {
    "timeout": 3600000,
    "maxSize": 200
  },
  "security": {
    "enableSSLPinning": true,
    "allowSelfSignedCertificates": false
  }
}
```

### Configuration Loader

```dart
// lib/core/config/config_loader.dart
class ConfigLoader {
  static late Map<String, dynamic> _config;
  
  static Future<void> load() async {
    final environment = Environment.current.name;
    final configPath = 'assets/config/$environment/config.json';
    
    try {
      final configString = await rootBundle.loadString(configPath);
      _config = json.decode(configString) as Map<String, dynamic>;
      
      // Validate configuration
      _validateConfig();
    } catch (e) {
      throw ConfigurationException('Failed to load configuration: $e');
    }
  }
  
  static T getValue<T>(String key, {T? defaultValue}) {
    final keys = key.split('.');
    dynamic value = _config;
    
    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        if (defaultValue != null) return defaultValue;
        throw ConfigurationException('Configuration key not found: $key');
      }
    }
    
    if (value is T) {
      return value;
    } else {
      if (defaultValue != null) return defaultValue;
      throw ConfigurationException('Configuration value type mismatch for key: $key');
    }
  }
  
  static String getString(String key, {String? defaultValue}) {
    return getValue<String>(key, defaultValue: defaultValue);
  }
  
  static int getInt(String key, {int? defaultValue}) {
    return getValue<int>(key, defaultValue: defaultValue);
  }
  
  static bool getBool(String key, {bool? defaultValue}) {
    return getValue<bool>(key, defaultValue: defaultValue);
  }
  
  static List<T> getList<T>(String key, {List<T>? defaultValue}) {
    final list = getValue<List<dynamic>>(key, defaultValue: defaultValue?.cast<dynamic>());
    return list?.cast<T>() ?? defaultValue ?? <T>[];
  }
  
  static Map<String, dynamic> getMap(String key, {Map<String, dynamic>? defaultValue}) {
    return getValue<Map<String, dynamic>>(key, defaultValue: defaultValue);
  }
  
  static void _validateConfig() {
    // Validate required configuration keys
    final requiredKeys = [
      'environment',
      'api.baseUrl',
      'database.name',
    ];
    
    for (final key in requiredKeys) {
      try {
        getValue(key);
      } catch (e) {
        throw ConfigurationException('Required configuration key missing: $key');
      }
    }
    
    // Validate environment
    final environment = getString('environment');
    if (!Environment.values.any((e) => e.name == environment)) {
      throw ConfigurationException('Invalid environment: $environment');
    }
    
    // Validate URLs
    final apiBaseUrl = getString('api.baseUrl');
    if (!Uri.tryParse(apiBaseUrl)?.hasAbsolutePath == true) {
      throw ConfigurationException('Invalid API base URL: $apiBaseUrl');
    }
  }
}

class ConfigurationException implements Exception {
  final String message;
  
  const ConfigurationException(this.message);
  
  @override
  String toString() => 'ConfigurationException: $message';
}
```

## 🌍 Environment Variables

### Dart Environment Variables

```dart
// lib/core/config/env_config.dart
class EnvConfig {
  // Environment detection
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev-api.budgetbuddy.com',
  );
  
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );
  
  // Feature Flags
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );
  
  static const bool enableCrashlytics = bool.fromEnvironment(
    'ENABLE_CRASHLYTICS',
    defaultValue: false,
  );
  
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );
  
  // Database Configuration
  static const String databaseUrl = String.fromEnvironment(
    'DATABASE_URL',
    defaultValue: '',
  );
  
  // Third-party Service Keys
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
  
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );
  
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
  
  // Validation
  static void validate() {
    final errors = <String>[];
    
    if (apiBaseUrl.isEmpty) {
      errors.add('API_BASE_URL is required');
    }
    
    if (enableAnalytics && googleMapsApiKey.isEmpty) {
      errors.add('GOOGLE_MAPS_API_KEY is required when analytics is enabled');
    }
    
    if (enableCrashlytics && sentryDsn.isEmpty) {
      errors.add('SENTRY_DSN is required when crash reporting is enabled');
    }
    
    if (errors.isNotEmpty) {
      throw ConfigurationException(
        'Environment validation failed:\n${errors.join('\n')}',
      );
    }
  }
  
  // Debug information
  static Map<String, dynamic> getDebugInfo() {
    return {
      'environment': environment,
      'apiBaseUrl': apiBaseUrl,
      'enableAnalytics': enableAnalytics,
      'enableCrashlytics': enableCrashlytics,
      'enableLogging': enableLogging,
      'hasApiKey': apiKey.isNotEmpty,
      'hasGoogleMapsKey': googleMapsApiKey.isNotEmpty,
      'hasFirebaseProjectId': firebaseProjectId.isNotEmpty,
      'hasSentryDsn': sentryDsn.isNotEmpty,
    };
  }
}
```

### Environment Variable Files

```bash
# .env.development
ENVIRONMENT=development
API_BASE_URL=https://dev-api.budgetbuddy.com
API_KEY=dev_api_key_here
ENABLE_ANALYTICS=false
ENABLE_CRASHLYTICS=false
ENABLE_LOGGING=true
GOOGLE_MAPS_API_KEY=your_dev_google_maps_key
FIREBASE_PROJECT_ID=budgetbuddy-dev
SENTRY_DSN=
```

```bash
# .env.staging
ENVIRONMENT=staging
API_BASE_URL=https://staging-api.budgetbuddy.com
API_KEY=staging_api_key_here
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
ENABLE_LOGGING=true
GOOGLE_MAPS_API_KEY=your_staging_google_maps_key
FIREBASE_PROJECT_ID=budgetbuddy-staging
SENTRY_DSN=your_staging_sentry_dsn
```

```bash
# .env.production
ENVIRONMENT=production
API_BASE_URL=https://api.budgetbuddy.com
API_KEY=production_api_key_here
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
ENABLE_LOGGING=false
GOOGLE_MAPS_API_KEY=your_production_google_maps_key
FIREBASE_PROJECT_ID=budgetbuddy-prod
SENTRY_DSN=your_production_sentry_dsn
```

## 🛠️ Build Scripts

### Flutter Build Scripts

```bash
#!/bin/bash
# scripts/build_android.sh

set -e

ENVIRONMENT=${1:-development}
BUILD_TYPE=${2:-debug}

echo "Building Android app for $ENVIRONMENT environment..."

# Load environment variables
if [ -f ".env.$ENVIRONMENT" ]; then
    export $(cat .env.$ENVIRONMENT | xargs)
fi

# Build Android app
case $BUILD_TYPE in
    debug)
        flutter build apk \
            --debug \
            --dart-define=ENVIRONMENT=$ENVIRONMENT \
            --dart-define=API_BASE_URL=$API_BASE_URL \
            --dart-define=API_KEY=$API_KEY \
            --dart-define=ENABLE_ANALYTICS=$ENABLE_ANALYTICS \
            --dart-define=ENABLE_CRASHLYTICS=$ENABLE_CRASHLYTICS \
            --dart-define=ENABLE_LOGGING=$ENABLE_LOGGING \
            --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY \
            --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
            --dart-define=SENTRY_DSN=$SENTRY_DSN
        ;;
    release)
        flutter build apk \
            --release \
            --dart-define=ENVIRONMENT=$ENVIRONMENT \
            --dart-define=API_BASE_URL=$API_BASE_URL \
            --dart-define=API_KEY=$API_KEY \
            --dart-define=ENABLE_ANALYTICS=$ENABLE_ANALYTICS \
            --dart-define=ENABLE_CRASHLYTICS=$ENABLE_CRASHLYTICS \
            --dart-define=ENABLE_LOGGING=$ENABLE_LOGGING \
            --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY \
            --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
            --dart-define=SENTRY_DSN=$SENTRY_DSN
        ;;
esac

echo "Build completed successfully!"
```

```bash
#!/bin/bash
# scripts/build_ios.sh

set -e

ENVIRONMENT=${1:-development}
BUILD_TYPE=${2:-debug}

echo "Building iOS app for $ENVIRONMENT environment..."

# Load environment variables
if [ -f ".env.$ENVIRONMENT" ]; then
    export $(cat .env.$ENVIRONMENT | xargs)
fi

# Build iOS app
case $BUILD_TYPE in
    debug)
        flutter build ios \
            --debug \
            --dart-define=ENVIRONMENT=$ENVIRONMENT \
            --dart-define=API_BASE_URL=$API_BASE_URL \
            --dart-define=API_KEY=$API_KEY \
            --dart-define=ENABLE_ANALYTICS=$ENABLE_ANALYTICS \
            --dart-define=ENABLE_CRASHLYTICS=$ENABLE_CRASHLYTICS \
            --dart-define=ENABLE_LOGGING=$ENABLE_LOGGING \
            --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY \
            --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
            --dart-define=SENTRY_DSN=$SENTRY_DSN
        ;;
    release)
        flutter build ios \
            --release \
            --dart-define=ENVIRONMENT=$ENVIRONMENT \
            --dart-define=API_BASE_URL=$API_BASE_URL \
            --dart-define=API_KEY=$API_KEY \
            --dart-define=ENABLE_ANALYTICS=$ENABLE_ANALYTICS \
            --dart-define=ENABLE_CRASHLYTICS=$ENABLE_CRASHLYTICS \
            --dart-define=ENABLE_LOGGING=$ENABLE_LOGGING \
            --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY \
            --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
            --dart-define=SENTRY_DSN=$SENTRY_DSN
        ;;
esac

echo "Build completed successfully!"
```

### Package.json Scripts

```json
{
  "scripts": {
    "build:dev:android": "./scripts/build_android.sh development debug",
    "build:staging:android": "./scripts/build_android.sh staging release",
    "build:prod:android": "./scripts/build_android.sh production release",
    "build:dev:ios": "./scripts/build_ios.sh development debug",
    "build:staging:ios": "./scripts/build_ios.sh staging release",
    "build:prod:ios": "./scripts/build_ios.sh production release",
    "run:dev": "flutter run --dart-define-from-file=.env.development",
    "run:staging": "flutter run --dart-define-from-file=.env.staging",
    "test:unit": "flutter test",
    "test:integration": "flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart",
    "analyze": "flutter analyze",
    "format": "dart format .",
    "clean": "flutter clean && flutter pub get"
  }
}
```

## 🚀 CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/build_and_deploy.yml
name: Build and Deploy

on:
  push:
    branches: [main, develop, staging]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Analyze code
        run: flutter analyze

  build_android:
    needs: test
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [development, staging, production]
    
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Setup environment variables
        run: |
          echo "ENVIRONMENT=${{ matrix.environment }}" >> $GITHUB_ENV
          echo "API_BASE_URL=${{ secrets[format('API_BASE_URL_{0}', upper(matrix.environment))] }}" >> $GITHUB_ENV
          echo "API_KEY=${{ secrets[format('API_KEY_{0}', upper(matrix.environment))] }}" >> $GITHUB_ENV
      
      - name: Build Android APK
        run: |
          flutter build apk \
            --release \
            --dart-define=ENVIRONMENT=${{ matrix.environment }} \
            --dart-define=API_BASE_URL=${{ env.API_BASE_URL }} \
            --dart-define=API_KEY=${{ env.API_KEY }}
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: apk-${{ matrix.environment }}
          path: build/app/outputs/flutter-apk/app-release.apk

  build_ios:
    needs: test
    runs-on: macos-latest
    strategy:
      matrix:
        environment: [development, staging, production]
    
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Setup environment variables
        run: |
          echo "ENVIRONMENT=${{ matrix.environment }}" >> $GITHUB_ENV
          echo "API_BASE_URL=${{ secrets[format('API_BASE_URL_{0}', upper(matrix.environment))] }}" >> $GITHUB_ENV
          echo "API_KEY=${{ secrets[format('API_KEY_{0}', upper(matrix.environment))] }}" >> $GITHUB_ENV
      
      - name: Build iOS
        run: |
          flutter build ios \
            --release \
            --no-codesign \
            --dart-define=ENVIRONMENT=${{ matrix.environment }} \
            --dart-define=API_BASE_URL=${{ env.API_BASE_URL }} \
            --dart-define=API_KEY=${{ env.API_KEY }}
      
      - name: Upload iOS build
        uses: actions/upload-artifact@v3
        with:
          name: ios-${{ matrix.environment }}
          path: build/ios/iphoneos/
```

## ✅ Best Practices

### 1. Configuration Management
- Separate configurations by environment
- Use version control for configuration files
- Validate configurations at startup
- Document all configuration options

### 2. Security
- Never commit sensitive data to version control
- Use environment variables for secrets
- Implement proper secret rotation
- Use secure storage for production keys

### 3. Deployment
- Automate build processes
- Use consistent naming conventions
- Implement proper versioning
- Test configurations in staging

### 4. Monitoring
- Log configuration loading
- Monitor environment-specific metrics
- Implement health checks
- Track deployment success rates

## 🔧 Troubleshooting

### Common Issues

**Configuration not loading**
- Check file paths and names
- Verify JSON syntax
- Ensure proper environment detection

**Environment variables not working**
- Check variable names and values
- Verify build script configuration
- Test variable substitution

**Build variants failing**
- Check platform-specific configuration
- Verify signing certificates
- Test with clean builds

## 📚 Related Documentation

- [Settings Management](settings.md) - User preferences and app settings
- [App Configuration](app-config.md) - Global configuration management
- [Security Best Practices](../advanced/security.md) - Security guidelines
- [Deployment Guide](../advanced/deployment.md) - Deployment processes

## 🔗 Quick Links

- [← Settings Management](settings.md)
- [→ App Configuration](app-config.md)
- [🏠 Documentation Home](../README.md)
