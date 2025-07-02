import 'package:flutter_test/flutter_test.dart';
import 'package:finance/features/budgets/domain/entities/budget_enums.dart';
import 'package:finance/features/budgets/presentation/bloc/budgets_state.dart';
import 'package:finance/features/categories/domain/entities/category.dart';
import 'package:flutter/material.dart';

void main() {
  group('BudgetCreationState Tests', () {
    test('initializes with correct default values', () {
      const state = BudgetCreationState();
      
      expect(state.trackingType, equals(BudgetTrackingType.automatic));
      expect(state.availableAccounts, isEmpty);
      expect(state.selectedAccounts, isEmpty);
      expect(state.isAllAccountsSelected, isTrue);
      expect(state.availableCategories, isEmpty);
      expect(state.includedCategories, isEmpty);
      expect(state.isAllCategoriesIncluded, isTrue);
      expect(state.excludedCategories, isEmpty);
      expect(state.isAccountsLoading, isFalse);
      expect(state.isCategoriesLoading, isFalse);
    });

    test('copyWith updates specific fields correctly', () {
      const initialState = BudgetCreationState();
      
      final updatedState = initialState.copyWith(
        trackingType: BudgetTrackingType.manual,
        isAccountsLoading: true,
        isAllAccountsSelected: false,
      );
      
      expect(updatedState.trackingType, equals(BudgetTrackingType.manual));
      expect(updatedState.isAccountsLoading, isTrue);
      expect(updatedState.isAllAccountsSelected, isFalse);
      
      // Unchanged fields should remain the same
      expect(updatedState.availableAccounts, isEmpty);
      expect(updatedState.selectedAccounts, isEmpty);
      expect(updatedState.isAllCategoriesIncluded, isTrue);
    });

    test('shouldShowAccountsSelector returns correct value based on tracking type', () {
      const automaticState = BudgetCreationState(
        trackingType: BudgetTrackingType.automatic,
      );
      expect(automaticState.shouldShowAccountsSelector, isTrue);
      
      const manualState = BudgetCreationState(
        trackingType: BudgetTrackingType.manual,
      );
      expect(manualState.shouldShowAccountsSelector, isFalse);
    });

    test('shouldReduceIncludeCategoriesOpacity returns correct value', () {
      // Test with no excluded categories
      const stateWithoutExcluded = BudgetCreationState(
        excludedCategories: [],
      );
      expect(stateWithoutExcluded.shouldReduceIncludeCategoriesOpacity, isFalse);
      
      // Test with excluded categories
      final excludedCategory = Category(
        id: 1,
        name: 'Entertainment',
        icon: '🎬',
        color: Colors.purple,
        isExpense: true,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'category-1',
      );
      
      final stateWithExcluded = BudgetCreationState(
        excludedCategories: [excludedCategory],
      );
      expect(stateWithExcluded.shouldReduceIncludeCategoriesOpacity, isTrue);
    });

    test('equality works correctly', () {
      const state1 = BudgetCreationState(
        trackingType: BudgetTrackingType.manual,
        isAllAccountsSelected: false,
      );
      
      const state2 = BudgetCreationState(
        trackingType: BudgetTrackingType.manual,
        isAllAccountsSelected: false,
      );
      
      const state3 = BudgetCreationState(
        trackingType: BudgetTrackingType.automatic,
        isAllAccountsSelected: false,
      );
      
      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('props includes all fields for equality comparison', () {
      final category1 = Category(
        id: 1,
        name: 'Food',
        icon: '🍔',
        color: Colors.orange,
        isExpense: true,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'category-1',
      );
      
      final category2 = Category(
        id: 2,
        name: 'Transport',
        icon: '🚗',
        color: Colors.blue,
        isExpense: true,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'category-2',
      );
      
      final state1 = BudgetCreationState(
        trackingType: BudgetTrackingType.automatic,
        includedCategories: [category1],
        excludedCategories: [category2],
        isAccountsLoading: true,
        isCategoriesLoading: false,
      );
      
      final state2 = BudgetCreationState(
        trackingType: BudgetTrackingType.automatic,
        includedCategories: [category1],
        excludedCategories: [category2],
        isAccountsLoading: true,
        isCategoriesLoading: false,
      );
      
      expect(state1, equals(state2));
      
      // Change one field and verify inequality
      final state3 = state1.copyWith(isAccountsLoading: false);
      expect(state1, isNot(equals(state3)));
    });
  });

  group('BudgetTrackingType Tests', () {
    test('enum values have correct getters', () {
      expect(BudgetTrackingType.manual.isManual, isTrue);
      expect(BudgetTrackingType.manual.isAutomatic, isFalse);
      
      expect(BudgetTrackingType.automatic.isManual, isFalse);
      expect(BudgetTrackingType.automatic.isAutomatic, isTrue);
    });

    test('enum has expected values', () {
      expect(BudgetTrackingType.values.length, equals(2));
      expect(BudgetTrackingType.values, contains(BudgetTrackingType.manual));
      expect(BudgetTrackingType.values, contains(BudgetTrackingType.automatic));
    });
  });
}