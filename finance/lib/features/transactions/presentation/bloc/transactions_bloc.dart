import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/transaction_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

@injectable
class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  TransactionsBloc(
    this._transactionRepository,
    this._categoryRepository,
  ) : super(TransactionsInitial()) {
    on<LoadAllTransactions>(_onLoadAllTransactions);
    on<LoadTransactionsByAccount>(_onLoadTransactionsByAccount);
    on<LoadTransactionsByCategory>(_onLoadTransactionsByCategory);
    on<LoadTransactionsByDateRange>(_onLoadTransactionsByDateRange);
    on<LoadTransactionsWithCategories>(_onLoadTransactionsWithCategories);
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<RefreshTransactions>(_onRefreshTransactions);
    on<ChangeSelectedMonth>(_onChangeSelectedMonth);
  }

  Future<void> _onLoadAllTransactions(
      LoadAllTransactions event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final transactions = await _transactionRepository.getAllTransactions();
      // Sort transactions by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));
      
      final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      emit(TransactionsLoaded(
        transactions: transactions,
        categories: const {},
        selectedMonth: currentMonth,
      ));
    } catch (e) {
      emit(TransactionsError('Failed to load transactions: $e'));
    }
  }

  Future<void> _onLoadTransactionsByAccount(
      LoadTransactionsByAccount event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final transactions = await _transactionRepository
          .getTransactionsByAccount(event.accountId);
      // Sort transactions by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));
      
      final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      emit(TransactionsLoaded(
        transactions: transactions,
        categories: const {},
        selectedMonth: currentMonth,
      ));
    } catch (e) {
      emit(TransactionsError('Failed to load transactions by account: $e'));
    }
  }

  Future<void> _onLoadTransactionsByCategory(
      LoadTransactionsByCategory event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final transactions = await _transactionRepository
          .getTransactionsByCategory(event.categoryId);
      // Sort transactions by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));
      
      final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      emit(TransactionsLoaded(
        transactions: transactions,
        categories: const {},
        selectedMonth: currentMonth,
      ));
    } catch (e) {
      emit(TransactionsError('Failed to load transactions by category: $e'));
    }
  }

  Future<void> _onLoadTransactionsByDateRange(
      LoadTransactionsByDateRange event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final transactions = await _transactionRepository
          .getTransactionsByDateRange(event.startDate, event.endDate);
      // Sort transactions by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));
      
      final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      emit(TransactionsLoaded(
        transactions: transactions,
        categories: const {},
        selectedMonth: currentMonth,
      ));
    } catch (e) {
      emit(TransactionsError('Failed to load transactions by date range: $e'));
    }
  }

  Future<void> _onLoadTransactionsWithCategories(
      LoadTransactionsWithCategories event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final transactionsFuture = _transactionRepository.getAllTransactions();
      final categoriesFuture = _categoryRepository.getAllCategories();

      final transactions = await transactionsFuture;
      final categories = await categoriesFuture;

      // Sort transactions by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      final categoriesMap = {for (var c in categories) c.id!: c};
      final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

      emit(TransactionsLoaded(
        transactions: transactions,
        categories: categoriesMap,
        selectedMonth: currentMonth,
      ));
    } catch (e) {
      emit(TransactionsError('Failed to load data: $e'));
    }
  }

  Future<void> _onCreateTransaction(
      CreateTransactionEvent event, Emitter<TransactionsState> emit) async {
    try {
      await _transactionRepository.createTransaction(event.transaction);
      // Reload data after creating
      add(LoadTransactionsWithCategories());
    } catch (e) {
      emit(TransactionsError('Failed to create transaction: $e'));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransactionEvent event, Emitter<TransactionsState> emit) async {
    try {
      await _transactionRepository.updateTransaction(event.transaction);
      // Reload data after updating
      add(LoadTransactionsWithCategories());
    } catch (e) {
      emit(TransactionsError('Failed to update transaction: $e'));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event, Emitter<TransactionsState> emit) async {
    try {
      await _transactionRepository.deleteTransaction(event.id);
      // Reload data after deleting
      add(LoadTransactionsWithCategories());
    } catch (e) {
      emit(TransactionsError('Failed to delete transaction: $e'));
    }
  }

  Future<void> _onRefreshTransactions(
      RefreshTransactions event, Emitter<TransactionsState> emit) async {
    // Simply reload the data
    add(LoadTransactionsWithCategories());
  }

  void _onChangeSelectedMonth(
      ChangeSelectedMonth event, Emitter<TransactionsState> emit) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      emit(currentState.copyWith(selectedMonth: event.selectedMonth));
    }
  }
}