import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide isNotNull;

import 'entity_builders.dart';
import 'event_sourcing_helpers.dart';
import 'test_database_setup.dart';
import 'package:finance/core/database/app_database.dart';

/// ✅ PHASE 4.3: Test Infrastructure Verification
///
/// Comprehensive tests to verify all Phase 4.3 test infrastructure helpers
/// work correctly and provide clean, reliable testing foundation.
void main() {
  group('Phase 4.3: Test Infrastructure Tests', () {
    group('TestEntityBuilders', () {
      test('should create test transaction with default values', () {
        final transaction = TestEntityBuilders.createTestTransaction();

        expect(transaction.title, equals('Test Transaction'));
        expect(transaction.amount, equals(100.0));
        expect(transaction.categoryId, equals(1));
        expect(transaction.accountId, equals(1));
        expect(transaction.syncId, isNotNull);
        expect(transaction.syncId, startsWith('test-txn-'));
        expect(transaction.date, isNotNull);
        expect(transaction.createdAt, isNotNull);
        expect(transaction.updatedAt, isNotNull);
      });

      test('should create test transaction with custom values', () {
        final customDate = DateTime(2024, 1, 15);
        final transaction = TestEntityBuilders.createTestTransaction(
          syncId: 'custom-sync-id',
          title: 'Custom Transaction',
          amount: 250.0,
          categoryId: 5,
          accountId: 2,
          date: customDate,
          note: 'Test note',
        );

        expect(transaction.syncId, equals('custom-sync-id'));
        expect(transaction.title, equals('Custom Transaction'));
        expect(transaction.amount, equals(250.0));
        expect(transaction.categoryId, equals(5));
        expect(transaction.accountId, equals(2));
        expect(transaction.date, equals(customDate));
        expect(transaction.note, equals('Test note'));
      });

      test('should create test subscription transaction', () {
        final subscription = TestEntityBuilders.createTestSubscription();

        expect(subscription.title, equals('Test Subscription'));
        expect(subscription.amount, equals(-9.99));
        expect(subscription.isSubscription, isTrue);
        expect(subscription.isRecurring, isTrue);
        expect(subscription.isScheduled, isTrue);
        expect(subscription.syncId, startsWith('test-sub-'));
      });

      test('should create test account with default values', () {
        final account = TestEntityBuilders.createTestAccount();

        expect(account.name, equals('Test Account'));
        expect(account.balance, equals(1000.0));
        expect(account.currency, equals('USD'));
        expect(account.isDefault, isFalse);
        expect(account.syncId, startsWith('test-acc-'));
      });

      test('should create test budget with default values', () {
        final budget = TestEntityBuilders.createTestBudget();

        expect(budget.name, equals('Test Budget'));
        expect(budget.amount, equals(500.0));
        expect(budget.spent, equals(100.0));
        expect(budget.remaining, equals(400.0));
        expect(budget.percentageSpent, equals(0.2));
        expect(budget.isOverBudget, isFalse);
        expect(budget.syncId, startsWith('test-budget-'));
      });

      test('should create test category with default values', () {
        final category = TestEntityBuilders.createTestCategory();

        expect(category.name, equals('Test Category'));
        expect(category.icon, equals('shopping_cart'));
        expect(category.color, equals(Colors.blue));
        expect(category.isExpense, isTrue);
        expect(category.isDefault, isFalse);
        expect(category.syncId, startsWith('test-cat-'));
      });

      test('should create test attachment with default values', () {
        final attachment = TestEntityBuilders.createTestAttachment();

        expect(attachment.transactionId, equals(1));
        expect(attachment.fileName, equals('test_image.jpg'));
        expect(attachment.isImage, isTrue);
        expect(attachment.isUploaded, isTrue);
        expect(attachment.isDeleted, isFalse);
        expect(attachment.syncId, startsWith('test-att-'));
      });

      test('should create transaction batch with correct count', () {
        final transactions =
            TestEntityBuilders.createTestTransactionBatch(count: 3);

        expect(transactions.length, equals(3));

        for (int i = 0; i < transactions.length; i++) {
          expect(transactions[i].title, equals('Transaction $i'));
          expect(transactions[i].amount, equals(100.0 + (i * 10)));
          expect(transactions[i].syncId, isNotNull);
        }
      });

      test('should create account batch with first account as default', () {
        final accounts = TestEntityBuilders.createTestAccountBatch(count: 3);

        expect(accounts.length, equals(3));
        expect(accounts[0].isDefault, isTrue);
        expect(accounts[1].isDefault, isFalse);
        expect(accounts[2].isDefault, isFalse);

        for (int i = 0; i < accounts.length; i++) {
          expect(accounts[i].name, equals('Account $i'));
          expect(accounts[i].balance, equals(1000.0 + (i * 500)));
        }
      });

      test('should create default test categories with correct types', () {
        final categories = TestEntityBuilders.createDefaultTestCategories();

        expect(categories.length, equals(3));

        final salaryCategory = categories.firstWhere((c) => c.name == 'Salary');
        expect(salaryCategory.isExpense, isFalse);
        expect(salaryCategory.isDefault, isTrue);
        expect(salaryCategory.syncId, equals('test-cat-income-salary'));

        final foodCategory = categories.firstWhere((c) => c.name == 'Food');
        expect(foodCategory.isExpense, isTrue);
        expect(foodCategory.isDefault, isTrue);
        expect(foodCategory.syncId, equals('test-cat-expense-food'));
      });

      test('should create complete test scenario with all entity types', () {
        final scenario = TestEntityBuilders.createCompleteTestScenario();

        expect(scenario['accounts'], isNotNull);
        expect(scenario['categories'], isNotNull);
        expect(scenario['transactions'], isNotNull);

        final accounts = scenario['accounts'] as List;
        final categories = scenario['categories'] as List;
        final transactions = scenario['transactions'] as List;

        expect(accounts.length, equals(2));
        expect(categories.length, equals(3));
        expect(transactions.length, equals(3));
      });
    });

    group('EventSourcingTestHelpers', () {
      test('should create test sync event', () {
        final event = EventSourcingTestHelpers.createSyncEvent(
          operation: 'create',
          tableName: 'transactions',
          recordId: 'test-txn-1',
          data: {'title': 'Test Transaction', 'amount': 100.0},
        );

        expect(event.operation, equals('create'));
        expect(event.tableName, equals('transactions'));
        expect(event.recordId, equals('test-txn-1'));
        expect(event.data['title'], equals('Test Transaction'));
        expect(event.data['amount'], equals(100.0));
        expect(event.deviceId, equals('test-device'));
        expect(event.sequenceNumber, equals(1));
        expect(event.hash, isNotNull);
      });

      test('should create conflicting events for CRDT testing', () {
        final events = EventSourcingTestHelpers.createConflictingEvents(
          recordId: 'test-record-1',
          tableName: 'transactions',
          deviceIds: ['device1', 'device2', 'device3'],
        );

        expect(events.length, equals(3));

        for (int i = 0; i < events.length; i++) {
          expect(events[i].recordId, equals('test-record-1'));
          expect(events[i].tableName, equals('transactions'));
          expect(events[i].operation, equals('update'));
          expect(events[i].deviceId, equals('device${i + 1}'));
          expect(events[i].sequenceNumber, equals(i + 1));
        }
      });

      test('should create transaction lifecycle events', () {
        final events =
            EventSourcingTestHelpers.createTransactionLifecycleEvents(
          syncId: 'test-txn-lifecycle',
        );

        expect(events.length, equals(3));

        // Create event
        expect(events[0].operation, equals('create'));
        expect(events[0].data['title'], equals('Test Transaction'));
        expect(events[0].data['amount'], equals(100.0));

        // Update event
        expect(events[1].operation, equals('update'));
        expect(events[1].data['title'], equals('Updated Transaction'));
        expect(events[1].data['amount'], equals(150.0));

        // Delete event
        expect(events[2].operation, equals('delete'));
        expect(events[2].data['sync_id'], equals('test-txn-lifecycle'));
      });

      test('should create multi-table events in correct order', () {
        final events = EventSourcingTestHelpers.createMultiTableEvents();

        expect(events.length, equals(4));

        // Account first
        expect(events[0].tableName, equals('accounts'));
        expect(events[0].sequenceNumber, equals(1));

        // Category second
        expect(events[1].tableName, equals('categories'));
        expect(events[1].sequenceNumber, equals(2));

        // Transaction third (depends on account and category)
        expect(events[2].tableName, equals('transactions'));
        expect(events[2].sequenceNumber, equals(3));

        // Budget fourth
        expect(events[3].tableName, equals('budgets'));
        expect(events[3].sequenceNumber, equals(4));
      });

      test('should create test event batch', () {
        final batch = EventSourcingTestHelpers.createTestEventBatch(
          deviceId: 'test-device-batch',
        );

        expect(batch.deviceId, equals('test-device-batch'));
        expect(batch.events, isNotEmpty);
        expect(batch.timestamp, isNotNull);

        // Test batch methods
        final eventsByTable = batch.eventsByTable;
        expect(eventsByTable.keys, contains('accounts'));
        expect(eventsByTable.keys, contains('categories'));
        expect(eventsByTable.keys, contains('transactions'));
        expect(eventsByTable.keys, contains('budgets'));

        final eventsByRecord = batch.eventsByRecord;
        expect(eventsByRecord.keys, contains('accounts:test-acc-1'));
        expect(eventsByRecord.keys, contains('categories:test-cat-1'));
        expect(eventsByRecord.keys, contains('transactions:test-txn-1'));
        expect(eventsByRecord.keys, contains('budgets:test-budget-1'));

        expect(batch.hasConflicts, isFalse);
      });

      test('should detect conflicts in event batch', () {
        final conflictingEvents = [
          EventSourcingTestHelpers.createSyncEvent(
            operation: 'update',
            tableName: 'transactions',
            recordId: 'same-record',
            deviceId: 'device1',
          ),
          EventSourcingTestHelpers.createSyncEvent(
            operation: 'update',
            tableName: 'transactions',
            recordId: 'same-record',
            deviceId: 'device2',
          ),
        ];

        final batch = SyncEventBatch(
          deviceId: 'test-device',
          timestamp: DateTime.now(),
          events: conflictingEvents,
        );

        expect(batch.hasConflicts, isTrue);

        final eventsByRecord = batch.eventsByRecord;
        expect(eventsByRecord['transactions:same-record']!.length, equals(2));
      });

      test('should create large event batch for performance testing', () {
        final events = EventSourcingTestHelpers.createLargeEventBatch(
          count: 100,
          tableName: 'transactions',
        );

        expect(events.length, equals(100));

        for (int i = 0; i < events.length; i++) {
          expect(events[i].operation, equals('create'));
          expect(events[i].tableName, equals('transactions'));
          expect(events[i].recordId, equals('test-record-$i'));
          expect(events[i].sequenceNumber, equals(i + 1));
          expect(events[i].data['title'], equals('Test Transaction $i'));
          expect(events[i].data['amount'], equals(i * 10.0));
        }
      });
    });

    group('TestDatabaseSetup', () {
      test('should create clean test database', () async {
        final database = await TestDatabaseSetup.createCleanTestDatabase();

        try {
          // Verify Phase 4 compliance
          await TestDatabaseSetup.verifyPhase4Compliance(database);

          // Verify test data integrity
          await TestDatabaseSetup.verifyTestDataIntegrity(database);

          // Verify categories were inserted
          final categories =
              await database.select(database.categoriesTable).get();
          expect(categories.length, greaterThanOrEqualTo(2));

          // Verify default account was inserted
          final accounts = await database.select(database.accountsTable).get();
          expect(accounts.length, greaterThanOrEqualTo(1));
          final defaultAccount = accounts.where((a) => a.isDefault).firstOrNull;
          expect(defaultAccount, isNotNull);
        } finally {
          await TestDatabaseSetup.cleanupTestDatabase(database);
        }
      });

      test('should create populated test database', () async {
        final database = await TestDatabaseSetup.createPopulatedTestDatabase();

        try {
          // Verify all data was inserted
          final categories =
              await database.select(database.categoriesTable).get();
          final accounts = await database.select(database.accountsTable).get();
          final budgets = await database.select(database.budgetsTable).get();
          final transactions =
              await database.select(database.transactionsTable).get();

          expect(categories.length,
              greaterThanOrEqualTo(6)); // 2 default + 4 additional
          expect(accounts.length,
              greaterThanOrEqualTo(4)); // 1 default + 3 additional
          expect(budgets.length, greaterThanOrEqualTo(3));
          expect(transactions.length, greaterThanOrEqualTo(5));
        } finally {
          await TestDatabaseSetup.cleanupTestDatabase(database);
        }
      });

      test('should verify Phase 4 table structure', () async {
        final database = await TestDatabaseSetup.createCleanTestDatabase();

        try {
          await TestDatabaseSetup.verifyPhase4TableStructure(database);

          // Additional manual verification
          final tables = [
            'transactions',
            'accounts',
            'categories',
            'budgets',
            'attachments'
          ];

          for (final tableName in tables) {
            final tableInfo = await database
                .customSelect("PRAGMA table_info($tableName)")
                .get();

            final columns =
                tableInfo.map((row) => row.data['name'] as String).toList();

            // Should have syncId
            expect(columns, contains('sync_id'));

            // Should NOT have legacy sync fields
            expect(columns, isNot(contains('device_id')));
            expect(columns, isNot(contains('is_synced')));
            expect(columns, isNot(contains('last_sync_at')));
            expect(columns, isNot(contains('version')));
          }
        } finally {
          await TestDatabaseSetup.cleanupTestDatabase(database);
        }
      });

      test('should verify event sourcing triggers exist', () async {
        final database = await TestDatabaseSetup.createCleanTestDatabase();

        try {
          await TestDatabaseSetup.verifyEventSourcingTriggers(database);

          // Verify triggers actually work by inserting test data
          final now = DateTime.now();
          await database.into(database.transactionsTable).insert(
                TransactionsTableCompanion.insert(
                  title: 'Trigger Test Transaction',
                  amount: 100.0,
                  categoryId: 1,
                  accountId: 1,
                  date: now,
                  syncId: 'trigger-test-txn',
                ),
              );

          // Wait for triggers to fire
          await TestDatabaseSetup.waitForTriggers();

          // Verify event was created
          final events =
              await database.select(database.syncEventLogTable).get();
          expect(events, isNotEmpty);

          final createEvent = events
              .where((e) =>
                  e.tableNameField == 'transactions' &&
                  e.recordId == 'trigger-test-txn' &&
                  e.operation == 'create')
              .firstOrNull;

          expect(createEvent, isNotNull);
        } finally {
          await TestDatabaseSetup.cleanupTestDatabase(database);
        }
      });

      test('should setup test device metadata', () async {
        final database = await TestDatabaseSetup.createCleanTestDatabase();

        try {
          await TestDatabaseSetup.setupTestDeviceMetadata(
            database,
            deviceId: 'test-device-123',
          );

          // Verify device ID was inserted
          final deviceIdRow = await (database.select(database.syncMetadataTable)
                ..where((t) => t.key.equals('device_id')))
              .getSingleOrNull();

          expect(deviceIdRow, isNotNull);
          expect(deviceIdRow!.value, equals('test-device-123'));

          // Verify last sync time was inserted
          final lastSyncRow = await (database.select(database.syncMetadataTable)
                ..where((t) => t.key.equals('last_sync_time')))
              .getSingleOrNull();

          expect(lastSyncRow, isNotNull);
          expect(lastSyncRow!.value, isNotNull);
        } finally {
          await TestDatabaseSetup.cleanupTestDatabase(database);
        }
      });

      test('should create minimal test database', () async {
        final database = await TestDatabaseSetup.createMinimalTestDatabase();

        try {
          // Verify schema version
          final version =
              await database.customSelect('PRAGMA user_version').getSingle();
          expect(version.data['user_version'], greaterThanOrEqualTo(8));

          // Verify event sourcing tables exist (but no test data)
          final eventTableInfo = await database
              .customSelect("PRAGMA table_info(sync_event_log)")
              .get();
          expect(eventTableInfo.isNotEmpty, true);

          final stateTableInfo = await database
              .customSelect("PRAGMA table_info(sync_state)")
              .get();
          expect(stateTableInfo.isNotEmpty, true);

          // Should have no test data
          final categories =
              await database.select(database.categoriesTable).get();
          expect(categories, isEmpty);
        } finally {
          await TestDatabaseSetup.cleanupTestDatabase(database);
        }
      });
    });

    group('Integration Tests', () {
      test('should work together: entities, events, and database', () async {
        final database = await TestDatabaseSetup.createCleanTestDatabase();

        try {
          // Create test entities using TestEntityBuilders
          final transaction = TestEntityBuilders.createTestTransaction(
            syncId: 'integration-test-txn',
            title: 'Integration Test Transaction',
            amount: 150.0,
          );

          final account = TestEntityBuilders.createTestAccount(
            syncId: 'integration-test-acc',
            name: 'Integration Test Account',
          );

          // Insert entities into database
          await database.into(database.transactionsTable).insert(
                TransactionsTableCompanion.insert(
                  title: transaction.title,
                  amount: transaction.amount,
                  categoryId: transaction.categoryId,
                  accountId: transaction.accountId,
                  date: transaction.date,
                  syncId: transaction.syncId,
                ),
              );

          await database.into(database.accountsTable).insert(
                AccountsTableCompanion.insert(
                  name: account.name,
                  balance: Value(account.balance),
                  currency: Value(account.currency),
                  isDefault: Value(account.isDefault),
                  createdAt: Value(account.createdAt),
                  updatedAt: Value(account.updatedAt),
                  syncId: account.syncId,
                ),
              );

          // Wait for triggers
          await TestDatabaseSetup.waitForTriggers();

          // Verify events were created using EventSourcingTestHelpers
          final isTransactionEventCreated =
              await EventSourcingTestHelpers.validateTriggersCreatedEvents(
            database,
            tableName: 'transactions',
            operation: 'create',
            recordId: transaction.syncId,
          );
          expect(isTransactionEventCreated, isTrue);

          final isAccountEventCreated =
              await EventSourcingTestHelpers.validateTriggersCreatedEvents(
            database,
            tableName: 'accounts',
            operation: 'create',
            recordId: account.syncId,
          );
          expect(isAccountEventCreated, isTrue);

          // Get unsynced events
          final unsyncedEvents =
              await EventSourcingTestHelpers.getUnsyncedEvents(database);
          expect(unsyncedEvents.length, greaterThanOrEqualTo(2));

          // Cleanup test events
          await EventSourcingTestHelpers.cleanupTestEvents(database);

          final eventsAfterCleanup =
              await database.select(database.syncEventLogTable).get();
          expect(eventsAfterCleanup, isEmpty);
        } finally {
          await TestDatabaseSetup.cleanupTestDatabase(database);
        }
      });
    });
  });
}
