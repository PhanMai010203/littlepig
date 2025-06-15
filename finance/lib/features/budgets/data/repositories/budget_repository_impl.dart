import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final AppDatabase _database;
  final _uuid = const Uuid();

  BudgetRepositoryImpl(this._database);

  @override
  Future<List<Budget>> getAllBudgets() async {
    final budgets = await _database.select(_database.budgetsTable).get();
    return budgets.map(_mapToEntity).toList();
  }

  @override
  Future<List<Budget>> getActiveBudgets() async {
    final budgets = await (_database.select(_database.budgetsTable)
          ..where((tbl) => tbl.isActive.equals(true)))
        .get();
    return budgets.map(_mapToEntity).toList();
  }

  @override
  Future<Budget?> getBudgetById(int id) async {
    final budget = await (_database.select(_database.budgetsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return budget != null ? _mapToEntity(budget) : null;
  }

  @override
  Future<Budget?> getBudgetBySyncId(String syncId) async {
    final budget = await (_database.select(_database.budgetsTable)
          ..where((tbl) => tbl.syncId.equals(syncId)))
        .getSingleOrNull();
    return budget != null ? _mapToEntity(budget) : null;
  }

  @override
  Future<List<Budget>> getBudgetsByCategory(int categoryId) async {
    final budgets = await (_database.select(_database.budgetsTable)
          ..where((tbl) => tbl.categoryId.equals(categoryId)))
        .get();
    return budgets.map(_mapToEntity).toList();
  }

  @override
  Future<Budget> createBudget(Budget budget) async {
    final now = DateTime.now();
    final syncId = budget.syncId.isEmpty ? _uuid.v4() : budget.syncId;
    
    final companion = BudgetsTableCompanion.insert(
      name: budget.name,
      amount: budget.amount,
      spent: Value(budget.spent),
      categoryId: Value(budget.categoryId),
      period: budget.period.name,
      startDate: budget.startDate,
      endDate: budget.endDate,
      isActive: Value(budget.isActive),
      deviceId: budget.deviceId,
      syncId: syncId,
      createdAt: Value(budget.createdAt),
      updatedAt: Value(now),
    );

    final id = await _database.into(_database.budgetsTable).insert(companion);
    
    return budget.copyWith(
      id: id,
      syncId: syncId,
      updatedAt: now,
    );
  }

  @override
  Future<Budget> updateBudget(Budget budget) async {
    final now = DateTime.now();
    final companion = BudgetsTableCompanion(
      id: Value(budget.id!),
      name: Value(budget.name),
      amount: Value(budget.amount),
      spent: Value(budget.spent),
      categoryId: Value(budget.categoryId),
      period: Value(budget.period.name),
      startDate: Value(budget.startDate),
      endDate: Value(budget.endDate),
      isActive: Value(budget.isActive),
      updatedAt: Value(now),
      isSynced: const Value(false), // Mark as unsynced when updated
      version: Value(budget.version + 1),
    );

    await (_database.update(_database.budgetsTable)
          ..where((tbl) => tbl.id.equals(budget.id!)))
        .write(companion);
    
    return budget.copyWith(
      updatedAt: now,
      isSynced: false,
      version: budget.version + 1,
    );
  }

  @override
  Future<void> deleteBudget(int id) async {
    await (_database.delete(_database.budgetsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  @override
  Future<void> updateSpentAmount(int budgetId, double spentAmount) async {
    final now = DateTime.now();
    await (_database.update(_database.budgetsTable)
          ..where((tbl) => tbl.id.equals(budgetId)))
        .write(BudgetsTableCompanion(
          spent: Value(spentAmount),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ));
  }

  @override
  Future<List<Budget>> getUnsyncedBudgets() async {
    final budgets = await (_database.select(_database.budgetsTable)
          ..where((tbl) => tbl.isSynced.equals(false)))
        .get();
    return budgets.map(_mapToEntity).toList();
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    await (_database.update(_database.budgetsTable)
          ..where((tbl) => tbl.syncId.equals(syncId)))
        .write(BudgetsTableCompanion(
          isSynced: const Value(true),
          lastSyncAt: Value(syncTime),
        ));
  }

  @override
  Future<void> insertOrUpdateFromSync(Budget budget) async {
    final existing = await getBudgetBySyncId(budget.syncId);
    
    if (existing == null) {
      // Insert new budget from sync
      final companion = BudgetsTableCompanion.insert(
        name: budget.name,
        amount: budget.amount,
        spent: Value(budget.spent),
        categoryId: Value(budget.categoryId),
        period: budget.period.name,
        startDate: budget.startDate,
        endDate: budget.endDate,
        isActive: Value(budget.isActive),
        createdAt: Value(budget.createdAt),
        updatedAt: Value(budget.updatedAt),
        deviceId: budget.deviceId,
        isSynced: const Value(true),
        lastSyncAt: Value(budget.lastSyncAt),
        syncId: budget.syncId,
        version: Value(budget.version),
      );
      await _database.into(_database.budgetsTable).insert(companion);
    } else if (budget.version > existing.version) {
      // Update existing budget if incoming version is newer
      final companion = BudgetsTableCompanion(
        id: Value(existing.id!),
        name: Value(budget.name),
        amount: Value(budget.amount),
        spent: Value(budget.spent),
        categoryId: Value(budget.categoryId),
        period: Value(budget.period.name),
        startDate: Value(budget.startDate),
        endDate: Value(budget.endDate),
        isActive: Value(budget.isActive),
        updatedAt: Value(budget.updatedAt),
        isSynced: const Value(true),
        lastSyncAt: Value(budget.lastSyncAt),
        version: Value(budget.version),
      );
      
      await (_database.update(_database.budgetsTable)
            ..where((tbl) => tbl.id.equals(existing.id!)))
          .write(companion);
    }
  }

  Budget _mapToEntity(BudgetsTableData data) {
    return Budget(
      id: data.id,
      name: data.name,
      amount: data.amount,
      spent: data.spent,
      categoryId: data.categoryId,
      period: BudgetPeriod.values.firstWhere((e) => e.name == data.period),
      startDate: data.startDate,
      endDate: data.endDate,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deviceId: data.deviceId,
      isSynced: data.isSynced,
      lastSyncAt: data.lastSyncAt,
      syncId: data.syncId,
      version: data.version,
    );
  }
}
