import '../entities/ai_response.dart';
import '../entities/ai_tool_call.dart';
import '../entities/chat_message.dart';

/// Repository interface for AI service operations
/// Defines the contract for AI interactions with tool calling capabilities
abstract class AIServiceRepository {
  /// Initialize the AI service with the current configuration
  Future<void> initialize();

  /// Check if the AI service is properly configured and ready
  bool get isConfigured;

  /// Send a message to the AI and get a response with potential tool calls
  /// Returns a stream of responses to handle streaming responses
  Stream<AIResponse> sendMessageStream(
    String message, {
    List<ChatMessage>? conversationHistory,
    List<AIToolConfiguration>? availableTools,
  });

  /// Send a message and get tool calls that need to be executed
  Future<List<AIToolCall>> getToolCalls(
    String message, {
    List<ChatMessage>? conversationHistory,
    List<AIToolConfiguration>? availableTools,
  });

  /// Execute tool calls and get the final AI response
  Future<AIResponse> executeToolsAndGetResponse(
    String originalMessage,
    List<ChatMessage> conversationHistory,
    List<AIToolCall> toolCalls,
    List<ToolExecutionResult> toolResults,
  );

  /// Update AI service configuration
  Future<void> updateConfiguration(AIServiceConfig config);

  /// Dispose of any resources
  Future<void> dispose();
}