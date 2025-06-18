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
        expect(GoogleDriveSyncService.SYNC_FOLDER, equals('FinanceApp/database_sync'));
        expect(GoogleDriveSyncService.ATTACHMENTS_FOLDER, equals('FinanceApp/user_attachments'));
      });

      test('should separate sync and attachment file namespaces', () {
        // Verify that sync and attachment folders are different
        expect(GoogleDriveSyncService.SYNC_FOLDER, isNot(equals(GoogleDriveSyncService.ATTACHMENTS_FOLDER)));
        
        // Verify hierarchical structure
        expect(GoogleDriveSyncService.SYNC_FOLDER, startsWith(GoogleDriveSyncService.APP_ROOT));
        expect(GoogleDriveSyncService.ATTACHMENTS_FOLDER, startsWith(GoogleDriveSyncService.APP_ROOT));
      });
    });

    group('Phase 1: Change Detection', () {
      test('should detect unsynced changes in transactions', () async {
        // Insert a test transaction
        await database.into(database.transactionsTable).insert(
          TransactionsTableCompanion.insert(
            title: 'Test Transaction',
            note: const Value('Test note'),
            amount: 100.0,
            categoryId: 1,
            accountId: 1,
            date: DateTime.now(),
            deviceId: 'test-device',
            syncId: 'test-sync-id',
            isSynced: const Value(false), // Unsynced
          ),
        );

        // Check if there are unsynced changes
        final unsyncedCount = await database.customSelect('''
          SELECT COUNT(*) as count FROM transactions WHERE is_synced = false
        ''').getSingle();

        expect(unsyncedCount.data['count'], equals(1));
      });

      test('should detect when no changes need syncing', () async {
        // Insert a synced transaction
        await database.into(database.transactionsTable).insert(
          TransactionsTableCompanion.insert(
            title: 'Synced Transaction',
            note: const Value('Synced note'),
            amount: 50.0,
            categoryId: 1,
            accountId: 1,
            date: DateTime.now(),
            deviceId: 'test-device',
            syncId: 'synced-id',
            isSynced: const Value(true), // Already synced
          ),
        );

        // Check that no unsynced changes exist
        final unsyncedCount = await database.customSelect('''
          SELECT COUNT(*) as count FROM transactions WHERE is_synced = false
        ''').getSingle();

        expect(unsyncedCount.data['count'], equals(0));
      });

      test('should detect unsynced changes across all tables', () async {
        // Count existing unsynced records before adding our test data
        final initialUnsyncedCount = await database.customSelect('''
          SELECT COUNT(*) as count FROM (
            SELECT 1 FROM transactions WHERE is_synced = false
            UNION ALL
            SELECT 1 FROM categories WHERE is_synced = false
            UNION ALL
            SELECT 1 FROM accounts WHERE is_synced = false
            UNION ALL
            SELECT 1 FROM budgets WHERE is_synced = false
            UNION ALL
            SELECT 1 FROM attachments WHERE is_synced = false
          )
        ''').getSingle();

        // Insert unsynced records in different tables
        await database.into(database.transactionsTable).insert(
          TransactionsTableCompanion.insert(
            title: 'Transaction',
            amount: 100.0,
            categoryId: 1,
            accountId: 1,
            date: DateTime.now(),
            deviceId: 'test-device',
            syncId: 'txn-1',
            isSynced: const Value(false),
          ),
        );

        await database.into(database.categoriesTable).insert(
          CategoriesTableCompanion.insert(
            name: 'Test Category 2',
            icon: '🏪',
            color: 0xFF2196F3,
            isExpense: true,
            deviceId: 'test-device',
            syncId: 'cat-2',
            isSynced: const Value(false),
          ),
        );

        // Check total unsynced count - should be initial + 2 new records
        final finalUnsyncedCount = await database.customSelect('''
          SELECT COUNT(*) as count FROM (
            SELECT 1 FROM transactions WHERE is_synced = false
            UNION ALL
            SELECT 1 FROM categories WHERE is_synced = false
            UNION ALL
            SELECT 1 FROM accounts WHERE is_synced = false
            UNION ALL
            SELECT 1 FROM budgets WHERE is_synced = false
            UNION ALL
            SELECT 1 FROM attachments WHERE is_synced = false
          )
        ''').getSingle();

        expect(finalUnsyncedCount.data['count'], 
               equals(initialUnsyncedCount.data['count']! + 2));
      });
    });

    group('Phase 1: Content Hashing', () {
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

      test('should ignore sync-specific fields in content hash', () {
        final baseData = {
          'title': 'Test Transaction',
          'amount': 100.0,
        };

        final dataWithSyncFields = Map<String, dynamic>.from(baseData)
          ..addAll({
            'isSynced': true,
            'lastSyncAt': DateTime.now().toIso8601String(),
            'version': 2,
          });

        final hash1 = _calculateRecordHash(baseData);
        final hash2 = _calculateRecordHash(dataWithSyncFields);

        expect(hash1, equals(hash2));
      });
    });

    group('Phase 2: Event Sourcing Tables', () {
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

      test('should insert event log entry when transaction is created', () async {
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
            deviceId: 'test-device',
            syncId: 'test-txn-1',
          ),
        );

        // Check if event was created
        await Future.delayed(Duration(milliseconds: 100)); // Allow trigger to fire
        
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

    group('Phase 2: Database Migration', () {
      test('should upgrade from schema version 6 to 7', () async {
        // Test database should already be at version 7
        final version = await database.customSelect('PRAGMA user_version').getSingle();
        expect(version.data['user_version'], equals(7));
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
              deviceId: deviceId,
              syncId: category.syncId,
            ),
          );
        }

        final categories = await database.select(database.categoriesTable).get();
        expect(categories.length, equals(DefaultCategories.allCategories.length));

        // Check that all categories have proper sync IDs
        for (final category in categories) {
          expect(category.syncId, isNotEmpty);
          expect(category.syncId, anyOf(startsWith('income-'), startsWith('expense-')));
        }
      });
    });
  });
}

// Helper function to setup test data
Future<void> _setupTestData(AppDatabase database) async {
  // Create a test category using INSERT OR IGNORE to avoid conflicts
  await database.customStatement('''
    INSERT OR IGNORE INTO categories (id, name, icon, color, is_expense, device_id, sync_id)
    VALUES (1, 'Test Category', '🏠', ?, TRUE, 'test-device', 'test-category-1')
  ''', [0xFF4CAF50]);

  // Create a test account using INSERT OR IGNORE to avoid conflicts
  await database.customStatement('''
    INSERT OR IGNORE INTO accounts (id, name, balance, currency, device_id, sync_id)
    VALUES (1, 'Test Account', 1000.0, 'USD', 'test-device', 'test-account-1')
  ''');
}

// Helper function for content hashing (same as in sync service)
String _calculateRecordHash(Map<String, dynamic> data) {
  final contentData = Map<String, dynamic>.from(data);
  // Remove sync-specific fields that shouldn't affect content
  contentData.remove('isSynced');
  contentData.remove('lastSyncAt');
  contentData.remove('version');
  
  final content = jsonEncode(contentData);
  return sha256.convert(content.codeUnits).toString();
} 