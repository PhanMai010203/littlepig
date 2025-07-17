import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../budgets/domain/entities/budget.dart';
import '../../../budgets/domain/repositories/budget_repository.dart';
import 'transaction_create_event.dart';
import 'transaction_create_state.dart';

@injectable
class TransactionCreateBloc extends Bloc<TransactionCreateEvent, TransactionCreateState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final AccountRepository _accountRepository;
  final BudgetRepository _budgetRepository;
  final AttachmentRepository _attachmentRepository;

  TransactionCreateBloc(
    this._transactionRepository,
    this._categoryRepository,
    this._accountRepository,
    this._budgetRepository,
    this._attachmentRepository,
  ) : super(TransactionCreateInitial()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<UpdateTitle>(_onUpdateTitle);
    on<UpdateAmount>(_onUpdateAmount);
    on<UpdateNote>(_onUpdateNote);
    on<UpdateDate>(_onUpdateDate);
    on<UpdateTransactionType>(_onUpdateTransactionType);
    on<UpdateCategory>(_onUpdateCategory);
    on<UpdateAccount>(_onUpdateAccount);
    on<UpdateSpecialType>(_onUpdateSpecialType);
    on<UpdateRecurrence>(_onUpdateRecurrence);
    on<UpdateTransactionState>(_onUpdateTransactionState);
    on<AddAttachment>(_onAddAttachment);
    on<RemoveAttachment>(_onRemoveAttachment);
    on<LinkToBudget>(_onLinkToBudget);
    on<RemoveBudgetLink>(_onRemoveBudgetLink);
    on<ValidateForm>(_onValidateForm);
    on<CreateTransaction>(_onCreateTransaction);
    on<ResetForm>(_onResetForm);
  }

  Future<void> _onLoadInitialData(
      LoadInitialData event, Emitter<TransactionCreateState> emit) async {
    emit(TransactionCreateLoading());
    
    try {
      // Load all required data in parallel
      final results = await Future.wait([
        _categoryRepository.getAllCategories(),
        _accountRepository.getAllAccounts(),
        _budgetRepository.getAllBudgets(),
      ]);

      final categories = results[0] as List<Category>;
      final accounts = results[1] as List<Account>;
      final budgets = results[2] as List<Budget>;

      // Filter categories by type
      final incomeCategories = categories.where((c) => !c.isExpense).toList();
      final expenseCategories = categories.where((c) => c.isExpense).toList();

      // Filter manual budgets only
      final manualBudgets = budgets.where((b) => b.manualAddMode).toList();

      // Pre-select the default account to skip account selection step
      final defaultAccount = accounts.firstWhere(
        (account) => account.isDefault,
        orElse: () => accounts.isNotEmpty ? accounts.first : throw Exception('No accounts available'),
      );

      emit(TransactionCreateLoaded(
        incomeCategories: incomeCategories,
        expenseCategories: expenseCategories,
        accounts: accounts,
        manualBudgets: manualBudgets,
        date: DateTime.now(),
        selectedAccount: defaultAccount, // Pre-select default account
      ));
      
      // Trigger validation after loading
      add(ValidateForm());
    } catch (e) {
      emit(TransactionCreateError('errors.failed_to_load_data'.tr(args: [e.toString()])));
    }
  }

  void _onUpdateTitle(UpdateTitle event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      emit(currentState.copyWith(title: event.title));
      add(ValidateForm());
    }
  }

  void _onUpdateAmount(UpdateAmount event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      emit(currentState.copyWith(amount: event.amount));
      add(ValidateForm());
    }
  }

  void _onUpdateNote(UpdateNote event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      emit(currentState.copyWith(note: event.note));
    }
  }

  void _onUpdateDate(UpdateDate event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      emit(currentState.copyWith(date: event.date));
    }
  }

  void _onUpdateTransactionType(
      UpdateTransactionType event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      
      // Clear category selection when type changes if current category doesn't match new type
      Category? newSelectedCategory = currentState.selectedCategory;
      if (newSelectedCategory != null) {
        final newCategories = event.transactionType == TransactionType.income 
            ? currentState.incomeCategories 
            : currentState.expenseCategories;
        
        if (!newCategories.contains(newSelectedCategory)) {
          newSelectedCategory = null;
        }
      }

      emit(currentState.copyWith(
        transactionType: event.transactionType,
        selectedCategory: newSelectedCategory,
      ));
      add(ValidateForm());
    }
  }

  void _onUpdateCategory(UpdateCategory event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      emit(currentState.copyWith(selectedCategory: event.category));
      add(ValidateForm());
    }
  }

  void _onUpdateAccount(UpdateAccount event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      emit(currentState.copyWith(selectedAccount: event.account));
      add(ValidateForm());
    }
  }

  void _onUpdateSpecialType(
      UpdateSpecialType event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      emit(currentState.copyWith(specialType: event.specialType));
    }
  }

  void _onUpdateRecurrence(
      UpdateRecurrence event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      emit(currentState.copyWith(
        recurrence: event.recurrence,
        periodLength: event.periodLength,
        endDate: event.endDate,
      ));
    }
  }

  void _onUpdateTransactionState(
      UpdateTransactionState event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      emit(currentState.copyWith(transactionState: event.transactionState));
    }
  }

  void _onAddAttachment(AddAttachment event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      final newAttachment = AttachmentData(
        filePath: event.filePath,
        fileName: event.fileName,
        isCapturedFromCamera: event.isCapturedFromCamera,
      );
      
      final updatedAttachments = List<AttachmentData>.from(currentState.attachments)
        ..add(newAttachment);
      
      emit(currentState.copyWith(attachments: updatedAttachments));
    }
  }

  void _onRemoveAttachment(
      RemoveAttachment event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      final updatedAttachments = currentState.attachments
          .where((a) => a.filePath != event.filePath)
          .toList();
      
      emit(currentState.copyWith(attachments: updatedAttachments));
    }
  }

  void _onLinkToBudget(LinkToBudget event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      final newLink = BudgetLink(
        budget: event.budget,
        customAmount: event.customAmount,
      );
      
      // Remove existing link to same budget if exists
      final updatedLinks = currentState.budgetLinks
          .where((link) => link.budget.id != event.budget.id)
          .toList()
        ..add(newLink);
      
      emit(currentState.copyWith(budgetLinks: updatedLinks));
    }
  }

  void _onRemoveBudgetLink(
      RemoveBudgetLink event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      final updatedLinks = currentState.budgetLinks
          .where((link) => link.budget.id != event.budget.id)
          .toList();
      
      emit(currentState.copyWith(budgetLinks: updatedLinks));
    }
  }

  void _onValidateForm(ValidateForm event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      final errors = <String, String>{};
      String? nextField;

      // Validate title
      if (currentState.title.trim().isEmpty) {
        errors['title'] = 'validation.title_required'.tr();
        nextField ??= 'title';
      }

      // Validate amount
      if (currentState.amount == null || currentState.amount == 0) {
        errors['amount'] = 'validation.amount_required'.tr();
        nextField ??= 'amount';
      }

      // Validate category
      if (currentState.selectedCategory == null) {
        errors['category'] = 'validation.category_required'.tr();
        nextField ??= 'category';
      }

      // Account validation is skipped since we pre-select the default account
      // Account selection is still available in the UI but not part of the progressive flow

      // Additional validation for recurring transactions
      if (currentState.recurrence != TransactionRecurrence.none) {
        if (currentState.periodLength == null || currentState.periodLength! < 1) {
          errors['periodLength'] = 'validation.period_length_for_recurrence_required'.tr();
          nextField ??= 'periodLength';
        }
      }

      final isValid = errors.isEmpty;

      emit(currentState.copyWith(
        validationErrors: errors,
        isValid: isValid,
        nextRequiredField: nextField, // This will be null if all required fields are filled
        clearNextRequiredField: nextField == null, // Clear if no next field is required
      ));
    }
  }

  Future<void> _onCreateTransaction(
      CreateTransaction event, Emitter<TransactionCreateState> emit) async {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;
      
      if (!currentState.isValid) {
        emit(TransactionCreateError('errors.fill_required_fields'.tr()));
        return;
      }

      emit(currentState.copyWith(isCreating: true));

      try {
        // Create transaction entity
        final transaction = _createTransactionFromState(currentState);
        debugPrint('💳 Creating transaction: ${transaction.title}');
        debugPrint('💰 Amount: ${transaction.amount}');
        debugPrint('📅 Date: ${transaction.date}');
        debugPrint('🏷️ Category ID: ${transaction.categoryId}');
        debugPrint('🏦 Account ID: ${transaction.accountId}');
        debugPrint('🔄 Transaction Type: ${transaction.transactionType}');
        
        // Create transaction in repository
        final createdTransaction = await _transactionRepository.createTransaction(transaction);
        debugPrint('✅ Transaction created with ID: ${createdTransaction.id}');
        
        // Handle attachments if any
        if (currentState.attachments.isNotEmpty) {
          await _processAttachments(createdTransaction.id!, currentState.attachments);
        }

        // Handle budget links if any
        if (currentState.budgetLinks.isNotEmpty) {
          await _processBudgetLinks(createdTransaction.id!, currentState.budgetLinks);
        }

        emit(TransactionCreateSuccess('transactions.transaction_added'.tr()));
      } catch (e) {
        debugPrint('Error creating transaction: $e');
        emit(TransactionCreateError('transactions.creation_failed_generic'.tr(args: [e.toString()])));
      }
    }
  }

  void _onResetForm(ResetForm event, Emitter<TransactionCreateState> emit) {
    if (state is TransactionCreateLoaded) {
      final currentState = state as TransactionCreateLoaded;

      // Pre-select the default account to skip account selection step
      final defaultAccount = currentState.accounts.firstWhere(
        (account) => account.isDefault,
        orElse: () => currentState.accounts.isNotEmpty ? currentState.accounts.first : throw Exception('No accounts available'),
      );

      emit(TransactionCreateLoaded(
        incomeCategories: currentState.incomeCategories,
        expenseCategories: currentState.expenseCategories,
        accounts: currentState.accounts,
        manualBudgets: currentState.manualBudgets,
        date: DateTime.now(),
        selectedAccount: defaultAccount, // Pre-select default account
      ));
      
      add(ValidateForm());
    }
  }

  Transaction _createTransactionFromState(TransactionCreateLoaded state) {
    final syncId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Convert amount based on transaction type
    final amount = state.amount!;
    double finalAmount;
    
    switch (state.transactionType) {
      case TransactionType.income:
        finalAmount = amount.abs();
        break;
      case TransactionType.expense:
      case TransactionType.subscription:
      case TransactionType.loan:
      case TransactionType.adjustment:
        finalAmount = -amount.abs();
        break;
      case TransactionType.transfer:
        finalAmount = amount; // Keep as-is for transfers
        break;
    }

    return Transaction(
      title: state.title.trim(),
      note: state.note.isNotEmpty ? state.note : null,
      amount: finalAmount,
      categoryId: state.selectedCategory!.id!,
      accountId: state.selectedAccount!.id!,
      date: state.date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncId: syncId,
      transactionType: state.transactionType,
      specialType: state.specialType,
      recurrence: state.recurrence,
      periodLength: state.periodLength,
      endDate: state.endDate,
      transactionState: state.transactionState,
    );
  }

  Future<void> _processAttachments(int transactionId, List<AttachmentData> attachments) async {
    for (final attachment in attachments) {
      try {
        debugPrint('Processing attachment: ${attachment.fileName} for transaction $transactionId');
        
        // 1. Create Attachment entity using repository compression and storage
        final attachmentEntity = await _attachmentRepository.compressAndStoreFile(
          attachment.filePath,
          transactionId,
          attachment.fileName,
          isCapturedFromCamera: attachment.isCapturedFromCamera,
        );
        
        // 2. Save attachment record to database
        final createdAttachment = await _attachmentRepository.createAttachment(attachmentEntity);
        
        // 3. Upload to Google Drive in background
        await _attachmentRepository.uploadToGoogleDrive(createdAttachment);
        
        debugPrint('Successfully processed attachment: ${attachment.fileName}');
      } catch (e) {
        debugPrint('Failed to process attachment ${attachment.fileName}: $e');
        // Continue with other attachments even if one fails
      }
    }
  }

  Future<void> _processBudgetLinks(int transactionId, List<BudgetLink> budgetLinks) async {
    for (final link in budgetLinks) {
      try {
        await _budgetRepository.addTransactionToBudget(
          transactionId,
          link.budget.id!,
        );
      } catch (e) {
        debugPrint('Failed to link transaction to budget ${link.budget.name}: $e');
        // Continue with other links even if one fails
      }
    }
  }
}