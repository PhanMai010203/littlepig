// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_tool_call.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIToolCallImpl _$$AIToolCallImplFromJson(Map<String, dynamic> json) =>
    _$AIToolCallImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
      isExecuted: json['isExecuted'] as bool? ?? false,
      result: json['result'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$AIToolCallImplToJson(_$AIToolCallImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'arguments': instance.arguments,
      'isExecuted': instance.isExecuted,
      'result': instance.result,
      'error': instance.error,
    };

_$ToolExecutionResultImpl _$$ToolExecutionResultImplFromJson(
        Map<String, dynamic> json) =>
    _$ToolExecutionResultImpl(
      toolCallId: json['toolCallId'] as String,
      success: json['success'] as bool,
      result: json['result'],
      error: json['error'] as String?,
      executedAt: json['executedAt'] == null
          ? null
          : DateTime.parse(json['executedAt'] as String),
    );

Map<String, dynamic> _$$ToolExecutionResultImplToJson(
        _$ToolExecutionResultImpl instance) =>
    <String, dynamic>{
      'toolCallId': instance.toolCallId,
      'success': instance.success,
      'result': instance.result,
      'error': instance.error,
      'executedAt': instance.executedAt?.toIso8601String(),
    };

_$AIToolConfigurationImpl _$$AIToolConfigurationImplFromJson(
        Map<String, dynamic> json) =>
    _$AIToolConfigurationImpl(
      name: json['name'] as String,
      description: json['description'] as String,
      schema: json['schema'] as Map<String, dynamic>,
      enabled: json['enabled'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AIToolConfigurationImplToJson(
        _$AIToolConfigurationImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'schema': instance.schema,
      'enabled': instance.enabled,
      'metadata': instance.metadata,
    };
