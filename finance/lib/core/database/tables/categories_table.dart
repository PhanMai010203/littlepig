import 'package:drift/drift.dart';

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
