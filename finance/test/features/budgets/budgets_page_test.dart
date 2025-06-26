import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance/core/di/injection.dart';
import 'package:finance/features/budgets/domain/repositories/budget_repository.dart';
import 'package:finance/features/budgets/domain/services/budget_update_service.dart';
import 'package:finance/features/budgets/domain/services/budget_filter_service.dart';
import 'package:finance/features/budgets/presentation/pages/budgets_page.dart';
import 'package:finance/features/budgets/presentation/bloc/budgets_bloc.dart';
import 'package:finance/features/budgets/presentation/bloc/budgets_event.dart';
import 'package:finance/features/budgets/presentation/bloc/budgets_state.dart';
import 'package:finance/features/budgets/domain/entities/budget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';
import '../../helpers/entity_builders.dart';
import '../../helpers/localization_test_wrapper.dart';

// Mocks
class MockBudgetRepository extends Mock implements BudgetRepository {}
class MockBudgetUpdateService extends Mock implements BudgetUpdateService {}
class MockBudgetFilterService extends Mock implements BudgetFilterService {}
class MockBudgetsBloc extends Mock implements BudgetsBloc {}
class FakeBudgetsEvent extends Fake implements BudgetsEvent {}

void main() {
  late MockBudgetRepository mockBudgetRepository;
  late MockBudgetUpdateService mockBudgetUpdateService;
  late MockBudgetFilterService mockBudgetFilterService;
  late MockBudgetsBloc mockBudgetsBloc;

  setUpAll(() {
    registerFallbackValue(FakeBudgetsEvent());
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
    await resetDependencies();
    mockBudgetRepository = MockBudgetRepository();
    mockBudgetUpdateService = MockBudgetUpdateService();
    mockBudgetFilterService = MockBudgetFilterService();
    mockBudgetsBloc = MockBudgetsBloc();

    getIt.registerSingleton<BudgetRepository>(mockBudgetRepository);
    getIt.registerSingleton<BudgetUpdateService>(mockBudgetUpdateService);
    getIt.registerSingleton<BudgetFilterService>(mockBudgetFilterService);

    // Mock EasyLocalization
    EasyLocalization.logger.enableBuildModes = [];
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/shared_preferences'), null);
    resetDependencies();
  });

  Future<void> pumpBudgetsPage(WidgetTester tester) async {
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
          home: BlocProvider<BudgetsBloc>(
            create: (context) => mockBudgetsBloc,
            child: const BudgetsPage(),
          ),
        ),
      ),
    );
  }

  final tBudget = TestEntityBuilders.createTestBudget(
    name: 'Test Budget',
    amount: 1000.0,
    spent: 250.0,
  );

  group('BudgetsPage Event Dispatching Tests (Task 1)', () {
    testWidgets(
        'should dispatch LoadAllBudgets event exactly once during widget initialization',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockBudgetsBloc.stream)
          .thenAnswer((_) => Stream.fromIterable([BudgetsInitial()]));
      when(() => mockBudgetsBloc.state).thenReturn(BudgetsInitial());
      when(() => mockBudgetsBloc.add(any())).thenReturn(null);
      when(() => mockBudgetsBloc.close()).thenAnswer((_) async {});

      // Act
      await pumpBudgetsPage(tester);

      // Assert - Verify LoadAllBudgets was added exactly once
      verify(() => mockBudgetsBloc.add(any(that: isA<LoadAllBudgets>())))
          .called(1);
    });

    testWidgets(
        'should NOT dispatch LoadAllBudgets again during widget rebuilds',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockBudgetsBloc.stream).thenAnswer((_) => Stream.fromIterable([
            BudgetsInitial(),
            BudgetsLoading(),
            BudgetsLoaded(budgets: [tBudget]),
          ]));
      when(() => mockBudgetsBloc.state)
          .thenReturn(BudgetsLoaded(budgets: [tBudget]));
      when(() => mockBudgetsBloc.add(any())).thenReturn(null);
      when(() => mockBudgetsBloc.close()).thenAnswer((_) async {});

      // Act
      await pumpBudgetsPage(tester);
      
      // Force a rebuild by pumping again
      await tester.pump();
      
      // Force another rebuild by updating the widget tree
      await tester.pump();

      // Assert - Verify LoadAllBudgets was still only called once despite rebuilds
      verify(() => mockBudgetsBloc.add(any(that: isA<LoadAllBudgets>())))
          .called(1);
    });

    testWidgets(
        'should show loading state initially and then loaded state with budgets',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockBudgetsBloc.stream).thenAnswer((_) => Stream.fromIterable([
            BudgetsLoading(),
            BudgetsLoaded(budgets: [tBudget]),
          ]));
      when(() => mockBudgetsBloc.state).thenReturn(BudgetsLoading());
      when(() => mockBudgetsBloc.add(any())).thenReturn(null);
      when(() => mockBudgetsBloc.close()).thenAnswer((_) async {});

      // Act
      await pumpBudgetsPage(tester);

      // Assert - Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Simulate state change to loaded
      when(() => mockBudgetsBloc.state)
          .thenReturn(BudgetsLoaded(budgets: [tBudget]));
      await tester.pump();

      // Assert - Budget is displayed
      expect(find.text('Test Budget'), findsOneWidget);
      expect(find.text('Amount: 1000.00'), findsOneWidget);
    });

    testWidgets('should show error state when budget loading fails',
        (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load budgets';
      when(() => mockBudgetsBloc.stream)
          .thenAnswer((_) => Stream.fromIterable([BudgetsError(errorMessage)]));
      when(() => mockBudgetsBloc.state).thenReturn(BudgetsError(errorMessage));
      when(() => mockBudgetsBloc.add(any())).thenReturn(null);
      when(() => mockBudgetsBloc.close()).thenAnswer((_) async {});

      // Act
      await pumpBudgetsPage(tester);

      // Assert
      expect(find.text('Error: $errorMessage'), findsOneWidget);
    });

    testWidgets('should show empty state when no budgets exist',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockBudgetsBloc.stream)
          .thenAnswer((_) => Stream.fromIterable([BudgetsLoaded(budgets: [])]));
      when(() => mockBudgetsBloc.state).thenReturn(BudgetsLoaded(budgets: []));
      when(() => mockBudgetsBloc.add(any())).thenReturn(null);
      when(() => mockBudgetsBloc.close()).thenAnswer((_) async {});

      // Act
      await pumpBudgetsPage(tester);

      // Assert
      expect(find.text('No budgets found. Create one!'), findsOneWidget);
    });
  });
} 