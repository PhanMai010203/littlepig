import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  final Map<int, Category> categories;
  final DateTime selectedMonth;

  const TransactionsLoaded({
    required this.transactions,
    required this.categories,
    required this.selectedMonth,
  });

  TransactionsLoaded copyWith({
    List<Transaction>? transactions,
    Map<int, Category>? categories,
    DateTime? selectedMonth,
  }) {
    return TransactionsLoaded(
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }

  @override
  List<Object?> get props => [transactions, categories, selectedMonth];
}

class TransactionOperationSuccess extends TransactionsState {
  final String message;

  const TransactionOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}
