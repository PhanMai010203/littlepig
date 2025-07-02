import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:finance/features/budgets/presentation/bloc/budgets_bloc.dart';
import 'package:finance/features/budgets/presentation/bloc/budgets_event.dart';
import 'package:finance/features/budgets/presentation/bloc/budgets_state.dart';
import 'package:finance/features/budgets/domain/repositories/budget_repository.dart';
import 'package:finance/features/budgets/domain/services/budget_update_service.dart';
import 'package:finance/features/budgets/domain/services/budget_filter_service.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';
import 'package:finance/features/categories/domain/repositories/category_repository.dart';
import 'package:finance/features/accounts/domain/entities/account.dart';
import 'package:finance/features/categories/domain/entities/category.dart';
import 'package:finance/features/budgets/domain/entities/budget_enums.dart';
import 'package:flutter/material.dart';

// Generate mocks
@GenerateMocks([
  BudgetRepository,
  BudgetUpdateService,
  BudgetFilterService,
  AccountRepository,
  CategoryRepository,
])
import 'budget_creation_bloc_test.mocks.dart';

void main() {
  group('BudgetsBloc Budget Creation Tests', () {
    late BudgetsBloc budgetsBloc;
    late MockBudgetRepository mockBudgetRepository;
    late MockBudgetUpdateService mockBudgetUpdateService;
    late MockBudgetFilterService mockBudgetFilterService;
    late MockAccountRepository mockAccountRepository;
    late MockCategoryRepository mockCategoryRepository;

    setUp(() {
      mockBudgetRepository = MockBudgetRepository();
      mockBudgetUpdateService = MockBudgetUpdateService();
      mockBudgetFilterService = MockBudgetFilterService();
      mockAccountRepository = MockAccountRepository();
      mockCategoryRepository = MockCategoryRepository();

      budgetsBloc = BudgetsBloc(
        mockBudgetRepository,
        mockBudgetUpdateService,
        mockBudgetFilterService,
        mockAccountRepository,
        mockCategoryRepository,
      );
    });

    tearDown(() {
      budgetsBloc.close();
    });

    test('initial state is BudgetsInitial', () {
      expect(budgetsBloc.state, isA<BudgetsInitial>());
    });

    group('BudgetTrackingTypeChanged Event', () {
      test('emits BudgetCreationState with manual tracking type', () {
        // Act
        budgetsBloc.add(const BudgetTrackingTypeChanged(BudgetTrackingType.manual));

        // Assert
        expectLater(
          budgetsBloc.stream,
          emits(
            isA<BudgetCreationState>()
                .having((state) => state.trackingType, 'trackingType', BudgetTrackingType.manual),
          ),
        );
      });

      test('emits BudgetCreationState with automatic tracking type', () {
        // Act
        budgetsBloc.add(const BudgetTrackingTypeChanged(BudgetTrackingType.automatic));

        // Assert
        expectLater(
          budgetsBloc.stream,
          emits(
            isA<BudgetCreationState>()
                .having((state) => state.trackingType, 'trackingType', BudgetTrackingType.automatic),
          ),
        );
      });

      test('updates existing BudgetCreationState', () async {
        // First set initial state
        budgetsBloc.add(const BudgetTrackingTypeChanged(BudgetTrackingType.automatic));
        await expectLater(
          budgetsBloc.stream,
          emits(isA<BudgetCreationState>()),
        );

        // Then change tracking type
        budgetsBloc.add(const BudgetTrackingTypeChanged(BudgetTrackingType.manual));
        await expectLater(
          budgetsBloc.stream,
          emits(
            isA<BudgetCreationState>()
                .having((state) => state.trackingType, 'trackingType', BudgetTrackingType.manual),
          ),
        );
      });
    });

    group('LoadAccountsForBudget Event', () {
      test('loads accounts successfully', () async {
        // Arrange
        final mockAccounts = [
          Account(
            id: 1,
            name: 'Checking',
            balance: 1000.0,
            currency: 'USD',
            isDefault: true,
            color: Colors.blue,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncId: 'account-1',
          ),
          Account(
            id: 2,
            name: 'Savings',
            balance: 5000.0,
            currency: 'USD',
            isDefault: false,
            color: Colors.green,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncId: 'account-2',
          ),
        ];

        when(mockAccountRepository.getAllAccounts()).thenAnswer((_) async => mockAccounts);

        // Act
        budgetsBloc.add(LoadAccountsForBudget());

        // Assert
        await expectLater(
          budgetsBloc.stream,
          emitsInOrder([
            // Loading state
            isA<BudgetCreationState>()
                .having((state) => state.isAccountsLoading, 'isAccountsLoading', true),
            // Loaded state
            isA<BudgetCreationState>()
                .having((state) => state.isAccountsLoading, 'isAccountsLoading', false)
                .having((state) => state.availableAccounts.length, 'availableAccounts.length', 2),
          ]),
        );

        verify(mockAccountRepository.getAllAccounts()).called(1);
      });

      test('handles loading accounts error', () async {
        // Arrange
        when(mockAccountRepository.getAllAccounts()).thenThrow(Exception('Failed to load accounts'));

        // Act
        budgetsBloc.add(LoadAccountsForBudget());

        // Assert
        await expectLater(
          budgetsBloc.stream,
          emitsInOrder([
            // Loading state
            isA<BudgetCreationState>()
                .having((state) => state.isAccountsLoading, 'isAccountsLoading', true),
            // Error handled - loading false, empty accounts
            isA<BudgetCreationState>()
                .having((state) => state.isAccountsLoading, 'isAccountsLoading', false)
                .having((state) => state.availableAccounts.length, 'availableAccounts.length', 0),
          ]),
        );
      });
    });

    group('LoadCategoriesForBudget Event', () {
      test('loads categories successfully', () async {
        // Arrange
        final mockCategories = [
          Category(
            id: 1,
            name: 'Food',
            icon: '🍔',
            color: Colors.orange,
            isExpense: true,
            isDefault: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncId: 'category-1',
          ),
          Category(
            id: 2,
            name: 'Transport',
            icon: '🚗',
            color: Colors.blue,
            isExpense: true,
            isDefault: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncId: 'category-2',
          ),
        ];

        when(mockCategoryRepository.getExpenseCategories()).thenAnswer((_) async => mockCategories);

        // Act
        budgetsBloc.add(LoadCategoriesForBudget());

        // Assert
        await expectLater(
          budgetsBloc.stream,
          emitsInOrder([
            // Loading state
            isA<BudgetCreationState>()
                .having((state) => state.isCategoriesLoading, 'isCategoriesLoading', true),
            // Loaded state
            isA<BudgetCreationState>()
                .having((state) => state.isCategoriesLoading, 'isCategoriesLoading', false)
                .having((state) => state.availableCategories.length, 'availableCategories.length', 2),
          ]),
        );

        verify(mockCategoryRepository.getExpenseCategories()).called(1);
      });
    });

    group('Account Selection Events', () {
      test('BudgetAccountsSelected updates selected accounts', () {
        // Arrange
        final mockAccounts = [
          Account(
            id: 1,
            name: 'Test Account',
            balance: 100.0,
            currency: 'USD',
            isDefault: true,
            color: Colors.blue,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncId: 'account-1',
          ),
        ];

        // First set up creation state
        budgetsBloc.add(const BudgetTrackingTypeChanged(BudgetTrackingType.automatic));

        // Act
        budgetsBloc.add(BudgetAccountsSelected(mockAccounts, false));

        // Assert
        expectLater(
          budgetsBloc.stream,
          emitsThrough(
            isA<BudgetCreationState>()
                .having((state) => state.selectedAccounts.length, 'selectedAccounts.length', 1)
                .having((state) => state.isAllAccountsSelected, 'isAllAccountsSelected', false),
          ),
        );
      });

      test('BudgetAccountsSelected with isAllSelected true', () {
        // First set up creation state
        budgetsBloc.add(const BudgetTrackingTypeChanged(BudgetTrackingType.automatic));

        // Act
        budgetsBloc.add(const BudgetAccountsSelected([], true));

        // Assert
        expectLater(
          budgetsBloc.stream,
          emitsThrough(
            isA<BudgetCreationState>()
                .having((state) => state.selectedAccounts.length, 'selectedAccounts.length', 0)
                .having((state) => state.isAllAccountsSelected, 'isAllAccountsSelected', true),
          ),
        );
      });
    });

    group('Category Selection Events', () {
      test('BudgetIncludeCategoriesSelected updates included categories', () {
        // Arrange
        final mockCategories = [
          Category(
            id: 1,
            name: 'Food',
            icon: '🍔',
            color: Colors.orange,
            isExpense: true,
            isDefault: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncId: 'category-1',
          ),
        ];

        // First set up creation state
        budgetsBloc.add(const BudgetTrackingTypeChanged(BudgetTrackingType.automatic));

        // Act
        budgetsBloc.add(BudgetIncludeCategoriesSelected(mockCategories, false));

        // Assert
        expectLater(
          budgetsBloc.stream,
          emitsThrough(
            isA<BudgetCreationState>()
                .having((state) => state.includedCategories.length, 'includedCategories.length', 1)
                .having((state) => state.isAllCategoriesIncluded, 'isAllCategoriesIncluded', false),
          ),
        );
      });

      test('BudgetExcludeCategoriesSelected updates excluded categories', () {
        // Arrange
        final mockCategories = [
          Category(
            id: 2,
            name: 'Entertainment',
            icon: '🎬',
            color: Colors.purple,
            isExpense: true,
            isDefault: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncId: 'category-2',
          ),
        ];

        // First set up creation state
        budgetsBloc.add(const BudgetTrackingTypeChanged(BudgetTrackingType.automatic));

        // Act
        budgetsBloc.add(BudgetExcludeCategoriesSelected(mockCategories));

        // Assert
        expectLater(
          budgetsBloc.stream,
          emitsThrough(
            isA<BudgetCreationState>()
                .having((state) => state.excludedCategories.length, 'excludedCategories.length', 1),
          ),
        );
      });
    });

    group('BudgetCreationState Helper Properties', () {
      test('shouldShowAccountsSelector returns correct value', () {
        // Test automatic mode
        const automaticState = BudgetCreationState(trackingType: BudgetTrackingType.automatic);
        expect(automaticState.shouldShowAccountsSelector, isTrue);

        // Test manual mode
        const manualState = BudgetCreationState(trackingType: BudgetTrackingType.manual);
        expect(manualState.shouldShowAccountsSelector, isFalse);
      });

      test('shouldReduceIncludeCategoriesOpacity returns correct value', () {
        // Test with excluded categories
        final excludedCategories = [
          Category(
            id: 1,
            name: 'Test',
            icon: '🧪',
            color: Colors.red,
            isExpense: true,
            isDefault: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncId: 'test-1',
          ),
        ];

        final stateWithExcluded = BudgetCreationState(excludedCategories: excludedCategories);
        expect(stateWithExcluded.shouldReduceIncludeCategoriesOpacity, isTrue);

        // Test without excluded categories
        const stateWithoutExcluded = BudgetCreationState(excludedCategories: []);
        expect(stateWithoutExcluded.shouldReduceIncludeCategoriesOpacity, isFalse);
      });
    });
  });
}