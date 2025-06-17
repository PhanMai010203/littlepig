import 'package:equatable/equatable.dart';
import 'budget_enums.dart';

enum BudgetPeriod { daily, weekly, monthly, yearly }

class Budget extends Equatable {
  final int? id;
  final String name;
  final double amount;
  final double spent;
  final int? categoryId;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final bool isSynced;
  final DateTime? lastSyncAt;
  final String syncId;
  final int version;

  // Advanced filtering
  final bool excludeDebtCreditInstallments;
  final bool excludeObjectiveInstallments;
  final List<String>? walletFks;
  final List<String>? currencyFks;

  // Shared budget support  
  final String? sharedReferenceBudgetPk;
  final List<String>? budgetFksExclude;

  // Currency & normalization
  final String? normalizeToCurrency;
  final bool isIncomeBudget;

  // Transfer handling
  final bool includeTransferInOutWithSameCurrency;
  final bool includeUpcomingTransactionFromBudget;

  // Metadata
  final DateTime? dateCreatedOriginal;
  final Map<String, dynamic>? budgetTransactionFilters;

  const Budget({
    this.id,
    required this.name,
    required this.amount,
    required this.spent,
    this.categoryId,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    required this.isSynced,
    this.lastSyncAt,
    required this.syncId,
    required this.version,
    
    // Advanced filtering parameters
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
  });

  Budget copyWith({
    int? id,
    String? name,
    double? amount,
    double? spent,
    int? categoryId,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deviceId,
    bool? isSynced,
    DateTime? lastSyncAt,
    String? syncId,
    int? version,
    
    // Advanced filtering parameters
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
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      categoryId: categoryId ?? this.categoryId,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncId: syncId ?? this.syncId,
      version: version ?? this.version,
      
      // Advanced filtering assignments
      excludeDebtCreditInstallments: excludeDebtCreditInstallments ?? this.excludeDebtCreditInstallments,
      excludeObjectiveInstallments: excludeObjectiveInstallments ?? this.excludeObjectiveInstallments,
      walletFks: walletFks ?? this.walletFks,
      currencyFks: currencyFks ?? this.currencyFks,
      sharedReferenceBudgetPk: sharedReferenceBudgetPk ?? this.sharedReferenceBudgetPk,
      budgetFksExclude: budgetFksExclude ?? this.budgetFksExclude,
      normalizeToCurrency: normalizeToCurrency ?? this.normalizeToCurrency,
      isIncomeBudget: isIncomeBudget ?? this.isIncomeBudget,
      includeTransferInOutWithSameCurrency: includeTransferInOutWithSameCurrency ?? this.includeTransferInOutWithSameCurrency,
      includeUpcomingTransactionFromBudget: includeUpcomingTransactionFromBudget ?? this.includeUpcomingTransactionFromBudget,
      dateCreatedOriginal: dateCreatedOriginal ?? this.dateCreatedOriginal,
      budgetTransactionFilters: budgetTransactionFilters ?? this.budgetTransactionFilters,
    );
  }

  double get remaining => amount - spent;
  double get percentageSpent => spent / amount;
  bool get isOverBudget => spent > amount;

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        spent,
        categoryId,
        period,
        startDate,
        endDate,
        isActive,
        createdAt,
        updatedAt,
        deviceId,
        isSynced,
        lastSyncAt,
        syncId,
        version,
        
        // Advanced filtering props
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
      ];
}
