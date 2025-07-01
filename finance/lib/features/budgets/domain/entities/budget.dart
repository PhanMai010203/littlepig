import 'package:equatable/equatable.dart';

enum BudgetPeriod { daily, weekly, monthly, yearly }

class Budget extends Equatable {
  final int? id;
  final String name;
  final double amount;
  final double spent;
  final int? categoryId;
  final BudgetPeriod period;
  final int periodAmount; // Number of periods (e.g., 2 for "2 months")
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncId;

  final bool excludeDebtCreditInstallments;
  final bool excludeObjectiveInstallments;
  final List<String>? walletFks;
  final List<String>? currencyFks;

  final String? sharedReferenceBudgetPk;
  final List<String>? budgetFksExclude;

  final String? normalizeToCurrency;
  final bool isIncomeBudget;

  final bool includeTransferInOutWithSameCurrency;
  final bool includeUpcomingTransactionFromBudget;

  final DateTime? dateCreatedOriginal;
  final Map<String, dynamic>? budgetTransactionFilters;

  // Budget color as hex string (e.g., "#4CAF50")
  final String? colour;

  const Budget({
    this.id,
    required this.name,
    required this.amount,
    required this.spent,
    this.categoryId,
    required this.period,
    this.periodAmount = 1, // Default to 1 for backward compatibility
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.syncId,

    this.excludeDebtCreditInstallments = false,
    this.excludeObjectiveInstallments = false,
    this.walletFks,
    this.currencyFks,
    this.sharedReferenceBudgetPk,
    this.budgetFksExclude,
    this.normalizeToCurrency,
    this.isIncomeBudget = false,
    this.includeTransferInOutWithSameCurrency = false,
    this.includeUpcomingTransactionFromBudget = false,
    this.dateCreatedOriginal,
    this.budgetTransactionFilters,
    this.colour,
  });

  Budget copyWith({
    int? id,
    String? name,
    double? amount,
    double? spent,
    int? categoryId,
    BudgetPeriod? period,
    int? periodAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncId,

    bool? excludeDebtCreditInstallments,
    bool? excludeObjectiveInstallments,
    List<String>? walletFks,
    List<String>? currencyFks,
    String? sharedReferenceBudgetPk,
    List<String>? budgetFksExclude,
    String? normalizeToCurrency,
    bool? isIncomeBudget,
    bool? includeTransferInOutWithSameCurrency,
    bool? includeUpcomingTransactionFromBudget,
    DateTime? dateCreatedOriginal,
    Map<String, dynamic>? budgetTransactionFilters,
    String? colour,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      categoryId: categoryId ?? this.categoryId,
      period: period ?? this.period,
      periodAmount: periodAmount ?? this.periodAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncId: syncId ?? this.syncId,

      excludeDebtCreditInstallments:
          excludeDebtCreditInstallments ?? this.excludeDebtCreditInstallments,
      excludeObjectiveInstallments:
          excludeObjectiveInstallments ?? this.excludeObjectiveInstallments,
      walletFks: walletFks ?? this.walletFks,
      currencyFks: currencyFks ?? this.currencyFks,
      sharedReferenceBudgetPk:
          sharedReferenceBudgetPk ?? this.sharedReferenceBudgetPk,
      budgetFksExclude: budgetFksExclude ?? this.budgetFksExclude,
      normalizeToCurrency: normalizeToCurrency ?? this.normalizeToCurrency,
      isIncomeBudget: isIncomeBudget ?? this.isIncomeBudget,
      includeTransferInOutWithSameCurrency:
          includeTransferInOutWithSameCurrency ??
              this.includeTransferInOutWithSameCurrency,
      includeUpcomingTransactionFromBudget:
          includeUpcomingTransactionFromBudget ??
              this.includeUpcomingTransactionFromBudget,
      dateCreatedOriginal: dateCreatedOriginal ?? this.dateCreatedOriginal,
      budgetTransactionFilters:
          budgetTransactionFilters ?? this.budgetTransactionFilters,
      colour: colour ?? this.colour,
    );
  }

  double get remaining => amount - spent;
  double get percentageSpent => spent / amount;
  bool get isOverBudget => spent > amount;

  bool get manualAddMode => walletFks == null;

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        spent,
        categoryId,
        period,
        periodAmount,
        startDate,
        endDate,
        isActive,
        createdAt,
        updatedAt,
        syncId,

        excludeDebtCreditInstallments,
        excludeObjectiveInstallments,
        walletFks,
        currencyFks,
        sharedReferenceBudgetPk,
        budgetFksExclude,
        normalizeToCurrency,
        isIncomeBudget,
        includeTransferInOutWithSameCurrency,
        includeUpcomingTransactionFromBudget,
        dateCreatedOriginal,
        budgetTransactionFilters,
        colour,
      ];
}
