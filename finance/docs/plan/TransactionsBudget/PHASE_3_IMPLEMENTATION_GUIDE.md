# Phase 3 Implementation Guide: Real-Time Budget Updates & Transaction Integration

## Overview

Phase 3 focuses on implementing real-time budget updates and seamless integration between the transaction and budget systems. This phase builds upon the advanced budget filtering capabilities from Phase 2 and creates a responsive, dynamic budget management experience.

**Duration**: 4-5 days  
**Priority**: HIGH  
**Dependencies**: Phase 2 (Budget Schema Extensions) must be completed  

---

## 🔥 Quick Start - Required Packages

### Additional Flutter Packages for Phase 3

Add these to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  # Biometric authentication for budget protection
  local_auth: ^2.2.0
  
  # Enhanced state management for real-time updates
  rxdart: ^0.27.7
  
  # Performance monitoring
  flutter_performance_tools: ^1.0.0
```

---

## Phase 3.1: Real-Time Budget Calculation Service (2-3 days)

### 3.1.1 Create Budget Update Service Interface

**File**: `lib/features/budgets/domain/services/budget_update_service.dart`

```dart
import 'dart:async';
import '../entities/budget.dart';
import '../../transactions/domain/entities/transaction.dart';

abstract class BudgetUpdateService {
  Future<void> updateBudgetOnTransactionChange(
    Transaction transaction, 
    TransactionChangeType changeType
  );
  
  Future<void> recalculateAllBudgetSpentAmounts();
  Future<void> recalculateBudgetSpentAmount(int budgetId);
  
  Stream<Budget> watchBudgetUpdates(int budgetId);
  Stream<List<Budget>> watchAllBudgetUpdates();
  Stream<Map<int, double>> watchBudgetSpentAmounts();
  
  // Authentication for sensitive budget operations
  Future<bool> authenticateForBudgetAccess();
  
  // Performance monitoring
  Future<Map<String, dynamic>> getBudgetUpdatePerformanceMetrics();
}

enum TransactionChangeType { created, updated, deleted }
```

### 3.1.2 Create Budget Authentication Service

**File**: `lib/features/budgets/data/services/budget_auth_service.dart`

```dart
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class BudgetAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  Future<bool> authenticateForBudgetAccess() async {
    try {
      // Check if biometric authentication is available
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!isAvailable || !isDeviceSupported) {
        return false; // Fallback to no authentication if not available
      }
      
      // Get available biometric types
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        return false; // No biometric methods available
      }
      
      // Attempt authentication
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access sensitive budget information',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Budget Authentication',
            cancelButton: 'Cancel',
            biometricHint: 'Touch fingerprint sensor',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('Biometric authentication error: $e');
      return false; // Fallback to no authentication on error
    }
  }
  
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      return isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
}
```

### 3.1.3 Implement Real-Time Budget Update Service

**File**: `lib/features/budgets/data/services/budget_update_service_impl.dart`

```dart
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
      if (transaction.date.isAfter(budget.startDate.subtract(Duration(days: 1))) &&
          transaction.date.isBefore(budget.endDate.add(Duration(days: 1)))) {
        
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
  
  void dispose() {
    _budgetUpdatesController.close();
    _budgetSpentController.close();
  }
}
```

---

## Phase 3.2: Transaction Repository Integration (2 days)

### 3.2.1 Update Transaction Repository to Trigger Budget Updates

**File**: `lib/features/transactions/data/repositories/transaction_repository_impl.dart`

```dart
// Add budget update integration to existing methods

class TransactionRepositoryImpl implements TransactionRepository {
  // ...existing fields...
  final BudgetUpdateService? _budgetUpdateService;
  
  TransactionRepositoryImpl(
    this._database,
    // ...other dependencies...
    this._budgetUpdateService, // Add as optional dependency
  );
  
  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    // ...existing creation logic...
    
    // Trigger budget updates if service is available
    if (_budgetUpdateService != null) {
      await _budgetUpdateService!.updateBudgetOnTransactionChange(
        createdTransaction, 
        TransactionChangeType.created
      );
    }
    
    return createdTransaction;
  }
  
  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    // ...existing update logic...
    
    // Trigger budget updates if service is available
    if (_budgetUpdateService != null) {
      await _budgetUpdateService!.updateBudgetOnTransactionChange(
        updatedTransaction, 
        TransactionChangeType.updated
      );
    }
    
    return updatedTransaction;
  }
  
  @override
  Future<void> deleteTransaction(int id) async {
    // Get transaction before deletion for budget update
    final transaction = await getTransactionById(id);
    
    // ...existing deletion logic...
    
    // Trigger budget updates if service is available and transaction existed
    if (_budgetUpdateService != null && transaction != null) {
      await _budgetUpdateService!.updateBudgetOnTransactionChange(
        transaction, 
        TransactionChangeType.deleted
      );
    }
  }
  
  @override
  Future<void> insertOrUpdateFromSync(Transaction transaction) async {
    final existing = await getTransactionBySyncId(transaction.syncId);
    
    if (existing == null) {
      // Insert new transaction from sync
      await createTransaction(transaction);
    } else if (transaction.version > existing.version) {
      // Update with newer version
      await updateTransaction(transaction);
    }
  }
}
```

### 3.2.2 Update Dependency Injection

**File**: `lib/core/di/injection.dart`

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Add budget update service registration
@module
abstract class BudgetModule {
  
  @LazySingleton()
  BudgetAuthService get budgetAuthService => BudgetAuthService();
  
  @LazySingleton()
  BudgetCsvService get budgetCsvService => BudgetCsvService();
  
  @LazySingleton()
  BudgetFilterService get budgetFilterService => BudgetFilterServiceImpl(
    getIt<TransactionRepository>(),
    getIt<CurrencyService>(),
    getIt<BudgetCsvService>(),
  );
  
  @LazySingleton()
  BudgetUpdateService get budgetUpdateService => BudgetUpdateServiceImpl(
    getIt<BudgetRepository>(),
    getIt<BudgetFilterService>(),
    getIt<BudgetAuthService>(),
  );
}

// Update transaction module to include budget service
@module
abstract class TransactionModule {
  
  @LazySingleton()
  TransactionRepository get transactionRepository => TransactionRepositoryImpl(
    getIt<AppDatabase>(),
    // ...other dependencies...
    getIt<BudgetUpdateService>(), // Add budget update service
  );
}
```

---

## Phase 3.3: Enhanced BLoC Implementation

### 3.3.1 Update Budget BLoC Events

**File**: `lib/features/budgets/presentation/bloc/budgets_event.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';

abstract class BudgetsEvent extends Equatable {
  const BudgetsEvent();

  @override
  List<Object?> get props => [];
}

// Existing events...
class LoadAllBudgets extends BudgetsEvent {}
class CreateBudget extends BudgetsEvent {
  final Budget budget;
  const CreateBudget(this.budget);
  @override
  List<Object?> get props => [budget];
}

// New events for real-time updates
class StartRealTimeUpdates extends BudgetsEvent {}
class StopRealTimeUpdates extends BudgetsEvent {}
class BudgetRealTimeUpdateReceived extends BudgetsEvent {
  final List<Budget> budgets;
  const BudgetRealTimeUpdateReceived(this.budgets);
  @override
  List<Object?> get props => [budgets];
}

class BudgetSpentAmountUpdateReceived extends BudgetsEvent {
  final Map<int, double> spentAmounts;
  const BudgetSpentAmountUpdateReceived(this.spentAmounts);
  @override
  List<Object?> get props => [spentAmounts];
}

class AuthenticateForBudgetAccess extends BudgetsEvent {
  final int budgetId;
  const AuthenticateForBudgetAccess(this.budgetId);
  @override
  List<Object?> get props => [budgetId];
}

class RecalculateAllBudgets extends BudgetsEvent {}
class RecalculateBudget extends BudgetsEvent {
  final int budgetId;
  const RecalculateBudget(this.budgetId);
  @override
  List<Object?> get props => [budgetId];
}

class ExportBudgetData extends BudgetsEvent {
  final Budget budget;
  const ExportBudgetData(this.budget);
  @override
  List<Object?> get props => [budget];
}

class ExportMultipleBudgets extends BudgetsEvent {
  final List<Budget> budgets;
  const ExportMultipleBudgets(this.budgets);
  @override
  List<Object?> get props => [budgets];
}
```

### 3.3.2 Update Budget BLoC State

**File**: `lib/features/budgets/presentation/bloc/budgets_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';

abstract class BudgetsState extends Equatable {
  const BudgetsState();

  @override
  List<Object?> get props => [];
}

class BudgetsInitial extends BudgetsState {}

class BudgetsLoading extends BudgetsState {}

class BudgetsLoaded extends BudgetsState {
  final List<Budget> budgets;
  final Map<int, double> realTimeSpentAmounts;
  final bool isRealTimeActive;
  final Map<int, bool> authenticatedBudgets;
  final bool isExporting;
  final String? exportStatus;
  
  const BudgetsLoaded({
    required this.budgets,
    this.realTimeSpentAmounts = const {},
    this.isRealTimeActive = false,
    this.authenticatedBudgets = const {},
    this.isExporting = false,
    this.exportStatus,
  });

  BudgetsLoaded copyWith({
    List<Budget>? budgets,
    Map<int, double>? realTimeSpentAmounts,
    bool? isRealTimeActive,
    Map<int, bool>? authenticatedBudgets,
    bool? isExporting,
    String? exportStatus,
  }) {
    return BudgetsLoaded(
      budgets: budgets ?? this.budgets,
      realTimeSpentAmounts: realTimeSpentAmounts ?? this.realTimeSpentAmounts,
      isRealTimeActive: isRealTimeActive ?? this.isRealTimeActive,
      authenticatedBudgets: authenticatedBudgets ?? this.authenticatedBudgets,
      isExporting: isExporting ?? this.isExporting,
      exportStatus: exportStatus ?? this.exportStatus,
    );
  }

  @override
  List<Object?> get props => [
    budgets,
    realTimeSpentAmounts,
    isRealTimeActive,
    authenticatedBudgets,
    isExporting,
    exportStatus,
  ];
}

class BudgetsError extends BudgetsState {
  final String message;

  const BudgetsError(this.message);

  @override
  List<Object?> get props => [message];
}

class BudgetAuthenticationRequired extends BudgetsState {
  final int budgetId;

  const BudgetAuthenticationRequired(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}

class BudgetAuthenticationSuccess extends BudgetsState {
  final int budgetId;

  const BudgetAuthenticationSuccess(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}

class BudgetAuthenticationFailed extends BudgetsState {
  final int budgetId;
  final String reason;

  const BudgetAuthenticationFailed(this.budgetId, this.reason);

  @override
  List<Object?> get props => [budgetId, reason];
}
```

### 3.3.3 Enhanced Budget BLoC Implementation

**File**: `lib/features/budgets/presentation/bloc/budgets_bloc.dart`

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/budget_repository.dart';
import '../../domain/services/budget_update_service.dart';
import '../../domain/services/budget_filter_service.dart';
import 'budgets_event.dart';
import 'budgets_state.dart';

class BudgetsBloc extends Bloc<BudgetsEvent, BudgetsState> {
  final BudgetRepository _budgetRepository;
  final BudgetUpdateService _budgetUpdateService;
  final BudgetFilterService _budgetFilterService;
  
  StreamSubscription<List<Budget>>? _budgetUpdatesSubscription;
  StreamSubscription<Map<int, double>>? _spentAmountsSubscription;
  
  BudgetsBloc(
    this._budgetRepository,
    this._budgetUpdateService,
    this._budgetFilterService,
  ) : super(BudgetsInitial()) {
    on<LoadAllBudgets>(_onLoadAllBudgets);
    on<CreateBudget>(_onCreateBudget);
    on<StartRealTimeUpdates>(_onStartRealTimeUpdates);
    on<StopRealTimeUpdates>(_onStopRealTimeUpdates);
    on<BudgetRealTimeUpdateReceived>(_onBudgetRealTimeUpdateReceived);
    on<BudgetSpentAmountUpdateReceived>(_onBudgetSpentAmountUpdateReceived);
    on<AuthenticateForBudgetAccess>(_onAuthenticateForBudgetAccess);
    on<RecalculateAllBudgets>(_onRecalculateAllBudgets);
    on<RecalculateBudget>(_onRecalculateBudget);
    on<ExportBudgetData>(_onExportBudgetData);
    on<ExportMultipleBudgets>(_onExportMultipleBudgets);
  }
  
  Future<void> _onLoadAllBudgets(LoadAllBudgets event, Emitter<BudgetsState> emit) async {
    emit(BudgetsLoading());
    try {
      final budgets = await _budgetRepository.getAllBudgets();
      emit(BudgetsLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetsError('Failed to load budgets: $e'));
    }
  }
  
  Future<void> _onCreateBudget(CreateBudget event, Emitter<BudgetsState> emit) async {
    try {
      await _budgetRepository.createBudget(event.budget);
      add(LoadAllBudgets());
    } catch (e) {
      emit(BudgetsError('Failed to create budget: $e'));
    }
  }
  
  Future<void> _onStartRealTimeUpdates(StartRealTimeUpdates event, Emitter<BudgetsState> emit) async {
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;
      
      // Cancel existing subscriptions
      await _budgetUpdatesSubscription?.cancel();
      await _spentAmountsSubscription?.cancel();
      
      // Subscribe to real-time updates
      _budgetUpdatesSubscription = _budgetUpdateService.watchAllBudgetUpdates().listen(
        (budgets) => add(BudgetRealTimeUpdateReceived(budgets)),
      );
      
      _spentAmountsSubscription = _budgetUpdateService.watchBudgetSpentAmounts().listen(
        (spentAmounts) => add(BudgetSpentAmountUpdateReceived(spentAmounts)),
      );
      
      emit(currentState.copyWith(isRealTimeActive: true));
    }
  }
  
  Future<void> _onStopRealTimeUpdates(StopRealTimeUpdates event, Emitter<BudgetsState> emit) async {
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;
      
      // Cancel subscriptions
      await _budgetUpdatesSubscription?.cancel();
      await _spentAmountsSubscription?.cancel();
      
      emit(currentState.copyWith(isRealTimeActive: false));
    }
  }
  
  void _onBudgetRealTimeUpdateReceived(BudgetRealTimeUpdateReceived event, Emitter<BudgetsState> emit) {
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;
      emit(currentState.copyWith(budgets: event.budgets));
    }
  }
  
  void _onBudgetSpentAmountUpdateReceived(BudgetSpentAmountUpdateReceived event, Emitter<BudgetsState> emit) {
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;
      emit(currentState.copyWith(realTimeSpentAmounts: event.spentAmounts));
    }
  }
  
  Future<void> _onAuthenticateForBudgetAccess(AuthenticateForBudgetAccess event, Emitter<BudgetsState> emit) async {
    try {
      final isAuthenticated = await _budgetUpdateService.authenticateForBudgetAccess();
      
      if (isAuthenticated) {
        if (state is BudgetsLoaded) {
          final currentState = state as BudgetsLoaded;
          final updatedAuth = Map<int, bool>.from(currentState.authenticatedBudgets);
          updatedAuth[event.budgetId] = true;
          emit(currentState.copyWith(authenticatedBudgets: updatedAuth));
        }
        emit(BudgetAuthenticationSuccess(event.budgetId));
      } else {
        emit(BudgetAuthenticationFailed(event.budgetId, 'Authentication failed'));
      }
    } catch (e) {
      emit(BudgetAuthenticationFailed(event.budgetId, 'Authentication error: $e'));
    }
  }
  
  Future<void> _onRecalculateAllBudgets(RecalculateAllBudgets event, Emitter<BudgetsState> emit) async {
    try {
      await _budgetUpdateService.recalculateAllBudgetSpentAmounts();
      add(LoadAllBudgets());
    } catch (e) {
      emit(BudgetsError('Failed to recalculate budgets: $e'));
    }
  }
  
  Future<void> _onRecalculateBudget(RecalculateBudget event, Emitter<BudgetsState> emit) async {
    try {
      await _budgetUpdateService.recalculateBudgetSpentAmount(event.budgetId);
    } catch (e) {
      emit(BudgetsError('Failed to recalculate budget: $e'));
    }
  }
  
  Future<void> _onExportBudgetData(ExportBudgetData event, Emitter<BudgetsState> emit) async {
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;
      emit(currentState.copyWith(isExporting: true, exportStatus: 'Exporting budget data...'));
      
      try {
        await _budgetFilterService.exportBudgetData(event.budget, '');
        emit(currentState.copyWith(isExporting: false, exportStatus: 'Export completed successfully'));
      } catch (e) {
        emit(currentState.copyWith(isExporting: false, exportStatus: 'Export failed: $e'));
      }
    }
  }
  
  Future<void> _onExportMultipleBudgets(ExportMultipleBudgets event, Emitter<BudgetsState> emit) async {
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;
      emit(currentState.copyWith(isExporting: true, exportStatus: 'Exporting ${event.budgets.length} budgets...'));
      
      try {
        await _budgetFilterService.exportMultipleBudgets(event.budgets);
        emit(currentState.copyWith(isExporting: false, exportStatus: 'Export completed successfully'));
      } catch (e) {
        emit(currentState.copyWith(isExporting: false, exportStatus: 'Export failed: $e'));
      }
    }
  }
  
  @override
  Future<void> close() {
    _budgetUpdatesSubscription?.cancel();
    _spentAmountsSubscription?.cancel();
    return super.close();
  }
}
```

---

## Testing Phase 3

### 3.1 Unit Tests for Real-Time Updates

**File**: `test/features/budgets/budget_update_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('Budget Update Service Tests', () {
    late BudgetUpdateService budgetUpdateService;
    late MockBudgetRepository mockBudgetRepository;
    late MockBudgetFilterService mockFilterService;
    late MockBudgetAuthService mockAuthService;
    
    setUp(() {
      mockBudgetRepository = MockBudgetRepository();
      mockFilterService = MockBudgetFilterService();
      mockAuthService = MockBudgetAuthService();
      
      budgetUpdateService = BudgetUpdateServiceImpl(
        mockBudgetRepository,
        mockFilterService,
        mockAuthService,
      );
    });
    
    test('should update budget when transaction is created', () async {
      // Test real-time budget update logic
    });
    
    test('should emit real-time updates through stream', () async {
      // Test stream functionality
    });
    
    test('should authenticate for biometric access', () async {
      // Test biometric authentication
    });
    
    test('should handle performance tracking', () async {
      // Test performance monitoring
    });
  });
}
```

### 3.2 Integration Tests

**File**: `test/integration/real_time_budget_integration_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Real-Time Budget Integration Tests', () {
    testWidgets('complete real-time update flow', (tester) async {
      // Test complete flow:
      // 1. Create budget
      // 2. Enable real-time updates
      // 3. Create transaction
      // 4. Verify budget updates in real-time
      // 5. Test authentication flow
    });
    
    testWidgets('biometric authentication flow', (tester) async {
      // Test biometric authentication integration
    });
    
    testWidgets('performance under load', (tester) async {
      // Test performance with many rapid updates
    });
  });
}
```

---

## Success Criteria for Phase 3

### Phase 3.1 Complete When:
- [ ] Budget update service fully functional
- [ ] Real-time streams working correctly
- [ ] Biometric authentication implemented
- [ ] Performance tracking operational
- [ ] Unit tests passing with >90% coverage

### Phase 3.2 Complete When:
- [ ] Transaction repository integrated with budget updates
- [ ] Dependency injection configured
- [ ] BLoC events and states updated
- [ ] Real-time UI updates working
- [ ] Integration tests passing

---

## Performance Considerations

### Optimization Strategies
1. **Debouncing**: Prevent too frequent updates
2. **Batching**: Group multiple transaction changes
3. **Caching**: Cache budget calculations
4. **Lazy Loading**: Load budget details on demand

### Memory Management
- Proper stream disposal
- Limited retention of historical data
- Efficient data structures for real-time updates

---

## Next Steps

Upon completion of Phase 3, proceed to:
- **Phase 4**: UI Integration & Enhanced Features
- **Phase 5**: Testing & Documentation

This phase establishes real-time responsiveness and secure access to budget information while maintaining high performance standards.
