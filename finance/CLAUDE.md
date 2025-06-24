# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Prerequisites

- **Flutter SDK:** Version 3.10.0 or higher
- **Dart SDK:** Version 3.0.0 or higher  
- **Android Studio/Xcode:** Latest stable versions
- **Java:** Version 11 (for Android development)

## Initial Setup

### Google Services Configuration
**Critical:** This app requires Google Drive integration for sync functionality.

1. **Create Google Cloud Project:**
   - Enable Google Drive API and Google Sign-In API
   - Configure OAuth consent screen

2. **Add Configuration Files:**
   - Android: Place `google-services.json` in `android/app/`
   - iOS: Add `GoogleService-Info.plist` to iOS project

3. **Install Dependencies:**
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

## Development Commands

### Code Generation
```bash
# Regenerate code generation (drift database, injectable DI, freezed models)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation during development
dart run build_runner watch --delete-conflicting-outputs
```

### Testing
```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/path/to/specific_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Running the App
```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device_id>
```

### Linting and Analysis
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .
```

## Architecture Overview

This is a **production-ready Flutter finance app** following **Clean Architecture** principles with a feature-first approach.

### Core Architecture Patterns

**Clean Architecture Layers:**
- **Presentation**: BLoC state management, UI widgets, pages
- **Domain**: Business entities, repository interfaces, use cases
- **Data**: Repository implementations, data sources (local/remote)

**State Management:**
- Uses `flutter_bloc` with the BLoC pattern throughout
- All BLoCs are registered via `@injectable` annotation in dependency injection
- States use `equatable` for efficient comparisons
- Events and states follow consistent naming conventions

**Dependency Injection:**
- Uses `get_it` with `injectable` annotations
- All repositories, services, and BLoCs are auto-registered
- Run `dart run build_runner build` after adding new `@injectable` classes
- Access via `getIt<YourService>()` pattern

### Key Technical Decisions

**Database & Persistence:**
- **Drift ORM** for type-safe SQLite operations
- Database schemas defined in `core/database/tables/`
- Migrations handled in `core/database/migrations/`
- In-memory caching layer via `DatabaseCacheService`

**Sync & Cloud Integration:**
- Google Drive integration for data backup and file attachments  
- CRDT-based conflict resolution for multi-device sync
- Event-sourcing architecture with `IncrementalSyncService`
- Offline-first design with real-time sync when connected

**Animation Framework:**
- Migration from custom animations to `flutter_animate` for performance
- Platform-aware animations with battery optimization
- Performance monitoring and reduced motion support
- Comprehensive animation widgets in `shared/widgets/animations/`

**Multi-Currency Support:**
- Local and remote exchange rate data sources
- Currency formatting with locale support
- Real-time exchange rate updates with offline fallbacks

### Project Structure Key Points

**Feature Organization:**
```
lib/features/[feature_name]/
├── domain/          # Business logic layer
│   ├── entities/    # Business models
│   ├── repositories/# Interface contracts
│   └── usecases/   # Business use cases
├── data/           # Data access layer
│   ├── repositories/# Repository implementations
│   ├── datasources/ # API/Database access
│   └── models/     # Data transfer objects
└── presentation/   # UI layer
    ├── pages/      # Screen widgets
    ├── widgets/    # Feature-specific widgets
    └── bloc/       # State management
```

**Shared Components:**
- `lib/shared/widgets/` - Reusable UI components
- `lib/shared/extensions/` - Dart extensions
- `lib/core/` - Infrastructure (database, DI, sync)

### Development Guidelines

**BLoC Pattern Implementation:**
- All pages must use BLoC for state management (no StatefulWidget for business logic)
- Use `BlocProvider` at page level, `BlocConsumer` for reactive UI
- Events should be descriptive and represent user intentions
- States should be immutable with `copyWith` methods

**Database Changes:**
- Always create migrations when modifying table schemas
- Update corresponding entities and repository methods
- Test migrations with both upgrade and downgrade scenarios

**Context7 Integration:**
- Maintain `docs/.context7/library.md` with searched library IDs
- Use 2k-10k token range for context7 queries
- Check existing library IDs before searching new ones

**Documentation Requirements:**
- Read `@docs/README.md` (project docs) before major changes
- Refer to `docs/FILE_STRUCTURE.md` for architectural guidance
- Update relevant documentation when adding new features

### Testing Approach

**Unit Tests:** Focus on BLoCs, repositories, and business logic
**Widget Tests:** Test individual widgets and simple flows  
**Integration Tests:** Test complete user journeys and database operations

Use `test/helpers/test_database_setup.dart` for database testing utilities and `test/mocks/` for repository mocks.