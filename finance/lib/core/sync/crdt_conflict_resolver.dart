import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'sync_event.dart';

/// CRDT (Conflict-free Replicated Data Type) conflict resolver
/// Implements intelligent conflict resolution using vector clocks and field-level merging
class CRDTConflictResolver {
  /// Resolve conflicts between multiple sync events for the same record
  Future<ConflictResolution> resolveCRDT(
      List<SyncEvent> conflictingEvents) async {
    if (conflictingEvents.isEmpty) {
      throw ArgumentError('Cannot resolve conflicts for empty event list');
    }

    if (conflictingEvents.length == 1) {
      return ConflictResolution.useLatest(conflictingEvents.first);
    }

    // Sort by vector clock: sequence number, timestamp, then device ID for deterministic ordering
    conflictingEvents.sort(_compareEventsByVectorClock);

    // Check if changes can be merged (different fields modified)
    if (await _canMergeEvents(conflictingEvents)) {
      final merged = await _mergeEvents(conflictingEvents);
      return ConflictResolution.merge(merged);
    }

    // Use Last-Writer-Wins CRDT for conflicting changes
    return ConflictResolution.useLatest(conflictingEvents.last);
  }

  /// Compare events using vector clock ordering
  int _compareEventsByVectorClock(SyncEvent a, SyncEvent b) {
    // Primary: Compare sequence numbers (causal ordering)
    if (a.sequenceNumber != b.sequenceNumber) {
      return a.sequenceNumber.compareTo(b.sequenceNumber);
    }

    // Secondary: Timestamp (wall clock)
    if (a.timestamp != b.timestamp) {
      return a.timestamp.compareTo(b.timestamp);
    }

    // Tertiary: Device ID (deterministic tie-breaker)
    return a.deviceId.compareTo(b.deviceId);
  }

  /// Check if events can be automatically merged (modify different fields)
  Future<bool> _canMergeEvents(List<SyncEvent> events) async {
    if (events.length != 2) return false;

    // Only support merging for update operations
    if (!events.every((event) => event.operation == 'update')) {
      return false;
    }

    // Check if they're for the same table and record
    if (!events.every((event) =>
        event.tableName == events.first.tableName &&
        event.recordId == events.first.recordId)) {
      return false;
    }

    // Get the changed fields for each event
    final changedFields1 = await _getChangedFields(events[0]);
    final changedFields2 = await _getChangedFields(events[1]);
    final conflictingFields = changedFields1.intersection(changedFields2);

    // Can merge if they modify different fields
    if (conflictingFields.isEmpty) {
      return true;
    }

    // Special case: Allow merging for certain fields with business logic
    return _canMergeConflictingFields(
        events.first.tableName, conflictingFields);
  }

  /// Check if conflicting fields can be merged using business logic
  bool _canMergeConflictingFields(
      String tableName, Set<String> conflictingFields) {
    switch (tableName) {
      case 'transactions':
        // Allow merging if only the note field conflicts (we can concatenate notes)
        return conflictingFields.length == 1 &&
            conflictingFields.contains('note');
      case 'budgets':
        // Allow merging if only the spent field conflicts (we use latest)
        return conflictingFields.length == 1 &&
            conflictingFields.contains('spent');
      case 'accounts':
        // Allow merging if only the balance field conflicts (we use latest)
        return conflictingFields.length == 1 &&
            conflictingFields.contains('balance');
      default:
        return false;
    }
  }

  /// Get the fields that were actually changed in an update event
  Future<Set<String>> _getChangedFields(SyncEvent event) async {
    if (event.operation != 'update') {
      return event.data.keys.toSet();
    }

    // For update events, we need to know which fields actually changed
    // This would require the previous state, but for now we'll use all fields
    // In a real implementation, you'd store field-level diffs
    return event.data.keys.toSet();
  }

  /// Merge non-conflicting events
  Future<Map<String, dynamic>> _mergeEvents(List<SyncEvent> events) async {
    final merged = <String, dynamic>{};

    // Start with the base data from the first event
    merged.addAll(events.first.data);

    // Apply changes from subsequent events
    for (int i = 1; i < events.length; i++) {
      final event = events[i];
      final changedFields = await _getChangedFields(event);

      // Add only the changed fields
      for (final field in changedFields) {
        if (event.data.containsKey(field)) {
          merged[field] = event.data[field];
        }
      }
    }

    // Apply table-specific merging rules
    return await _applyTableSpecificMerging(
        events.first.tableName, events, merged);
  }

  /// Apply business logic specific merging for different table types
  Future<Map<String, dynamic>> _applyTableSpecificMerging(
    String tableName,
    List<SyncEvent> events,
    Map<String, dynamic> baseData,
  ) async {
    switch (tableName) {
      case 'transactions':
        return await _mergeTransactionFields(events, baseData);
      case 'budgets':
        return await _mergeBudgetFields(events, baseData);
      case 'categories':
        return await _mergeCategoryFields(events, baseData);
      case 'accounts':
        return await _mergeAccountFields(events, baseData);
      case 'attachments':
        return await _mergeAttachmentFields(events, baseData);
      default:
        return baseData;
    }
  }

  /// Merge transaction fields with business logic
  Future<Map<String, dynamic>> _mergeTransactionFields(
    List<SyncEvent> events,
    Map<String, dynamic> baseData,
  ) async {
    final merged = Map<String, dynamic>.from(baseData);

    // Transactions are mostly immutable, but notes can be merged
    final notes = <String>[];
    for (final event in events) {
      final note = event.data['note'] as String?;
      if (note != null && note.isNotEmpty && !notes.contains(note)) {
        notes.add(note);
      }
    }

    if (notes.isNotEmpty) {
      merged['note'] = notes.join('\n---\n');
    }

    return merged;
  }

  /// Merge budget fields with business logic
  Future<Map<String, dynamic>> _mergeBudgetFields(
    List<SyncEvent> events,
    Map<String, dynamic> baseData,
  ) async {
    final merged = Map<String, dynamic>.from(baseData);

    // For budgets, take the latest spending amount (it's cumulative)
    final latestEvent = events.last;
    if (latestEvent.data.containsKey('spent')) {
      merged['spent'] = latestEvent.data['spent'];
    }

    return merged;
  }

  /// Merge category fields with business logic
  Future<Map<String, dynamic>> _mergeCategoryFields(
    List<SyncEvent> events,
    Map<String, dynamic> baseData,
  ) async {
    // Categories use last-writer-wins for all fields
    return Map<String, dynamic>.from(events.last.data);
  }

  /// Merge account fields with business logic
  Future<Map<String, dynamic>> _mergeAccountFields(
    List<SyncEvent> events,
    Map<String, dynamic> baseData,
  ) async {
    final merged = Map<String, dynamic>.from(baseData);

    // For accounts, balance should use the latest value
    final latestEvent = events.last;
    if (latestEvent.data.containsKey('balance')) {
      merged['balance'] = latestEvent.data['balance'];
    }

    return merged;
  }

  /// Merge attachment fields with business logic
  Future<Map<String, dynamic>> _mergeAttachmentFields(
    List<SyncEvent> events,
    Map<String, dynamic> baseData,
  ) async {
    final merged = Map<String, dynamic>.from(baseData);

    // Attachments are mostly immutable, use latest for metadata updates
    final latestEvent = events.last;

    // Take latest upload status and drive IDs
    if (latestEvent.data.containsKey('isUploaded')) {
      merged['isUploaded'] = latestEvent.data['isUploaded'];
    }
    if (latestEvent.data.containsKey('googleDriveFileId')) {
      merged['googleDriveFileId'] = latestEvent.data['googleDriveFileId'];
    }
    if (latestEvent.data.containsKey('googleDriveLink')) {
      merged['googleDriveLink'] = latestEvent.data['googleDriveLink'];
    }

    return merged;
  }

  /// Calculate content hash for conflict detection
  String calculateContentHash(Map<String, dynamic> data) {
    final contentData = Map<String, dynamic>.from(data);

    // ✅ PHASE 4.4: Remove legacy sync fields that were in the old sync infrastructure
    // but keep the current event sourcing infrastructure fields
    contentData.remove('deviceId');
    contentData.remove('isSynced');
    contentData.remove('version');
    contentData.remove('lastSyncAt');

    // Also remove current sync infrastructure fields that shouldn't affect content
    contentData.remove('syncId');
    contentData.remove('createdAt');
    contentData.remove('updatedAt');

    final content = jsonEncode(contentData);
    return sha256.convert(utf8.encode(content)).toString();
  }

  /// Detect if two data sets have the same content (ignoring sync metadata)
  bool hasSameContent(Map<String, dynamic> data1, Map<String, dynamic> data2) {
    final hash1 = calculateContentHash(data1);
    final hash2 = calculateContentHash(data2);
    return hash1 == hash2;
  }

  /// Check if a conflict requires manual resolution
  bool requiresManualResolution(List<SyncEvent> events) {
    // Manual resolution required for:
    // 1. Delete vs Update conflicts
    // 2. Conflicting critical fields (like amount in transactions)
    // 3. Too many conflicting events

    if (events.length > 5) {
      return true; // Too many conflicts
    }

    // Check for delete vs update conflicts
    final operations = events.map((e) => e.operation).toSet();
    if (operations.contains('delete') && operations.contains('update')) {
      return true;
    }

    // Check for critical field conflicts in transactions
    if (events.first.tableName == 'transactions') {
      final criticalFields = {'amount', 'categoryId', 'accountId', 'date'};
      for (final field in criticalFields) {
        final values = events
            .where((e) => e.data.containsKey(field))
            .map((e) => e.data[field])
            .toSet();
        if (values.length > 1) {
          return true; // Conflicting critical field
        }
      }
    }

    return false;
  }
}
