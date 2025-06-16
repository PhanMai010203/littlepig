import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _database;
  final String _deviceId;

  TransactionRepositoryImpl(this._database, this._deviceId);

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final query = _database.select(_database.transactionsTable);
    final results = await query.get();
    return results.map(_mapTransactionData).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByAccount(int accountId) async {
    final query = _database.select(_database.transactionsTable)
      ..where((t) => t.accountId.equals(accountId));
    final results = await query.get();
    return results.map(_mapTransactionData).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    final query = _database.select(_database.transactionsTable)
      ..where((t) => t.categoryId.equals(categoryId));
    final results = await query.get();
    return results.map(_mapTransactionData).toList();
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
    final query = _database.select(_database.transactionsTable)
      ..where((t) => t.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? _mapTransactionData(result) : null;
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
      description: Value(transaction.description),
      note: Value(transaction.note),
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      accountId: transaction.accountId,
      date: transaction.date,
      deviceId: _deviceId,
      syncId: const Uuid().v4(),
    );
    
    final id = await _database.into(_database.transactionsTable).insert(companion);
    return transaction.copyWith(id: id, deviceId: _deviceId);
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final companion = TransactionsTableCompanion(
      id: Value(transaction.id!),
      title: Value(transaction.title),
      description: Value(transaction.description),
      note: Value(transaction.note),
      amount: Value(transaction.amount),
      categoryId: Value(transaction.categoryId),
      accountId: Value(transaction.accountId),
      date: Value(transaction.date),
      updatedAt: Value(DateTime.now()),
      isSynced: const Value(false),
      version: Value(transaction.version + 1),
    );
    
    await _database.update(_database.transactionsTable).replace(companion);
    return transaction.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
      version: transaction.version + 1,
    );
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await (_database.delete(_database.transactionsTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<List<Transaction>> getUnsyncedTransactions() async {
    final query = _database.select(_database.transactionsTable)
      ..where((t) => t.isSynced.equals(false));
    final results = await query.get();
    return results.map(_mapTransactionData).toList();
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    await (_database.update(_database.transactionsTable)
          ..where((t) => t.syncId.equals(syncId)))
        .write(TransactionsTableCompanion(
          isSynced: const Value(true),
          lastSyncAt: Value(syncTime),
        ));
  }

  @override
  Future<void> insertOrUpdateFromSync(Transaction transaction) async {
    final existing = await getTransactionBySyncId(transaction.syncId);
      if (existing == null) {
      // Insert new transaction from sync
      final companion = TransactionsTableCompanion.insert(
        title: transaction.title,
        description: Value(transaction.description),
        note: Value(transaction.note),
        amount: transaction.amount,
        categoryId: transaction.categoryId,
        accountId: transaction.accountId,
        date: transaction.date,
        createdAt: Value(transaction.createdAt),
        updatedAt: Value(transaction.updatedAt),
        deviceId: transaction.deviceId,
        isSynced: const Value(true),
        lastSyncAt: Value(transaction.lastSyncAt),
        syncId: transaction.syncId,
        version: Value(transaction.version),
      );
      await _database.into(_database.transactionsTable).insert(companion);
    } else if (transaction.version > existing.version) {
      // Update with newer version
      final companion = TransactionsTableCompanion(
        id: Value(existing.id!),
        title: Value(transaction.title),
        description: Value(transaction.description),
        note: Value(transaction.note),
        amount: Value(transaction.amount),
        categoryId: Value(transaction.categoryId),
        accountId: Value(transaction.accountId),
        date: Value(transaction.date),
        updatedAt: Value(transaction.updatedAt),
        isSynced: const Value(true),
        lastSyncAt: Value(transaction.lastSyncAt),
        version: Value(transaction.version),
      );
      await _database.update(_database.transactionsTable).replace(companion);
    }
  }

  @override
  Future<double> getTotalByCategory(int categoryId, DateTime? from, DateTime? to) async {
    var query = _database.selectOnly(_database.transactionsTable)
      ..addColumns([_database.transactionsTable.amount.sum()])
      ..where(_database.transactionsTable.categoryId.equals(categoryId));
    
    if (from != null) {
      query = query..where(_database.transactionsTable.date.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query = query..where(_database.transactionsTable.date.isSmallerOrEqualValue(to));
    }
    
    final result = await query.getSingle();
    return result.read(_database.transactionsTable.amount.sum()) ?? 0.0;
  }

  @override
  Future<double> getTotalByAccount(int accountId, DateTime? from, DateTime? to) async {
    var query = _database.selectOnly(_database.transactionsTable)
      ..addColumns([_database.transactionsTable.amount.sum()])
      ..where(_database.transactionsTable.accountId.equals(accountId));
    
    if (from != null) {
      query = query..where(_database.transactionsTable.date.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query = query..where(_database.transactionsTable.date.isSmallerOrEqualValue(to));
    }
    
    final result = await query.getSingle();
    return result.read(_database.transactionsTable.amount.sum()) ?? 0.0;
  }

  @override
  Future<Map<int, double>> getSpendingByCategory(DateTime? from, DateTime? to) async {
    var query = _database.selectOnly(_database.transactionsTable)
      ..addColumns([
        _database.transactionsTable.categoryId,
        _database.transactionsTable.amount.sum()
      ])
      ..groupBy([_database.transactionsTable.categoryId]);
    
    if (from != null) {
      query = query..where(_database.transactionsTable.date.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query = query..where(_database.transactionsTable.date.isSmallerOrEqualValue(to));
    }
    
    final results = await query.get();
    return Map.fromEntries(
      results.map((row) => MapEntry(
        row.read(_database.transactionsTable.categoryId)!,
        row.read(_database.transactionsTable.amount.sum()) ?? 0.0,
      )),
    );
  }

  Transaction _mapTransactionData(TransactionsTableData data) {
    return Transaction(
      id: data.id,
      title: data.title,
      description: data.description,
      note: data.note,
      amount: data.amount,
      categoryId: data.categoryId,
      accountId: data.accountId,
      date: data.date,
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
