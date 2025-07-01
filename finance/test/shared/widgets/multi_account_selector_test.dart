import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:finance/shared/widgets/multi_account_selector.dart';
import 'package:finance/features/accounts/domain/entities/account.dart';
import '../../helpers/localization_test_wrapper.dart';

void main() {
  group('MultiAccountSelector Widget Tests', () {
    late List<Account> mockAccounts;
    late List<Account> selectedAccounts;
    late bool isAllSelected;
    late ValueChanged<List<Account>> mockOnSelectionChanged;
    late VoidCallback mockOnAllSelected;

    setUp(() {
      mockAccounts = [
        Account(
          id: 1,
          name: 'Checking Account',
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
          name: 'Savings Account', 
          balance: 5000.0,
          currency: 'USD',
          isDefault: false,
          color: Colors.green,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'account-2',
        ),
        Account(
          id: 3,
          name: 'Credit Card',
          balance: -500.0,
          currency: 'USD',
          isDefault: false,
          color: Colors.red,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'account-3',
        ),
      ];
      
      selectedAccounts = [];
      isAllSelected = true;
      mockOnSelectionChanged = (selectedAccounts) {};
      mockOnAllSelected = () {};
    });

    testWidgets('displays title and all accounts selection correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EasyLocalization(
            supportedLocales: const [Locale('en')],
            path: 'assets/translations',
            fallbackLocale: const Locale('en'),
            assetLoader: const FakeAssetLoader(),
            child: Scaffold(
              body: MultiAccountSelector(
                title: 'Select Accounts',
                availableAccounts: mockAccounts,
                selectedAccounts: selectedAccounts,
                isAllSelected: isAllSelected,
                onSelectionChanged: mockOnSelectionChanged,
                onAllSelected: mockOnAllSelected,
              ),
            ),
          ),
        ),
      );

      // Verify title is displayed
      expect(find.text('Select Accounts'), findsOneWidget);
      
      // Verify "All accounts" summary is shown when all selected
      expect(find.textContaining('all'), findsOneWidget);
    });

    testWidgets('displays selected account count when specific accounts selected', (tester) async {
      selectedAccounts = [mockAccounts[0], mockAccounts[1]];
      isAllSelected = false;

      await tester.pumpWidget(
        LocalizationTestWrapper(
          child: MultiAccountSelector(
            title: 'Select Accounts',
            availableAccounts: mockAccounts,
            selectedAccounts: selectedAccounts,
            isAllSelected: isAllSelected,
            onSelectionChanged: mockOnSelectionChanged,
            onAllSelected: mockOnAllSelected,
          ),
        ),
      );

      // Should show "2 accounts selected"
      expect(find.textContaining('2'), findsOneWidget);
    });

    testWidgets('displays single account name when one account selected', (tester) async {
      selectedAccounts = [mockAccounts[0]];
      isAllSelected = false;

      await tester.pumpWidget(
        LocalizationTestWrapper(
          child: MultiAccountSelector(
            title: 'Select Accounts',
            availableAccounts: mockAccounts,
            selectedAccounts: selectedAccounts,
            isAllSelected: isAllSelected,
            onSelectionChanged: mockOnSelectionChanged,
            onAllSelected: mockOnAllSelected,
          ),
        ),
      );

      // Should show the account name
      expect(find.text('Checking Account'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        LocalizationTestWrapper(
          child: MultiAccountSelector(
            title: 'Select Accounts',
            availableAccounts: mockAccounts,
            selectedAccounts: selectedAccounts,
            isAllSelected: isAllSelected,
            onSelectionChanged: mockOnSelectionChanged,
            onAllSelected: mockOnAllSelected,
            isLoading: true,
          ),
        ),
      );

      // Should show loading indicator instead of chevron
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('opens selection modal when tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocalizationTestWrapper(
              child: MultiAccountSelector(
                title: 'Select Accounts',
                availableAccounts: mockAccounts,
                selectedAccounts: selectedAccounts,
                isAllSelected: isAllSelected,
                onSelectionChanged: mockOnSelectionChanged,
                onAllSelected: mockOnAllSelected,
              ),
            ),
          ),
        ),
      );

      // Tap on the selector
      await tester.tap(find.byType(MultiAccountSelector));
      await tester.pumpAndSettle();

      // Modal should be opened with "All Accounts" option
      expect(find.textContaining('All'), findsAtLeastNWidget(1));
      
      // Should show all available accounts
      expect(find.text('Checking Account'), findsOneWidget);
      expect(find.text('Savings Account'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
    });

    testWidgets('modal shows account colors and currencies', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocalizationTestWrapper(
              child: MultiAccountSelector(
                title: 'Select Accounts',
                availableAccounts: mockAccounts,
                selectedAccounts: selectedAccounts,
                isAllSelected: isAllSelected,
                onSelectionChanged: mockOnSelectionChanged,
                onAllSelected: mockOnAllSelected,
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.byType(MultiAccountSelector));
      await tester.pumpAndSettle();

      // Should show currency info for accounts
      expect(find.text('USD'), findsAtLeastNWidget(1));
      
      // Should show color indicators (Container widgets with account colors)
      final containers = find.byType(Container);
      expect(containers, findsAtLeastNWidget(1));
    });

    testWidgets('does not open modal when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocalizationTestWrapper(
              child: MultiAccountSelector(
                title: 'Select Accounts',
                availableAccounts: mockAccounts,
                selectedAccounts: selectedAccounts,
                isAllSelected: isAllSelected,
                onSelectionChanged: mockOnSelectionChanged,
                onAllSelected: mockOnAllSelected,
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      // Try to tap when loading
      await tester.tap(find.byType(MultiAccountSelector));
      await tester.pumpAndSettle();

      // Modal should not open - we shouldn't find Save/Cancel buttons
      expect(find.text('Save'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    });
  });

  group('MultiAccountSelector Integration Tests', () {
    testWidgets('calls onAllSelected when All Accounts is selected', (tester) async {
      bool allSelectedCalled = false;
      List<Account> changedSelection = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocalizationTestWrapper(
              child: MultiAccountSelector(
                title: 'Select Accounts',
                availableAccounts: [
                  Account(
                    id: 1,
                    name: 'Test Account',
                    balance: 100.0,
                    currency: 'USD',
                    isDefault: true,
                    color: Colors.blue,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    syncId: 'test-1',
                  ),
                ],
                selectedAccounts: [],
                isAllSelected: false,
                onSelectionChanged: (accounts) => changedSelection = accounts,
                onAllSelected: () => allSelectedCalled = true,
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.byType(MultiAccountSelector));
      await tester.pumpAndSettle();

      // Tap "All Accounts" checkbox
      final allAccountsCheckbox = find.byType(CheckboxListTile).first;
      await tester.tap(allAccountsCheckbox);
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify onAllSelected was called
      expect(allSelectedCalled, isTrue);
    });

    testWidgets('calls onSelectionChanged when individual accounts are selected', (tester) async {
      List<Account> changedSelection = [];
      final testAccount = Account(
        id: 1,
        name: 'Test Account',
        balance: 100.0,
        currency: 'USD',
        isDefault: true,
        color: Colors.blue,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'test-1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocalizationTestWrapper(
              child: MultiAccountSelector(
                title: 'Select Accounts',
                availableAccounts: [testAccount],
                selectedAccounts: [],
                isAllSelected: true,
                onSelectionChanged: (accounts) => changedSelection = accounts,
                onAllSelected: () {},
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.byType(MultiAccountSelector));
      await tester.pumpAndSettle();

      // Uncheck "All Accounts" first
      final allAccountsCheckbox = find.byType(CheckboxListTile).first;
      await tester.tap(allAccountsCheckbox);
      await tester.pumpAndSettle();

      // Check individual account
      final accountCheckboxes = find.byType(CheckboxListTile);
      await tester.tap(accountCheckboxes.at(1)); // Second checkbox (first account)
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify onSelectionChanged was called with the account
      expect(changedSelection.length, equals(1));
      expect(changedSelection.first.id, equals(testAccount.id));
    });
  });
}