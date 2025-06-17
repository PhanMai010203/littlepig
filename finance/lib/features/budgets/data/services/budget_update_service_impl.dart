import 'dart:async';
import 'package:rxdart/rxdart.dart';

import '../../domain/services/budget_update_service.dart';
import '../../domain/services/budget_filter_service.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';
import 'budget_auth_service.dart';

class BudgetUpdateServiceImpl implements BudgetUpdateService {
  final BudgetRepository _budgetRepository;
  final BudgetFilterService _filterService;
  final BudgetAuthService _authService;
  
  // Real-time update streams
  final BehaviorSubject<List<Budget>> _budgetUpdatesController = BehaviorSubject<List<Budget>>();
  final BehaviorSubject<Map<int, double>> _budgetSpentController = BehaviorSubject<Map<int, double>>();
  
  // Performance tracking
  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, int> _operationCounts = {};
  
  BudgetUpdateServiceImpl(
    this._budgetRepository,
    this._filterService,
    this._authService,
  ) {
    _initializeStreams();
  }
  
  void _initializeStreams() async {
    // Initialize with current budget data
    final budgets = await _budgetRepository.getAllBudgets();
    _budgetUpdatesController.add(budgets);
    
    // Initialize spent amounts
    final spentAmounts = <int, double>{};
    for (final budget in budgets) {
      if (budget.id != null) {
        spentAmounts[budget.id!] = budget.spent;
      }
    }
    _budgetSpentController.add(spentAmounts);
  }
  
  @override
  Future<void> updateBudgetOnTransactionChange(
    Transaction transaction, 
    TransactionChangeType changeType
  ) async {
    final operationId = 'update_${DateTime.now().millisecondsSinceEpoch}';
    _startPerformanceTracking(operationId);
    
    try {
      // Find all budgets that might be affected by this transaction
      final affectedBudgets = await _findAffectedBudgets(transaction);
      
      for (final budget in affectedBudgets) {
        // Check if transaction should be included in this budget
        final shouldInclude = await _filterService.shouldIncludeTransaction(budget, transaction);
        
        if (shouldInclude) {
          await _updateBudgetSpentAmount(budget, transaction, changeType);
        }
      }
      
      // Notify listeners of budget updates
      if (affectedBudgets.isNotEmpty) {
        final allBudgets = await _budgetRepository.getAllBudgets();
        _budgetUpdatesController.add(allBudgets);
        
        // Update spent amounts map
        final currentSpentAmounts = _budgetSpentController.value ?? <int, double>{};
        for (final budget in affectedBudgets) {
          if (budget.id != null) {
            currentSpentAmounts[budget.id!] = budget.spent;
          }
        }
        _budgetSpentController.add(currentSpentAmounts);
      }
    } finally {
      _endPerformanceTracking(operationId);
    }
  }
  
  @override
  Future<void> recalculateBudgetSpentAmount(int budgetId) async {
    final operationId = 'recalculate_$budgetId';
    _startPerformanceTracking(operationId);
    
    try {
      final budget = await _budgetRepository.getBudgetById(budgetId);
      if (budget == null) return;
      
      // Calculate accurate spent amount using filter service
      final actualSpent = await _filterService.calculateBudgetSpent(budget);
      
      // Update budget with new spent amount
      final updatedBudget = budget.copyWith(spent: actualSpent);
      await _budgetRepository.updateBudget(updatedBudget);
      
      // Update streams
      final allBudgets = await _budgetRepository.getAllBudgets();
      _budgetUpdatesController.add(allBudgets);
      
      final currentSpentAmounts = _budgetSpentController.value ?? <int, double>{};
      currentSpentAmounts[budgetId] = actualSpent;
      _budgetSpentController.add(currentSpentAmounts);
    } finally {
      _endPerformanceTracking(operationId);
    }
  }
  
  @override
  Future<void> recalculateAllBudgetSpentAmounts() async {
    final operationId = 'recalculate_all';
    _startPerformanceTracking(operationId);
    
    try {
      final budgets = await _budgetRepository.getAllBudgets();
      final spentAmounts = <int, double>{};
      
      for (final budget in budgets) {
        if (budget.id != null) {
          final actualSpent = await _filterService.calculateBudgetSpent(budget);
          spentAmounts[budget.id!] = actualSpent;
          
          // Update budget in database
          final updatedBudget = budget.copyWith(spent: actualSpent);
          await _budgetRepository.updateBudget(updatedBudget);
        }
      }
      
      // Update streams
      final updatedBudgets = await _budgetRepository.getAllBudgets();
      _budgetUpdatesController.add(updatedBudgets);
      _budgetSpentController.add(spentAmounts);
    } finally {
      _endPerformanceTracking(operationId);
    }
  }
  
  @override
  Stream<Budget> watchBudgetUpdates(int budgetId) {
    return _budgetUpdatesController.stream
        .map((budgets) => budgets.where((b) => b.id == budgetId))
        .expand((budgets) => budgets);
  }
  
  @override
  Stream<List<Budget>> watchAllBudgetUpdates() {
    return _budgetUpdatesController.stream;
  }
  
  @override
  Stream<Map<int, double>> watchBudgetSpentAmounts() {
    return _budgetSpentController.stream;
  }
  
  @override
  Future<bool> authenticateForBudgetAccess() async {
    return await _authService.authenticateForBudgetAccess();
  }
  
  @override
  Future<Map<String, dynamic>> getBudgetUpdatePerformanceMetrics() async {
    return {
      'operation_counts': Map<String, int>.from(_operationCounts),
      'average_durations': _calculateAverageDurations(),
      'total_operations': _operationCounts.values.fold(0, (sum, count) => sum + count),
    };
  }
  
  // Private helper methods
  Future<List<Budget>> _findAffectedBudgets(Transaction transaction) async {
    final allBudgets = await _budgetRepository.getAllBudgets();
    final affectedBudgets = <Budget>[];
    
    for (final budget in allBudgets) {
      // Check if transaction falls within budget date range
      if (transaction.date.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(budget.endDate.add(const Duration(days: 1)))) {
        
        // Check if transaction should be included based on filters
        final shouldInclude = await _filterService.shouldIncludeTransaction(budget, transaction);
        if (shouldInclude) {
          affectedBudgets.add(budget);
        }
      }
    }
    
    return affectedBudgets;
  }
  
  Future<void> _updateBudgetSpentAmount(
    Budget budget, 
    Transaction transaction, 
    TransactionChangeType changeType
  ) async {
    double amountChange = 0.0;
    
    switch (changeType) {
      case TransactionChangeType.created:
        amountChange = transaction.amount.abs(); // Always positive for budget spending
        break;
      case TransactionChangeType.deleted:
        amountChange = -transaction.amount.abs(); // Subtract from spent amount
        break;
      case TransactionChangeType.updated:
        // For updates, recalculate the entire budget for accuracy
        await recalculateBudgetSpentAmount(budget.id!);
        return;
    }
    
    // Apply currency normalization if needed
    if (budget.normalizeToCurrency != null) {
      final transactionCurrency = await _getTransactionCurrency(transaction);
      amountChange = await _filterService.normalizeAmountToCurrency(
        amountChange, 
        transactionCurrency, 
        budget.normalizeToCurrency!
      );
    }
    
    // Update budget spent amount
    final newSpentAmount = (budget.spent + amountChange).clamp(0.0, double.infinity);
    final updatedBudget = budget.copyWith(spent: newSpentAmount);
    await _budgetRepository.updateBudget(updatedBudget);
  }
  
  Future<String> _getTransactionCurrency(Transaction transaction) async {
    // Implementation to get transaction currency based on account
    // This would interact with your account repository
    return 'USD'; // Default fallback
  }
  
  void _startPerformanceTracking(String operationId) {
    _operationStartTimes[operationId] = DateTime.now();
    _operationCounts[operationId] = (_operationCounts[operationId] ?? 0) + 1;
  }
  
  void _endPerformanceTracking(String operationId) {
    _operationStartTimes.remove(operationId);
  }
  
  Map<String, double> _calculateAverageDurations() {
    // Implementation for calculating average operation durations
    return {};
  }
  
  @override
  void dispose() {
    _budgetUpdatesController.close();
    _budgetSpentController.close();
  }
} 