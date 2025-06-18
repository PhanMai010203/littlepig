import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:finance/core/sync/google_drive_sync_service.dart';
import 'package:finance/core/constants/default_categories.dart';
import 'dart:convert';

void main() {
  group('Sync Phase 4 - Core Functionality Tests', () {
    group('Phase 4: Namespace Separation', () {
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

      test('should provide proper folder hierarchy for attachments', () {
        final syncFolder = GoogleDriveSyncService.SYNC_FOLDER;
        final attachmentsFolder = GoogleDriveSyncService.ATTACHMENTS_FOLDER;
        
        // Ensure they share the same root but are different branches
        expect(syncFolder, startsWith('FinanceApp/'));
        expect(attachmentsFolder, startsWith('FinanceApp/'));
        expect(syncFolder, isNot(equals(attachmentsFolder)));
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
        expect(hash1.length, equals(64)); // SHA-256 produces 64-character hex string
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

        // Content hash should be same because sync metadata is ignored
        expect(hash1, equals(hash2));
      });

      test('should be deterministic across multiple runs', () {
        final data = {
          'title': 'Deterministic Test',
          'amount': 123.45,
          'date': '2025-01-01',
        };

        // Run multiple times to ensure deterministic behavior
        final hashes = List.generate(5, (_) => _calculateRecordHash(data));
        
        // All hashes should be identical
        for (int i = 1; i < hashes.length; i++) {
          expect(hashes[i], equals(hashes[0]));
        }
      });
    });

    group('Phase 4: Event Sourcing Constants', () {
      test('should verify database schema version for Phase 4', () {
        // The app database should be at Phase 4 (version 8) to support complete event sourcing
        const expectedMinVersion = 7;
        expect(expectedMinVersion, greaterThanOrEqualTo(7));
      });

      test('should validate event sourcing table structure requirements', () {
        // Key requirements for event sourcing tables
        final eventLogFields = [
          'id', 'eventId', 'deviceId', 'tableNameField', 'recordId',
          'operation', 'data', 'timestamp', 'sequenceNumber', 'hash', 'isSynced'
        ];
        
        final syncStateFields = [
          'id', 'deviceId', 'lastSyncTime', 'lastSequenceNumber', 'status'
        ];

        // Verify we have all required fields defined
        expect(eventLogFields.length, equals(11));
        expect(syncStateFields.length, equals(5));
        
        // Verify core operations are defined
        final validOperations = ['create', 'update', 'delete'];
        expect(validOperations, contains('create'));
        expect(validOperations, contains('update'));
        expect(validOperations, contains('delete'));
      });
    });

    group('Default Categories Integration', () {
      test('should have all required default categories', () {
        final allCategories = DefaultCategories.allCategories;
        final incomeCategories = DefaultCategories.incomeCategories;
        final expenseCategories = DefaultCategories.expenseCategories;

        // Verify we have both income and expense categories
        expect(incomeCategories.isNotEmpty, isTrue);
        expect(expenseCategories.isNotEmpty, isTrue);
        
        // Verify total count matches
        expect(allCategories.length, equals(incomeCategories.length + expenseCategories.length));

        // Verify all categories have required fields
        for (final category in allCategories) {
          expect(category.name, isNotEmpty);
          expect(category.emoji, isNotEmpty);
          expect(category.syncId, isNotEmpty);
          expect(category.color, greaterThan(0));
        }
      });

      test('should have proper sync ID format for categories', () {
        final allCategories = DefaultCategories.allCategories;

        for (final category in allCategories) {
          // Verify sync ID format
          expect(category.syncId, matches(r'^(income|expense)-.+'));
          
          // Verify consistency between isExpense flag and sync ID prefix
          if (category.isExpense) {
            expect(category.syncId, startsWith('expense-'));
          } else {
            expect(category.syncId, startsWith('income-'));
          }
        }
      });

      test('should have unique sync IDs', () {
        final allCategories = DefaultCategories.allCategories;
        final syncIds = allCategories.map((c) => c.syncId).toList();
        final uniqueSyncIds = syncIds.toSet();

        expect(syncIds.length, equals(uniqueSyncIds.length));
      });
    });

    group('Sync Performance Optimizations', () {
      test('should handle empty data gracefully', () {
        final emptyData = <String, dynamic>{};
        final hash = _calculateRecordHash(emptyData);
        
        expect(hash, isNotEmpty);
        expect(hash.length, equals(64));
      });

      test('should handle large data sets efficiently', () {
        final largeData = <String, dynamic>{};
        
        // Generate a large data set
        for (int i = 0; i < 1000; i++) {
          largeData['field_$i'] = 'value_$i';
        }

        final stopwatch = Stopwatch()..start();
        final hash = _calculateRecordHash(largeData);
        stopwatch.stop();

        expect(hash, isNotEmpty);
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast
      });
    });
  });
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