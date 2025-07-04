import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_tool_call.freezed.dart';
part 'ai_tool_call.g.dart';

/// Represents a tool call made by the AI
@freezed
class AIToolCall with _$AIToolCall {
  const factory AIToolCall({
    required String id,
    required String name,
    required Map<String, dynamic> arguments,
    @Default(false) bool isExecuted,
    String? result,
    String? error,
  }) = _AIToolCall;

  factory AIToolCall.fromJson(Map<String, dynamic> json) =>
      _$AIToolCallFromJson(json);
}

/// Represents the result of executing a tool call
@freezed
class ToolExecutionResult with _$ToolExecutionResult {
  const factory ToolExecutionResult({
    required String toolCallId,
    required bool success,
    dynamic result,
    String? error,
    DateTime? executedAt,
  }) = _ToolExecutionResult;

  factory ToolExecutionResult.fromJson(Map<String, dynamic> json) =>
      _$ToolExecutionResultFromJson(json);
}

/// Configuration for AI tools and their capabilities
@freezed
class AIToolConfiguration with _$AIToolConfiguration {
  const factory AIToolConfiguration({
    required String name,
    required String description,
    required Map<String, dynamic> schema,
    @Default(true) bool enabled,
    Map<String, dynamic>? metadata,
  }) = _AIToolConfiguration;

  factory AIToolConfiguration.fromJson(Map<String, dynamic> json) =>
      _$AIToolConfigurationFromJson(json);
}