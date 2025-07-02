import 'package:uuid/uuid.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';
import '../../domain/services/database_tool.dart';
import '../../domain/entities/ai_tool_call.dart';

/// Tool for querying and searching transactions
class QueryTransactionsTool extends FinancialDataTool {
  final TransactionRepository _transactionRepository;
  final _uuid = const Uuid();

  QueryTransactionsTool(this._transactionRepository);

  @override
  String get name => 'query_transactions';

  @override
  String get description => 
      'Search and filter transactions by various criteria like date range, account, category, amount, or keywords';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'query_type': {
        'type': 'string',
        'enum': ['all', 'by_account', 'by_category', 'by_date_range', 'by_keyword', 'paginated'],
        'description': 'Type of query to perform',
      },
      'account_id': {
        'type': 'integer',
        'description': 'Filter by specific account ID (required for by_account)',
      },
      'category_id': {
        'type': 'integer', 
        'description': 'Filter by specific category ID (required for by_category)',
      },
      'start_date': {
        'type': 'string',
        'format': 'date',
        'description': 'Start date for date range filter (YYYY-MM-DD)',
      },
      'end_date': {
        'type': 'string',
        'format': 'date',
        'description': 'End date for date range filter (YYYY-MM-DD)',
      },
      'keyword': {
        'type': 'string',
        'description': 'Search keyword for title or note',
      },
      'page': {
        'type': 'integer',
        'description': 'Page number for paginated results (starts at 0)',
        'minimum': 0,
      },
      'limit': {
        'type': 'integer',
        'description': 'Number of results per page (max 100)',
        'minimum': 1,
        'maximum': 100,
      },
      'amount_min': {
        'type': 'number',
        'description': 'Minimum amount filter',
      },
      'amount_max': {
        'type': 'number',
        'description': 'Maximum amount filter',
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
      'category': 'transactions',
      'access_level': 'read',
    },
  );

  @override
  bool get requiresAccountAccess => false;

  @override
  bool get canModifyData => false;

  @override
  List<String> get accessibleEntities => ['transactions'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    final queryType = parameters['query_type'] as String;
    
    try {
      List<Transaction> transactions;
      
      switch (queryType) {
        case 'all':
          transactions = await _transactionRepository.getAllTransactions();
          break;
          
        case 'by_account':
          final accountId = parameters['account_id'] as int;
          transactions = await _transactionRepository.getTransactionsByAccount(accountId);
          break;
          
        case 'by_category':
          final categoryId = parameters['category_id'] as int;
          transactions = await _transactionRepository.getTransactionsByCategory(categoryId);
          break;
          
        case 'by_date_range':
          final startDate = DateTime.parse(parameters['start_date'] as String);
          final endDate = DateTime.parse(parameters['end_date'] as String);
          transactions = await _transactionRepository.getTransactionsByDateRange(startDate, endDate);
          break;
          
        case 'paginated':
          final page = parameters['page'] as int? ?? 0;
          final limit = parameters['limit'] as int? ?? 20;
          transactions = await _transactionRepository.getTransactions(page: page, limit: limit);
          break;
          
        case 'by_keyword':
          // For keyword search, we'll get all transactions and filter locally
          final keyword = (parameters['keyword'] as String).toLowerCase();
          final allTransactions = await _transactionRepository.getAllTransactions();
          transactions = allTransactions.where((t) => 
            t.title.toLowerCase().contains(keyword) || 
            (t.note?.toLowerCase().contains(keyword) ?? false)
          ).toList();
          break;
          
        default:
          throw ArgumentError('Invalid query_type: $queryType');
      }
      
      // Apply additional filters if provided
      if (parameters.containsKey('amount_min')) {
        final minAmount = parameters['amount_min'] as double;
        transactions = transactions.where((t) => t.amount >= minAmount).toList();
      }
      
      if (parameters.containsKey('amount_max')) {
        final maxAmount = parameters['amount_max'] as double;
        transactions = transactions.where((t) => t.amount <= maxAmount).toList();
      }
      
      return {
        'success': true,
        'count': transactions.length,
        'transactions': transactions.map((t) => _transactionToMap(t)).toList(),
        'query_info': {
          'query_type': queryType,
          'filters_applied': parameters.keys.where((k) => k != 'query_type').toList(),
        },
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to query transactions: ${e.toString()}',
        'query_type': queryType,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('query_type')) return false;
    
    final queryType = parameters['query_type'] as String?;
    
    switch (queryType) {
      case 'by_account':
        return parameters.containsKey('account_id') && parameters['account_id'] is int;
      case 'by_category':
        return parameters.containsKey('category_id') && parameters['category_id'] is int;
      case 'by_date_range':
        return parameters.containsKey('start_date') && 
               parameters.containsKey('end_date') &&
               parameters['start_date'] is String &&
               parameters['end_date'] is String;
      case 'by_keyword':
        return parameters.containsKey('keyword') && parameters['keyword'] is String;
      case 'paginated':
        return true; // page and limit are optional with defaults
      case 'all':
        return true;
      default:
        return false;
    }
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Get all transactions',
      'parameters': {'query_type': 'all'},
    },
    {
      'description': 'Get transactions for a specific account',
      'parameters': {'query_type': 'by_account', 'account_id': 1},
    },
    {
      'description': 'Get transactions from last month',
      'parameters': {
        'query_type': 'by_date_range',
        'start_date': '2024-01-01',
        'end_date': '2024-01-31',
      },
    },
    {
      'description': 'Search for groceries transactions',
      'parameters': {'query_type': 'by_keyword', 'keyword': 'grocery'},
    },
    {
      'description': 'Get first page of transactions (20 per page)',
      'parameters': {'query_type': 'paginated', 'page': 0, 'limit': 20},
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    // For read operations, validation is minimal
    return true;
  }

  Map<String, dynamic> _transactionToMap(Transaction transaction) {
    return {
      'id': transaction.id,
      'title': transaction.title,
      'note': transaction.note,
      'amount': transaction.amount,
      'category_id': transaction.categoryId,
      'account_id': transaction.accountId,
      'date': transaction.date.toIso8601String(),
      'created_at': transaction.createdAt.toIso8601String(),
      'updated_at': transaction.updatedAt.toIso8601String(),
      'transaction_type': transaction.transactionType.toString(),
      'is_income': transaction.isIncome,
      'is_expense': transaction.isExpense,
      'is_loan': transaction.isLoan,
      'is_recurring': transaction.isRecurring,
      'transaction_state': transaction.transactionState.toString(),
      'remaining_amount': transaction.remainingAmount,
      'parent_transaction_id': transaction.parentTransactionId,
    };
  }
}

/// Tool for creating new transactions
class CreateTransactionTool extends FinancialDataTool {
  final TransactionRepository _transactionRepository;
  final _uuid = const Uuid();

  CreateTransactionTool(this._transactionRepository);

  @override
  String get name => 'create_transaction';

  @override
  String get description => 
      'Create a new transaction (income or expense) with specified details';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'title': {
        'type': 'string',
        'description': 'Transaction title/description',
        'minLength': 1,
      },
      'amount': {
        'type': 'number',
        'description': 'Transaction amount (positive for income, negative for expense)',
      },
      'category_id': {
        'type': 'integer',
        'description': 'Category ID for this transaction',
      },
      'account_id': {
        'type': 'integer',
        'description': 'Account ID where this transaction occurs',
      },
      'note': {
        'type': 'string',
        'description': 'Additional notes for the transaction',
      },
      'date': {
        'type': 'string',
        'format': 'date',
        'description': 'Transaction date (YYYY-MM-DD), defaults to today',
      },
      'transaction_type': {
        'type': 'string',
        'enum': ['expense', 'income', 'transfer', 'loan', 'subscription'],
        'description': 'Type of transaction',
      },
    },
    'required': ['title', 'amount', 'category_id', 'account_id'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'transactions',
      'access_level': 'write',
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['transactions'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final now = DateTime.now();
      final date = parameters.containsKey('date') 
          ? DateTime.parse(parameters['date'] as String)
          : now;
          
      final transactionType = parameters.containsKey('transaction_type')
          ? _parseTransactionType(parameters['transaction_type'] as String)
          : (parameters['amount'] as double) > 0 
              ? TransactionType.income 
              : TransactionType.expense;

      final transaction = Transaction(
        title: parameters['title'] as String,
        note: parameters['note'] as String?,
        amount: parameters['amount'] as double,
        categoryId: parameters['category_id'] as int,
        accountId: parameters['account_id'] as int,
        date: date,
        createdAt: now,
        updatedAt: now,
        transactionType: transactionType,
        syncId: _uuid.v4(),
      );

      final createdTransaction = await _transactionRepository.createTransaction(transaction);

      return {
        'success': true,
        'transaction': _transactionToMap(createdTransaction),
        'message': 'Transaction created successfully',
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to create transaction: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    final requiredFields = ['title', 'amount', 'category_id', 'account_id'];
    
    for (final field in requiredFields) {
      if (!parameters.containsKey(field)) return false;
    }
    
    if (parameters['title'] is! String || (parameters['title'] as String).isEmpty) {
      return false;
    }
    
    if (parameters['amount'] is! num) return false;
    if (parameters['category_id'] is! int) return false;
    if (parameters['account_id'] is! int) return false;
    
    return true;
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Create a grocery expense',
      'parameters': {
        'title': 'Grocery shopping',
        'amount': -85.50,
        'category_id': 1,
        'account_id': 1,
        'note': 'Weekly groceries at SuperMart',
      },
    },
    {
      'description': 'Create salary income',
      'parameters': {
        'title': 'Monthly salary',
        'amount': 3000.00,
        'category_id': 2,
        'account_id': 1,
        'transaction_type': 'income',
      },
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    // Validate that amount is reasonable (not zero, not too large)
    final amount = data['amount'] as double?;
    if (amount == null || amount == 0.0 || amount.abs() > 1000000) {
      return false;
    }
    
    return true;
  }

  TransactionType _parseTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'transfer':
        return TransactionType.transfer;
      case 'loan':
        return TransactionType.loan;
      case 'subscription':
        return TransactionType.subscription;
      default:
        return TransactionType.expense;
    }
  }

  Map<String, dynamic> _transactionToMap(Transaction transaction) {
    return {
      'id': transaction.id,
      'title': transaction.title,
      'note': transaction.note,
      'amount': transaction.amount,
      'category_id': transaction.categoryId,
      'account_id': transaction.accountId,
      'date': transaction.date.toIso8601String(),
      'created_at': transaction.createdAt.toIso8601String(),
      'updated_at': transaction.updatedAt.toIso8601String(),
      'transaction_type': transaction.transactionType.toString(),
      'is_income': transaction.isIncome,
      'is_expense': transaction.isExpense,
    };
  }
}

/// Tool for updating existing transactions
class UpdateTransactionTool extends FinancialDataTool {
  final TransactionRepository _transactionRepository;

  UpdateTransactionTool(this._transactionRepository);

  @override
  String get name => 'update_transaction';

  @override
  String get description => 
      'Update an existing transaction by ID with new values';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'transaction_id': {
        'type': 'integer',
        'description': 'ID of the transaction to update',
      },
      'title': {
        'type': 'string',
        'description': 'New transaction title',
      },
      'amount': {
        'type': 'number',
        'description': 'New transaction amount',
      },
      'category_id': {
        'type': 'integer',
        'description': 'New category ID',
      },
      'account_id': {
        'type': 'integer',
        'description': 'New account ID',
      },
      'note': {
        'type': 'string',
        'description': 'New note for the transaction',
      },
      'date': {
        'type': 'string',
        'format': 'date',
        'description': 'New transaction date (YYYY-MM-DD)',
      },
    },
    'required': ['transaction_id'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'transactions',
      'access_level': 'write',
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['transactions'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final transactionId = parameters['transaction_id'] as int;
      
      // Get the existing transaction
      final existingTransaction = await _transactionRepository.getTransactionById(transactionId);
      if (existingTransaction == null) {
        return {
          'success': false,
          'error': 'Transaction with ID $transactionId not found',
        };
      }

      // Create updated transaction with changed fields
      final updatedTransaction = existingTransaction.copyWith(
        title: parameters['title'] as String?,
        amount: parameters['amount'] as double?,
        categoryId: parameters['category_id'] as int?,
        accountId: parameters['account_id'] as int?,
        note: parameters['note'] as String?,
        date: parameters.containsKey('date') 
            ? DateTime.parse(parameters['date'] as String)
            : null,
        updatedAt: DateTime.now(),
      );

      final result = await _transactionRepository.updateTransaction(updatedTransaction);

      return {
        'success': true,
        'transaction': _transactionToMap(result),
        'message': 'Transaction updated successfully',
        'changes_made': parameters.keys.where((k) => k != 'transaction_id').toList(),
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update transaction: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('transaction_id') || parameters['transaction_id'] is! int) {
      return false;
    }
    
    // At least one field to update must be provided
    final updateFields = ['title', 'amount', 'category_id', 'account_id', 'note', 'date'];
    return updateFields.any((field) => parameters.containsKey(field));
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Update transaction title and amount',
      'parameters': {
        'transaction_id': 123,
        'title': 'Updated grocery shopping',
        'amount': -95.75,
      },
    },
    {
      'description': 'Move transaction to different category',
      'parameters': {
        'transaction_id': 456,
        'category_id': 5,
        'note': 'Recategorized from food to entertainment',
      },
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    if (data.containsKey('amount')) {
      final amount = data['amount'] as double?;
      if (amount == null || amount == 0.0 || amount.abs() > 1000000) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> _transactionToMap(Transaction transaction) {
    return {
      'id': transaction.id,
      'title': transaction.title,
      'note': transaction.note,
      'amount': transaction.amount,
      'category_id': transaction.categoryId,
      'account_id': transaction.accountId,
      'date': transaction.date.toIso8601String(),
      'updated_at': transaction.updatedAt.toIso8601String(),
    };
  }
}

/// Tool for deleting transactions
class DeleteTransactionTool extends FinancialDataTool {
  final TransactionRepository _transactionRepository;

  DeleteTransactionTool(this._transactionRepository);

  @override
  String get name => 'delete_transaction';

  @override
  String get description => 
      'Delete a transaction by ID. Use with caution as this action cannot be undone.';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'transaction_id': {
        'type': 'integer',
        'description': 'ID of the transaction to delete',
      },
      'confirm': {
        'type': 'boolean',
        'description': 'Confirmation that user wants to delete the transaction',
      },
    },
    'required': ['transaction_id', 'confirm'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'transactions',
      'access_level': 'delete',
      'requires_confirmation': true,
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['transactions'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final transactionId = parameters['transaction_id'] as int;
      final confirm = parameters['confirm'] as bool;

      if (!confirm) {
        return {
          'success': false,
          'error': 'Deletion not confirmed. Set confirm parameter to true to proceed.',
        };
      }

      // Check if transaction exists before deletion
      final existingTransaction = await _transactionRepository.getTransactionById(transactionId);
      if (existingTransaction == null) {
        return {
          'success': false,
          'error': 'Transaction with ID $transactionId not found',
        };
      }

      await _transactionRepository.deleteTransaction(transactionId);

      return {
        'success': true,
        'message': 'Transaction deleted successfully',
        'deleted_transaction': {
          'id': transactionId,
          'title': existingTransaction.title,
          'amount': existingTransaction.amount,
        },
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to delete transaction: ${e.toString()}',
        'transaction_id': parameters['transaction_id'],
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    return parameters.containsKey('transaction_id') && 
           parameters['transaction_id'] is int &&
           parameters.containsKey('confirm') &&
           parameters['confirm'] is bool;
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Delete a transaction with confirmation',
      'parameters': {
        'transaction_id': 789,
        'confirm': true,
      },
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    // For deletion, we just need to verify the transaction exists (done in execute)
    return true;
  }
}

/// Tool for transaction analytics and insights
class TransactionAnalyticsTool extends FinancialDataTool {
  final TransactionRepository _transactionRepository;

  TransactionAnalyticsTool(this._transactionRepository);

  @override
  String get name => 'transaction_analytics';

  @override
  String get description => 
      'Get analytics and insights about transactions including spending by category, account totals, and trends';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'analysis_type': {
        'type': 'string',
        'enum': ['spending_by_category', 'account_totals', 'category_total', 'summary'],
        'description': 'Type of analysis to perform',
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
      'category_id': {
        'type': 'integer',
        'description': 'Specific category ID for category_total analysis',
      },
      'account_id': {
        'type': 'integer',
        'description': 'Specific account ID for account analysis',
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
      'category': 'transactions',
      'access_level': 'read',
      'provides_insights': true,
    },
  );

  @override
  bool get requiresAccountAccess => false;

  @override
  bool get canModifyData => false;

  @override
  List<String> get accessibleEntities => ['transactions'];

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
        case 'spending_by_category':
          final spending = await _transactionRepository.getSpendingByCategory(startDate, endDate);
          return {
            'success': true,
            'analysis_type': analysisType,
            'period': _formatDateRange(startDate, endDate),
            'spending_by_category': spending,
            'total_categories': spending.length,
          };

        case 'category_total':
          final categoryId = parameters['category_id'] as int;
          final total = await _transactionRepository.getTotalByCategory(categoryId, startDate, endDate);
          return {
            'success': true,
            'analysis_type': analysisType,
            'category_id': categoryId,
            'period': _formatDateRange(startDate, endDate),
            'total': total,
          };

        case 'account_totals':
          final accountId = parameters['account_id'] as int?;
          if (accountId != null) {
            final total = await _transactionRepository.getTotalByAccount(accountId, startDate, endDate);
            return {
              'success': true,
              'analysis_type': analysisType,
              'account_id': accountId,
              'period': _formatDateRange(startDate, endDate),
              'total': total,
            };
          } else {
            return {
              'success': false,
              'error': 'account_id is required for account_totals analysis',
            };
          }

        case 'summary':
          // Get overall summary
          final allTransactions = startDate != null && endDate != null
              ? await _transactionRepository.getTransactionsByDateRange(startDate, endDate)
              : await _transactionRepository.getAllTransactions();
          
          final totalIncome = allTransactions
              .where((t) => t.isIncome)
              .fold(0.0, (sum, t) => sum + t.amount);
          
          final totalExpenses = allTransactions
              .where((t) => t.isExpense)
              .fold(0.0, (sum, t) => sum + t.amount.abs());

          return {
            'success': true,
            'analysis_type': analysisType,
            'period': _formatDateRange(startDate, endDate),
            'summary': {
              'total_transactions': allTransactions.length,
              'total_income': totalIncome,
              'total_expenses': totalExpenses,
              'net_amount': totalIncome - totalExpenses,
              'income_transactions': allTransactions.where((t) => t.isIncome).length,
              'expense_transactions': allTransactions.where((t) => t.isExpense).length,
            },
          };

        default:
          return {
            'success': false,
            'error': 'Invalid analysis_type: $analysisType',
          };
      }

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to perform analytics: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('analysis_type')) return false;
    
    final analysisType = parameters['analysis_type'] as String?;
    
    if (analysisType == 'category_total' && !parameters.containsKey('category_id')) {
      return false;
    }
    
    return ['spending_by_category', 'account_totals', 'category_total', 'summary']
        .contains(analysisType);
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Get spending breakdown by category for this month',
      'parameters': {
        'analysis_type': 'spending_by_category',
        'start_date': '2024-01-01',
        'end_date': '2024-01-31',
      },
    },
    {
      'description': 'Get total for a specific category',
      'parameters': {
        'analysis_type': 'category_total',
        'category_id': 1,
        'start_date': '2024-01-01',
        'end_date': '2024-01-31',
      },
    },
    {
      'description': 'Get overall transaction summary',
      'parameters': {
        'analysis_type': 'summary',
      },
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    return true; // Analytics operations don't modify data
  }

  String _formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) return 'All time';
    if (startDate == null) return 'Until ${endDate!.toIso8601String().split('T')[0]}';
    if (endDate == null) return 'From ${startDate.toIso8601String().split('T')[0]}';
    return '${startDate.toIso8601String().split('T')[0]} to ${endDate.toIso8601String().split('T')[0]}';
  }
}