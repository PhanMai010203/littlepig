import '../core/di/injection.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/categories/domain/repositories/category_repository.dart';
import '../features/accounts/domain/repositories/account_repository.dart';
import '../features/budgets/domain/repositories/budget_repository.dart';

import '../core/sync/sync_service.dart';
import 'currency_service.dart';

/// Example service demonstrating how to use the new repositories and sync system
class FinanceService {
  late final TransactionRepository _transactionRepository;
  late final CategoryRepository _categoryRepository;
  late final AccountRepository _accountRepository;
  late final BudgetRepository _budgetRepository;
  late final SyncService _syncService;
  late final CurrencyService _currencyService;

  FinanceService() {
    _transactionRepository = getIt<TransactionRepository>();
    _categoryRepository = getIt<CategoryRepository>();
    _accountRepository = getIt<AccountRepository>();
    _budgetRepository = getIt<BudgetRepository>();
    _syncService = getIt<SyncService>();
    _currencyService = getIt<CurrencyService>();
  }

  /// Example: Get all expense categories
  Future<void> loadExpenseCategories() async {
    final expenseCategories = await _categoryRepository.getExpenseCategories();
    print('Found ${expenseCategories.length} expense categories');
  }

  /// Example: Get all accounts
  Future<void> loadAccounts() async {
    final accounts = await _accountRepository.getAllAccounts();
    print('Found ${accounts.length} accounts');
  }

  /// Example: Get all transactions
  Future<void> loadTransactions() async {
    final transactions = await _transactionRepository.getAllTransactions();
    print('Found ${transactions.length} transactions');
  }

  /// Example: Get active budgets
  Future<void> loadActiveBudgets() async {
    final budgets = await _budgetRepository.getActiveBudgets();
    print('Found ${budgets.length} active budgets');
  }

  /// Example: Check sync status
  Future<void> checkSyncStatus() async {
    final isSignedIn = await _syncService.isSignedIn();
    print('Sync service signed in: $isSignedIn');

    if (isSignedIn) {
      final email = await _syncService.getCurrentUserEmail();
      print('Signed in as: $email');
    }
  }

  /// Example: Perform sync
  Future<void> performSync() async {
    final isSignedIn = await _syncService.isSignedIn();

    if (!isSignedIn) {
      final signInSuccess = await _syncService.signIn();
      if (!signInSuccess) {
        print('Failed to sign in');
        return;
      }
    }

    // Upload local changes
    final uploadResult = await _syncService.syncToCloud();
    print(
        'Upload result: ${uploadResult.success ? 'Success' : 'Failed - ${uploadResult.error}'}');

    // Download remote changes
    final downloadResult = await _syncService.syncFromCloud();
    print(
        'Download result: ${downloadResult.success ? 'Success' : 'Failed - ${downloadResult.error}'}');
  }

  /// Example: Listen to sync status changes
  void listenToSyncStatus() {
    _syncService.syncStatusStream.listen((status) {
      print('Sync status changed: $status');
    });
  }

  /// Get the currency service for currency operations
  CurrencyService get currencyService => _currencyService;
}
