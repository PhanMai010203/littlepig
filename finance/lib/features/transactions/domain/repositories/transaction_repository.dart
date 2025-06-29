import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();

  // 🆕 Phase 1.2: Paginated transactions for lazy loading
  Future<List<Transaction>> getTransactions({
    required int page,
    required int limit,
  });

  // 🆕 Phase 2: Month-optimized transaction loading
  Future<List<Transaction>> getTransactionsByMonth({
    required int year,
    required int month,
    required int page,
    required int limit,
  });

  Future<List<Transaction>> getTransactionsByAccount(int accountId);
  Future<List<Transaction>> getTransactionsByCategory(int categoryId);
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Transaction?> getTransactionById(int id);
  Future<Transaction?> getTransactionBySyncId(String syncId);

  Future<Transaction> createTransaction(Transaction transaction);
  Future<Transaction> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(int id);

  // Sync related
  Future<List<Transaction>> getUnsyncedTransactions();
  Future<void> markAsSynced(String syncId, DateTime syncTime);
  Future<void> insertOrUpdateFromSync(Transaction transaction);

  // Analytics
  Future<double> getTotalByCategory(
      int categoryId, DateTime? from, DateTime? to);
  Future<double> getTotalByAccount(int accountId, DateTime? from, DateTime? to);
  Future<Map<int, double>> getSpendingByCategory(DateTime? from, DateTime? to);

  Future<void> collectPartialCredit(
      {required Transaction credit, required double amount});
  Future<void> settlePartialDebt(
      {required Transaction debt, required double amount});
  Future<List<Transaction>> getLoanPayments(int parentTransactionId);
  double getRemainingAmount(Transaction loan);

  Future<void> deleteAllTransactions();
}
