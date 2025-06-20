import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finance/features/budgets/domain/entities/budget.dart';
import 'package:finance/features/budgets/data/services/budget_filter_service_impl.dart';
import 'package:finance/features/transactions/domain/entities/transaction.dart';
import 'package:finance/features/transactions/domain/entities/transaction_enums.dart';
import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';
import 'package:finance/services/currency_service.dart';
import 'package:finance/features/budgets/data/services/budget_csv_service.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockCurrencyService extends Mock implements CurrencyService {}

class MockBudgetCsvService extends Mock implements BudgetCsvService {}

void main() {
  group('BudgetFilterService', () {
    late BudgetFilterServiceImpl service;
    late MockTransactionRepository mockTransactionRepository;
    late MockAccountRepository mockAccountRepository;
    late MockCurrencyService mockCurrencyService;
    late MockBudgetCsvService mockBudgetCsvService;

    setUp(() {
      mockTransactionRepository = MockTransactionRepository();
      mockAccountRepository = MockAccountRepository();
      mockCurrencyService = MockCurrencyService();
      mockBudgetCsvService = MockBudgetCsvService();

      service = BudgetFilterServiceImpl(
        mockTransactionRepository,
        mockAccountRepository,
        mockCurrencyService,
        mockBudgetCsvService,
      );
    });

    test('should filter out debt/credit transactions when enabled', () async {
      // Arrange
      final transactions = [
        Transaction(
          id: 1,
          title: 'Normal expense',
          amount: -100.0,
          date: DateTime.now(),
          categoryId: 1,
          accountId: 1,
          transactionType: TransactionType.expense,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'sync1',
        ),
        Transaction(
          id: 2,
          title: 'Credit payment',
          amount: -50.0,
          date: DateTime.now(),
          categoryId: 1,
          accountId: 1,
          transactionType: TransactionType.expense,
          specialType: TransactionSpecialType.credit,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'sync2',
        ),
      ];

      // Act
      final filtered =
          await service.excludeDebtCreditTransactions(transactions);

      // Assert
      expect(filtered, hasLength(1));
      expect(filtered.first.title, equals('Normal expense'));
    });

    test('should normalize currency amounts correctly', () async {
      // Arrange
      when(() => mockCurrencyService.convertAmount(
            amount: 100.0,
            fromCurrency: 'EUR',
            toCurrency: 'USD',
          )).thenAnswer((_) async => 110.0);

      // Act
      final result =
          await service.normalizeAmountToCurrency(100.0, 'EUR', 'USD');

      // Assert
      expect(result, equals(110.0));
      verify(() => mockCurrencyService.convertAmount(
            amount: 100.0,
            fromCurrency: 'EUR',
            toCurrency: 'USD',
          )).called(1);
    });

    test('should return same amount when currencies are equal', () async {
      // Act
      final result =
          await service.normalizeAmountToCurrency(100.0, 'USD', 'USD');

      // Assert
      expect(result, equals(100.0));
      verifyNever(() => mockCurrencyService.convertAmount(
            amount: any(named: 'amount'),
            fromCurrency: any(named: 'fromCurrency'),
            toCurrency: any(named: 'toCurrency'),
          ));
    });

    test('should filter transactions by wallet IDs', () async {
      // Arrange
      final transactions = [
        Transaction(
          id: 1,
          title: 'Wallet 1 transaction',
          amount: -100.0,
          date: DateTime.now(),
          categoryId: 1,
          accountId: 1,
          transactionType: TransactionType.expense,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'sync1',
        ),
        Transaction(
          id: 2,
          title: 'Wallet 2 transaction',
          amount: -50.0,
          date: DateTime.now(),
          categoryId: 1,
          accountId: 2,
          transactionType: TransactionType.expense,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'sync2',
        ),
      ];

      // Act
      final filtered = await service.filterByWallets(transactions, ['1']);

      // Assert
      expect(filtered, hasLength(1));
      expect(filtered.first.accountId, equals(1));
    });

    test('should exclude objective transactions when enabled', () async {
      // Arrange
      final transactions = [
        Transaction(
          id: 1,
          title: 'Normal expense',
          amount: -100.0,
          date: DateTime.now(),
          categoryId: 1,
          accountId: 1,
          transactionType: TransactionType.expense,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'sync1',
          objectiveLoanFk: null,
        ),
        Transaction(
          id: 2,
          title: 'Loan payment',
          amount: -50.0,
          date: DateTime.now(),
          categoryId: 1,
          accountId: 1,
          transactionType: TransactionType.expense,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'sync2',
          objectiveLoanFk: '123',
        ),
      ];

      // Act
      final filtered = await service.excludeObjectiveTransactions(transactions);

      // Assert
      expect(filtered, hasLength(1));
      expect(filtered.first.title, equals('Normal expense'));
    });

    test('should include transaction based on budget criteria', () async {
      // Arrange
      final budget = Budget(
        name: 'Test Budget',
        amount: 1000.0,
        spent: 0.0,
        period: BudgetPeriod.monthly,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'budget1',
        excludeDebtCreditInstallments: true,
        excludeObjectiveInstallments: false,
      );

      final transaction = Transaction(
        id: 1,
        title: 'Normal expense',
        amount: -100.0,
        date: DateTime.now(),
        categoryId: 1,
        accountId: 1,
        transactionType: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'sync1',
      );

      // Act
      final shouldInclude =
          await service.shouldIncludeTransaction(budget, transaction);

      // Assert
      expect(shouldInclude, isTrue);
    });

    test(
        'should exclude transaction if it is credit and budget excludes credit',
        () async {
      // Arrange
      final budget = Budget(
        name: 'Test Budget',
        amount: 1000.0,
        spent: 0.0,
        period: BudgetPeriod.monthly,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'budget1',
        excludeDebtCreditInstallments: true,
      );

      final transaction = Transaction(
        id: 1,
        title: 'Credit payment',
        amount: -100.0,
        date: DateTime.now(),
        categoryId: 1,
        accountId: 1,
        transactionType: TransactionType.expense,
        specialType: TransactionSpecialType.credit,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'sync1',
      );

      // Act
      final shouldInclude =
          await service.shouldIncludeTransaction(budget, transaction);

      // Assert
      expect(shouldInclude, isFalse);
    });

    test('should handle error in currency conversion gracefully', () async {
      // Arrange
      when(() => mockCurrencyService.convertAmount(
            amount: 100.0,
            fromCurrency: 'INVALID',
            toCurrency: 'USD',
          )).thenThrow(Exception('Currency not found'));

      // Act
      final result =
          await service.normalizeAmountToCurrency(100.0, 'INVALID', 'USD');

      // Assert - should return original amount as fallback
      expect(result, equals(100.0));
    });
  });
}
