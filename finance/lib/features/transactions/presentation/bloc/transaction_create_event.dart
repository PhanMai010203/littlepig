import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_enums.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../budgets/domain/entities/budget.dart';

abstract class TransactionCreateEvent extends Equatable {
  const TransactionCreateEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial data needed for transaction creation
class LoadInitialData extends TransactionCreateEvent {}

/// Update transaction title
class UpdateTitle extends TransactionCreateEvent {
  final String title;

  const UpdateTitle(this.title);

  @override
  List<Object?> get props => [title];
}

/// Update transaction amount
class UpdateAmount extends TransactionCreateEvent {
  final double amount;

  const UpdateAmount(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Update transaction note
class UpdateNote extends TransactionCreateEvent {
  final String note;

  const UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

/// Update transaction date
class UpdateDate extends TransactionCreateEvent {
  final DateTime date;

  const UpdateDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Update transaction type (income/expense)
class UpdateTransactionType extends TransactionCreateEvent {
  final TransactionType transactionType;

  const UpdateTransactionType(this.transactionType);

  @override
  List<Object?> get props => [transactionType];
}

/// Update selected category
class UpdateCategory extends TransactionCreateEvent {
  final Category category;

  const UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Update selected account
class UpdateAccount extends TransactionCreateEvent {
  final Account account;

  const UpdateAccount(this.account);

  @override
  List<Object?> get props => [account];
}

/// Update transaction special type (credit/debt)
class UpdateSpecialType extends TransactionCreateEvent {
  final TransactionSpecialType? specialType;

  const UpdateSpecialType(this.specialType);

  @override
  List<Object?> get props => [specialType];
}

/// Update recurrence settings
class UpdateRecurrence extends TransactionCreateEvent {
  final TransactionRecurrence recurrence;
  final int? periodLength;
  final DateTime? endDate;

  const UpdateRecurrence(this.recurrence, {this.periodLength, this.endDate});

  @override
  List<Object?> get props => [recurrence, periodLength, endDate];
}

/// Update transaction state
class UpdateTransactionState extends TransactionCreateEvent {
  final TransactionState transactionState;

  const UpdateTransactionState(this.transactionState);

  @override
  List<Object?> get props => [transactionState];
}

/// Add attachment to transaction
class AddAttachment extends TransactionCreateEvent {
  final String filePath;
  final String fileName;
  final bool isCapturedFromCamera;

  const AddAttachment(this.filePath, this.fileName, {this.isCapturedFromCamera = false});

  @override
  List<Object?> get props => [filePath, fileName, isCapturedFromCamera];
}

/// Remove attachment from transaction
class RemoveAttachment extends TransactionCreateEvent {
  final String filePath;

  const RemoveAttachment(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Link transaction to budget
class LinkToBudget extends TransactionCreateEvent {
  final Budget budget;
  final double? customAmount;

  const LinkToBudget(this.budget, {this.customAmount});

  @override
  List<Object?> get props => [budget, customAmount];
}

/// Remove budget link
class RemoveBudgetLink extends TransactionCreateEvent {
  final Budget budget;

  const RemoveBudgetLink(this.budget);

  @override
  List<Object?> get props => [budget];
}

/// Validate form and check what's missing
class ValidateForm extends TransactionCreateEvent {}

/// Create the transaction
class CreateTransaction extends TransactionCreateEvent {}

/// Reset form to initial state
class ResetForm extends TransactionCreateEvent {}