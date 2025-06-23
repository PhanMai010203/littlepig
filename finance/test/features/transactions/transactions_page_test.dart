import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finance/core/di/injection.dart';
import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance/features/categories/domain/repositories/category_repository.dart';
import 'package:finance/features/transactions/presentation/pages/transactions_page.dart';
import 'package:finance/features/transactions/domain/entities/transaction.dart';
import 'package:finance/features/categories/domain/entities/category.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';
import '../../helpers/entity_builders.dart';

// Mocks
class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockTransactionRepository mockTransactionRepository;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Mock SharedPreferences for EasyLocalization
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, Object>{
          'flutter.EasyLocalization.Path': 'assets/translations',
          'flutter.EasyLocalization.Locale': 'en'
        };
      }
      if (methodCall.method == 'setString') {
        return true;
      }
      return null;
    });

    await EasyLocalization.ensureInitialized();
    await resetDependencies();
    mockTransactionRepository = MockTransactionRepository();
    mockCategoryRepository = MockCategoryRepository();
    getIt.registerSingleton<TransactionRepository>(mockTransactionRepository);
    getIt.registerSingleton<CategoryRepository>(mockCategoryRepository);

    // Mock EasyLocalization
    EasyLocalization.logger.enableBuildModes = [];
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/shared_preferences'), null);
    resetDependencies();
  });

  Future<void> pumpTransactionsPage(WidgetTester tester) async {
    // Set a screen size for MediaQuery to work correctly.
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    // Required for EasyLocalization
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const MaterialApp(
          home: TransactionsPage(),
        ),
      ),
    );
  }

  final tCategory = TestEntityBuilders.createTestCategory(
      name: 'Food', icon: '🍔', color: const Color(0xFFFF9800));
  final tTransactionsPage1 = List.generate(
    20,
    (index) =>
        TestEntityBuilders.createTestTransaction(title: 'Transaction $index'),
  );
  final tTransactionsPage2 = List.generate(
    10,
    (index) => TestEntityBuilders.createTestTransaction(
        title: 'Transaction ${index + 20}'),
  );

  testWidgets(
      'should display loading indicator and then first page of transactions',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockCategoryRepository.getAllCategories())
        .thenAnswer((_) async => [tCategory]);
    when(() => mockTransactionRepository.getTransactions(page: 1, limit: 20))
        .thenAnswer((_) async => tTransactionsPage1);

    // Act
    await pumpTransactionsPage(tester);

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(); // Allow the future to complete
    await tester.pump(); // Rebuild the widget

    // Assert
    expect(find.text('Transaction 0'), findsOneWidget);
    expect(find.text('Transaction 19'), findsOneWidget);
    expect(find.text('Transaction 20'), findsNothing);
  });

  testWidgets('should load next page when scrolling to the end',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockCategoryRepository.getAllCategories())
        .thenAnswer((_) async => [tCategory]);
    when(() => mockTransactionRepository.getTransactions(page: 1, limit: 20))
        .thenAnswer((_) async => tTransactionsPage1);
    when(() => mockTransactionRepository.getTransactions(page: 2, limit: 20))
        .thenAnswer((_) async => tTransactionsPage2);

    // Act
    await pumpTransactionsPage(tester);
    await tester.pump();
    await tester.pump();

    // Assert
    expect(find.text('Transaction 19'), findsOneWidget);

    // Act
    await tester.drag(find.text('Transaction 19'), const Offset(0.0, -600.0));
    await tester.pump();
    await tester.pump();

    // Assert
    expect(find.text('Transaction 20'), findsOneWidget);
    expect(find.text('Transaction 29'), findsOneWidget);
  });
}
