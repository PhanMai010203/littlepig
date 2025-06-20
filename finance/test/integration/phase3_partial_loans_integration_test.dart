import 'package:flutter_test/flutter_test.dart';
import 'package:finance/features/transactions/domain/entities/transaction.dart';
import 'package:finance/features/transactions/domain/entities/transaction_enums.dart';
import 'package:finance/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:finance/core/database/app_database.dart';
import 'package:finance/core/database/migrations/phase3_partial_loans_migration.dart';
import '../helpers/test_database_setup.dart';

void main() {
  group('Phase 3: Partial Loans Integration Tests', () {
    late AppDatabase database;
    late TransactionRepositoryImpl repository;

    setUp(() async {
      database = await TestDatabaseSetup.createCleanTestDatabase();
      repository = TransactionRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('Database Migration Tests', () {
      test('should apply Phase 3 migration successfully', () async {
        // Arrange: Create migration
        final migration = Phase3PartialLoansMigration(database);

        // Act: Execute migration
        await migration.executePhase3Migration();

        // Assert: Verify schema version is updated
        final versionResult = await database.customSelect(
          'SELECT version FROM schema_version ORDER BY version DESC LIMIT 1'
        ).getSingleOrNull();
        
        expect(versionResult?.data['version'], equals(9));

        // Assert: Verify new columns exist
        final tableInfo = await database.customSelect(
          "PRAGMA table_info(transactions)"
        ).get();
        
        final columnNames = tableInfo
            .map((row) => row.data['name'] as String)
            .toList();
        
        expect(columnNames, contains('remaining_amount'));
        expect(columnNames, contains('parent_transaction_id'));
      });

      test('should initialize existing loan transactions correctly', () async {
        // Arrange: Create some loan transactions before migration
        await database.customStatement('''
          INSERT INTO transactions (
            title, amount, category_id, account_id, date, 
            created_at, updated_at, transaction_type, special_type,
            recurrence, transaction_state, paid, skip_paid,
            sync_id
          ) VALUES 
          ('Old Credit', -1000.0, 1, 1, '2024-01-01', 
           '2024-01-01', '2024-01-01', 'loan', 'credit',
           'none', 'completed', 0, 0, 'old-credit-1'),
          ('Old Debt', 500.0, 1, 1, '2024-01-01',
           '2024-01-01', '2024-01-01', 'loan', 'debt', 
           'none', 'completed', 0, 0, 'old-debt-1')
        ''');

        // Act: Apply migration
        final migration = Phase3PartialLoansMigration(database);
        await migration.executePhase3Migration();

        // Assert: Check credit transaction
        final creditResult = await database.customSelect(
          "SELECT * FROM transactions WHERE sync_id = 'old-credit-1'"
        ).getSingle();
        
        expect(creditResult.data['remaining_amount'], equals(1000.0)); // abs(-1000)
        expect(creditResult.data['transaction_state'], equals('actionRequired'));

        // Assert: Check debt transaction
        final debtResult = await database.customSelect(
          "SELECT * FROM transactions WHERE sync_id = 'old-debt-1'"
        ).getSingle();
        
        expect(debtResult.data['remaining_amount'], equals(500.0)); // abs(500)
        expect(debtResult.data['transaction_state'], equals('actionRequired'));
      });
    });

    group('End-to-End Loan Payment Workflows', () {
      test('should handle complete credit collection workflow', () async {
        // Arrange: Create a credit transaction
        final credit = Transaction(
          title: 'Loan to Friend',
          amount: -1500.0,
          categoryId: 1,
          accountId: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          transactionType: TransactionType.loan,
          specialType: TransactionSpecialType.credit,
          transactionState: TransactionState.actionRequired,
          remainingAmount: 1500.0,
          syncId: 'integration-credit-1',
        );

        final createdCredit = await repository.createTransaction(credit);

        // Act: Collect in multiple payments
        await repository.collectPartialCredit(
          credit: createdCredit,
          amount: 500.0,
        );

        final afterFirst = await repository.getTransactionById(createdCredit.id!);
        await repository.collectPartialCredit(
          credit: afterFirst!,
          amount: 300.0,
        );

        final afterSecond = await repository.getTransactionById(createdCredit.id!);
        await repository.collectPartialCredit(
          credit: afterSecond!,
          amount: 700.0,
        );

        // Assert: Verify final state
        final finalCredit = await repository.getTransactionById(createdCredit.id!);
        expect(finalCredit!.remainingAmount, equals(0.0));
        expect(finalCredit.transactionState, equals(TransactionState.completed));

        // Assert: Verify payment history
        final payments = await repository.getLoanPayments(createdCredit.id!);
        expect(payments.length, equals(3));
        
        final paymentAmounts = payments.map((p) => p.amount).toList();
        expect(paymentAmounts, containsAll([500.0, 300.0, 700.0]));

        // Assert: All payments are income type and completed
        for (final payment in payments) {
          expect(payment.transactionType, equals(TransactionType.income));
          expect(payment.transactionState, equals(TransactionState.completed));
          expect(payment.parentTransactionId, equals(createdCredit.id));
        }
      });

      test('should handle complete debt settlement workflow', () async {
        // Arrange: Create a debt transaction
        final debt = Transaction(
          title: 'Bank Loan',
          amount: 2500.0,
          categoryId: 1,
          accountId: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          transactionType: TransactionType.loan,
          specialType: TransactionSpecialType.debt,
          transactionState: TransactionState.actionRequired,
          remainingAmount: 2500.0,
          syncId: 'integration-debt-1',
        );

        final createdDebt = await repository.createTransaction(debt);

        // Act: Settle in multiple payments
        await repository.settlePartialDebt(
          debt: createdDebt,
          amount: 1000.0,
        );

        final afterFirst = await repository.getTransactionById(createdDebt.id!);
        await repository.settlePartialDebt(
          debt: afterFirst!,
          amount: 1500.0,
        );

        // Assert: Verify final state
        final finalDebt = await repository.getTransactionById(createdDebt.id!);
        expect(finalDebt!.remainingAmount, equals(0.0));
        expect(finalDebt.transactionState, equals(TransactionState.completed));

        // Assert: Verify settlement history
        final settlements = await repository.getLoanPayments(createdDebt.id!);
        expect(settlements.length, equals(2));
        
        final settlementAmounts = settlements.map((s) => s.amount).toList();
        expect(settlementAmounts, containsAll([-1000.0, -1500.0]));

        // Assert: All settlements are expense type and completed
        for (final settlement in settlements) {
          expect(settlement.transactionType, equals(TransactionType.expense));
          expect(settlement.transactionState, equals(TransactionState.completed));
          expect(settlement.parentTransactionId, equals(createdDebt.id));
        }
      });

      test('should prevent over-collection and over-settlement', () async {
        // Arrange: Create small credit
        final credit = Transaction(
          title: 'Small Credit',
          amount: -100.0,
          categoryId: 1,
          accountId: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          transactionType: TransactionType.loan,
          specialType: TransactionSpecialType.credit,
          transactionState: TransactionState.actionRequired,
          remainingAmount: 100.0,
          syncId: 'small-credit-1',
        );

        final createdCredit = await repository.createTransaction(credit);

        // Act & Assert: Try over-collection
        expect(
          () => repository.collectPartialCredit(
            credit: createdCredit,
            amount: 150.0,
          ),
          throwsA(isA<OverCollectionException>()),
        );

        // Arrange: Create small debt
        final debt = Transaction(
          title: 'Small Debt',
          amount: 200.0,
          categoryId: 1,
          accountId: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          transactionType: TransactionType.loan,
          specialType: TransactionSpecialType.debt,
          transactionState: TransactionState.actionRequired,
          remainingAmount: 200.0,
          syncId: 'small-debt-1',
        );

        final createdDebt = await repository.createTransaction(debt);

        // Act & Assert: Try over-settlement
        expect(
          () => repository.settlePartialDebt(
            debt: createdDebt,
            amount: 250.0,
          ),
          throwsA(isA<OverCollectionException>()),
        );
      });
    });

    group('getRemainingAmount Helper Integration', () {
      test('should return correct remaining amounts throughout loan lifecycle', () async {
        // Arrange: Create credit
        final credit = Transaction(
          title: 'Lifecycle Credit',
          amount: -1000.0,
          categoryId: 1,
          accountId: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          transactionType: TransactionType.loan,
          specialType: TransactionSpecialType.credit,
          transactionState: TransactionState.actionRequired,
          remainingAmount: 1000.0,
          syncId: 'lifecycle-credit-1',
        );

        final createdCredit = await repository.createTransaction(credit);

        // Act & Assert: Initial state
        expect(repository.getRemainingAmount(createdCredit), equals(1000.0));

        // Act: Partial collection
        await repository.collectPartialCredit(
          credit: createdCredit,
          amount: 400.0,
        );

        final afterPartial = await repository.getTransactionById(createdCredit.id!);
        expect(repository.getRemainingAmount(afterPartial!), equals(600.0));

        // Act: Complete collection
        await repository.collectPartialCredit(
          credit: afterPartial,
          amount: 600.0,
        );

        final afterComplete = await repository.getTransactionById(createdCredit.id!);
        expect(repository.getRemainingAmount(afterComplete!), equals(0.0));
      });
    });

    group('Data Integrity Tests', () {
      test('should maintain parent-child relationships through repository', () async {
        // Arrange
        final credit = Transaction(
          title: 'Integrity Test Credit',
          amount: -800.0,
          categoryId: 1,
          accountId: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          transactionType: TransactionType.loan,
          specialType: TransactionSpecialType.credit,
          transactionState: TransactionState.actionRequired,
          remainingAmount: 800.0,
          syncId: 'integrity-credit-1',
        );

        final createdCredit = await repository.createTransaction(credit);

        // Act: Make multiple collections
        await repository.collectPartialCredit(credit: createdCredit, amount: 200.0);
        
        final afterFirst = await repository.getTransactionById(createdCredit.id!);
        await repository.collectPartialCredit(credit: afterFirst!, amount: 300.0);

        // Assert: Verify parent state through repository
        final finalParent = await repository.getTransactionById(createdCredit.id!);
        expect(finalParent!.remainingAmount, equals(300.0)); // 800 - 200 - 300

        // Assert: Verify child relationships through repository
        final children = await repository.getLoanPayments(createdCredit.id!);
        expect(children.length, equals(2));
        expect(children.map((c) => c.amount).toList(), containsAll([200.0, 300.0]));
        
        // All children should reference the parent
        for (final child in children) {
          expect(child.parentTransactionId, equals(createdCredit.id));
        }
      });
    });
  });
} 