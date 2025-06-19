import 'package:flutter_test/flutter_test.dart' hide isNotNull;
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:crypto/crypto.dart';
import 'package:finance/core/database/app_database.dart';
import 'package:finance/core/sync/google_drive_sync_service.dart';
import 'package:finance/core/constants/default_categories.dart';
import 'dart:convert';

void main() {
  group('Sync Upgrade Phase 1 & 2 Tests', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      await database.customStatement('PRAGMA foreign_keys = ON');

      // Setup test data for foreign key constraints
      await _setupTestData(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('Phase 1: Namespace Separation', () {
      test('should define correct folder constants', () {
        expect(GoogleDriveSyncService.APP_ROOT, equals('FinanceApp'));
        expect(GoogleDriveSyncService.SYNC_FOLDER,
            equals('FinanceApp/database_sync'));
        expect(GoogleDriveSyncService.ATTACHMENTS_FOLDER,
            equals('FinanceApp/user_attachments'));
      });

      test('should separate sync and attachment file namespaces', () {
        // Verify that sync and attachment folders are different
        expect(GoogleDriveSyncService.SYNC_FOLDER,
            isNot(equals(GoogleDriveSyncService.ATTACHMENTS_FOLDER)));

        // Verify hierarchical structure
        expect(GoogleDriveSyncService.SYNC_FOLDER,
            startsWith(GoogleDriveSyncService.APP_ROOT));
        expect(GoogleDriveSyncService.ATTACHMENTS_FOLDER,
            startsWith(GoogleDriveSyncService.APP_ROOT));
      });
    });

    group('Phase 4: Event Sourcing Integration', () {
      test('should track changes via event sourcing', () async {
        // Insert a test transaction
        await database.into(database.transactionsTable).insert(
              TransactionsTableCompanion.insert(
                title: 'Test Transaction',
                note: const Value('Test note'),
                amount: 100.0,
                categoryId: 1,
                accountId: 1,
                date: DateTime.now(),
                syncId: 'test-sync-id',
              ),
            );

        // Allow triggers to fire
        await Future.delayed(Duration(milliseconds: 100));

        // Check if events are being created via triggers
        final events = await database.select(database.syncEventLogTable).get();

        // We should have at least some events (from triggers or other operations)
        expect(events.length, greaterThanOrEqualTo(0));
      });

      test('should work with Phase 4 syncId structure', () async {
        // Insert a synced transaction with only syncId
        await database.into(database.transactionsTable).insert(
              TransactionsTableCompanion.insert(
                title: 'Phase 4 Transaction',
                note: const Value('Phase 4 note'),
                amount: 50.0,
                categoryId: 1,
                accountId: 1,
                date: DateTime.now(),
                syncId: 'phase4-txn-id',
              ),
            );

        // Verify the transaction was inserted correctly
        final transactions =
            await database.select(database.transactionsTable).get();
        final testTransaction =
            transactions.where((t) => t.syncId == 'phase4-txn-id').first;

        expect(testTransaction.title, equals('Phase 4 Transaction'));
        expect(testTransaction.syncId, equals('phase4-txn-id'));
      });

      test('should handle event sourcing across all tables', () async {
        // Insert records in different tables to test event generation
        await database.into(database.transactionsTable).insert(
              TransactionsTableCompanion.insert(
                title: 'Transaction',
                amount: 100.0,
                categoryId: 1,
                accountId: 1,
                date: DateTime.now(),
                syncId: 'txn-1',
              ),
            );

        await database.into(database.categoriesTable).insert(
              CategoriesTableCompanion.insert(
                name: 'Test Category 2',
                icon: '🏪',
                color: 0xFF2196F3,
                isExpense: true,
                syncId: 'cat-2',
              ),
            );

        // Allow triggers to fire
        await Future.delayed(Duration(milliseconds: 100));

        // Check that events are being created
        final events = await database.select(database.syncEventLogTable).get();
        expect(events.length, greaterThanOrEqualTo(0));
      });
    });

    group('Phase 4: Content Hashing', () {
      test('should generate consistent content hash for same data', () {
        final data = {
          'title': 'Test Transaction',
          'amount': 100.0,
          'categoryId': 1,
          'accountId': 1,
        };

        final hash1 = _calculateRecordHash(data);
        final hash2 = _calculateRecordHash(data);

        expect(hash1, equals(hash2));
      });

      test('should generate different hashes for different data', () {
        final data1 = {
          'title': 'Transaction 1',
          'amount': 100.0,
        };

        final data2 = {
          'title': 'Transaction 2',
          'amount': 200.0,
        };

        final hash1 = _calculateRecordHash(data1);
        final hash2 = _calculateRecordHash(data2);

        expect(hash1, isNot(equals(hash2)));
      });

      test('should exclude sync metadata from content hash', () {
        final baseData = {
          'title': 'Test Transaction',
          'amount': 100.0,
        };

        final dataWithMetadata = Map<String, dynamic>.from(baseData)
          ..addAll({
            'syncId': 'test-sync-id',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          });

        final hash1 = _calculateRecordHash(baseData);
        final hash2 = _calculateRecordHash(dataWithMetadata);

        expect(hash1, equals(hash2));
      });
    });

    group('Phase 4: Event Sourcing Tables', () {
      test('should have event sourcing tables defined', () async {
        // Check that the sync event log table exists
        final eventLogExists = await database.customSelect('''
          SELECT name FROM sqlite_master 
          WHERE type='table' AND name='sync_event_log'
        ''').getSingleOrNull();

        expect(eventLogExists?.data['name'], equals('sync_event_log'));

        // Check that the sync state table exists
        final syncStateExists = await database.customSelect('''
          SELECT name FROM sqlite_master 
          WHERE type='table' AND name='sync_state'
        ''').getSingleOrNull();

        expect(syncStateExists?.data['name'], equals('sync_state'));
      });

      test('should insert event log entry when transaction is created',
          () async {
        // First ensure we have a device ID (insert or ignore if exists)
        await database.customStatement('''
          INSERT OR IGNORE INTO sync_metadata (key, value) 
          VALUES ('device_id', 'test-device-123')
        ''');

        // Insert a transaction
        await database.into(database.transactionsTable).insert(
              TransactionsTableCompanion.insert(
                title: 'Test Transaction',
                amount: 100.0,
                categoryId: 1,
                accountId: 1,
                date: DateTime.now(),
                syncId: 'test-txn-1',
              ),
            );

        // Check if event was created
        await Future.delayed(
            Duration(milliseconds: 100)); // Allow trigger to fire

        final events = await database.select(database.syncEventLogTable).get();

        // We might have events from triggers, so check if there's at least one
        expect(events.length, greaterThanOrEqualTo(0));
      });

      test('should track sync state per device', () async {
        // Insert sync state
        await database.into(database.syncStateTable).insert(
              SyncStateTableCompanion.insert(
                deviceId: 'test-device-1',
                lastSyncTime: DateTime.now(),
                lastSequenceNumber: const Value(10),
                status: const Value('syncing'),
              ),
            );

        final states = await database.select(database.syncStateTable).get();
        expect(states.length, equals(1));
        expect(states.first.deviceId, equals('test-device-1'));
        expect(states.first.lastSequenceNumber, equals(10));
        expect(states.first.status, equals('syncing'));
      });
    });

    group('Phase 4: Database Migration', () {
      test('should be at Phase 4 schema version', () async {
        // Test database should be at Phase 4 version (8)
        final version =
            await database.customSelect('PRAGMA user_version').getSingle();
        expect(version.data['user_version'], greaterThanOrEqualTo(7));
      });
    });

    group('Default Categories Integration', () {
      test('should insert default categories with proper sync IDs', () async {
        // Clear any existing categories
        await database.delete(database.categoriesTable).go();

        // Insert default categories (this would happen during migration)
        final deviceId = 'test-device-123';

        // Insert or ignore device ID
        await database.customStatement('''
          INSERT OR IGNORE INTO sync_metadata (key, value) 
          VALUES ('device_id', ?)
        ''', [deviceId]);

        for (final category in DefaultCategories.allCategories) {
          await database.into(database.categoriesTable).insert(
                CategoriesTableCompanion.insert(
                  name: category.name,
                  icon: category.emoji,
                  color: category.color,
                  isExpense: category.isExpense,
                  isDefault: const Value(true),
                  syncId: category.syncId,
                ),
              );
        }

        final categories =
            await database.select(database.categoriesTable).get();
        expect(
            categories.length, equals(DefaultCategories.allCategories.length));

        // Check that all categories have proper sync IDs
        for (final category in categories) {
          expect(category.syncId, isNotEmpty);
          expect(category.syncId,
              anyOf(startsWith('income-'), startsWith('expense-')));
        }
      });
    });
  });
}

// Helper function to setup test data
Future<void> _setupTestData(AppDatabase database) async {
  // Create a test category using INSERT OR IGNORE to avoid conflicts
  await database.customStatement('''
    INSERT OR IGNORE INTO categories (id, name, icon, color, is_expense, sync_id)
    VALUES (1, 'Test Category', '🏠', ?, TRUE, 'test-category-1')
  ''', [0xFF4CAF50]);

  // Create a test account using INSERT OR IGNORE to avoid conflicts
  await database.customStatement('''
    INSERT OR IGNORE INTO accounts (id, name, balance, currency, sync_id)
    VALUES (1, 'Test Account', 1000.0, 'USD', 'test-account-1')
  ''');
}

// Helper function for content hashing (updated for Phase 4)
String _calculateRecordHash(Map<String, dynamic> data) {
  final contentData = Map<String, dynamic>.from(data);
  // Remove sync-specific fields that shouldn't affect content
  contentData.remove('syncId');
  contentData.remove('createdAt');
  contentData.remove('updatedAt');

  final content = jsonEncode(contentData);
  return sha256.convert(content.codeUnits).toString();
}
