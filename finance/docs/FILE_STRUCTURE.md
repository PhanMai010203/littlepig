# 📱 Finance App - File Structure Documentation

This Flutter application follows **Clean Architecture** principles with a clear separation of concerns across Presentation, Domain, and Data layers.

## 🏗️ Architecture Overview

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

## 📁 File Structure

### 🚀 Root Entry Point
```
lib/
├── main.dart                           # App entry point - initializes dependencies, settings, localization
├── demo/                              # Demo and example code
│   └── currency_demo.dart            # Currency system demonstration
└── tmp/                               # Temporary files and development resources
    ├── currencies.json               # Currency data (54KB)
    ├── currenciesInfo.json           # Currency information data (28KB)
    ├── currenciesInfo2.json          # Additional currency data (22KB)
    └── ONLY_FOR_TEMPORARY_FILE_ONLY  # Placeholder file
```
**Summary**: Main application entry point that initializes the Flutter app, sets up dependency injection, localization, Material You theming, and Bloc observers. Includes demo code and temporary development resources.

---

### 📱 App Configuration Layer
```
lib/app/
├── app.dart                           # Main app widget with theme and routing setup
└── router/                            # Navigation configuration
    ├── app_router.dart               # GoRouter setup with enhanced page transitions
    ├── app_routes.dart               # Route constants and path definitions
    └── page_transitions.dart         # Phase 4: Page transition framework with platform-aware animations
```
**Summary**: Contains the main app configuration including routing setup using GoRouter, theme management, and app-level state providers.

---

### ⚙️ Core Layer (Infrastructure & Shared Services)
```
lib/core/
├── database/                          # Database layer (Drift/SQLite)
│   ├── app_database.dart             # Main database class with table definitions and migrations
│   ├── app_database.g.dart           # Generated Drift database code
│   └── tables/                       # Database table definitions
│       ├── financial_tables.dart     # Combined financial table definitions
│       ├── transactions_table.dart   # Transaction table schema
│       ├── categories_table.dart     # Category table schema
│       ├── budgets_table.dart        # Budget table schema
│       ├── accounts_table.dart       # Account table schema
│       ├── attachments_table.dart    # Attachment/file table schema
│       └── sync_metadata_table.dart  # Sync metadata for cloud synchronization
├── services/                         # Core service layer
│   ├── database_service.dart         # Database service abstraction
│   ├── file_picker_service.dart      # File selection and attachment processing service
│   ├── cache_management_service.dart # Local file cache management service
│   ├── database_cache_service.dart # Phase 2: In-memory cache for database queries
│   ├── platform_service.dart        # Platform detection, device capabilities, and high refresh rate management service
│   ├── dialog_service.dart          # Dialog and popup service (Phase 3)
│   └── animation_performance_service.dart # Phase 6: Advanced animation performance optimization and monitoring service
├── sync/                             # Cloud synchronization services (Phase 5A)
│   ├── sync_service.dart            # Legacy sync service interface
│   ├── incremental_sync_service.dart # Event-driven sync service (Phase 4)
│   ├── enhanced_incremental_sync_service.dart # Phase 5A enhanced sync service
│   ├── event_processor.dart         # Phase 5A event processing engine
│   ├── sync_state_manager.dart      # Phase 5A sync state and progress tracking
│   ├── crdt_conflict_resolver.dart  # CRDT-based conflict resolution
│   ├── sync_event.dart             # Event sourcing data structures
│   ├── google_drive_sync_service.dart # Google Drive sync implementation
│   ├── interfaces/                  # Team A/B interface contracts
│   │   └── sync_interfaces.dart    # Shared sync service interfaces
│   └── migrations/                  # Database schema migrations
│       └── schema_cleanup_migration.dart # Phase 4 schema cleanup
├── utils/                            # Core utilities
│   └── bloc_observer.dart           # BLoC observer for debugging and logging
├── theme/                            # App theming system
│   ├── app_theme.dart               # Main theme definitions (light/dark)
│   ├── app_colors.dart              # Color constants and Material You colors
│   ├── app_text_theme.dart          # Typography definitions
│   └── material_you.dart            # Material You dynamic color implementation
├── settings/                         # App settings management
│   └── app_settings.dart            # SharedPreferences-based settings manager
├── constants/                        # App constants and default data
│   └── default_categories.dart      # Default financial categories with emojis
└── di/                              # Dependency Injection
    ├── injection.dart               # GetIt service locator configuration
    └── injection.config.dart        # Generated dependency injection configuration
```
**Summary**: Core infrastructure layer containing database setup with Drift ORM, file management and attachment services, **Phase 5A advanced sync services** with event sourcing and real-time capabilities, **Phase 6.1 animation performance optimization**, platform detection with high refresh rate management for optimal display performance, theming system with Material You support, dependency injection setup, and shared utilities.

---

### 🎯 Features Layer (Business Features)
```
lib/features/
├── home/                             # Home screen feature
│   ├── presentation/                 # UI layer
│   │   └── pages/
│   │       └── home_page.dart       # Main dashboard page
│   └── widgets/                      # Home-specific widgets
│       └── home_page_username.dart   # Username display widget
├── transactions/                     # Transaction management feature
│   ├── domain/                       # Business logic layer
│   │   ├── entities/
│   │   │   ├── transaction.dart     # Transaction entity/model
│   │   │   └── attachment.dart      # Attachment entity with Google Drive integration
│   │   ├── repositories/
│   │   │   ├── transaction_repository.dart # Transaction repository interface
│   │   │   └── attachment_repository.dart # Attachment repository interface
│   │   └── usecases/                # Business use cases
│   │       ├── get_transactions.dart # Transaction retrieval use cases
│   │       └── manage_transactions.dart # Transaction management use cases
│   ├── data/                        # Data access layer
│   │   └── repositories/
│   │       ├── transaction_repository_impl.dart # Transaction repository implementation
│   │       └── attachment_repository_impl.dart # Attachment repository implementation
│   └── presentation/                # UI layer
│       ├── pages/
│       │   └── transactions_page.dart # Transaction list/management page
│       └── bloc/                    # State management
│           ├── transactions_event.dart # Transaction events
│           └── transactions_state.dart # Transaction states
├── budgets/                         # Budget management feature
│   ├── domain/                      # Business logic layer
│   │   ├── entities/
│   │   │   └── budget.dart          # Budget entity/model
│   │   └── repositories/
│   │       └── budget_repository.dart # Budget repository interface
│   ├── data/                        # Data access layer
│   │   └── repositories/
│   │       └── budget_repository_impl.dart # Budget repository implementation
│   └── presentation/                # UI layer
│       └── pages/
│           └── budgets_page.dart    # Budget management page
├── accounts/                        # Account management feature
│   ├── domain/                      # Business logic layer
│   │   ├── entities/
│   │   │   └── account.dart         # Account entity/model
│   │   └── repositories/
│   │       └── account_repository.dart # Account repository interface
│   └── data/                        # Data access layer
│       └── repositories/
│           └── account_repository_impl.dart # Account repository implementation
├── categories/                      # Category management feature
│   ├── domain/                      # Business logic layer
│   │   ├── entities/
│   │   │   └── category.dart        # Category entity/model
│   │   └── repositories/
│   │       └── category_repository.dart # Category repository interface
│   └── data/                        # Data access layer
│       └── repositories/
│           └── category_repository_impl.dart # Category repository implementation
├── currencies/                      # Currency and exchange rate feature
│   ├── domain/                      # Business logic layer
│   │   ├── entities/
│   │   │   ├── currency.dart        # Currency entity with formatting
│   │   │   └── exchange_rate.dart   # Exchange rate entity
│   │   ├── repositories/
│   │   │   └── currency_repository.dart # Currency repository interface
│   │   └── usecases/
│   │       └── get_currencies.dart  # Currency retrieval use cases
│   └── data/                        # Data access layer
│       ├── repositories/
│       │   └── currency_repository_impl.dart # Currency repository implementation
│       ├── datasources/             # Data sources
│       │   ├── currency_local_data_source.dart # Local currency data
│       │   ├── exchange_rate_local_data_source.dart # Local exchange rates
│       │   └── exchange_rate_remote_data_source.dart # Remote exchange API
│       └── models/                  # Data transfer objects
│           ├── currency_model.dart  # Currency data model
│           └── exchange_rate_model.dart # Exchange rate data model
├── navigation/                      # Navigation feature (Enhanced in Phase 5)
│   ├── domain/                      # Navigation entities
│   │   └── entities/                # Navigation-related entities
│   │       └── navigation_item.dart # Navigation item entity with customization support
│   └── presentation/                # Navigation UI components
│       ├── widgets/                 # Navigation widgets
│       │   ├── adaptive_bottom_navigation.dart # Bottom navigation bar with TappableWidget integration
│       │   ├── main_shell.dart      # Main app shell wrapper with PopupFramework integration
│       │   └── navigation_customization_content.dart # Phase 5: Custom dialog content for navigation customization
│       └── bloc/                    # Navigation state management
│           ├── navigation_bloc.dart # Navigation BLoC
│           ├── navigation_event.dart # Navigation events
│           ├── navigation_state.dart # Navigation states
│           └── navigation_bloc.freezed.dart # Generated freezed code
├── settings/                        # Settings feature
│   └── presentation/                # Settings UI
│       ├── pages/                   # Settings pages
│       └── bloc/                    # Settings state management
│           └── settings_bloc.dart   # Settings BLoC
└── more/                           # More/additional features page
    └── presentation/                # More page UI
```
**Summary**: Feature modules organized by business domain, each following clean architecture with domain (entities, repositories, use cases), data (repository implementations, data sources), and presentation (UI, BLoC) layers. Includes comprehensive attachment management with Google Drive integration and multi-currency support.

---

### 🔧 Services Layer (Business Services)
```
lib/services/
└── finance_service.dart              # Example service demonstrating repository usage
```
**Summary**: High-level business services that orchestrate multiple repositories and demonstrate usage patterns for the finance app's core functionality.

---

### 🛠️ Shared Layer (Reusable Components)
```
lib/shared/
├── widgets/                          # Reusable UI components
│   ├── animations/                   # Comprehensive animation framework (Phase 1-6)
│   │   ├── animation_utils.dart     # Core animation utilities with performance optimization
│   │   ├── fade_in.dart             # Fade entrance animation
│   │   ├── scale_in.dart            # Scale entrance animation with elastic curves
│   │   ├── slide_in.dart            # Directional slide animations
│   │   ├── bouncing_widget.dart     # Elastic bouncing effects
│   │   ├── breathing_widget.dart    # Pulsing scale animations
│   │   ├── animated_expanded.dart   # Smooth expand/collapse with fade
│   │   ├── animated_size_switcher.dart # Content switching with size transitions
│   │   ├── scaled_animated_switcher.dart # Scale + fade content switching
│   │   ├── slide_fade_transition.dart # Combined slide and fade effects
│   │   ├── tappable_widget.dart     # Tap response with customizable feedback (Enhanced in Phase 5)
│   │   ├── shake_animation.dart     # Horizontal shake effects for errors
│   │   └── animated_scale_opacity.dart # Combined scale and opacity changes
│   │   └── animation_performance_monitor.dart # Real-time performance monitor widget
│   ├── app_lifecycle_manager.dart   # App lifecycle manager for handling resume/pause events and high refresh rate
│   ├── dialogs/                      # Reusable dialog framework (Phase 3)
│   │   ├── popup_framework.dart     # Reusable popup template with Material 3 design
│   │   └── bottom_sheet_service.dart # Smart bottom sheets with snapping and options
│   ├── transitions/                  # Page transition components (Phase 4)
│   │   └── open_container_navigation.dart # Material 3 OpenContainer navigation components
│   ├── app_text.dart                # Custom text widgets with theming
│   ├── page_template.dart           # Common page layout template (Enhanced in Phase 5 with FadeIn and AnimatedSwitcher)
│   └── language_selector.dart       # Language selection widget
└── utils/                           # Shared utilities (currently empty)
```
**Summary**: Shared components and utilities that can be used across multiple features, including a comprehensive animation and dialog framework, reusable widgets, and common utilities.

---

## 🎨 Key Architecture Patterns

### 🏛️ Clean Architecture Implementation
- **Domain Layer**: Pure business logic with entities and repository interfaces
- **Data Layer**: External concerns like database access and API calls
- **Presentation Layer**: UI components and state management with BLoC

### 🗄️ Database Architecture
- **Drift ORM**: Type-safe SQL database access
- **Table Definitions**: Separate files for each entity table
- **Migration Support**: Schema versioning and data migration
- **Sync Metadata**: Cloud synchronization tracking

### 🎨 Theming System
- **Material You**: Dynamic color generation from system
- **Light/Dark Themes**: Comprehensive theme switching
- **Custom Typography**: Consistent text styling across the app
- **Color Management**: Centralized color constants

### 🔄 State Management
- **BLoC Pattern**: Business Logic Components for state management
- **Freezed**: Immutable state and event classes
- **Stream-based**: Reactive state updates

### 🔗 Dependency Injection
- **GetIt**: Service locator pattern
- **Injectable**: Code generation for DI setup
- **Repository Pattern**: Abstracted data access

### 🌐 Localization
- **EasyLocalization**: Multi-language support (English, Vietnamese)
- **Asset-based**: Translation files in assets folder

### 📱 High Refresh Rate Display
- **Android Support**: Uses flutter_displaymode package for high refresh rate on supported devices
- **iOS Support**: Configured with CADisableMinimumFrameDurationOnPhone in Info.plist
- **Lifecycle Management**: Automatically sets high refresh rate on app startup and resume
- **Platform Detection**: Smart detection of device capabilities and platform-specific handling

### ☁️ Cloud Synchronization
- **Google Drive**: Cloud storage for data backup and file attachments
- **Conflict Resolution**: Sync metadata for data consistency
- **Device Management**: Multi-device data synchronization
- **File Upload**: Automatic attachment upload to Google Drive
- **Authentication**: Google Sign-In integration for cloud access

### 📁 File Management & Attachments
- **Attachment System**: Complete file management with Google Drive integration
- **Image Processing**: Automatic compression for camera-captured images
- **Cache Management**: Smart local caching with 30-day expiry for camera images
- **File Types**: Support for images, documents, and other file types
- **Cloud Storage**: Seamless Google Drive upload and sharing

### 💱 Currency System
- **Multi-Currency**: Support for global currencies with exchange rates
- **Currency Formatting**: Native symbol display and proper decimal handling
- **Exchange Rates**: Local and remote data sources for real-time rates
- **Country Integration**: Flag and country information for currencies

## 📊 Feature Completeness
- ✅ **Home Dashboard**: Overview of financial data
- ✅ **Transaction Management**: CRUD operations with attachment support
- ✅ **Attachment System**: File management with Google Drive integration
- ✅ **Category System**: Expense and income categorization with emoji icons
- ✅ **Account Management**: Multiple account support with balance tracking
- ✅ **Budget Tracking**: Budget creation and monitoring
- ✅ **Currency Support**: Multi-currency with exchange rate handling
- ✅ **Navigation**: Bottom navigation with adaptive design
- ✅ **Settings**: App configuration and preferences with enhanced animation controls
- ✅ **Cloud Sync**: Google Drive integration with conflict resolution
- ✅ **File Management**: Camera, gallery, and file picker integration
- ✅ **Cache Management**: Smart local file caching system
- ✅ **Theming**: Material You and custom themes
- ✅ **Localization**: Multi-language support (English, Vietnamese)
- ✅ **Use Cases**: Business logic abstraction layer
- ✅ **State Management**: Comprehensive BLoC implementation
- ✅ **Animation Framework**: Phase 1-6 - Complete animation and dialog framework with performance optimization.

### 🎬 Animation Framework (All Phases Complete)
- **Platform Detection**: Comprehensive platform and device capability detection
- **Animation Settings**: Enhanced user preferences with granular animation controls  
- **Animation Utilities**: Core framework with settings-aware animation wrappers
- **Entry Animations**: FadeIn, ScaleIn, SlideIn, BouncingWidget, BreathingWidget
- **Transition Animations**: AnimatedExpanded, AnimatedSizeSwitcher, ScaledAnimatedSwitcher, SlideFadeTransition
- **Interactive Animations**: TappableWidget, ShakeAnimation, AnimatedScaleOpacity
- **Dialog Framework**: PopupFramework, DialogService, BottomSheetService with animation integration
- **Page Transitions**: Platform-aware slide, fade, scale, and slide-fade transitions with Material 3 OpenContainer support
- **Navigation Enhancement**: Seamless container transitions for card-to-page and list-to-page navigation
- **Phase 5 Integration**: Enhanced navigation with PopupFramework dialogs, animated PageTemplate, and comprehensive TappableWidget integration
- **Performance Optimization**: Battery saver, real-time performance monitoring, and reduced motion support with zero overhead when disabled
- **Platform Adaptation**: iOS, Android, web, and desktop-specific behaviors

This architecture provides a scalable, maintainable foundation for a comprehensive personal finance management application with advanced file management, multi-currency capabilities, and a sophisticated animation framework. 