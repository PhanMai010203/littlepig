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

part 'app_database.g.dart';

@DriftDatabase(tables: [
  TransactionsTable,
  CategoriesTable,
  BudgetsTable,
  AccountsTable,
  SyncMetadataTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  // Constructor for opening a specific file (used for sync merging)
  AppDatabase.fromFile(File file) : super(NativeDatabase(file));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _insertDefaultData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future schema migrations here
      },
    );
  }  /// Insert default categories and accounts
  Future<void> _insertDefaultData() async {
    final deviceId = 'default-device';
    
    // Default expense categories
    final expenseCategories = [
      CategoriesTableCompanion.insert(
        name: 'Food & Dining',
        icon: 'restaurant',
        color: 0xFFFF6B35,
        isExpense: true,
        deviceId: deviceId,
        syncId: 'category-food-dining',
      ),
      CategoriesTableCompanion.insert(
        name: 'Transportation',
        icon: 'directions_car',
        color: 0xFF4CAF50,
        isExpense: true,
        deviceId: deviceId,
        syncId: 'category-transportation',
      ),
      CategoriesTableCompanion.insert(
        name: 'Shopping',
        icon: 'shopping_bag',
        color: 0xFF9C27B0,
        isExpense: true,
        deviceId: deviceId,
        syncId: 'category-shopping',
      ),
      CategoriesTableCompanion.insert(
        name: 'Entertainment',
        icon: 'movie',
        color: 0xFFE91E63,
        isExpense: true,
        deviceId: deviceId,
        syncId: 'category-entertainment',
      ),
      CategoriesTableCompanion.insert(
        name: 'Healthcare',
        icon: 'local_hospital',
        color: 0xFFF44336,
        isExpense: true,
        deviceId: deviceId,
        syncId: 'category-healthcare',
      ),
      CategoriesTableCompanion.insert(
        name: 'Utilities',
        icon: 'flash_on',
        color: 0xFFFF9800,
        isExpense: true,
        deviceId: deviceId,
        syncId: 'category-utilities',
      ),
    ];

    // Default income categories
    final incomeCategories = [
      CategoriesTableCompanion.insert(
        name: 'Salary',
        icon: 'work',
        color: 0xFF2196F3,
        isExpense: false,
        deviceId: deviceId,
        syncId: 'category-salary',
      ),
      CategoriesTableCompanion.insert(
        name: 'Freelance',
        icon: 'laptop_mac',
        color: 0xFF673AB7,
        isExpense: false,
        deviceId: deviceId,
        syncId: 'category-freelance',
      ),
      CategoriesTableCompanion.insert(
        name: 'Investment',
        icon: 'trending_up',
        color: 0xFF4CAF50,
        isExpense: false,
        deviceId: deviceId,
        syncId: 'category-investment',
      ),
    ];

    // Insert categories
    for (final category in [...expenseCategories, ...incomeCategories]) {
      await into(categoriesTable).insert(category);
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
