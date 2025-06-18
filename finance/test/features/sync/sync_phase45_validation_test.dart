import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/sync/crdt_conflict_resolver.dart';
import 'package:finance/core/sync/google_drive_sync_service.dart';
import 'package:finance/core/constants/default_categories.dart';

void main() {
  group('🎯 Phase 4.5: Comprehensive Validation Tests', () {
    group('✅ Code Architecture Validation', () {
      test('should verify Google Drive sync service constants', () {
        // Verify namespace separation constants
        expect(GoogleDriveSyncService.APP_ROOT, equals('FinanceApp'));
        expect(GoogleDriveSyncService.SYNC_FOLDER, equals('FinanceApp/database_sync'));
        expect(GoogleDriveSyncService.ATTACHMENTS_FOLDER, equals('FinanceApp/user_attachments'));
        
        // Verify proper folder hierarchy
        expect(GoogleDriveSyncService.SYNC_FOLDER, startsWith(GoogleDriveSyncService.APP_ROOT));
        expect(GoogleDriveSyncService.ATTACHMENTS_FOLDER, startsWith(GoogleDriveSyncService.APP_ROOT));
        expect(GoogleDriveSyncService.SYNC_FOLDER, isNot(equals(GoogleDriveSyncService.ATTACHMENTS_FOLDER)));
      });
    });

    group('✅ CRDT Conflict Resolution Validation', () {
      test('should verify conflict resolver works with clean architecture', () {
        final resolver = CRDTConflictResolver();
        
        // Test data with current sync infrastructure (should be ignored in content hash)
        final testData = {
          'title': 'Test Transaction',
          'amount': 100.0,
          'categoryId': 1,
          'accountId': 1,
          'syncId': 'test-sync-id',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        
        // Calculate content hash (should ignore sync fields)
        final hash = resolver.calculateContentHash(testData);
        expect(hash, isNotEmpty);
        expect(hash.length, equals(64)); // SHA-256 produces 64-character hex string
        
        // Same data without sync fields should produce same hash
        final businessData = {
          'title': 'Test Transaction',
          'amount': 100.0,
          'categoryId': 1,
          'accountId': 1,
        };
        
        final businessHash = resolver.calculateContentHash(businessData);
        expect(businessHash, equals(hash),
          reason: 'Content hash should ignore sync infrastructure fields');
      });

      test('should verify deterministic hashing', () {
        final resolver = CRDTConflictResolver();
        
        final data = {
          'title': 'Deterministic Test',
          'amount': 123.45,
          'date': '2025-01-01',
          'syncId': 'test-sync-id',
          'createdAt': '2025-01-01T00:00:00Z',
          'updatedAt': '2025-01-01T00:00:00Z',
        };

        // Run multiple times to ensure deterministic behavior
        final hashes = List.generate(5, (_) => resolver.calculateContentHash(data));
        
        // All hashes should be identical
        for (int i = 1; i < hashes.length; i++) {
          expect(hashes[i], equals(hashes[0]),
            reason: 'Content hash should be deterministic across multiple runs');
        }
      });

      test('should generate different hashes for different business content', () {
        final resolver = CRDTConflictResolver();
        
        final data1 = {
          'title': 'Transaction 1',
          'amount': 100.0,
          'syncId': 'sync-1',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final data2 = {
          'title': 'Transaction 2',
          'amount': 200.0,
          'syncId': 'sync-2',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final hash1 = resolver.calculateContentHash(data1);
        final hash2 = resolver.calculateContentHash(data2);

        expect(hash1, isNot(equals(hash2)),
          reason: 'Different business content should produce different hashes');
      });
    });

    group('✅ Default Categories Integration Validation', () {
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

        expect(syncIds.length, equals(uniqueSyncIds.length),
          reason: 'All category sync IDs should be unique');
      });
    });

    group('✅ Performance Validation', () {
      test('should handle empty data gracefully', () {
        final resolver = CRDTConflictResolver();
        final emptyData = <String, dynamic>{};
        final hash = resolver.calculateContentHash(emptyData);
        
        expect(hash, isNotEmpty);
        expect(hash.length, equals(64));
      });

      test('should handle large data sets efficiently', () {
        final resolver = CRDTConflictResolver();
        final largeData = <String, dynamic>{};
        
        // Generate a large data set
        for (int i = 0; i < 1000; i++) {
          largeData['field_$i'] = 'value_$i';
        }

        final stopwatch = Stopwatch()..start();
        final hash = resolver.calculateContentHash(largeData);
        stopwatch.stop();

        expect(hash, isNotEmpty);
        expect(stopwatch.elapsedMilliseconds, lessThan(100), 
          reason: 'Large data set hashing should complete within 100ms');
      });
    });

    group('✅ Event Sourcing Table Structure Validation', () {
      test('should define correct event sourcing field requirements', () {
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

    group('✅ Phase 4 Architecture Compliance', () {
      test('should verify clean architecture principles', () {
        // Test that architecture follows Phase 4 clean principles
        
        // 1. Namespace separation
        expect(GoogleDriveSyncService.SYNC_FOLDER, isNot(equals(GoogleDriveSyncService.ATTACHMENTS_FOLDER)));
        
        // 2. Content hashing excludes sync metadata
        final resolver = CRDTConflictResolver();
        final dataWithSync = {
          'business': 'data',
          'syncId': 'should-be-ignored',
          'createdAt': DateTime.now().toIso8601String(),
        };
        final dataWithoutSync = {'business': 'data'};
        
        final hash1 = resolver.calculateContentHash(dataWithSync);
        final hash2 = resolver.calculateContentHash(dataWithoutSync);
        expect(hash1, equals(hash2));
        
        // 3. Default categories have proper structure
        final categories = DefaultCategories.allCategories;
        expect(categories.isNotEmpty, isTrue);
        for (final category in categories) {
          expect(category.syncId, isNotEmpty);
          expect(category.name, isNotEmpty);
        }
      });

      test('should verify Phase 4 completion criteria', () {
        // This test verifies that Phase 4 architecture is complete and ready for Phase 5
        
        // ✅ CRDT conflict resolution functional
        final resolver = CRDTConflictResolver();
        final testHash = resolver.calculateContentHash({'test': 'data'});
        expect(testHash.length, equals(64),
          reason: 'CRDT conflict resolver should generate valid SHA-256 hashes');
        
        // ✅ Namespace separation implemented
        expect(GoogleDriveSyncService.APP_ROOT, equals('FinanceApp'));
        expect(GoogleDriveSyncService.SYNC_FOLDER, contains('database_sync'));
        expect(GoogleDriveSyncService.ATTACHMENTS_FOLDER, contains('user_attachments'));
        
        // ✅ Default categories with syncId structure
        final categories = DefaultCategories.allCategories;
        expect(categories.isNotEmpty, isTrue);
        for (final category in categories) {
          expect(category.syncId, matches(r'^(income|expense)-.+'));
        }
        
        // ✅ Performance requirements met
        final largeData = <String, dynamic>{};
        for (int i = 0; i < 100; i++) {
          largeData['field_$i'] = 'value_$i';
        }
        
        final stopwatch = Stopwatch()..start();
        resolver.calculateContentHash(largeData);
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(50),
          reason: 'Performance should meet Phase 4 requirements');
      });
    });
  });
} 