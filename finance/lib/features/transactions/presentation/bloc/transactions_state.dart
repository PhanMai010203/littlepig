import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsPaginated extends TransactionsState {
  final PagingState<int, Transaction> pagingState;
  final Map<int, Category> categories;
  final DateTime selectedMonth;

  const TransactionsPaginated({
    required this.pagingState,
    required this.categories,
    required this.selectedMonth,
  });

  TransactionsPaginated copyWith({
    PagingState<int, Transaction>? pagingState,
    Map<int, Category>? categories,
    DateTime? selectedMonth,
  }) {
    return TransactionsPaginated(
      pagingState: pagingState ?? this.pagingState,
      categories: categories ?? this.categories,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }

  @override
  List<Object?> get props => [pagingState, categories, selectedMonth];
}

// Legacy state for backward compatibility during transition
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
