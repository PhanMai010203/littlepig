import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finance/core/di/injection.dart';
import 'package:finance/features/transactions/presentation/pages/transactions_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:finance/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:finance/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../helpers/localization_test_wrapper.dart';

// Mocks
class MockTransactionsBloc extends Mock implements TransactionsBloc {}
class FakeTransactionsEvent extends Fake implements TransactionsEvent {}

void main() {
  late MockTransactionsBloc mockTransactionsBloc;

  setUpAll(() {
    registerFallbackValue(FakeTransactionsEvent());
  });

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
    await resetDependencies(); // Ensure a clean slate for dependencies
    mockTransactionsBloc = MockTransactionsBloc();

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
        assetLoader: const FakeAssetLoader(),
        child: MaterialApp(
          home: BlocProvider<TransactionsBloc>(
            create: (_) => mockTransactionsBloc,
            child: const TransactionsPage(),
          ),
        ),
      ),
    );
  }

  group('TransactionsPage Event Dispatching Tests (Task 1)', () {
    testWidgets(
        'should dispatch LoadTransactionsWithCategories event exactly once on init',
        (WidgetTester tester) async {
      // Arrange
      // Stub the stream and state before pumping the widget
      when(() => mockTransactionsBloc.stream)
          .thenAnswer((_) => Stream.fromIterable([TransactionsInitial()]));
      when(() => mockTransactionsBloc.state).thenReturn(TransactionsInitial());
      when(() => mockTransactionsBloc.close()).thenAnswer((_) async => {});

      // Stub the `add` method to avoid errors
      when(() => mockTransactionsBloc.add(any())).thenReturn(null);

      // Act
      await pumpTransactionsPage(tester);

      // Assert
      verify(() => mockTransactionsBloc
          .add(any(that: isA<LoadTransactionsWithCategories>()))).called(1);
    });

    testWidgets(
        'should NOT dispatch LoadTransactionsWithCategories again on rebuild',
        (WidgetTester tester) async {
      // Arrange
      final initialState = TransactionsPaginated(
        pagingState: PagingState<int, TransactionListItem>(),
        categories: {},
        selectedMonth: DateTime.now(),
      );
      when(() => mockTransactionsBloc.stream)
          .thenAnswer((_) => Stream.fromIterable([initialState]));
      when(() => mockTransactionsBloc.state).thenReturn(initialState);
      when(() => mockTransactionsBloc.add(any())).thenReturn(null);
      when(() => mockTransactionsBloc.close()).thenAnswer((_) async => {});

      // Act
      await pumpTransactionsPage(tester);

      // Force a rebuild
      await tester.pump();

      // Assert - Verify the event was still called only once
      verify(() => mockTransactionsBloc
          .add(any(that: isA<LoadTransactionsWithCategories>()))).called(1);
    });
  });
}
