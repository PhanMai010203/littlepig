import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AppDatabase _database;
  final _uuid = const Uuid();

  AccountRepositoryImpl(this._database);

  @override
  Future<List<Account>> getAllAccounts() async {
    final accounts = await _database.select(_database.accountsTable).get();
    return accounts.map(_mapToEntity).toList();
  }

  @override
  Future<Account?> getAccountById(int id) async {
    final account = await (_database.select(_database.accountsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return account != null ? _mapToEntity(account) : null;
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
      deviceId: account.deviceId,
      syncId: syncId,
      createdAt: Value(account.createdAt),
      updatedAt: Value(now),
    );

    final id = await _database.into(_database.accountsTable).insert(companion);
    
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
      updatedAt: Value(now),
      isSynced: const Value(false), // Mark as unsynced when updated
      version: Value(account.version + 1),
    );

    await (_database.update(_database.accountsTable)
          ..where((tbl) => tbl.id.equals(account.id!)))
        .write(companion);
    
    return account.copyWith(
      updatedAt: now,
      isSynced: false,
      version: account.version + 1,
    );
  }

  @override
  Future<void> deleteAccount(int id) async {
    await (_database.delete(_database.accountsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  @override
  Future<void> updateBalance(int accountId, double amount) async {
    final now = DateTime.now();
    await (_database.update(_database.accountsTable)
          ..where((tbl) => tbl.id.equals(accountId)))
        .write(AccountsTableCompanion(
          balance: Value(amount),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ));
  }

  @override
  Future<List<Account>> getUnsyncedAccounts() async {
    final accounts = await (_database.select(_database.accountsTable)
          ..where((tbl) => tbl.isSynced.equals(false)))
        .get();
    return accounts.map(_mapToEntity).toList();
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    await (_database.update(_database.accountsTable)
          ..where((tbl) => tbl.syncId.equals(syncId)))
        .write(AccountsTableCompanion(
          isSynced: const Value(true),
          lastSyncAt: Value(syncTime),
        ));
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
        createdAt: Value(account.createdAt),
        updatedAt: Value(account.updatedAt),
        deviceId: account.deviceId,
        isSynced: const Value(true),
        lastSyncAt: Value(account.lastSyncAt),
        syncId: account.syncId,
        version: Value(account.version),
      );
      await _database.into(_database.accountsTable).insert(companion);
    } else if (account.version > existing.version) {
      // Update existing account if incoming version is newer
      final companion = AccountsTableCompanion(
        id: Value(existing.id!),
        name: Value(account.name),
        balance: Value(account.balance),
        currency: Value(account.currency),
        isDefault: Value(account.isDefault),
        updatedAt: Value(account.updatedAt),
        isSynced: const Value(true),
        lastSyncAt: Value(account.lastSyncAt),
        version: Value(account.version),
      );
      
      await (_database.update(_database.accountsTable)
            ..where((tbl) => tbl.id.equals(existing.id!)))
          .write(companion);
    }
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
      deviceId: data.deviceId,
      isSynced: data.isSynced,
      lastSyncAt: data.lastSyncAt,
      syncId: data.syncId,
      version: data.version,
    );
  }
}
