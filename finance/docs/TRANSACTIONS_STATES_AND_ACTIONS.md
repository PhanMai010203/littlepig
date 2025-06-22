# Advanced Guide: Transaction States, Partial Payments, and Actions

This guide provides a detailed look into the lifecycle of advanced transaction types, including their states, how partial loan payments are handled, and the actions available to the user.

-   **Related Enums**: `lib/features/transactions/domain/entities/transaction_enums.dart`
-   **Core Logic**: `lib/features/transactions/domain/entities/transaction.dart`

---

## 1. Transaction States (`TransactionState`)

The `TransactionState` enum defines the status of a transaction within the system. This is crucial for filtering, displaying, and determining available actions.

| State | Description |
|---|---|
| `completed` | A standard, finalized transaction. This is the most common state. |
| `pending` | A transaction that has been created but not yet confirmed or paid. Common for future bills that have arrived but are not yet due. |
| `scheduled` | A future instance of a recurring transaction or subscription that has not yet occurred. The system creates these automatically based on the recurrence rules. |
| `cancelled` | A transaction that has been voided. It is kept for historical purposes but has no financial impact. |
| `actionRequired` | A special state for loans, indicating that a payment is due to be collected (for credit you gave) or settled (for a debt you owe). |

---

## 2. Partial Loan Payments

The system supports partial payments for loans (both credit and debt). This is handled by a parent-child relationship between transaction records.

-   **The Parent Loan**: The initial transaction that creates the loan (`isLoan == true`). It has a `null` `parentTransactionId`. The `remainingAmount` field on this transaction is updated as payments are made.
-   **The Payment**: When a user makes a payment on the loan, a new, separate transaction is created. This new transaction will have its `parentTransactionId` set to the `id` of the original loan transaction.

### Example Flow:

1.  You create a **Debt** transaction for \$100 that you borrowed.
    -   `id: 50`, `specialType: debt`, `amount: 100`, `remainingAmount: 100`, `parentTransactionId: null`
2.  You make a partial payment of \$20.
    -   A new transaction is created: `id: 88`, `amount: -20`, `parentTransactionId: 50`
    -   The original loan transaction is updated: `id: 50`, `remainingAmount: 80`
3.  This continues until `remainingAmount` on the parent loan is `0`.

---

## 3. Available Actions (`TransactionAction`)

The UI presents users with different actions based on the transaction's current state and type. This logic is centralized in the `get availableActions` getter on the `Transaction` entity.

This ensures that users can only perform valid operations, creating a more intuitive experience.

| Action | When is it available? |
|---|---|
| `edit`, `delete` | Almost always available, except in some locked-down scenarios. |
| `pay`, `skip` | Available for `pending` and `scheduled` transactions. `pay` confirms it, `skip` cancels that specific instance. |
| `unpay` | Reverts a `completed` recurring transaction back to its previous state. |
| `collect` | Appears on an `actionRequired` credit transaction (when someone needs to pay you). |
| `settle` | Appears on an `actionRequired` debt transaction (when you need to pay someone). |

By checking the `transaction.availableActions` list, the UI can dynamically build context menus or buttons, ensuring consistency throughout the app. 