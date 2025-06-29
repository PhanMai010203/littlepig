import 'package:flutter_test/flutter_test.dart';
import 'package:finance/features/transactions/data/services/transaction_display_service_impl.dart';
import 'package:finance/features/transactions/domain/entities/transaction.dart';
import 'package:finance/features/transactions/domain/services/transaction_display_service.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';
import 'package:finance/features/currencies/domain/repositories/currency_repository.dart';
import 'package:finance/features/accounts/domain/entities/account.dart';
import 'package:finance/features/currencies/domain/entities/currency.dart';
import 'package:finance/features/currencies/domain/entities/exchange_rate.dart';

// ---------------------------------------------------------------------------
// Fake repository implementations for testing purposes
// ---------------------------------------------------------------------------

class _FakeAccountRepository implements AccountRepository {
  @override
  Future<List<Account>> getAllAccounts() async => [];

  @override
  Future<Account?> getAccountById(int id) async => throw UnimplementedError();

  @override
  Future<Account?> getAccountBySyncId(String syncId) async => throw UnimplementedError();

  @override
  Future<Account?> getDefaultAccount() async => throw UnimplementedError();

  @override
  Future<Account> createAccount(Account account) async => throw UnimplementedError();

  @override
  Future<Account> updateAccount(Account account) async => throw UnimplementedError();

  @override
  Future<void> deleteAccount(int id) async => throw UnimplementedError();

  @override
  Future<void> deleteAllAccounts() async => throw UnimplementedError();

  @override
  Future<void> updateBalance(int accountId, double amount) async => throw UnimplementedError();

  @override
  Future<List<Account>> getUnsyncedAccounts() async => throw UnimplementedError();

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async => throw UnimplementedError();

  @override
  Future<void> insertOrUpdateFromSync(Account account) async => throw UnimplementedError();
}

class _FakeCurrencyRepository implements CurrencyRepository {
  @override
  Future<List<Currency>> getAllCurrencies() async => throw UnimplementedError();

  @override
  Future<Currency?> getCurrencyByCode(String code) async => null;

  @override
  Future<List<Currency>> getPopularCurrencies() async => throw UnimplementedError();

  @override
  Future<List<Currency>> searchCurrencies(String query) async => throw UnimplementedError();

  @override
  Future<Map<String, ExchangeRate>> getExchangeRates() async => throw UnimplementedError();

  @override
  Future<ExchangeRate?> getExchangeRate(String fromCurrency, String toCurrency) async => throw UnimplementedError();

  @override
  Future<void> setCustomExchangeRate(String fromCurrency, String toCurrency, double rate) async => throw UnimplementedError();

  @override
  Future<void> removeCustomExchangeRate(String fromCurrency, String toCurrency) async => throw UnimplementedError();

  @override
  Future<List<ExchangeRate>> getCustomExchangeRates() async => throw UnimplementedError();

  @override
  Future<bool> refreshExchangeRates() async => throw UnimplementedError();

  @override
  Future<double> convertAmount({required double amount, required String fromCurrency, required String toCurrency}) async => throw UnimplementedError();

  @override
  Future<DateTime?> getLastExchangeRateUpdate() async => throw UnimplementedError();
}

void main() {
  group('Transaction Filtering Tests', () {
    late TransactionDisplayService service;
    late List<Transaction> testTransactions;

    setUp(() {
      service = TransactionDisplayServiceImpl(
        _FakeAccountRepository(),
        _FakeCurrencyRepository(),
      );
      
      // Create test transactions with current month dates
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      
      testTransactions = [
        // Income transactions
        Transaction(
          id: 1,
          title: 'Salary',
          amount: 3000.0,
          categoryId: 1,
          accountId: 1,
          date: currentMonth.add(const Duration(days: 5)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-1',
        ),
        Transaction(
          id: 2,
          title: 'Freelance',
          amount: 500.0,
          categoryId: 2,
          accountId: 1,
          date: currentMonth.add(const Duration(days: 10)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-2',
        ),
        // Expense transactions
        Transaction(
          id: 3,
          title: 'Groceries',
          amount: -150.0,
          categoryId: 3,
          accountId: 1,
          date: currentMonth.add(const Duration(days: 3)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-3',
        ),
        Transaction(
          id: 4,
          title: 'Gas',
          amount: -60.0,
          categoryId: 4,
          accountId: 1,
          date: currentMonth.add(const Duration(days: 8)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-4',
        ),
        // Additional transactions to test behavior with more than 5 items
        Transaction(
          id: 6,
          title: 'Rent',
          amount: -1200.0,
          categoryId: 5,
          accountId: 1,
          date: currentMonth.add(const Duration(days: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-6',
        ),
        Transaction(
          id: 7,
          title: 'Utilities',
          amount: -80.0,
          categoryId: 6,
          accountId: 1,
          date: currentMonth.add(const Duration(days: 12)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-7',
        ),
        Transaction(
          id: 8,
          title: 'Bonus',
          amount: 1000.0,
          categoryId: 7,
          accountId: 1,
          date: currentMonth.add(const Duration(days: 15)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-8',
        ),
        // Transaction from previous month (should be filtered out)
        Transaction(
          id: 5,
          title: 'Last Month Expense',
          amount: -100.0,
          categoryId: 3,
          accountId: 1,
          date: currentMonth.subtract(const Duration(days: 5)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-5',
        ),
      ];
    });

    test('filterCurrentMonthTransactions should only return current month transactions', () {
      final result = service.filterCurrentMonthTransactions(testTransactions);
      
      // Should return 7 transactions (excluding the previous month one)
      expect(result.length, equals(7));
      
      // Should not include the previous month transaction
      expect(result.any((t) => t.id == 5), isFalse);
    });

    test('filterTransactionsByType with "all" should return all current month transactions', () {
      final currentMonthTransactions = service.filterCurrentMonthTransactions(testTransactions);
      final result = service.filterTransactionsByType(currentMonthTransactions, TransactionFilter.all);
      
      // Should return all current month transactions (7 total)
      expect(result.length, equals(7));
      
      // Should include both income and expense transactions
      final incomeCount = result.where((t) => t.isIncome).length;
      final expenseCount = result.where((t) => t.isExpense).length;
      expect(incomeCount, equals(3)); // Salary, Freelance, Bonus
      expect(expenseCount, equals(4)); // Groceries, Gas, Rent, Utilities
    });

    test('filterTransactionsByType with "income" should return only income transactions', () {
      final currentMonthTransactions = service.filterCurrentMonthTransactions(testTransactions);
      final result = service.filterTransactionsByType(currentMonthTransactions, TransactionFilter.income);
      
      // Should return only income transactions (3 total)
      expect(result.length, equals(3));
      expect(result.every((t) => t.isIncome), isTrue);
      
      // Should include specific income transactions
      expect(result.any((t) => t.title == 'Salary'), isTrue);
      expect(result.any((t) => t.title == 'Freelance'), isTrue);
      expect(result.any((t) => t.title == 'Bonus'), isTrue);
    });

    test('filterTransactionsByType with "expense" should return only expense transactions', () {
      final currentMonthTransactions = service.filterCurrentMonthTransactions(testTransactions);
      final result = service.filterTransactionsByType(currentMonthTransactions, TransactionFilter.expense);
      
      // Should return only expense transactions (4 total)
      expect(result.length, equals(4));
      expect(result.every((t) => t.isExpense), isTrue);
      
      // Should include specific expense transactions
      expect(result.any((t) => t.title == 'Groceries'), isTrue);
      expect(result.any((t) => t.title == 'Gas'), isTrue);
      expect(result.any((t) => t.title == 'Rent'), isTrue);
      expect(result.any((t) => t.title == 'Utilities'), isTrue);
    });

    test('all filter should equal income + expense combined', () {
      final currentMonthTransactions = service.filterCurrentMonthTransactions(testTransactions);
      
      final allTransactions = service.filterTransactionsByType(currentMonthTransactions, TransactionFilter.all);
      final incomeTransactions = service.filterTransactionsByType(currentMonthTransactions, TransactionFilter.income);
      final expenseTransactions = service.filterTransactionsByType(currentMonthTransactions, TransactionFilter.expense);
      
      // All should equal income + expense
      expect(allTransactions.length, equals(incomeTransactions.length + expenseTransactions.length));
      
      // All transactions should be present in either income or expense
      for (final transaction in allTransactions) {
        final isInIncomeList = incomeTransactions.any((t) => t.id == transaction.id);
        final isInExpenseList = expenseTransactions.any((t) => t.id == transaction.id);
        expect(isInIncomeList || isInExpenseList, isTrue);
      }
    });

    test('filters should show consistent results with more than 5 transactions', () {
      final currentMonthTransactions = service.filterCurrentMonthTransactions(testTransactions);
      
      // Verify we have more than 5 transactions to test this scenario
      expect(currentMonthTransactions.length, greaterThan(5));
      
      final allTransactions = service.filterTransactionsByType(currentMonthTransactions, TransactionFilter.all);
      final incomeTransactions = service.filterTransactionsByType(currentMonthTransactions, TransactionFilter.income);
      final expenseTransactions = service.filterTransactionsByType(currentMonthTransactions, TransactionFilter.expense);
      
      // All transactions in income filter should also be in all filter
      for (final transaction in incomeTransactions) {
        expect(allTransactions.any((t) => t.id == transaction.id), isTrue,
            reason: 'Income transaction ${transaction.title} should be in All filter');
      }
      
      // All transactions in expense filter should also be in all filter
      for (final transaction in expenseTransactions) {
        expect(allTransactions.any((t) => t.id == transaction.id), isTrue,
            reason: 'Expense transaction ${transaction.title} should be in All filter');
      }
      
      // Total count should be consistent
      expect(allTransactions.length, equals(incomeTransactions.length + expenseTransactions.length));
    });
  });
} 