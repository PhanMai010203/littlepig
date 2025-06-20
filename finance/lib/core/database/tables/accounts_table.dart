import 'package:drift/drift.dart';

class AccountsTable extends Table {
  @override
  String get tableName => 'accounts';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('USD'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // ✅ PHASE 1: Account color customization
  IntColumn get color => integer().withDefault(const Constant(0xFF9E9E9E))();

  // ✅ PHASE 4: Only essential sync field (event sourcing handles the rest)
  TextColumn get syncId => text().unique()();
}
