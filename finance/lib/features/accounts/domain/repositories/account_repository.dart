import '../entities/account.dart';

abstract class AccountRepository {
  Future<List<Account>> getAllAccounts();
  Future<Account?> getAccountById(int id);
  Future<Account?> getAccountBySyncId(String syncId);
  Future<Account?> getDefaultAccount();

  Future<Account> createAccount(Account account);
  Future<Account> updateAccount(Account account);
  Future<void> deleteAccount(int id);

  Future<void> updateBalance(int accountId, double amount);

  // Sync related
  Future<List<Account>> getUnsyncedAccounts();
  Future<void> markAsSynced(String syncId, DateTime syncTime);
  Future<void> insertOrUpdateFromSync(Account account);
}
