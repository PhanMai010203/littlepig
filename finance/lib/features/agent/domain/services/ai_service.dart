import '../entities/ai_response.dart';
import '../entities/ai_tool_call.dart';
import '../entities/chat_message.dart';

/// Core AI service interface defining the contract for AI operations
abstract class AIService {
  /// Initialize the AI service with configuration
  Future<void> initialize(AIServiceConfig config);

  /// Check if the service is properly configured and ready
  bool get isInitialized;

  /// Check if the service is currently configured
  bool get isConfigured;

  /// Send a message and get a streaming response
  Stream<AIResponse> sendMessageStream(
    String message, {
    List<ChatMessage>? conversationHistory,
    List<AIToolConfiguration>? availableTools,
  });

  /// Send a message and get a complete response
  Future<AIResponse> sendMessage(
    String message, {
    List<ChatMessage>? conversationHistory,
    List<AIToolConfiguration>? availableTools,
  });

  /// Update the service configuration
  Future<void> updateConfiguration(AIServiceConfig config);

  /// Dispose of any resources
  Future<void> dispose();
}

/// Interface for managing AI tools and their execution
abstract class AIToolManager {
  /// Get all available tools
  List<AIToolConfiguration> get availableTools;

  /// Register a new tool
  void registerTool(AIToolConfiguration tool);

  /// Execute a tool call and return the result
  Future<ToolExecutionResult> executeTool(AIToolCall toolCall);

  /// Execute multiple tool calls in parallel
  Future<List<ToolExecutionResult>> executeTools(List<AIToolCall> toolCalls);

  /// Check if a tool is available and enabled
  bool isToolAvailable(String toolName);

  /// Get tool configuration by name
  AIToolConfiguration? getToolConfiguration(String toolName);
}

/// Interface for managing conversation context and memory
abstract class ConversationManager {
  /// Add a message to the conversation history
  void addMessage(ChatMessage message);

  /// Get the current conversation history
  List<ChatMessage> get conversationHistory;

  /// Clear the conversation history
  void clearHistory();

  /// Get conversation summary for context management
  String getConversationSummary();

  /// Limit conversation history to fit within token limits
  List<ChatMessage> getTrimmedHistory(int maxTokens);
}