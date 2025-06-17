// Advanced transaction type enums for extended functionality
// This file defines the enums needed for subscription/recurring payments, 
// loans, credit/debt tracking, and advanced transaction states/actions.

/// Type of transaction - regular income/expense vs special types like loans
enum TransactionType {
  /// Regular income transaction
  income,
  /// Regular expense transaction
  expense,
  /// Transfer between accounts (future use)
  transfer,
  /// Subscription or recurring payment
  subscription,
  /// Loan-related transaction (credit/debt)
  loan,
  /// Adjustment or correction transaction
  adjustment,
}

/// Special transaction types for loan and credit/debt tracking
/// This follows the pattern from FromAnotherProject.md
enum TransactionSpecialType {
  /// Credit - money lent to someone else
  credit,
  /// Debt - money borrowed from someone else  
  debt,
}

/// Recurrence pattern for subscription/recurring transactions
/// Based on BudgetReoccurrence from FromAnotherProject.md
enum TransactionRecurrence {
  /// No recurrence (one-time transaction)
  none,
  /// Recurring daily
  daily,
  /// Recurring weekly
  weekly,
  /// Recurring monthly
  monthly,
  /// Recurring yearly
  yearly,
}

/// State of a transaction for action management
/// This supports the advanced state/action system
enum TransactionState {
  /// Regular completed transaction
  completed,
  /// Pending transaction (not yet processed)
  pending,
  /// Scheduled for future (recurring transactions)
  scheduled,
  /// Cancelled transaction
  cancelled,
  /// Transaction that needs action (loan collection/settlement)
  actionRequired,
}

/// Available actions that can be performed on a transaction
/// Based on the action button system from FromAnotherProject.md
enum TransactionAction {
  /// No action available
  none,
  /// Pay a pending transaction
  pay,
  /// Skip a scheduled transaction
  skip,
  /// Unpay a paid transaction (reverse)
  unpay,
  /// Collect money (for credit transactions)
  collect,
  /// Settle debt (for debt transactions)
  settle,
  /// Edit transaction details
  edit,
  /// Delete transaction
  delete,
}
