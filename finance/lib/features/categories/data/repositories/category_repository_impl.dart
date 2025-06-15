import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _database;
  final _uuid = const Uuid();

  CategoryRepositoryImpl(this._database);

  @override
  Future<List<Category>> getAllCategories() async {
    final categories = await _database.select(_database.categoriesTable).get();
    return categories.map(_mapToEntity).toList();
  }

  @override
  Future<List<Category>> getExpenseCategories() async {
    final categories = await (_database.select(_database.categoriesTable)
          ..where((tbl) => tbl.isExpense.equals(true)))
        .get();
    return categories.map(_mapToEntity).toList();
  }

  @override
  Future<List<Category>> getIncomeCategories() async {
    final categories = await (_database.select(_database.categoriesTable)
          ..where((tbl) => tbl.isExpense.equals(false)))
        .get();
    return categories.map(_mapToEntity).toList();
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    final category = await (_database.select(_database.categoriesTable)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return category != null ? _mapToEntity(category) : null;
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
      deviceId: category.deviceId,
      syncId: syncId,
      createdAt: Value(category.createdAt),
      updatedAt: Value(now),
    );

    final id = await _database.into(_database.categoriesTable).insert(companion);
    
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
      isSynced: const Value(false), // Mark as unsynced when updated
      version: Value(category.version + 1),
    );

    await (_database.update(_database.categoriesTable)
          ..where((tbl) => tbl.id.equals(category.id!)))
        .write(companion);
    
    return category.copyWith(
      updatedAt: now,
      isSynced: false,
      version: category.version + 1,
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    await (_database.delete(_database.categoriesTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  @override
  Future<List<Category>> getUnsyncedCategories() async {
    final categories = await (_database.select(_database.categoriesTable)
          ..where((tbl) => tbl.isSynced.equals(false)))
        .get();
    return categories.map(_mapToEntity).toList();
  }

  @override
  Future<void> markAsSynced(String syncId, DateTime syncTime) async {
    await (_database.update(_database.categoriesTable)
          ..where((tbl) => tbl.syncId.equals(syncId)))
        .write(CategoriesTableCompanion(
          isSynced: const Value(true),
          lastSyncAt: Value(syncTime),
        ));
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
        deviceId: category.deviceId,
        isSynced: const Value(true),
        lastSyncAt: Value(category.lastSyncAt),
        syncId: category.syncId,
        version: Value(category.version),
      );
      await _database.into(_database.categoriesTable).insert(companion);
    } else if (category.version > existing.version) {
      // Update existing category if incoming version is newer
      final companion = CategoriesTableCompanion(
        id: Value(existing.id!),
        name: Value(category.name),
        icon: Value(category.icon),
        color: Value(category.color.value),
        isExpense: Value(category.isExpense),
        isDefault: Value(category.isDefault),
        updatedAt: Value(category.updatedAt),
        isSynced: const Value(true),
        lastSyncAt: Value(category.lastSyncAt),
        version: Value(category.version),
      );
      
      await (_database.update(_database.categoriesTable)
            ..where((tbl) => tbl.id.equals(existing.id!)))
          .write(companion);
    }
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
      deviceId: data.deviceId,
      isSynced: data.isSynced,
      lastSyncAt: data.lastSyncAt,
      syncId: data.syncId,
      version: data.version,
    );
  }
}
