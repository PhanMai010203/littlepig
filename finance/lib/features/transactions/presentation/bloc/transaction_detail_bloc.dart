import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import 'transaction_detail_event.dart';
import 'transaction_detail_state.dart';

class TransactionDetailBloc extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  final TransactionRepository _transactionRepository;
  final AttachmentRepository _attachmentRepository;
  final CategoryRepository _categoryRepository;
  final AccountRepository _accountRepository;

  TransactionDetailBloc({
    required TransactionRepository transactionRepository,
    required AttachmentRepository attachmentRepository,
    required CategoryRepository categoryRepository,
    required AccountRepository accountRepository,
  })  : _transactionRepository = transactionRepository,
        _attachmentRepository = attachmentRepository,
        _categoryRepository = categoryRepository,
        _accountRepository = accountRepository,
        super(TransactionDetailInitial()) {
    on<LoadTransactionDetail>(_onLoadTransactionDetail);
    on<LoadTransactionAttachments>(_onLoadTransactionAttachments);
    on<UpdateTransactionDetail>(_onUpdateTransactionDetail);
    on<DeleteTransactionDetail>(_onDeleteTransactionDetail);
    on<RefreshTransactionDetail>(_onRefreshTransactionDetail);
  }

  Future<void> _onLoadTransactionDetail(
    LoadTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    try {
      emit(TransactionDetailLoading());

      // Load transaction
      final transaction = await _transactionRepository.getTransactionById(event.transactionId);
      if (transaction == null) {
        emit(const TransactionDetailError('Transaction not found'));
        return;
      }

      // Load attachments
      final attachments = await _attachmentRepository.getAttachmentsByTransaction(event.transactionId);

      // Load category
      final category = await _categoryRepository.getCategoryById(transaction.categoryId);

      // Load account
      final account = await _accountRepository.getAccountById(transaction.accountId);

      emit(TransactionDetailLoaded(
        transaction: transaction,
        attachments: attachments,
        category: category,
        account: account,
      ));
    } catch (e) {
      emit(TransactionDetailError('Failed to load transaction: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTransactionAttachments(
    LoadTransactionAttachments event,
    Emitter<TransactionDetailState> emit,
  ) async {
    if (state is TransactionDetailLoaded) {
      try {
        final currentState = state as TransactionDetailLoaded;
        final attachments = await _attachmentRepository.getAttachmentsByTransaction(event.transactionId);
        
        emit(currentState.copyWith(attachments: attachments));
      } catch (e) {
        emit(TransactionDetailError('Failed to load attachments: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateTransactionDetail(
    UpdateTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    try {
      final updatedTransaction = await _transactionRepository.updateTransaction(event.transaction);
      
      emit(const TransactionDetailActionSuccess('Transaction updated successfully'));
      
      // Reload the transaction detail
      add(LoadTransactionDetail(updatedTransaction.id!));
    } catch (e) {
      emit(TransactionDetailError('Failed to update transaction: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTransactionDetail(
    DeleteTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    try {
      // Delete all attachments first
      final attachments = await _attachmentRepository.getAttachmentsByTransaction(event.transactionId);
      for (final attachment in attachments) {
        if (attachment.id != null) {
          await _attachmentRepository.deleteAttachment(attachment.id!);
        }
      }

      // Delete the transaction
      await _transactionRepository.deleteTransaction(event.transactionId);
      
      emit(const TransactionDetailActionSuccess('Transaction deleted successfully'));
    } catch (e) {
      emit(TransactionDetailError('Failed to delete transaction: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshTransactionDetail(
    RefreshTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    add(LoadTransactionDetail(event.transactionId));
  }
}