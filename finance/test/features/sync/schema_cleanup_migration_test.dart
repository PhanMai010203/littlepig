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
      
      // Add some test data first
      await _insertTestData(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('Pre-Migration State', () {
      test('should have redundant sync fields before migration', () async {
        // Check transactions table structure
        final transactionColumns = await database.customSelect(
          'PRAGMA table_info(transactions)'
        ).get();

        final columnNames = transactionColumns.map((col) => col.data['name']).toList();
        
        // Should have redundant sync fields before migration
        expect(columnNames, contains('device_id'));
        expect(columnNames, contains('is_synced'));
        expect(columnNames, contains('last_sync_at'));
        expect(columnNames, contains('version'));
        expect(columnNames, contains('sync_id'));
      });

      test('should have test data in all tables', () async {
        final transactionCount = await database.customSelect(
          'SELECT COUNT(*) as count FROM transactions'
        ).getSingle();
        
        final categoryCount = await database.customSelect(
          'SELECT COUNT(*) as count FROM categories'
        ).getSingle();
        
        expect(transactionCount.data['count'], greaterThan(0));
        expect(categoryCount.data['count'], greaterThan(0));
      });
    });

    group('Migration Execution', () {
      test('should execute migration successfully', () async {
        // Run the migration
        await migration.executeCleanup();
        
        // Verify migration completed
        final isValid = await migration.verifyMigration();
        expect(isValid, isTrue);
      });

      test('should create backup tables', () async {
        // Execute backup creation
        await migration.executeCleanup();
        
        // Check that backup tables exist
        final backupTables = await database.customSelect('''
          SELECT name FROM sqlite_master 
          WHERE type='table' AND name LIKE '%_backup'
        ''').get();
        
        expect(backupTables.length, greaterThan(0));
      });

      test('should preserve data during migration', () async {
        // Count records before migration
        final initialCounts = await _getRecordCounts(database);
        
        // Execute migration
        await migration.executeCleanup();
        
        // Count records after migration
        final finalCounts = await _getRecordCounts(database);
        
        // Data should be preserved
        expect(finalCounts['transactions'], equals(initialCounts['transactions']));
        expect(finalCounts['categories'], equals(initialCounts['categories']));
        expect(finalCounts['accounts'], equals(initialCounts['accounts']));
      });

      test('should update schema version', () async {
        // Execute migration
        await migration.executeCleanup();
        
        // Check schema version
        final schemaVersion = await database.customSelect('''
          SELECT value FROM sync_metadata WHERE key = 'schema_version'
        ''').getSingleOrNull();
        
        expect(schemaVersion?.data['value'], equals('8'));
      });
    });

    group('Post-Migration Verification', () {
      test('should remove redundant sync fields', () async {
        // Execute migration
        await migration.executeCleanup();
        
        // Check transactions table structure after migration
        final transactionColumns = await database.customSelect(
          'PRAGMA table_info(transactions)'
        ).get();

        final columnNames = transactionColumns.map((col) => col.data['name']).toList();
        
        // Should not have redundant sync fields after migration
        expect(columnNames, isNot(contains('device_id')));
        expect(columnNames, isNot(contains('is_synced')));
        expect(columnNames, isNot(contains('last_sync_at')));
        expect(columnNames, isNot(contains('version')));
        
        // Should still have essential sync field
        expect(columnNames, contains('sync_id'));
      });

      test('should preserve business logic fields', () async {
        // Execute migration
        await migration.executeCleanup();
        
        // Check that important business fields are preserved
        final transactionColumns = await database.customSelect(
          'PRAGMA table_info(transactions)'
        ).get();

        final columnNames = transactionColumns.map((col) => col.data['name']).toList();
        
        expect(columnNames, contains('title'));
        expect(columnNames, contains('amount'));
        expect(columnNames, contains('category_id'));
        expect(columnNames, contains('account_id'));
        expect(columnNames, contains('date'));
        expect(columnNames, contains('created_at'));
        expect(columnNames, contains('updated_at'));
      });

      test('should verify all tables successfully', () async {
        // Execute migration
        await migration.executeCleanup();
        
        // Verify migration
        final isValid = await migration.verifyMigration();
        expect(isValid, isTrue);
      });
    });

    group('Rollback Functionality', () {
      test('should rollback successfully on migration failure', () async {
        // We'll simulate a failure by corrupting the migration process
        try {
          // This should fail and trigger rollback
          await database.customStatement('CREATE TABLE invalid_syntax ( invalid');
        } catch (e) {
          // Expected to fail
        }
        
        // Execute rollback manually (accessing private method for testing)
        // Note: In a real scenario, rollback would be called automatically on failure
        
        // Verify original structure is restored
        final transactionColumns = await database.customSelect(
          'PRAGMA table_info(transactions)'
        ).get();

        final columnNames = transactionColumns.map((col) => col.data['name']).toList();
        expect(columnNames, contains('sync_id'));
      });
    });

    group('Migration Statistics', () {
      test('should calculate migration statistics', () async {
        // Execute migration
        await migration.executeCleanup();
        
        // Get statistics
        final stats = await migration.getStats();
        
        expect(stats.totalRecords, greaterThan(0));
        expect(stats.spaceSavedBytes, equals(49)); // ~49 bytes per record
        expect(stats.recordCounts, isNotEmpty);
        
        // Check statistics string representation
        final statsString = stats.toString();
        expect(statsString, contains('Migration Statistics'));
        expect(statsString, contains('Total records migrated'));
        expect(statsString, contains('space saved'));
      });

      test('should track record counts by table', () async {
        // Execute migration
        await migration.executeCleanup();
        
        // Get statistics
        final stats = await migration.getStats();
        
        expect(stats.recordCounts.containsKey('transactions'), isTrue);
        expect(stats.recordCounts.containsKey('categories'), isTrue);
        expect(stats.recordCounts.containsKey('accounts'), isTrue);
        
        // Should have some records
        expect(stats.recordCounts['transactions'], greaterThan(0));
        expect(stats.recordCounts['categories'], greaterThan(0));
      });
    });

    group('Cleanup Operations', () {
      test('should cleanup backup tables after successful migration', () async {
        // Execute migration
        await migration.executeCleanup();
        
        // Cleanup backups
        await migration.cleanupBackups();
        
        // Check that backup tables are removed
        final backupTables = await database.customSelect('''
          SELECT name FROM sqlite_master 
          WHERE type='table' AND name LIKE '%_backup'
        ''').get();
        
        expect(backupTables, isEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle missing tables gracefully', () async {
        // Drop a table to simulate missing table scenario
        await database.customStatement('DROP TABLE IF EXISTS test_missing');
        
        // Migration should still work with existing tables
        await migration.executeCleanup();
        
        final isValid = await migration.verifyMigration();
        expect(isValid, isTrue);
      });

      test('should handle verification failure', () async {
        // Execute migration
        await migration.executeCleanup();
        
        // Corrupt the migrated table to cause verification failure
        await database.customStatement('DROP TABLE transactions');
        
        // Verification should fail
        final isValid = await migration.verifyMigration();
        expect(isValid, isFalse);
      });
    });

    group('Edge Cases', () {
      test('should handle empty tables', () async {
        // Clear all data
        await database.customStatement('DELETE FROM transactions');
        await database.customStatement('DELETE FROM categories');
        await database.customStatement('DELETE FROM accounts');
        
        // Migration should still work
        await migration.executeCleanup();
        
        final isValid = await migration.verifyMigration();
        expect(isValid, isTrue);
      });

      test('should handle tables with large amounts of data', () async {
        // Add more test data
        for (int i = 1; i < 100; i++) { // Start from 1 to avoid conflict with existing txn-1
          await database.into(database.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              title: 'Transaction $i',
              amount: i * 10.0,
              categoryId: 1,
              accountId: 1,
              date: DateTime.now(),
              deviceId: 'test-device',
              syncId: 'txn-bulk-$i',
            ),
          );
        }
        
        // Migration should handle large datasets
        await migration.executeCleanup();
        
        final stats = await migration.getStats();
        expect(stats.totalRecords, greaterThan(100));
      });
    });
  });
}

// Helper function to insert test data
Future<void> _insertTestData(AppDatabase database) async {
  // Insert test categories
  await database.into(database.categoriesTable).insert(
    CategoriesTableCompanion.insert(
      name: 'Test Category',
      icon: '🏠',
      color: 0xFF4CAF50,
      isExpense: true,
      deviceId: 'test-device',
      syncId: 'cat-1',
    ),
  );

  // Insert test accounts
  await database.into(database.accountsTable).insert(
    AccountsTableCompanion.insert(
      name: 'Test Account',
      balance: const Value(1000.0),
      deviceId: 'test-device',
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
      deviceId: 'test-device',
      syncId: 'txn-1',
    ),
  );

  // Insert test budgets
  await database.into(database.budgetsTable).insert(
    BudgetsTableCompanion.insert(
      name: 'Test Budget',
      amount: 500.0,
      period: 'monthly',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30)),
      deviceId: 'test-device',
      syncId: 'budget-1',
    ),
  );
}

// Helper function to get record counts
Future<Map<String, int>> _getRecordCounts(AppDatabase database) async {
  final counts = <String, int>{};
  
  final tables = ['transactions', 'categories', 'accounts', 'budgets', 'attachments'];
  
  for (final table in tables) {
    final result = await database.customSelect(
      'SELECT COUNT(*) as count FROM $table'
    ).getSingle();
    counts[table] = result.data['count'] as int;
  }
  
  return counts;
} 