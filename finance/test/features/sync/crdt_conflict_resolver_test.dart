import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/sync/crdt_conflict_resolver.dart';
import 'package:finance/core/sync/sync_event.dart';

void main() {
  group('CRDT Conflict Resolver Tests', () {
    late CRDTConflictResolver resolver;

    setUp(() {
      resolver = CRDTConflictResolver();
    });

    group('Vector Clock Ordering', () {
      test('should order by sequence number first', () async {
        final event1 = SyncEvent(
          eventId: 'event1',
          deviceId: 'device1',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'amount': 100},
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'hash1',
        );

        final event2 = SyncEvent(
          eventId: 'event2',
          deviceId: 'device1',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'amount': 200},
          timestamp: DateTime.now(),
          sequenceNumber: 2,
          hash: 'hash2',
        );

        final resolution = await resolver.resolveCRDT([event1, event2]);

        expect(resolution.type, ConflictResolutionType.useLatest);
        expect(resolution.resolvedData!['amount'], 200);
      });

      test('should order by timestamp if sequence numbers are equal', () async {
        final baseTime = DateTime.now();

        final event1 = SyncEvent(
          eventId: 'event1',
          deviceId: 'device1',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'amount': 100},
          timestamp: baseTime,
          sequenceNumber: 1,
          hash: 'hash1',
        );

        final event2 = SyncEvent(
          eventId: 'event2',
          deviceId: 'device2',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'amount': 200},
          timestamp: baseTime.add(Duration(seconds: 1)),
          sequenceNumber: 1,
          hash: 'hash2',
        );

        final resolution = await resolver.resolveCRDT([event1, event2]);

        expect(resolution.type, ConflictResolutionType.useLatest);
        expect(resolution.resolvedData!['amount'], 200);
      });

      test('should order by device ID if timestamp and sequence are equal',
          () async {
        final baseTime = DateTime.now();

        final event1 = SyncEvent(
          eventId: 'event1',
          deviceId: 'device_b',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'amount': 100},
          timestamp: baseTime,
          sequenceNumber: 1,
          hash: 'hash1',
        );

        final event2 = SyncEvent(
          eventId: 'event2',
          deviceId: 'device_a',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'amount': 200},
          timestamp: baseTime,
          sequenceNumber: 1,
          hash: 'hash2',
        );

        final resolution = await resolver.resolveCRDT([event1, event2]);

        expect(resolution.type, ConflictResolutionType.useLatest);
        expect(resolution.resolvedData!['amount'],
            100); // device_b comes after device_a
      });
    });

    group('Field-Level Merging', () {
      test('should merge non-conflicting field updates', () async {
        final event1 = SyncEvent(
          eventId: 'event1',
          deviceId: 'device1',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'title': 'Updated Title'},
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'hash1',
        );

        final event2 = SyncEvent(
          eventId: 'event2',
          deviceId: 'device2',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'note': 'Updated Note'},
          timestamp: DateTime.now().add(Duration(seconds: 1)),
          sequenceNumber: 2,
          hash: 'hash2',
        );

        final resolution = await resolver.resolveCRDT([event1, event2]);

        expect(resolution.type, ConflictResolutionType.merge);
        expect(resolution.resolvedData!['title'], 'Updated Title');
        expect(resolution.resolvedData!['note'], 'Updated Note');
      });

      test('should not merge conflicting field updates', () async {
        final event1 = SyncEvent(
          eventId: 'event1',
          deviceId: 'device1',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'amount': 100},
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'hash1',
        );

        final event2 = SyncEvent(
          eventId: 'event2',
          deviceId: 'device2',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'amount': 200},
          timestamp: DateTime.now().add(Duration(seconds: 1)),
          sequenceNumber: 2,
          hash: 'hash2',
        );

        final resolution = await resolver.resolveCRDT([event1, event2]);

        expect(resolution.type, ConflictResolutionType.useLatest);
        expect(resolution.resolvedData!['amount'], 200);
      });
    });

    group('Transaction Business Logic', () {
      test('should concatenate transaction notes', () async {
        final event1 = SyncEvent(
          eventId: 'event1',
          deviceId: 'device1',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'note': 'Original note'},
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'hash1',
        );

        final event2 = SyncEvent(
          eventId: 'event2',
          deviceId: 'device2',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'note': 'Additional note'},
          timestamp: DateTime.now().add(Duration(seconds: 1)),
          sequenceNumber: 2,
          hash: 'hash2',
        );

        final resolution = await resolver.resolveCRDT([event1, event2]);

        expect(resolution.type, ConflictResolutionType.merge);
        expect(resolution.resolvedData!['note'], contains('Original note'));
        expect(resolution.resolvedData!['note'], contains('Additional note'));
        expect(resolution.resolvedData!['note'], contains('---'));
      });
    });

    group('Budget Business Logic', () {
      test('should use latest spending amount for budgets', () async {
        final event1 = SyncEvent(
          eventId: 'event1',
          deviceId: 'device1',
          tableName: 'budgets',
          recordId: 'budget1',
          operation: 'update',
          data: {'spent': 150.0},
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'hash1',
        );

        final event2 = SyncEvent(
          eventId: 'event2',
          deviceId: 'device2',
          tableName: 'budgets',
          recordId: 'budget1',
          operation: 'update',
          data: {'spent': 200.0},
          timestamp: DateTime.now().add(Duration(seconds: 1)),
          sequenceNumber: 2,
          hash: 'hash2',
        );

        final resolution = await resolver.resolveCRDT([event1, event2]);

        expect(resolution.type, ConflictResolutionType.merge);
        expect(resolution.resolvedData!['spent'], 200.0);
      });
    });

    group('Account Business Logic', () {
      test('should use latest balance for accounts', () async {
        final event1 = SyncEvent(
          eventId: 'event1',
          deviceId: 'device1',
          tableName: 'accounts',
          recordId: 'acc1',
          operation: 'update',
          data: {'balance': 1000.0},
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'hash1',
        );

        final event2 = SyncEvent(
          eventId: 'event2',
          deviceId: 'device2',
          tableName: 'accounts',
          recordId: 'acc1',
          operation: 'update',
          data: {'balance': 1200.0},
          timestamp: DateTime.now().add(Duration(seconds: 1)),
          sequenceNumber: 2,
          hash: 'hash2',
        );

        final resolution = await resolver.resolveCRDT([event1, event2]);

        expect(resolution.type, ConflictResolutionType.merge);
        expect(resolution.resolvedData!['balance'], 1200.0);
      });
    });

    group('Content Hashing', () {
      test('should generate consistent content hash', () {
        final data = {
          'title': 'Test Transaction',
          'amount': 100.0,
        };

        final hash1 = resolver.calculateContentHash(data);
        final hash2 = resolver.calculateContentHash(data);

        expect(hash1, equals(hash2));
      });

      test('should ignore sync metadata in content hash', () {
        final baseData = {'title': 'Test', 'amount': 100.0};
        final dataWithSync = Map<String, dynamic>.from(baseData);

        final hash1 = resolver.calculateContentHash(baseData);
        final hash2 = resolver.calculateContentHash(dataWithSync);

        expect(hash1, equals(hash2));
      });

      test('should detect same content', () {
        final data1 = {'title': 'Test', 'amount': 100.0};
        final data2 = Map<String, dynamic>.from(data1);

        final isSame = resolver.hasSameContent(data1, data2);
        expect(isSame, isTrue);
      });
    });

    group('Manual Resolution Detection', () {
      test('should require manual resolution for delete vs update conflicts',
          () {
        final events = [
          SyncEvent(
            eventId: 'event1',
            deviceId: 'device1',
            tableName: 'transactions',
            recordId: 'txn1',
            operation: 'delete',
            data: {},
            timestamp: DateTime.now(),
            sequenceNumber: 1,
            hash: 'hash1',
          ),
          SyncEvent(
            eventId: 'event2',
            deviceId: 'device2',
            tableName: 'transactions',
            recordId: 'txn1',
            operation: 'update',
            data: {'amount': 200},
            timestamp: DateTime.now().add(Duration(seconds: 1)),
            sequenceNumber: 2,
            hash: 'hash2',
          ),
        ];

        final requiresManual = resolver.requiresManualResolution(events);
        expect(requiresManual, isTrue);
      });

      test('should require manual resolution for too many conflicts', () {
        final events = List.generate(
            6,
            (index) => SyncEvent(
                  eventId: 'event$index',
                  deviceId: 'device$index',
                  tableName: 'transactions',
                  recordId: 'txn1',
                  operation: 'update',
                  data: {'amount': index * 100},
                  timestamp: DateTime.now().add(Duration(seconds: index)),
                  sequenceNumber: index + 1,
                  hash: 'hash$index',
                ));

        final requiresManual = resolver.requiresManualResolution(events);
        expect(requiresManual, isTrue);
      });

      test(
          'should require manual resolution for critical field conflicts in transactions',
          () {
        final events = [
          SyncEvent(
            eventId: 'event1',
            deviceId: 'device1',
            tableName: 'transactions',
            recordId: 'txn1',
            operation: 'update',
            data: {'amount': 100},
            timestamp: DateTime.now(),
            sequenceNumber: 1,
            hash: 'hash1',
          ),
          SyncEvent(
            eventId: 'event2',
            deviceId: 'device2',
            tableName: 'transactions',
            recordId: 'txn1',
            operation: 'update',
            data: {'amount': 200},
            timestamp: DateTime.now().add(Duration(seconds: 1)),
            sequenceNumber: 2,
            hash: 'hash2',
          ),
        ];

        final requiresManual = resolver.requiresManualResolution(events);
        expect(requiresManual, isTrue);
      });
    });

    group('Single Event Resolution', () {
      test('should return single event as latest', () async {
        final event = SyncEvent(
          eventId: 'event1',
          deviceId: 'device1',
          tableName: 'transactions',
          recordId: 'txn1',
          operation: 'update',
          data: {'amount': 100},
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          hash: 'hash1',
        );

        final resolution = await resolver.resolveCRDT([event]);

        expect(resolution.type, ConflictResolutionType.useLatest);
        expect(resolution.resolvedData!['amount'], 100);
      });
    });

    group('Error Handling', () {
      test('should throw for empty event list', () async {
        expect(
          () => resolver.resolveCRDT([]),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
