import 'package:finance/core/events/transaction_event_publisher.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionEventPublisher extends Mock
    implements TransactionEventPublisher {}