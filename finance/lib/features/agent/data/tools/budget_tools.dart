import 'package:uuid/uuid.dart';
import '../../../budgets/domain/repositories/budget_repository.dart';
import '../../../budgets/domain/entities/budget.dart';
import '../../domain/services/database_tool.dart';
import '../../domain/entities/ai_tool_call.dart';

/// Tool for querying and searching budgets
class QueryBudgetsTool extends FinancialDataTool {
  final BudgetRepository _budgetRepository;

  QueryBudgetsTool(this._budgetRepository);

  @override
  String get name => 'query_budgets';

  @override
  String get description => 
      'Search and filter budgets by various criteria like active status, category, period, or keywords';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'query_type': {
        'type': 'string',
        'enum': ['all', 'active', 'by_category', 'by_period', 'by_keyword', 'by_id'],
        'description': 'Type of query to perform',
      },
      'category_id': {
        'type': 'integer',
        'description': 'Filter by specific category ID (required for by_category)',
      },
      'period': {
        'type': 'string',
        'enum': ['daily', 'weekly', 'monthly', 'yearly'],
        'description': 'Filter by budget period (required for by_period)',
      },
      'keyword': {
        'type': 'string',
        'description': 'Search keyword for budget name',
      },
      'budget_id': {
        'type': 'integer',
        'description': 'Specific budget ID to retrieve (required for by_id)',
      },
      'include_inactive': {
        'type': 'boolean',
        'description': 'Include inactive budgets in results',
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
      'category': 'budgets',
      'access_level': 'read',
    },
  );

  @override
  bool get requiresAccountAccess => false;

  @override
  bool get canModifyData => false;

  @override
  List<String> get accessibleEntities => ['budgets'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    final queryType = parameters['query_type'] as String;
    
    try {
      List<Budget> budgets;
      
      switch (queryType) {
        case 'all':
          budgets = await _budgetRepository.getAllBudgets();
          break;
          
        case 'active':
          budgets = await _budgetRepository.getActiveBudgets();
          break;
          
        case 'by_category':
          final categoryId = parameters['category_id'] as int;
          budgets = await _budgetRepository.getBudgetsByCategory(categoryId);
          break;
          
        case 'by_period':
          final period = _parseBudgetPeriod(parameters['period'] as String);
          final allBudgets = await _budgetRepository.getAllBudgets();
          budgets = allBudgets.where((b) => b.period == period).toList();
          break;
          
        case 'by_keyword':
          final keyword = (parameters['keyword'] as String).toLowerCase();
          final allBudgets = await _budgetRepository.getAllBudgets();
          budgets = allBudgets.where((b) => 
            b.name.toLowerCase().contains(keyword)
          ).toList();
          break;
          
        case 'by_id':
          final budgetId = parameters['budget_id'] as int;
          final budget = await _budgetRepository.getBudgetById(budgetId);
          budgets = budget != null ? [budget] : [];
          break;
          
        default:
          throw ArgumentError('Invalid query_type: $queryType');
      }
      
      // Filter inactive budgets unless specifically requested
      final includeInactive = parameters['include_inactive'] as bool? ?? false;
      if (!includeInactive) {
        budgets = budgets.where((b) => b.isActive).toList();
      }
      
      return {
        'success': true,
        'count': budgets.length,
        'budgets': budgets.map((b) => _budgetToMap(b)).toList(),
        'query_info': {
          'query_type': queryType,
          'filters_applied': parameters.keys.where((k) => k != 'query_type').toList(),
        },
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to query budgets: ${e.toString()}',
        'query_type': queryType,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('query_type')) return false;
    
    final queryType = parameters['query_type'] as String?;
    
    switch (queryType) {
      case 'by_category':
        return parameters.containsKey('category_id') && parameters['category_id'] is int;
      case 'by_period':
        return parameters.containsKey('period') && 
               ['daily', 'weekly', 'monthly', 'yearly'].contains(parameters['period']);
      case 'by_keyword':
        return parameters.containsKey('keyword') && parameters['keyword'] is String;
      case 'by_id':
        return parameters.containsKey('budget_id') && parameters['budget_id'] is int;
      case 'all':
      case 'active':
        return true;
      default:
        return false;
    }
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Get all active budgets',
      'parameters': {'query_type': 'active'},
    },
    {
      'description': 'Get budgets for a specific category',
      'parameters': {'query_type': 'by_category', 'category_id': 1},
    },
    {
      'description': 'Get monthly budgets',
      'parameters': {'query_type': 'by_period', 'period': 'monthly'},
    },
    {
      'description': 'Search for grocery budgets',
      'parameters': {'query_type': 'by_keyword', 'keyword': 'grocery'},
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

  BudgetPeriod _parseBudgetPeriod(String period) {
    switch (period.toLowerCase()) {
      case 'daily':
        return BudgetPeriod.daily;
      case 'weekly':
        return BudgetPeriod.weekly;
      case 'monthly':
        return BudgetPeriod.monthly;
      case 'yearly':
        return BudgetPeriod.yearly;
      default:
        return BudgetPeriod.monthly;
    }
  }

  Map<String, dynamic> _budgetToMap(Budget budget) {
    return {
      'id': budget.id,
      'name': budget.name,
      'amount': budget.amount,
      'spent': budget.spent,
      'remaining': budget.remaining,
      'percentage_spent': budget.percentageSpent,
      'is_over_budget': budget.isOverBudget,
      'category_id': budget.categoryId,
      'period': budget.period.toString().split('.').last,
      'period_amount': budget.periodAmount,
      'start_date': budget.startDate.toIso8601String().split('T')[0],
      'end_date': budget.endDate.toIso8601String().split('T')[0],
      'is_active': budget.isActive,
      'is_income_budget': budget.isIncomeBudget,
      'manual_add_mode': budget.manualAddMode,
      'created_at': budget.createdAt.toIso8601String(),
      'updated_at': budget.updatedAt.toIso8601String(),
      'colour': budget.colour,
    };
  }
}

/// Tool for creating new budgets
class CreateBudgetTool extends FinancialDataTool {
  final BudgetRepository _budgetRepository;
  final _uuid = const Uuid();

  CreateBudgetTool(this._budgetRepository);

  @override
  String get name => 'create_budget';

  @override
  String get description => 
      'Create a new budget with specified amount, period, and tracking criteria';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'name': {
        'type': 'string',
        'description': 'Budget name/title',
        'minLength': 1,
      },
      'amount': {
        'type': 'number',
        'description': 'Budget amount limit',
        'minimum': 0.01,
      },
      'period': {
        'type': 'string',
        'enum': ['daily', 'weekly', 'monthly', 'yearly'],
        'description': 'Budget period type',
      },
      'category_id': {
        'type': 'integer',
        'description': 'Category ID to track (optional for global budgets)',
      },
      'start_date': {
        'type': 'string',
        'format': 'date',
        'description': 'Budget start date (YYYY-MM-DD), defaults to today',
      },
      'period_amount': {
        'type': 'integer',
        'description': 'Number of periods (e.g., 2 for "2 months")',
        'minimum': 1,
        'default': 1,
      },
      'is_income_budget': {
        'type': 'boolean',
        'description': 'Whether this is an income budget (vs expense budget)',
        'default': false,
      },
      'colour': {
        'type': 'string',
        'description': 'Budget color as hex code (e.g., "#4CAF50")',
      },
      'wallet_accounts': {
        'type': 'array',
        'items': {'type': 'string'},
        'description': 'Account IDs to track (for automatic mode)',
      },
      'exclude_debt_credit': {
        'type': 'boolean',
        'description': 'Exclude debt/credit installments',
        'default': false,
      },
    },
    'required': ['name', 'amount', 'period'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'budgets',
      'access_level': 'write',
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['budgets'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final now = DateTime.now();
      final startDate = parameters.containsKey('start_date') 
          ? DateTime.parse(parameters['start_date'] as String)
          : now;
          
      final period = _parseBudgetPeriod(parameters['period'] as String);
      final periodAmount = parameters['period_amount'] as int? ?? 1;
      final endDate = _calculateEndDate(startDate, period, periodAmount);

      final budget = Budget(
        name: parameters['name'] as String,
        amount: (parameters['amount'] as num).toDouble(),
        spent: 0.0,
        categoryId: parameters['category_id'] as int?,
        period: period,
        periodAmount: periodAmount,
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        syncId: _uuid.v4(),
        isIncomeBudget: parameters['is_income_budget'] as bool? ?? false,
        colour: parameters['colour'] as String?,
        walletFks: parameters['wallet_accounts'] as List<String>?,
        excludeDebtCreditInstallments: parameters['exclude_debt_credit'] as bool? ?? false,
      );

      final createdBudget = await _budgetRepository.createBudget(budget);

      return {
        'success': true,
        'budget': _budgetToMap(createdBudget),
        'message': 'Budget created successfully',
        'period_info': {
          'period': period.toString().split('.').last,
          'duration': periodAmount,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to create budget: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    final requiredFields = ['name', 'amount', 'period'];
    
    for (final field in requiredFields) {
      if (!parameters.containsKey(field)) return false;
    }
    
    if (parameters['name'] is! String || (parameters['name'] as String).isEmpty) {
      return false;
    }
    
    if (parameters['amount'] is! num || (parameters['amount'] as num) <= 0) {
      return false;
    }
    
    final period = parameters['period'] as String?;
    if (!['daily', 'weekly', 'monthly', 'yearly'].contains(period)) {
      return false;
    }
    
    return true;
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Create a monthly grocery budget',
      'parameters': {
        'name': 'Monthly Groceries',
        'amount': 400.0,
        'period': 'monthly',
        'category_id': 1,
        'colour': '#4CAF50',
      },
    },
    {
      'description': 'Create a yearly vacation budget',
      'parameters': {
        'name': 'Vacation Fund',
        'amount': 3000.0,
        'period': 'yearly',
        'colour': '#2196F3',
      },
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    final amount = data['amount'] as double?;
    if (amount == null || amount <= 0 || amount > 1000000) {
      return false;
    }
    return true;
  }

  BudgetPeriod _parseBudgetPeriod(String period) {
    switch (period.toLowerCase()) {
      case 'daily':
        return BudgetPeriod.daily;
      case 'weekly':
        return BudgetPeriod.weekly;
      case 'monthly':
        return BudgetPeriod.monthly;
      case 'yearly':
        return BudgetPeriod.yearly;
      default:
        return BudgetPeriod.monthly;
    }
  }

  DateTime _calculateEndDate(DateTime startDate, BudgetPeriod period, int periodAmount) {
    switch (period) {
      case BudgetPeriod.daily:
        return startDate.add(Duration(days: periodAmount));
      case BudgetPeriod.weekly:
        return startDate.add(Duration(days: 7 * periodAmount));
      case BudgetPeriod.monthly:
        return DateTime(startDate.year, startDate.month + periodAmount, startDate.day);
      case BudgetPeriod.yearly:
        return DateTime(startDate.year + periodAmount, startDate.month, startDate.day);
    }
  }

  Map<String, dynamic> _budgetToMap(Budget budget) {
    return {
      'id': budget.id,
      'name': budget.name,
      'amount': budget.amount,
      'spent': budget.spent,
      'remaining': budget.remaining,
      'period': budget.period.toString().split('.').last,
      'period_amount': budget.periodAmount,
      'start_date': budget.startDate.toIso8601String().split('T')[0],
      'end_date': budget.endDate.toIso8601String().split('T')[0],
      'is_active': budget.isActive,
      'is_income_budget': budget.isIncomeBudget,
      'manual_add_mode': budget.manualAddMode,
      'colour': budget.colour,
    };
  }
}

/// Tool for updating existing budgets
class UpdateBudgetTool extends FinancialDataTool {
  final BudgetRepository _budgetRepository;

  UpdateBudgetTool(this._budgetRepository);

  @override
  String get name => 'update_budget';

  @override
  String get description => 
      'Update an existing budget by ID with new values';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'budget_id': {
        'type': 'integer',
        'description': 'ID of the budget to update',
      },
      'name': {
        'type': 'string',
        'description': 'New budget name',
      },
      'amount': {
        'type': 'number',
        'description': 'New budget amount',
        'minimum': 0.01,
      },
      'category_id': {
        'type': 'integer',
        'description': 'New category ID',
      },
      'is_active': {
        'type': 'boolean',
        'description': 'Whether the budget is active',
      },
      'colour': {
        'type': 'string',
        'description': 'New budget color as hex code',
      },
      'start_date': {
        'type': 'string',
        'format': 'date',
        'description': 'New start date (YYYY-MM-DD)',
      },
      'end_date': {
        'type': 'string',
        'format': 'date',
        'description': 'New end date (YYYY-MM-DD)',
      },
    },
    'required': ['budget_id'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'budgets',
      'access_level': 'write',
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['budgets'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final budgetId = parameters['budget_id'] as int;
      
      final existingBudget = await _budgetRepository.getBudgetById(budgetId);
      if (existingBudget == null) {
        return {
          'success': false,
          'error': 'Budget with ID $budgetId not found',
        };
      }

      final updatedBudget = existingBudget.copyWith(
        name: parameters['name'] as String?,
        amount: parameters['amount'] as double?,
        categoryId: parameters['category_id'] as int?,
        isActive: parameters['is_active'] as bool?,
        colour: parameters['colour'] as String?,
        startDate: parameters.containsKey('start_date') 
            ? DateTime.parse(parameters['start_date'] as String)
            : null,
        endDate: parameters.containsKey('end_date')
            ? DateTime.parse(parameters['end_date'] as String)
            : null,
        updatedAt: DateTime.now(),
      );

      final result = await _budgetRepository.updateBudget(updatedBudget);

      return {
        'success': true,
        'budget': _budgetToMap(result),
        'message': 'Budget updated successfully',
        'changes_made': parameters.keys.where((k) => k != 'budget_id').toList(),
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update budget: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('budget_id') || parameters['budget_id'] is! int) {
      return false;
    }
    
    final updateFields = ['name', 'amount', 'category_id', 'is_active', 'colour', 'start_date', 'end_date'];
    return updateFields.any((field) => parameters.containsKey(field));
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Update budget amount and make it inactive',
      'parameters': {
        'budget_id': 123,
        'amount': 500.0,
        'is_active': false,
      },
    },
    {
      'description': 'Change budget name and color',
      'parameters': {
        'budget_id': 456,
        'name': 'Updated Grocery Budget',
        'colour': '#FF5722',
      },
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    if (data.containsKey('amount')) {
      final amount = data['amount'] as double?;
      if (amount == null || amount <= 0 || amount > 1000000) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> _budgetToMap(Budget budget) {
    return {
      'id': budget.id,
      'name': budget.name,
      'amount': budget.amount,
      'spent': budget.spent,
      'remaining': budget.remaining,
      'percentage_spent': budget.percentageSpent,
      'is_over_budget': budget.isOverBudget,
      'is_active': budget.isActive,
      'updated_at': budget.updatedAt.toIso8601String(),
    };
  }
}

/// Tool for deleting budgets
class DeleteBudgetTool extends FinancialDataTool {
  final BudgetRepository _budgetRepository;

  DeleteBudgetTool(this._budgetRepository);

  @override
  String get name => 'delete_budget';

  @override
  String get description => 
      'Delete a budget by ID. Use with caution as this action cannot be undone.';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'budget_id': {
        'type': 'integer',
        'description': 'ID of the budget to delete',
      },
      'confirm': {
        'type': 'boolean',
        'description': 'Confirmation that user wants to delete the budget',
      },
    },
    'required': ['budget_id', 'confirm'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'budgets',
      'access_level': 'delete',
      'requires_confirmation': true,
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['budgets'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final budgetId = parameters['budget_id'] as int;
      final confirm = parameters['confirm'] as bool;

      if (!confirm) {
        return {
          'success': false,
          'error': 'Deletion not confirmed. Set confirm parameter to true to proceed.',
        };
      }

      final existingBudget = await _budgetRepository.getBudgetById(budgetId);
      if (existingBudget == null) {
        return {
          'success': false,
          'error': 'Budget with ID $budgetId not found',
        };
      }

      await _budgetRepository.deleteBudget(budgetId);

      return {
        'success': true,
        'message': 'Budget deleted successfully',
        'deleted_budget': {
          'id': budgetId,
          'name': existingBudget.name,
          'amount': existingBudget.amount,
        },
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to delete budget: ${e.toString()}',
        'budget_id': parameters['budget_id'],
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    return parameters.containsKey('budget_id') && 
           parameters['budget_id'] is int &&
           parameters.containsKey('confirm') &&
           parameters['confirm'] is bool;
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Delete a budget with confirmation',
      'parameters': {
        'budget_id': 789,
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

/// Tool for budget analytics and insights
class BudgetAnalyticsTool extends FinancialDataTool {
  final BudgetRepository _budgetRepository;

  BudgetAnalyticsTool(this._budgetRepository);

  @override
  String get name => 'budget_analytics';

  @override
  String get description => 
      'Get analytics and insights about budgets including performance, trends, and recommendations';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'analysis_type': {
        'type': 'string',
        'enum': ['overview', 'performance', 'over_budget', 'category_breakdown', 'period_comparison'],
        'description': 'Type of analysis to perform',
      },
      'budget_id': {
        'type': 'integer',
        'description': 'Specific budget ID for detailed analysis',
      },
      'include_inactive': {
        'type': 'boolean',
        'description': 'Include inactive budgets in analysis',
        'default': false,
      },
      'period_filter': {
        'type': 'string',
        'enum': ['daily', 'weekly', 'monthly', 'yearly'],
        'description': 'Filter budgets by period type',
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
      'category': 'budgets',
      'access_level': 'read',
      'provides_insights': true,
    },
  );

  @override
  bool get requiresAccountAccess => false;

  @override
  bool get canModifyData => false;

  @override
  List<String> get accessibleEntities => ['budgets'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final analysisType = parameters['analysis_type'] as String;
      final includeInactive = parameters['include_inactive'] as bool? ?? false;

      List<Budget> budgets;
      if (includeInactive) {
        budgets = await _budgetRepository.getAllBudgets();
      } else {
        budgets = await _budgetRepository.getActiveBudgets();
      }

      // Apply period filter if specified
      if (parameters.containsKey('period_filter')) {
        final periodFilter = _parseBudgetPeriod(parameters['period_filter'] as String);
        budgets = budgets.where((b) => b.period == periodFilter).toList();
      }

      switch (analysisType) {
        case 'overview':
          return _generateOverview(budgets);

        case 'performance':
          if (parameters.containsKey('budget_id')) {
            final budgetId = parameters['budget_id'] as int;
            final budget = budgets.firstWhere((b) => b.id == budgetId);
            return _generateBudgetPerformance(budget);
          } else {
            return _generateAllBudgetsPerformance(budgets);
          }

        case 'over_budget':
          final overBudgets = budgets.where((b) => b.isOverBudget).toList();
          return _generateOverBudgetAnalysis(overBudgets);

        case 'category_breakdown':
          return _generateCategoryBreakdown(budgets);

        case 'period_comparison':
          return _generatePeriodComparison(budgets);

        default:
          return {
            'success': false,
            'error': 'Invalid analysis_type: $analysisType',
          };
      }

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to perform budget analytics: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('analysis_type')) return false;
    
    final analysisType = parameters['analysis_type'] as String?;
    return ['overview', 'performance', 'over_budget', 'category_breakdown', 'period_comparison']
        .contains(analysisType);
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Get budget overview and summary',
      'parameters': {'analysis_type': 'overview'},
    },
    {
      'description': 'Analyze performance of all budgets',
      'parameters': {'analysis_type': 'performance'},
    },
    {
      'description': 'Find budgets that are over limit',
      'parameters': {'analysis_type': 'over_budget'},
    },
    {
      'description': 'Get category breakdown of budgets',
      'parameters': {'analysis_type': 'category_breakdown'},
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

  Map<String, dynamic> _generateOverview(List<Budget> budgets) {
    final totalBudgeted = budgets.fold(0.0, (sum, b) => sum + b.amount);
    final totalSpent = budgets.fold(0.0, (sum, b) => sum + b.spent);
    final overBudgetCount = budgets.where((b) => b.isOverBudget).length;
    final activeBudgets = budgets.where((b) => b.isActive).length;

    return {
      'success': true,
      'analysis_type': 'overview',
      'summary': {
        'total_budgets': budgets.length,
        'active_budgets': activeBudgets,
        'total_budgeted': totalBudgeted,
        'total_spent': totalSpent,
        'total_remaining': totalBudgeted - totalSpent,
        'overall_utilization': totalBudgeted > 0 ? (totalSpent / totalBudgeted) : 0.0,
        'over_budget_count': overBudgetCount,
        'on_track_count': budgets.length - overBudgetCount,
      },
      'recommendations': _generateRecommendations(budgets),
    };
  }

  Map<String, dynamic> _generateBudgetPerformance(Budget budget) {
    final daysTotal = budget.endDate.difference(budget.startDate).inDays;
    final daysElapsed = DateTime.now().difference(budget.startDate).inDays;
    final progressPercentage = daysTotal > 0 ? (daysElapsed / daysTotal) : 0.0;
    
    final expectedSpent = budget.amount * progressPercentage;
    final variance = budget.spent - expectedSpent;

    return {
      'success': true,
      'analysis_type': 'performance',
      'budget': _budgetToMap(budget),
      'performance': {
        'days_total': daysTotal,
        'days_elapsed': daysElapsed,
        'days_remaining': daysTotal - daysElapsed,
        'time_progress_percentage': progressPercentage,
        'expected_spent': expectedSpent,
        'actual_spent': budget.spent,
        'variance': variance,
        'is_on_track': variance <= 0,
        'daily_average_needed': budget.remaining / (daysTotal - daysElapsed).clamp(1, daysTotal),
      },
    };
  }

  Map<String, dynamic> _generateAllBudgetsPerformance(List<Budget> budgets) {
    final performances = budgets.map((b) => {
      'budget_id': b.id,
      'budget_name': b.name,
      'performance': _generateBudgetPerformance(b)['performance'],
    }).toList();

    return {
      'success': true,
      'analysis_type': 'performance',
      'count': budgets.length,
      'budget_performances': performances,
    };
  }

  Map<String, dynamic> _generateOverBudgetAnalysis(List<Budget> overBudgets) {
    final totalOverAmount = overBudgets.fold(0.0, (sum, b) => sum + (b.spent - b.amount));
    
    final severityLevels = {
      'critical': overBudgets.where((b) => b.percentageSpent > 1.5).length, // >150%
      'high': overBudgets.where((b) => b.percentageSpent > 1.2 && b.percentageSpent <= 1.5).length, // 120-150%
      'moderate': overBudgets.where((b) => b.percentageSpent > 1.0 && b.percentageSpent <= 1.2).length, // 100-120%
    };

    return {
      'success': true,
      'analysis_type': 'over_budget',
      'summary': {
        'total_over_budget': overBudgets.length,
        'total_overspent_amount': totalOverAmount,
        'severity_breakdown': severityLevels,
      },
      'over_budget_details': overBudgets.map((b) => {
        'budget_id': b.id,
        'budget_name': b.name,
        'amount': b.amount,
        'spent': b.spent,
        'overspent_amount': b.spent - b.amount,
        'overspent_percentage': (b.percentageSpent - 1.0) * 100,
        'severity': _calculateSeverity(b.percentageSpent),
      }).toList(),
    };
  }

  Map<String, dynamic> _generateCategoryBreakdown(List<Budget> budgets) {
    final categoryGroups = <int, List<Budget>>{};
    
    for (final budget in budgets) {
      if (budget.categoryId != null) {
        categoryGroups.putIfAbsent(budget.categoryId!, () => []).add(budget);
      }
    }

    final categoryAnalysis = categoryGroups.entries.map((entry) {
      final categoryBudgets = entry.value;
      final totalBudgeted = categoryBudgets.fold(0.0, (sum, b) => sum + b.amount);
      final totalSpent = categoryBudgets.fold(0.0, (sum, b) => sum + b.spent);
      
      return {
        'category_id': entry.key,
        'budget_count': categoryBudgets.length,
        'total_budgeted': totalBudgeted,
        'total_spent': totalSpent,
        'total_remaining': totalBudgeted - totalSpent,
        'utilization_rate': totalBudgeted > 0 ? (totalSpent / totalBudgeted) : 0.0,
        'over_budget_count': categoryBudgets.where((b) => b.isOverBudget).length,
      };
    }).toList();

    return {
      'success': true,
      'analysis_type': 'category_breakdown',
      'categories_count': categoryGroups.length,
      'category_analysis': categoryAnalysis,
    };
  }

  Map<String, dynamic> _generatePeriodComparison(List<Budget> budgets) {
    final periodGroups = <BudgetPeriod, List<Budget>>{};
    
    for (final budget in budgets) {
      periodGroups.putIfAbsent(budget.period, () => []).add(budget);
    }

    final periodAnalysis = periodGroups.entries.map((entry) {
      final periodBudgets = entry.value;
      final totalBudgeted = periodBudgets.fold(0.0, (sum, b) => sum + b.amount);
      final totalSpent = periodBudgets.fold(0.0, (sum, b) => sum + b.spent);
      
      return {
        'period': entry.key.toString().split('.').last,
        'budget_count': periodBudgets.length,
        'total_budgeted': totalBudgeted,
        'total_spent': totalSpent,
        'average_budget_amount': totalBudgeted / periodBudgets.length,
        'average_spent': totalSpent / periodBudgets.length,
        'utilization_rate': totalBudgeted > 0 ? (totalSpent / totalBudgeted) : 0.0,
      };
    }).toList();

    return {
      'success': true,
      'analysis_type': 'period_comparison',
      'periods_count': periodGroups.length,
      'period_analysis': periodAnalysis,
    };
  }

  List<String> _generateRecommendations(List<Budget> budgets) {
    final recommendations = <String>[];
    
    final overBudgets = budgets.where((b) => b.isOverBudget).toList();
    if (overBudgets.isNotEmpty) {
      recommendations.add('${overBudgets.length} budget(s) are over limit. Consider reviewing spending or adjusting budget amounts.');
    }
    
    final lowUtilization = budgets.where((b) => b.percentageSpent < 0.5 && !b.isOverBudget).toList();
    if (lowUtilization.isNotEmpty) {
      recommendations.add('${lowUtilization.length} budget(s) have low utilization (<50%). Consider reallocating funds.');
    }
    
    final nearEnd = budgets.where((b) {
      final daysTotal = b.endDate.difference(b.startDate).inDays;
      final daysRemaining = b.endDate.difference(DateTime.now()).inDays;
      return daysRemaining <= (daysTotal * 0.1) && b.isActive; // Less than 10% time remaining
    }).toList();
    
    if (nearEnd.isNotEmpty) {
      recommendations.add('${nearEnd.length} budget(s) are near their end date. Consider creating new budget periods.');
    }

    return recommendations;
  }

  String _calculateSeverity(double percentageSpent) {
    if (percentageSpent > 1.5) return 'critical';
    if (percentageSpent > 1.2) return 'high';
    if (percentageSpent > 1.0) return 'moderate';
    return 'normal';
  }

  BudgetPeriod _parseBudgetPeriod(String period) {
    switch (period.toLowerCase()) {
      case 'daily':
        return BudgetPeriod.daily;
      case 'weekly':
        return BudgetPeriod.weekly;
      case 'monthly':
        return BudgetPeriod.monthly;
      case 'yearly':
        return BudgetPeriod.yearly;
      default:
        return BudgetPeriod.monthly;
    }
  }

  Map<String, dynamic> _budgetToMap(Budget budget) {
    return {
      'id': budget.id,
      'name': budget.name,
      'amount': budget.amount,
      'spent': budget.spent,
      'remaining': budget.remaining,
      'percentage_spent': budget.percentageSpent,
      'is_over_budget': budget.isOverBudget,
      'period': budget.period.toString().split('.').last,
      'start_date': budget.startDate.toIso8601String().split('T')[0],
      'end_date': budget.endDate.toIso8601String().split('T')[0],
    };
  }
}