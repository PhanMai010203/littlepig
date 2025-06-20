import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/repositories/cacheable_repository_mixin.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../budgets/domain/services/budget_update_service.dart';

class TransactionRepositoryImpl with CacheableRepositoryMixin implements TransactionRepository {
  final AppDatabase _database;
  BudgetUpdateService? _budgetUpdateService;

  TransactionRepositoryImpl(
    this._database, {
    BudgetUpdateService? budgetUpdateService,
  }) : _budgetUpdateService = budgetUpdateService;

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return cacheRead(
      'getAllTransactions',
      () async {
        final query = _database.select(_database.transactionsTable);
        final results = await query.get();
        return results.map(_mapTransactionData).toList();
      },
      ttl: const Duration(minutes: 5), // Cache for 5 minutes
    );
  }

  @override
  Future<List<Transaction>> getTransactionsByAccount(int accountId) async {
    return cacheRead(
      'getTransactionsByAccount',
      () async {
        final query = _database.select(_database.transactionsTable)
          ..where((t) => t.accountId.equals(accountId));
        final results = await query.get();
        return results.map(_mapTransactionData).toList();
      },
      params: {'accountId': accountId},
      ttl: const Duration(minutes: 3), // Cache for 3 minutes
    );
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    return cacheRead(
      'getTransactionsByCategory',
      () async {
        final query = _database.select(_database.transactionsTable)
          ..where((t) => t.categoryId.equals(categoryId));
        final results = await query.get();
        return results.map(_mapTransactionData).toList();
      },
      params: {'categoryId': categoryId},
      ttl: const Duration(minutes: 3), // Cache for 3 minutes
    );
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = _database.select(_database.transactionsTable)
      ..where((t) => t.date.isBetweenValues(startDate, endDate));
    final results = await query.get();
    return results.map(_mapTransactionData).toList();
  }

  @override
  Future<Transaction?> getTransactionById(int id) async {
    return cacheReadSingle(
      'getTransactionById',
      () async {
        final query = _database.select(_database.transactionsTable)
          ..where((t) => t.id.equals(id));
        final result = await query.getSingleOrNull();
        return result != null ? _mapTransactionData(result) : null;
      },
      params: {'id': id},
      ttl: const Duration(minutes: 10), // Cache for 10 minutes
    );
  }

  @override
  Future<Transaction?> getTransactionBySyncId(String syncId) async {
    final query = _database.select(_database.transactionsTable)
      ..where((t) => t.syncId.equals(syncId));
    final result = await query.getSingleOrNull();
    return result != null ? _mapTransactionData(result) : null;
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    final companion = TransactionsTableCompanion.insert(
      title: transaction.title,
      note: Value(transaction.note),
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      accountId: transaction.accountId,
      date: transaction.date,

      // Advanced fields
      transactionType: Value(transaction.transactionType.name),
      specialType: Value(transaction.specialType?.name),
      recurrence: Value(transaction.recurrence.name),
      periodLength: Value(transaction.periodLength),
      endDate: Value(transaction.endDate),
      originalDateDue: Value(transaction.originalDateDue),
      transactionState: Value(transaction.transactionState.name),
      paid: Value(transaction.paid),
      skipPaid: Value(transaction.skipPaid),
      createdAnotherFutureTransaction:
          Value(transaction.createdAnotherFutureTransaction),
      objectiveLoanFk: Value(transaction.objectiveLoanFk),

      // ✅ PHASE 4: Only essential sync field
      syncId: const Uuid().v4(),
    );

    final id =
        await _database.into(_database.transactionsTable).insert(companion);
    final createdTransaction = transaction.copyWith(id: id);

    // Invalidate cache after creating transaction
    await invalidateEntityCache('transaction');

    // Trigger budget updates if service is available
    if (_budgetUpdateService != null) {
      await _budgetUpdateService!.updateBudgetOnTransactionChange(
          createdTransaction, TransactionChangeType.created);
    }

    return createdTransaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final companion = TransactionsTableCompanion(
      id: Value(transaction.id!),
      title: Value(transaction.title),
      note: Value(transaction.note),
      amount: Value(transaction.amount),
      categoryId: Value(transaction.categoryId),
      accountId: Value(transaction.accountId),
      date: Value(transaction.date),

      // Advanced fields
      transactionType: Value(transaction.transactionType.name),
      specialType: Value(transaction.specialType?.name),
      recurrence: Value(transaction.recurrence.name),
      periodLength: Value(transaction.periodLength),
      endDate: Value(transaction.endDate),
      originalDateDue: Value(transaction.originalDateDue),
      transactionState: Value(transaction.transactionState.name),
      paid: Value(transaction.paid),
      skipPaid: Value(transaction.skipPaid),
      createdAnotherFutureTransaction:
          Value(transaction.createdAnotherFutureTransaction),
      objectiveLoanFk: Value(transaction.objectiveLoanFk),

      updatedAt: Value(DateTime.now()),
      // ✅ PHASE 4: No more redundant sync fields - event sourcing handles sync state
    );

    await _database.update(_database.transactionsTable).replace(companion);
    final updatedTransaction = transaction.copyWith(updatedAt: DateTime.now());

    // Invalidate cache after updating transaction
    await invalidateCache('transaction', id: transaction.id);

    // Trigger budget updates if service is available
    if (_budgetUpdateService != null) {
      await _budgetUpdateService!.updateBudgetOnTransactionChange(
          updatedTransaction, TransactionChangeType.updated);
    }

    return updatedTransaction;
  }

  @override
  Future<void> deleteTransaction(int id) async {
    // Get transaction before deletion for budget update
    final transaction = await getTransactionById(id);

    await (_database.delete(_database.transactionsTable)
          ..where((t) => t.id.equals(id)))
        .go();

    // Invalidate cache after deleting transaction
    await invalidateCache('transaction', id: id);

    // Trigger budget updates if service is available and transaction existed
    if (_budgetUpdateService != null && transaction != null) {
      await _budgetUpdateService!.updateBudgetOnTransactionChange(
          transaction, TransactionChangeType.deleted);
    }
  }

  @override
  Future<List<Transaction>> getUnsyncedTransactions() async {
    // ✅ PHASE 4: Use event sourcing to get unsynced transactions
    final unsyncedEvents = await _database.customSelect('''
      SELECT DISTINCT record_id as sync_id
      FROM sync_event_log 
      WHERE table_name_field = 'transactions' AND is_synced = false
    ''').get();

    final unsyncedSyncIds =
        unsyncedEvents.map((row) => row.data['sync_id'] as String).toList();

    if (unsyncedSyncIds.isEmpty) return [];

    final query = _database.select(_database.transactionsTable)
      ..where((t) => t.syncId.isIn(unsyncedSyncIds));
    final results = await query.get();
    return results.map(_mapTransactionData).toList();
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    // ✅ PHASE 4: Mark sync events as synced instead of table records
    await _database.customStatement('''
      UPDATE sync_event_log 
      SET is_synced = true 
      WHERE table_name_field = 'transactions' AND record_id = ?
    ''', [syncId]);
  }

  @override
  Future<void> insertOrUpdateFromSync(Transaction transaction) async {
    final existing = await getTransactionBySyncId(transaction.syncId);

    if (existing == null) {
      // Insert new transaction from sync
      final companion = TransactionsTableCompanion.insert(
        title: transaction.title,
        note: Value(transaction.note),
        amount: transaction.amount,
        categoryId: transaction.categoryId,
        accountId: transaction.accountId,
        date: transaction.date,

        // Advanced fields
        transactionType: Value(transaction.transactionType.name),
        specialType: Value(transaction.specialType?.name),
        recurrence: Value(transaction.recurrence.name),
        periodLength: Value(transaction.periodLength),
        endDate: Value(transaction.endDate),
        originalDateDue: Value(transaction.originalDateDue),
        transactionState: Value(transaction.transactionState.name),
        paid: Value(transaction.paid),
        skipPaid: Value(transaction.skipPaid),
        createdAnotherFutureTransaction:
            Value(transaction.createdAnotherFutureTransaction),
        objectiveLoanFk: Value(transaction.objectiveLoanFk),

        createdAt: Value(transaction.createdAt),
        updatedAt: Value(transaction.updatedAt),
        // ✅ PHASE 4: Only sync_id field for sync operations
        syncId: transaction.syncId,
      );
      await _database.into(_database.transactionsTable).insert(companion);

      // Trigger budget updates for new sync transaction
      if (_budgetUpdateService != null) {
        await _budgetUpdateService!.updateBudgetOnTransactionChange(
            transaction, TransactionChangeType.created);
      }
    } else {
      // ✅ PHASE 4: Always update with newer data from sync (no version comparison needed)
      final companion = TransactionsTableCompanion(
        id: Value(existing.id!),
        title: Value(transaction.title),
        note: Value(transaction.note),
        amount: Value(transaction.amount),
        categoryId: Value(transaction.categoryId),
        accountId: Value(transaction.accountId),
        date: Value(transaction.date),

        // Advanced fields
        transactionType: Value(transaction.transactionType.name),
        specialType: Value(transaction.specialType?.name),
        recurrence: Value(transaction.recurrence.name),
        periodLength: Value(transaction.periodLength),
        endDate: Value(transaction.endDate),
        originalDateDue: Value(transaction.originalDateDue),
        transactionState: Value(transaction.transactionState.name),
        paid: Value(transaction.paid),
        skipPaid: Value(transaction.skipPaid),
        createdAnotherFutureTransaction:
            Value(transaction.createdAnotherFutureTransaction),
        objectiveLoanFk: Value(transaction.objectiveLoanFk),

        updatedAt: Value(transaction.updatedAt),
        // ✅ PHASE 4: No redundant sync fields to update
      );
      await _database.update(_database.transactionsTable).replace(companion);

      // Trigger budget updates for updated sync transaction
      if (_budgetUpdateService != null) {
        await _budgetUpdateService!.updateBudgetOnTransactionChange(
            transaction, TransactionChangeType.updated);
      }
    }
  }

  @override
  Future<double> getTotalByCategory(
      int categoryId, DateTime? from, DateTime? to) async {
    var query = _database.selectOnly(_database.transactionsTable)
      ..addColumns([_database.transactionsTable.amount.sum()])
      ..where(_database.transactionsTable.categoryId.equals(categoryId));

    if (from != null) {
      query = query
        ..where(_database.transactionsTable.date.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query = query
        ..where(_database.transactionsTable.date.isSmallerOrEqualValue(to));
    }

    final result = await query.getSingle();
    return result.read(_database.transactionsTable.amount.sum()) ?? 0.0;
  }

  @override
  Future<double> getTotalByAccount(
      int accountId, DateTime? from, DateTime? to) async {
    var query = _database.selectOnly(_database.transactionsTable)
      ..addColumns([_database.transactionsTable.amount.sum()])
      ..where(_database.transactionsTable.accountId.equals(accountId));

    if (from != null) {
      query = query
        ..where(_database.transactionsTable.date.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query = query
        ..where(_database.transactionsTable.date.isSmallerOrEqualValue(to));
    }

    final result = await query.getSingle();
    return result.read(_database.transactionsTable.amount.sum()) ?? 0.0;
  }

  @override
  Future<Map<int, double>> getSpendingByCategory(
      DateTime? from, DateTime? to) async {
    var query = _database.selectOnly(_database.transactionsTable)
      ..addColumns([
        _database.transactionsTable.categoryId,
        _database.transactionsTable.amount.sum()
      ])
      ..groupBy([_database.transactionsTable.categoryId]);

    if (from != null) {
      query = query
        ..where(_database.transactionsTable.date.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query = query
        ..where(_database.transactionsTable.date.isSmallerOrEqualValue(to));
    }

    final results = await query.get();
    return Map.fromEntries(
      results.map((row) => MapEntry(
            row.read(_database.transactionsTable.categoryId)!,
            row.read(_database.transactionsTable.amount.sum()) ?? 0.0,
          )),
    );
  }

  // ✅ PHASE 4: Method to set budget service after construction
  void setBudgetUpdateService(BudgetUpdateService service) {
    _budgetUpdateService = service;
  }

  // ✅ PHASE 4: Clean mapping without redundant sync fields
  Transaction _mapTransactionData(TransactionsTableData data) {
    return Transaction(
      id: data.id,
      title: data.title,
      note: data.note,
      amount: data.amount,
      categoryId: data.categoryId,
      accountId: data.accountId,
      date: data.date,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,

      // Advanced fields
      transactionType: TransactionType.values.firstWhere(
        (e) => e.name == data.transactionType,
        orElse: () => TransactionType.expense,
      ),
      specialType: data.specialType != null
          ? TransactionSpecialType.values.firstWhere(
              (e) => e.name == data.specialType!,
              orElse: () => TransactionSpecialType.credit,
            )
          : null,
      recurrence: TransactionRecurrence.values.firstWhere(
        (e) => e.name == data.recurrence,
        orElse: () => TransactionRecurrence.none,
      ),
      periodLength: data.periodLength,
      endDate: data.endDate,
      originalDateDue: data.originalDateDue,
      transactionState: TransactionState.values.firstWhere(
        (e) => e.name == data.transactionState,
        orElse: () => TransactionState.completed,
      ),
      paid: data.paid,
      skipPaid: data.skipPaid,
      createdAnotherFutureTransaction: data.createdAnotherFutureTransaction,
      objectiveLoanFk: data.objectiveLoanFk,

      // ✅ PHASE 4: Only essential sync field
      syncId: data.syncId,
    );
  }
}
