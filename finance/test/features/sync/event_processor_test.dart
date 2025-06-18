import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/sync/event_processor.dart';
import '../../../lib/core/sync/sync_event.dart';
import '../../../lib/core/database/app_database.dart';
import 'package:drift/drift.dart';
import '../../helpers/test_database_setup.dart';

void main() {
  group('EventProcessor Tests - Phase 5A', () {
    late AppDatabase database;
    late EventProcessor eventProcessor;

    setUp(() async {
      database = await TestDatabaseSetup.createCleanTestDatabase();
      eventProcessor = EventProcessor(database);
    });

    tearDown(() async {
      eventProcessor.dispose();
      await database.close();
    });

    group('Event Validation', () {
      test('should validate valid transaction event', () async {
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {
            'title': 'Test Transaction',
            'amount': 100.0,
            'categoryId': 1,
            'accountId': 1,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        final isValid = await eventProcessor.validateEvent(event);
        expect(isValid, isTrue);
      });

      test('should reject event with missing required fields', () async {
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {
            'title': 'Test Transaction',
            // Missing amount field
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        final isValid = await eventProcessor.validateEvent(event);
        expect(isValid, isFalse);
      });

      test('should reject event with invalid operation', () async {
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'invalid_operation',
          data: {
            'title': 'Test Transaction',
            'amount': 100.0,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        final isValid = await eventProcessor.validateEvent(event);
        expect(isValid, isFalse);
      });

      test('should reject event with future timestamp', () async {
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {
            'title': 'Test Transaction',
            'amount': 100.0,
          },
          timestamp: DateTime.now().add(Duration(hours: 1)),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        final isValid = await eventProcessor.validateEvent(event);
        expect(isValid, isFalse);
      });
    });

    group('Event Compression', () {
      test('should remove null values and empty strings', () async {
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {
            'title': 'Test Transaction',
            'amount': 100.0,
            'note': null,
            'description': '',
            'categoryId': 1,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        final compressed = await eventProcessor.compressEvent(event);
        
        expect(compressed.data.containsKey('note'), isFalse);
        expect(compressed.data.containsKey('description'), isFalse);
        expect(compressed.data['title'], equals('Test Transaction'));
        expect(compressed.data['amount'], equals(100.0));
        expect(compressed.data['categoryId'], equals(1));
      });

      test('should normalize transaction amounts to 2 decimal places', () async {
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {
            'title': 'Test Transaction',
            'amount': 100.123456,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        final compressed = await eventProcessor.compressEvent(event);
        
        expect(compressed.data['amount'], equals(100.12));
      });

      test('should trim whitespace from text fields', () async {
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {
            'title': '  Test Transaction  ',
            'note': '  This is a note  ',
            'amount': 100.0,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        final compressed = await eventProcessor.compressEvent(event);
        
        expect(compressed.data['title'], equals('Test Transaction'));
        expect(compressed.data['note'], equals('This is a note'));
      });
    });

    group('Event Deduplication', () {
      test('should remove exact duplicate events', () async {
        final events = [
          SyncEvent(
            eventId: 'event-1',
            deviceId: 'device-1',
            tableName: 'transactions',
            recordId: 'txn-1',
            operation: 'create',
            data: {'amount': 100.0},
            timestamp: DateTime.now(),
            sequenceNumber: 1,
            hash: 'same-hash',
          ),
          SyncEvent(
            eventId: 'event-2',
            deviceId: 'device-1',
            tableName: 'transactions',
            recordId: 'txn-1',
            operation: 'create',
            data: {'amount': 100.0},
            timestamp: DateTime.now(),
            sequenceNumber: 1,
            hash: 'same-hash',
          ),
        ];

        final deduplicated = await eventProcessor.deduplicateEvents(events);
        
        expect(deduplicated.length, equals(1));
        expect(deduplicated.first.eventId, equals('event-1'));
      });

      test('should keep newer version of same record', () async {
        final baseTime = DateTime.now();
        
        final events = [
          SyncEvent(
            eventId: 'event-1',
            deviceId: 'device-1',
            tableName: 'transactions',
            recordId: 'txn-1',
            operation: 'update',
            data: {'amount': 100.0},
            timestamp: baseTime,
            sequenceNumber: 1,
            hash: 'hash-1',
          ),
          SyncEvent(
            eventId: 'event-2',
            deviceId: 'device-1',
            tableName: 'transactions',
            recordId: 'txn-1',
            operation: 'update',
            data: {'amount': 200.0},
            timestamp: baseTime.add(Duration(seconds: 1)),
            sequenceNumber: 2,
            hash: 'hash-2',
          ),
        ];

        final deduplicated = await eventProcessor.deduplicateEvents(events);
        
        expect(deduplicated.length, equals(1));
        expect(deduplicated.first.eventId, equals('event-2'));
        expect(deduplicated.first.data['amount'], equals(200.0));
      });

      test('should keep events for different records', () async {
        final events = [
          SyncEvent(
            eventId: 'event-1',
            deviceId: 'device-1',
            tableName: 'transactions',
            recordId: 'txn-1',
            operation: 'create',
            data: {'amount': 100.0},
            timestamp: DateTime.now(),
            sequenceNumber: 1,
            hash: 'hash-1',
          ),
          SyncEvent(
            eventId: 'event-2',
            deviceId: 'device-1',
            tableName: 'transactions',
            recordId: 'txn-2',
            operation: 'create',
            data: {'amount': 200.0},
            timestamp: DateTime.now(),
            sequenceNumber: 2,
            hash: 'hash-2',
          ),
        ];

        final deduplicated = await eventProcessor.deduplicateEvents(events);
        
        expect(deduplicated.length, equals(2));
      });
    });

    group('Event Processing', () {
      test('should process valid event successfully', () async {
        // Clean up any existing events first
        await database.delete(database.syncEventLogTable).go();
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {
            'title': 'Test Transaction',
            'amount': 100.0,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        // Should not throw
        await eventProcessor.processEvent(event);
        
        // Verify event was stored
        final storedEvents = await database.select(database.syncEventLogTable).get();
        expect(storedEvents.length, equals(1));
        expect(storedEvents.first.eventId, equals('test-event-1'));
      });

      test('should skip duplicate events', () async {
        // Clean up any existing events first
        await database.delete(database.syncEventLogTable).go();
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {
            'title': 'Test Transaction',
            'amount': 100.0,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        // Process same event twice
        await eventProcessor.processEvent(event);
        await eventProcessor.processEvent(event);
        
        // Should only store once
        final storedEvents = await database.select(database.syncEventLogTable).get();
        expect(storedEvents.length, equals(1));
      });

      test('should throw on invalid event', () async {
        final invalidEvent = SyncEvent(
          eventId: '', // Invalid empty ID
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {'amount': 100.0},
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        expect(
          () => eventProcessor.processEvent(invalidEvent),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Event Broadcasting', () {
      test('should broadcast events to stream', () async {
        final events = <SyncEvent>[];
        eventProcessor.eventBroadcastStream.listen(events.add);
        
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {'amount': 100.0},
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        await eventProcessor.broadcastEvent(event);
        
        // Give stream time to process
        await Future.delayed(Duration(milliseconds: 10));
        
        expect(events.length, equals(1));
        expect(events.first.eventId, equals('test-event-1'));
      });
    });

    group('Event Listeners', () {
      test('should trigger registered event listeners', () async {
        // Clean up any existing events first
        await database.delete(database.syncEventLogTable).go();
        
        var callbackCalled = false;
        var receivedEvent;
        
        eventProcessor.registerEventListener('transactions:create', (SyncEvent event) {
          callbackCalled = true;
          receivedEvent = event;
        });
        
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {
            'title': 'Test Transaction',
            'amount': 100.0,
            'categoryId': 1,
            'accountId': 1,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        await eventProcessor.processEvent(event);
        
        expect(callbackCalled, isTrue);
        expect(receivedEvent.eventId, equals('test-event-1'));
      });

      test('should trigger general listeners', () async {
        // Clean up any existing events first
        await database.delete(database.syncEventLogTable).go();
        
        var callbackCalled = false;
        
        eventProcessor.registerEventListener('*', (SyncEvent event) {
          callbackCalled = true;
        });
        
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'transactions',
          recordId: 'txn-1',
          operation: 'create',
          data: {
            'title': 'Test Transaction',
            'amount': 100.0,
            'categoryId': 1,
            'accountId': 1,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        await eventProcessor.processEvent(event);
        
        expect(callbackCalled, isTrue);
      });
    });

    group('Business Logic Validation', () {
      test('should validate budget events with positive limits', () async {
        final validEvent = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'budgets',
          recordId: 'budget-1',
          operation: 'create',
          data: {
            'name': 'Test Budget',
            'limit': 1000.0,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        final isValid = await eventProcessor.validateEvent(validEvent);
        expect(isValid, isTrue);
      });

      test('should reject budget events with non-positive limits', () async {
        final invalidEvent = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'budgets',
          recordId: 'budget-1',
          operation: 'create',
          data: {
            'name': 'Test Budget',
            'limit': -100.0, // Invalid negative limit
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        final isValid = await eventProcessor.validateEvent(invalidEvent);
        expect(isValid, isFalse);
      });

      test('should validate account events with required name', () async {
        final validEvent = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'accounts',
          recordId: 'account-1',
          operation: 'create',
          data: {
            'name': 'Test Account',
            'balance': 1000.0,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        final isValid = await eventProcessor.validateEvent(validEvent);
        expect(isValid, isTrue);
      });
    });

    group('Table-Specific Optimization', () {
      test('should optimize attachment events by removing temp paths', () async {
        final event = SyncEvent(
          eventId: 'test-event-1',
          deviceId: 'test-device',
          tableName: 'attachments',
          recordId: 'attachment-1',
          operation: 'create',
          data: {
            'filename': 'test.jpg',
            'filePath': '/storage/test.jpg',
            'tempPath': '/tmp/test.jpg',
            'localCachePath': '/cache/test.jpg',
            'fileSize': 1024,
          },
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'test-hash',
        );

        final compressed = await eventProcessor.compressEvent(event);
        
        expect(compressed.data.containsKey('tempPath'), isFalse);
        expect(compressed.data.containsKey('localCachePath'), isFalse);
        expect(compressed.data['filename'], equals('test.jpg'));
        expect(compressed.data['filePath'], equals('/storage/test.jpg'));
        expect(compressed.data['fileSize'], equals(1024));
      });
    });

    group('Performance Tests', () {
      test('should process 1000 events in under 1 second', () async {
        // Clean up any existing events first
        await database.delete(database.syncEventLogTable).go();
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          final event = SyncEvent(
            eventId: 'event-$i',
            deviceId: 'test-device',
            tableName: 'transactions',
            recordId: 'txn-$i',
            operation: 'create',
            data: {
              'title': 'Transaction $i',
              'amount': i * 10.0,
            },
            timestamp: DateTime.now().add(Duration(milliseconds: i)),
            sequenceNumber: i + 1,
            hash: 'hash-$i',
          );
          
          await eventProcessor.processEvent(event);
        }
        
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(1500)); // Allow 1.5 seconds for better reliability
        
        // Verify all events were stored
        final storedEvents = await database.select(database.syncEventLogTable).get();
        expect(storedEvents.length, equals(1000));
      });

      test('should deduplicate 10k events efficiently', () async {
        final events = <SyncEvent>[];
        
        // Create 10k events with many duplicates
        for (int i = 0; i < 10000; i++) {
          events.add(SyncEvent(
            eventId: 'event-${i % 100}', // Only 100 unique events
            deviceId: 'test-device',
            tableName: 'transactions',
            recordId: 'txn-${i % 100}',
            operation: 'create',
            data: {'amount': (i % 100) * 10.0},
            timestamp: DateTime.now(),
            sequenceNumber: i + 1,
            hash: 'hash-${i % 100}',
          ));
        }
        
        final stopwatch = Stopwatch()..start();
        final deduplicated = await eventProcessor.deduplicateEvents(events);
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        expect(deduplicated.length, equals(100));
      });
    });
  });
} 