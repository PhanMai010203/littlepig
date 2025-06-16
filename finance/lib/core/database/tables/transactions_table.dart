import 'package:drift/drift.dart';
import 'categories_table.dart';
import 'accounts_table.dart';

class TransactionsTable extends Table {
  @override
  String get tableName => 'transactions';

  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get note => text().nullable()();
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
