# Phase 2 Implementation Guide: Budget Schema Extensions & Advanced Filtering

## Overview

Phase 2 focuses on extending the budget system with advanced filtering capabilities and enhanced database schema. This phase builds upon the Phase 1 transaction features and creates the foundation for sophisticated budget management.

**Duration**: 5-7 days  
**Priority**: HIGH  
**Dependencies**: Phase 1 (Advanced Transactions) must be completed  

---

## 🔥 Quick Start - Immediate Actions

### Required Flutter Packages

Add these to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  # CSV Import/Export functionality
  csv: ^6.0.0
  share_plus: ^10.0.0
  flutter_charset_detector: ^1.0.2
  
  # Enhanced analytics and charts (optional)
  fl_chart: ^0.68.0
```

### ⚠️ Packages to AVOID (Conflicts with existing implementation)

```yaml
# DO NOT ADD - Conflicts with existing AppSettings class
# app_settings: ^5.1.1

# DO NOT ADD - Conflicts with existing dynamic_color implementation  
# system_theme: ^3.0.0
# flutter_displaymode: ^0.6.0
```

---

## Phase 2.1: Budget Table Schema Extensions (2-3 days)

### 2.1.1 Database Migration - Schema v5

**File**: `lib/core/database/app_database.dart`

Update schema version and add migration:

```dart
@DriftDatabase(
  tables: [
    // ...existing tables...
    BudgetsTable,
  ],
  version: 5, // Update from 4 to 5
)
class AppDatabase extends _$AppDatabase {
  // ...existing code...

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // ...existing migrations...
        
        if (from <= 4) {
          // Migration from v4 to v5 - Add budget advanced fields
          await m.addColumn(budgetsTable, budgetsTable.budgetTransactionFilters);
          await m.addColumn(budgetsTable, budgetsTable.excludeDebtCreditInstallments);
          await m.addColumn(budgetsTable, budgetsTable.excludeObjectiveInstallments);
          await m.addColumn(budgetsTable, budgetsTable.walletFks);
          await m.addColumn(budgetsTable, budgetsTable.currencyFks);
          await m.addColumn(budgetsTable, budgetsTable.sharedReferenceBudgetPk);
          await m.addColumn(budgetsTable, budgetsTable.budgetFksExclude);
          await m.addColumn(budgetsTable, budgetsTable.normalizeToCurrency);
          await m.addColumn(budgetsTable, budgetsTable.isIncomeBudget);
          await m.addColumn(budgetsTable, budgetsTable.includeTransferInOutWithSameCurrency);
          await m.addColumn(budgetsTable, budgetsTable.includeUpcomingTransactionFromBudget);
          await m.addColumn(budgetsTable, budgetsTable.dateCreatedOriginal);
        }
      },
    );
  }
}
```

### 2.1.2 Update Budget Table Definition

**File**: `lib/core/database/tables/budgets_table.dart`

```dart
import 'package:drift/drift.dart';

@DataClassName('BudgetTableData')
class BudgetsTable extends Table {
  // ...existing columns...
  
  // Advanced filtering fields
  TextColumn get budgetTransactionFilters => text().nullable()(); // JSON string
  BoolColumn get excludeDebtCreditInstallments => boolean().withDefault(const Constant(false))();
  BoolColumn get excludeObjectiveInstallments => boolean().withDefault(const Constant(false))();
  TextColumn get walletFks => text().nullable()(); // JSON array of wallet IDs
  TextColumn get currencyFks => text().nullable()(); // JSON array of currency codes
  
  // Shared budget support
  TextColumn get sharedReferenceBudgetPk => text().nullable()();
  TextColumn get budgetFksExclude => text().nullable()(); // JSON array of budget IDs to exclude
  
  // Currency normalization
  TextColumn get normalizeToCurrency => text().nullable()();
  BoolColumn get isIncomeBudget => boolean().withDefault(const Constant(false))();
  
  // Advanced features
  BoolColumn get includeTransferInOutWithSameCurrency => boolean().withDefault(const Constant(false))();
  BoolColumn get includeUpcomingTransactionFromBudget => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dateCreatedOriginal => dateTime().nullable()();
}
```

### 2.1.3 Create Budget Enums

**File**: `lib/features/budgets/domain/entities/budget_enums.dart`

```dart
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
```

### 2.1.4 Update Budget Entity

**File**: `lib/features/budgets/domain/entities/budget.dart`

```dart
import 'package:equatable/equatable.dart';
import 'budget_enums.dart';

class Budget extends Equatable {
  // ...existing fields...
  
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
    // ...existing parameters...
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

  // Enhanced copyWith method
  Budget copyWith({
    // ...existing parameters...
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
      // ...existing assignments...
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

  @override
  List<Object?> get props => [
    // ...existing props...
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
```

---

## Phase 2.2: Budget Filtering Logic Implementation (3-4 days)

### 2.2.1 Create Budget Filter Service Interface

**File**: `lib/features/budgets/domain/services/budget_filter_service.dart`

```dart
import '../entities/budget.dart';
import '../../transactions/domain/entities/transaction.dart';

abstract class BudgetFilterService {
  Future<List<Transaction>> getFilteredTransactionsForBudget(
    Budget budget, 
    DateTime startDate, 
    DateTime endDate
  );
  
  Future<double> calculateBudgetSpent(Budget budget);
  Future<double> calculateBudgetRemaining(Budget budget);
  Future<bool> shouldIncludeTransaction(Budget budget, Transaction transaction);
  
  // Advanced filtering methods
  Future<List<Transaction>> excludeDebtCreditTransactions(List<Transaction> transactions);
  Future<List<Transaction>> excludeObjectiveTransactions(List<Transaction> transactions);
  Future<List<Transaction>> filterByWallets(List<Transaction> transactions, List<String> walletFks);
  Future<List<Transaction>> filterByCurrency(List<Transaction> transactions, List<String> currencyFks);
  Future<double> normalizeAmountToCurrency(double amount, String fromCurrency, String toCurrency);
  
  // CSV Export functionality
  Future<void> exportBudgetData(Budget budget, String filePath);
  Future<void> exportMultipleBudgets(List<Budget> budgets);
}
```

### 2.2.2 Create CSV Service for Budget Data

**File**: `lib/features/budgets/data/services/budget_csv_service.dart`

```dart
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/budget.dart';

class BudgetCsvService {
  Future<void> exportBudgetToCSV(Budget budget, String fileName) async {
    final csvData = [
      // Header row
      [
        'Budget Name',
        'Amount',
        'Spent',
        'Remaining',
        'Start Date',
        'End Date',
        'Category ID',
        'Exclude Debt/Credit',
        'Exclude Objectives',
        'Currency Normalization',
        'Is Income Budget',
      ],
      // Data row
      [
        budget.name,
        budget.amount.toString(),
        budget.spent.toString(),
        (budget.amount - budget.spent).toString(),
        budget.startDate.toIso8601String(),
        budget.endDate.toIso8601String(),
        budget.categoryId?.toString() ?? '',
        budget.excludeDebtCreditInstallments.toString(),
        budget.excludeObjectiveInstallments.toString(),
        budget.normalizeToCurrency ?? '',
        budget.isIncomeBudget.toString(),
      ],
    ];
    
    final csvString = const ListToCsvConverter().convert(csvData);
    
    // Get temporary directory for file storage
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${fileName.isEmpty ? 'budget_export.csv' : fileName}');
    await file.writeAsString(csvString);
    
    // Share the file
    await Share.shareXFiles([XFile(file.path)], text: 'Budget Export');
  }
  
  Future<void> exportBudgetsToCSV(List<Budget> budgets) async {
    final csvData = [
      // Header row
      [
        'Budget Name',
        'Amount',
        'Spent',
        'Remaining',
        'Start Date',
        'End Date',
        'Category ID',
        'Exclude Debt/Credit',
        'Exclude Objectives',
        'Currency Normalization',
        'Is Income Budget',
      ],
    ];
    
    // Add data rows
    for (final budget in budgets) {
      csvData.add([
        budget.name,
        budget.amount.toString(),
        budget.spent.toString(),
        (budget.amount - budget.spent).toString(),
        budget.startDate.toIso8601String(),
        budget.endDate.toIso8601String(),
        budget.categoryId?.toString() ?? '',
        budget.excludeDebtCreditInstallments.toString(),
        budget.excludeObjectiveInstallments.toString(),
        budget.normalizeToCurrency ?? '',
        budget.isIncomeBudget.toString(),
      ]);
    }
    
    final csvString = const ListToCsvConverter().convert(csvData);
    
    // Get temporary directory for file storage
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/budgets_export.csv');
    await file.writeAsString(csvString);
    
    // Share the file
    await Share.shareXFiles([XFile(file.path)], text: 'Budgets Export');
  }
  
  Future<List<Budget>> importBudgetsFromCSV(String filePath) async {
    try {
      // Detect encoding
      final encoding = await CharsetDetector.detectFromPath(filePath) ?? 'utf-8';
      
      // Read file with detected encoding
      final file = File(filePath);
      final csvString = await file.readAsString();
      
      // Parse CSV
      final csvData = const CsvToListConverter().convert(csvString);
      
      // Skip header row and convert to budgets
      final budgets = <Budget>[];
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.length >= 11) {
          budgets.add(_convertRowToBudget(row));
        }
      }
      
      return budgets;
    } catch (e) {
      throw Exception('Failed to import budgets from CSV: $e');
    }
  }
  
  Budget _convertRowToBudget(List<dynamic> row) {
    return Budget(
      name: row[0].toString(),
      amount: double.tryParse(row[1].toString()) ?? 0.0,
      spent: double.tryParse(row[2].toString()) ?? 0.0,
      startDate: DateTime.tryParse(row[4].toString()) ?? DateTime.now(),
      endDate: DateTime.tryParse(row[5].toString()) ?? DateTime.now().add(Duration(days: 30)),
      categoryId: int.tryParse(row[6].toString()),
      excludeDebtCreditInstallments: row[7].toString().toLowerCase() == 'true',
      excludeObjectiveInstallments: row[8].toString().toLowerCase() == 'true',
      normalizeToCurrency: row[9].toString().isEmpty ? null : row[9].toString(),
      isIncomeBudget: row[10].toString().toLowerCase() == 'true',
    );
  }
}
```

### 2.2.3 Implement Budget Filter Service

**File**: `lib/features/budgets/data/services/budget_filter_service_impl.dart`

```dart
import '../../domain/services/budget_filter_service.dart';
import '../../domain/entities/budget.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../../core/services/currency_service.dart';
import 'budget_csv_service.dart';

class BudgetFilterServiceImpl implements BudgetFilterService {
  final TransactionRepository _transactionRepository;
  final CurrencyService _currencyService;
  final BudgetCsvService _csvService;
  
  BudgetFilterServiceImpl(
    this._transactionRepository,
    this._currencyService,
    this._csvService,
  );
  
  @override
  Future<List<Transaction>> getFilteredTransactionsForBudget(
    Budget budget, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    // Step 1: Get base transactions by date range and category
    List<Transaction> transactions = await _getBaseTransactions(budget, startDate, endDate);
    
    // Step 2: Apply exclude debt/credit filter
    if (budget.excludeDebtCreditInstallments) {
      transactions = await excludeDebtCreditTransactions(transactions);
    }
    
    // Step 3: Apply exclude objective filter
    if (budget.excludeObjectiveInstallments) {
      transactions = await excludeObjectiveTransactions(transactions);
    }
    
    // Step 4: Apply wallet filter
    if (budget.walletFks?.isNotEmpty == true) {
      transactions = await filterByWallets(transactions, budget.walletFks!);
    }
    
    // Step 5: Apply currency filter and normalization
    if (budget.currencyFks?.isNotEmpty == true) {
      transactions = await filterByCurrency(transactions, budget.currencyFks!);
    }
    
    // Step 6: Apply shared budget exclusions
    if (budget.budgetFksExclude?.isNotEmpty == true) {
      transactions = await _excludeSharedBudgetTransactions(transactions, budget.budgetFksExclude!);
    }
    
    // Step 7: Apply transfer same-currency filter
    if (budget.includeTransferInOutWithSameCurrency) {
      transactions = await _includeTransferTransactions(transactions, budget);
    }
    
    return transactions;
  }
  
  @override
  Future<bool> shouldIncludeTransaction(Budget budget, Transaction transaction) async {
    // Check debt/credit exclusion
    if (budget.excludeDebtCreditInstallments && (transaction.isCredit || transaction.isDebt)) {
      return false;
    }
    
    // Check objective exclusion
    if (budget.excludeObjectiveInstallments && transaction.objectiveLoanFk != null) {
      return false;
    }
    
    // Check wallet inclusion
    if (budget.walletFks?.isNotEmpty == true) {
      if (!budget.walletFks!.contains(transaction.accountId.toString())) {
        return false;
      }
    }
    
    // Check currency inclusion (will need account currency lookup)
    if (budget.currencyFks?.isNotEmpty == true) {
      final accountCurrency = await _getAccountCurrency(transaction.accountId);
      if (!budget.currencyFks!.contains(accountCurrency)) {
        return false;
      }
    }
    
    // Check category match (existing logic)
    if (budget.categoryId != null && transaction.categoryId != budget.categoryId) {
      return false;
    }
    
    return true;
  }

  @override
  Future<List<Transaction>> excludeDebtCreditTransactions(List<Transaction> transactions) async {
    return transactions.where((t) => !t.isCredit && !t.isDebt).toList();
  }

  @override
  Future<List<Transaction>> excludeObjectiveTransactions(List<Transaction> transactions) async {
    return transactions.where((t) => t.objectiveLoanFk == null).toList();
  }

  @override
  Future<List<Transaction>> filterByWallets(List<Transaction> transactions, List<String> walletFks) async {
    return transactions.where((t) => walletFks.contains(t.accountId.toString())).toList();
  }

  @override
  Future<List<Transaction>> filterByCurrency(List<Transaction> transactions, List<String> currencyFks) async {
    final filteredTransactions = <Transaction>[];
    
    for (final transaction in transactions) {
      final accountCurrency = await _getAccountCurrency(transaction.accountId);
      if (currencyFks.contains(accountCurrency)) {
        filteredTransactions.add(transaction);
      }
    }
    
    return filteredTransactions;
  }

  @override
  Future<double> normalizeAmountToCurrency(double amount, String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return amount;
    
    try {
      final exchangeRate = await _currencyService.getExchangeRate(fromCurrency, toCurrency);
      return amount * exchangeRate;
    } catch (e) {
      print('Currency conversion error: $e');
      return amount; // Return original amount as fallback
    }
  }

  @override
  Future<double> calculateBudgetSpent(Budget budget) async {
    final transactions = await getFilteredTransactionsForBudget(
      budget, 
      budget.startDate, 
      budget.endDate
    );
    
    double totalSpent = 0.0;
    for (final transaction in transactions) {
      double amount = transaction.amount.abs();
      
      // Apply currency normalization if needed
      if (budget.normalizeToCurrency != null) {
        final transactionCurrency = await _getTransactionCurrency(transaction);
        amount = await normalizeAmountToCurrency(amount, transactionCurrency, budget.normalizeToCurrency!);
      }
      
      totalSpent += amount;
    }
    
    return totalSpent;
  }

  @override
  Future<double> calculateBudgetRemaining(Budget budget) async {
    final spent = await calculateBudgetSpent(budget);
    return budget.amount - spent;
  }

  @override
  Future<void> exportBudgetData(Budget budget, String filePath) async {
    await _csvService.exportBudgetToCSV(budget, filePath);
  }

  @override
  Future<void> exportMultipleBudgets(List<Budget> budgets) async {
    await _csvService.exportBudgetsToCSV(budgets);
  }
  
  // Private helper methods
  Future<List<Transaction>> _getBaseTransactions(Budget budget, DateTime startDate, DateTime endDate) async {
    if (budget.categoryId != null) {
      final allTransactions = await _transactionRepository.getTransactionsByCategory(budget.categoryId!);
      return allTransactions.where((t) => 
        t.date.isAfter(startDate.subtract(Duration(days: 1))) && 
        t.date.isBefore(endDate.add(Duration(days: 1)))
      ).toList();
    }
    return await _transactionRepository.getTransactionsByDateRange(startDate, endDate);
  }
  
  Future<String> _getAccountCurrency(int accountId) async {
    // Implementation to get account currency
    // This would interact with your account repository
    return 'USD'; // Default fallback
  }
  
  Future<String> _getTransactionCurrency(Transaction transaction) async {
    return await _getAccountCurrency(transaction.accountId);
  }
  
  Future<List<Transaction>> _excludeSharedBudgetTransactions(List<Transaction> transactions, List<String> budgetFksExclude) async {
    // Implementation for shared budget exclusions
    // This would be expanded in Phase 4
    return transactions;
  }
  
  Future<List<Transaction>> _includeTransferTransactions(List<Transaction> transactions, Budget budget) async {
    // Implementation for transfer transactions
    // This would be expanded based on transfer logic
    return transactions;
  }
}
```

---

## Testing Phase 2

### 2.1 Unit Tests

**File**: `test/features/budgets/budget_filter_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:finance/features/budgets/domain/services/budget_filter_service.dart';
import 'package:finance/features/budgets/data/services/budget_filter_service_impl.dart';

void main() {
  group('Budget Filter Service Tests', () {
    late BudgetFilterService budgetFilterService;
    late MockTransactionRepository mockTransactionRepository;
    late MockCurrencyService mockCurrencyService;
    late MockBudgetCsvService mockCsvService;
    
    setUp(() {
      mockTransactionRepository = MockTransactionRepository();
      mockCurrencyService = MockCurrencyService();
      mockCsvService = MockBudgetCsvService();
      
      budgetFilterService = BudgetFilterServiceImpl(
        mockTransactionRepository,
        mockCurrencyService,
        mockCsvService,
      );
    });
    
    test('should exclude debt/credit transactions when flag is set', () async {
      // Arrange
      final budget = Budget(
        name: 'Test Budget',
        amount: 1000.0,
        spent: 0.0,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        excludeDebtCreditInstallments: true,
      );
      
      final transactions = [
        Transaction(/* regular transaction */),
        Transaction(/* debt transaction with isDebt = true */),
        Transaction(/* credit transaction with isCredit = true */),
      ];
      
      // Act
      final filtered = await budgetFilterService.excludeDebtCreditTransactions(transactions);
      
      // Assert
      expect(filtered.length, equals(1)); // Only regular transaction should remain
    });
    
    test('should filter by wallet IDs correctly', () async {
      // Test wallet filtering logic
    });
    
    test('should normalize currencies correctly', () async {
      // Test currency normalization
    });
    
    test('should export budget data to CSV', () async {
      // Test CSV export functionality
    });
  });
}
```

### 2.2 Integration Tests

**File**: `test/integration/budget_filtering_integration_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Budget Filtering Integration Tests', () {
    testWidgets('complete budget filtering workflow', (tester) async {
      // Test complete flow:
      // 1. Create budget with filters
      // 2. Create various transactions
      // 3. Verify filtering works correctly
      // 4. Test CSV export
    });
    
    testWidgets('budget schema migration', (tester) async {
      // Test database migration from v4 to v5
      // Verify all new fields are added correctly
    });
  });
}
```

---

## Success Criteria for Phase 2

### Phase 2.1 Complete When:
- [ ] Database schema migration v4 → v5 successful
- [ ] Budget entity supports all new fields
- [ ] Budget enums created and integrated
- [ ] All existing budget tests pass
- [ ] New budget fields properly validated

### Phase 2.2 Complete When:
- [ ] Budget filtering service fully functional
- [ ] Transaction inclusion logic working correctly
- [ ] Debt/credit exclusion implemented
- [ ] Wallet and currency filtering operational
- [ ] CSV export/import working
- [ ] Unit tests passing with >90% coverage
- [ ] Integration tests passing

---

## Risk Mitigation

### High-Risk Areas
1. **Database Migration**: Schema changes could break existing data
   - **Mitigation**: Thorough testing with backup data
   - **Contingency**: Rollback scripts prepared

2. **Performance**: Complex filtering with large transaction sets
   - **Mitigation**: Implement proper indexing
   - **Contingency**: Add caching layer

3. **CSV Export Memory**: Large datasets could cause memory issues
   - **Mitigation**: Stream-based processing
   - **Contingency**: Chunked export for large datasets

### Package Risks
- **csv package**: Memory usage with large files
- **share_plus**: Platform-specific sharing differences
- **flutter_charset_detector**: Encoding detection accuracy

---

## Next Steps

Upon completion of Phase 2, proceed to:
- **Phase 3**: Real-Time Budget Updates & Transaction Integration
- **Phase 4**: UI Integration & Enhanced Features
- **Phase 5**: Testing & Documentation

This phase establishes the foundation for advanced budget management while maintaining backward compatibility and introducing powerful new filtering and export capabilities.
