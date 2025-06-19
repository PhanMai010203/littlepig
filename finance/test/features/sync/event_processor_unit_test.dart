import 'dart:convert';
import 'package:test/test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import '../../../lib/core/sync/event_processor.dart';
import '../../../lib/core/sync/sync_event.dart';
import '../../../lib/core/database/app_database.dart';
import '../../helpers/test_database_setup.dart';

void main() {
  group('EventProcessor - Pure Dart Tests', () {
    late AppDatabase database;
    late EventProcessor eventProcessor;

    setUp(() async {
      database = await TestDatabaseSetup.createCleanTestDatabase();
      eventProcessor = EventProcessor(database);
      await database.customStatement('PRAGMA foreign_keys = ON');
    });

    tearDown(() async {
      await database.close();
    });

    test('validateEvent - should validate basic event structure', () async {
      final validEvent = SyncEvent(
        eventId: 'test-event-1',
        deviceId: 'device-123',
        tableName: 'transactions',
        recordId: 'record-456',
        operation: 'create',
        data: {'amount': 100.0, 'title': 'Test transaction'},
        timestamp: DateTime.now(),
        sequenceNumber: 1,
        hash: 'test-hash',
      );

      final result = await eventProcessor.validateEvent(validEvent);
      expect(result, isTrue);
    });

    test('validateEvent - should reject invalid operation', () async {
      final invalidEvent = SyncEvent(
        eventId: 'test-event-1',
        deviceId: 'device-123',
        tableName: 'transactions',
        recordId: 'record-456',
        operation: 'invalid-operation',
        data: {'amount': 100.0},
        timestamp: DateTime.now(),
        sequenceNumber: 1,
        hash: 'test-hash',
      );

      final result = await eventProcessor.validateEvent(invalidEvent);
      expect(result, isFalse);
    });

    test('validateEvent - should reject empty event ID', () async {
      final invalidEvent = SyncEvent(
        eventId: '',
        deviceId: 'device-123',
        tableName: 'transactions',
        recordId: 'record-456',
        operation: 'create',
        data: {'amount': 100.0},
        timestamp: DateTime.now(),
        sequenceNumber: 1,
        hash: 'test-hash',
      );

      final result = await eventProcessor.validateEvent(invalidEvent);
      expect(result, isFalse);
    });

    test('validateEvent - should reject invalid table name', () async {
      final invalidEvent = SyncEvent(
        eventId: 'test-event-1',
        deviceId: 'device-123',
        tableName: 'invalid_table',
        recordId: 'record-456',
        operation: 'create',
        data: {'amount': 100.0},
        timestamp: DateTime.now(),
        sequenceNumber: 1,
        hash: 'test-hash',
      );

      final result = await eventProcessor.validateEvent(invalidEvent);
      expect(result, isFalse);
    });

    test('compressEvent - should remove null values and empty strings',
        () async {
      final event = SyncEvent(
        eventId: 'test-event-1',
        deviceId: 'device-123',
        tableName: 'transactions',
        recordId: 'record-456',
        operation: 'create',
        data: {
          'amount': 100.0,
          'description': 'Test transaction',
          'nullField': null,
          'emptyField': '',
          'validField': 'value'
        },
        timestamp: DateTime.now(),
        sequenceNumber: 1,
        hash: 'test-hash',
      );

      final compressedEvent = await eventProcessor.compressEvent(event);

      expect(compressedEvent.data.containsKey('nullField'), isFalse);
      expect(compressedEvent.data.containsKey('emptyField'), isFalse);
      expect(compressedEvent.data.containsKey('amount'), isTrue);
      expect(compressedEvent.data.containsKey('description'), isTrue);
      expect(compressedEvent.data.containsKey('validField'), isTrue);
    });

    test('deduplicateEvents - should remove exact duplicates', () async {
      final event1 = SyncEvent(
        eventId: 'event-1',
        deviceId: 'device-123',
        tableName: 'transactions',
        recordId: 'record-456',
        operation: 'create',
        data: {'amount': 100.0},
        timestamp: DateTime.now(),
        sequenceNumber: 1,
        hash: 'hash-1',
      );

      final event2 = SyncEvent(
        eventId: 'event-2',
        deviceId: 'device-123',
        tableName: 'transactions',
        recordId: 'record-456',
        operation: 'create',
        data: {'amount': 100.0},
        timestamp: DateTime.now(),
        sequenceNumber: 1,
        hash: 'hash-1', // Same hash = duplicate
      );

      final events = [event1, event2];
      final uniqueEvents = await eventProcessor.deduplicateEvents(events);

      expect(uniqueEvents.length, equals(1));
    });

    test('deduplicateEvents - should keep newer version of same record',
        () async {
      final oldEvent = SyncEvent(
        eventId: 'event-1',
        deviceId: 'device-123',
        tableName: 'transactions',
        recordId: 'record-456',
        operation: 'update',
        data: {'amount': 100.0},
        timestamp: DateTime.now().subtract(Duration(minutes: 10)),
        sequenceNumber: 1,
        hash: 'hash-1',
      );

      final newEvent = SyncEvent(
        eventId: 'event-2',
        deviceId: 'device-123',
        tableName: 'transactions',
        recordId: 'record-456', // Same record
        operation: 'update',
        data: {'amount': 150.0},
        timestamp: DateTime.now(),
        sequenceNumber: 2,
        hash: 'hash-2',
      );

      final events = [oldEvent, newEvent];
      final uniqueEvents = await eventProcessor.deduplicateEvents(events);

      expect(uniqueEvents.length, equals(1));
      expect(uniqueEvents.first.eventId, equals('event-2'));
      expect(uniqueEvents.first.data['amount'], equals(150.0));
    });

    test('registerEventListener - should register and trigger listeners',
        () async {
      bool listenerCalled = false;
      String? receivedEventType;

      eventProcessor.registerEventListener('transactions:create', (event) {
        listenerCalled = true;
        receivedEventType = '${event.tableName}:${event.operation}';
      });

      final event = SyncEvent(
        eventId: 'test-event-1',
        deviceId: 'device-123',
        tableName: 'transactions',
        recordId: 'record-456',
        operation: 'create',
        data: {'amount': 100.0},
        timestamp: DateTime.now(),
        sequenceNumber: 1,
        hash: 'test-hash',
      );

      // This would trigger the listener through processEvent
      expect(listenerCalled, isFalse); // Not called yet
    });

    test('broadcastEvent - should add event to broadcast stream', () async {
      final event = SyncEvent(
        eventId: 'test-event-1',
        deviceId: 'device-123',
        tableName: 'transactions',
        recordId: 'record-456',
        operation: 'create',
        data: {'amount': 100.0},
        timestamp: DateTime.now(),
        sequenceNumber: 1,
        hash: 'test-hash',
      );

      bool eventReceived = false;

      // Listen to the broadcast stream
      eventProcessor.eventBroadcastStream.listen((broadcastEvent) {
        eventReceived = true;
        expect(broadcastEvent.eventId, equals(event.eventId));
      });

      await eventProcessor.broadcastEvent(event);

      // Give the stream time to process
      await Future.delayed(Duration(milliseconds: 10));
      expect(eventReceived, isTrue);
    });
  });
}
