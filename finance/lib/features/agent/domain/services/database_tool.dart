import '../entities/ai_tool_call.dart';

/// Abstract base class for all database tools
/// Defines the contract for tools that interact with the app's database
abstract class DatabaseTool {
  /// The unique name of this tool
  String get name;

  /// Human-readable description of what this tool does
  String get description;

  /// JSON schema defining the input parameters for this tool
  Map<String, dynamic> get inputSchema;

  /// Configuration for this tool
  AIToolConfiguration get configuration;

  /// Execute the tool with the given parameters
  /// Returns the result of the operation or throws an exception
  Future<dynamic> execute(Map<String, dynamic> parameters);

  /// Validate that the provided parameters are correct
  /// Returns true if valid, false otherwise
  bool validateParameters(Map<String, dynamic> parameters);

  /// Get example usage of this tool for AI training
  List<Map<String, dynamic>> get examples;
}

/// Specialized interface for financial data tools
abstract class FinancialDataTool extends DatabaseTool {
  /// Whether this tool requires specific account permissions
  bool get requiresAccountAccess;

  /// Whether this tool can modify financial data
  bool get canModifyData;

  /// The types of financial entities this tool can access
  List<String> get accessibleEntities;

  /// Format financial amounts for display
  String formatAmount(double amount, String currencyCode);

  /// Validate financial data before operations
  Future<bool> validateFinancialData(Map<String, dynamic> data);
}

/// Interface for tools that can perform bulk operations
abstract class BulkOperationTool extends FinancialDataTool {
  /// Maximum number of items that can be processed in a single operation
  int get maxBatchSize;

  /// Execute the tool in bulk mode with multiple items
  Future<List<dynamic>> executeBulk(List<Map<String, dynamic>> parametersList);

  /// Validate all items in a bulk operation
  Future<List<String>> validateBulkParameters(List<Map<String, dynamic>> parametersList);
}

/// Tool execution context containing metadata about the current operation
class ToolExecutionContext {
  final String userId;
  final DateTime requestTime;
  final Map<String, dynamic> sessionData;
  final List<String> conversationHistory;

  const ToolExecutionContext({
    required this.userId,
    required this.requestTime,
    required this.sessionData,
    required this.conversationHistory,
  });
}

/// Result wrapper for tool executions
class ToolResult {
  final bool success;
  final dynamic data;
  final String? error;
  final Map<String, dynamic>? metadata;

  const ToolResult({
    required this.success,
    this.data,
    this.error,
    this.metadata,
  });

  factory ToolResult.success(dynamic data, {Map<String, dynamic>? metadata}) {
    return ToolResult(
      success: true,
      data: data,
      metadata: metadata,
    );
  }

  factory ToolResult.error(String error, {Map<String, dynamic>? metadata}) {
    return ToolResult(
      success: false,
      error: error,
      metadata: metadata,
    );
  }
}