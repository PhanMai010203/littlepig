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
import 'tables/sync_event_log_table.dart';
import 'tables/sync_state_table.dart';
import 'tables/transaction_budgets_table.dart';
import '../constants/default_categories.dart';
import 'migrations/schema_cleanup_migration.dart';
import 'migrations/phase3_partial_loans_migration.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  TransactionsTable,
  CategoriesTable,
  BudgetsTable,
  AccountsTable,
  SyncMetadataTable,
  AttachmentsTable,
  SyncEventLogTable,
  SyncStateTable,
  TransactionBudgetsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Constructor for opening a specific file (used for sync merging)
  AppDatabase.fromFile(File file) : super(NativeDatabase(file));

  // Constructor for testing with in-memory database
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _insertDefaultCategories();
          await _insertDefaultAccount();
          await _addEventSourcingTriggers();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 7) {
            await m.createTable(syncEventLogTable);
            await m.createTable(syncStateTable);

            await _addEventSourcingTriggers();
          }

          // ✅ PHASE 4: Schema Cleanup Migration (v7 → v8)
          if (from < 8) {
            print('🧹 Starting Phase 4: Schema Cleanup Migration (v7 → v8)...');
            final migration = SchemaCleanupMigration(this);
            await migration.executeCleanup();
            print('✅ Phase 4 migration completed successfully!');
          }

          // ✅ PHASE 1: Account Color Customization (v8 → v9)
          if (from < 9) {
            print('🎨 Starting Phase 1: Account Color Migration (v8 → v9)...');
            await m.addColumn(
                accountsTable, accountsTable.color as GeneratedColumn);
            print('✅ Phase 1 migration completed successfully!');
          }

          // ✅ PHASE 2: Manual Budget Links (v9 → v10)
          if (from < 10) {
            print(
                '🔗 Starting Phase 2: Manual Budget Links Migration (v9 → v10)...');
            await m.createTable(transactionBudgetsTable);
            print('✅ Phase 2 migration completed successfully!');
          }

          // ✅ PHASE 3: Partial Loan Payments Migration (v10 → v11)
          if (from < 11) {
            print(
                '🏦 Starting Phase 3: Partial Loan Payments Migration (v10 → v11)...');
            final migration = Phase3PartialLoansMigration(this);
            await migration.executePhase3Migration();
            print('✅ Phase 3 migration completed successfully!');
          }

          // ✅ Budget Color Support Migration (v11 → v12)
          if (from < 12) {
            print(
                '🎨 Starting Budget Color Support Migration (v11 → v12)...');
            await m.addColumn(
                budgetsTable, budgetsTable.colour as GeneratedColumn);
            print('✅ Budget Color migration completed successfully!');
          }

          // ✅ Budget Period Amount Support Migration (v12 → v13)
          if (from < 13) {
            print(
                '📅 Starting Budget Period Amount Support Migration (v12 → v13)...');
            await m.addColumn(
                budgetsTable, budgetsTable.periodAmount as GeneratedColumn);
            print('✅ Budget Period Amount migration completed successfully!');
          }

          // ✅ Default Account Creation (v13 → v14)
          if (from < 14) {
            print('🏦 Starting Default Account Creation Migration (v13 → v14)...');
            // Check if there are no accounts, then create default account
            final accountCount = await customSelect('SELECT COUNT(*) as count FROM accounts').getSingle();
            final count = accountCount.data['count'] as int;
            if (count == 0) {
              await _insertDefaultAccount();
              print('✅ Default account created successfully!');
            } else {
              print('✅ Accounts already exist, skipping default account creation.');
            }
            print('✅ Default Account migration completed successfully!');
          }
        },
      );

  Future<void> _addEventSourcingTriggers() async {
    final deviceId = await _getOrCreateDeviceId();

    for (final tableName in [
      'transactions',
      'categories',
      'accounts',
      'budgets',
      'attachments',
      'transaction_budgets'
    ]) {
      await customStatement('''
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
            json_object(${_getTableFieldsForJson(tableName)}),
            datetime('now'),
            (SELECT COALESCE(MAX(sequence_number), 0) + 1 FROM sync_event_log WHERE device_id = '$deviceId'),
            '',
            false
          );
        END
      ''');

      await customStatement('''
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
            json_object(${_getTableFieldsForJson(tableName)}),
            datetime('now'),
            (SELECT COALESCE(MAX(sequence_number), 0) + 1 FROM sync_event_log WHERE device_id = '$deviceId'),
            '',
            false
          );
        END
      ''');

      await customStatement('''
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
            json_object('sync_id', OLD.sync_id),
            datetime('now'),
            (SELECT COALESCE(MAX(sequence_number), 0) + 1 FROM sync_event_log WHERE device_id = '$deviceId'),
            '',
            false
          );
        END
      ''');
    }
  }

  String _getTableFieldsForJson(String tableName) {
    switch (tableName) {
      case 'transactions':
        return '''
          'id', NEW.id,
          'title', NEW.title,
          'note', NEW.note,
          'amount', NEW.amount,
          'category_id', NEW.category_id,
          'account_id', NEW.account_id,
          'date', NEW.date,
          'created_at', NEW.created_at,
          'updated_at', NEW.updated_at,
          'transaction_type', NEW.transaction_type,
          'special_type', NEW.special_type,
          'recurrence', NEW.recurrence,
          'period_length', NEW.period_length,
          'end_date', NEW.end_date,
          'original_date_due', NEW.original_date_due,
          'transaction_state', NEW.transaction_state,
          'paid', NEW.paid,
          'skip_paid', NEW.skip_paid,
          'created_another_future_transaction', NEW.created_another_future_transaction,
          'objective_loan_fk', NEW.objective_loan_fk,
          'sync_id', NEW.sync_id,
          'remaining_amount', NEW.remaining_amount,
          'parent_transaction_id', NEW.parent_transaction_id
        ''';
      case 'categories':
        return '''
          'id', NEW.id,
          'name', NEW.name,
          'icon', NEW.icon,
          'color', NEW.color,
          'is_expense', NEW.is_expense,
          'is_default', NEW.is_default,
          'created_at', NEW.created_at,
          'updated_at', NEW.updated_at,
          'sync_id', NEW.sync_id
        ''';
      case 'accounts':
        return '''
          'id', NEW.id,
          'name', NEW.name,
          'balance', NEW.balance,
          'currency', NEW.currency,
          'is_default', NEW.is_default,
          'created_at', NEW.created_at,
          'updated_at', NEW.updated_at,
          'sync_id', NEW.sync_id
        ''';
      case 'budgets':
        return '''
          'id', NEW.id,
          'name', NEW.name,
          'amount', NEW.amount,
          'spent', NEW.spent,
          'category_id', NEW.category_id,
          'period', NEW.period,
          'period_amount', NEW.period_amount,
          'start_date', NEW.start_date,
          'end_date', NEW.end_date,
          'is_active', NEW.is_active,
          'created_at', NEW.created_at,
          'updated_at', NEW.updated_at,
          'budget_transaction_filters', NEW.budget_transaction_filters,
          'exclude_debt_credit_installments', NEW.exclude_debt_credit_installments,
          'exclude_objective_installments', NEW.exclude_objective_installments,
          'wallet_fks', NEW.wallet_fks,
          'currency_fks', NEW.currency_fks,
          'shared_reference_budget_pk', NEW.shared_reference_budget_pk,
          'budget_fks_exclude', NEW.budget_fks_exclude,
          'normalize_to_currency', NEW.normalize_to_currency,
          'is_income_budget', NEW.is_income_budget,
          'include_transfer_in_out_with_same_currency', NEW.include_transfer_in_out_with_same_currency,
          'include_upcoming_transaction_from_budget', NEW.include_upcoming_transaction_from_budget,
          'date_created_original', NEW.date_created_original,
          'colour', NEW.colour,
          'sync_id', NEW.sync_id
        ''';
      case 'attachments':
        return '''
          'id', NEW.id,
          'transaction_id', NEW.transaction_id,
          'file_name', NEW.file_name,
          'file_path', NEW.file_path,
          'google_drive_file_id', NEW.google_drive_file_id,
          'google_drive_link', NEW.google_drive_link,
          'type', NEW.type,
          'mime_type', NEW.mime_type,
          'file_size_bytes', NEW.file_size_bytes,
          'created_at', NEW.created_at,
          'updated_at', NEW.updated_at,
          'is_uploaded', NEW.is_uploaded,
          'is_deleted', NEW.is_deleted,
          'is_captured_from_camera', NEW.is_captured_from_camera,
          'local_cache_expiry', NEW.local_cache_expiry,
          'sync_id', NEW.sync_id
        ''';
      case 'transaction_budgets':
        return '''
          'id', NEW.id,
          'transaction_id', NEW.transaction_id,
          'budget_id', NEW.budget_id,
          'amount', NEW.amount,
          'created_at', NEW.created_at,
          'updated_at', NEW.updated_at,
          'sync_id', NEW.sync_id
        ''';
      default:
        return '''
          'id', NEW.id,
          'sync_id', NEW.sync_id
        ''';
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    final existing = await (select(syncMetadataTable)
          ..where((t) => t.key.equals('device_id')))
        .getSingleOrNull();

    if (existing != null) {
      return existing.value;
    }

    final deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
    await into(syncMetadataTable).insert(
      SyncMetadataTableCompanion.insert(
        key: 'device_id',
        value: deviceId,
      ),
    );

    return deviceId;
  }

  Future<void> _insertDefaultCategories() async {
    for (final category in DefaultCategories.allCategories) {
      await into(categoriesTable).insert(
        CategoriesTableCompanion.insert(
          name: category.name,
          icon: category.emoji,
          color: category.color,
          isExpense: category.isExpense,
          isDefault: const Value(true),
          syncId: category.syncId,
        ),
      );
    }
  }

  Future<void> _insertDefaultAccount() async {
    await into(accountsTable).insert(
      AccountsTableCompanion.insert(
        name: 'Main Account',
        balance: const Value(0.0),
        currency: const Value('VND'),
        isDefault: const Value(true),
        color: const Value(0xFF2196F3), // Blue color
        syncId: 'default-main-account',
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'finance_db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
