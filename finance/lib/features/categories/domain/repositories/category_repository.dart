import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getExpenseCategories();
  Future<List<Category>> getIncomeCategories();
  Future<Category?> getCategoryById(int id);
  Future<Category?> getCategoryBySyncId(String syncId);

  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(int id);
  Future<void> deleteAllCategories();

  // Sync related
  Future<List<Category>> getUnsyncedCategories();
  Future<void> markAsSynced(String syncId, DateTime syncTime);
  Future<void> insertOrUpdateFromSync(Category category);
}
