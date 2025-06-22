import 'package:drift/drift.dart';
import 'categories_table.dart';
import 'accounts_table.dart';

class TransactionsTable extends Table {
  @override
  String get tableName => 'transactions';
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get note => text().nullable()();
  RealColumn get amount => real()();

  IntColumn get categoryId => integer().references(CategoriesTable, #id)();
  IntColumn get accountId => integer().references(AccountsTable, #id)();

  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Advanced transaction fields

  // Transaction type and special type
  TextColumn get transactionType => text()
      .withLength(min: 1, max: 20)
      .withDefault(const Constant('expense'))();
  TextColumn get specialType =>
      text().withLength(min: 1, max: 20).nullable()(); // credit, debt, etc.

  // Recurring/Subscription fields
  TextColumn get recurrence =>
      text().withLength(min: 1, max: 20).withDefault(const Constant('none'))();
  IntColumn get periodLength =>
      integer().nullable()(); // e.g., 1 for "every 1 month"
  DateTimeColumn get endDate =>
      dateTime().nullable()(); // When to stop creating instances
  DateTimeColumn get originalDateDue =>
      dateTime().nullable()(); // Original due date for recurring

  // State and action management
  TextColumn get transactionState => text()
      .withLength(min: 1, max: 20)
      .withDefault(const Constant('completed'))();
  BoolColumn get paid => boolean()
      .withDefault(const Constant(false))(); // For loan/recurring logic
  BoolColumn get skipPaid => boolean()
      .withDefault(const Constant(false))(); // Skip vs pay for recurring
  BoolColumn get createdAnotherFutureTransaction => boolean()
      .withDefault(const Constant(false))
      .nullable()(); // Prevents duplicate creation

  // Loan/Objective linking (for complex loans)
  TextColumn get objectiveLoanFk =>
      text().nullable()(); // Links to objectives table (future use)

  // sync field (event sourcing handles the rest)
  TextColumn get syncId => text().unique()(); // UUID for global uniqueness

  // Phase 3 – Partial loan payments
  RealColumn get remainingAmount => real().nullable()();
  IntColumn get parentTransactionId =>
      integer().nullable().references(TransactionsTable, #id)();
}
