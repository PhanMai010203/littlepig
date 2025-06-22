import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/repositories/cacheable_repository_mixin.dart';

class CategoryRepositoryImpl with CacheableRepositoryMixin implements CategoryRepository {
  final AppDatabase _database;
  final _uuid = const Uuid();

  CategoryRepositoryImpl(this._database);

  @override
  Future<List<Category>> getAllCategories() async {
    return cacheRead('getAllCategories', () async {
      final categories = await _database.select(_database.categoriesTable).get();
      return categories.map(_mapToEntity).toList();
    });
  }

  @override
  Future<List<Category>> getExpenseCategories() async {
    return cacheRead('getExpenseCategories', () async {
      final categories = await (_database.select(_database.categoriesTable)
            ..where((tbl) => tbl.isExpense.equals(true)))
          .get();
      return categories.map(_mapToEntity).toList();
    });
  }

  @override
  Future<List<Category>> getIncomeCategories() async {
    return cacheRead('getIncomeCategories', () async {
      final categories = await (_database.select(_database.categoriesTable)
            ..where((tbl) => tbl.isExpense.equals(false)))
          .get();
      return categories.map(_mapToEntity).toList();
    });
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    return cacheReadSingle(
      'getCategoryById',
      () async {
        final category = await (_database.select(_database.categoriesTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
        return category != null ? _mapToEntity(category) : null;
      },
      params: {'id': id},
    );
  }

  @override
  Future<Category?> getCategoryBySyncId(String syncId) async {
    final category = await (_database.select(_database.categoriesTable)
          ..where((tbl) => tbl.syncId.equals(syncId)))
        .getSingleOrNull();
    return category != null ? _mapToEntity(category) : null;
  }

  @override
  Future<Category> createCategory(Category category) async {
    final now = DateTime.now();
    final syncId = category.syncId.isEmpty ? _uuid.v4() : category.syncId;

    final companion = CategoriesTableCompanion.insert(
      name: category.name,
      icon: category.icon,
      color: category.color.value,
      isExpense: category.isExpense,
      isDefault: Value(category.isDefault),
      createdAt: Value(category.createdAt),
      updatedAt: Value(now),
      syncId: syncId,
    );

    final id =
        await _database.into(_database.categoriesTable).insert(companion);

    await invalidateEntityCache('category');

    return category.copyWith(
      id: id,
      syncId: syncId,
      updatedAt: now,
    );
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final now = DateTime.now();
    final companion = CategoriesTableCompanion(
      id: Value(category.id!),
      name: Value(category.name),
      icon: Value(category.icon),
      color: Value(category.color.value),
      isExpense: Value(category.isExpense),
      isDefault: Value(category.isDefault),
      updatedAt: Value(now),
    );

    await (_database.update(_database.categoriesTable)
          ..where((tbl) => tbl.id.equals(category.id!)))
        .write(companion);

    await invalidateCache('category', id: category.id);

    return category.copyWith(updatedAt: now);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await (_database.delete(_database.categoriesTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
    await invalidateCache('category', id: id);
  }

  @override
  Future<List<Category>> getUnsyncedCategories() async {
    final categories = await _database.select(_database.categoriesTable).get();
    return categories.map(_mapToEntity).toList();
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    // ✅ PHASE 4: No-op since sync fields removed from table
    // Event sourcing tracks sync status in sync_event_log table
    // This method kept for backward compatibility
  }

  @override
  Future<void> insertOrUpdateFromSync(Category category) async {
    final existing = await getCategoryBySyncId(category.syncId);

    if (existing == null) {
      // Insert new category from sync
      final companion = CategoriesTableCompanion.insert(
        name: category.name,
        icon: category.icon,
        color: category.color.value,
        isExpense: category.isExpense,
        isDefault: Value(category.isDefault),
        createdAt: Value(category.createdAt),
        updatedAt: Value(category.updatedAt),
        syncId: category.syncId,
      );
      await _database.into(_database.categoriesTable).insert(companion);
    } else {
      // ✅ PHASE 4: Always update with newer data from sync (no version comparison needed)
      final companion = CategoriesTableCompanion(
        id: Value(existing.id!),
        name: Value(category.name),
        icon: Value(category.icon),
        color: Value(category.color.value),
        isExpense: Value(category.isExpense),
        isDefault: Value(category.isDefault),
        updatedAt: Value(category.updatedAt),
      );

      await (_database.update(_database.categoriesTable)
            ..where((tbl) => tbl.id.equals(existing.id!)))
          .write(companion);
    }
    await invalidateEntityCache('category');
  }

  Category _mapToEntity(CategoriesTableData data) {
    return Category(
      id: data.id,
      name: data.name,
      icon: data.icon,
      color: Color(data.color),
      isExpense: data.isExpense,
      isDefault: data.isDefault,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      syncId: data.syncId,
    );
  }
}
