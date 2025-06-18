# Next Steps Quick Reference

## Immediate Actions (Phase 2.1 - Start This Week)

### 1. Database Schema Migration (Priority: HIGH)

**Files to Create/Modify:**
```
lib/core/database/app_database.dart - Update schema version to 5
lib/core/database/tables/budgets_table.dart - Add new columns
```

**New Budget Table Fields (Schema v5):**
```sql
-- Core advanced filtering
ALTER TABLE budgets ADD COLUMN budget_transaction_filters TEXT;
ALTER TABLE budgets ADD COLUMN exclude_debt_credit_installments BOOLEAN DEFAULT FALSE;
ALTER TABLE budgets ADD COLUMN exclude_objective_installments BOOLEAN DEFAULT FALSE;
ALTER TABLE budgets ADD COLUMN wallet_fks TEXT; -- JSON array
ALTER TABLE budgets ADD COLUMN currency_fks TEXT; -- JSON array

-- Shared budget support
ALTER TABLE budgets ADD COLUMN shared_reference_budget_pk TEXT;
ALTER TABLE budgets ADD COLUMN budget_fks_exclude TEXT; -- JSON array

-- Currency normalization
ALTER TABLE budgets ADD COLUMN normalize_to_currency TEXT;
ALTER TABLE budgets ADD COLUMN is_income_budget BOOLEAN DEFAULT FALSE;

-- Advanced features
ALTER TABLE budgets ADD COLUMN include_transfer_in_out_with_same_currency BOOLEAN DEFAULT FALSE;
ALTER TABLE budgets ADD COLUMN include_upcoming_transaction_from_budget BOOLEAN DEFAULT FALSE;
ALTER TABLE budgets ADD COLUMN date_created_original DATETIME;
```

### 2. Budget Entity Extensions

**File to Modify:** `lib/features/budgets/domain/entities/budget.dart`

**Add These Fields:**
```dart
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
```

### 3. Create Budget Enums

**New File:** `lib/features/budgets/domain/entities/budget_enums.dart`

```dart
enum BudgetTransactionFilter {
  includeAll,
  excludeDebtCredit,
  excludeObjectives,
  includeOnlyCurrent,
  customFilter
}

enum BudgetShareType {
  personal,
  shared,
  household,
  project
}
```

## Week 1 Goals (Phase 2.1 Complete)

### Day 1-2: Schema & Entity Updates
- [x] Phase 1 completed (advanced transactions)
- [ ] Create budget schema migration (v4 → v5)
- [ ] Extend budget entity with new fields
- [ ] Update budget repository CRUD operations
- [ ] Create budget enums file

### Day 3-4: Repository & Migration
- [ ] Test database migration thoroughly
- [ ] Update BudgetRepositoryImpl with new fields
- [ ] Create migration tests
- [ ] Update existing budget tests

### Day 5: Basic Filter Logic Foundation
- [ ] Create BudgetFilterService interface
- [ ] Implement basic shouldIncludeTransaction method
- [ ] Write unit tests for basic filtering

## Week 2 Goals (Phase 2.2 + 3.1)

### Budget Filtering Logic
- [ ] Implement complete BudgetFilterService
- [ ] Add debt/credit transaction exclusion
- [ ] Add wallet and currency filtering
- [ ] Add objective transaction exclusion

### Real-Time Updates Foundation
- [ ] Create BudgetUpdateService interface
- [ ] Implement basic real-time budget recalculation
- [ ] Connect transaction CRUD to budget updates
- [ ] Add budget update streams

## Critical Integration Points

### 1. Transaction → Budget Updates
**When transaction created/updated/deleted:**
```dart
// In TransactionRepositoryImpl
await _budgetUpdateService.updateBudgetOnTransactionChange(
  transaction, 
  TransactionChangeType.created
);
```

### 2. Budget Filtering Logic
**Core filtering method:**
```dart
Future<bool> shouldIncludeTransaction(Budget budget, Transaction transaction) async {
  // Check debt/credit exclusion
  if (budget.excludeDebtCreditInstallments && (transaction.isCredit || transaction.isDebt)) {
    return false;
  }
  
  // Check objective exclusion  
  if (budget.excludeObjectiveInstallments && transaction.objectiveLoanFk != null) {
    return false;
  }
  
  // Check wallet filter
  if (budget.walletFks?.isNotEmpty == true) {
    if (!budget.walletFks!.contains(transaction.accountId.toString())) {
      return false;
    }
  }
  
  return true;
}
```

### 3. Real-Time Budget Spent Calculation
**Key algorithm:**
```dart
Future<double> calculateRealTimeBudgetSpent(Budget budget) async {
  final transactions = await getFilteredTransactionsForBudget(budget);
  
  double totalSpent = 0.0;
  for (final transaction in transactions) {
    // Apply currency normalization if needed
    double amount = transaction.amount;
    if (budget.normalizeToCurrency != null) {
      amount = await normalizeAmountToCurrency(amount, transactionCurrency, budget.normalizeToCurrency!);
    }
    totalSpent += amount;
  }
  
  return totalSpent;
}
```

## Dependencies & Services Needed

### New Services to Create:
1. **BudgetFilterService** - Core filtering logic
2. **BudgetUpdateService** - Real-time budget updates  
3. **BudgetCurrencyService** - Multi-currency support
4. **SharedBudgetService** - Shared budget management (Phase 4)

### Existing Services to Extend:
1. **TransactionRepository** - Add budget update triggers
2. **BudgetRepository** - Add new field support
3. **CurrencyService** - Add budget normalization support

## Testing Strategy

### Unit Tests (Week 1)
- [ ] Budget entity with new fields
- [ ] Budget table migration
- [ ] Basic budget filtering logic

### Integration Tests (Week 2)  
- [ ] Transaction creation → budget update flow
- [ ] Budget filtering with real transactions
- [ ] Currency normalization accuracy

### Performance Tests (Week 3)
- [ ] Budget calculation with large transaction sets
- [ ] Real-time update performance
- [ ] Memory usage with filtered transactions

## Risk Mitigation

### High-Risk Areas:
1. **Database migration** - Test thoroughly with existing data
2. **Performance** - Budget calculations with many transactions
3. **Real-time updates** - Avoid infinite update loops
4. **Currency conversion** - Handle rate fetch failures

### Backup Plans:
1. **Migration issues** - Have rollback scripts ready
2. **Performance problems** - Implement caching layer
3. **Update loops** - Add proper debouncing
4. **Currency failures** - Use cached fallback rates

## Success Criteria

### Phase 2.1 Complete When:
- [x] Phase 1 transaction features working
- [ ] Database schema v5 migration successful  
- [ ] Budget entity supports all new fields
- [ ] All existing budget tests pass
- [ ] New budget fields properly validated

### Phase 2.2 Complete When:
- [ ] Budget filtering service fully functional
- [ ] Transaction inclusion logic working correctly
- [ ] Debt/credit exclusion implemented
- [ ] Wallet and currency filtering operational
- [ ] Integration tests passing

This provides a clear, actionable roadmap for the immediate next steps while maintaining the comprehensive planning from the detailed implementation document.
