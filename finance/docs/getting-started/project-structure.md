# 🏗️ Project Structure

Understanding the organization and architecture of the Flutter boilerplate project.

## 📁 High-Level Overview

```
boilerplate/
├── 📱 android/           # Android platform files
├── 🍎 ios/              # iOS platform files  
├── 🌐 web/              # Web platform files
├── 🪟 windows/          # Windows platform files
├── 🐧 linux/            # Linux platform files
├── 🖥️ macos/            # macOS platform files
├── 📦 assets/           # Images, fonts, icons
├── 📚 docs/             # Documentation
├── 🧪 test/             # Unit and widget tests
├── 📄 pubspec.yaml      # Dependencies and metadata
├── 📖 README.md         # Project overview
└── 📂 lib/              # Main Dart source code
    ├── 🚀 main.dart     # App entry point
    ├── 📱 app/          # App configuration
    ├── ⚙️ core/         # Core utilities and services
    ├── 🧩 features/     # Feature modules
    └── 🔄 shared/       # Shared components
```

## 📂 Detailed Structure

### `/lib` - Main Source Code

The heart of your Flutter application:

```
lib/
├── main.dart                 # Application entry point
├── app/                      # App-level configuration
│   ├── app.dart             # Main app widget
│   └── router/              # Navigation and routing
│       ├── app_router.dart  # Go Router configuration
│       └── app_routes.dart  # Route definitions
├── core/                     # Core functionality
│   ├── di/                  # Dependency injection
│   ├── settings/            # App settings management
│   │   └── app_settings.dart
│   ├── theme/               # Theming system
│   │   ├── app_colors.dart  # Color definitions
│   │   ├── app_text_theme.dart # Typography
│   │   ├── app_theme.dart   # Theme configuration
│   │   └── material_you.dart # Material You integration
│   └── utils/               # Utility functions
├── features/                 # Feature modules (Clean Architecture)
│   ├── navigation/          # Bottom navigation feature
│   │   ├── domain/          # Business logic
│   │   │   └── entities/    # Navigation entities
│   │   └── presentation/    # UI layer
│   │       ├── bloc/        # State management
│   │       └── widgets/     # Navigation widgets
│   ├── settings/            # Settings feature
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/
│   └── [your_features]/     # Add your features here
└── shared/                   # Shared components
    └── widgets/             # Reusable UI components
        ├── app_text.dart    # Custom text widget
        └── page_template.dart # Page layout template
```

## 🎯 Architecture Principles

### Clean Architecture

The project follows Clean Architecture principles:

```
📱 Presentation Layer (UI)
    ├── Pages (Screens)
    ├── Widgets (UI Components)  
    └── BLoC (State Management)
           ↓
⚙️ Domain Layer (Business Logic)
    ├── Entities (Data Models)
    ├── Use Cases (Business Rules)
    └── Repositories (Interfaces)
           ↓
💾 Data Layer (External)
    ├── Data Sources (API, Local DB)
    ├── Repositories (Implementations)
    └── Models (Data Transfer Objects)
```

### Feature-Based Organization

Each feature is self-contained:

```
features/my_feature/
├── domain/
│   ├── entities/           # Business objects
│   ├── repositories/       # Abstract interfaces  
│   └── use_cases/         # Business logic
├── data/
│   ├── data_sources/      # API, local storage
│   ├── models/            # Data transfer objects
│   └── repositories/      # Interface implementations
└── presentation/
    ├── bloc/              # State management
    ├── pages/             # Screen widgets
    └── widgets/           # Feature-specific widgets
```

## 📱 Core Components

### 1. App Layer (`/app`)

**Purpose:** Application-level configuration and setup

#### Key Files:
- **`app.dart`** - Main app widget with theme configuration
- **`app_router.dart`** - Navigation routes using Go Router
- **`app_routes.dart`** - Route path constants

```dart
// app/app.dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Boilerplate',
      routerConfig: AppRouter.router,
      // Theme configuration
    );
  }
}
```

### 2. Core Layer (`/core`)

**Purpose:** Fundamental app services and utilities

#### Key Components:

##### Theme System (`/core/theme`)
- **`app_colors.dart`** - Color system with light/dark support
- **`app_text_theme.dart`** - Typography definitions  
- **`material_you.dart`** - Dynamic color support
- **`app_theme.dart`** - Theme configuration

##### Settings (`/core/settings`)
- **`app_settings.dart`** - Persistent user preferences

##### Dependency Injection (`/core/di`)
- Service locator setup
- Provider configuration

### 3. Features Layer (`/features`)

**Purpose:** Business features organized by domain

#### Current Features:

##### Navigation Feature
```
features/navigation/
├── domain/entities/
│   └── navigation_item.dart    # Navigation item model
└── presentation/
    ├── bloc/                   # Navigation state management
    └── widgets/
        ├── adaptive_bottom_navigation.dart
        └── main_shell.dart     # Main app shell
```

##### Settings Feature
```
features/settings/
└── presentation/
    ├── bloc/                   # Settings state management
    └── pages/
        └── settings_page.dart  # Settings UI
```

### 4. Shared Layer (`/shared`)

**Purpose:** Reusable components across features

#### Key Components:
- **`app_text.dart`** - Enhanced text widget with theming
- **`page_template.dart`** - Standardized page layout

## 🎨 Assets Organization

### Asset Structure
```
assets/
├── fonts/                    # Custom fonts
│   ├── AvenirLTStd-Black.otf
│   ├── AvenirLTStd-Roman.otf
│   ├── Inter-Bold.ttf
│   ├── Inter-Regular.ttf
│   └── ... (other fonts)
├── icons/                    # SVG icons for navigation
│   ├── icon_home.svg
│   ├── icon_transactions.svg
│   ├── icon_budget.svg
│   └── icon_more.svg
└── images/                   # App images and graphics
    └── (your images here)
```

### Asset Configuration

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/icons/
    - assets/images/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

## 🧪 Testing Structure

```
test/
├── unit_tests/              # Business logic tests
├── widget_tests/            # UI component tests
├── integration_tests/       # Full app tests
└── test_helpers/           # Test utilities
```

## 📋 Configuration Files

### Key Configuration Files

#### `pubspec.yaml` - Dependencies and Metadata
```yaml
name: boilerplate
description: Flutter boilerplate with advanced theming
version: 1.0.0+1

dependencies:
  flutter:
    sdk: flutter
  go_router: ^latest
  flutter_bloc: ^latest
  # ... other dependencies
```

#### `analysis_options.yaml` - Code Analysis Rules
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
```

## 🔄 Data Flow

### State Management Flow

```
User Action → Widget → BLoC Event → Business Logic → State Change → UI Update
```

### Theme System Flow

```
User Setting → AppSettings → Theme Configuration → Color System → UI Components
```

### Navigation Flow

```
User Tap → Navigation BLoC → Route Change → Go Router → Page Display
```

## 🎯 Adding New Features

### 1. Create Feature Structure

```bash
mkdir -p lib/features/my_feature/{domain,data,presentation}/{entities,repositories,use_cases,bloc,pages,widgets}
```

### 2. Implement Layers

1. **Domain** - Define entities and business rules
2. **Data** - Implement data sources and repositories  
3. **Presentation** - Create UI and state management

### 3. Register Routes

Add routes in `app_router.dart` and `app_routes.dart`

### 4. Add Navigation (if needed)

Update navigation items in the navigation feature

## 🔧 Customization Points

### Easy Customization

1. **Colors** - Edit `core/theme/app_colors.dart`
2. **Typography** - Modify `core/theme/app_text_theme.dart`
3. **Navigation** - Update `features/navigation/`
4. **Settings** - Extend `core/settings/app_settings.dart`

### Advanced Customization

1. **Theme System** - Extend the color and theme system
2. **State Management** - Add new BLoCs or change pattern
3. **Architecture** - Modify the clean architecture setup
4. **Platform** - Add platform-specific implementations

## 📱 Platform-Specific Code

### Android (`/android`)
- Native Android configuration
- Gradle build files
- Android manifest
- Platform channels (if needed)

### iOS (`/ios`)  
- Native iOS configuration
- Xcode project files
- Info.plist configuration
- Platform channels (if needed)

### Web (`/web`)
- HTML entry point
- Web-specific assets
- Service worker configuration

## 🎯 Best Practices

### File Naming
- Use **snake_case** for file names
- Use descriptive names: `user_profile_page.dart`
- Group related files in folders

### Import Organization
```dart
// 1. Dart core libraries
import 'dart:core';

// 2. Flutter libraries  
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:go_router/go_router.dart';

// 4. Internal imports
import '../../../core/theme/app_colors.dart';
```

### Code Organization
- Keep files focused and small (< 300 lines)
- Separate concerns (UI, logic, data)
- Use meaningful variable and function names
- Comment complex business logic

## 🔍 Navigation Guide

### Quick File Finder

Looking for specific functionality?

| Feature | Location |
|---------|----------|
| 🎨 Colors | `core/theme/app_colors.dart` |
| 📝 Text Styles | `shared/widgets/app_text.dart` |
| 🧭 Navigation | `features/navigation/` |
| ⚙️ Settings | `features/settings/` |
| 🚦 Routes | `app/router/` |
| 🎯 Main App | `app/app.dart` |
| 🚀 Entry Point | `main.dart` |

---

**Next:** [Creating Your First Page →](first-page.md)
