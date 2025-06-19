import '../../domain/services/budget_filter_service.dart';
import '../../domain/entities/budget.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../../services/currency_service.dart';
import 'budget_csv_service.dart';

class BudgetFilterServiceImpl implements BudgetFilterService {
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final CurrencyService _currencyService;
  final BudgetCsvService _csvService;

  BudgetFilterServiceImpl(
    this._transactionRepository,
    this._accountRepository,
    this._currencyService,
    this._csvService,
  );

  @override
  Future<List<Transaction>> getFilteredTransactionsForBudget(
      Budget budget, DateTime startDate, DateTime endDate) async {
    // Step 1: Get base transactions by date range and category
    List<Transaction> transactions =
        await _getBaseTransactions(budget, startDate, endDate);

    // Step 2: Apply exclude debt/credit filter
    if (budget.excludeDebtCreditInstallments) {
      transactions = await excludeDebtCreditTransactions(transactions);
    }

    // Step 3: Apply exclude objective filter
    if (budget.excludeObjectiveInstallments) {
      transactions = await excludeObjectiveTransactions(transactions);
    }

    // Step 4: Apply wallet filter
    if (budget.walletFks?.isNotEmpty == true) {
      transactions = await filterByWallets(transactions, budget.walletFks!);
    }

    // Step 5: Apply currency filter and normalization
    if (budget.currencyFks?.isNotEmpty == true) {
      transactions = await filterByCurrency(transactions, budget.currencyFks!);
    }

    // Step 6: Apply shared budget exclusions
    if (budget.budgetFksExclude?.isNotEmpty == true) {
      transactions = await _excludeSharedBudgetTransactions(
          transactions, budget.budgetFksExclude!);
    }

    // Step 7: Apply transfer same-currency filter
    if (budget.includeTransferInOutWithSameCurrency) {
      transactions = await _includeTransferTransactions(transactions, budget);
    }

    return transactions;
  }

  @override
  Future<bool> shouldIncludeTransaction(
      Budget budget, Transaction transaction) async {
    // Check debt/credit exclusion
    if (budget.excludeDebtCreditInstallments &&
        (transaction.isCredit || transaction.isDebt)) {
      return false;
    }

    // Check objective exclusion
    if (budget.excludeObjectiveInstallments &&
        transaction.objectiveLoanFk != null) {
      return false;
    }

    // Check wallet inclusion
    if (budget.walletFks?.isNotEmpty == true) {
      if (!budget.walletFks!.contains(transaction.accountId.toString())) {
        return false;
      }
    }

    // Check currency inclusion (will need account currency lookup)
    if (budget.currencyFks?.isNotEmpty == true) {
      final accountCurrency = await _getAccountCurrency(transaction.accountId);
      if (!budget.currencyFks!.contains(accountCurrency)) {
        return false;
      }
    }

    // Check category match (existing logic)
    if (budget.categoryId != null &&
        transaction.categoryId != budget.categoryId) {
      return false;
    }

    return true;
  }

  @override
  Future<List<Transaction>> excludeDebtCreditTransactions(
      List<Transaction> transactions) async {
    return transactions.where((t) => !t.isCredit && !t.isDebt).toList();
  }

  @override
  Future<List<Transaction>> excludeObjectiveTransactions(
      List<Transaction> transactions) async {
    return transactions.where((t) => t.objectiveLoanFk == null).toList();
  }

  @override
  Future<List<Transaction>> filterByWallets(
      List<Transaction> transactions, List<String> walletFks) async {
    return transactions
        .where((t) => walletFks.contains(t.accountId.toString()))
        .toList();
  }

  @override
  Future<List<Transaction>> filterByCurrency(
      List<Transaction> transactions, List<String> currencyFks) async {
    final filteredTransactions = <Transaction>[];

    for (final transaction in transactions) {
      final accountCurrency = await _getAccountCurrency(transaction.accountId);
      if (currencyFks.contains(accountCurrency)) {
        filteredTransactions.add(transaction);
      }
    }

    return filteredTransactions;
  }

  @override
  Future<double> normalizeAmountToCurrency(
      double amount, String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return amount;

    try {
      return await _currencyService.convertAmount(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    } catch (e) {
      print('Currency conversion error: $e');
      return amount; // Return original amount as fallback
    }
  }

  @override
  Future<double> calculateBudgetSpent(Budget budget) async {
    final transactions = await getFilteredTransactionsForBudget(
        budget, budget.startDate, budget.endDate);

    double totalSpent = 0.0;
    for (final transaction in transactions) {
      double amount = transaction.amount.abs();

      // Apply currency normalization if needed
      if (budget.normalizeToCurrency != null) {
        final transactionCurrency = await _getTransactionCurrency(transaction);
        amount = await normalizeAmountToCurrency(
            amount, transactionCurrency, budget.normalizeToCurrency!);
      }

      totalSpent += amount;
    }

    return totalSpent;
  }

  @override
  Future<double> calculateBudgetRemaining(Budget budget) async {
    final spent = await calculateBudgetSpent(budget);
    return budget.amount - spent;
  }

  @override
  Future<void> exportBudgetData(Budget budget, String filePath) async {
    await _csvService.exportBudgetToCSV(budget, filePath);
  }

  @override
  Future<void> exportMultipleBudgets(List<Budget> budgets) async {
    await _csvService.exportBudgetsToCSV(budgets);
  }

  // Private helper methods
  Future<List<Transaction>> _getBaseTransactions(
      Budget budget, DateTime startDate, DateTime endDate) async {
    if (budget.categoryId != null) {
      final allTransactions = await _transactionRepository
          .getTransactionsByCategory(budget.categoryId!);
      return allTransactions
          .where((t) =>
              t.date.isAfter(startDate.subtract(Duration(days: 1))) &&
              t.date.isBefore(endDate.add(Duration(days: 1))))
          .toList();
    }
    return await _transactionRepository.getTransactionsByDateRange(
        startDate, endDate);
  }

  Future<String> _getAccountCurrency(int accountId) async {
    try {
      final account = await _accountRepository.getAccountById(accountId);
      return account?.currency ?? 'USD'; // Default fallback
    } catch (e) {
      print('Error getting account currency: $e');
      return 'USD'; // Default fallback
    }
  }

  Future<String> _getTransactionCurrency(Transaction transaction) async {
    return await _getAccountCurrency(transaction.accountId);
  }

  Future<List<Transaction>> _excludeSharedBudgetTransactions(
      List<Transaction> transactions, List<String> budgetFksExclude) async {
    // Implementation for shared budget exclusions
    // This would be expanded in Phase 4
    return transactions;
  }

  Future<List<Transaction>> _includeTransferTransactions(
      List<Transaction> transactions, Budget budget) async {
    // Implementation for transfer transactions
    // This would be expanded based on transfer logic
    return transactions;
  }
}
