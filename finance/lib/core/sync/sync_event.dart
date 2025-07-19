import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../database/app_database.dart';
import '../utils/safe_parsing.dart';

/// Represents a synchronization event that can be applied across devices
class SyncEvent {
  final String eventId;
  final String deviceId;
  final String tableName;
  final String recordId;
  final String operation;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int sequenceNumber;
  final String hash;
  final bool isSynced;

  const SyncEvent({
    required this.eventId,
    required this.deviceId,
    required this.tableName,
    required this.recordId,
    required this.operation,
    required this.data,
    required this.timestamp,
    required this.sequenceNumber,
    required this.hash,
    this.isSynced = false,
  });

  /// Create from database event log entry
  factory SyncEvent.fromEventLog(SyncEventLogData eventLog) {
    debugPrint('🔧 SyncEvent.fromEventLog: Creating from eventId=${eventLog.eventId}');
    debugPrint('🔧 Raw data field: "${eventLog.data}" (${eventLog.data.runtimeType})');
    debugPrint('🔧 Raw timestamp field: "${eventLog.timestamp}" (${eventLog.timestamp.runtimeType})');
    debugPrint('🔧 Raw sequenceNumber field: "${eventLog.sequenceNumber}" (${eventLog.sequenceNumber.runtimeType})');
    
    Map<String, dynamic> parsedData;
    try {
      parsedData = jsonDecode(eventLog.data);
      debugPrint('🔧 Successfully parsed JSON data');
    } catch (jsonError) {
      debugPrint('❌ JSON decode error: $jsonError');
      debugPrint('❌ Problematic data: "${eventLog.data}"');
      rethrow;
    }
    
    return SyncEvent(
      eventId: eventLog.eventId,
      deviceId: eventLog.deviceId,
      tableName: eventLog.tableNameField,
      recordId: eventLog.recordId,
      operation: eventLog.operation,
      data: parsedData,
      timestamp: eventLog.timestamp,
      sequenceNumber: eventLog.sequenceNumber,
      hash: eventLog.hash,
      isSynced: eventLog.isSynced,
    );
  }

  /// Create from JSON (for network transmission)
  factory SyncEvent.fromJson(Map<String, dynamic> json) {
    debugPrint('🔧 SyncEvent.fromJson: Parsing event with eventId=${json['eventId']}, sequenceNumber=${json['sequenceNumber']} (type: ${json['sequenceNumber'].runtimeType})');
    
    return SyncEvent(
      eventId: json['eventId'] ?? '',
      deviceId: json['deviceId'] ?? '',
      tableName: json['tableName'] ?? '',
      recordId: json['recordId'] ?? '',
      operation: json['operation'] ?? '',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : {},
      timestamp: SafeParsing.parseDateTime(json['timestamp']),
      sequenceNumber: SafeParsing.parseInt(json['sequenceNumber']),
      hash: json['hash'] ?? '',
      isSynced: SafeParsing.parseBool(json['isSynced']),
    );
  }

  /// Convert to JSON for network transmission
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'deviceId': deviceId,
      'tableName': tableName,
      'recordId': recordId,
      'operation': operation,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'sequenceNumber': sequenceNumber,
      'hash': hash,
      'isSynced': isSynced,
    };
  }

  /// Create a copy with updated fields
  SyncEvent copyWith({
    String? eventId,
    String? deviceId,
    String? tableName,
    String? recordId,
    String? operation,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? sequenceNumber,
    String? hash,
    bool? isSynced,
  }) {
    return SyncEvent(
      eventId: eventId ?? this.eventId,
      deviceId: deviceId ?? this.deviceId,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      hash: hash ?? this.hash,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncEvent &&
        other.eventId == eventId &&
        other.deviceId == deviceId &&
        other.tableName == tableName &&
        other.recordId == recordId &&
        other.operation == operation &&
        other.timestamp == timestamp &&
        other.sequenceNumber == sequenceNumber &&
        other.hash == hash;
  }

  @override
  int get hashCode {
    return Object.hash(
      eventId,
      deviceId,
      tableName,
      recordId,
      operation,
      timestamp,
      sequenceNumber,
      hash,
    );
  }

  @override
  String toString() {
    return 'SyncEvent{eventId: $eventId, deviceId: $deviceId, tableName: $tableName, operation: $operation, recordId: $recordId, timestamp: $timestamp}';
  }
}

/// Represents the result of conflict resolution
class ConflictResolution {
  final ConflictResolutionType type;
  final Map<String, dynamic>? resolvedData;
  final String? reason;

  const ConflictResolution({
    required this.type,
    this.resolvedData,
    this.reason,
  });

  factory ConflictResolution.merge(Map<String, dynamic> mergedData) {
    return ConflictResolution(
      type: ConflictResolutionType.merge,
      resolvedData: mergedData,
      reason: 'Events were successfully merged',
    );
  }

  factory ConflictResolution.useLatest(SyncEvent latestEvent) {
    return ConflictResolution(
      type: ConflictResolutionType.useLatest,
      resolvedData: latestEvent.data,
      reason: 'Used latest event based on vector clock ordering',
    );
  }

  factory ConflictResolution.useLocal() {
    return const ConflictResolution(
      type: ConflictResolutionType.useLocal,
      reason: 'Local version was more recent',
    );
  }

  factory ConflictResolution.requireManualResolution(String reason) {
    return ConflictResolution(
      type: ConflictResolutionType.manualResolution,
      reason: reason,
    );
  }
}

enum ConflictResolutionType {
  merge,
  useLatest,
  useLocal,
  manualResolution,
}

/// Batch of sync events for efficient transmission
class SyncEventBatch {
  final String deviceId;
  final DateTime timestamp;
  final List<SyncEvent> events;

  const SyncEventBatch({
    required this.deviceId,
    required this.timestamp,
    required this.events,
  });

  factory SyncEventBatch.fromJson(Map<String, dynamic> json) {
    return SyncEventBatch(
      deviceId: json['deviceId'],
      timestamp: DateTime.parse(json['timestamp']),
      events:
          (json['events'] as List).map((e) => SyncEvent.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'events': events.map((e) => e.toJson()).toList(),
    };
  }
}
