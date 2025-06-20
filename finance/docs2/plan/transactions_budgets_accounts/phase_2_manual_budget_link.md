# Phase 2 – Manual-Add Budgets (Explicit Transaction ↔ Budget Link)

> **Priority**: HIGH | **Est. Effort**: 2 – 3 days | **Owner**: _backend + data_

## 1  Problem Statement

Automatic budgets are already calculated via filters.  Users also need "Manual-Add" budgets (Vacation, Wedding, …) that include only **transactions explicitly chosen** by the user from the Add / Edit Transaction screen.

## 2  Proposed Solution

Introduce a join table **`transaction_budgets`** (many-to-many) that stores `(transaction_id INT, budget_id INT, amount REAL)`.  `amount` allows future partial allocation if a tx should be split across budgets.

## 3  Database Changes

1. Create new Drift table:

```dart
class TransactionBudgetsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer()();
  IntColumn get budgetId => integer()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();

  // foreign keys (optional strict)
  @override
  List<String> get customConstraints => [
    'FOREIGN KEY(transaction_id) REFERENCES transactions(id)',
    'FOREIGN KEY(budget_id) REFERENCES budgets(id)'  
  ];
}
```

2. Migration: add table in `onUpgrade` when `from ≤ X`.

## 4  Domain Layer

* Create entity `TransactionBudgetLink` mirroring the table.
* Add
  ```dart
  Future<void> addTransactionToBudget(int transactionId, int budgetId, {double? amount});
  Future<void> removeTransactionFromBudget(int transactionId, int budgetId);
  Future<List<Budget>> getBudgetsForTransaction(int transactionId);
  Future<List<Transaction>> getTransactionsForBudget(int budgetId);
  ```
  to `BudgetRepository` or a dedicated `ManualBudgetRepository`.

## 5  Service & Business Logic

* Update **`BudgetFilterServiceImpl`**: when `budget.walletFks == null` *and* `manualAddMode == true` (new getter), use the join table instead of filters.
* Add utility to compute allocated / unallocated amount per transaction.

## 6  UI/API Contract

* **Add/Edit Transaction Screen**: optional chips list of Manual budgets; multi-select allowed.
* **Budget Detail**: list transactions via new `getTransactionsForBudget`.

> _UI code is not in this phase; expose the API & tests only._

## 7  Testing Strategy

| Test | Description |
|------|-------------|
| Unit – Repository | CRUD on `transaction_budgets` works, duplicates prevented |
| Unit – BudgetFilterService | `calculateBudgetSpent` reflects only linked txns |
| Integration | Create budget, link tx, unlink tx, totals update |

## 8  Risks / Considerations

1. **Cascade delete** – when a transaction or budget is deleted, related join rows must be purged.  Use `ON DELETE CASCADE` or manual repository cleanup.
2. **Sync payload size** – join table must be included in event log & Drive serialisation.
3. **Performance** – add compound index `(budget_id, transaction_id)`.

## 9  Done Definition

- [x] Schema migration + tests pass (AppDatabase v10 migration adds transaction_budgets table; full test suite green).
- [x] Repositories expose new APIs (`addTransactionToBudget`, `removeTransactionFromBudget`, query helpers, etc.).
- [x] All existing budget logic unaffected for automatic budgets (verified by updated integration tests).
- [x] Coverage ≥ 90 % on new code (see CI badge).
- [x] Roadmap checkbox ticked.

### ✅ Implementation Summary (2025-06-20)

The `transaction_budgets` join table is live (schema version 10) with cascade-delete FK constraints and event-sourcing triggers. Domain entity `TransactionBudgetLink` plus repository and service extensions enable CRUD operations + spent-amount calculations. Integration tests confirm correct linkage behaviour and no regression to automatic-filter budgets. UI hooks will be wired in Phase 3 UI work. 