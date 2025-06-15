import 'package:drift/drift.dart';

class TransactionsTable extends Table {
  @override
  String get tableName => 'transactions';

  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real()();
  
  IntColumn get categoryId => integer().references(CategoriesTable, #id)();
  IntColumn get accountId => integer().references(AccountsTable, #id)();
  
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  // Sync fields
  TextColumn get deviceId => text().withLength(min: 1, max: 50)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  
  // For conflict resolution
  TextColumn get syncId => text().unique()(); // UUID for global uniqueness
  IntColumn get version => integer().withDefault(const Constant(1))();
}

class CategoriesTable extends Table {
  @override
  String get tableName => 'categories';

  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get icon => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer()(); // Color value as int
  BoolColumn get isExpense => boolean()(); // true for expense, false for income
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  // Sync fields
  TextColumn get deviceId => text().withLength(min: 1, max: 50)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get syncId => text().unique()();
  IntColumn get version => integer().withDefault(const Constant(1))();
}

class AccountsTable extends Table {
  @override
  String get tableName => 'accounts';

  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withLength(min: 3, max: 3).withDefault(const Constant('USD'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  // Sync fields
  TextColumn get deviceId => text().withLength(min: 1, max: 50)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get syncId => text().unique()();
  IntColumn get version => integer().withDefault(const Constant(1))();
}

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
}

class SyncMetadataTable extends Table {
  @override
  String get tableName => 'sync_metadata';

  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get key => text().unique()(); // 'last_sync', 'device_id', etc.
  TextColumn get value => text()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
