import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/category.dart';

part 'categories_event.freezed.dart';

@freezed
class CategoriesEvent with _$CategoriesEvent {
  const factory CategoriesEvent.loadCategories() = LoadCategories;
  const factory CategoriesEvent.refreshCategories() = RefreshCategories;
  const factory CategoriesEvent.createCategory(Category category) = CreateCategory;
  const factory CategoriesEvent.updateCategory(Category category) = UpdateCategory;
  const factory CategoriesEvent.deleteCategory(int id) = DeleteCategory;
}