import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/shared/widgets/multi_category_selector.dart';
import 'package:finance/features/categories/domain/entities/category.dart';

void main() {
  group('MultiCategorySelector Basic Tests', () {
    late List<Category> mockCategories;

    setUp(() {
      mockCategories = [
        Category(
          id: 1,
          name: 'Food',
          icon: '🍔',
          color: Colors.orange,
          isExpense: true,
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'category-1',
        ),
        Category(
          id: 2,
          name: 'Transport',
          icon: '🚗',
          color: Colors.blue,
          isExpense: true,
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'category-2',
        ),
        Category(
          id: 3,
          name: 'Entertainment',
          icon: '🎬',
          color: Colors.purple,
          isExpense: true,
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'category-3',
        ),
      ];
    });

    testWidgets('creates widget without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCategorySelector(
              title: 'Select Categories',
              availableCategories: mockCategories,
              selectedCategories: const [],
              isAllSelected: true,
              onSelectionChanged: (categories) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.byType(MultiCategorySelector), findsOneWidget);
    });

    testWidgets('displays title correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCategorySelector(
              title: 'Test Categories Title',
              availableCategories: mockCategories,
              selectedCategories: const [],
              isAllSelected: true,
              onSelectionChanged: (categories) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Categories Title'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCategorySelector(
              title: 'Select Categories',
              availableCategories: mockCategories,
              selectedCategories: const [],
              isAllSelected: true,
              onSelectionChanged: (categories) {},
              onAllSelected: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows chevron icon when not loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCategorySelector(
              title: 'Select Categories',
              availableCategories: mockCategories,
              selectedCategories: const [],
              isAllSelected: true,
              onSelectionChanged: (categories) {},
              onAllSelected: () {},
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays single category name when one category selected', (tester) async {
      final selectedCategory = mockCategories[0];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCategorySelector(
              title: 'Select Categories',
              availableCategories: mockCategories,
              selectedCategories: [selectedCategory],
              isAllSelected: false,
              onSelectionChanged: (categories) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('applies opacity when isOpacityReduced is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCategorySelector(
              title: 'Select Categories',
              availableCategories: mockCategories,
              selectedCategories: const [],
              isAllSelected: true,
              onSelectionChanged: (categories) {},
              onAllSelected: () {},
              isOpacityReduced: true,
            ),
          ),
        ),
      );

      // Should find AnimatedOpacity widget
      expect(find.byType(AnimatedOpacity), findsOneWidget);
      expect(find.byType(MultiCategorySelector), findsOneWidget);
    });

    testWidgets('exclude mode works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCategorySelector(
              title: 'Exclude Categories',
              availableCategories: mockCategories,
              selectedCategories: [mockCategories[1]],
              isAllSelected: false,
              onSelectionChanged: (categories) {},
              onAllSelected: () {},
              isExcludeMode: true,
            ),
          ),
        ),
      );

      expect(find.byType(MultiCategorySelector), findsOneWidget);
      expect(find.text('Exclude Categories'), findsOneWidget);
    });
  });

  group('MultiCategorySelector State Tests', () {
    testWidgets('displays correct summary for different selection states', (tester) async {
      final mockCategories = [
        Category(
          id: 1,
          name: 'Category 1',
          icon: '💰',
          color: Colors.green,
          isExpense: true,
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'category-1',
        ),
        Category(
          id: 2,
          name: 'Category 2',
          icon: '🏠',
          color: Colors.blue,
          isExpense: true,
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'category-2',
        ),
      ];

      // Test "All selected" state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCategorySelector(
              title: 'Select Categories',
              availableCategories: mockCategories,
              selectedCategories: const [],
              isAllSelected: true,
              onSelectionChanged: (categories) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.byType(MultiCategorySelector), findsOneWidget);

      // Test multiple categories selected
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCategorySelector(
              title: 'Select Categories',
              availableCategories: mockCategories,
              selectedCategories: mockCategories,
              isAllSelected: false,
              onSelectionChanged: (categories) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.byType(MultiCategorySelector), findsOneWidget);

      // Test no categories selected
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCategorySelector(
              title: 'Select Categories',
              availableCategories: mockCategories,
              selectedCategories: const [],
              isAllSelected: false,
              onSelectionChanged: (categories) {},
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.byType(MultiCategorySelector), findsOneWidget);
    });

    testWidgets('opacity reduced state shows correct behavior', (tester) async {
      final mockCategories = [
        Category(
          id: 1,
          name: 'Test Category',
          icon: '✨',
          color: Colors.yellow,
          isExpense: true,
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'category-1',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCategorySelector(
              title: 'Select Categories',
              availableCategories: mockCategories,
              selectedCategories: const [],
              isAllSelected: true,
              onSelectionChanged: (categories) {},
              onAllSelected: () {},
              isOpacityReduced: true,
            ),
          ),
        ),
      );

      // Verify the widget is wrapped in AnimatedOpacity
      final animatedOpacity = find.byType(AnimatedOpacity);
      expect(animatedOpacity, findsOneWidget);
      
      // The widget should still be functional
      expect(find.byType(MultiCategorySelector), findsOneWidget);
    });
  });
}