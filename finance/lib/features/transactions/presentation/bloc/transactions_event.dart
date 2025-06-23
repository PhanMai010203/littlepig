import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllTransactions extends TransactionsEvent {}

class LoadTransactionsByAccount extends TransactionsEvent {
  final int accountId;

  const LoadTransactionsByAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class LoadTransactionsByCategory extends TransactionsEvent {
  final int categoryId;

  const LoadTransactionsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class LoadTransactionsByDateRange extends TransactionsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadTransactionsByDateRange(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}

class CreateTransactionEvent extends TransactionsEvent {
  final Transaction transaction;

  const CreateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionsEvent {
  final Transaction transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionsEvent {
  final int id;

  const DeleteTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class RefreshTransactions extends TransactionsEvent {}

class LoadTransactionsWithCategories extends TransactionsEvent {}

class ChangeSelectedMonth extends TransactionsEvent {
  final DateTime selectedMonth;

  const ChangeSelectedMonth(this.selectedMonth);

  @override
  List<Object?> get props => [selectedMonth];
}

class FetchNextTransactionPage extends TransactionsEvent {}

class RefreshPaginatedTransactions extends TransactionsEvent {}
