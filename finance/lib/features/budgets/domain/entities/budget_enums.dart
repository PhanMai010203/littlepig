enum BudgetTransactionFilter {
  includeAll,
  excludeDebtCredit,
  excludeObjectives,
  includeOnlyCurrent,
  customFilter
}

enum BudgetShareType { personal, shared, household, project }

enum MemberExclusionType { none, specific, allExceptOwner }

enum BudgetPeriodType { weekly, biweekly, monthly, quarterly, yearly, custom }

enum BudgetTrackingType { 
  manual, 
  automatic;
  
  bool get isManual => this == BudgetTrackingType.manual;
  bool get isAutomatic => this == BudgetTrackingType.automatic;
}
