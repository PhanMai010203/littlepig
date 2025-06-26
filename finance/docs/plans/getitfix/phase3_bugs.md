# Plan to Fix `get_it` and BLoC Integration Bugs (Phase 3)

This document outlines the plan to fix several critical bugs related to BLoC event dispatching, test environment configuration, and asynchronous operations.

## Summary of Bugs

1.  **Redundant BLoC Events**: `BudgetsPage` and `TransactionsPage` dispatch data loading events inside their `build` methods, causing excessive and unnecessary data fetching on every widget rebuild.
2.  **Broken Test Environment**: The dependency injection setup for the 'test' environment is missing, forcing tests to run against the production database, which breaks test isolation and causes failures.
3.  **Unhandled Async Operation**: An asynchronous budget update method is called without being awaited, leading to silent failures and unhandled exceptions.

## Remediation Plan

### Task 1: Fix Redundant BLoC Event Dispatching

**Status**: ✅ **COMPLETELY VERIFIED** - Code implementation is correct, tests are passing, and functionality is confirmed.

**Verification Details**:
- **Code Review**: Both `lib/features/budgets/presentation/pages/budgets_page.dart` and `lib/features/transactions/presentation/pages/transactions_page.dart` have been correctly converted to `StatefulWidget`.
- **Event Dispatch**: The `LoadAllBudgets` and `LoadTransactionsWithCategories` events are correctly dispatched from within the `initState` method, ensuring they are called only once. The `build` methods are free from event dispatching logic.
- **Test Execution**: ✅ All dedicated tests for Task 1 are now **PASSING**
  - `budgets_page_test.dart`: 5 tests passed - Confirms LoadAllBudgets dispatched once on init, not on rebuilds
  - `transactions_page_test.dart`: 2 tests passed - Confirms LoadTransactionsWithCategories dispatched once on init, not on rebuilds
- **Test Environment Fix**: The test execution issue was resolved by regenerating the dependency injection configuration (`flutter packages pub run build_runner build --delete-conflicting-outputs`) which fixed parameter mismatches in the generated `injection.config.dart` file.

**Implementation Summary**:
```dart
// Both pages follow this correct pattern:
class BudgetsPage extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    context.read<BudgetsBloc>().add(LoadAllBudgets()); // ✅ Once in initState
  }
  
  @override
  Widget build(BuildContext context) {
    // ✅ Clean build method with no event dispatching
    return PageTemplate(/* UI only */);
  }
}
```

**Conclusion**: Task 1 is fully implemented, tested, and working correctly. The redundant BLoC event dispatching issue has been completely resolved.

---

### Task 2: Restore Test Environment Configuration

**Status**: ✅ **COMPLETED** - Test environment configuration is correctly implemented and verified.

**Verification Details**:
- **Code Review**: Confirmed `lib/core/di/register_module.dart` contains correct test environment providers:
  - `testDatabaseService` with `@Environment('test')` annotation (line 41-42)
  - `testAppDatabase` with `@Environment('test')` annotation (line 51-53)
- **Generated Configuration**: Verified `lib/core/di/injection.config.dart` correctly registers test services:
  - `testDatabaseService` registered for `_test` environment (lines 121-124)
  - `testAppDatabase` registered for `_test` environment (lines 125-128)
  - Production services correctly separated for `_prod` and `_dev` environments
- **Test Infrastructure**: Confirmed existing test helper framework uses `configureDependencies('test')` correctly
- **Database Isolation**: Test environment uses `DatabaseService.forTesting()` which creates `AppDatabase.forTesting(NativeDatabase.memory())`

**Implementation Summary**:
```dart
// register_module.dart - Test environment providers
@lazySingleton
@Environment(Environment.test)
DatabaseService get testDatabaseService => DatabaseService.forTesting();

@lazySingleton
@Environment(Environment.test)
AppDatabase testAppDatabase(DatabaseService service) => service.database;
```

**Conclusion**: Task 2 was already completed. The test environment configuration correctly isolates tests using in-memory databases, preventing tests from interfering with production data.

---

### Task 3: Await Asynchronous Budget Update

**Status**: 🟡 **PENDING**

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