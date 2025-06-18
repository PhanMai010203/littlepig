import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'sync_event.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

/// Core event processing engine for Phase 5A
/// Handles event validation, compression, deduplication, and broadcasting
class EventProcessor {
  final AppDatabase _database;
  final Map<String, Function> _eventListeners = {};
  final StreamController<SyncEvent> _eventBroadcastController = 
      StreamController<SyncEvent>.broadcast();
  
  EventProcessor(this._database);

  /// Stream for broadcasting processed events to Team B
  Stream<SyncEvent> get eventBroadcastStream => _eventBroadcastController.stream;

  /// Process a single sync event with full validation and optimization
  Future<void> processEvent(SyncEvent event) async {
    // Validate event before processing
    if (!await validateEvent(event)) {
      throw ArgumentError('Event validation failed for ${event.eventId}');
    }

    // Check for duplicates before processing
    if (await _isDuplicateEvent(event)) {
      print('Skipping duplicate event: ${event.eventId}');
      return;
    }

    // Compress event data for storage efficiency
    final compressedEvent = await compressEvent(event);
    
    // Store the processed event
    await _storeProcessedEvent(compressedEvent);
    
    // Broadcast to registered listeners
    await broadcastEvent(compressedEvent);
    
    // Trigger any registered event listeners
    await _triggerEventListeners(compressedEvent);
  }

  /// Validate event data integrity and business rules
  Future<bool> validateEvent(SyncEvent event) async {
    // Basic validation
    if (event.eventId.isEmpty || event.recordId.isEmpty) {
      return false;
    }

    // Validate operation type
    if (!['create', 'update', 'delete'].contains(event.operation)) {
      return false;
    }

    // Validate table name
    if (!['transactions', 'budgets', 'categories', 'accounts', 'attachments']
        .contains(event.tableName)) {
      return false;
    }

    // Validate timestamp is not in future
    if (event.timestamp.isAfter(DateTime.now().add(Duration(minutes: 5)))) {
      return false;
    }

    // Business rule validation based on table type
    return await _validateBusinessRules(event);
  }

  /// Compress event data for storage efficiency
  Future<SyncEvent> compressEvent(SyncEvent event) async {
    final compressedData = <String, dynamic>{};
    
    // Remove null values and empty strings to reduce size
    for (final entry in event.data.entries) {
      if (entry.value != null && entry.value.toString().isNotEmpty) {
        compressedData[entry.key] = entry.value;
      }
    }

    // Apply table-specific compression
    final optimizedData = await _applyTableSpecificOptimization(
      event.tableName, 
      compressedData
    );

    return SyncEvent(
      eventId: event.eventId,
      deviceId: event.deviceId,
      tableName: event.tableName,
      recordId: event.recordId,
      operation: event.operation,
      data: optimizedData,
      timestamp: event.timestamp,
      sequenceNumber: event.sequenceNumber,
      hash: _calculateOptimizedHash(optimizedData),
    );
  }

  /// Deduplicate events in a batch
  Future<List<SyncEvent>> deduplicateEvents(List<SyncEvent> events) async {
    final uniqueEvents = <String, SyncEvent>{};
    final recordVersions = <String, Map<String, dynamic>>{};

    for (final event in events) {
      final recordKey = '${event.tableName}:${event.recordId}';
      
      // Check if we've seen this exact event before
      final eventHash = event.hash;
      if (uniqueEvents.containsKey(eventHash)) {
        continue; // Skip duplicate
      }

      // Check if this is a newer version of the same record
      if (recordVersions.containsKey(recordKey)) {
        final existing = recordVersions[recordKey]!;
        
        // Compare timestamps and sequence numbers
        if (_isEventNewer(event, existing)) {
          // Remove old version and add new one
          final oldEventHash = existing['eventHash'] as String;
          uniqueEvents.remove(oldEventHash);
          uniqueEvents[eventHash] = event;
          recordVersions[recordKey] = {
            'eventId': event.eventId,
            'eventHash': eventHash,
            'timestamp': event.timestamp,
            'sequenceNumber': event.sequenceNumber,
          };
        }
      } else {
        // First time seeing this record
        uniqueEvents[eventHash] = event;
        recordVersions[recordKey] = {
          'eventId': event.eventId,
          'eventHash': eventHash,
          'timestamp': event.timestamp,
          'sequenceNumber': event.sequenceNumber,
        };
      }
    }

    return uniqueEvents.values.toList();
  }

  /// Register event listener for specific event types
  void registerEventListener(String eventType, Function callback) {
    _eventListeners[eventType] = callback;
  }

  /// Broadcast event to all subscribers (Team B interface)
  Future<void> broadcastEvent(SyncEvent event) async {
    if (!_eventBroadcastController.isClosed) {
      _eventBroadcastController.add(event);
    }
  }

  /// Check if event is duplicate based on hash and content
  Future<bool> _isDuplicateEvent(SyncEvent event) async {
    final query = _database.select(_database.syncEventLogTable)
      ..where((tbl) => tbl.hash.equals(event.hash));
    
    final existing = await query.getSingleOrNull();
    return existing != null;
  }

  /// Store processed event in database
  Future<void> _storeProcessedEvent(SyncEvent event) async {
    await _database.into(_database.syncEventLogTable).insert(
      SyncEventLogTableCompanion.insert(
        eventId: event.eventId,
        deviceId: event.deviceId,
        tableNameField: event.tableName,
        recordId: event.recordId,
        operation: event.operation,
        data: jsonEncode(event.data),
        timestamp: event.timestamp,
        sequenceNumber: event.sequenceNumber,
        hash: event.hash,
        isSynced: const Value(false),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Trigger registered event listeners
  Future<void> _triggerEventListeners(SyncEvent event) async {
    final eventType = '${event.tableName}:${event.operation}';
    
    if (_eventListeners.containsKey(eventType)) {
      try {
        await _eventListeners[eventType]!(event);
      } catch (e) {
        print('Error in event listener for $eventType: $e');
      }
    }

    // Also trigger general listeners
    if (_eventListeners.containsKey('*')) {
      try {
        await _eventListeners['*']!(event);
      } catch (e) {
        print('Error in general event listener: $e');
      }
    }
  }

  /// Validate business rules specific to each table type
  Future<bool> _validateBusinessRules(SyncEvent event) async {
    switch (event.tableName) {
      case 'transactions':
        return _validateTransactionEvent(event);
      case 'budgets':
        return _validateBudgetEvent(event);
      case 'categories':
        return _validateCategoryEvent(event);
      case 'accounts':
        return _validateAccountEvent(event);
      case 'attachments':
        return _validateAttachmentEvent(event);
      default:
        return false;
    }
  }

  /// Validate transaction event business rules
  bool _validateTransactionEvent(SyncEvent event) {
    if (event.operation == 'create' || event.operation == 'update') {
      // Required fields for transactions
      if (!event.data.containsKey('amount') || !event.data.containsKey('title')) {
        return false;
      }
      
      // Amount should be a number
      final amount = event.data['amount'];
      if (amount != null && amount is! num) {
        return false;
      }
    }
    return true;
  }

  /// Validate budget event business rules
  bool _validateBudgetEvent(SyncEvent event) {
    if (event.operation == 'create' || event.operation == 'update') {
      // Required fields for budgets
      if (!event.data.containsKey('name') || !event.data.containsKey('limit')) {
        return false;
      }
      
      // Budget limit should be positive
      final limit = event.data['limit'];
      if (limit != null && limit is num && limit <= 0) {
        return false;
      }
    }
    return true;
  }

  /// Validate category event business rules
  bool _validateCategoryEvent(SyncEvent event) {
    if (event.operation == 'create' || event.operation == 'update') {
      // Required fields for categories
      if (!event.data.containsKey('name')) {
        return false;
      }
    }
    return true;
  }

  /// Validate account event business rules
  bool _validateAccountEvent(SyncEvent event) {
    if (event.operation == 'create' || event.operation == 'update') {
      // Required fields for accounts
      if (!event.data.containsKey('name')) {
        return false;
      }
    }
    return true;
  }

  /// Validate attachment event business rules
  bool _validateAttachmentEvent(SyncEvent event) {
    if (event.operation == 'create' || event.operation == 'update') {
      // Required fields for attachments
      if (!event.data.containsKey('filename') || !event.data.containsKey('filePath')) {
        return false;
      }
    }
    return true;
  }

  /// Apply table-specific data optimization
  Future<Map<String, dynamic>> _applyTableSpecificOptimization(
    String tableName, 
    Map<String, dynamic> data
  ) async {
    switch (tableName) {
      case 'transactions':
        return _optimizeTransactionData(data);
      case 'budgets':
        return _optimizeBudgetData(data);
      case 'categories':
        return _optimizeCategoryData(data);
      case 'accounts':
        return _optimizeAccountData(data);
      case 'attachments':
        return _optimizeAttachmentData(data);
      default:
        return data;
    }
  }

  /// Optimize transaction data
  Map<String, dynamic> _optimizeTransactionData(Map<String, dynamic> data) {
    final optimized = Map<String, dynamic>.from(data);
    
    // Normalize amount precision to 2 decimal places
    if (optimized.containsKey('amount') && optimized['amount'] is num) {
      optimized['amount'] = double.parse(optimized['amount'].toStringAsFixed(2));
    }
    
    // Trim whitespace from text fields
    if (optimized.containsKey('title')) {
      optimized['title'] = optimized['title'].toString().trim();
    }
    if (optimized.containsKey('note')) {
      optimized['note'] = optimized['note'].toString().trim();
    }
    
    return optimized;
  }

  /// Optimize budget data
  Map<String, dynamic> _optimizeBudgetData(Map<String, dynamic> data) {
    final optimized = Map<String, dynamic>.from(data);
    
    // Normalize limit and spent to 2 decimal places
    for (final field in ['limit', 'spent']) {
      if (optimized.containsKey(field) && optimized[field] is num) {
        optimized[field] = double.parse(optimized[field].toStringAsFixed(2));
      }
    }
    
    return optimized;
  }

  /// Optimize category data
  Map<String, dynamic> _optimizeCategoryData(Map<String, dynamic> data) {
    final optimized = Map<String, dynamic>.from(data);
    
    // Trim whitespace from name
    if (optimized.containsKey('name')) {
      optimized['name'] = optimized['name'].toString().trim();
    }
    
    return optimized;
  }

  /// Optimize account data
  Map<String, dynamic> _optimizeAccountData(Map<String, dynamic> data) {
    final optimized = Map<String, dynamic>.from(data);
    
    // Normalize balance to 2 decimal places
    if (optimized.containsKey('balance') && optimized['balance'] is num) {
      optimized['balance'] = double.parse(optimized['balance'].toStringAsFixed(2));
    }
    
    return optimized;
  }

  /// Optimize attachment data
  Map<String, dynamic> _optimizeAttachmentData(Map<String, dynamic> data) {
    final optimized = Map<String, dynamic>.from(data);
    
    // Remove temporary file paths that shouldn't be synced
    optimized.remove('tempPath');
    optimized.remove('localCachePath');
    
    return optimized;
  }

  /// Calculate optimized hash for compressed data
  String _calculateOptimizedHash(Map<String, dynamic> data) {
    final content = jsonEncode(data);
    return sha256.convert(utf8.encode(content)).toString();
  }

  /// Check if an event is newer than existing event data
  bool _isEventNewer(SyncEvent event, Map<String, dynamic> existing) {
    final existingSequence = existing['sequenceNumber'] as int;
    final existingTimestamp = existing['timestamp'] as DateTime;
    
    // Compare by sequence number first
    if (event.sequenceNumber != existingSequence) {
      return event.sequenceNumber > existingSequence;
    }
    
    // Then by timestamp
    return event.timestamp.isAfter(existingTimestamp);
  }

  /// Clean up resources
  void dispose() {
    _eventBroadcastController.close();
    _eventListeners.clear();
  }
} 