import '../entities/budget.dart';
import '../../../transactions/domain/entities/transaction.dart';

abstract class BudgetFilterService {
  Future<List<Transaction>> getFilteredTransactionsForBudget(
      Budget budget, DateTime startDate, DateTime endDate);

  Future<double> calculateBudgetSpent(Budget budget);
  Future<double> calculateBudgetRemaining(Budget budget);
  Future<bool> shouldIncludeTransaction(Budget budget, Transaction transaction);

  // Advanced filtering methods
  Future<List<Transaction>> excludeDebtCreditTransactions(
      List<Transaction> transactions);
  Future<List<Transaction>> excludeObjectiveTransactions(
      List<Transaction> transactions);
  Future<List<Transaction>> filterByWallets(
      List<Transaction> transactions, List<String> walletFks);
  Future<List<Transaction>> filterByCurrency(
      List<Transaction> transactions, List<String> currencyFks);
  Future<double> normalizeAmountToCurrency(
      double amount, String fromCurrency, String toCurrency);

  // CSV Export functionality
  Future<void> exportBudgetData(Budget budget, String filePath);
  Future<void> exportMultipleBudgets(List<Budget> budgets);
}
