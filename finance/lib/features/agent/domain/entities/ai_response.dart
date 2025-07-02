import 'package:freezed_annotation/freezed_annotation.dart';
import 'ai_tool_call.dart';

part 'ai_response.freezed.dart';
part 'ai_response.g.dart';

/// Represents a complete AI response including content and tool calls
@freezed
class AIResponse with _$AIResponse {
  const factory AIResponse({
    required String id,
    required String content,
    @Default([]) List<AIToolCall> toolCalls,
    @Default(false) bool isStreaming,
    @Default(false) bool isComplete,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) = _AIResponse;

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);
}

/// Represents AI service configuration
@freezed
class AIServiceConfig with _$AIServiceConfig {
  const factory AIServiceConfig({
    required String apiKey,
    @Default('gemini-1.5-pro') String model,
    @Default(0.3) double temperature,
    @Default(4000) int maxTokens,
    @Default(true) bool toolsEnabled,
    @Default([]) List<String> enabledTools,
  }) = _AIServiceConfig;

  factory AIServiceConfig.fromJson(Map<String, dynamic> json) =>
      _$AIServiceConfigFromJson(json);
}