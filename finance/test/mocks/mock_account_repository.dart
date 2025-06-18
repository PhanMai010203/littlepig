import 'package:finance/features/accounts/domain/entities/account.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';

class MockAccountRepository implements AccountRepository {
  @override
  Future<List<Account>> getAllAccounts() async {
    return [
      Account(
        id: 1,
        name: 'Test Account',
        balance: 1000.0,
        currency: 'USD',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'test-sync-id',
      ),
    ];
  }

  @override
  Future<Account?> getAccountById(int id) async {
    if (id == 1) {
      return Account(
        id: 1,
        name: 'Test Account',
        balance: 1000.0,
        currency: 'USD',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'test-sync-id',
      );
    }
    return null;
  }

  @override
  Future<Account?> getAccountBySyncId(String syncId) async {
    return null;
  }

  @override
  Future<Account?> getDefaultAccount() async {
    return await getAccountById(1);
  }

  @override
  Future<Account> createAccount(Account account) async {
    return account.copyWith(id: 1);
  }

  @override
  Future<Account> updateAccount(Account account) async {
    return account;
  }

  @override
  Future<void> deleteAccount(int id) async {
    // Mock delete
  }

  @override
  Future<void> updateBalance(int accountId, double amount) async {
    // Mock balance update
  }

  @override
  Future<List<Account>> getUnsyncedAccounts() async {
    return [];
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    // Mock sync
  }

  @override
  Future<void> insertOrUpdateFromSync(Account account) async {
    // Mock sync insert/update
  }
}
