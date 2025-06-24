import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/repositories/cacheable_repository_mixin.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../budgets/domain/services/budget_update_service.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl
    with CacheableRepositoryMixin
    implements TransactionRepository {
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
  Future<List<Transaction>> getTransactions({
    required int page,
    required int limit,
  }) async {
    final offset = page * limit;

    return cacheRead(
      'getTransactions',
      () async {
        final query = _database.select(_database.transactionsTable)
          ..orderBy([
            (t) => OrderingTerm.desc(t.date)
          ]) // Order by date descending (newest first)
          ..limit(limit, offset: offset);
        final results = await query.get();
        return results.map(_mapTransactionData).toList();
      },
      params: {'page': page, 'limit': limit},
      ttl: const Duration(minutes: 3), // Cache for 3 minutes
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

      // Phase 3: Partial loan fields
      remainingAmount: Value(transaction.remainingAmount),
      parentTransactionId: Value(transaction.parentTransactionId),

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

      // Phase 3: Partial loan fields
      remainingAmount: Value(transaction.remainingAmount),
      parentTransactionId: Value(transaction.parentTransactionId),

      // Keep syncId for updates
      syncId: Value(transaction.syncId),

      // ✅ PHASE 4: No more redundant sync fields - event sourcing handles sync state
    );

    await _database.update(_database.transactionsTable).replace(companion);
    final updatedTransaction = transaction.copyWith(updatedAt: DateTime.now());

    // Invalidate cache after updating transaction
    await invalidateEntityCache('transaction');

    // Trigger budget updates if service is available
    if (_budgetUpdateService != null) {
      await _budgetUpdateService!.updateBudgetOnTransactionChange(
          updatedTransaction, TransactionChangeType.updated);
    }

    return updatedTransaction;
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await (_database.delete(_database.transactionsTable)
          ..where((t) => t.id.equals(id)))
        .go();
    await invalidateEntityCache('transaction');
  }

  @override
  Future<void> deleteAllTransactions() async {
    await _database.delete(_database.transactionsTable).go();
    await invalidateEntityCache('transaction');
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

        // Phase 3: Partial loan fields
        remainingAmount: Value(transaction.remainingAmount),
        parentTransactionId: Value(transaction.parentTransactionId),

        // ✅ PHASE 4: Only sync_id field for sync operations
        syncId: transaction.syncId,
      );
      await _database.into(_database.transactionsTable).insert(companion);

      await invalidateEntityCache('transaction');

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

        // Phase 3: Partial loan fields
        remainingAmount: Value(transaction.remainingAmount),
        parentTransactionId: Value(transaction.parentTransactionId),

        // ✅ PHASE 4: No redundant sync fields to update
      );
      await _database.update(_database.transactionsTable).replace(companion);

      await invalidateEntityCache('transaction');

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

      // Phase 3: Partial loan fields
      remainingAmount: data.remainingAmount,
      parentTransactionId: data.parentTransactionId,

      // ✅ PHASE 4: Only essential sync field
      syncId: data.syncId,
    );
  }

  // ---------------- Phase 3: Partial Loan Handling ----------------

  @override
  Future<void> collectPartialCredit({
    required Transaction credit,
    required double amount,
  }) async {
    assert(credit.isCredit, 'Transaction must be a credit (money lent)');
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Must be > 0');
    }

    final remaining = credit.remainingAmount ?? credit.amount.abs();
    if (amount > remaining) {
      throw OverCollectionException(
          'Collect amount ($amount) exceeds remaining amount ($remaining)');
    }

    await _database.transaction(() async {
      // 1. Insert child payment transaction (positive amount)
      final childTxn = Transaction(
        title: 'Loan collection',
        note: 'Partial collection',
        amount: amount, // positive (money received)
        categoryId: credit.categoryId,
        accountId: credit.accountId,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transactionType: TransactionType.income,
        specialType: credit.specialType,
        transactionState: TransactionState.completed,
        parentTransactionId: credit.id,
        remainingAmount: null,
        syncId: const Uuid().v4(),
      );

      await createTransaction(childTxn);

      // 2. Update parent remainingAmount and state
      final newRemaining = remaining - amount;
      final updatedParent = credit.copyWith(
        remainingAmount: newRemaining,
        transactionState: newRemaining == 0
            ? TransactionState.completed
            : TransactionState.actionRequired,
      );

      await updateTransaction(updatedParent);
    });
  }

  @override
  Future<void> settlePartialDebt({
    required Transaction debt,
    required double amount,
  }) async {
    assert(debt.isDebt, 'Transaction must be a debt (money borrowed)');
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Must be > 0');
    }

    final remaining = debt.remainingAmount ?? debt.amount.abs();
    if (amount > remaining) {
      throw OverCollectionException(
          'Settle amount ($amount) exceeds remaining amount ($remaining)');
    }

    await _database.transaction(() async {
      // 1. Insert child settlement transaction (negative amount)
      final childTxn = Transaction(
        title: 'Loan settlement',
        note: 'Partial settlement',
        amount: -amount, // negative (money paid)
        categoryId: debt.categoryId,
        accountId: debt.accountId,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transactionType: TransactionType.expense,
        specialType: debt.specialType,
        transactionState: TransactionState.completed,
        parentTransactionId: debt.id,
        remainingAmount: null,
        syncId: const Uuid().v4(),
      );

      await createTransaction(childTxn);

      // 2. Update parent remainingAmount and state
      final newRemaining = remaining - amount;
      final updatedParent = debt.copyWith(
        remainingAmount: newRemaining,
        transactionState: newRemaining == 0
            ? TransactionState.completed
            : TransactionState.actionRequired,
      );

      await updateTransaction(updatedParent);
    });
  }

  @override
  Future<List<Transaction>> getLoanPayments(int parentTransactionId) async {
    final query = _database.select(_database.transactionsTable)
      ..where((t) => t.parentTransactionId.equals(parentTransactionId));
    final results = await query.get();
    return results.map(_mapTransactionData).toList();
  }

  /// Helper method to get remaining amount for a loan transaction
  /// Returns the remaining amount to be collected/settled, or 0 if fully completed
  double getRemainingAmount(Transaction loan) {
    if (!loan.isLoan) {
      return 0.0; // Not a loan transaction
    }

    return loan.remainingAmount ?? loan.amount.abs();
  }
}

// Phase 3 – Custom exception for over collection/settlement
class OverCollectionException implements Exception {
  final String message;
  OverCollectionException(this.message);

  @override
  String toString() => 'OverCollectionException: $message';
}
