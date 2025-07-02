import '../../domain/entities/budget.dart';
import '../../domain/entities/transaction_budget_link.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/repositories/cacheable_repository_mixin.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:injectable/injectable.dart';
import 'dart:convert';

@LazySingleton(as: BudgetRepository)
class BudgetRepositoryImpl
    with CacheableRepositoryMixin
    implements BudgetRepository {
  final AppDatabase _database;
  final _uuid = const Uuid();

  BudgetRepositoryImpl(this._database);

  @override
  Future<List<Budget>> getAllBudgets() async {
    return cacheRead(
      'getAllBudgets',
      () async {
        final budgets = await _database.select(_database.budgetsTable).get();
        return budgets.map<Budget>(_mapToEntity).toList();
      },
      ttl: const Duration(minutes: 5), // Cache for 5 minutes
    );
  }

  @override
  Future<List<Budget>> getActiveBudgets() async {
    return cacheRead(
      'getActiveBudgets',
      () async {
        final budgets = await (_database.select(_database.budgetsTable)
              ..where((tbl) => tbl.isActive.equals(true)))
            .get();
        return budgets.map<Budget>(_mapToEntity).toList();
      },
      ttl: const Duration(minutes: 3), // Cache for 3 minutes
    );
  }

  @override
  Future<Budget?> getBudgetById(int id) async {
    return cacheReadSingle(
      'getBudgetById',
      () async {
        final budget = await (_database.select(_database.budgetsTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
        return budget != null ? _mapToEntity(budget) : null;
      },
      params: {'id': id},
      ttl: const Duration(minutes: 10), // Cache for 10 minutes
    );
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
    return cacheRead(
      'getBudgetsByCategory',
      () async {
        final budgets = await (_database.select(_database.budgetsTable)
              ..where((tbl) => tbl.categoryId.equals(categoryId)))
            .get();
        return budgets.map<Budget>(_mapToEntity).toList();
      },
      params: {'categoryId': categoryId},
    );
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
      periodAmount: Value(budget.periodAmount),
      startDate: budget.startDate,
      endDate: budget.endDate,
      isActive: Value(budget.isActive),
      syncId: syncId,
      createdAt: Value(budget.createdAt),
      updatedAt: Value(now),

      // Advanced filtering fields
      budgetTransactionFilters: Value(budget.budgetTransactionFilters != null
          ? jsonEncode(budget.budgetTransactionFilters)
          : null),
      excludeDebtCreditInstallments:
          Value(budget.excludeDebtCreditInstallments),
      excludeObjectiveInstallments: Value(budget.excludeObjectiveInstallments),
      walletFks:
          Value(budget.walletFks != null ? jsonEncode(budget.walletFks) : null),
      currencyFks: Value(
          budget.currencyFks != null ? jsonEncode(budget.currencyFks) : null),
      sharedReferenceBudgetPk: Value(budget.sharedReferenceBudgetPk),
      budgetFksExclude: Value(budget.budgetFksExclude != null
          ? jsonEncode(budget.budgetFksExclude)
          : null),
      normalizeToCurrency: Value(budget.normalizeToCurrency),
      isIncomeBudget: Value(budget.isIncomeBudget),
      includeTransferInOutWithSameCurrency:
          Value(budget.includeTransferInOutWithSameCurrency),
      includeUpcomingTransactionFromBudget:
          Value(budget.includeUpcomingTransactionFromBudget),
      dateCreatedOriginal: Value(budget.dateCreatedOriginal),
      colour: Value(budget.colour),
    );

    final id = await _database.into(_database.budgetsTable).insert(companion);

    // Invalidate cache after creating budget
    await invalidateEntityCache('budget');

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

      // Advanced filtering fields
      budgetTransactionFilters: Value(budget.budgetTransactionFilters != null
          ? jsonEncode(budget.budgetTransactionFilters)
          : null),
      excludeDebtCreditInstallments:
          Value(budget.excludeDebtCreditInstallments),
      excludeObjectiveInstallments: Value(budget.excludeObjectiveInstallments),
      walletFks:
          Value(budget.walletFks != null ? jsonEncode(budget.walletFks) : null),
      currencyFks: Value(
          budget.currencyFks != null ? jsonEncode(budget.currencyFks) : null),
      sharedReferenceBudgetPk: Value(budget.sharedReferenceBudgetPk),
      budgetFksExclude: Value(budget.budgetFksExclude != null
          ? jsonEncode(budget.budgetFksExclude)
          : null),
      normalizeToCurrency: Value(budget.normalizeToCurrency),
      isIncomeBudget: Value(budget.isIncomeBudget),
      includeTransferInOutWithSameCurrency:
          Value(budget.includeTransferInOutWithSameCurrency),
      includeUpcomingTransactionFromBudget:
          Value(budget.includeUpcomingTransactionFromBudget),
      dateCreatedOriginal: Value(budget.dateCreatedOriginal),
      colour: Value(budget.colour),
    );

    await (_database.update(_database.budgetsTable)
          ..where((tbl) => tbl.id.equals(budget.id!)))
        .write(companion);

    // Invalidate cache after updating budget
    await invalidateEntityCache('budget');

    return budget.copyWith(updatedAt: now);
  }

  @override
  Future<void> deleteBudget(int id) async {
    // Delete budget and its related transaction links in a single transaction
    await _database.transaction(() async {
      // 1. Remove links referencing this budget
      await (_database.delete(_database.transactionBudgetsTable)
            ..where((tbl) => tbl.budgetId.equals(id)))
          .go();

      // 2. Delete the budget itself
      await (_database.delete(_database.budgetsTable)
            ..where((b) => b.id.equals(id)))
          .go();
    });

    // Invalidate caches for both budgets and transaction-budget links
    await invalidateEntityCache('budget');
    await invalidateEntityCache('transaction_budget_link');
  }

  @override
  Future<void> deleteAllBudgets() async {
    await _database.transaction(() async {
      // Clear links first to maintain FK consistency
      await _database.delete(_database.transactionBudgetsTable).go();
      await _database.delete(_database.budgetsTable).go();
    });

    await invalidateEntityCache('budget');
    await invalidateEntityCache('transaction_budget_link');
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

    await invalidateEntityCache('budget');
  }

  @override
  Future<List<Budget>> getUnsyncedBudgets() async {
    // ✅ PHASE 4: With event sourcing, use event log to determine unsynced items
    // For now, return all budgets since individual table sync is replaced by event sourcing
    final budgets = await _database.select(_database.budgetsTable).get();
    return budgets.map<Budget>(_mapToEntity).toList();
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    // ✅ PHASE 4: No-op since sync fields removed from table
    // Event sourcing tracks sync status in sync_event_log table
    // This method kept for backward compatibility
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
        periodAmount: Value(budget.periodAmount),
        startDate: budget.startDate,
        endDate: budget.endDate,
        isActive: Value(budget.isActive),
        createdAt: Value(budget.createdAt),
        updatedAt: Value(budget.updatedAt),
        syncId: budget.syncId,

        // Advanced filtering fields
        budgetTransactionFilters: Value(budget.budgetTransactionFilters != null
            ? jsonEncode(budget.budgetTransactionFilters)
            : null),
        excludeDebtCreditInstallments:
            Value(budget.excludeDebtCreditInstallments),
        excludeObjectiveInstallments:
            Value(budget.excludeObjectiveInstallments),
        walletFks: Value(
            budget.walletFks != null ? jsonEncode(budget.walletFks) : null),
        currencyFks: Value(
            budget.currencyFks != null ? jsonEncode(budget.currencyFks) : null),
        sharedReferenceBudgetPk: Value(budget.sharedReferenceBudgetPk),
        budgetFksExclude: Value(budget.budgetFksExclude != null
            ? jsonEncode(budget.budgetFksExclude)
            : null),
        normalizeToCurrency: Value(budget.normalizeToCurrency),
        isIncomeBudget: Value(budget.isIncomeBudget),
        includeTransferInOutWithSameCurrency:
            Value(budget.includeTransferInOutWithSameCurrency),
        includeUpcomingTransactionFromBudget:
            Value(budget.includeUpcomingTransactionFromBudget),
        dateCreatedOriginal: Value(budget.dateCreatedOriginal),
        colour: Value(budget.colour),
      );
      await _database.into(_database.budgetsTable).insert(companion);
    } else {
      // ✅ PHASE 4: Always update with newer data from sync (no version comparison needed)
      final companion = BudgetsTableCompanion(
        id: Value(existing.id!),
        name: Value(budget.name),
        amount: Value(budget.amount),
        spent: Value(budget.spent),
        categoryId: Value(budget.categoryId),
        period: Value(budget.period.name),
        periodAmount: Value(budget.periodAmount),
        startDate: Value(budget.startDate),
        endDate: Value(budget.endDate),
        isActive: Value(budget.isActive),
        updatedAt: Value(budget.updatedAt),

        // Advanced filtering fields
        budgetTransactionFilters: Value(budget.budgetTransactionFilters != null
            ? jsonEncode(budget.budgetTransactionFilters)
            : null),
        excludeDebtCreditInstallments:
            Value(budget.excludeDebtCreditInstallments),
        excludeObjectiveInstallments:
            Value(budget.excludeObjectiveInstallments),
        walletFks: Value(
            budget.walletFks != null ? jsonEncode(budget.walletFks) : null),
        currencyFks: Value(
            budget.currencyFks != null ? jsonEncode(budget.currencyFks) : null),
        sharedReferenceBudgetPk: Value(budget.sharedReferenceBudgetPk),
        budgetFksExclude: Value(budget.budgetFksExclude != null
            ? jsonEncode(budget.budgetFksExclude)
            : null),
        normalizeToCurrency: Value(budget.normalizeToCurrency),
        isIncomeBudget: Value(budget.isIncomeBudget),
        includeTransferInOutWithSameCurrency:
            Value(budget.includeTransferInOutWithSameCurrency),
        includeUpcomingTransactionFromBudget:
            Value(budget.includeUpcomingTransactionFromBudget),
        dateCreatedOriginal: Value(budget.dateCreatedOriginal),
        colour: Value(budget.colour),
      );

      await (_database.update(_database.budgetsTable)
            ..where((tbl) => tbl.id.equals(existing.id!)))
          .write(companion);
    }

    // Invalidate cache
    await invalidateEntityCache('budget');
  }

  // ✅ PHASE 2: Manual budget linking methods
  @override
  Future<void> addTransactionToBudget(int transactionId, int budgetId,
      {double? amount}) async {
    // Check if link already exists to prevent duplicates
    final existing = await (_database.select(_database.transactionBudgetsTable)
          ..where((tbl) =>
              tbl.transactionId.equals(transactionId) &
              tbl.budgetId.equals(budgetId)))
        .getSingleOrNull();

    if (existing != null) {
      // Update existing link with new amount if provided
      if (amount != null) {
        await (_database.update(_database.transactionBudgetsTable)
              ..where((tbl) => tbl.id.equals(existing.id)))
            .write(TransactionBudgetsTableCompanion(
          amount: Value(amount),
          updatedAt: Value(DateTime.now()),
        ));
      }
      return;
    }

    // Create new link
    final now = DateTime.now();
    final syncId = _uuid.v4();

    await _database.into(_database.transactionBudgetsTable).insert(
          TransactionBudgetsTableCompanion.insert(
            transactionId: transactionId,
            budgetId: budgetId,
            amount: Value(amount ?? 0.0),
            syncId: syncId,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    // Invalidate related caches
    await invalidateEntityCache('budget');
    await invalidateEntityCache('transaction_budget_link');
  }

  @override
  Future<void> removeTransactionFromBudget(
      int transactionId, int budgetId) async {
    await (_database.delete(_database.transactionBudgetsTable)
          ..where((tbl) =>
              tbl.transactionId.equals(transactionId) &
              tbl.budgetId.equals(budgetId)))
        .go();

    // Invalidate related caches
    await invalidateEntityCache('budget');
    await invalidateEntityCache('transaction_budget_link');
  }

  @override
  Future<List<Budget>> getBudgetsForTransaction(int transactionId) async {
    return cacheRead(
      'getBudgetsForTransaction',
      () async {
        final query = _database.select(_database.budgetsTable).join([
          innerJoin(
            _database.transactionBudgetsTable,
            _database.budgetsTable.id
                .equalsExp(_database.transactionBudgetsTable.budgetId),
          ),
        ])
          ..where(_database.transactionBudgetsTable.transactionId
              .equals(transactionId));

        final results = await query.get();
        return results
            .map((row) => _mapToEntity(row.readTable(_database.budgetsTable)))
            .toList();
      },
      params: {'transactionId': transactionId},
      ttl: const Duration(minutes: 5),
    );
  }

  @override
  Future<List<TransactionBudgetLink>> getTransactionLinksForBudget(
      int budgetId) async {
    return cacheRead(
      'getTransactionLinksForBudget',
      () async {
        final links = await (_database.select(_database.transactionBudgetsTable)
              ..where((tbl) => tbl.budgetId.equals(budgetId)))
            .get();
        return links
            .map<TransactionBudgetLink>(_mapTransactionBudgetLinkToEntity)
            .toList();
      },
      params: {'budgetId': budgetId},
      ttl: const Duration(minutes: 5),
    );
  }

  @override
  Future<List<TransactionBudgetLink>> getAllTransactionBudgetLinks() async {
    return cacheRead(
      'getAllTransactionBudgetLinks',
      () async {
        final links =
            await _database.select(_database.transactionBudgetsTable).get();
        return links
            .map<TransactionBudgetLink>(_mapTransactionBudgetLinkToEntity)
            .toList();
      },
      ttl: const Duration(minutes: 5),
    );
  }

  TransactionBudgetLink _mapTransactionBudgetLinkToEntity(
      TransactionBudgetTableData data) {
    return TransactionBudgetLink(
      id: data.id,
      transactionId: data.transactionId,
      budgetId: data.budgetId,
      amount: data.amount,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      syncId: data.syncId,
    );
  }

  Budget _mapToEntity(BudgetTableData data) {
    return Budget(
      id: data.id,
      name: data.name,
      amount: data.amount,
      spent: data.spent,
      categoryId: data.categoryId,
      period: BudgetPeriod.values.firstWhere((e) => e.name == data.period),
      periodAmount: data.periodAmount,
      startDate: data.startDate,
      endDate: data.endDate,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      syncId: data.syncId,

      // Advanced filtering fields
      excludeDebtCreditInstallments: data.excludeDebtCreditInstallments,
      excludeObjectiveInstallments: data.excludeObjectiveInstallments,
      walletFks: data.walletFks != null
          ? List<String>.from(jsonDecode(data.walletFks!))
          : null,
      currencyFks: data.currencyFks != null
          ? List<String>.from(jsonDecode(data.currencyFks!))
          : null,
      sharedReferenceBudgetPk: data.sharedReferenceBudgetPk,
      budgetFksExclude: data.budgetFksExclude != null
          ? List<String>.from(jsonDecode(data.budgetFksExclude!))
          : null,
      normalizeToCurrency: data.normalizeToCurrency,
      isIncomeBudget: data.isIncomeBudget,
      includeTransferInOutWithSameCurrency:
          data.includeTransferInOutWithSameCurrency,
      includeUpcomingTransactionFromBudget:
          data.includeUpcomingTransactionFromBudget,
      dateCreatedOriginal: data.dateCreatedOriginal,
      budgetTransactionFilters: data.budgetTransactionFilters != null
          ? Map<String, dynamic>.from(
              jsonDecode(data.budgetTransactionFilters!))
          : null,
      colour: data.colour,
    );
  }
}
