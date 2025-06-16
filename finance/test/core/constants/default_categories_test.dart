import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/database/app_database.dart';
import 'package:finance/core/constants/default_categories.dart';
import 'package:drift/native.dart';

void main() {  group('Default Categories Tests', () {
    late AppDatabase database;

    setUp(() async {
      // Create an in-memory database for testing
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('should have correct number of default categories', () {
      expect(DefaultCategories.incomeCategories.length, 5);
      expect(DefaultCategories.expenseCategories.length, 17);
      expect(DefaultCategories.allCategories.length, 22);
    });

    test('should have emoji icons for all categories', () {
      for (final category in DefaultCategories.allCategories) {
        // Check that icon is a single emoji character (emojis are typically 1-2 UTF-16 code units)
        expect(category.emoji.isNotEmpty, true);
        expect(category.emoji.length, lessThanOrEqualTo(4)); // Allow for complex emojis
        
        // Check that it's not a Material Icon name (emojis don't contain underscores)
        expect(category.emoji.contains('_'), false);
      }
    });

    test('should have unique sync IDs', () {
      final syncIds = DefaultCategories.allCategories.map((c) => c.syncId).toList();
      final uniqueSyncIds = syncIds.toSet();
      expect(syncIds.length, uniqueSyncIds.length);
    });

    test('should have correct income and expense categories', () {
      final incomeCategories = DefaultCategories.allCategories.where((c) => !c.isExpense).toList();
      final expenseCategories = DefaultCategories.allCategories.where((c) => c.isExpense).toList();
      
      expect(incomeCategories.length, 5);
      expect(expenseCategories.length, 17);
      
      // Check specific categories exist
      expect(incomeCategories.any((c) => c.name.contains('Lương') && c.emoji == '💰'), true);
      expect(expenseCategories.any((c) => c.name.contains('Ăn uống') && c.emoji == '🍽️'), true);
    });

    test('should use emoji icons instead of Material Icons', () {
      // Sample of old Material Icon names that should NOT be present
      final oldIconNames = ['restaurant', 'directions_car', 'shopping_bag', 'work', 'movie'];
      
      for (final category in DefaultCategories.allCategories) {
        for (final oldIcon in oldIconNames) {
          expect(category.emoji, isNot(oldIcon));
        }
      }
    });

    test('should have Vietnamese and English names', () {
      // Check that categories have Vietnamese-English format
      for (final category in DefaultCategories.allCategories) {
        expect(category.name.contains(' - '), true, 
               reason: 'Category "${category.name}" should have Vietnamese - English format');
      }
    });
  });
}
