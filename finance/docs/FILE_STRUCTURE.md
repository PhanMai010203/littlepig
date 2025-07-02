# 📱 Finance App – Updated File Structure (2025-06)

This Flutter application keeps a strict **Clean Architecture** separation across Presentation, Domain and Data layers.  The outline below reflects the *current* directory tree – remove the temporary directories that no longer exist and add the new modules that have been introduced since the last revision.

## 🏗️ Architecture Layers

```
📱 Presentation Layer (UI)
    ├── Pages (Screens)
    ├── Widgets (UI Components)
    └── BLoC (State Management)
           ↓
⚙️ Domain Layer (Business Logic)
    ├── Entities (Pure Models)
    ├── Use-Cases (Business Rules)
    └── Repositories (Interfaces)
           ↓
💾 Data Layer (External)
    ├── Data-Sources (API / Local DB)
    ├── Repository Implementations
    └── DTO Models
```

---

## 📁 Directory Overview

Only the `lib/` tree is shown here – platform folders (`android/`, `ios/`, …), build output and CI tooling are omitted for brevity.

### 🚀 Root entry point

```
lib/
├── main.dart                     # Application entry – sets up DI, localisation & theming
├── demo/                         # Demo utilities & playground screens
│   ├── currency_demo.dart
│   ├── data_seeder.dart          # Large in-memory seed data generator for quick testing
│   ├── demo_transition_pages.dart
│   └── framework_demo_page.dart  # Show-case of animation framework
```
**Summary**: Main bootstrap file plus a playground folder used during development and manual QA.  The former `tmp/` directory has been removed – any JSON reference data now lives in the appropriate data-source folders.

---

### 📱 App configuration layer

```
lib/app/
├── app.dart                      # Top-level `MaterialApp` (theme, localisation wrappers)
└── router/
    ├── app_router.dart           # GoRouter configuration
    ├── app_routes.dart           # Typed path constants
    ├── page_transitions.dart     # Shared transition builders
    └── _experimental_transitions.dart  # In-progress prototypes
```
**Summary**: Centralised navigation and theme/environment configuration.

---

### ⚙️ Core layer (infrastructure & shared services)

```
lib/core/
├── database/
│   ├── app_database.dart         # Drift DB wrapper
│   ├── app_database.g.dart       # Generated code
│   ├── migrations/
│   │   ├── phase3_partial_loans_migration.dart
│   │   └── schema_cleanup_migration.dart
│   └── tables/
│       ├── accounts_table.dart
│       ├── attachments_table.dart
│       ├── budgets_table.dart
│       ├── categories_table.dart
│       ├── sync_event_log_table.dart
│       ├── sync_metadata_table.dart
│       ├── sync_state_table.dart
│       ├── transaction_budgets_table.dart
│       └── transactions_table.dart
│
├── services/                     # Device / IO / performance facades
│   ├── animation_performance_service.dart
│   ├── cache_management_service.dart
│   ├── database_cache_service.dart
│   ├── database_connection_optimizer.dart
│   ├── database_service.dart
│   ├── dialog_service.dart
│   ├── file_picker_service.dart
│   ├── platform_service.dart
│   └── timer_management_service.dart
│
├── sync/                         # Cloud sync & CRDT
│   ├── enhanced_incremental_sync_service.dart
│   ├── incremental_sync_service.dart
│   ├── sync_event.dart
│   ├── sync_service.dart
│   ├── sync_state_manager.dart
│   ├── event_processor.dart
│   ├── google_drive_sync_service.dart
│   ├── crdt_conflict_resolver.dart
│   └── interfaces/
│       └── sync_interfaces.dart
│
├── events/
│   └── transaction_event_publisher.dart  # Domain-event broadcaster
│
├── repositories/
│   └── cacheable_repository_mixin.dart   # Caching helper for data repos
│
├── settings/
│   └── app_settings.dart
│
├── theme/
│   ├── app_colors.dart
│   ├── app_text_theme.dart
│   ├── app_theme.dart
│   └── material_you.dart
│
├── utils/
│   └── bloc_observer.dart
│
├── constants/
│   └── default_categories.dart
│
└── di/
    ├── injection.dart
    ├── injection.config.dart
    └── register_module.dart
```
**Summary**: Low-level infrastructure – Drift database, platform abstractions, advanced sync/CRDT engine, centralised settings & theme, DI glue and various performance helpers.

---

### 🎯 Features layer (business use-cases)

Each feature follows the **presentation ⇄ domain ⇄ data** triplet.  Only high-level folders are listed here; see in-folder `README`s for deeper details.

```
lib/features/
├── accounts/
├── budgets/
├── categories/
├── currencies/
├── home/
├── more/
├── navigation/
├── settings/
└── transactions/
```
**Summary**: Modularised business functionality with independent tests and DI registrations.

---

### 🔧 Services layer (orchestration helpers)

```
lib/services/
├── currency_service.dart
└── finance_service.dart
```
These classes stitch multiple repositories together for convenience (e.g. UI widgets that need cross-cutting data).

---

### 🛠️ Shared layer (re-usable UI & utilities)

```
lib/shared/
├── widgets/
│   ├── animations/      # 18 animation wrappers incl. FadeIn, BreathingWidget, etc.
│   ├── dialogs/         # popup_framework.dart, bottom_sheet_service.dart, note_popup.dart
│   ├── transitions/     # open_container_navigation.dart
│   ├── page_template.dart
│   ├── app_text.dart
│   ├── app_lifecycle_manager.dart
│   ├── selector_widget.dart          # Generic multi/single select base
│   ├── single_account_selector.dart  # Concrete selectors built on top
│   ├── multi_account_selector.dart
│   ├── single_category_selector.dart
│   ├── multi_category_selector.dart
│   ├── language_selector.dart
│   └── collapsible_app_bar_title.dart
│
├── extensions/
│   └── account_currency_extension.dart
│
└── utils/
    ├── currency_formatter.dart
    ├── no_overscroll_behavior.dart
    ├── optimized_list_extensions.dart
    ├── performance_optimization.dart
    ├── responsive_layout_builder.dart
    └── snap_size_cache.dart
```
**Summary**: A large collection of widgets, transition wrappers and pure-Dart helpers used throughout the app.  All widgets respect the central animation/low-motion settings.

---

### 🧪 Performance & benchmark tests

```
test/performance/
├── database_cache_performance_test.dart
└── phase_2_performance_test.dart
```
Benchmarks ensure that database caching and re-layout optimisations hit their performance budgets.

---

## 🎨 Key architecture patterns (unchanged)

* **Clean Architecture** – Pure domain models, interface driven repositories.
* **Drift ORM** – Type-safe SQL + migrations.
* **BLoC + Freezed** – Reactive state management.
* **GetIt + Injectable** – Compile-time DI.
* **Material You** – Dynamic system colour extraction.
* **High-refresh screen** handling & frame pacing.
* **Google Drive** sync with CRDT conflict resolution.
* **Locale & currency** abstraction for multi-currency budgeting.

> See `docs/ARCHITECTURE.md` for an in-depth explanation of these patterns. 