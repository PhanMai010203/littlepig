// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIResponseImpl _$$AIResponseImplFromJson(Map<String, dynamic> json) =>
    _$AIResponseImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      toolCalls: (json['toolCalls'] as List<dynamic>?)
              ?.map((e) => AIToolCall.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isStreaming: json['isStreaming'] as bool? ?? false,
      isComplete: json['isComplete'] as bool? ?? false,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AIResponseImplToJson(_$AIResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'toolCalls': instance.toolCalls,
      'isStreaming': instance.isStreaming,
      'isComplete': instance.isComplete,
      'timestamp': instance.timestamp?.toIso8601String(),
      'metadata': instance.metadata,
    };

_$AIServiceConfigImpl _$$AIServiceConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$AIServiceConfigImpl(
      apiKey: json['apiKey'] as String,
      model: json['model'] as String? ?? 'gemini-1.5-pro',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.3,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 4000,
      toolsEnabled: json['toolsEnabled'] as bool? ?? true,
      enabledTools: (json['enabledTools'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$AIServiceConfigImplToJson(
        _$AIServiceConfigImpl instance) =>
    <String, dynamic>{
      'apiKey': instance.apiKey,
      'model': instance.model,
      'temperature': instance.temperature,
      'maxTokens': instance.maxTokens,
      'toolsEnabled': instance.toolsEnabled,
      'enabledTools': instance.enabledTools,
    };
