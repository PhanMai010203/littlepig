import 'package:drift/drift.dart';
import 'transactions_table.dart';
import 'budgets_table.dart';

@DataClassName('TransactionBudgetTableData')
class TransactionBudgetsTable extends Table {
  @override
  String get tableName => 'transaction_budgets';

  IntColumn get id => integer().autoIncrement()();
  
  IntColumn get transactionId => integer().references(TransactionsTable, #id)();
  IntColumn get budgetId => integer().references(BudgetsTable, #id)();
  RealColumn get amount => real().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Sync field for event sourcing
  TextColumn get syncId => text().unique()();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY(transaction_id) REFERENCES transactions(id) ON DELETE CASCADE',
    'FOREIGN KEY(budget_id) REFERENCES budgets(id) ON DELETE CASCADE',
    'UNIQUE(transaction_id, budget_id)' // Prevent duplicate links
  ];
} 