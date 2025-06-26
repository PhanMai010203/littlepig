@ -0,0 +1,149 @@
# Plan to Fix `get_it` and BLoC Integration Bugs (Phase 3)

This document outlines the plan to fix several critical bugs related to BLoC event dispatching, test environment configuration, and asynchronous operations.

## Summary of Bugs

1.  **Redundant BLoC Events**: `BudgetsPage` and `TransactionsPage` dispatch data loading events inside their `build` methods, causing excessive and unnecessary data fetching on every widget rebuild.
2.  **Broken Test Environment**: The dependency injection setup for the 'test' environment is missing, forcing tests to run against the production database, which breaks test isolation and causes failures.
3.  **Unhandled Async Operation**: An asynchronous budget update method is called without being awaited, leading to silent failures and unhandled exceptions.

## Remediation Plan

### Task 1: Fix Redundant BLoC Event Dispatching

**Problem**: BLoC events are triggered inside the `build()` method, leading to performance degradation.

**Files to Modify**:
*   `lib/features/budgets/presentation/pages/budgets_page.dart`
*   `lib/features/transactions/presentation/pages/transactions_page.dart`

**Solution**:
Convert `BudgetsPage` and `TransactionsPage` from `StatelessWidget` to `StatefulWidget`. Dispatch the initial data loading event once in the `initState()` method. This ensures the event is fired only when the widget is first inserted into the widget tree.

**Implementation for `budgets_page.dart`**:

To fix `budgets_page.dart`, I will convert it to a `StatefulWidget` and move the `LoadAllBudgets` event dispatch to `initState`.

```dart
// lib/features/budgets/presentation/pages/budgets_page.dart

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  @override
  void initState() {
    super.initState();
    // Initiate the first event load. The BlocProvider is now in app.dart.
    context.read<BudgetsBloc>().add(LoadAllBudgets());
  }

  @override
  Widget build(BuildContext context) {
    return const _BudgetsView();
  }
}
```

**Implementation for `transactions_page.dart`**:

Similarly for `transactions_page.dart`, I will convert it to a `StatefulWidget` and move the `LoadTransactionsWithCategories` event dispatch to `initState`.

```dart
// lib/features/transactions/presentation/pages/transactions_page.dart

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    // The BlocProvider is now in app.dart, so we just use the bloc.
    // We initiate the first event load here.
    context.read<TransactionsBloc>().add(LoadTransactionsWithCategories());
  }

  @override
  Widget build(BuildContext context) {
    return const _TransactionsView();
  }
}
```

---

### Task 2: Restore Test Environment Configuration

**Problem**: Missing `@Environment('test')` providers for `DatabaseService` and `AppDatabase` in `register_module.dart` forces tests to use the production database.

**File to Modify**:
*   `lib/core/di/register_module.dart`

**Solution**:
Re-introduce the test-specific providers for `DatabaseService` and `AppDatabase` using the `@Environment('test')` annotation. This will register an in-memory database (`AppDatabase.forTesting`) for testing purposes, ensuring test isolation.

**Proposed Implementation**:
I will add the following annotated methods back to the `RegisterModule` class in `lib/core/di/register_module.dart`.

```dart
// lib/core/di/register_module.dart

@module
abstract class RegisterModule {

  // ... existing prod/dev providers

  @Environment('test')
  @preResolve
  @singleton
  Future<AppDatabase> get testAppDatabase =>
      Future.value(AppDatabase.forTesting(constructDb(logStatements: true)));

  @Environment('test')
  @Singleton(as: DatabaseService)
  DatabaseService get TestDatabaseService => DatabaseService(getIt<AppDatabase>());
}
```

---

### Task 2.5: Enable Safe Environment Switching in Tests

**Problem**: After the test-environment providers were restored, developers still needed an ergonomic way to *switch* environments during a single test run.  Calling `configureDependencies('test')` **after** an earlier call with another environment had no effect because `configureDependencies` intentionally short-circuits when GetIt is already initialised.

**Files Modified**:
* `lib/core/di/injection.dart`  (new helper added)

**Solution**:
Add a small wrapper that resets GetIt **then** re-initialises it with the desired environment.  The helper keeps production code safe (because it will only be used explicitly in tests or hot-reload scenarios) while giving tests a one-liner to get a *fresh* environment.

```dart
// lib/core/di/injection.dart

/// Reset all dependencies and re-configure with the desired environment.
Future<void> configureDependenciesWithReset([String? environment]) async {
  await resetDependencies();
  await configureDependencies(environment);
}
```

**How to use in tests**

```dart
// Arrange – fresh DI for a test environment
setUp(() async {
  await configureDependenciesWithReset('test');
});

// Switch to prod (rare, but now possible)
await configureDependenciesWithReset('prod');
```

This keeps the original `configureDependencies()` semantics (idempotent for the same env) but makes switching explicit and safe.

---

### Task 3: Await Asynchronous Budget Update

**Problem**: An `async` method `updateBudgetOnTransactionChange` is called without `await`, causing potential unhandled exceptions and silent failures.

**File to Modify**:
*   `lib/features/budgets/data/services/budget_update_service_impl.dart`

**Solution**:
Add the `await` keyword to the call to `updateBudgetOnTransactionChange` within the event stream listener. This will also involve making the listener callback `async`.

**Implementation for `budget_update_service_impl.dart`**:

```dart
// lib/features/budgets/data/services/budget_update_service_impl.dart

_eventSubscription =
    _eventPublisher.events.listen((event) async { // Make the listener async
  if (event is TransactionChangedEvent) {
    try {
      await updateBudgetOnTransactionChange( // Add await
          event.oldTransaction, event.newTransaction);
    } catch (e, s) {
      // It's good practice to log the error
      log('Error updating budget on transaction change', error: e, stackTrace: s);
    }
  }
});
```

</rewritten_file> 