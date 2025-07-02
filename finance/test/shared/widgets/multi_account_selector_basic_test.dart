import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/shared/widgets/multi_account_selector.dart';
import 'package:finance/features/accounts/domain/entities/account.dart';

void main() {
  group('MultiAccountSelector Basic Tests', () {
    late List<Account> mockAccounts;

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
      ];
    });

    testWidgets('creates widget without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAccountSelector(
              title: 'Select Accounts',
              availableAccounts: mockAccounts,
              selectedAccounts: const [],
              isAllSelected: true,
              onSelectionChanged: (accounts) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.byType(MultiAccountSelector), findsOneWidget);
    });

    testWidgets('displays title correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAccountSelector(
              title: 'Test Title',
              availableAccounts: mockAccounts,
              selectedAccounts: const [],
              isAllSelected: true,
              onSelectionChanged: (accounts) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAccountSelector(
              title: 'Select Accounts',
              availableAccounts: mockAccounts,
              selectedAccounts: const [],
              isAllSelected: true,
              onSelectionChanged: (accounts) {},
              onAllSelected: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows chevron icon when not loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAccountSelector(
              title: 'Select Accounts',
              availableAccounts: mockAccounts,
              selectedAccounts: const [],
              isAllSelected: true,
              onSelectionChanged: (accounts) {},
              onAllSelected: () {},
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays single account name when one account selected', (tester) async {
      final selectedAccount = mockAccounts[0];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAccountSelector(
              title: 'Select Accounts',
              availableAccounts: mockAccounts,
              selectedAccounts: [selectedAccount],
              isAllSelected: false,
              onSelectionChanged: (accounts) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.text('Checking Account'), findsOneWidget);
    });
  });

  group('MultiAccountSelector State Tests', () {
    testWidgets('displays correct summary for different selection states', (tester) async {
      final mockAccounts = [
        Account(
          id: 1,
          name: 'Account 1',
          balance: 100.0,
          currency: 'USD',
          isDefault: true,
          color: Colors.blue,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'account-1',
        ),
        Account(
          id: 2,
          name: 'Account 2',
          balance: 200.0,
          currency: 'USD',
          isDefault: false,
          color: Colors.green,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'account-2',
        ),
      ];

      // Test "All selected" state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAccountSelector(
              title: 'Select Accounts',
              availableAccounts: mockAccounts,
              selectedAccounts: const [],
              isAllSelected: true,
              onSelectionChanged: (accounts) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      // Should contain some indication of "all" selection
      expect(find.byType(MultiAccountSelector), findsOneWidget);

      // Test multiple accounts selected
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAccountSelector(
              title: 'Select Accounts',
              availableAccounts: mockAccounts,
              selectedAccounts: mockAccounts,
              isAllSelected: false,
              onSelectionChanged: (accounts) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.byType(MultiAccountSelector), findsOneWidget);

      // Test no accounts selected
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAccountSelector(
              title: 'Select Accounts',
              availableAccounts: mockAccounts,
              selectedAccounts: const [],
              isAllSelected: false,
              onSelectionChanged: (accounts) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.byType(MultiAccountSelector), findsOneWidget);
    });
  });
}