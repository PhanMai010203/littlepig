import 'package:drift/drift.dart';
import 'categories_table.dart';

@DataClassName('BudgetTableData')
class BudgetsTable extends Table {
  @override
  String get tableName => 'budgets';

  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get amount => real()();
  RealColumn get spent => real().withDefault(const Constant(0.0))();
  
  IntColumn get categoryId => integer().references(CategoriesTable, #id).nullable()();
  
  // Budget period: 'monthly', 'weekly', 'daily', 'yearly'
  TextColumn get period => text().withLength(min: 1, max: 20)();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  // Sync fields
  TextColumn get deviceId => text().withLength(min: 1, max: 50)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get syncId => text().unique()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  
  // Advanced filtering fields (Phase 2)
  TextColumn get budgetTransactionFilters => text().nullable()(); // JSON string
  BoolColumn get excludeDebtCreditInstallments => boolean().withDefault(const Constant(false))();
  BoolColumn get excludeObjectiveInstallments => boolean().withDefault(const Constant(false))();
  TextColumn get walletFks => text().nullable()(); // JSON array of wallet IDs
  TextColumn get currencyFks => text().nullable()(); // JSON array of currency codes
  
  // Shared budget support
  TextColumn get sharedReferenceBudgetPk => text().nullable()();
  TextColumn get budgetFksExclude => text().nullable()(); // JSON array of budget IDs to exclude
  
  // Currency normalization
  TextColumn get normalizeToCurrency => text().nullable()();
  BoolColumn get isIncomeBudget => boolean().withDefault(const Constant(false))();
  
  // Advanced features
  BoolColumn get includeTransferInOutWithSameCurrency => boolean().withDefault(const Constant(false))();
  BoolColumn get includeUpcomingTransactionFromBudget => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dateCreatedOriginal => dateTime().nullable()();
}
