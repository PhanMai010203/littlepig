import 'package:equatable/equatable.dart';

class TransactionBudgetLink extends Equatable {
  final int? id;
  final int transactionId;
  final int budgetId;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncId;

  const TransactionBudgetLink({
    this.id,
    required this.transactionId,
    required this.budgetId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.syncId,
  });

  TransactionBudgetLink copyWith({
    int? id,
    int? transactionId,
    int? budgetId,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncId,
  }) {
    return TransactionBudgetLink(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      budgetId: budgetId ?? this.budgetId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncId: syncId ?? this.syncId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transactionId,
        budgetId,
        amount,
        createdAt,
        updatedAt,
        syncId,
      ];

  @override
  String toString() {
    return 'TransactionBudgetLink{id: $id, transactionId: $transactionId, budgetId: $budgetId, amount: $amount}';
  }
} 