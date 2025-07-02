import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_enums.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../budgets/domain/entities/budget.dart';

abstract class TransactionCreateState extends Equatable {
  const TransactionCreateState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class TransactionCreateInitial extends TransactionCreateState {}

/// Loading initial data (categories, accounts, budgets)
class TransactionCreateLoading extends TransactionCreateState {}

/// Error state
class TransactionCreateError extends TransactionCreateState {
  final String message;

  const TransactionCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Form is loaded and ready for input
class TransactionCreateLoaded extends TransactionCreateState {
  // Available options
  final List<Category> incomeCategories;
  final List<Category> expenseCategories;
  final List<Account> accounts;
  final List<Budget> manualBudgets;

  // Current form values
  final String title;
  final double? amount;
  final String note;
  final DateTime date;
  final TransactionType transactionType;
  final Category? selectedCategory;
  final Account? selectedAccount;
  final TransactionSpecialType? specialType;
  final TransactionRecurrence recurrence;
  final int? periodLength;
  final DateTime? endDate;
  final TransactionState transactionState;

  // Attachments
  final List<AttachmentData> attachments;

  // Budget links
  final List<BudgetLink> budgetLinks;

  // Form validation
  final Map<String, String> validationErrors;
  final bool isValid;

  // UI state
  final bool isCreating;
  final String? nextRequiredField;

  const TransactionCreateLoaded({
    required this.incomeCategories,
    required this.expenseCategories,
    required this.accounts,
    required this.manualBudgets,
    this.title = '',
    this.amount,
    this.note = '',
    required this.date,
    this.transactionType = TransactionType.expense,
    this.selectedCategory,
    this.selectedAccount,
    this.specialType,
    this.recurrence = TransactionRecurrence.none,
    this.periodLength,
    this.endDate,
    this.transactionState = TransactionState.completed,
    this.attachments = const [],
    this.budgetLinks = const [],
    this.validationErrors = const {},
    this.isValid = false,
    this.isCreating = false,
    this.nextRequiredField,
  });

  TransactionCreateLoaded copyWith({
    List<Category>? incomeCategories,
    List<Category>? expenseCategories,
    List<Account>? accounts,
    List<Budget>? manualBudgets,
    String? title,
    double? amount,
    String? note,
    DateTime? date,
    TransactionType? transactionType,
    Category? selectedCategory,
    Account? selectedAccount,
    TransactionSpecialType? specialType,
    TransactionRecurrence? recurrence,
    int? periodLength,
    DateTime? endDate,
    TransactionState? transactionState,
    List<AttachmentData>? attachments,
    List<BudgetLink>? budgetLinks,
    Map<String, String>? validationErrors,
    bool? isValid,
    bool? isCreating,
    String? nextRequiredField,
  }) {
    return TransactionCreateLoaded(
      incomeCategories: incomeCategories ?? this.incomeCategories,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      accounts: accounts ?? this.accounts,
      manualBudgets: manualBudgets ?? this.manualBudgets,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      transactionType: transactionType ?? this.transactionType,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      specialType: specialType ?? this.specialType,
      recurrence: recurrence ?? this.recurrence,
      periodLength: periodLength ?? this.periodLength,
      endDate: endDate ?? this.endDate,
      transactionState: transactionState ?? this.transactionState,
      attachments: attachments ?? this.attachments,
      budgetLinks: budgetLinks ?? this.budgetLinks,
      validationErrors: validationErrors ?? this.validationErrors,
      isValid: isValid ?? this.isValid,
      isCreating: isCreating ?? this.isCreating,
      nextRequiredField: nextRequiredField ?? this.nextRequiredField,
    );
  }

  /// Get categories filtered by current transaction type
  List<Category> get currentCategories {
    switch (transactionType) {
      case TransactionType.income:
        return incomeCategories;
      case TransactionType.expense:
      case TransactionType.subscription:
      case TransactionType.loan:
      case TransactionType.adjustment:
        return expenseCategories;
      case TransactionType.transfer:
        return [...incomeCategories, ...expenseCategories];
    }
  }

  @override
  List<Object?> get props => [
        incomeCategories,
        expenseCategories,
        accounts,
        manualBudgets,
        title,
        amount,
        note,
        date,
        transactionType,
        selectedCategory,
        selectedAccount,
        specialType,
        recurrence,
        periodLength,
        endDate,
        transactionState,
        attachments,
        budgetLinks,
        validationErrors,
        isValid,
        isCreating,
        nextRequiredField,
      ];
}

/// Transaction created successfully
class TransactionCreateSuccess extends TransactionCreateState {
  final String message;

  const TransactionCreateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Attachment data model
class AttachmentData extends Equatable {
  final String filePath;
  final String fileName;
  final bool isCapturedFromCamera;

  const AttachmentData({
    required this.filePath,
    required this.fileName,
    this.isCapturedFromCamera = false,
  });

  @override
  List<Object?> get props => [filePath, fileName, isCapturedFromCamera];
}

/// Budget link data model
class BudgetLink extends Equatable {
  final Budget budget;
  final double? customAmount;

  const BudgetLink({
    required this.budget,
    this.customAmount,
  });

  @override
  List<Object?> get props => [budget, customAmount];
}