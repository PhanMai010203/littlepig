import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class CreateTransaction {
  final TransactionRepository _repository;

  CreateTransaction(this._repository);

  Future<Transaction> call(Transaction transaction) async {
    // Add validation logic here if needed
    _validateTransaction(transaction);
    return await _repository.createTransaction(transaction);
  }

  void _validateTransaction(Transaction transaction) {
    if (transaction.title.trim().isEmpty) {
      throw ArgumentError('Transaction title cannot be empty');
    }
    if (transaction.amount == 0) {
      throw ArgumentError('Transaction amount cannot be zero');
    }
    if (transaction.categoryId <= 0) {
      throw ArgumentError('Invalid category ID');
    }
    if (transaction.accountId <= 0) {
      throw ArgumentError('Invalid account ID');
    }
  }
}

class UpdateTransaction {
  final TransactionRepository _repository;

  UpdateTransaction(this._repository);

  Future<Transaction> call(Transaction transaction) async {
    if (transaction.id == null) {
      throw ArgumentError('Transaction ID is required for update');
    }
    _validateTransaction(transaction);
    return await _repository.updateTransaction(transaction);
  }

  void _validateTransaction(Transaction transaction) {
    if (transaction.title.trim().isEmpty) {
      throw ArgumentError('Transaction title cannot be empty');
    }
    if (transaction.amount == 0) {
      throw ArgumentError('Transaction amount cannot be zero');
    }
    if (transaction.categoryId <= 0) {
      throw ArgumentError('Invalid category ID');
    }
    if (transaction.accountId <= 0) {
      throw ArgumentError('Invalid account ID');
    }
  }
}

class DeleteTransaction {
  final TransactionRepository _repository;

  DeleteTransaction(this._repository);

  Future<void> call(int id) async {
    if (id <= 0) {
      throw ArgumentError('Invalid transaction ID');
    }
    await _repository.deleteTransaction(id);
  }
}
