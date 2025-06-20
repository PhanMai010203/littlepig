import 'package:equatable/equatable.dart';
import 'transaction_enums.dart';

class Transaction extends Equatable {
  final int? id;
  final String title;
  final String? note;
  final double amount;
  final int categoryId;
  final int accountId;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Advanced transaction fields

  // Transaction type and special type
  final TransactionType transactionType;
  final TransactionSpecialType? specialType; // credit, debt, etc.

  // Recurring/Subscription fields
  final TransactionRecurrence recurrence;
  final int? periodLength; // e.g., 1 for "every 1 month"
  final DateTime? endDate; // When to stop creating instances
  final DateTime? originalDateDue; // Original due date for recurring

  // State and action management
  final TransactionState transactionState;
  final bool paid; // For loan/recurring logic
  final bool skipPaid; // Skip vs pay for recurring
  final bool? createdAnotherFutureTransaction; // Prevents duplicate creation

  // Loan/Objective linking (for complex loans)
  final String? objectiveLoanFk; // Links to objectives table (future use)

  // Phase 3 – Partial loan payments support
  final double? remainingAmount; // null for regular transactions
  final int? parentTransactionId; // null when this is the parent loan itself

  // ✅ PHASE 4: Only essential sync field (event sourcing handles the rest)
  final String syncId;

  const Transaction({
    this.id,
    required this.title,
    this.note,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,

    // Advanced fields with defaults for backward compatibility
    this.transactionType = TransactionType.expense,
    this.specialType,
    this.recurrence = TransactionRecurrence.none,
    this.periodLength,
    this.endDate,
    this.originalDateDue,
    this.transactionState = TransactionState.completed,
    this.paid = false,
    this.skipPaid = false,
    this.createdAnotherFutureTransaction,
    this.objectiveLoanFk,

    // Phase 3
    this.remainingAmount,
    this.parentTransactionId,
    required this.syncId,
  });
  Transaction copyWith({
    int? id,
    String? title,
    String? note,
    double? amount,
    int? categoryId,
    int? accountId,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    TransactionType? transactionType,
    TransactionSpecialType? specialType,
    TransactionRecurrence? recurrence,
    int? periodLength,
    DateTime? endDate,
    DateTime? originalDateDue,
    TransactionState? transactionState,
    bool? paid,
    bool? skipPaid,
    bool? createdAnotherFutureTransaction,
    String? objectiveLoanFk,
    double? remainingAmount,
    int? parentTransactionId,
    String? syncId,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionType: transactionType ?? this.transactionType,
      specialType: specialType ?? this.specialType,
      recurrence: recurrence ?? this.recurrence,
      periodLength: periodLength ?? this.periodLength,
      endDate: endDate ?? this.endDate,
      originalDateDue: originalDateDue ?? this.originalDateDue,
      transactionState: transactionState ?? this.transactionState,
      paid: paid ?? this.paid,
      skipPaid: skipPaid ?? this.skipPaid,
      createdAnotherFutureTransaction: createdAnotherFutureTransaction ??
          this.createdAnotherFutureTransaction,
      objectiveLoanFk: objectiveLoanFk ?? this.objectiveLoanFk,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      parentTransactionId: parentTransactionId ?? this.parentTransactionId,
      syncId: syncId ?? this.syncId,
    );
  }

  bool get isIncome => amount > 0;
  bool get isExpense => amount < 0;

  // Phase 3 helper
  bool get isLoanPayment => parentTransactionId != null;

  // Advanced transaction type helpers
  bool get isRecurring => recurrence != TransactionRecurrence.none;
  bool get isSubscription => transactionType == TransactionType.subscription;
  bool get isLoan =>
      transactionType == TransactionType.loan || specialType != null;
  bool get isCredit => specialType == TransactionSpecialType.credit;
  bool get isDebt => specialType == TransactionSpecialType.debt;
  bool get isPending => transactionState == TransactionState.pending;
  bool get isScheduled => transactionState == TransactionState.scheduled;
  bool get needsAction => transactionState == TransactionState.actionRequired;

  /// Gets the available actions for this transaction based on its state and type
  List<TransactionAction> get availableActions {
    final actions = <TransactionAction>[];

    // Basic actions always available
    actions.addAll([TransactionAction.edit, TransactionAction.delete]);

    // State-based actions
    switch (transactionState) {
      case TransactionState.pending:
        actions.addAll([TransactionAction.pay, TransactionAction.skip]);
        break;
      case TransactionState.completed:
        if (isRecurring) {
          actions.add(TransactionAction.unpay);
        }
        break;
      case TransactionState.scheduled:
        actions.addAll([TransactionAction.pay, TransactionAction.skip]);
        break;
      case TransactionState.actionRequired:
        if (isCredit) {
          actions
              .add(paid ? TransactionAction.collect : TransactionAction.none);
        } else if (isDebt) {
          actions.add(paid ? TransactionAction.settle : TransactionAction.none);
        }
        break;
      case TransactionState.cancelled:
        // Only basic actions for cancelled transactions
        break;
    }

    return actions;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        note,
        amount,
        categoryId,
        accountId,
        date,
        createdAt,
        updatedAt,
        transactionType,
        specialType,
        recurrence,
        periodLength,
        endDate,
        originalDateDue,
        transactionState,
        paid,
        skipPaid,
        createdAnotherFutureTransaction,
        objectiveLoanFk,
        remainingAmount,
        parentTransactionId,
        syncId,
      ];
}
