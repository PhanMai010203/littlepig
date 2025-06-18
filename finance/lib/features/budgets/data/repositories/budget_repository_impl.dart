import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class BudgetRepositoryImpl implements BudgetRepository {
  final AppDatabase _database;
  final _uuid = const Uuid();

  BudgetRepositoryImpl(this._database);

  @override
  Future<List<Budget>> getAllBudgets() async {
    final budgets = await _database.select(_database.budgetsTable).get();
    return budgets.map<Budget>(_mapToEntity).toList();
  }

  @override
  Future<List<Budget>> getActiveBudgets() async {
    final budgets = await (_database.select(_database.budgetsTable)
          ..where((tbl) => tbl.isActive.equals(true)))
        .get();
    return budgets.map<Budget>(_mapToEntity).toList();
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
    return budgets.map<Budget>(_mapToEntity).toList();
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
      
      // Advanced filtering fields
      budgetTransactionFilters: Value(budget.budgetTransactionFilters != null 
        ? jsonEncode(budget.budgetTransactionFilters) 
        : null),
      excludeDebtCreditInstallments: Value(budget.excludeDebtCreditInstallments),
      excludeObjectiveInstallments: Value(budget.excludeObjectiveInstallments),
      walletFks: Value(budget.walletFks != null 
        ? jsonEncode(budget.walletFks) 
        : null),
      currencyFks: Value(budget.currencyFks != null 
        ? jsonEncode(budget.currencyFks) 
        : null),
      sharedReferenceBudgetPk: Value(budget.sharedReferenceBudgetPk),
      budgetFksExclude: Value(budget.budgetFksExclude != null 
        ? jsonEncode(budget.budgetFksExclude) 
        : null),
      normalizeToCurrency: Value(budget.normalizeToCurrency),
      isIncomeBudget: Value(budget.isIncomeBudget),
      includeTransferInOutWithSameCurrency: Value(budget.includeTransferInOutWithSameCurrency),
      includeUpcomingTransactionFromBudget: Value(budget.includeUpcomingTransactionFromBudget),
      dateCreatedOriginal: Value(budget.dateCreatedOriginal),
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
      
      // Advanced filtering fields
      budgetTransactionFilters: Value(budget.budgetTransactionFilters != null 
        ? jsonEncode(budget.budgetTransactionFilters) 
        : null),
      excludeDebtCreditInstallments: Value(budget.excludeDebtCreditInstallments),
      excludeObjectiveInstallments: Value(budget.excludeObjectiveInstallments),
      walletFks: Value(budget.walletFks != null 
        ? jsonEncode(budget.walletFks) 
        : null),
      currencyFks: Value(budget.currencyFks != null 
        ? jsonEncode(budget.currencyFks) 
        : null),
      sharedReferenceBudgetPk: Value(budget.sharedReferenceBudgetPk),
      budgetFksExclude: Value(budget.budgetFksExclude != null 
        ? jsonEncode(budget.budgetFksExclude) 
        : null),
      normalizeToCurrency: Value(budget.normalizeToCurrency),
      isIncomeBudget: Value(budget.isIncomeBudget),
      includeTransferInOutWithSameCurrency: Value(budget.includeTransferInOutWithSameCurrency),
      includeUpcomingTransactionFromBudget: Value(budget.includeUpcomingTransactionFromBudget),
      dateCreatedOriginal: Value(budget.dateCreatedOriginal),
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
        ));
  }

  @override
  Future<List<Budget>> getUnsyncedBudgets() async {
    // Phase 4: Since sync fields removed, return all budgets for now
    // TODO: Implement proper event sourcing logic
    final budgets = await _database.select(_database.budgetsTable).get();
    return budgets.map<Budget>(_mapToEntity).toList();
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    // Phase 4: No-op since sync fields removed from table
    // TODO: Implement proper event sourcing logic
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
        
        // Advanced filtering fields
        budgetTransactionFilters: Value(budget.budgetTransactionFilters != null 
          ? jsonEncode(budget.budgetTransactionFilters) 
          : null),
        excludeDebtCreditInstallments: Value(budget.excludeDebtCreditInstallments),
        excludeObjectiveInstallments: Value(budget.excludeObjectiveInstallments),
        walletFks: Value(budget.walletFks != null 
          ? jsonEncode(budget.walletFks) 
          : null),
        currencyFks: Value(budget.currencyFks != null 
          ? jsonEncode(budget.currencyFks) 
          : null),
        sharedReferenceBudgetPk: Value(budget.sharedReferenceBudgetPk),
        budgetFksExclude: Value(budget.budgetFksExclude != null 
          ? jsonEncode(budget.budgetFksExclude) 
          : null),
        normalizeToCurrency: Value(budget.normalizeToCurrency),
        isIncomeBudget: Value(budget.isIncomeBudget),
        includeTransferInOutWithSameCurrency: Value(budget.includeTransferInOutWithSameCurrency),
        includeUpcomingTransactionFromBudget: Value(budget.includeUpcomingTransactionFromBudget),
        dateCreatedOriginal: Value(budget.dateCreatedOriginal),
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
        
        // Advanced filtering fields
        budgetTransactionFilters: Value(budget.budgetTransactionFilters != null 
          ? jsonEncode(budget.budgetTransactionFilters) 
          : null),
        excludeDebtCreditInstallments: Value(budget.excludeDebtCreditInstallments),
        excludeObjectiveInstallments: Value(budget.excludeObjectiveInstallments),
        walletFks: Value(budget.walletFks != null 
          ? jsonEncode(budget.walletFks) 
          : null),
        currencyFks: Value(budget.currencyFks != null 
          ? jsonEncode(budget.currencyFks) 
          : null),
        sharedReferenceBudgetPk: Value(budget.sharedReferenceBudgetPk),
        budgetFksExclude: Value(budget.budgetFksExclude != null 
          ? jsonEncode(budget.budgetFksExclude) 
          : null),
        normalizeToCurrency: Value(budget.normalizeToCurrency),
        isIncomeBudget: Value(budget.isIncomeBudget),
        includeTransferInOutWithSameCurrency: Value(budget.includeTransferInOutWithSameCurrency),
        includeUpcomingTransactionFromBudget: Value(budget.includeUpcomingTransactionFromBudget),
        dateCreatedOriginal: Value(budget.dateCreatedOriginal),
      );
      
      await (_database.update(_database.budgetsTable)
            ..where((tbl) => tbl.id.equals(existing.id!)))
          .write(companion);
    }
  }

  Budget _mapToEntity(BudgetTableData data) {
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
      
      // Advanced filtering fields with proper JSON parsing
      budgetTransactionFilters: data.budgetTransactionFilters != null 
        ? _parseJsonMap(data.budgetTransactionFilters!) 
        : null,
      excludeDebtCreditInstallments: data.excludeDebtCreditInstallments,
      excludeObjectiveInstallments: data.excludeObjectiveInstallments,
      walletFks: data.walletFks != null 
        ? _parseJsonStringList(data.walletFks!) 
        : null,
      currencyFks: data.currencyFks != null 
        ? _parseJsonStringList(data.currencyFks!) 
        : null,
      sharedReferenceBudgetPk: data.sharedReferenceBudgetPk,
      budgetFksExclude: data.budgetFksExclude != null 
        ? _parseJsonStringList(data.budgetFksExclude!) 
        : null,
      normalizeToCurrency: data.normalizeToCurrency,
      isIncomeBudget: data.isIncomeBudget,
      includeTransferInOutWithSameCurrency: data.includeTransferInOutWithSameCurrency,
      includeUpcomingTransactionFromBudget: data.includeUpcomingTransactionFromBudget,
      dateCreatedOriginal: data.dateCreatedOriginal,
    );
  }

  // Helper methods for JSON parsing
  List<String>? _parseJsonStringList(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.cast<String>();
      }
      return null;
    } catch (e) {
      print('Error parsing JSON string list: $e');
      return null;
    }
  }

  Map<String, dynamic>? _parseJsonMap(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      print('Error parsing JSON map: $e');
      return null;
    }
  }
}
