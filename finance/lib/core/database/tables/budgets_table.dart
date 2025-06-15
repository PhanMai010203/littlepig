import 'package:drift/drift.dart';
import 'categories_table.dart';

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
