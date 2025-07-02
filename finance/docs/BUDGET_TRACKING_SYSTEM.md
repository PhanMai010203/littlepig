# Budget Tracking System – Frontend Development Guide

## 1. Overview
Welcome to the developer guide for the Budget Tracking System. This document provides a comprehensive overview of the architecture, state management, and key components of the budget feature, with a focus on frontend development.

The budget module lets you create, filter, and monitor budgets with advanced rules such as wallet or currency scopes, debt-credit exclusions, and real-time spent calculations. It's built around the **BLoC (Business Logic Component)** pattern to ensure a clear separation of concerns and a reactive, predictable UI.

---

## 2. Core Concepts

### 2.1 Budget Types: Expense vs. Income

-   **Expense Budget (Default):** This is the standard budget type for tracking spending. Set `isIncomeBudget: false`.
-   **Income Budget:** This type allows you to track income against a target. For example, you can create a budget to monitor if you've reached a monthly freelance income goal. Set `isIncomeBudget: true`.

### 2.2 Budget Modes: Automatic vs. Manual

-   **Automatic Mode (Wallet-Based):** This is the standard mode where the budget automatically tracks all transactions from specific wallets (`walletFks`). This is the most common use case.
-   **Manual Mode (No Wallets):** By **not** providing any `walletFks`, the budget enters "Manual Mode". In this mode, no transactions are tracked automatically. You must manually link individual transactions to the budget. This is useful for event-specific budgets (e.g., a "Vacation" budget) where you want to hand-pick expenses from multiple wallets. The `budget.manualAddMode` getter can be used to check this in the UI.

   **Implementation Note (v2):** The creation wizard relies on the `BudgetTrackingType` enum (`manual` | `automatic`) defined in `lib/features/budgets/domain/entities/budget_enums.dart`. The enum drives the form logic, but the final mode is still determined by whether `walletFks` is present (automatic) or omitted (manual).

---

## 3. BLoC State Management (for Frontend)

The entire budget feature is orchestrated by the `BudgetsBloc`, which manages the state and business logic. Here's how the pieces fit together.

### 3.1 State Flow Diagram
```
BudgetsInitial -> BudgetsLoading -> BudgetsLoaded (with real-time updates)
                                -> BudgetsError

BudgetDetailsLoading -> BudgetDetailsLoaded (with history & daily allowance)
                    -> BudgetDetailsError
```

### 3.2 BudgetsState - UI State Representation
These states represent all possible UI states in the budget feature. Each state contains the data needed to render the corresponding UI.

#### `BudgetsInitial`
The starting state before any budget data has been loaded.
**UI Action:** Trigger `LoadAllBudgets` event.

#### `BudgetsLoading`
Indicates that budget data is currently being fetched.
**UI Action:** Show a loading indicator (e.g., `CircularProgressIndicator`).

#### `BudgetsError` / `BudgetDetailsError`
Indicates an error occurred.
**UI Action:** Display an error message and a "Retry" button.

#### `BudgetsLoaded`
This is the primary state for the budget list page. It contains all the data needed for the budget overview.
-   `budgets`: `List<Budget>` - The list of all budgets.
-   `realTimeSpentAmounts`: `Map<int, double>` - Live spending data for each budget.
-   `dailySpendingAllowances`: `Map<int, double>` - Recommended daily spending to stay on track.
-   `isRealTimeActive`: `bool` - Indicates if live updates are connected.
-   `authenticatedBudgets`: `Map<int, bool>` - Tracks which budgets are unlocked via biometrics.
-   `isExporting` & `exportStatus`: `bool`, `String?` - For showing export progress.

**UI Example:**
```dart
if (state is BudgetsLoaded) {
  return ListView.builder(
    itemCount: state.budgets.length,
    itemBuilder: (context, index) {
      final budget = state.budgets[index];
      final spent = state.realTimeSpentAmounts[budget.id] ?? 0.0;
      final dailyAllowance = state.dailySpendingAllowances[budget.id] ?? 0.0;
      
      return BudgetCard(
        budget: budget,
        spentAmount: spent,
        dailyAllowance: dailyAllowance,
        isManual: budget.manualAddMode,
      );
    },
  );
}
```

#### `BudgetDetailsLoading`
Indicates that details for a single budget are being fetched.
**UI Action:** Show a loading indicator on the details page.

#### `BudgetDetailsLoaded`
Contains detailed information for a single budget, including its history.
-   `budget`: `Budget` - The specific budget being viewed.
-   `history`: `List<BudgetHistoryEntry>` - Performance from past periods.
-   `dailySpendingAllowance`: `double` - The daily spending allowance for the current period.

**UI Example:**
```dart
if (state is BudgetDetailsLoaded) {
  return DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(title: Text(state.budget.name)),
      body: TabBarView(
        children: [
          BudgetOverviewTab(budget: state.budget, ...),
          BudgetHistoryTab(history: state.history),
          BudgetSettingsTab(budget: state.budget),
        ],
      ),
    ),
  );
}
```

#### Authentication States
- `BudgetAuthenticationRequired`: UI should show a locked/blurred view and a button to trigger `AuthenticateForBudgetAccess`.
- `BudgetAuthenticationSuccess`: UI can now show the sensitive budget details.
- `BudgetAuthenticationFailed`: UI should show an error message.

#### `BudgetCreationState`
This state powers the multi-step *Create / Edit Budget* flow.

Key fields you are most likely to bind to UI controls:

- `trackingType`: `BudgetTrackingType` – determines whether the wizard shows account selectors (`automatic`) or transaction-linking UI (`manual`). Convenience getters `isManual` and `isAutomatic` are available.
- `availableAccounts` / `selectedAccounts` / `isAllAccountsSelected`
- `availableCategories`, `includedCategories`, `excludedCategories`, `isAllCategoriesIncluded`
- `isAccountsLoading`, `isCategoriesLoading` – show loading indicators while data is fetched.

Helper getters:

- `shouldShowAccountsSelector` – `true` when `trackingType.isAutomatic`.
- `shouldReduceIncludeCategoriesOpacity` – `true` when any categories are excluded, useful for subtle UI hints.

---

## 3.3 BudgetsEvent - User Actions
These events represent user interactions and system triggers. Dispatch them to the `BudgetsBloc` to perform actions.

-   `LoadAllBudgets`: Fetches all budgets for the main list view. Call this in `initState` or on pull-to-refresh.
-   `LoadBudgetDetails(budgetId)`: Fetches detailed data for a single budget. Call this when a user taps on a budget item.
-   `CreateBudget(budget)`: Creates a new budget.
-   `UpdateBudget(budget)`: Updates an existing budget.
-   `DeleteBudget(budgetId)`: Deletes a budget.
-   `StartRealTimeUpdates` / `StopRealTimeUpdates`: Handled automatically by the BLoC, but can be used to manage resources (e.g., in `dispose`).
-   `AuthenticateForBudgetAccess(budgetId)`: Triggers biometric authentication.
-   `RecalculateAllBudgets` / `RecalculateBudget(budgetId)`: Forces a manual recalculation of spent amounts. Useful for pull-to-refresh.
-   `ExportBudgetData(budget)` / `ExportMultipleBudgets(budgets)`: Triggers a CSV export.
-   `BudgetTrackingTypeChanged(trackingType)`: Switches between *Automatic* and *Manual* during creation.
-   `LoadAccountsForBudget` / `LoadCategoriesForBudget`: Fetches data for selectors in the creation wizard.
-   `BudgetAccountsSelected(selectedAccounts, isAllSelected)`
-   `BudgetIncludeCategoriesSelected(selectedCategories, isAllSelected)`
-   `BudgetExcludeCategoriesSelected(selectedCategories)`

**Example: Creating a Budget**
```dart
// Create an automatic budget (tracks all grocery spending from checking account)
final automaticBudget = Budget(
  name: 'Monthly Groceries',
  amount: 400.0,
  walletFks: ['checking-account-id'], // Makes it automatic
  categoryId: groceryCategoryId,
  excludeDebtCreditInstallments: true, // Exclude loan payments
  period: BudgetPeriod.monthly,
  // ... other fields
);
context.read<BudgetsBloc>().add(CreateBudget(automaticBudget));

// Create a manual budget (user manually links vacation expenses)
final manualBudget = Budget(
  name: 'Vacation Fund',
  amount: 2000.0,
  walletFks: null, // Makes it manual - no automatic tracking
  period: BudgetPeriod.yearly,
  // ... other fields
);
context.read<BudgetsBloc>().add(CreateBudget(manualBudget));
```

**Example: Navigating to the Create Budget Page**
To open the dedicated page for creating a new budget, use `GoRouter`:

```dart
// In your widget, likely on a button press
context.push(AppRoutes.budgetCreate);
```

### 3.4 BudgetsBloc - Business Logic
The `BudgetsBloc` is the central coordinator. Its key responsibilities include:
-   Responding to UI events (`BudgetsEvent`).
-   Interacting with repositories and services (`BudgetRepository`, `BudgetUpdateService`, `BudgetFilterService`).
-   Emitting new states (`BudgetsState`) for the UI to consume.
-   **Calculating Daily Spending Allowance:** Determines how much the user can spend per day to stay within the budget period limit. This value is provided in the `BudgetsLoaded` and `BudgetDetailsLoaded` states.
-   **Managing Real-time Updates:** Subscribes to streams from `BudgetUpdateService` to provide live updates to spent amounts and budget data without requiring manual refreshes.

---

## 4. Key Data Entities

### 4.1 `Budget`
The core entity representing a single budget.
-   **Key Fields**: `id`, `name`, `amount`, `spent`, `period`, `startDate`, `endDate`.
-   **Filtering**: `categoryId`, `walletFks`, `currencyFks`, `excludeDebtCreditInstallments`.
-   **Mode**: `manualAddMode` (getter) returns `true` if `walletFks` is null/empty.
-   **Computed Properties**: `remaining`, `percentageSpent`, `isOverBudget`.

### 4.2 `BudgetHistoryEntry`
Represents a single historical performance record for a budget in a past period. This is used for the "History" tab.
-   **Key Fields**: `periodName`, `totalSpent`, `totalBudgeted`.
-   **Computed Properties**: `difference`, `utilizationPercentage`, `isUnderBudget`, `isOverBudget`, `absoluteDifference`.

**UI Example for History:**
```dart
ListView.builder(
  itemCount: historyEntries.length,
  itemBuilder: (context, index) {
    final entry = historyEntries[index];
    final isOverBudget = entry.isOverBudget;
    return ListTile(
      title: Text(entry.periodName),
      subtitle: Text('Spent: \$${entry.totalSpent.toStringAsFixed(2)}'),
      trailing: Text(
        isOverBudget 
          ? 'Over by \$${entry.absoluteDifference.toStringAsFixed(2)}'
          : 'Under by \$${entry.absoluteDifference.toStringAsFixed(2)}',
        style: TextStyle(color: isOverBudget ? Colors.red : Colors.green),
      ),
    );
  },
)
```

### 4.3 `TransactionBudgetLink`
An entity that links a `Transaction` to a `Budget`. This is primarily used for **manual mode** budgets to track which transactions have been hand-picked by the user.

### 4.4 `BudgetPeriod` and Other Enums
The main enums live in `lib/features/budgets/domain/entities/budget_enums.dart`, except for `BudgetPeriod`, which is declared directly in `budget.dart` along with the `Budget` class.

| Enum | Location | Notes |
|------|----------|-------|
| `BudgetPeriod` | `lib/features/budgets/domain/entities/budget.dart` | Core period enum used by the mobile UI (`daily`, `weekly`, `monthly`, `yearly`). |
| `BudgetTrackingType` | `budget_enums.dart` | `manual` vs `automatic` with helper getters. |
| `BudgetPeriodType` | `budget_enums.dart` | Broader presets used by other layers (`weekly`, `biweekly`, `monthly`, `quarterly`, `yearly`, `custom`). |
| `BudgetTransactionFilter` | `budget_enums.dart` | Advanced low-level filtering. |
| `BudgetShareType` | `budget_enums.dart` | Options for shared/household budgets. |

---

## 5. Data Layer and Services (Brief)

The frontend primarily interacts with the `BudgetsBloc`. However, it's good to be aware of the underlying services.

-   `BudgetRepository`: Handles basic CRUD operations for `Budget` entities.
-   `BudgetFilterService`: Performs complex calculations like `calculateBudgetSpent` and fetching filtered transactions. This is used by the BLoC internally.
-   `BudgetUpdateService`: Provides real-time streams (`watchAllBudgetUpdates`, `watchBudgetSpentAmounts`) that the BLoC subscribes to. This service is the magic behind the live updates.
-   `BudgetCsvService`: Handles CSV import and export functionality.

---

## 6. Outstanding TODOs

-   **Implement Budget History Calculation**: The history data in `BudgetDetailsLoaded` is currently a placeholder. The logic needs to be implemented in `BudgetFilterService` to calculate past period performance for both automatic and manual budgets.
    -   *Location:* `_onLoadBudgetDetails` in `budgets_bloc.dart`.

---

## 7. Quick BLoC Provider Example
To use the `BudgetsBloc`, you'll provide it to the widget tree, typically at the page level.

```dart
// In your budgets_page.dart
class BudgetsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create and provide the BudgetsBloc, and immediately trigger the event to load all budgets.
      create: (context) => getIt<BudgetsBloc>()..add(LoadAllBudgets()),
      child: Scaffold(
        // ... build your UI using BlocBuilder/BlocListener
      ),
    );
  }
}
```

Enjoy budgeting! :moneybag: 