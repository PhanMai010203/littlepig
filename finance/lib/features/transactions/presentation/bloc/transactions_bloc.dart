import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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

  static const int _pageSize = 25;
  Map<int, Category> _categories = {};
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int _consecutiveEmptyFetches = 0;

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
    on<FetchNextTransactionPage>(_onFetchNextTransactionPage);
    on<RefreshPaginatedTransactions>(_onRefreshPaginatedTransactions);
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
      // Load categories first
      final categories = await _categoryRepository.getAllCategories();
      _categories = {for (var c in categories) c.id!: c};

      // Initialize pagination with empty state
      final initialPagingState = PagingState<int, TransactionListItem>();

      emit(TransactionsPaginated(
        pagingState: initialPagingState,
        categories: _categories,
        selectedMonth: _selectedMonth,
      ));

      // Trigger first page load
      add(FetchNextTransactionPage());
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
    _selectedMonth = event.selectedMonth;
    _consecutiveEmptyFetches = 0;
    
    if (state is TransactionsPaginated) {
      final currentState = state as TransactionsPaginated;
      emit(currentState.copyWith(selectedMonth: event.selectedMonth));
      // Refresh pagination when month changes
      add(RefreshPaginatedTransactions());
    } else if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      emit(currentState.copyWith(selectedMonth: event.selectedMonth));
    }
  }

  Future<void> _onFetchNextTransactionPage(
      FetchNextTransactionPage event, Emitter<TransactionsState> emit) async {
    if (state is! TransactionsPaginated) return;
    
    final currentState = state as TransactionsPaginated;
    final currentPagingState = currentState.pagingState;
    
    // Prevent multiple simultaneous requests
    if (currentPagingState.isLoading) return;
    
    try {
      final nextPageKey = (currentPagingState.keys?.last ?? -1) + 1;
      
      // Set loading state
      emit(currentState.copyWith(
        pagingState: currentPagingState.copyWith(
          isLoading: true,
          error: null,
        ),
      ));

      // Fetch transactions for the page
      final newTransactions = await _transactionRepository.getTransactions(
        page: nextPageKey,
        limit: _pageSize,
      );

      // Filter transactions by selected month
      final filteredTransactions = newTransactions.where((t) {
        return t.date.year == _selectedMonth.year &&
            t.date.month == _selectedMonth.month;
      }).toList();

      if (filteredTransactions.isEmpty && newTransactions.isNotEmpty) {
        _consecutiveEmptyFetches++;
      } else {
        _consecutiveEmptyFetches = 0;
      }

      final isLastPage = newTransactions.length < _pageSize || _consecutiveEmptyFetches > 5;
      if (isLastPage) {
        _consecutiveEmptyFetches = 0;
      }

      // Group transactions
      final existingItems = currentState.pagingState.pages?.expand((page) => page).toList();
      final newItems = _groupTransactions(filteredTransactions, existingItems);

      // Update the paging state
      final updatedPagingState = currentPagingState.copyWith(
        pages: [...?currentPagingState.pages, newItems],
        keys: [...?currentPagingState.keys, nextPageKey],
        hasNextPage: !isLastPage,
        isLoading: false,
      );

      emit(currentState.copyWith(pagingState: updatedPagingState));
    } catch (error) {
      final errorPagingState = currentPagingState.copyWith(
        error: error,
        isLoading: false,
      );
      emit(currentState.copyWith(pagingState: errorPagingState));
    }
  }

  List<TransactionListItem> _groupTransactions(List<Transaction> transactions, List<TransactionListItem>? existingItems) {
    if (transactions.isEmpty) {
      return [];
    }

    TransactionItem? lastTransactionItem;
    if (existingItems != null) {
      final transactionItems = existingItems.whereType<TransactionItem>().toList();
      if (transactionItems.isNotEmpty) {
        lastTransactionItem = transactionItems.last;
      }
    }
    final lastTransactionDate = lastTransactionItem != null 
      ? DateUtils.dateOnly(lastTransactionItem.transaction.date)
      : null;

    final newItems = <TransactionListItem>[];
    final groupedByDate = <DateTime, List<Transaction>>{};

    for (final transaction in transactions) {
      final day = DateUtils.dateOnly(transaction.date);
      if (groupedByDate[day] == null) {
        groupedByDate[day] = [];
      }
      groupedByDate[day]!.add(transaction);
    }

    final sortedDates = groupedByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      final transactionsOnDate = groupedByDate[date]!;
      final totalAmount = transactionsOnDate.fold<double>(0, (sum, t) => sum + t.amount);
      
      if (date != lastTransactionDate || (existingItems?.isEmpty ?? true)) {
        newItems.add(DateHeaderItem(date, totalAmount, transactionsOnDate.length));
      } else {
        // Find header for this date and update total
        final headerIndex = existingItems!.indexWhere((item) => item is DateHeaderItem && item.date == date);
        if (headerIndex != -1) {
          final oldHeader = existingItems[headerIndex] as DateHeaderItem;
          final newTotal = oldHeader.totalAmount + totalAmount;
          // This is tricky because PagingState is immutable. 
          // A better approach is to not have header in item list but build it in UI.
          // For now, let's stick to the logic that may produce multiple headers for same date if pages are small.
          // The logic to avoid double headers is already there: `if (date != lastTransactionDate)`
        }
        
      }
      newItems.addAll(transactionsOnDate.map((t) => TransactionItem(t)));
    }

    // A simpler logic for grouping that might be better
    final items = <TransactionListItem>[];
    if (transactions.isNotEmpty) {
      final grouped = <DateTime, List<Transaction>>{};
      for (var t in transactions) {
        final date = DateUtils.dateOnly(t.date);
        grouped.putIfAbsent(date, () => []).add(t);
      }
      
      DateTime? lastDate;
      if(existingItems?.isNotEmpty ?? false) {
        final lastItem = existingItems!.last;
        if (lastItem is TransactionItem) {
          lastDate = DateUtils.dateOnly(lastItem.transaction.date);
        }
      }

      final sortedDates = grouped.keys.toList()..sort((a,b) => b.compareTo(a));

      for (var date in sortedDates) {
        if (date != lastDate) {
          final total = grouped[date]!.fold<double>(0, (prev, curr) => prev + curr.amount);
          items.add(DateHeaderItem(date, total, grouped[date]!.length));
        }
        items.addAll(grouped[date]!.map((t) => TransactionItem(t)));
        lastDate = date;
      }
    }

    return items;
  }

  Future<void> _onRefreshPaginatedTransactions(
      RefreshPaginatedTransactions event, Emitter<TransactionsState> emit) async {
    if (state is! TransactionsPaginated) return;
    
    final currentState = state as TransactionsPaginated;
    
    // Reset pagination state
    final refreshedPagingState = PagingState<int, TransactionListItem>();
    
    emit(currentState.copyWith(pagingState: refreshedPagingState));
    
    // Fetch first page
    add(FetchNextTransactionPage());
  }
}