# 📥 Installation & Setup

Get your Flutter boilerplate project up and running in minutes.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software
- **Flutter SDK** 3.16.0 or higher
- **Dart** 3.2.0 or higher
- **Git** for version control

### Development Environment
Choose one of the following:
- **Android Studio** with Flutter plugin
- **Visual Studio Code** with Flutter extension
- **IntelliJ IDEA** with Flutter plugin

### Platform-Specific Requirements

#### Android Development
- **Android SDK** (API level 21 or higher)
- **Android SDK Tools**
- **Java Development Kit (JDK)** 8 or higher

#### iOS Development (macOS only)
- **Xcode** 12.0 or higher
- **iOS Simulator** or physical iOS device
- **CocoaPods** for dependency management

#### Web Development
- **Chrome** browser for debugging
- No additional setup required

## 🚀 Quick Start

### 1. Clone the Repository

```bash
# Clone the project
git clone <your-repository-url>
cd boilerplate

# Or download as ZIP and extract
```

### 2. Install Dependencies

```bash
# Get Flutter packages
flutter pub get

# For iOS (macOS only)
cd ios && pod install && cd ..
```

### 3. Verify Installation

```bash
# Check Flutter setup
flutter doctor

# Run tests to ensure everything works
flutter test
```

### 4. Run the App

```bash
# Run on connected device/emulator
flutter run

# Or specify platform
flutter run -d chrome          # Web
flutter run -d ios             # iOS Simulator
flutter run -d android         # Android Emulator
```

## 🔧 Detailed Setup

### Flutter SDK Setup

If you don't have Flutter installed:

#### Windows
```bash
# Download Flutter from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\flutter
# Add C:\flutter\bin to your PATH environment variable

# Verify installation
flutter --version
```

#### macOS
```bash
# Using Homebrew (recommended)
brew install --cask flutter

# Or download from https://flutter.dev/docs/get-started/install/macos
# Verify installation
flutter --version
```

#### Linux
```bash
# Download from https://flutter.dev/docs/get-started/install/linux
# Extract and add to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter --version
```

### IDE Setup

#### Visual Studio Code
1. Install the [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
2. Install the [Dart extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
3. Restart VS Code

#### Android Studio
1. Install [Flutter plugin](https://plugins.jetbrains.com/plugin/9212-flutter)
2. Install [Dart plugin](https://plugins.jetbrains.com/plugin/6351-dart)
3. Restart Android Studio

### Device Setup

#### Android
```bash
# Create and start an emulator
flutter emulators --launch <emulator_id>

# Or connect a physical device with USB debugging enabled
flutter devices
```

#### iOS (macOS only)
```bash
# Open iOS Simulator
open -a Simulator

# Or connect a physical device
flutter devices
```

## ⚙️ Project Configuration

### 1. App Configuration

Edit the app configuration files:

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String appName = 'Your App Name';
  static const String packageName = 'com.yourcompany.yourapp';
  static const String version = '1.0.0';
}
```

### 2. Package Name

Update the package name in:

#### Android
```gradle
// android/app/build.gradle.kts
android {
    namespace = "com.yourcompany.yourapp"
    // ...
}
```

#### iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleIdentifier</key>
<string>com.yourcompany.yourapp</string>
```

### 3. App Icons and Splash Screen

Replace default assets in:
- `assets/images/` - App images and logos
- `assets/icons/` - Navigation and UI icons
- Platform-specific icon folders

### 4. Environment Variables

Create environment configuration:

```dart
// lib/core/config/environment.dart
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment get currentEnvironment {
    // Configure based on your needs
    return Environment.development;
  }
  
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return 'https://dev-api.yourapp.com';
      case Environment.staging:
        return 'https://staging-api.yourapp.com';
      case Environment.production:
        return 'https://api.yourapp.com';
    }
  }
}
```

## 🎨 Initial Customization

### 1. Theme Colors

Customize your app's primary colors:

```dart
// In your main app or settings
await AppSettings.setAccentColor(Colors.purple);
```

### 2. App Name and Title

```dart
// lib/app/app.dart
MaterialApp.router(
  title: 'Your App Name',
  // ...
)
```

### 3. Default Settings

```dart
// lib/core/settings/app_settings.dart
static Map<String, dynamic> _getDefaultSettings() {
  return {
    'themeMode': 'system',
    'accentColor': '0xFF6200EE', // Your brand color
    'font': 'Inter', // Your preferred font
    // ... other defaults
  };
}
```

## 🔍 Verification

### Run Checks

```bash
# Verify everything is working
flutter doctor -v

# Check for any issues
flutter analyze

# Run tests
flutter test

# Build for release (optional)
flutter build apk --debug  # Android
flutter build ios --debug  # iOS
```

### Common Issues and Solutions

#### Issue: "Flutter command not found"
```bash
# Solution: Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

#### Issue: "Android SDK not found"
```bash
# Solution: Set ANDROID_HOME environment variable
export ANDROID_HOME=/path/to/android/sdk
```

#### Issue: "CocoaPods not installed" (iOS)
```bash
# Solution: Install CocoaPods
sudo gem install cocoapods
```

#### Issue: "Gradle build failed"
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📱 First Run

When you first run the app, you'll see:

1. **Home Screen** - Main dashboard with navigation
2. **Theme Selection** - Light/Dark mode toggle
3. **Settings Page** - Customize colors and preferences
4. **Navigation Bar** - Bottom navigation with customizable items

## 🎯 Next Steps

Now that your app is running:

1. **[Understand Project Structure](project-structure.md)** - Learn how the code is organized
2. **[Create Your First Page](first-page.md)** - Add a new feature
3. **[Explore Components](../components/app-text.md)** - Learn about custom widgets

## 🆘 Troubleshooting

### Getting Help

If you encounter issues:

1. **Check Flutter Doctor**: `flutter doctor -v`
2. **Read Error Messages**: Often contain helpful hints
3. **Search Documentation**: Use Ctrl+F to find specific topics
4. **Check GitHub Issues**: See if others had similar problems
5. **Ask for Help**: Create an issue with detailed information

### Useful Commands

```bash
# Clean project
flutter clean

# Upgrade Flutter
flutter upgrade

# Check connected devices
flutter devices

# Get packages
flutter pub get

# Run with verbose logging
flutter run -v

# Build for production
flutter build apk --release
flutter build ios --release
```

---

**Next:** [Project Structure →](project-structure.md)
