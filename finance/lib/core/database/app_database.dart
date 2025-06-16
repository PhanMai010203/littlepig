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
  int get schemaVersion => 2;

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
      },
    );
  }  /// Insert default categories and accounts
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
