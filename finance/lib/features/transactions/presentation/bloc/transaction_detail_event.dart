import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionDetailEvent extends Equatable {
  const TransactionDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionDetail extends TransactionDetailEvent {
  final int transactionId;

  const LoadTransactionDetail(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class LoadTransactionAttachments extends TransactionDetailEvent {
  final int transactionId;

  const LoadTransactionAttachments(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class UpdateTransactionDetail extends TransactionDetailEvent {
  final Transaction transaction;

  const UpdateTransactionDetail(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionDetail extends TransactionDetailEvent {
  final int transactionId;

  const DeleteTransactionDetail(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class RefreshTransactionDetail extends TransactionDetailEvent {
  final int transactionId;

  const RefreshTransactionDetail(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}