import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/services/database_tool.dart';
import '../../domain/entities/ai_tool_call.dart';
import '../../../currencies/domain/services/currency_intelligence_service.dart';
import '../../../../core/settings/app_settings.dart';

/// Tool for querying and searching accounts
class QueryAccountsTool extends FinancialDataTool {
  final AccountRepository _accountRepository;

  QueryAccountsTool(this._accountRepository);

  @override
  String get name => 'query_accounts';

  @override
  String get description => 
      'Search and filter accounts by various criteria like name, currency, default status, or keywords';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'query_type': {
        'type': 'string',
        'enum': ['all', 'default', 'by_currency', 'by_keyword', 'by_id'],
        'description': 'Type of query to perform',
      },
      'currency': {
        'type': 'string',
        'description': 'Filter by specific currency code (e.g., USD, EUR)',
      },
      'keyword': {
        'type': 'string',
        'description': 'Search keyword for account name',
      },
      'account_id': {
        'type': 'integer',
        'description': 'Specific account ID to retrieve',
      },
      'include_balance': {
        'type': 'boolean',
        'description': 'Include balance information in results',
        'default': true,
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
      'category': 'accounts',
      'access_level': 'read',
    },
  );

  @override
  bool get requiresAccountAccess => false;

  @override
  bool get canModifyData => false;

  @override
  List<String> get accessibleEntities => ['accounts'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    final queryType = parameters['query_type'] as String;
    
    try {
      List<Account> accounts;
      
      switch (queryType) {
        case 'all':
          accounts = await _accountRepository.getAllAccounts();
          break;
          
        case 'default':
          final defaultAccount = await _accountRepository.getDefaultAccount();
          accounts = defaultAccount != null ? [defaultAccount] : [];
          break;
          
        case 'by_currency':
          final currency = parameters['currency'] as String;
          final allAccounts = await _accountRepository.getAllAccounts();
          accounts = allAccounts.where((a) => 
            a.currency.toLowerCase() == currency.toLowerCase()
          ).toList();
          break;
          
        case 'by_keyword':
          final keyword = (parameters['keyword'] as String).toLowerCase();
          final allAccounts = await _accountRepository.getAllAccounts();
          accounts = allAccounts.where((a) => 
            a.name.toLowerCase().contains(keyword)
          ).toList();
          break;
          
        case 'by_id':
          final accountId = parameters['account_id'] as int;
          final account = await _accountRepository.getAccountById(accountId);
          accounts = account != null ? [account] : [];
          break;
          
        default:
          throw ArgumentError('Invalid query_type: $queryType');
      }
      
      final includeBalance = parameters['include_balance'] as bool? ?? true;
      
      return {
        'success': true,
        'count': accounts.length,
        'accounts': accounts.map((a) => _accountToMap(a, includeBalance)).toList(),
        'query_info': {
          'query_type': queryType,
          'filters_applied': parameters.keys.where((k) => k != 'query_type').toList(),
        },
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to query accounts: ${e.toString()}',
        'query_type': queryType,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('query_type')) return false;
    
    final queryType = parameters['query_type'] as String?;
    
    switch (queryType) {
      case 'by_currency':
        return parameters.containsKey('currency') && parameters['currency'] is String;
      case 'by_keyword':
        return parameters.containsKey('keyword') && parameters['keyword'] is String;
      case 'by_id':
        return parameters.containsKey('account_id') && parameters['account_id'] is int;
      case 'all':
      case 'default':
        return true;
      default:
        return false;
    }
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Get all accounts',
      'parameters': {'query_type': 'all'},
    },
    {
      'description': 'Get the default account',
      'parameters': {'query_type': 'default'},
    },
    {
      'description': 'Get USD accounts',
      'parameters': {'query_type': 'by_currency', 'currency': 'USD'},
    },
    {
      'description': 'Search for checking accounts',
      'parameters': {'query_type': 'by_keyword', 'keyword': 'checking'},
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

  Map<String, dynamic> _accountToMap(Account account, bool includeBalance) {
    final map = {
      'id': account.id,
      'name': account.name,
      'currency': account.currency,
      'is_default': account.isDefault,
      'created_at': account.createdAt.toIso8601String(),
      'updated_at': account.updatedAt.toIso8601String(),
      'color': '#${(account.color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
    };
    
    if (includeBalance) {
      map['balance'] = account.balance;
    }
    
    return map;
  }
}

/// Tool for creating new accounts
class CreateAccountTool extends FinancialDataTool {
  final AccountRepository _accountRepository;
  final CurrencyIntelligenceService _currencyIntelligenceService;
  final _uuid = const Uuid();

  CreateAccountTool(
    this._accountRepository,
    this._currencyIntelligenceService,
  );

  @override
  String get name => 'create_account';

  @override
  String get description => 
      'Create a new financial account (bank account, wallet, etc.) with specified details';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'name': {
        'type': 'string',
        'description': 'Account name (e.g., "Checking Account", "Cash Wallet")',
        'minLength': 1,
      },
      'currency': {
        'type': 'string',
        'description': 'Currency code (e.g., "USD", "EUR", "GBP") - will be intelligently detected if not provided',
        'minLength': 3,
        'maxLength': 3,
      },
      'initial_balance': {
        'type': 'number',
        'description': 'Starting balance for the account',
        'default': 0.0,
      },
      'is_default': {
        'type': 'boolean',
        'description': 'Whether this should be the default account',
        'default': false,
      },
      'color': {
        'type': 'string',
        'description': 'Account color as hex code (e.g., "#4CAF50")',
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
      'category': 'accounts',
      'access_level': 'write',
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['accounts'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final now = DateTime.now();
      final colorString = parameters['color'] as String?;
      final accountName = parameters['name'] as String;
      
      Color accountColor = Colors.blue; // Default color
      if (colorString != null) {
        try {
          // Parse hex color string
          final hexCode = colorString.replaceAll('#', '');
          accountColor = Color(int.parse('FF$hexCode', radix: 16));
        } catch (e) {
          // Use default color if parsing fails
        }
      }

      // **INTELLIGENT CURRENCY DETECTION**
      String currency;
      String? currencyNote;
      final providedCurrency = parameters['currency'] as String?;
      
      if (providedCurrency != null && await _currencyIntelligenceService.isCurrencySupported(providedCurrency)) {
        // Use explicitly provided currency
        currency = providedCurrency.toUpperCase();
      } else {
        // Get suggested currencies for account creation
        final suggestions = await _currencyIntelligenceService.getSuggestedCurrenciesForAccount(
          voiceLanguage: AppSettings.voiceLanguage,
          appLocale: AppSettings.get<String>('locale'),
        );
        
        // Use the highest confidence suggestion
        final bestSuggestion = suggestions.isNotEmpty ? suggestions.first : null;
        
        if (bestSuggestion != null) {
          currency = bestSuggestion.currencyCode;
          
          if (bestSuggestion.confidence < 0.8) {
            currencyNote = 'Currency auto-detected: ${bestSuggestion.reasoning}';
          }
        } else {
          // Ultimate fallback
          currency = 'USD';
          currencyNote = 'Currency fallback: Using USD as no intelligent detection was possible';
        }
      }

      final account = Account(
        name: accountName,
        currency: currency,
        balance: (parameters['initial_balance'] as num?)?.toDouble() ?? 0.0,
        isDefault: parameters['is_default'] as bool? ?? false,
        createdAt: now,
        updatedAt: now,
        syncId: _uuid.v4(),
        color: accountColor,
      );

      final createdAccount = await _accountRepository.createAccount(account);

      // Build enhanced response with currency intelligence info
      final response = {
        'success': true,
        'account': _accountToMap(createdAccount, true),
        'message': 'Account created successfully',
        'currency_intelligence': {
          'detected_currency': currency,
          'currency_note': currencyNote,
          'was_auto_detected': providedCurrency == null,
        },
      };

      return response;

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to create account: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    // Only name is required now - currency will be intelligently detected
    if (!parameters.containsKey('name')) return false;
    
    if (parameters['name'] is! String || (parameters['name'] as String).isEmpty) {
      return false;
    }
    
    // Validate currency if provided
    final currency = parameters['currency'] as String?;
    if (currency != null && currency.length != 3) {
      return false;
    }
    
    return true;
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Create a checking account with explicit currency',
      'parameters': {
        'name': 'Main Checking Account',
        'currency': 'USD',
        'initial_balance': 1500.00,
        'is_default': true,
        'color': '#2196F3',
      },
    },
    {
      'description': 'Create a savings account with intelligent currency detection',
      'parameters': {
        'name': 'Emergency Savings',
        'initial_balance': 5000.00,
        'color': '#4CAF50',
      },
    },
    {
      'description': 'Create Vietnamese cash wallet (currency auto-detected)',
      'parameters': {
        'name': 'Tiền mặt',
        'initial_balance': 1000000.0,
        'color': '#FF9800',
      },
    },
  ];

  @override
  String formatAmount(double amount, String currencyCode) {
    return '${amount.toStringAsFixed(2)} $currencyCode';
  }

  @override
  Future<bool> validateFinancialData(Map<String, dynamic> data) async {
    if (data.containsKey('initial_balance')) {
      final balance = data['initial_balance'] as double?;
      if (balance != null && balance.abs() > 10000000) { // 10 million limit
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> _accountToMap(Account account, bool includeBalance) {
    final map = {
      'id': account.id,
      'name': account.name,
      'currency': account.currency,
      'is_default': account.isDefault,
      'created_at': account.createdAt.toIso8601String(),
      'color': '#${(account.color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
    };
    
    if (includeBalance) {
      map['balance'] = account.balance;
    }
    
    return map;
  }
}

/// Tool for updating existing accounts
class UpdateAccountTool extends FinancialDataTool {
  final AccountRepository _accountRepository;

  UpdateAccountTool(this._accountRepository);

  @override
  String get name => 'update_account';

  @override
  String get description => 
      'Update an existing account by ID with new values';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'account_id': {
        'type': 'integer',
        'description': 'ID of the account to update',
      },
      'name': {
        'type': 'string',
        'description': 'New account name',
      },
      'currency': {
        'type': 'string',
        'description': 'New currency code',
        'minLength': 3,
        'maxLength': 3,
      },
      'is_default': {
        'type': 'boolean',
        'description': 'Whether this should be the default account',
      },
      'color': {
        'type': 'string',
        'description': 'New account color as hex code',
      },
    },
    'required': ['account_id'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'accounts',
      'access_level': 'write',
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['accounts'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final accountId = parameters['account_id'] as int;
      
      final existingAccount = await _accountRepository.getAccountById(accountId);
      if (existingAccount == null) {
        return {
          'success': false,
          'error': 'Account with ID $accountId not found',
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

      final updatedAccount = existingAccount.copyWith(
        name: parameters['name'] as String?,
        currency: parameters.containsKey('currency') 
            ? (parameters['currency'] as String).toUpperCase()
            : null,
        isDefault: parameters['is_default'] as bool?,
        color: newColor,
        updatedAt: DateTime.now(),
      );

      final result = await _accountRepository.updateAccount(updatedAccount);

      return {
        'success': true,
        'account': _accountToMap(result, true),
        'message': 'Account updated successfully',
        'changes_made': parameters.keys.where((k) => k != 'account_id').toList(),
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update account: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('account_id') || parameters['account_id'] is! int) {
      return false;
    }
    
    final updateFields = ['name', 'currency', 'is_default', 'color'];
    return updateFields.any((field) => parameters.containsKey(field));
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Update account name and make it default',
      'parameters': {
        'account_id': 123,
        'name': 'Primary Checking',
        'is_default': true,
      },
    },
    {
      'description': 'Change account color',
      'parameters': {
        'account_id': 456,
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
    return true; // No financial amounts in account updates
  }

  Map<String, dynamic> _accountToMap(Account account, bool includeBalance) {
    final map = {
      'id': account.id,
      'name': account.name,
      'currency': account.currency,
      'is_default': account.isDefault,
      'updated_at': account.updatedAt.toIso8601String(),
      'color': '#${(account.color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
    };
    
    if (includeBalance) {
      map['balance'] = account.balance;
    }
    
    return map;
  }
}

/// Tool for deleting accounts
class DeleteAccountTool extends FinancialDataTool {
  final AccountRepository _accountRepository;

  DeleteAccountTool(this._accountRepository);

  @override
  String get name => 'delete_account';

  @override
  String get description => 
      'Delete an account by ID. Use with caution as this action cannot be undone and will affect related transactions.';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'account_id': {
        'type': 'integer',
        'description': 'ID of the account to delete',
      },
      'confirm': {
        'type': 'boolean',
        'description': 'Confirmation that user wants to delete the account',
      },
    },
    'required': ['account_id', 'confirm'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'accounts',
      'access_level': 'delete',
      'requires_confirmation': true,
    },
  );

  @override
  bool get requiresAccountAccess => true;

  @override
  bool get canModifyData => true;

  @override
  List<String> get accessibleEntities => ['accounts'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final accountId = parameters['account_id'] as int;
      final confirm = parameters['confirm'] as bool;

      if (!confirm) {
        return {
          'success': false,
          'error': 'Deletion not confirmed. Set confirm parameter to true to proceed.',
        };
      }

      final existingAccount = await _accountRepository.getAccountById(accountId);
      if (existingAccount == null) {
        return {
          'success': false,
          'error': 'Account with ID $accountId not found',
        };
      }

      await _accountRepository.deleteAccount(accountId);

      return {
        'success': true,
        'message': 'Account deleted successfully',
        'deleted_account': {
          'id': accountId,
          'name': existingAccount.name,
          'currency': existingAccount.currency,
        },
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to delete account: ${e.toString()}',
        'account_id': parameters['account_id'],
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    return parameters.containsKey('account_id') && 
           parameters['account_id'] is int &&
           parameters.containsKey('confirm') &&
           parameters['confirm'] is bool;
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Delete an account with confirmation',
      'parameters': {
        'account_id': 789,
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

/// Tool for account balance inquiries and management
class AccountBalanceInquiryTool extends FinancialDataTool {
  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;

  AccountBalanceInquiryTool(this._accountRepository, this._transactionRepository);

  @override
  String get name => 'account_balance_inquiry';

  @override
  String get description => 
      'Get detailed balance information and recent transaction summaries for accounts';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'inquiry_type': {
        'type': 'string',
        'enum': ['single_account', 'all_accounts', 'currency_summary', 'account_history'],
        'description': 'Type of balance inquiry to perform',
      },
      'account_id': {
        'type': 'integer',
        'description': 'Specific account ID for single_account or account_history',
      },
      'currency': {
        'type': 'string',
        'description': 'Currency code for currency_summary',
      },
      'days_back': {
        'type': 'integer',
        'description': 'Number of days to look back for history (default 30)',
        'minimum': 1,
        'maximum': 365,
        'default': 30,
      },
    },
    'required': ['inquiry_type'],
  };

  @override
  AIToolConfiguration get configuration => AIToolConfiguration(
    name: name,
    description: description,
    schema: inputSchema,
    metadata: {
      'category': 'accounts',
      'access_level': 'read',
      'provides_insights': true,
    },
  );

  @override
  bool get requiresAccountAccess => false;

  @override
  bool get canModifyData => false;

  @override
  List<String> get accessibleEntities => ['accounts', 'transactions'];

  @override
  Future<dynamic> execute(Map<String, dynamic> parameters) async {
    try {
      final inquiryType = parameters['inquiry_type'] as String;

      switch (inquiryType) {
        case 'single_account':
          final accountId = parameters['account_id'] as int;
          return await _getSingleAccountBalance(accountId);

        case 'all_accounts':
          return await _getAllAccountsBalance();

        case 'currency_summary':
          final currency = parameters['currency'] as String;
          return await _getCurrencySummary(currency);

        case 'account_history':
          final accountId = parameters['account_id'] as int;
          final daysBack = parameters['days_back'] as int? ?? 30;
          return await _getAccountHistory(accountId, daysBack);

        default:
          return {
            'success': false,
            'error': 'Invalid inquiry_type: $inquiryType',
          };
      }

    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to perform balance inquiry: ${e.toString()}',
        'parameters': parameters,
      };
    }
  }

  @override
  bool validateParameters(Map<String, dynamic> parameters) {
    if (!parameters.containsKey('inquiry_type')) return false;
    
    final inquiryType = parameters['inquiry_type'] as String?;
    
    switch (inquiryType) {
      case 'single_account':
      case 'account_history':
        return parameters.containsKey('account_id') && parameters['account_id'] is int;
      case 'currency_summary':
        return parameters.containsKey('currency') && parameters['currency'] is String;
      case 'all_accounts':
        return true;
      default:
        return false;
    }
  }

  @override
  List<Map<String, dynamic>> get examples => [
    {
      'description': 'Get balance for a specific account',
      'parameters': {'inquiry_type': 'single_account', 'account_id': 1},
    },
    {
      'description': 'Get balances for all accounts',
      'parameters': {'inquiry_type': 'all_accounts'},
    },
    {
      'description': 'Get USD account summary',
      'parameters': {'inquiry_type': 'currency_summary', 'currency': 'USD'},
    },
    {
      'description': 'Get account transaction history for last 7 days',
      'parameters': {'inquiry_type': 'account_history', 'account_id': 1, 'days_back': 7},
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

  Future<Map<String, dynamic>> _getSingleAccountBalance(int accountId) async {
    final account = await _accountRepository.getAccountById(accountId);
    if (account == null) {
      return {
        'success': false,
        'error': 'Account with ID $accountId not found',
      };
    }

    // Get recent transactions for this account
    final recentTransactions = await _transactionRepository.getTransactionsByAccount(accountId);
    final last30Days = DateTime.now().subtract(const Duration(days: 30));
    final recentFiltered = recentTransactions.where((t) => t.date.isAfter(last30Days)).toList();

    final totalIncome = recentFiltered
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalExpenses = recentFiltered
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());

    return {
      'success': true,
      'inquiry_type': 'single_account',
      'account': {
        'id': account.id,
        'name': account.name,
        'balance': account.balance,
        'currency': account.currency,
        'is_default': account.isDefault,
      },
      'recent_activity': {
        'period_days': 30,
        'transaction_count': recentFiltered.length,
        'total_income': totalIncome,
        'total_expenses': totalExpenses,
        'net_change': totalIncome - totalExpenses,
      },
    };
  }

  Future<Map<String, dynamic>> _getAllAccountsBalance() async {
    final accounts = await _accountRepository.getAllAccounts();
    
    final accountSummaries = await Future.wait(
      accounts.map((account) async {
        final transactions = await _transactionRepository.getTransactionsByAccount(account.id!);
        final transactionCount = transactions.length;
        
        return {
          'id': account.id,
          'name': account.name,
          'balance': account.balance,
          'currency': account.currency,
          'is_default': account.isDefault,
          'transaction_count': transactionCount,
        };
      })
    );

    // Group by currency
    final currencyGroups = <String, List<Map<String, dynamic>>>{};
    double totalValue = 0.0;
    
    for (final summary in accountSummaries) {
      final currency = summary['currency'] as String;
      currencyGroups.putIfAbsent(currency, () => []).add(summary);
      totalValue += summary['balance'] as double;
    }

    return {
      'success': true,
      'inquiry_type': 'all_accounts',
      'summary': {
        'total_accounts': accounts.length,
        'total_currencies': currencyGroups.length,
        'estimated_total_value': totalValue, // Note: this assumes all currencies are equal
      },
      'accounts': accountSummaries,
      'by_currency': currencyGroups.map((currency, accounts) => MapEntry(
        currency,
        {
          'account_count': accounts.length,
          'total_balance': accounts.fold(0.0, (sum, acc) => sum + (acc['balance'] as double)),
          'accounts': accounts,
        },
      )),
    };
  }

  Future<Map<String, dynamic>> _getCurrencySummary(String currency) async {
    final allAccounts = await _accountRepository.getAllAccounts();
    final currencyAccounts = allAccounts.where((a) => 
      a.currency.toLowerCase() == currency.toLowerCase()
    ).toList();

    if (currencyAccounts.isEmpty) {
      return {
        'success': false,
        'error': 'No accounts found for currency: $currency',
      };
    }

    final totalBalance = currencyAccounts.fold(0.0, (sum, acc) => sum + acc.balance);
    
    final accountSummaries = await Future.wait(
      currencyAccounts.map((account) async {
        final transactions = await _transactionRepository.getTransactionsByAccount(account.id!);
        return {
          'id': account.id,
          'name': account.name,
          'balance': account.balance,
          'transaction_count': transactions.length,
        };
      })
    );

    return {
      'success': true,
      'inquiry_type': 'currency_summary',
      'currency': currency.toUpperCase(),
      'summary': {
        'account_count': currencyAccounts.length,
        'total_balance': totalBalance,
        'average_balance': totalBalance / currencyAccounts.length,
      },
      'accounts': accountSummaries,
    };
  }

  Future<Map<String, dynamic>> _getAccountHistory(int accountId, int daysBack) async {
    final account = await _accountRepository.getAccountById(accountId);
    if (account == null) {
      return {
        'success': false,
        'error': 'Account with ID $accountId not found',
      };
    }

    final startDate = DateTime.now().subtract(Duration(days: daysBack));
    final transactions = await _transactionRepository.getTransactionsByDateRange(startDate, DateTime.now());
    final accountTransactions = transactions.where((t) => t.accountId == accountId).toList();

    // Group by day
    final dailyTotals = <String, Map<String, dynamic>>{};
    
    for (final transaction in accountTransactions) {
      final dateKey = transaction.date.toIso8601String().split('T')[0];
      
      if (!dailyTotals.containsKey(dateKey)) {
        dailyTotals[dateKey] = {
          'date': dateKey,
          'income': 0.0,
          'expenses': 0.0,
          'transaction_count': 0,
        };
      }
      
      final daily = dailyTotals[dateKey]!;
      daily['transaction_count'] = (daily['transaction_count'] as int) + 1;
      
      if (transaction.isIncome) {
        daily['income'] = (daily['income'] as double) + transaction.amount;
      } else {
        daily['expenses'] = (daily['expenses'] as double) + transaction.amount.abs();
      }
    }

    return {
      'success': true,
      'inquiry_type': 'account_history',
      'account': {
        'id': account.id,
        'name': account.name,
        'current_balance': account.balance,
        'currency': account.currency,
      },
      'period': {
        'days_back': daysBack,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': DateTime.now().toIso8601String().split('T')[0],
      },
      'summary': {
        'total_transactions': accountTransactions.length,
        'total_income': accountTransactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount),
        'total_expenses': accountTransactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount.abs()),
      },
      'daily_breakdown': dailyTotals.values.toList()..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String)),
    };
  }
}