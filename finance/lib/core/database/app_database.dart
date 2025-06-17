import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables/transactions_table.dart';
import 'tables/categories_table.dart';
import 'tables/budgets_table.dart';
import 'tables/accounts_table.dart';
import 'tables/sync_metadata_table.dart';
import 'tables/attachments_table.dart';
import '../constants/default_categories.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  TransactionsTable,
  CategoriesTable,
  BudgetsTable,
  AccountsTable,
  SyncMetadataTable,
  AttachmentsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  // Constructor for opening a specific file (used for sync merging)
  AppDatabase.fromFile(File file) : super(NativeDatabase(file));
  
  // Constructor for testing with in-memory database
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);
  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _insertDefaultData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add note field to transactions table using raw SQL
          await customStatement('ALTER TABLE transactions ADD COLUMN note TEXT');
          // Create attachments table
          await m.createTable(attachmentsTable);
        }
        if (from < 3) {
          // Add cache management fields to attachments table
          await customStatement('ALTER TABLE attachments ADD COLUMN is_captured_from_camera BOOLEAN DEFAULT FALSE');
          await customStatement('ALTER TABLE attachments ADD COLUMN local_cache_expiry DATETIME');
        }
        if (from < 4) {
          await _addAdvancedTransactionFields();
        }        if (from <= 4) {
          await _addAdvancedBudgetFields();
        }
        if (from <= 5) {
          // Drop description column from transactions table (Migration from v5 to v6)
          await _removeDescriptionField();
        }
      },
    );
  }

  /// Add advanced transaction fields for loans, subscriptions, and recurring payments
  Future<void> _addAdvancedTransactionFields() async {
    // Transaction type and special type
    await customStatement('ALTER TABLE transactions ADD COLUMN transaction_type TEXT DEFAULT "expense"');
    await customStatement('ALTER TABLE transactions ADD COLUMN special_type TEXT');
    
    // Recurring/Subscription fields
    await customStatement('ALTER TABLE transactions ADD COLUMN recurrence TEXT DEFAULT "none"');
    await customStatement('ALTER TABLE transactions ADD COLUMN period_length INTEGER');
    await customStatement('ALTER TABLE transactions ADD COLUMN end_date DATETIME');
    await customStatement('ALTER TABLE transactions ADD COLUMN original_date_due DATETIME');
    
    // State and action management
    await customStatement('ALTER TABLE transactions ADD COLUMN transaction_state TEXT DEFAULT "completed"');
    await customStatement('ALTER TABLE transactions ADD COLUMN paid BOOLEAN DEFAULT FALSE');
    await customStatement('ALTER TABLE transactions ADD COLUMN skip_paid BOOLEAN DEFAULT FALSE');
    await customStatement('ALTER TABLE transactions ADD COLUMN created_another_future_transaction BOOLEAN DEFAULT FALSE');
    
    // Loan/Objective linking (for complex loans)
    await customStatement('ALTER TABLE transactions ADD COLUMN objective_loan_fk TEXT');
  }

  /// Add advanced budget fields for enhanced filtering and configuration
  Future<void> _addAdvancedBudgetFields() async {
    await customStatement('ALTER TABLE budgets ADD COLUMN budget_transaction_filters TEXT');
    await customStatement('ALTER TABLE budgets ADD COLUMN exclude_debt_credit_installments BOOLEAN DEFAULT FALSE');
    await customStatement('ALTER TABLE budgets ADD COLUMN exclude_objective_installments BOOLEAN DEFAULT FALSE');
    await customStatement('ALTER TABLE budgets ADD COLUMN wallet_fks TEXT');
    await customStatement('ALTER TABLE budgets ADD COLUMN currency_fks TEXT');
    await customStatement('ALTER TABLE budgets ADD COLUMN shared_reference_budget_pk TEXT');
    await customStatement('ALTER TABLE budgets ADD COLUMN budget_fks_exclude TEXT');
    await customStatement('ALTER TABLE budgets ADD COLUMN normalize_to_currency TEXT');
    await customStatement('ALTER TABLE budgets ADD COLUMN is_income_budget BOOLEAN DEFAULT FALSE');
    await customStatement('ALTER TABLE budgets ADD COLUMN include_transfer_in_out_with_same_currency BOOLEAN DEFAULT FALSE');
    await customStatement('ALTER TABLE budgets ADD COLUMN include_upcoming_transaction_from_budget BOOLEAN DEFAULT FALSE');
    await customStatement('ALTER TABLE budgets ADD COLUMN date_created_original DATETIME');
  }

  /// Remove description field from transactions table
  /// SQLite doesn't support DROP COLUMN directly, so we recreate the table
  Future<void> _removeDescriptionField() async {
    // Create new table without description field
    await customStatement('''
      CREATE TABLE transactions_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL CHECK (length(title) >= 1 AND length(title) <= 255),
        note TEXT,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL REFERENCES categories(id),
        account_id INTEGER NOT NULL REFERENCES accounts(id),
        date DATETIME NOT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        transaction_type TEXT NOT NULL DEFAULT 'expense' CHECK (length(transaction_type) >= 1 AND length(transaction_type) <= 20),
        special_type TEXT CHECK (length(special_type) >= 1 AND length(special_type) <= 20),
        recurrence TEXT NOT NULL DEFAULT 'none' CHECK (length(recurrence) >= 1 AND length(recurrence) <= 20),
        period_length INTEGER,
        end_date DATETIME,
        original_date_due DATETIME,
        transaction_state TEXT NOT NULL DEFAULT 'completed' CHECK (length(transaction_state) >= 1 AND length(transaction_state) <= 20),
        paid BOOLEAN NOT NULL DEFAULT FALSE,
        skip_paid BOOLEAN NOT NULL DEFAULT FALSE,
        created_another_future_transaction BOOLEAN DEFAULT FALSE,
        objective_loan_fk TEXT,
        device_id TEXT NOT NULL CHECK (length(device_id) >= 1 AND length(device_id) <= 50),
        is_synced BOOLEAN NOT NULL DEFAULT FALSE,
        last_sync_at DATETIME,
        sync_id TEXT NOT NULL UNIQUE,
        version INTEGER NOT NULL DEFAULT 1
      )
    ''');
    
    // Copy data from old table to new table (excluding description)
    await customStatement('''
      INSERT INTO transactions_new (
        id, title, note, amount, category_id, account_id, date, created_at, updated_at,
        transaction_type, special_type, recurrence, period_length, end_date, original_date_due,
        transaction_state, paid, skip_paid, created_another_future_transaction, objective_loan_fk,
        device_id, is_synced, last_sync_at, sync_id, version
      )
      SELECT 
        id, title, note, amount, category_id, account_id, date, created_at, updated_at,
        transaction_type, special_type, recurrence, period_length, end_date, original_date_due,
        transaction_state, paid, skip_paid, created_another_future_transaction, objective_loan_fk,
        device_id, is_synced, last_sync_at, sync_id, version
      FROM transactions
    ''');
    
    // Drop old table and rename new table
    await customStatement('DROP TABLE transactions');
    await customStatement('ALTER TABLE transactions_new RENAME TO transactions');
  }

  /// Insert default categories and accounts
  Future<void> _insertDefaultData() async {
    final deviceId = 'default-device';
    
    // Insert all default categories using emoji icons
    for (final defaultCategory in DefaultCategories.allCategories) {
      await into(categoriesTable).insert(
        CategoriesTableCompanion.insert(
          name: defaultCategory.name,
          icon: defaultCategory.emoji,
          color: defaultCategory.color,
          isExpense: defaultCategory.isExpense,
          isDefault: const Value(true), // Mark as default categories
          deviceId: deviceId,
          syncId: defaultCategory.syncId,
        ),
      );
    }

    // Default account
    await into(accountsTable).insert(
      AccountsTableCompanion.insert(
        name: 'Main Account',
        deviceId: deviceId,
        syncId: 'account-main',
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'finance_db.sqlite'));

    // Make sure sqlite3 is available
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
