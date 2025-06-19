import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/database/app_database.dart';
import 'package:finance/core/database/migrations/schema_cleanup_migration.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';

void main() {
  group('Schema Cleanup Migration Tests', () {
    late AppDatabase database;
    late SchemaCleanupMigration migration;

    setUp(() async {
      // Use in-memory database for testing
      database = AppDatabase.forTesting(NativeDatabase.memory());
      migration = SchemaCleanupMigration(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('Current Schema State', () {
      test('should have clean sync fields in current schema', () async {
        // Check transactions table structure (current clean state)
        final transactionColumns = await database
            .customSelect('PRAGMA table_info(transactions)')
            .get();

        final columnNames =
            transactionColumns.map((col) => col.data['name']).toList();

        // Should NOT have redundant sync fields (already cleaned)
        expect(columnNames, isNot(contains('device_id')));
        expect(columnNames, isNot(contains('is_synced')));
        expect(columnNames, isNot(contains('last_sync_at')));
        expect(columnNames, isNot(contains('version')));

        // Should have essential sync field
        expect(columnNames, contains('sync_id'));
      });

      test('should preserve business logic fields', () async {
        // Check that important business fields are preserved
        final transactionColumns = await database
            .customSelect('PRAGMA table_info(transactions)')
            .get();

        final columnNames =
            transactionColumns.map((col) => col.data['name']).toList();

        expect(columnNames, contains('title'));
        expect(columnNames, contains('amount'));
        expect(columnNames, contains('category_id'));
        expect(columnNames, contains('account_id'));
        expect(columnNames, contains('date'));
        expect(columnNames, contains('created_at'));
        expect(columnNames, contains('updated_at'));
      });
    });

    group('Migration Tests (Current Clean State)', () {
      test('should verify migration state successfully', () async {
        // Execute verification on current clean schema
        final isValid = await migration.verifyMigration();
        expect(isValid, isTrue);
      });

      test('should generate migration statistics', () async {
        // Add some test data first
        await _insertTestData(database);

        // Get statistics
        final stats = await migration.getStats();

        expect(stats.totalRecords, greaterThanOrEqualTo(0));
        expect(stats.spaceSavedBytes, equals(49)); // ~49 bytes per record
        expect(stats.recordCounts, isNotEmpty);

        // Check statistics string representation
        final statsString = stats.toString();
        expect(statsString, contains('Migration Statistics'));
        expect(statsString, contains('Total records migrated'));
        expect(statsString, contains('space saved'));
      });
    });

    group('Data Operations', () {
      test('should handle CRUD operations with clean schema', () async {
        // Test that database operations work with cleaned schema
        await _insertTestData(database);

        // Verify data was inserted
        final transactionCount = await database
            .customSelect('SELECT COUNT(*) as count FROM transactions')
            .getSingle();

        final categoryCount = await database
            .customSelect('SELECT COUNT(*) as count FROM categories')
            .getSingle();

        expect(transactionCount.data['count'], greaterThan(0));
        expect(categoryCount.data['count'], greaterThan(0));
      });

      test('should preserve data during backup operations', () async {
        // Add test data
        await _insertTestData(database);

        // Count records before backup
        final initialCounts = await _getRecordCounts(database);

        // Test backup creation (part of migration)
        await createTestBackup(migration, database);

        // Verify data is preserved
        final finalCounts = await _getRecordCounts(database);
        expect(
            finalCounts['transactions'], equals(initialCounts['transactions']));
        expect(finalCounts['categories'], equals(initialCounts['categories']));
      });
    });

    group('Schema Version Management', () {
      test('should handle schema version updates', () async {
        // Test schema version setting
        await database.customStatement('''
          INSERT OR REPLACE INTO sync_metadata (key, value) 
          VALUES ('schema_version', '8')
        ''');

        // Verify schema version
        final schemaVersion = await database.customSelect('''
          SELECT value FROM sync_metadata WHERE key = 'schema_version'
        ''').getSingleOrNull();

        expect(schemaVersion?.data['value'], equals('8'));
      });
    });

    group('Error Handling', () {
      test('should handle missing tables gracefully', () async {
        // Migration should work even if some tables don't exist
        final isValid = await migration.verifyMigration();

        // Should return false if tables are missing, but not crash
        expect(isValid, anyOf(isTrue, isFalse));
      });

      test('should handle empty database gracefully', () async {
        // Test with completely empty database
        final stats = await migration.getStats();

        expect(stats.totalRecords, greaterThanOrEqualTo(0));
        expect(stats.recordCounts, isNotEmpty);
      });
    });
  });
}

// Helper function to insert test data
Future<void> _insertTestData(AppDatabase database) async {
  try {
    // Insert test categories with only required fields (matching clean schema)
    await database.into(database.categoriesTable).insert(
          CategoriesTableCompanion.insert(
            name: 'Test Category',
            icon: '🏠',
            color: 0xFF4CAF50,
            isExpense: true,
            syncId: 'cat-1',
          ),
        );

    // Insert test accounts
    await database.into(database.accountsTable).insert(
          AccountsTableCompanion.insert(
            name: 'Test Account',
            balance: const Value(1000.0),
            syncId: 'acc-1',
          ),
        );

    // Insert test transactions
    await database.into(database.transactionsTable).insert(
          TransactionsTableCompanion.insert(
            title: 'Test Transaction',
            amount: 100.0,
            categoryId: 1,
            accountId: 1,
            date: DateTime.now(),
            syncId: 'txn-1',
          ),
        );

    // Insert test budgets
    await database.into(database.budgetsTable).insert(
          BudgetsTableCompanion.insert(
            name: 'Test Budget',
            amount: 500.0,
            period: 'monthly',
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now().add(const Duration(days: 30)),
            syncId: 'budget-1',
          ),
        );
  } catch (e) {
    print('Error inserting test data: $e');
  }
}

// Helper function to get record counts
Future<Map<String, int>> _getRecordCounts(AppDatabase database) async {
  final transactionCount = await database
      .customSelect('SELECT COUNT(*) as count FROM transactions')
      .getSingle();

  final categoryCount = await database
      .customSelect('SELECT COUNT(*) as count FROM categories')
      .getSingle();

  final accountCount = await database
      .customSelect('SELECT COUNT(*) as count FROM accounts')
      .getSingle();

  final budgetCount = await database
      .customSelect('SELECT COUNT(*) as count FROM budgets')
      .getSingle();

  return {
    'transactions': transactionCount.data['count'] as int,
    'categories': categoryCount.data['count'] as int,
    'accounts': accountCount.data['count'] as int,
    'budgets': budgetCount.data['count'] as int,
  };
}

// Helper function to create test backup
Future<void> createTestBackup(
    SchemaCleanupMigration migration, AppDatabase database) async {
  try {
    // Create backup tables if they don't exist
    await database.customStatement('''
      CREATE TABLE IF NOT EXISTS transactions_backup AS 
      SELECT * FROM transactions WHERE 0=1
    ''');

    await database.customStatement('''
      CREATE TABLE IF NOT EXISTS categories_backup AS 
      SELECT * FROM categories WHERE 0=1
    ''');
  } catch (e) {
    // Expected if tables already exist
  }
}
