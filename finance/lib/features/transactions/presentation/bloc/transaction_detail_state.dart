import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/attachment.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../accounts/domain/entities/account.dart';

abstract class TransactionDetailState extends Equatable {
  const TransactionDetailState();

  @override
  List<Object?> get props => [];
}

class TransactionDetailInitial extends TransactionDetailState {}

class TransactionDetailLoading extends TransactionDetailState {}

class TransactionDetailLoaded extends TransactionDetailState {
  final Transaction transaction;
  final List<Attachment> attachments;
  final Category? category;
  final Account? account;

  const TransactionDetailLoaded({
    required this.transaction,
    required this.attachments,
    this.category,
    this.account,
  });

  TransactionDetailLoaded copyWith({
    Transaction? transaction,
    List<Attachment>? attachments,
    Category? category,
    Account? account,
  }) {
    return TransactionDetailLoaded(
      transaction: transaction ?? this.transaction,
      attachments: attachments ?? this.attachments,
      category: category ?? this.category,
      account: account ?? this.account,
    );
  }

  @override
  List<Object?> get props => [transaction, attachments, category, account];
}

class TransactionDetailActionSuccess extends TransactionDetailState {
  final String message;

  const TransactionDetailActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionDetailError extends TransactionDetailState {
  final String message;

  const TransactionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}