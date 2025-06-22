import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../../../../core/repositories/cacheable_repository_mixin.dart';

class AccountRepositoryImpl
    with CacheableRepositoryMixin
    implements AccountRepository {
  final AppDatabase _database;
  final _uuid = const Uuid();

  AccountRepositoryImpl(this._database);

  @override
  Future<List<Account>> getAllAccounts() async {
    return cacheRead(
      'getAllAccounts',
      () async {
        final accounts = await _database.select(_database.accountsTable).get();
        return accounts.map(_mapToEntity).toList();
      },
      ttl: const Duration(minutes: 5),
    );
  }

  @override
  Future<Account?> getAccountById(int id) async {
    return cacheReadSingle(
      'getAccountById',
      () async {
        final account = await (_database.select(_database.accountsTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
        return account != null ? _mapToEntity(account) : null;
      },
      params: {'id': id},
    );
  }

  @override
  Future<Account?> getAccountBySyncId(String syncId) async {
    final account = await (_database.select(_database.accountsTable)
          ..where((tbl) => tbl.syncId.equals(syncId)))
        .getSingleOrNull();
    return account != null ? _mapToEntity(account) : null;
  }

  @override
  Future<Account?> getDefaultAccount() async {
    final account = await (_database.select(_database.accountsTable)
          ..where((tbl) => tbl.isDefault.equals(true)))
        .getSingleOrNull();
    return account != null ? _mapToEntity(account) : null;
  }

  @override
  Future<Account> createAccount(Account account) async {
    final now = DateTime.now();
    final syncId = account.syncId.isEmpty ? _uuid.v4() : account.syncId;
    final companion = AccountsTableCompanion.insert(
      name: account.name,
      balance: Value(account.balance),
      currency: Value(account.currency),
      isDefault: Value(account.isDefault),
      color: Value(account.color.value),
      syncId: syncId,
      createdAt: Value(account.createdAt),
      updatedAt: Value(now),
    );

    final id = await _database.into(_database.accountsTable).insert(companion);

    // Invalidate cache
    await invalidateEntityCache('account');

    return account.copyWith(
      id: id,
      syncId: syncId,
      updatedAt: now,
    );
  }

  @override
  Future<Account> updateAccount(Account account) async {
    final now = DateTime.now();
    final companion = AccountsTableCompanion(
      id: Value(account.id!),
      name: Value(account.name),
      balance: Value(account.balance),
      currency: Value(account.currency),
      isDefault: Value(account.isDefault),
      color: Value(account.color.value),
      updatedAt: Value(now),
    );

    await (_database.update(_database.accountsTable)
          ..where((tbl) => tbl.id.equals(account.id!)))
        .write(companion);

    // Invalidate cache
    await invalidateEntityCache('account');

    return account.copyWith(updatedAt: now);
  }

  @override
  Future<void> deleteAccount(int id) async {
    await (_database.delete(_database.accountsTable)
          ..where((a) => a.id.equals(id)))
        .go();
    await invalidateEntityCache('account');
  }

  @override
  Future<void> deleteAllAccounts() async {
    await _database.delete(_database.accountsTable).go();
    await invalidateEntityCache('account');
  }

  @override
  Future<void> updateBalance(int accountId, double amount) async {
    final now = DateTime.now();
    await (_database.update(_database.accountsTable)
          ..where((tbl) => tbl.id.equals(accountId)))
        .write(AccountsTableCompanion(
      balance: Value(amount),
      updatedAt: Value(now),
    ));

    // Invalidate cache
    await invalidateEntityCache('account');
  }

  @override
  Future<List<Account>> getUnsyncedAccounts() async {
    final accounts = await _database.select(_database.accountsTable).get();
    return accounts.map(_mapToEntity).toList();
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    // ✅ PHASE 4: No-op since sync fields removed from table
    // Event sourcing tracks sync status in sync_event_log table
    // This method kept for backward compatibility
  }

  @override
  Future<void> insertOrUpdateFromSync(Account account) async {
    final existing = await getAccountBySyncId(account.syncId);
    if (existing == null) {
      // Insert new account from sync
      final companion = AccountsTableCompanion.insert(
        name: account.name,
        balance: Value(account.balance),
        currency: Value(account.currency),
        isDefault: Value(account.isDefault),
        color: Value(account.color.value),
        createdAt: Value(account.createdAt),
        updatedAt: Value(account.updatedAt),
        syncId: account.syncId,
      );
      await _database.into(_database.accountsTable).insert(companion);
    } else {
      // ✅ PHASE 4: Always update with newer data from sync (no version comparison needed)
      final companion = AccountsTableCompanion(
        id: Value(existing.id!),
        name: Value(account.name),
        balance: Value(account.balance),
        currency: Value(account.currency),
        isDefault: Value(account.isDefault),
        color: Value(account.color.value),
        updatedAt: Value(account.updatedAt),
      );

      await (_database.update(_database.accountsTable)
            ..where((tbl) => tbl.id.equals(existing.id!)))
          .write(companion);
    }

    // Invalidate cache
    await invalidateEntityCache('account');
  }

  Account _mapToEntity(AccountsTableData data) {
    return Account(
      id: data.id,
      name: data.name,
      balance: data.balance,
      currency: data.currency,
      isDefault: data.isDefault,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      syncId: data.syncId,
      color: Color(data.color),
    );
  }
}
