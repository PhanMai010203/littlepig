import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/category.dart';

part 'categories_state.freezed.dart';

@freezed
class CategoriesState with _$CategoriesState {
  const factory CategoriesState.initial() = CategoriesInitial;
  const factory CategoriesState.loading() = CategoriesLoading;
  const factory CategoriesState.loaded({
    required Map<int, Category> categories,
    required DateTime lastUpdated,
  }) = CategoriesLoaded;
  const factory CategoriesState.error(String message) = CategoriesError;
}

extension CategoriesStateExtension on CategoriesState {
  Map<int, Category> get categories => when(
    initial: () => {},
    loading: () => {},
    loaded: (categories, _) => categories,
    error: (_) => {},
  );

  bool get hasCategories => categories.isNotEmpty;
  
  bool get isExpired {
    return when(
      initial: () => true,
      loading: () => false,
      loaded: (_, lastUpdated) => 
        DateTime.now().difference(lastUpdated).inMinutes > 30,
      error: (_) => true,
    );
  }
}