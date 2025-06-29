import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/category_repository.dart';
import '../../domain/entities/category.dart';
import 'categories_event.dart';
import 'categories_state.dart';

@singleton
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryRepository _categoryRepository;
  
  CategoriesBloc(this._categoryRepository) : super(const CategoriesState.initial()) {
    on<LoadCategories>(_onLoadCategories);
    on<RefreshCategories>(_onRefreshCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    
    // Load categories immediately on construction
    add(const CategoriesEvent.loadCategories());
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    // Only load if not already loaded or if cache is expired
    if (state is CategoriesLoaded && !state.isExpired) {
      return;
    }

    emit(const CategoriesState.loading());
    
    try {
      final categories = await _categoryRepository.getAllCategories();
      final categoriesMap = {for (var c in categories) c.id!: c};
      
      emit(CategoriesState.loaded(
        categories: categoriesMap,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(CategoriesState.error('Failed to load categories: $e'));
    }
  }

  Future<void> _onRefreshCategories(
    RefreshCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesState.loading());
    
    try {
      final categories = await _categoryRepository.getAllCategories();
      final categoriesMap = {for (var c in categories) c.id!: c};
      
      emit(CategoriesState.loaded(
        categories: categoriesMap,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(CategoriesState.error('Failed to refresh categories: $e'));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      final createdCategory = await _categoryRepository.createCategory(event.category);
      
      // Update cache with new category
      if (state is CategoriesLoaded) {
        final currentState = state as CategoriesLoaded;
        final updatedCategories = Map<int, Category>.from(currentState.categories);
        updatedCategories[createdCategory.id!] = createdCategory;
        
        emit(CategoriesState.loaded(
          categories: updatedCategories,
          lastUpdated: DateTime.now(),
        ));
      } else {
        // If not loaded, trigger a load
        add(const CategoriesEvent.loadCategories());
      }
    } catch (e) {
      emit(CategoriesState.error('Failed to create category: $e'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      final updatedCategory = await _categoryRepository.updateCategory(event.category);
      
      // Update cache with updated category
      if (state is CategoriesLoaded) {
        final currentState = state as CategoriesLoaded;
        final updatedCategories = Map<int, Category>.from(currentState.categories);
        updatedCategories[updatedCategory.id!] = updatedCategory;
        
        emit(CategoriesState.loaded(
          categories: updatedCategories,
          lastUpdated: DateTime.now(),
        ));
      } else {
        // If not loaded, trigger a load
        add(const CategoriesEvent.loadCategories());
      }
    } catch (e) {
      emit(CategoriesState.error('Failed to update category: $e'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      await _categoryRepository.deleteCategory(event.id);
      
      // Remove from cache
      if (state is CategoriesLoaded) {
        final currentState = state as CategoriesLoaded;
        final updatedCategories = Map<int, Category>.from(currentState.categories);
        updatedCategories.remove(event.id);
        
        emit(CategoriesState.loaded(
          categories: updatedCategories,
          lastUpdated: DateTime.now(),
        ));
      } else {
        // If not loaded, trigger a load
        add(const CategoriesEvent.loadCategories());
      }
    } catch (e) {
      emit(CategoriesState.error('Failed to delete category: $e'));
    }
  }
}