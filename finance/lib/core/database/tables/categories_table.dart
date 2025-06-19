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

  // ✅ PHASE 4: Only essential sync field (event sourcing handles the rest)
  TextColumn get syncId => text().unique()();
}
