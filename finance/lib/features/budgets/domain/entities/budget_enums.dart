/// Budget transaction filter types
enum BudgetTransactionFilter {
  includeAll,
  excludeDebtCredit,
  excludeObjectives,
  includeOnlyCurrent,
  customFilter
}

/// Budget sharing types
enum BudgetShareType {
  personal,
  shared,
  household,
  project
}

/// Member exclusion types
enum MemberExclusionType {
  none,
  specific,
  allExceptOwner
}

/// Budget period types for advanced scheduling
enum BudgetPeriodType {
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly,
  custom
} 