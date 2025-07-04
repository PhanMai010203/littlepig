import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../tools/transaction_tools.dart';
import '../tools/budget_tools.dart';
import '../tools/account_tools.dart';
import '../tools/category_tools.dart';
import 'gemini_ai_service.dart';

/// Service that registers all database tools with the AI system
class AIToolRegistryService {
  final DatabaseToolRegistry _toolRegistry;

  AIToolRegistryService(this._toolRegistry) {
    debugPrint('📝 AIToolRegistryService - Constructor called');
  }

  /// Register all available database tools
  void registerAllTools() {
    debugPrint('🚀 AIToolRegistryService - Starting tool registration');
    final getIt = GetIt.instance;

    // Register Transaction Tools
    debugPrint('💰 Registering Transaction Tools...');
    _registerTransactionTools(getIt);

    // Register Budget Tools
    debugPrint('📊 Registering Budget Tools...');
    _registerBudgetTools(getIt);

    // Register Account Tools
    debugPrint('🏦 Registering Account Tools...');
    _registerAccountTools(getIt);

    // Register Category Tools
    debugPrint('🏷️ Registering Category Tools...');
    _registerCategoryTools(getIt);

    debugPrint('✅ AIToolRegistryService - All tools registered successfully');
    debugPrint('📊 Total tools registered: ${_toolRegistry.availableTools.length}');
  }

  void _registerTransactionTools(GetIt getIt) {
    try {
      debugPrint('  🔧 Registering QueryTransactionsTool');
      _toolRegistry.registerDatabaseTool(
        QueryTransactionsTool(getIt.get()),
      );

      debugPrint('  🔧 Registering CreateTransactionTool');
      _toolRegistry.registerDatabaseTool(
        CreateTransactionTool(getIt.get(), getIt.get()),
      );

      debugPrint('  🔧 Registering UpdateTransactionTool');
      _toolRegistry.registerDatabaseTool(
        UpdateTransactionTool(getIt.get()),
      );

      debugPrint('  🔧 Registering DeleteTransactionTool');
      _toolRegistry.registerDatabaseTool(
        DeleteTransactionTool(getIt.get()),
      );

      debugPrint('  🔧 Registering TransactionAnalyticsTool');
      _toolRegistry.registerDatabaseTool(
        TransactionAnalyticsTool(getIt.get()),
      );

      debugPrint('  ✅ Transaction tools registered successfully');
    } catch (e) {
      debugPrint('  ❌ Error registering transaction tools: $e');
    }
  }

  void _registerBudgetTools(GetIt getIt) {
    try {
      debugPrint('  🔧 Registering QueryBudgetsTool');
      _toolRegistry.registerDatabaseTool(
        QueryBudgetsTool(getIt.get()),
      );

      debugPrint('  🔧 Registering CreateBudgetTool');
      _toolRegistry.registerDatabaseTool(
        CreateBudgetTool(getIt.get()),
      );

      debugPrint('  🔧 Registering UpdateBudgetTool');
      _toolRegistry.registerDatabaseTool(
        UpdateBudgetTool(getIt.get()),
      );

      debugPrint('  🔧 Registering DeleteBudgetTool');
      _toolRegistry.registerDatabaseTool(
        DeleteBudgetTool(getIt.get()),
      );

      debugPrint('  🔧 Registering BudgetAnalyticsTool');
      _toolRegistry.registerDatabaseTool(
        BudgetAnalyticsTool(getIt.get()),
      );

      debugPrint('  ✅ Budget tools registered successfully');
    } catch (e) {
      debugPrint('  ❌ Error registering budget tools: $e');
    }
  }

  void _registerAccountTools(GetIt getIt) {
    try {
      debugPrint('  🔧 Registering QueryAccountsTool');
      _toolRegistry.registerDatabaseTool(
        QueryAccountsTool(getIt.get()),
      );

      debugPrint('  🔧 Registering CreateAccountTool');
      _toolRegistry.registerDatabaseTool(
        CreateAccountTool(getIt.get(), getIt.get()),
      );

      debugPrint('  🔧 Registering UpdateAccountTool');
      _toolRegistry.registerDatabaseTool(
        UpdateAccountTool(getIt.get()),
      );

      debugPrint('  🔧 Registering DeleteAccountTool');
      _toolRegistry.registerDatabaseTool(
        DeleteAccountTool(getIt.get()),
      );

      debugPrint('  🔧 Registering AccountBalanceInquiryTool');
      _toolRegistry.registerDatabaseTool(
        AccountBalanceInquiryTool(getIt.get(), getIt.get()),
      );

      debugPrint('  ✅ Account tools registered successfully');
    } catch (e) {
      debugPrint('  ❌ Error registering account tools: $e');
    }
  }

  void _registerCategoryTools(GetIt getIt) {
    try {
      debugPrint('  🔧 Registering QueryCategoriesTool');
      _toolRegistry.registerDatabaseTool(
        QueryCategoriesTool(getIt.get()),
      );

      debugPrint('  🔧 Registering CreateCategoryTool');
      _toolRegistry.registerDatabaseTool(
        CreateCategoryTool(getIt.get()),
      );

      debugPrint('  🔧 Registering UpdateCategoryTool');
      _toolRegistry.registerDatabaseTool(
        UpdateCategoryTool(getIt.get()),
      );

      debugPrint('  🔧 Registering DeleteCategoryTool');
      _toolRegistry.registerDatabaseTool(
        DeleteCategoryTool(getIt.get()),
      );

      debugPrint('  🔧 Registering CategoryInsightsTool');
      _toolRegistry.registerDatabaseTool(
        CategoryInsightsTool(getIt.get(), getIt.get()),
      );

      debugPrint('  ✅ Category tools registered successfully');
    } catch (e) {
      debugPrint('  ❌ Error registering category tools: $e');
    }
  }

  /// Get the number of registered tools
  int get registeredToolCount {
    final count = _toolRegistry.availableTools.length;
    debugPrint('📊 AIToolRegistryService - registeredToolCount: $count');
    return count;
  }

  /// Get list of available tool names
  List<String> get availableToolNames {
    final names = _toolRegistry.availableTools.map((tool) => tool.name).toList();
    debugPrint('📋 AIToolRegistryService - availableToolNames: ${names.length} tools');
    return names;
  }

  /// Check if a specific tool is registered
  bool isToolRegistered(String toolName) {
    final registered = _toolRegistry.isToolAvailable(toolName);
    debugPrint('🔍 AIToolRegistryService - isToolRegistered($toolName): $registered');
    return registered;
  }

  /// Get debug information
  void printDebugInfo() {
    debugPrint('🔍 AIToolRegistryService - Debug Information:');
    debugPrint('  - Total registered tools: $registeredToolCount');
    debugPrint('  - Available tool names:');
    for (int i = 0; i < availableToolNames.length; i++) {
      debugPrint('    ${i + 1}. ${availableToolNames[i]}');
    }
  }
}