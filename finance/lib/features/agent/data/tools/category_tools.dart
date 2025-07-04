import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/services/database_tool.dart';
import '../../domain/entities/ai_tool_call.dart';

/// Tool for querying and searching categories
class QueryCategoriesTool extends FinancialDataTool {
  final CategoryRepository _categoryRepository;

  QueryCategoriesTool(this._categoryRepository);

  @override
  String get name => 'query_categories';

  @override
  String get description => 
      'Search and filter categories by type (expense/income), keyword, or default status';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'query_type': {
        'type': 'string',
        'enum': ['all', 'expense', 'income', 'default', 'by_keyword', 'by_id'],
        'description': 'Type of query to perform',
      },
      'keyword': {
        'type': 'string',
        'description': 'Search keyword for category name',
      },
      'category_id': {
        'type': 'integer',
        'description': 'Specific category ID to retrieve',
      },
      'include_usage_stats': {
        'type': 'boolean',
        'description': 'Include transaction count and usage statistics',
        'default': false,
      },
    },
    'required': ['query_type'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'categories',
      'access_level': 'read',
    },
  );

  @override
  bool get requiresAccountAccess => false;

  @override
  bool get canModifyData => false;

  @override
  List<String> get accessibleEntities => ['categories'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    final queryType = parameters['query_type'] as String;
    
    try {
      List<Category> categories;
      
      switch (queryType) {
        case 'all':
          categories = await _categoryRepository.getAllCategories();
          break;
          
        case 'expense':
          categories = await _categoryRepository.getExpenseCategories();
          break;
          
        case 'income':
          categories = await _categoryRepository.getIncomeCategories();
          break;
          
        case 'default':
          final allCategories = await _categoryRepository.getAllCategories();
          categories = allCategories.where((c) => c.isDefault).toList();
          break;
          
        case 'by_keyword':
          final keyword = (parameters['keyword'] as String).toLowerCase();
          final allCategories = await _categoryRepository.getAllCategories();
          categories = allCategories.where((c) => 
            c.name.toLowerCase().contains(keyword)
          ).toList();
          break;
          
        case 'by_id':
          final categoryId = parameters['category_id'] as int;
          final category = await _categoryRepository.getCategoryById(categoryId);
          categories = category != null ? [category] : [];
          break;
          
        default:
          throw ArgumentError('Invalid query_type: $queryType');
      }
      
      final includeUsageStats = parameters['include_usage_stats'] as bool? ?? false;
      
      return {
        'success': true,
        'count': categories.length,
        'categories': categories.map((c) => _categoryToMap(c, includeUsageStats)).toList(),
        'query_info': {
          'query_type': queryType,
          'filters_applied': parameters.keys.where((k) => k != 'query_type').toList(),
        },
        'summary': {
          'expense_categories': categories.where((c) => c.isExpense).length,
          'income_categories': categories.where((c) => !c.isExpense).length,
          'default_categories': categories.where((c) => c.isDefault).length,
        },
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to query categories: ${e.toString()}',
        'query_type': queryType,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('query_type')) return false;
    
    final queryType = parameters['query_type'] as String?;
    
    switch (queryType) {
      case 'by_keyword':
        return parameters.containsKey('keyword') && parameters['keyword'] is String;
      case 'by_id':
        return parameters.containsKey('category_id') && parameters['category_id'] is int;
      case 'all':
      case 'expense':
      case 'income':
      case 'default':
        return true;
      default:
        return false;
    }
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Get all categories',
      'parameters': {'query_type': 'all'},
    },
    {
      'description': 'Get expense categories only',
      'parameters': {'query_type': 'expense'},
    },
    {
      'description': 'Get income categories only',
      'parameters': {'query_type': 'income'},
    },
    {
      'description': 'Search for food categories',
      'parameters': {'query_type': 'by_keyword', 'keyword': 'food'},
    },
    {
      'description': 'Get categories with usage statistics',
      'parameters': {'query_type': 'all', 'include_usage_stats': true},
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    return true; // Read operations don't need financial validation
  }

  Map<String, dynamic> _categoryToMap(Category category, bool includeUsageStats) {
    final map = {
      'id': category.id,
      'name': category.name,
      'icon': category.icon,
      'color': '#${(category.color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
      'is_expense': category.isExpense,
      'is_default': category.isDefault,
      'created_at': category.createdAt.toIso8601String(),
      'updated_at': category.updatedAt.toIso8601String(),
    };
    
    // Note: Usage stats would require TransactionRepository access
    // This is a placeholder for future implementation
    if (includeUsageStats) {
      map['usage_stats'] = {
        'transaction_count': 0, // Would be calculated from transaction repository
        'total_amount': 0.0,
        'last_used': null,
      };
    }
    
    return map;
  }
}

/// Tool for creating new categories
class CreateCategoryTool extends FinancialDataTool {
  final CategoryRepository _categoryRepository;
  final _uuid = const Uuid();

  CreateCategoryTool(this._categoryRepository);

  @override
  String get name => 'create_category';

  @override
  String get description => 
      'Create a new category for organizing transactions with custom name, icon, and color';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'name': {
        'type': 'string',
        'description': 'Category name (e.g., "Groceries", "Salary", "Entertainment")',
        'minLength': 1,
      },
      'is_expense': {
        'type': 'boolean',
        'description': 'Whether this is an expense category (true) or income category (false)',
        'default': true,
      },
      'icon': {
        'type': 'string',
        'description': 'Icon name or identifier (e.g., "shopping_cart", "restaurant", "home")',
      },
      'color': {
        'type': 'string',
        'description': 'Category color as hex code (e.g., "#4CAF50", "#2196F3")',
      },
      'is_default': {
        'type': 'boolean',
        'description': 'Whether this should be a default category',
        'default': false,
      },
    },
    'required': ['name'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'categories',
      'access_level': 'write',
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['categories'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final now = DateTime.now();
      final colorString = parameters['color'] as String?;
      final iconString = parameters['icon'] as String?;
      
      Color categoryColor = Colors.blue; // Default color
      if (colorString != null) {
        try {
          final hexCode = colorString.replaceAll('#', '');
          categoryColor = Color(int.parse('FF$hexCode', radix: 16));
        } catch (e) {
          return {
            'success': false,
            'error': 'Invalid color format. Use hex format like #4CAF50',
          };
        }
      }

      final category = Category(
        name: parameters['name'] as String,
        icon: iconString ?? 'category', // Default icon
        color: categoryColor,
        isExpense: parameters['is_expense'] as bool? ?? true,
        isDefault: parameters['is_default'] as bool? ?? false,
        createdAt: now,
        updatedAt: now,
        syncId: _uuid.v4(),
      );

      final createdCategory = await _categoryRepository.createCategory(category);

      return {
        'success': true,
        'category': _categoryToMap(createdCategory),
        'message': 'Category created successfully',
        'type': createdCategory.isExpense ? 'expense' : 'income',
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to create category: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('name')) return false;
    
    if (parameters['name'] is! String || (parameters['name'] as String).isEmpty) {
      return false;
    }
    
    return true;
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Create a groceries expense category',
      'parameters': {
        'name': 'Groceries',
        'is_expense': true,
        'icon': 'shopping_cart',
        'color': '#4CAF50',
      },
    },
    {
      'description': 'Create a salary income category',
      'parameters': {
        'name': 'Salary',
        'is_expense': false,
        'icon': 'work',
        'color': '#2196F3',
      },
    },
    {
      'description': 'Create an entertainment expense category',
      'parameters': {
        'name': 'Entertainment',
        'is_expense': true,
        'icon': 'movie',
        'color': '#FF5722',
      },
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    return true; // Category creation doesn't involve financial amounts
  }

  Map<String, dynamic> _categoryToMap(Category category) {
    return {
      'id': category.id,
      'name': category.name,
      'icon': category.icon,
      'color': '#${(category.color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
      'is_expense': category.isExpense,
      'is_default': category.isDefault,
      'created_at': category.createdAt.toIso8601String(),
    };
  }
}

/// Tool for updating existing categories
class UpdateCategoryTool extends FinancialDataTool {
  final CategoryRepository _categoryRepository;

  UpdateCategoryTool(this._categoryRepository);

  @override
  String get name => 'update_category';

  @override
  String get description => 
      'Update an existing category by ID with new values';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'category_id': {
        'type': 'integer',
        'description': 'ID of the category to update',
      },
      'name': {
        'type': 'string',
        'description': 'New category name',
      },
      'icon': {
        'type': 'string',
        'description': 'New icon name or identifier',
      },
      'color': {
        'type': 'string',
        'description': 'New category color as hex code',
      },
      'is_expense': {
        'type': 'boolean',
        'description': 'Whether this is an expense category',
      },
      'is_default': {
        'type': 'boolean',
        'description': 'Whether this should be a default category',
      },
    },
    'required': ['category_id'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'categories',
      'access_level': 'write',
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['categories'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final categoryId = parameters['category_id'] as int;
      
      final existingCategory = await _categoryRepository.getCategoryById(categoryId);
      if (existingCategory == null) {
        return {
          'success': false,
          'error': 'Category with ID $categoryId not found',
        };
      }

      Color? newColor;
      if (parameters.containsKey('color')) {
        try {
          final colorString = parameters['color'] as String;
          final hexCode = colorString.replaceAll('#', '');
          newColor = Color(int.parse('FF$hexCode', radix: 16));
        } catch (e) {
          return {
            'success': false,
            'error': 'Invalid color format. Use hex format like #FF5722',
          };
        }
      }

      final updatedCategory = existingCategory.copyWith(
        name: parameters['name'] as String?,
        icon: parameters['icon'] as String?,
        color: newColor,
        isExpense: parameters['is_expense'] as bool?,
        isDefault: parameters['is_default'] as bool?,
        updatedAt: DateTime.now(),
      );

      final result = await _categoryRepository.updateCategory(updatedCategory);

      return {
        'success': true,
        'category': _categoryToMap(result),
        'message': 'Category updated successfully',
        'changes_made': parameters.keys.where((k) => k != 'category_id').toList(),
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update category: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('category_id') || parameters['category_id'] is! int) {
      return false;
    }
    
    final updateFields = ['name', 'icon', 'color', 'is_expense', 'is_default'];
    return updateFields.any((field) => parameters.containsKey(field));
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Update category name and color',
      'parameters': {
        'category_id': 123,
        'name': 'Food & Dining',
        'color': '#FF5722',
      },
    },
    {
      'description': 'Change category icon',
      'parameters': {
        'category_id': 456,
        'icon': 'restaurant',
      },
    },
    {
      'description': 'Convert expense category to income category',
      'parameters': {
        'category_id': 789,
        'is_expense': false,
      },
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    return true;
  }

  Map<String, dynamic> _categoryToMap(Category category) {
    return {
      'id': category.id,
      'name': category.name,
      'icon': category.icon,
      'color': '#${(category.color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
      'is_expense': category.isExpense,
      'is_default': category.isDefault,
      'updated_at': category.updatedAt.toIso8601String(),
    };
  }
}

/// Tool for deleting categories
class DeleteCategoryTool extends FinancialDataTool {
  final CategoryRepository _categoryRepository;

  DeleteCategoryTool(this._categoryRepository);

  @override
  String get name => 'delete_category';

  @override
  String get description => 
      'Delete a category by ID. Use with caution as this action cannot be undone and will affect related transactions.';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'category_id': {
        'type': 'integer',
        'description': 'ID of the category to delete',
      },
      'confirm': {
        'type': 'boolean',
        'description': 'Confirmation that user wants to delete the category',
      },
    },
    'required': ['category_id', 'confirm'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'categories',
      'access_level': 'delete',
      'requires_confirmation': true,
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['categories'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final categoryId = parameters['category_id'] as int;
      final confirm = parameters['confirm'] as bool;

      if (!confirm) {
        return {
          'success': false,
          'error': 'Deletion not confirmed. Set confirm parameter to true to proceed.',
        };
      }

      final existingCategory = await _categoryRepository.getCategoryById(categoryId);
      if (existingCategory == null) {
        return {
          'success': false,
          'error': 'Category with ID $categoryId not found',
        };
      }

      await _categoryRepository.deleteCategory(categoryId);

      return {
        'success': true,
        'message': 'Category deleted successfully',
        'deleted_category': {
          'id': categoryId,
          'name': existingCategory.name,
          'type': existingCategory.isExpense ? 'expense' : 'income',
        },
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to delete category: ${e.toString()}',
        'category_id': parameters['category_id'],
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    return parameters.containsKey('category_id') && 
           parameters['category_id'] is int &&
           parameters.containsKey('confirm') &&
           parameters['confirm'] is bool;
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Delete a category with confirmation',
      'parameters': {
        'category_id': 789,
        'confirm': true,
      },
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    return true;
  }
}

/// Tool for category insights and financial analysis
class CategoryInsightsTool extends FinancialDataTool {
  final CategoryRepository _categoryRepository;
  final TransactionRepository _transactionRepository;

  CategoryInsightsTool(this._categoryRepository, this._transactionRepository);

  @override
  String get name => 'category_insights';

  @override
  String get description => 
      'Get financial insights and analytics about categories including spending patterns and trends';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'analysis_type': {
        'type': 'string',
        'enum': ['spending_overview', 'category_usage', 'top_categories', 'category_trends'],
        'description': 'Type of analysis to perform',
      },
      'category_id': {
        'type': 'integer',
        'description': 'Specific category ID for detailed analysis',
      },
      'start_date': {
        'type': 'string',
        'format': 'date',
        'description': 'Start date for analysis period (YYYY-MM-DD)',
      },
      'end_date': {
        'type': 'string',
        'format': 'date',
        'description': 'End date for analysis period (YYYY-MM-DD)',
      },
      'limit': {
        'type': 'integer',
        'description': 'Limit number of results (for top_categories)',
        'minimum': 1,
        'maximum': 20,
        'default': 10,
      },
    },
    'required': ['analysis_type'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'categories',
      'access_level': 'read',
      'provides_insights': true,
    },
  );

  @override
  bool get requiresAccountAccess => false;

  @override
  bool get canModifyData => false;

  @override
  List<String> get accessibleEntities => ['categories', 'transactions'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final analysisType = parameters['analysis_type'] as String;
      final startDate = parameters.containsKey('start_date') 
          ? DateTime.parse(parameters['start_date'] as String)
          : null;
      final endDate = parameters.containsKey('end_date')
          ? DateTime.parse(parameters['end_date'] as String)
          : null;

      switch (analysisType) {
        case 'spending_overview':
          return await _getSpendingOverview(startDate, endDate);

        case 'category_usage':
          final categoryId = parameters['category_id'] as int?;
          return await _getCategoryUsage(categoryId, startDate, endDate);

        case 'top_categories':
          final limit = parameters['limit'] as int? ?? 10;
          return await _getTopCategories(limit, startDate, endDate);

        case 'category_trends':
          return await _getCategoryTrends(startDate, endDate);

        default:
          return {
            'success': false,
            'error': 'Invalid analysis_type: $analysisType',
          };
      }

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to perform category insights: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('analysis_type')) return false;
    
    final analysisType = parameters['analysis_type'] as String?;
    
    if (analysisType == 'category_usage' && parameters.containsKey('category_id')) {
      return parameters['category_id'] is int;
    }
    
    return ['spending_overview', 'category_usage', 'top_categories', 'category_trends']
        .contains(analysisType);
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Get spending overview by categories',
      'parameters': {'analysis_type': 'spending_overview'},
    },
    {
      'description': 'Get usage stats for a specific category',
      'parameters': {'analysis_type': 'category_usage', 'category_id': 1},
    },
    {
      'description': 'Get top 5 spending categories this month',
      'parameters': {
        'analysis_type': 'top_categories',
        'limit': 5,
        'start_date': '2024-01-01',
        'end_date': '2024-01-31',
      },
    },
    {
      'description': 'Get category spending trends',
      'parameters': {'analysis_type': 'category_trends'},
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    return true;
  }

  Future<Map<String, dynamic>> _getSpendingOverview(DateTime? startDate, DateTime? endDate) async {
    final categories = await _categoryRepository.getAllCategories();
    final spendingData = await _transactionRepository.getSpendingByCategory(startDate, endDate);
    
    final categoryAnalysis = <Map<String, dynamic>>[];
    double totalSpending = 0.0;
    
    for (final category in categories) {
      if (category.isExpense) {
        final spending = spendingData[category.id] ?? 0.0;
        totalSpending += spending.abs();
        
        categoryAnalysis.add({
          'category_id': category.id,
          'category_name': category.name,
          'amount_spent': spending.abs(),
          'percentage': 0.0, // Will be calculated after total is known
        });
      }
    }
    
    // Calculate percentages
    for (final analysis in categoryAnalysis) {
      final spent = analysis['amount_spent'] as double;
      analysis['percentage'] = totalSpending > 0 ? (spent / totalSpending) * 100 : 0.0;
    }
    
    // Sort by spending amount
    categoryAnalysis.sort((a, b) => (b['amount_spent'] as double).compareTo(a['amount_spent'] as double));

    return {
      'success': true,
      'analysis_type': 'spending_overview',
      'period': _formatDateRange(startDate, endDate),
      'summary': {
        'total_spending': totalSpending,
        'categories_with_spending': categoryAnalysis.where((c) => (c['amount_spent'] as double) > 0).length,
        'total_categories': categories.where((c) => c.isExpense).length,
      },
      'category_breakdown': categoryAnalysis,
    };
  }

  Future<Map<String, dynamic>> _getCategoryUsage(int? categoryId, DateTime? startDate, DateTime? endDate) async {
    if (categoryId == null) {
      return {
        'success': false,
        'error': 'category_id is required for category_usage analysis',
      };
    }

    final category = await _categoryRepository.getCategoryById(categoryId);
    if (category == null) {
      return {
        'success': false,
        'error': 'Category with ID $categoryId not found',
      };
    }

    final total = await _transactionRepository.getTotalByCategory(categoryId, startDate, endDate);
    final allTransactions = startDate != null && endDate != null
        ? await _transactionRepository.getTransactionsByDateRange(startDate, endDate)
        : await _transactionRepository.getAllTransactions();
    
    final categoryTransactions = allTransactions.where((t) => t.categoryId == categoryId).toList();

    return {
      'success': true,
      'analysis_type': 'category_usage',
      'category': {
        'id': category.id,
        'name': category.name,
        'type': category.isExpense ? 'expense' : 'income',
      },
      'period': _formatDateRange(startDate, endDate),
      'usage_stats': {
        'transaction_count': categoryTransactions.length,
        'total_amount': total.abs(),
        'average_amount': categoryTransactions.isNotEmpty ? total.abs() / categoryTransactions.length : 0.0,
        'first_used': categoryTransactions.isNotEmpty 
            ? categoryTransactions.map((t) => t.date).reduce((a, b) => a.isBefore(b) ? a : b).toIso8601String().split('T')[0]
            : null,
        'last_used': categoryTransactions.isNotEmpty 
            ? categoryTransactions.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String().split('T')[0]
            : null,
      },
    };
  }

  Future<Map<String, dynamic>> _getTopCategories(int limit, DateTime? startDate, DateTime? endDate) async {
    final categories = await _categoryRepository.getAllCategories();
    final spendingData = await _transactionRepository.getSpendingByCategory(startDate, endDate);
    
    final categorySpending = <Map<String, dynamic>>[];
    
    for (final category in categories) {
      final spending = spendingData[category.id] ?? 0.0;
      if (spending != 0.0) {
        categorySpending.add({
          'category_id': category.id,
          'category_name': category.name,
          'type': category.isExpense ? 'expense' : 'income',
          'amount': spending.abs(),
        });
      }
    }
    
    // Sort by amount and take top N
    categorySpending.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    final topCategories = categorySpending.take(limit).toList();

    return {
      'success': true,
      'analysis_type': 'top_categories',
      'period': _formatDateRange(startDate, endDate),
      'limit': limit,
      'top_categories': topCategories,
    };
  }

  Future<Map<String, dynamic>> _getCategoryTrends(DateTime? startDate, DateTime? endDate) async {
    final categories = await _categoryRepository.getAllCategories();
    final expenseCategories = categories.where((c) => c.isExpense).toList();
    
    // For simplicity, we'll show current vs previous period comparison
    final now = DateTime.now();
    final defaultEndDate = endDate ?? now;
    final defaultStartDate = startDate ?? DateTime(now.year, now.month - 1, now.day);
    
    final previousStart = DateTime(
      defaultStartDate.year,
      defaultStartDate.month - 1,
      defaultStartDate.day,
    );
    final previousEnd = DateTime(
      defaultEndDate.year,
      defaultEndDate.month - 1,
      defaultEndDate.day,
    );

    final currentSpending = await _transactionRepository.getSpendingByCategory(defaultStartDate, defaultEndDate);
    final previousSpending = await _transactionRepository.getSpendingByCategory(previousStart, previousEnd);

    final trends = <Map<String, dynamic>>[];
    
    for (final category in expenseCategories) {
      final currentAmount = (currentSpending[category.id] ?? 0.0).abs();
      final previousAmount = (previousSpending[category.id] ?? 0.0).abs();
      
      final change = currentAmount - previousAmount;
      final changePercentage = previousAmount > 0 ? (change / previousAmount) * 100 : 0.0;
      
      trends.add({
        'category_id': category.id,
        'category_name': category.name,
        'current_amount': currentAmount,
        'previous_amount': previousAmount,
        'change': change,
        'change_percentage': changePercentage,
        'trend': change > 0 ? 'increasing' : change < 0 ? 'decreasing' : 'stable',
      });
    }

    // Sort by absolute change
    trends.sort((a, b) => (b['change'] as double).abs().compareTo((a['change'] as double).abs()));

    return {
      'success': true,
      'analysis_type': 'category_trends',
      'current_period': _formatDateRange(defaultStartDate, defaultEndDate),
      'previous_period': _formatDateRange(previousStart, previousEnd),
      'trends': trends,
    };
  }

  String _formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) return 'All time';
    if (startDate == null) return 'Until ${endDate!.toIso8601String().split('T')[0]}';
    if (endDate == null) return 'From ${startDate.toIso8601String().split('T')[0]}';
    return '${startDate.toIso8601String().split('T')[0]} to ${endDate.toIso8601String().split('T')[0]}';
  }
}