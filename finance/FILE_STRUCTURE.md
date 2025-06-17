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
    ├── app_router.dart               # GoRouter setup and route definitions
    └── app_routes.dart               # Route constants and path definitions
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
│   └── cache_management_service.dart # Local file cache management service
├── sync/                             # Cloud synchronization services
│   ├── sync_service.dart            # Main sync service interface
│   └── google_drive_sync_service.dart # Google Drive sync implementation
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
**Summary**: Core infrastructure layer containing database setup with Drift ORM, file management and attachment services, cloud sync services, theming system with Material You support, dependency injection setup, and shared utilities.

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
├── transactions/                     # Transaction management feature (Phase 3 - Budget Integration)
│   ├── domain/                       # Business logic layer
│   │   ├── entities/
│   │   │   ├── transaction.dart     # Transaction entity/model
│   │   │   ├── transaction_enums.dart # Transaction enumerations including change types
│   │   │   └── attachment.dart      # Attachment entity with Google Drive integration
│   │   ├── repositories/
│   │   │   ├── transaction_repository.dart # Transaction repository interface
│   │   │   └── attachment_repository.dart # Attachment repository interface
│   │   └── usecases/                # Business use cases
│   │       ├── get_transactions.dart # Transaction retrieval use cases
│   │       └── manage_transactions.dart # Transaction management use cases
│   ├── data/                        # Data access layer
│   │   └── repositories/
│   │       ├── transaction_repository_impl.dart # Transaction repository with budget update integration
│   │       └── attachment_repository_impl.dart # Attachment repository implementation
│   └── presentation/                # UI layer
│       ├── pages/
│       │   └── transactions_page.dart # Transaction list/management page
│       └── bloc/                    # State management
│           ├── transactions_event.dart # Transaction events
│           └── transactions_state.dart # Transaction states
├── budgets/                         # Budget management feature (Phase 3 - Real-time updates & Auth)
│   ├── domain/                      # Business logic layer
│   │   ├── entities/
│   │   │   ├── budget.dart          # Budget entity/model
│   │   │   └── budget_enums.dart    # Budget-related enumerations
│   │   ├── repositories/
│   │   │   └── budget_repository.dart # Budget repository interface
│   │   └── services/                # Budget business services
│   │       ├── budget_filter_service.dart # Budget filtering and calculation interface
│   │       └── budget_update_service.dart # Real-time budget update service interface
│   ├── data/                        # Data access layer
│   │   ├── repositories/
│   │   │   └── budget_repository_impl.dart # Budget repository implementation
│   │   └── services/                # Budget service implementations
│   │       ├── budget_filter_service_impl.dart # Budget filtering and calculation logic
│   │       ├── budget_csv_service.dart # Budget CSV export/import service
│   │       ├── budget_update_service_impl.dart # Real-time budget updates with RxDart streams
│   │       └── budget_auth_service.dart # Biometric authentication service using local_auth
│   └── presentation/                # UI layer
│       ├── pages/
│       │   └── budgets_page.dart    # Budget management page
│       └── bloc/                    # Enhanced BLoC with real-time features
│           ├── budgets_bloc.dart    # Budget BLoC with real-time updates and authentication
│           ├── budgets_event.dart   # Budget events including real-time triggers
│           └── budgets_state.dart   # Budget states with authentication status
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
├── navigation/                      # Navigation feature
│   ├── domain/                      # Navigation entities
│   │   └── entities/                # Navigation-related entities
│   └── presentation/                # Navigation UI components
│       ├── widgets/                 # Navigation widgets
│       │   ├── adaptive_bottom_navigation.dart # Bottom navigation bar
│       │   └── main_shell.dart      # Main app shell wrapper
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
**Summary**: Feature modules organized by business domain, each following clean architecture with domain (entities, repositories, use cases), data (repository implementations, data sources), and presentation (UI, BLoC) layers. Includes comprehensive attachment management with Google Drive integration, multi-currency support, and Phase 3 enhancements with real-time budget updates using RxDart streams and biometric authentication via local_auth package.

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
│   ├── app_text.dart                # Custom text widgets with theming
│   ├── page_template.dart           # Common page layout template
│   └── language_selector.dart       # Language selection widget
└── utils/                           # Shared utilities (currently empty)
```
**Summary**: Shared components and utilities that can be used across multiple features, including reusable widgets and common utilities.

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
- ✅ **Settings**: App configuration and preferences
- ✅ **Cloud Sync**: Google Drive integration with conflict resolution
- ✅ **File Management**: Camera, gallery, and file picker integration
- ✅ **Cache Management**: Smart local file caching system
- ✅ **Theming**: Material You and custom themes
- ✅ **Localization**: Multi-language support (English, Vietnamese)
- ✅ **Use Cases**: Business logic abstraction layer
- ✅ **State Management**: Comprehensive BLoC implementation
- ✅ **Phase 3 Features**: Real-time budget updates with RxDart streams
- ✅ **Biometric Authentication**: Secure budget access using local_auth
- ✅ **Transaction-Budget Integration**: Automatic budget updates on transaction changes

## 🧪 Test Structure

### Unit Tests
```
test/
├── core/
│   ├── constants/
│   │   └── default_categories_test.dart    # Default categories validation
│   └── di/
│       └── injection_test.dart             # Dependency injection testing
├── features/
│   ├── budgets/
│   │   ├── budget_filter_service_test.dart # Budget filtering and calculation tests
│   │   └── budget_update_service_test.dart # Phase 3 real-time update service tests
│   ├── currencies/
│   │   ├── currency_integration_test.dart  # Currency integration tests
│   │   ├── currency_offline_test_new.dart  # Offline currency functionality
│   │   ├── exchange_rate_operations_test.dart # Exchange rate operations
│   │   ├── get_currencies_test.dart        # Currency retrieval use cases
│   │   └── currency_repository_test.dart   # Currency repository tests
│   └── transactions/
│       └── advanced_transaction_test.dart  # Advanced transaction scenarios
├── mocks/
│   ├── mock_account_repository.dart        # Account repository mocks
│   ├── mock_currency_local_data_source.dart # Currency data source mocks
│   ├── mock_exchange_rate_local_data_source.dart # Exchange rate mocks
│   ├── mock_exchange_rate_remote_data_source.dart # Remote API mocks
│   ├── mock_transaction_repository.dart    # Transaction repository mocks
│   └── mock_budget_repository.dart         # Budget repository mocks
└── widget_test.dart                        # Widget testing
```

This architecture provides a scalable, maintainable foundation for a comprehensive personal finance management application with advanced file management, multi-currency capabilities, real-time budget tracking, and biometric security features. 