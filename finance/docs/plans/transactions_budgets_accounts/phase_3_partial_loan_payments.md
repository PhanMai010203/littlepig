# Phase 3 – Partial Loan Collection & Settlement

> **Priority**: MEDIUM | **Est. Effort**: 3 – 4 days | **Owner**: _backend + domain_

## 1  Goal

Support collecting / settling **partial amounts** on credit (lent) and debt (borrowed) transactions while preserving full audit history.

## 2  High-Level Approach

We will **not mutate** the original loan transaction's `amount`.  Instead we create **child payment transactions** referencing the parent loan and invert their sign appropriately:

* For a **credit** (money lent, `amount < 0`) – when user collects 50 €, create a *positive* `collection` transaction of +50.
* For a **debt** (money borrowed, `amount > 0`) – when user settles 50 €, create a *negative* `settlement` transaction of −50.

Parent transaction stores `remainingAmount`.  Once it hits 0 → parent state becomes `completed`.

## 3  Schema Changes

1. **TransactionsTable**
   * Add `remainingAmount REAL` (default = `abs(amount)`).
   * Add `parentTransactionId INT` (nullable) to chain child payments.
2. Migration logic: when upgrading, set `remainingAmount = abs(amount)` for existing loans; null for others.

## 4  Domain Updates

* Extend `Transaction` entity:
  ```dart
  final double? remainingAmount; // null for regular txns
  final int?    parentTransactionId; // null for parents
  bool get isLoanPayment => parentTransactionId != null;
  ```
* Add use-cases:
  ```dart
  Future<void> collectPartialCredit({required Transaction credit, required double amount});
  Future<void> settlePartialDebt({required Transaction debt, required double amount});
  ```

## 5  Business Rules

1. `amount` of child payment **must not** exceed `remainingAmount`.
2. After each child insertion, recompute parent `remainingAmount` (= old − collected/settled) and update `transactionState` to `completed` when `0`.
3. Child payments inherit `categoryId` & `accountId` of parent.
4. `skipPaid` / `paid` flags remain on parent only.

## 6  Repository Implementation Steps

1. Add CRUD for child payments (reuse normal `createTransaction`).
2. Wrap steps above in atomic transaction (Drift `transaction{}` block).
3. Expose `getLoanPayments(int parentId)` helper.

## 7  Budget Interaction

Payments **must** count towards budgets just like normal transactions (automatic or manual), therefore they do not bypass existing filters.

## 8  Testing Matrix

| Scenario | Expected |
|----------|----------|
| Collect less than remaining | `remainingAmount` decreases; state stays `actionRequired` |
| Collect full remaining | `remainingAmount == 0`; state becomes `completed` |
| Attempt over-collect | Repository throws `OverCollectionException` |
| Budget spent update | Spent increases by collected amount |

Create unit tests + integration test verifying database rows.

## 9  UX Hooks (out of scope)

Return helper `double getRemainingAmount(Transaction loan)` so UI can render progress bar.

## 10  Done Definition

- [ ] Schema migration successful with data back-fill.
- [ ] API `collectPartialCredit/settlePartialDebt` works & documented.
- [ ] Unit + integration tests pass.
- [ ] CI green; roadmap checkbox ticked. 