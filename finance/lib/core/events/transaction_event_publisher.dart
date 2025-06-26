import 'dart:async';
import 'package:injectable/injectable.dart';

import '../../features/transactions/domain/entities/transaction.dart';

/// Transaction change types for domain events
enum TransactionChangeType {
  created,
  updated,
  deleted,
}

/// Domain event for transaction changes
class TransactionChangedEvent {
  final Transaction transaction;
  final TransactionChangeType changeType;
  final DateTime timestamp;

  TransactionChangedEvent({
    required this.transaction,
    required this.changeType,
    required this.timestamp,
  });
}

/// Event publisher service for transaction domain events
/// This allows decoupled communication between transaction repository and other services
/// following the domain events pattern to avoid circular dependencies
@LazySingleton()
class TransactionEventPublisher {
  final StreamController<TransactionChangedEvent> _eventController =
      StreamController<TransactionChangedEvent>.broadcast();

  /// Stream of transaction change events
  Stream<TransactionChangedEvent> get events => _eventController.stream;

  /// Publish a transaction change event
  void publishTransactionChanged(
    Transaction transaction,
    TransactionChangeType changeType,
  ) {
    final event = TransactionChangedEvent(
      transaction: transaction,
      changeType: changeType,
      timestamp: DateTime.now(),
    );
    _eventController.add(event);
  }

  /// Dispose the event publisher
  void dispose() {
    _eventController.close();
  }
}