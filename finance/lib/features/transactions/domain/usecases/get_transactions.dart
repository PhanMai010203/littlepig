import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetAllTransactions {
  final TransactionRepository _repository;

  GetAllTransactions(this._repository);

  Future<List<Transaction>> call() async {
    return await _repository.getAllTransactions();
  }
}

// 🆕 Phase 1.2: Paginated transactions use case for lazy loading
class GetTransactionsPaginated {
  final TransactionRepository _repository;

  GetTransactionsPaginated(this._repository);

  Future<List<Transaction>> call({
    required int page,
    required int limit,
  }) async {
    return await _repository.getTransactions(page: page, limit: limit);
  }
}

class GetTransactionsByAccount {
  final TransactionRepository _repository;

  GetTransactionsByAccount(this._repository);

  Future<List<Transaction>> call(int accountId) async {
    return await _repository.getTransactionsByAccount(accountId);
  }
}

class GetTransactionsByCategory {
  final TransactionRepository _repository;

  GetTransactionsByCategory(this._repository);

  Future<List<Transaction>> call(int categoryId) async {
    return await _repository.getTransactionsByCategory(categoryId);
  }
}

class GetTransactionsByDateRange {
  final TransactionRepository _repository;

  GetTransactionsByDateRange(this._repository);

  Future<List<Transaction>> call(DateTime startDate, DateTime endDate) async {
    return await _repository.getTransactionsByDateRange(startDate, endDate);
  }
}

class GetTransactionById {
  final TransactionRepository _repository;

  GetTransactionById(this._repository);

  Future<Transaction?> call(int id) async {
    return await _repository.getTransactionById(id);
  }
}
