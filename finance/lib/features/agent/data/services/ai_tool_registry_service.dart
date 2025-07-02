import 'package:get_it/get_it.dart';
import '../tools/transaction_tools.dart';
import '../tools/budget_tools.dart';
import '../tools/account_tools.dart';
import '../tools/category_tools.dart';
import 'gemini_ai_service.dart';

/// Service that registers all database tools with the AI system
class AIToolRegistryService {
  final DatabaseToolRegistry _toolRegistry;

  AIToolRegistryService(this._toolRegistry);

  /// Register all available database tools
  void registerAllTools() {
    final getIt = GetIt.instance;

    // Register Transaction Tools
    _toolRegistry.registerDatabaseTool(
      QueryTransactionsTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      CreateTransactionTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      UpdateTransactionTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      DeleteTransactionTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      TransactionAnalyticsTool(getIt.get()),
    );

    // Register Budget Tools
    _toolRegistry.registerDatabaseTool(
      QueryBudgetsTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      CreateBudgetTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      UpdateBudgetTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      DeleteBudgetTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      BudgetAnalyticsTool(getIt.get()),
    );

    // Register Account Tools
    _toolRegistry.registerDatabaseTool(
      QueryAccountsTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      CreateAccountTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      UpdateAccountTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      DeleteAccountTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      AccountBalanceInquiryTool(getIt.get(), getIt.get()),
    );

    // Register Category Tools
    _toolRegistry.registerDatabaseTool(
      QueryCategoriesTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      CreateCategoryTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      UpdateCategoryTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      DeleteCategoryTool(getIt.get()),
    );
    _toolRegistry.registerDatabaseTool(
      CategoryInsightsTool(getIt.get(), getIt.get()),
    );
  }

  /// Get the number of registered tools
  int get registeredToolCount => _toolRegistry.availableTools.length;

  /// Get all available tool names
  List<String> get availableToolNames => 
      _toolRegistry.availableTools.map((tool) => tool.name).toList();

  /// Check if a specific tool is available
  bool isToolAvailable(String toolName) => 
      _toolRegistry.isToolAvailable(toolName);
}