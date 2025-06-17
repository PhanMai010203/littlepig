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
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _insertDefaultData();
      },      onUpgrade: (Migrator m, int from, int to) async {
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
          // Phase 1: Add advanced transaction features fields
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
      },
    );
  }/// Insert default categories and accounts
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
