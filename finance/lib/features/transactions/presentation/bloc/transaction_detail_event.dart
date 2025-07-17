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

class UpdateTransactionNote extends TransactionDetailEvent {
  final int transactionId;
  final String note;

  const UpdateTransactionNote(this.transactionId, this.note);

  @override
  List<Object?> get props => [transactionId, note];
}

class AddAttachment extends TransactionDetailEvent {
  final int transactionId;

  const AddAttachment(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class DeleteAttachment extends TransactionDetailEvent {
  final int attachmentId;

  const DeleteAttachment(this.attachmentId);

  @override
  List<Object?> get props => [attachmentId];
}

class CheckGoogleDriveAuth extends TransactionDetailEvent {
  const CheckGoogleDriveAuth();
}

class AuthenticateGoogleDrive extends TransactionDetailEvent {
  const AuthenticateGoogleDrive();
}

class AddAttachmentFromCamera extends TransactionDetailEvent {
  final int transactionId;

  const AddAttachmentFromCamera(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class AddAttachmentFromGallery extends TransactionDetailEvent {
  final int transactionId;

  const AddAttachmentFromGallery(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class AddAttachmentFromFiles extends TransactionDetailEvent {
  final int transactionId;

  const AddAttachmentFromFiles(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}