# Transactions: Advanced Features

This guide covers advanced transaction functionalities, including subscriptions, loans, and different transaction states.

## Advanced Transaction Features (Phase 1)

The transaction system now supports advanced features including:
- **Notes Field**: A unified field for additional transaction information and context
- **Subscriptions/Recurring Payments**: Automatic recurring transactions
- **Loan System**: Credit/debt tracking with collection/settlement
- **Transaction States**: Pending, scheduled, completed, cancelled, action required
- **Advanced Actions**: Pay, skip, collect, settle based on transaction state

### Transaction Types

```dart
enum TransactionType {
  income,       // Regular income transaction
  expense,      // Regular expense transaction  
  transfer,     // Transfer between accounts (future use)
  subscription, // Subscription or recurring payment
  loan,         // Loan-related transaction (credit/debt)
  adjustment,   // Adjustment or correction transaction
}
```

### Special Transaction Types (for Loans)

```dart
enum TransactionSpecialType {
  credit, // Money lent to someone else
  debt,   // Money borrowed from someone else
}
```

### Recurrence Patterns

```dart
enum TransactionRecurrence {
  none,    // No recurrence (one-time transaction)
  daily,   // Recurring daily
  weekly,  // Recurring weekly
  monthly, // Recurring monthly
  yearly,  // Recurring yearly
}
```

### Transaction States

```dart
enum TransactionState {
  completed,      // Regular completed transaction
  pending,        // Pending transaction (not yet processed)
  scheduled,      // Scheduled for future (recurring transactions)
  cancelled,      // Cancelled transaction
  actionRequired, // Transaction that needs action (loan collection/settlement)
}
```

### Available Actions

```dart
enum TransactionAction {
  none,     // No action available
  pay,      // Pay a pending transaction
  skip,     // Skip a scheduled transaction
  unpay,    // Unpay a paid transaction (reverse)
  collect,  // Collect money (for credit transactions)
  settle,   // Settle debt (for debt transactions)
  edit,     // Edit transaction details
  delete,   // Delete transaction
}
```

## Creating Advanced Transactions

### Create Subscription/Recurring Transaction

```dart
// Create a monthly subscription
final subscription = Transaction(
  title: 'Netflix Subscription',
  note: 'Monthly video streaming service',
  amount: -9.99,
  categoryId: entertainmentCategoryId,
  accountId: bankAccountId,
  date: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncId: '',
  
  // Advanced fields for subscription
  transactionType: TransactionType.subscription,
  recurrence: TransactionRecurrence.monthly,
  periodLength: 1, // Every 1 month
  endDate: DateTime.now().add(Duration(days: 365)), // Auto-cancel after 1 year
  transactionState: TransactionState.scheduled,
  paid: false,
);

final createdSubscription = await transactionRepository.createTransaction(subscription);
```

### Create Credit Transaction (Money Lent)

```dart
// Create a transaction for money lent to someone
final creditTransaction = Transaction(
  title: 'Money Lent to John',
  note: 'Lent money for car repair - To be repaid by end of month',
  amount: -500.00, // Negative because money is leaving your account
  categoryId: personalCategoryId,
  accountId: savingsAccountId,
  date: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncId: '',
  
  // Advanced fields for credit
  transactionType: TransactionType.loan,
  specialType: TransactionSpecialType.credit,
  transactionState: TransactionState.actionRequired,
  paid: true, // Initially true (money was given out)
);

final createdCredit = await transactionRepository.createTransaction(creditTransaction);
```

### Create Debt Transaction (Money Borrowed)

```dart
// Create a transaction for money borrowed from someone
final debtTransaction = Transaction(
  title: 'Money Borrowed from Jane',
  note: 'Emergency fund for medical expenses - Need to repay with 5% interest',
  amount: 1000.00, // Positive because money is coming into your account
  categoryId: personalCategoryId,
  accountId: bankAccountId,
  date: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncId: '',
  
  // Advanced fields for debt
  transactionType: TransactionType.loan,
  specialType: TransactionSpecialType.debt,
  transactionState: TransactionState.actionRequired,
  paid: true, // Initially true (money was received)
);

final createdDebt = await transactionRepository.createTransaction(debtTransaction);
```

## Working with Advanced Transaction Properties

### Check Transaction Type and State

```dart
// Check transaction type
if (transaction.isSubscription) {
  print('This is a subscription');
}

if (transaction.isRecurring) {
  print('This transaction repeats');
}

if (transaction.isLoan) {
  print('This is a loan transaction');
}

if (transaction.isCredit) {
  print('Money was lent out');
}

if (transaction.isDebt) {
  print('Money was borrowed');
}

// Check transaction state
if (transaction.isPending) {
  print('Transaction is pending');
}

if (transaction.isScheduled) {
  print('Transaction is scheduled for future');
}

if (transaction.needsAction) {
  print('Transaction requires action (collect/settle)');
}
```

### Get Available Actions

```dart
// Get actions available for a transaction
final actions = transaction.availableActions;

for (final action in actions) {
  switch (action) {
    case TransactionAction.pay:
      print('Can pay this transaction');
      break;
    case TransactionAction.collect:
      print('Can collect money (for credit)');
      break;
    case TransactionAction.settle:
      print('Can settle debt');
      break;
    case TransactionAction.edit:
      print('Can edit transaction');
      break;
    case TransactionAction.delete:
      print('Can delete transaction');
      break;
    default:
      print('Action: ${action.name}');
  }
}
```

### Update Transaction State

```dart
// Mark a credit as collected (money returned)
final collectedCredit = creditTransaction.copyWith(
  paid: false, // Set to false when collected (net-zero effect)
  transactionState: TransactionState.completed,
  note: 'Money collected on ${DateTime.now().toString()}',
);

await transactionRepository.updateTransaction(collectedCredit);

// Mark a debt as settled (money paid back)
final settledDebt = debtTransaction.copyWith(
  paid: false, // Set to false when settled (net-zero effect)
  transactionState: TransactionState.completed,
  note: 'Debt settled on ${DateTime.now().toString()}',
);

await transactionRepository.updateTransaction(settledDebt);
```

### Working with Recurring Transactions

```dart
// Create next instance of a recurring transaction
final nextInstance = recurringTransaction.copyWith(
  id: null, // Remove ID to create new transaction
  date: DateTime.now().add(Duration(days: 30)), // Next month
  originalDateDue: recurringTransaction.originalDateDue ?? recurringTransaction.date,
  createdAnotherFutureTransaction: true,
  syncId: '', // Will generate new sync ID
);

await transactionRepository.createTransaction(nextInstance);

// Skip a recurring payment
final skippedTransaction = scheduledTransaction.copyWith(
  skipPaid: true,
  transactionState: TransactionState.cancelled,
  note: 'Payment skipped for this period',
);

await transactionRepository.updateTransaction(skippedTransaction);
```

## Advanced Filtering and Analytics

### Filter by Transaction Type

```dart
// Get all subscriptions
final allTransactions = await transactionRepository.getAllTransactions();
final subscriptions = allTransactions.where((t) => t.isSubscription).toList();

// Get all loans
final loans = allTransactions.where((t) => t.isLoan).toList();

// Get pending transactions
final pendingTransactions = allTransactions.where((t) => t.isPending).toList();

// Get transactions that need action
final actionRequired = allTransactions.where((t) => t.needsAction).toList();
```

### Calculate Loan Balances

```dart
// Calculate total money lent out (credits)
double totalCredits = 0.0;
double uncollectedCredits = 0.0;

final creditTransactions = allTransactions.where((t) => t.isCredit).toList();
for (final credit in creditTransactions) {
  totalCredits += credit.amount.abs();
  if (credit.paid) { // Still uncollected
    uncollectedCredits += credit.amount.abs();
  }
}

// Calculate total money owed (debts)
double totalDebts = 0.0;
double unsettledDebts = 0.0;

final debtTransactions = allTransactions.where((t) => t.isDebt).toList();
for (final debt in debtTransactions) {
  totalDebts += debt.amount;
  if (debt.paid) { // Still unsettled
    unsettledDebts += debt.amount;
  }
}

print('Total lent: \$${totalCredits.toStringAsFixed(2)}');
print('Uncollected: \$${uncollectedCredits.toStringAsFixed(2)}');
print('Total borrowed: \$${totalDebts.toStringAsFixed(2)}');
print('Unsettled: \$${unsettledDebts.toStringAsFixed(2)}');
```

### Monthly Subscription Analysis

```dart
// Calculate monthly subscription costs
final subscriptions = allTransactions.where((t) => t.isSubscription).toList();
double monthlySubscriptionCost = 0.0;

for (final subscription in subscriptions) {
  if (subscription.recurrence == TransactionRecurrence.monthly) {
    monthlySubscriptionCost += subscription.amount.abs();
  } else if (subscription.recurrence == TransactionRecurrence.yearly) {
    monthlySubscriptionCost += subscription.amount.abs() / 12;
  } else if (subscription.recurrence == TransactionRecurrence.weekly) {
    monthlySubscriptionCost += subscription.amount.abs() * 4.33; // Average weeks per month
  }
}

print('Monthly subscription cost: \$${monthlySubscriptionCost.toStringAsFixed(2)}');
```

## Advanced Use Cases

### Create Complex Loan with Objective Link

```dart
// For complex loans, you can link to an objective (future feature)
final complexLoan = Transaction(
  title: 'Car Loan Payment',
  note: 'Monthly payment for car loan',
  amount: -350.00,
  categoryId: transportationCategoryId,
  accountId: bankAccountId,
  date: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncId: '',
  
  transactionType: TransactionType.loan,
  recurrence: TransactionRecurrence.monthly,
  periodLength: 1,
  endDate: DateTime.now().add(Duration(days: 5 * 365)), // 5 years
  objectiveLoanFk: 'car-loan-objective-id', // Link to objectives table
  transactionState: TransactionState.scheduled,
);
```

### Bulk Operations on Advanced Transactions

```dart
// Mark all overdue subscriptions as action required
final allTransactions = await transactionRepository.getAllTransactions();
final overdueSubscriptions = allTransactions.where((t) => 
  t.isSubscription && 
  t.isScheduled && 
  t.date.isBefore(DateTime.now())
).toList();

for (final subscription in overdueSubscriptions) {
  final updated = subscription.copyWith(
    transactionState: TransactionState.actionRequired,
  );
  await transactionRepository.updateTransaction(updated);
}

// Automatically collect small credits (under $10)
final smallCredits = allTransactions.where((t) => 
  t.isCredit && 
  t.needsAction && 
  t.amount.abs() < 10.0
).toList();

for (final credit in smallCredits) {
  final collected = credit.copyWith(
    paid: false,
    transactionState: TransactionState.completed,
    note: '${credit.note ?? ''}\nAuto-collected (small amount)',
  );
  await transactionRepository.updateTransaction(collected);
}
``` 