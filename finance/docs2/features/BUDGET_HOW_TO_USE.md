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

## 2.  Reading Budgets
### 2.1 Get All Budgets
```dart
final budgets = await budgetRepository.getAllBudgets();
```

### 2.2 Get Single Budget
```dart
final budget = await budgetRepository.getBudgetById(budgetId);
```

### 2.3 Watch Real-Time Updates
```dart
final sub = budgetUpdateService.watchAllBudgetUpdates().listen((budgets) {
  // rebuild UI
});
```

> **Tip:** call `sub.cancel()` during `dispose()` to avoid memory leaks.

---

## 3.  Creating Budgets
### 3.1 Minimal Budget
```dart
final newBudget = Budget(
  name:        'Groceries – May',
  amount:      500,
  spent:       0,                // repository keeps this in sync
  period:      BudgetPeriod.monthly,
  startDate:   DateTime(2024, 5, 1),
  endDate:     DateTime(2024, 5, 31),
  isActive:    true,
  createdAt:   DateTime.now(),
  updatedAt:   DateTime.now(),
  syncId:      '',               // leave blank – generated automatically
);
await budgetRepository.createBudget(newBudget);
```

### 3.2 Budget With Advanced Filters
```dart
final vacationBudget = Budget(
  name:  'Vacation in Japan',
  amount: 2000,
  spent:  0,
  period: BudgetPeriod.custom,
  startDate: DateTime(2024, 10, 1),
  endDate:   DateTime(2024, 10, 20),
  walletFks: ['2', '4'],                 // limit to debit-card + cash wallets
  currencyFks: ['JPY'],                  // only JPY transactions
  excludeDebtCreditInstallments: true,   // ignore credit-card repayments
  excludeObjectiveInstallments: true,    // ignore objective/loan installments
  normalizeToCurrency: 'USD',            // show totals in USD
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncId: '',
);
await budgetRepository.createBudget(vacationBudget);
```

---

## 4.  Calculations & Filtering
### 4.1 Calculate Spent & Remaining
```dart
final spent      = await budgetFilterService.calculateBudgetSpent(vacationBudget);
final remaining  = await budgetFilterService.calculateBudgetRemaining(vacationBudget);
print('Spent: $spent  Remaining: $remaining');
```

### 4.2 Get Filtered Transactions
```dart
final txns = await budgetFilterService.getFilteredTransactionsForBudget(
  vacationBudget,
  vacationBudget.startDate,
  vacationBudget.endDate,
);
```

---

## 5.  Real-Time Streams
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

## 6.  CSV Import / Export
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

## 7.  Biometric Protection (Optional)
Enable biometric authentication before showing sensitive budget details:
```dart
final authOK = await budgetUpdateService.authenticateForBudgetAccess();
if (!authOK) {
  // show error / blur UI
}
```

---

## 8.  Common Gotchas
1. **Currency Normalisation** applies *after* filtering; make sure exchange-rate cache is fresh.  
2. **Transfer Transactions** with same-currency are excluded by default until you set `includeTransferInOutWithSameCurrency = true`.  
3. **Spent Field** inside `Budget` is **read-only** – update it via `BudgetUpdateService` or let the system handle it.  
4. **Objective Installments** are excluded only when you set `excludeObjectiveInstallments = true`.

---

## 9.  Quick BLoC Example
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

## 10.  Further Reading
• `lib/features/budgets/data/services/budget_filter_service_impl.dart` – full filtering logic.  
• `docs/plan/TransactionsBudget/PHASE_2_IMPLEMENTATION_GUIDE.md` – detailed design doc.  
• `test/features/budgets/budget_filter_service_test.dart` – sample unit tests.

Enjoy budgeting! :moneybag: 