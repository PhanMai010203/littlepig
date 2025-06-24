## 🏆 GetIt DI Unification & Refactoring - Master Plan

> Status: **FINALIZED – v3.0**  
> Author: Gemini Senior Project Manager  
> Date: 2025-01-28  
> Supersedes: `plan.md`, `plan2.md`

---

### 1. Executive Summary

This document outlines the official, unified plan to refactor the application's dependency injection (DI) system. We will migrate from a problematic dual-entry-point system (manual registration in `injection.dart` + partial code-generation in `injection.config.dart`) to a single, authoritative DI setup powered entirely by the **`injectable`** package. This will eliminate complexity, prevent runtime errors from missing registrations, and establish a clear, maintainable pattern for dependency management across production and test environments.

### 2. Problem Analysis - CONFIRMED

A thorough review confirms the critical issues stemming from our current DI setup:

*   **Two Competing Systems:** `injection.dart` contains ~400 lines of manual registrations, while the generated `injection.config.dart` is sparse, handling only 3 BLoCs. This creates confusion and is error-prone.
*   **Critical Missing Registrations:** Key components, most notably `BudgetsBloc` and `DatabaseService`, are absent from the generated configuration, leading to test failures and potential runtime crashes when not using the manual setup.
*   **High Maintenance Overhead:** The testing setup (`configureTestDependencies`) duplicates nearly all manual registrations, doubling the effort required to add or modify dependencies.
*   **Dependency Count Mismatch:**
    *   **Manual Registrations:** Over 35 services, repositories, and use cases.
    *   **Generated Registrations:** Only 3 BLoCs.

### 3. Guiding Principles

To ensure long-term success, this refactoring will adhere to the following principles:

1.  **Configuration by Declaration:** All DI configuration will be achieved through annotations (`@injectable`, `@module`, etc.) directly on or near the implementation classes.
2.  **Zero Manual Edits:** The generated `injection.config.dart` file will *never* be edited by hand. It is exclusively managed by the `build_runner`.
3.  **Environment-Driven Configuration:** We will use `injectable`'s environment feature (`@Environment('test')`) to provide alternate implementations (e.g., an in-memory database for tests).
4.  **Constructor Injection is King:** We will systematically eliminate service locator calls (`getIt<...>()`) in favor of constructor injection to make dependencies explicit and classes easier to test in isolation.

### 4. Goal

**Migrate to a unified, 100% `injectable`-powered DI system, eliminating manual registrations and supporting distinct build environments.**

### 5. Comprehensive File Impact Analysis

The following files have been identified for modification.

**Files Requiring `@injectable` Annotations (22 files):**
```
lib/features/accounts/data/repositories/account_repository_impl.dart
lib/features/budgets/data/repositories/budget_repository_impl.dart  
lib/features/budgets/presentation/bloc/budgets_bloc.dart ⭐ CRITICAL
lib/features/categories/data/repositories/category_repository_impl.dart
lib/features/currencies/data/repositories/currency_repository_impl.dart
lib/features/transactions/data/repositories/transaction_repository_impl.dart
lib/features/transactions/data/repositories/attachment_repository_impl.dart
lib/features/currencies/data/datasources/currency_local_data_source.dart
lib/features/currencies/data/datasources/exchange_rate_local_data_source.dart
lib/features/currencies/data/datasources/exchange_rate_remote_data_source.dart
lib/features/currencies/domain/usecases/get_currencies.dart (and 5 other use cases)
lib/features/budgets/data/services/budget_filter_service_impl.dart
lib/features/budgets/data/services/budget_update_service_impl.dart
lib/features/budgets/data/services/budget_auth_service.dart
lib/features/budgets/data/services/budget_csv_service.dart
lib/services/currency_service.dart
lib/services/finance_service.dart
lib/core/services/file_picker_service.dart
lib/core/sync/crdt_conflict_resolver.dart
lib/core/database/migrations/schema_cleanup_migration.dart
```

**Files Using `getIt<>` Calls to be Refactored (7+ files):**
```
lib/services/finance_service.dart (6 calls)
lib/demo/currency_demo.dart (1 call)
lib/demo/data_seeder.dart (4 calls)
lib/app/app.dart (2 calls)
lib/features/home/presentation/pages/home_page.dart (3 calls)
lib/features/transactions/presentation/pages/transactions_page.dart (1 call)
lib/features/budgets/presentation/pages/budgets_page.dart (1 call)
```

**Entry Point & Test Files to be Updated (10+ files):**
```
lib/main.dart
lib/demo/currency_demo.dart
test/widget_test.dart
// ...and all other test files using configureTestDependencies()
```

### 6. Five-Phase Implementation Plan

This project is broken down into five distinct, sequential phases to minimize risk and ensure a smooth transition.

#### **PHASE 1: Foundation - Annotate & Configure** (Effort: High)
*Goal: Annotate all necessary classes and configure the `RegisterModule`.*

| Task | Files | Complexity |
|------|-------|------------|
| 1.1 Add `@injectable` or `@LazySingleton` to all repository implementations | 7 repository files | ★★☆ |
| 1.2 Add `@injectable` to all data source implementations | 3 datasource files | ★☆☆ |
| 1.3 Add `@injectable` to all service implementations | 8 service files | ★★☆ |
| 1.4 **CRITICAL**: Add `@injectable` to `BudgetsBloc` | `budgets_bloc.dart` | ★★★ |
| 1.5 Expand `RegisterModule` with async services and test environment alternates | `register_module.dart` | ★★★ |
| 1.6 Run `build_runner` and resolve any initial generation errors | `injection.config.dart` | ★★☆ |

**Expected Outcome:** All data, service, and critical BLoC classes are known to `injectable`, and the generated file is populated but not yet integrated.

#### **PHASE 2: Integration - Switch Entry Points** (Effort: Medium)
*Goal: Reroute `main.dart` and test initializers to use the new `getIt.init()` method.*

| Task | Files | Complexity |
|------|-------|------------|
| 2.1 Create a new `configureDependencies` function that accepts an environment string | `injection.dart` | ★★☆ |
| 2.2 In the new function, call `getIt.init(environment: env)` | `injection.dart` | ★☆☆ |
| 2.3 Update `main.dart` to call the new wrapper without an environment (defaults to prod) | `main.dart` | ★★☆ |
| 2.4 Create a test helper (`test/helpers/test_di.dart`) that calls the wrapper with `env: 'test'` | New file | ★★☆ |
| 2.5 Update all test files to use the new test helper instead of `configureTestDependencies` | ~11 test files | ★★★ |

**Expected Outcome:** The application and all tests now run using the `injectable`-generated dependency graph. The old manual registration code is now dead code.

#### **PHASE 3: Cleanup - Remove Dead Code** (Effort: Medium)
*Goal: Eliminate the old manual DI system and refactor service locator calls.*

| Task | Files | Complexity |
|------|-------|------------|
| 3.1 Delete the old manual registration code from `injection.dart` | `injection.dart` | ★☆☆ |
| 3.2 Systematically replace all `getIt<...>()` service locator calls with constructor injection | 7+ UI/service files | ★★★ |
| 3.3 Remove any no-longer-needed `getIt` calls from demo files | `demo/*.dart` | ★☆☆ |

**Expected Outcome:** The codebase is free of the old DI system, and dependencies are made explicit through constructors, improving testability and readability.

#### **PHASE 4: Quality - Harden the System** (Effort: Medium)
*Goal: Implement automated checks to prevent future regressions.*

| Task | Files | Complexity |
|------|-------|------------|
| 4.1 Create a `di_sanity_test.dart` to verify critical registrations | New test file | ★★☆ |
| 4.2 Add a pre-commit hook or CI step that fails if `*.config.dart` is edited manually | Git hook / CI config | ★★★ |
| 4.3 Ensure all tests still pass after the full refactor | Test suite | ★★☆ |

**Expected Outcome:** A robust, self-policing DI system that is difficult to break accidentally.

#### **PHASE 5: Documentation - Update Guides** (Effort: Low)
*Goal: Ensure project documentation reflects the new, simplified DI process.*

| Task | Files | Complexity |
|------|-------|------------|
| 5.1 Update `docs/README.md` to describe the new DI workflow | `README.md` | ★☆☆ |
| 5.2 Mark old DI helper functions as `@deprecated` if any remain for compatibility | `injection.dart` | ★☆☆ |

**Expected Outcome:** Project documentation is up-to-date, enabling smooth onboarding for future developers.

### 7. Critical Dependencies & Ordering

- **Repositories before Services:** Repository implementations must be injectable before the services that depend on them.
- **`BudgetsBloc` is Critical:** This BLoC must be registered before the UI layer is refactored, as its absence will cause crashes.
- **Async Dependencies:** Services requiring async setup (like `SharedPreferences` or a database connection) must be handled with `@preResolve` in the `RegisterModule`.

### 8. Environment Strategy

-   **Production (`prod`, default):** Registers all real implementations, including the `Drift` database and `GoogleDriveSyncService`.
-   **Test (`test`):** Registers mock implementations where necessary and an in-memory database to ensure fast, hermetic tests. This is controlled by the `@Environment('test')` annotation in `RegisterModule`.

### 9. Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| **`BudgetsBloc` not registered** | **HIGH** | Prioritized in Phase 1; guarded by sanity tests in Phase 4. |
| **Circular Dependencies** | **MEDIUM** | Use `@lazy` annotation for one side of the dependency pair. Break cycles by introducing a third class if necessary. |
| **Test Suite Breakage** | **MEDIUM** | Phased rollout ensures tests are run and fixed incrementally. A dedicated test DI helper minimizes per-test changes. |
| **Async Initialization Failure** | **LOW** | Use `@preResolve` and ensure `main` is `async`. Guarded by app startup tests. |

### 10. Verification & Success Metrics

-   ✅ `flutter test` passes 100% without any manual registration code.
-   ✅ The application successfully launches and all critical user flows are functional.
-   ✅ `BudgetsBloc` is correctly registered and the Budgets page loads without error.
-   ✅ The final `lib/core/di/injection.dart` contains only `getIt.init()` and reset logic.
-   ✅ The generated `injection.config.dart` is comprehensive and contains all dependencies.
-   ✅ All `getIt<...>()` calls outside of `main` have been replaced with constructor injection.
-   ✅ The CI check for manual edits to generated files is active and functional.

### 11. Implementation Snippets

**`RegisterModule` Expansion:**
```dart
@module
abstract class RegisterModule {
  // Existing: SharedPreferences, GoogleSignIn, etc.
  
  // Add new module providers for third-party or complex initializations.
  @preResolve
  @LazySingleton
  Future<DatabaseService> get databaseService async {
    final service = DatabaseService();
    await service.init(); // Assuming an async init method
    return service;
  }
  
  @Environment('test')
  @LazySingleton(as: DatabaseService)
  DatabaseService get testDatabaseService => InMemoryDatabaseService();
}
```

**`BudgetsBloc` Registration:**
```dart
@injectable
class BudgetsBloc extends Bloc<BudgetsEvent, BudgetsState> {
  BudgetsBloc(
    this._budgetRepository,
    this._budgetUpdateService, 
    this._budgetFilterService,
  ) : super(BudgetsInitial()) {
    // ... existing implementation
  }
  // ...
}
```

---

This master plan provides a clear, low-risk, and comprehensive path to a modern, maintainable dependency injection system. 