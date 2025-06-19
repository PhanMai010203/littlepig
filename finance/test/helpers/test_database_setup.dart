import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/database/app_database.dart';

// Configure drift to suppress multiple database warnings in tests
void _configureDriftForTesting() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
}

/// ✅ PHASE 4.3: Test Database Setup
///
/// Provides utilities for creating clean test databases and verifying
/// Phase 4 event sourcing infrastructure is properly configured.
class TestDatabaseSetup {
  /// Creates a clean test database for testing
  static Future<AppDatabase> createCleanTestDatabase() async {
    // Configure drift for testing
    _configureDriftForTesting();

    final database = AppDatabase.forTesting(NativeDatabase.memory());

    // Ensure schema is at version 8 (Phase 4 complete)
    await database.customStatement('PRAGMA user_version = 8');

    // Verify event sourcing tables exist
    await _verifyEventSourcingTables(database);

    // Manually create triggers since test database skips migrations
    await _createEventSourcingTriggers(database);

    // Insert default categories for testing
    await _insertDefaultTestCategories(database);

    // Insert default test account
    await _insertDefaultTestAccount(database);

    return database;
  }

  /// Creates a test database with populated test data
  static Future<AppDatabase> createPopulatedTestDatabase() async {
    final database = await createCleanTestDatabase();

    // Insert additional test categories
    await _insertAdditionalTestCategories(database);

    // Insert additional test accounts
    await _insertAdditionalTestAccounts(database);

    // Insert test budgets
    await _insertTestBudgets(database);

    // Insert test transactions
    await _insertTestTransactions(database);

    return database;
  }

  /// Verifies that event sourcing tables exist and are properly structured
  static Future<void> _verifyEventSourcingTables(AppDatabase database) async {
    // Verify SyncEventLogTable exists
    final eventTableInfo =
        await database.customSelect("PRAGMA table_info(sync_event_log)").get();

    expect(eventTableInfo.isNotEmpty, true,
        reason: 'sync_event_log table should exist');

    // Verify required columns exist
    final eventColumns = eventTableInfo.map((row) => row.data['name']).toList();
    final requiredEventColumns = [
      'id',
      'event_id',
      'device_id',
      'table_name_field',
      'record_id',
      'operation',
      'data',
      'timestamp',
      'sequence_number',
      'hash',
      'is_synced'
    ];

    for (final column in requiredEventColumns) {
      expect(eventColumns, contains(column),
          reason: 'sync_event_log should have $column column');
    }

    // Verify SyncStateTable exists
    final stateTableInfo =
        await database.customSelect("PRAGMA table_info(sync_state)").get();

    expect(stateTableInfo.isNotEmpty, true,
        reason: 'sync_state table should exist');

    // Verify required columns exist
    final stateColumns = stateTableInfo.map((row) => row.data['name']).toList();
    final requiredStateColumns = [
      'id',
      'device_id',
      'last_sync_time',
      'last_sequence_number',
      'status'
    ];

    for (final column in requiredStateColumns) {
      expect(stateColumns, contains(column),
          reason: 'sync_state should have $column column');
    }
  }

  /// Verifies that all main tables have only syncId as sync field
  static Future<void> verifyPhase4TableStructure(AppDatabase database) async {
    final tables = [
      'transactions',
      'accounts',
      'categories',
      'budgets',
      'attachments'
    ];

    for (final tableName in tables) {
      final tableInfo =
          await database.customSelect("PRAGMA table_info($tableName)").get();

      final columns =
          tableInfo.map((row) => row.data['name'] as String).toList();

      // Should have syncId
      expect(columns, contains('sync_id'),
          reason: '$tableName should have sync_id column');

      // Should NOT have legacy sync fields
      const legacyFields = [
        'device_id',
        'is_synced',
        'last_sync_at',
        'version'
      ];
      for (final legacyField in legacyFields) {
        expect(columns, isNot(contains(legacyField)),
            reason:
                '$tableName should not have legacy sync field: $legacyField');
      }
    }
  }

  /// Verifies that database triggers exist for event sourcing
  static Future<void> verifyEventSourcingTriggers(AppDatabase database) async {
    final tables = [
      'transactions',
      'accounts',
      'categories',
      'budgets',
      'attachments'
    ];

    for (final tableName in tables) {
      // Check for insert trigger
      final insertTrigger = await database
          .customSelect(
              "SELECT name FROM sqlite_master WHERE type='trigger' AND name='${tableName}_sync_insert'")
          .getSingleOrNull();

      expect(insertTrigger, isNotNull,
          reason: '$tableName should have insert trigger for event sourcing');

      // Check for update trigger
      final updateTrigger = await database
          .customSelect(
              "SELECT name FROM sqlite_master WHERE type='trigger' AND name='${tableName}_sync_update'")
          .getSingleOrNull();

      expect(updateTrigger, isNotNull,
          reason: '$tableName should have update trigger for event sourcing');

      // Check for delete trigger
      final deleteTrigger = await database
          .customSelect(
              "SELECT name FROM sqlite_master WHERE type='trigger' AND name='${tableName}_sync_delete'")
          .getSingleOrNull();

      expect(deleteTrigger, isNotNull,
          reason: '$tableName should have delete trigger for event sourcing');
    }
  }

  /// Inserts default test categories
  static Future<void> _insertDefaultTestCategories(AppDatabase database) async {
    final now = DateTime.now();

    // Insert income category
    await database.into(database.categoriesTable).insert(
          CategoriesTableCompanion.insert(
            name: 'Salary',
            icon: '💰',
            color: 0xFF4CAF50, // Green
            isExpense: false,
            isDefault: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncId: 'test-cat-income-salary',
          ),
        );

    // Insert expense category
    await database.into(database.categoriesTable).insert(
          CategoriesTableCompanion.insert(
            name: 'Food',
            icon: '🍔',
            color: 0xFFFF9800, // Orange
            isExpense: true,
            isDefault: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncId: 'test-cat-expense-food',
          ),
        );
  }

  /// Inserts additional test categories
  static Future<void> _insertAdditionalTestCategories(
      AppDatabase database) async {
    final now = DateTime.now();

    final additionalCategories = [
      ('Transport', '🚗', 0xFFF44336, true), // Red
      ('Entertainment', '🎬', 0xFF9C27B0, true), // Purple
      ('Shopping', '🛒', 0xFF2196F3, true), // Blue
      ('Investment', '📈', 0xFF009688, false), // Teal
    ];

    for (int i = 0; i < additionalCategories.length; i++) {
      final (name, icon, color, isExpense) = additionalCategories[i];
      await database.into(database.categoriesTable).insert(
            CategoriesTableCompanion.insert(
              name: name,
              icon: icon,
              color: color,
              isExpense: isExpense,
              isDefault: const Value(false),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncId:
                  'test-cat-${isExpense ? 'expense' : 'income'}-${name.toLowerCase()}',
            ),
          );
    }
  }

  /// Inserts default test account
  static Future<void> _insertDefaultTestAccount(AppDatabase database) async {
    final now = DateTime.now();

    await database.into(database.accountsTable).insert(
          AccountsTableCompanion.insert(
            name: 'Test Account',
            balance: const Value(1000.0),
            currency: const Value('USD'),
            isDefault: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncId: 'test-account-default',
          ),
        );
  }

  /// Inserts additional test accounts
  static Future<void> _insertAdditionalTestAccounts(
      AppDatabase database) async {
    final now = DateTime.now();

    final accounts = [
      ('Savings Account', 2500.0, 'USD', false),
      ('Credit Card', -500.0, 'USD', false),
      ('Cash Wallet', 150.0, 'USD', false),
    ];

    for (int i = 0; i < accounts.length; i++) {
      final (name, balance, currency, isDefault) = accounts[i];
      await database.into(database.accountsTable).insert(
            AccountsTableCompanion.insert(
              name: name,
              balance: Value(balance),
              currency: Value(currency),
              isDefault: Value(isDefault),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncId: 'test-account-${i + 1}',
            ),
          );
    }
  }

  /// Inserts test budgets
  static Future<void> _insertTestBudgets(AppDatabase database) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final budgets = [
      ('Food Budget', 500.0, 150.0, 2), // Food category
      ('Transport Budget', 200.0, 50.0, 3), // Transport category
      ('Entertainment Budget', 300.0, 100.0, 4), // Entertainment category
    ];

    for (int i = 0; i < budgets.length; i++) {
      final (name, amount, spent, categoryId) = budgets[i];
      await database.into(database.budgetsTable).insert(
            BudgetsTableCompanion.insert(
              name: name,
              amount: amount,
              spent: Value(spent),
              categoryId: Value(categoryId),
              period: 'monthly',
              startDate: startOfMonth,
              endDate: endOfMonth,
              isActive: const Value(true),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncId: 'test-budget-${i + 1}',
            ),
          );
    }
  }

  /// Inserts test transactions
  static Future<void> _insertTestTransactions(AppDatabase database) async {
    final now = DateTime.now();

    final transactions = [
      (
        'Salary Payment',
        3000.0,
        1,
        1
      ), // Income: Salary category, default account
      (
        'Grocery Shopping',
        -75.0,
        2,
        1
      ), // Expense: Food category, default account
      (
        'Gas Station',
        -45.0,
        3,
        1
      ), // Expense: Transport category, default account
      (
        'Movie Night',
        -25.0,
        4,
        1
      ), // Expense: Entertainment category, default account
      (
        'Stock Investment',
        -500.0,
        6,
        2
      ), // Investment: Investment category, savings account
    ];

    for (int i = 0; i < transactions.length; i++) {
      final (title, amount, categoryId, accountId) = transactions[i];
      await database.into(database.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              title: title,
              amount: amount,
              categoryId: categoryId,
              accountId: accountId,
              date: now.subtract(Duration(days: i)),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncId: 'test-transaction-${i + 1}',
            ),
          );
    }
  }

  /// Sets up test device metadata
  static Future<void> setupTestDeviceMetadata(
    AppDatabase database, {
    required String deviceId,
  }) async {
    // Insert or update device ID
    await database.customStatement('''
      INSERT OR REPLACE INTO sync_metadata (key, value) 
      VALUES ('device_id', '$deviceId')
    ''');

    // Insert or update last sync time
    final now = DateTime.now();
    await database.customStatement('''
      INSERT OR REPLACE INTO sync_metadata (key, value) 
      VALUES ('last_sync_time', '${now.toIso8601String()}')
    ''');
  }

  /// Verifies test data was inserted correctly
  static Future<void> verifyTestDataIntegrity(AppDatabase database) async {
    // Verify categories
    final categories = await database.select(database.categoriesTable).get();
    expect(categories.length, greaterThanOrEqualTo(2),
        reason: 'Should have at least 2 test categories');

    // Verify accounts
    final accounts = await database.select(database.accountsTable).get();
    expect(accounts.length, greaterThanOrEqualTo(1),
        reason: 'Should have at least 1 test account');

    // Verify default account exists
    final defaultAccount = accounts.where((a) => a.isDefault).firstOrNull;
    expect(defaultAccount, isNotNull, reason: 'Should have a default account');
  }

  /// Cleans up test database and closes connection
  static Future<void> cleanupTestDatabase(AppDatabase database) async {
    try {
      // Clear all test data
      await database.delete(database.transactionsTable).go();
      await database.delete(database.budgetsTable).go();
      await database.delete(database.accountsTable).go();
      await database.delete(database.categoriesTable).go();
      await database.delete(database.syncEventLogTable).go();
      await database.delete(database.syncStateTable).go();
      await database.delete(database.syncMetadataTable).go();
      await database.delete(database.attachmentsTable).go();
    } catch (e) {
      // Ignore errors during cleanup
    } finally {
      await database.close();
    }
  }

  /// Creates a minimal test database for unit tests
  static Future<AppDatabase> createMinimalTestDatabase() async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    // Set to Phase 4 schema version
    await database.customStatement('PRAGMA user_version = 8');

    // Clear any default data that was inserted during database initialization
    await database.customStatement('DELETE FROM categories');
    await database.customStatement('DELETE FROM accounts');
    await database.customStatement('DELETE FROM sync_event_log');
    await database.customStatement('DELETE FROM sync_state');
    await database.customStatement('DELETE FROM sync_metadata');

    // Only verify event sourcing tables exist (no test data)
    await _verifyEventSourcingTables(database);

    // Create triggers but don't insert any test data
    await _createEventSourcingTriggers(database);

    return database;
  }

  /// Creates event sourcing triggers for test databases
  static Future<void> _createEventSourcingTriggers(AppDatabase database) async {
    // Get or create device ID for tests
    final deviceId = await _getOrCreateTestDeviceId(database);

    for (final tableName in [
      'transactions',
      'categories',
      'accounts',
      'budgets',
      'attachments'
    ]) {
      await database.customStatement('''
        CREATE TRIGGER IF NOT EXISTS ${tableName}_sync_insert
        AFTER INSERT ON $tableName
        BEGIN
          INSERT INTO sync_event_log (
            event_id, device_id, table_name_field, record_id, operation, data, timestamp, sequence_number, hash, is_synced
          ) VALUES (
            hex(randomblob(16)),
            '$deviceId',
            '$tableName',
            NEW.sync_id,
            'create',
            '{}',
            (strftime('%s', 'now') * 1000),
            (SELECT COALESCE(MAX(sequence_number), 0) + 1 FROM sync_event_log WHERE device_id = '$deviceId'),
            'test-hash',
            0
          );
        END
      ''');

      await database.customStatement('''
        CREATE TRIGGER IF NOT EXISTS ${tableName}_sync_update
        AFTER UPDATE ON $tableName
        WHEN NEW.sync_id = OLD.sync_id
        BEGIN
          INSERT INTO sync_event_log (
            event_id, device_id, table_name_field, record_id, operation, data, timestamp, sequence_number, hash, is_synced
          ) VALUES (
            hex(randomblob(16)),
            '$deviceId',
            '$tableName',
            NEW.sync_id,
            'update',
            '{}',
            (strftime('%s', 'now') * 1000),
            (SELECT COALESCE(MAX(sequence_number), 0) + 1 FROM sync_event_log WHERE device_id = '$deviceId'),
            'test-hash',
            0
          );
        END
      ''');

      await database.customStatement('''
        CREATE TRIGGER IF NOT EXISTS ${tableName}_sync_delete
        AFTER DELETE ON $tableName
        BEGIN
          INSERT INTO sync_event_log (
            event_id, device_id, table_name_field, record_id, operation, data, timestamp, sequence_number, hash, is_synced
          ) VALUES (
            hex(randomblob(16)),
            '$deviceId',
            '$tableName',
            OLD.sync_id,
            'delete',
            '{}',
            (strftime('%s', 'now') * 1000),
            (SELECT COALESCE(MAX(sequence_number), 0) + 1 FROM sync_event_log WHERE device_id = '$deviceId'),
            'test-hash',
            0
          );
        END
      ''');
    }
  }

  /// Gets or creates a test device ID
  static Future<String> _getOrCreateTestDeviceId(AppDatabase database) async {
    final existing = await (database.select(database.syncMetadataTable)
          ..where((t) => t.key.equals('device_id')))
        .getSingleOrNull();

    if (existing != null) {
      return existing.value;
    }

    final deviceId = 'test-device-${DateTime.now().millisecondsSinceEpoch}';
    await database.into(database.syncMetadataTable).insert(
          SyncMetadataTableCompanion.insert(
            key: 'device_id',
            value: deviceId,
          ),
        );

    return deviceId;
  }

  /// Waits for database triggers to complete (useful in tests)
  static Future<void> waitForTriggers() async {
    // Small delay to allow triggers to fire and process
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Verifies Phase 4 compliance of the database
  static Future<void> verifyPhase4Compliance(AppDatabase database) async {
    // Check schema version
    final version =
        await database.customSelect('PRAGMA user_version').getSingle();
    expect(version.data['user_version'], greaterThanOrEqualTo(8),
        reason: 'Database should be at Phase 4 schema version (8 or higher)');

    // Verify table structure
    await verifyPhase4TableStructure(database);

    // Verify event sourcing infrastructure
    await _verifyEventSourcingTables(database);
    await verifyEventSourcingTriggers(database);
  }
}
