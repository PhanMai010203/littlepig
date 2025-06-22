# Budget Tracking System – Usage Guide

## Overview
The budget module lets you create, filter, and monitor budgets with advanced rules such as wallet or currency scopes, debt-credit exclusions, and real-time spent calculations.  
This guide shows the most common APIs you will use from the **Domain** and **Data** layers after Phase 2 completion.

---

## 1.  Basic Setup
```dart
import 'package:finance/core/di/injection.dart';
import 'package:finance/features/budgets/domain/repositories/budget_repository.dart';
import 'package:finance/features/budgets/domain/services/budget_filter_service.dart';
import 'package:finance/features/budgets/domain/services/budget_update_service.dart';

final budgetRepository      = getIt<BudgetRepository>();
final budgetFilterService   = getIt<BudgetFilterService>();
final budgetUpdateService   = getIt<BudgetUpdateService>();
```
`BudgetRepository` handles CRUD operations; `BudgetFilterService` performs heavy-weight filtering & calculations;  
`BudgetUpdateService` provides real-time streams that update automatically when transactions change.

---

## 2. Budget Types & Modes

Before creating a budget, it's important to understand the two main types and two primary modes of operation.

### 2.1 Budget Types: Expense vs. Income

-   **Expense Budget (Default):** This is the standard budget type for tracking spending. Set `isIncomeBudget: false`.
-   **Income Budget:** This type allows you to track income against a target. For example, you can create a budget to monitor if you've reached a monthly freelance income goal. Set `isIncomeBudget: true`.

### 2.2 Budget Modes: Automatic vs. Manual

-   **Automatic Mode (Wallet-Based):** This is the standard mode where the budget automatically tracks all transactions from specific wallets (`walletFks`). This is the most common use case.
-   **Manual Mode (No Wallets):** By **not** providing any `walletFks`, the budget enters "Manual Mode". In this mode, no transactions are tracked automatically. You must manually link individual transactions to the budget. This is useful for event-specific budgets (e.g., a "Vacation" budget) where you want to hand-pick expenses from multiple wallets.

---

## 3.  Reading Budgets
### 3.1 Get All Budgets
```dart
final budgets = await budgetRepository.getAllBudgets();
```

### 3.2 Get Single Budget
```dart
final budget = await budgetRepository.getBudgetById(budgetId);
```

### 3.3 Watch Real-Time Updates
```dart
final sub = budgetUpdateService.watchAllBudgetUpdates().listen((budgets) {
  // rebuild UI
});
```

> **Tip:** call `sub.cancel()` during `dispose()` to avoid memory leaks.

---

## 4.  Creating Budgets
### 4.1 Minimal Budget
```dart
final newBudget = Budget(
  name:        'Groceries – May',
  amount:      500,
  spent:       0,
  period:      BudgetPeriod.monthly,
  categoryId:  15,
  startDate:   DateTime(2024, 5, 1),
  endDate:     DateTime(2024, 5, 31),
  isActive:    true,
  createdAt:   DateTime.now(),
  updatedAt:   DateTime.now(),
  syncId:      '',
);
await budgetRepository.createBudget(newBudget);
```

### 4.2 Budget With Advanced Filters
```dart
final vacationBudget = Budget(
  name:  'Vacation in Japan',
  amount: 2000,
  spent:  0,
  period: BudgetPeriod.yearly,
  startDate: DateTime(2024, 10, 1),
  endDate:   DateTime(2024, 10, 20),
  walletFks: ['2', '4'],
  currencyFks: ['JPY'],
  excludeDebtCreditInstallments: true,
  excludeObjectiveInstallments: true,
  normalizeToCurrency: 'USD',
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncId: '',
);
await budgetRepository.createBudget(vacationBudget);
```

---

## 5.  Calculations & Filtering
### 5.1 Calculate Spent & Remaining
```dart
final spent      = await budgetFilterService.calculateBudgetSpent(vacationBudget);
final remaining  = await budgetFilterService.calculateBudgetRemaining(vacationBudget);
print('Spent: $spent  Remaining: $remaining');
```

### 5.2 Get Filtered Transactions
```dart
final txns = await budgetFilterService.getFilteredTransactionsForBudget(
  vacationBudget,
  vacationBudget.startDate,
  vacationBudget.endDate,
);
```

---

## 6. Advanced Transaction Filtering

For highly specific scenarios, you can use the `budgetTransactionFilters` map to apply low-level filters. This gives you direct control over which transactions are included in the budget's calculation.

-   **Enum Location**: `lib/features/budgets/domain/entities/budget_enums.dart`

```dart
import 'package:finance/features/budgets/domain/entities/budget_enums.dart';

final filteredBudget = Budget(
  // ... other properties
  budgetTransactionFilters: {
    'filterType': BudgetTransactionFilter.customFilter.index,
    'includeTags': ['#business'],
    'excludeTags': ['#personal-expense'],
  }
);
```

This feature is powerful but should be used with caution, as it can lead to complex and hard-to-debug budget behaviors.

---

## 7. Shared Budgets
The app supports a "Shared Budget" feature, where a primary budget can be linked to other budgets. This is useful for creating a master budget (e.g., "Total Household Expenses") that aggregates spending from several smaller, more specific budgets (e.g., "Groceries," "Utilities"). This system uses the `BudgetShareType` and `MemberExclusionType` enums to manage permissions and visibility.

-   `sharedReferenceBudgetPk`: The `syncId` of the master budget you want to link to.
-   `budgetFksExclude`: A list of budget `syncId`s to explicitly exclude from the shared calculation, preventing double-counting.

This feature is powerful but requires careful management of the relationships between budgets in your UI.

---

## 8. Real-Time Streams
After you inject `BudgetUpdateService`, every time a transaction is **created / updated / deleted** the service recomputes affected budgets and emits updated values.
```dart
// Listen to spent-amount deltas only
budgetUpdateService.watchBudgetSpentAmounts().listen((map) {
  final spent = map[budgetId] ?? 0;
});

// Force a full recalculation (e.g. after bulk CSV import)
await budgetUpdateService.recalculateAllBudgetSpentAmounts();
// Or just one budget
await budgetUpdateService.recalculateBudgetSpentAmount(budgetId);
```

---

## 9. CSV Import / Export
The helper `BudgetCsvService` wraps the `csv` and `share_plus` packages.
```dart
import 'package:finance/features/budgets/data/services/budget_csv_service.dart';
final csvService = BudgetCsvService();

// Export single budget
await csvService.exportBudgetToCSV(vacationBudget, 'vacation_budget.csv');

// Export multiple budgets at once
await csvService.exportBudgetsToCSV(budgets);
```

To **import** budgets back:
```dart
final imported = await csvService.importBudgetsFromCSV(filePath);
for (final b in imported) {
  await budgetRepository.createBudget(b);
}
```

---

## 10. Biometric Protection (Optional)
Enable biometric authentication before showing sensitive budget details:
```dart
final authOK = await budgetUpdateService.authenticateForBudgetAccess();
if (!authOK) {
  // show error / blur UI
}
```

---

## 11. Common Gotchas
1.  **Currency Normalisation** applies *after* filtering; make sure exchange-rate cache is fresh.
2.  **Transfer Transactions** with same-currency are excluded by default until you set `includeTransferInOutWithSameCurrency = true`.
3.  **Upcoming Transactions** are only included in calculations if you set `includeUpcomingTransactionFromBudget = true`.
4.  **Spent Field** inside `Budget` is **read-only** – update it via `BudgetUpdateService` or let the system handle it.
5.  **Objective Installments** are excluded only when you set `excludeObjectiveInstallments = true`.

---

## 12. Quick BLoC Example
```dart
class BudgetOverviewBloc extends Bloc<BudgetsEvent, BudgetsState> {
  BudgetOverviewBloc() : super(BudgetsInitial()) {
    on<LoadAllBudgets>((_, emit) async {
      final budgets = await budgetRepository.getAllBudgets();
      emit(BudgetsLoaded(budgets: budgets));
    });
  }
}
```

---

## 13. Further Reading
• `lib/features/budgets/data/services/budget_filter_service_impl.dart` – full filtering logic.  
• `docs/plan/TransactionsBudget/PHASE_2_IMPLEMENTATION_GUIDE.md` – detailed design doc.  
• `test/features/budgets/budget_filter_service_test.dart` – sample unit tests.

Enjoy budgeting! :moneybag: 