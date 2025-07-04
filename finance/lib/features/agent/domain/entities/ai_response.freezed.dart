// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AIResponse _$AIResponseFromJson(Map<String, dynamic> json) {
  return _AIResponse.fromJson(json);
}

/// @nodoc
mixin _$AIResponse {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<AIToolCall> get toolCalls => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;
  bool get isComplete => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this AIResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIResponseCopyWith<AIResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIResponseCopyWith<$Res> {
  factory $AIResponseCopyWith(
          AIResponse value, $Res Function(AIResponse) then) =
      _$AIResponseCopyWithImpl<$Res, AIResponse>;
  @useResult
  $Res call(
      {String id,
      String content,
      List<AIToolCall> toolCalls,
      bool isStreaming,
      bool isComplete,
      DateTime? timestamp,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$AIResponseCopyWithImpl<$Res, $Val extends AIResponse>
    implements $AIResponseCopyWith<$Res> {
  _$AIResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? toolCalls = null,
    Object? isStreaming = null,
    Object? isComplete = null,
    Object? timestamp = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      toolCalls: null == toolCalls
          ? _value.toolCalls
          : toolCalls // ignore: cast_nullable_to_non_nullable
              as List<AIToolCall>,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIResponseImplCopyWith<$Res>
    implements $AIResponseCopyWith<$Res> {
  factory _$$AIResponseImplCopyWith(
          _$AIResponseImpl value, $Res Function(_$AIResponseImpl) then) =
      __$$AIResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String content,
      List<AIToolCall> toolCalls,
      bool isStreaming,
      bool isComplete,
      DateTime? timestamp,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$AIResponseImplCopyWithImpl<$Res>
    extends _$AIResponseCopyWithImpl<$Res, _$AIResponseImpl>
    implements _$$AIResponseImplCopyWith<$Res> {
  __$$AIResponseImplCopyWithImpl(
      _$AIResponseImpl _value, $Res Function(_$AIResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? toolCalls = null,
    Object? isStreaming = null,
    Object? isComplete = null,
    Object? timestamp = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$AIResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      toolCalls: null == toolCalls
          ? _value._toolCalls
          : toolCalls // ignore: cast_nullable_to_non_nullable
              as List<AIToolCall>,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIResponseImpl implements _AIResponse {
  const _$AIResponseImpl(
      {required this.id,
      required this.content,
      final List<AIToolCall> toolCalls = const [],
      this.isStreaming = false,
      this.isComplete = false,
      this.timestamp,
      final Map<String, dynamic>? metadata})
      : _toolCalls = toolCalls,
        _metadata = metadata;

  factory _$AIResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIResponseImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  final List<AIToolCall> _toolCalls;
  @override
  @JsonKey()
  List<AIToolCall> get toolCalls {
    if (_toolCalls is EqualUnmodifiableListView) return _toolCalls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_toolCalls);
  }

  @override
  @JsonKey()
  final bool isStreaming;
  @override
  @JsonKey()
  final bool isComplete;
  @override
  final DateTime? timestamp;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AIResponse(id: $id, content: $content, toolCalls: $toolCalls, isStreaming: $isStreaming, isComplete: $isComplete, timestamp: $timestamp, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality()
                .equals(other._toolCalls, _toolCalls) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming) &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      content,
      const DeepCollectionEquality().hash(_toolCalls),
      isStreaming,
      isComplete,
      timestamp,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIResponseImplCopyWith<_$AIResponseImpl> get copyWith =>
      __$$AIResponseImplCopyWithImpl<_$AIResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIResponseImplToJson(
      this,
    );
  }
}

abstract class _AIResponse implements AIResponse {
  const factory _AIResponse(
      {required final String id,
      required final String content,
      final List<AIToolCall> toolCalls,
      final bool isStreaming,
      final bool isComplete,
      final DateTime? timestamp,
      final Map<String, dynamic>? metadata}) = _$AIResponseImpl;

  factory _AIResponse.fromJson(Map<String, dynamic> json) =
      _$AIResponseImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  List<AIToolCall> get toolCalls;
  @override
  bool get isStreaming;
  @override
  bool get isComplete;
  @override
  DateTime? get timestamp;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIResponseImplCopyWith<_$AIResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIServiceConfig _$AIServiceConfigFromJson(Map<String, dynamic> json) {
  return _AIServiceConfig.fromJson(json);
}

/// @nodoc
mixin _$AIServiceConfig {
  String get apiKey => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  int get maxTokens => throw _privateConstructorUsedError;
  bool get toolsEnabled => throw _privateConstructorUsedError;
  List<String> get enabledTools => throw _privateConstructorUsedError;

  /// Serializes this AIServiceConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIServiceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIServiceConfigCopyWith<AIServiceConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIServiceConfigCopyWith<$Res> {
  factory $AIServiceConfigCopyWith(
          AIServiceConfig value, $Res Function(AIServiceConfig) then) =
      _$AIServiceConfigCopyWithImpl<$Res, AIServiceConfig>;
  @useResult
  $Res call(
      {String apiKey,
      String model,
      double temperature,
      int maxTokens,
      bool toolsEnabled,
      List<String> enabledTools});
}

/// @nodoc
class _$AIServiceConfigCopyWithImpl<$Res, $Val extends AIServiceConfig>
    implements $AIServiceConfigCopyWith<$Res> {
  _$AIServiceConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIServiceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiKey = null,
    Object? model = null,
    Object? temperature = null,
    Object? maxTokens = null,
    Object? toolsEnabled = null,
    Object? enabledTools = null,
  }) {
    return _then(_value.copyWith(
      apiKey: null == apiKey
          ? _value.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      toolsEnabled: null == toolsEnabled
          ? _value.toolsEnabled
          : toolsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      enabledTools: null == enabledTools
          ? _value.enabledTools
          : enabledTools // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIServiceConfigImplCopyWith<$Res>
    implements $AIServiceConfigCopyWith<$Res> {
  factory _$$AIServiceConfigImplCopyWith(_$AIServiceConfigImpl value,
          $Res Function(_$AIServiceConfigImpl) then) =
      __$$AIServiceConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String apiKey,
      String model,
      double temperature,
      int maxTokens,
      bool toolsEnabled,
      List<String> enabledTools});
}

/// @nodoc
class __$$AIServiceConfigImplCopyWithImpl<$Res>
    extends _$AIServiceConfigCopyWithImpl<$Res, _$AIServiceConfigImpl>
    implements _$$AIServiceConfigImplCopyWith<$Res> {
  __$$AIServiceConfigImplCopyWithImpl(
      _$AIServiceConfigImpl _value, $Res Function(_$AIServiceConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIServiceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiKey = null,
    Object? model = null,
    Object? temperature = null,
    Object? maxTokens = null,
    Object? toolsEnabled = null,
    Object? enabledTools = null,
  }) {
    return _then(_$AIServiceConfigImpl(
      apiKey: null == apiKey
          ? _value.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      toolsEnabled: null == toolsEnabled
          ? _value.toolsEnabled
          : toolsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      enabledTools: null == enabledTools
          ? _value._enabledTools
          : enabledTools // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIServiceConfigImpl implements _AIServiceConfig {
  const _$AIServiceConfigImpl(
      {required this.apiKey,
      this.model = 'gemini-1.5-pro',
      this.temperature = 0.3,
      this.maxTokens = 4000,
      this.toolsEnabled = true,
      final List<String> enabledTools = const []})
      : _enabledTools = enabledTools;

  factory _$AIServiceConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIServiceConfigImplFromJson(json);

  @override
  final String apiKey;
  @override
  @JsonKey()
  final String model;
  @override
  @JsonKey()
  final double temperature;
  @override
  @JsonKey()
  final int maxTokens;
  @override
  @JsonKey()
  final bool toolsEnabled;
  final List<String> _enabledTools;
  @override
  @JsonKey()
  List<String> get enabledTools {
    if (_enabledTools is EqualUnmodifiableListView) return _enabledTools;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enabledTools);
  }

  @override
  String toString() {
    return 'AIServiceConfig(apiKey: $apiKey, model: $model, temperature: $temperature, maxTokens: $maxTokens, toolsEnabled: $toolsEnabled, enabledTools: $enabledTools)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIServiceConfigImpl &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.toolsEnabled, toolsEnabled) ||
                other.toolsEnabled == toolsEnabled) &&
            const DeepCollectionEquality()
                .equals(other._enabledTools, _enabledTools));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      apiKey,
      model,
      temperature,
      maxTokens,
      toolsEnabled,
      const DeepCollectionEquality().hash(_enabledTools));

  /// Create a copy of AIServiceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIServiceConfigImplCopyWith<_$AIServiceConfigImpl> get copyWith =>
      __$$AIServiceConfigImplCopyWithImpl<_$AIServiceConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIServiceConfigImplToJson(
      this,
    );
  }
}

abstract class _AIServiceConfig implements AIServiceConfig {
  const factory _AIServiceConfig(
      {required final String apiKey,
      final String model,
      final double temperature,
      final int maxTokens,
      final bool toolsEnabled,
      final List<String> enabledTools}) = _$AIServiceConfigImpl;

  factory _AIServiceConfig.fromJson(Map<String, dynamic> json) =
      _$AIServiceConfigImpl.fromJson;

  @override
  String get apiKey;
  @override
  String get model;
  @override
  double get temperature;
  @override
  int get maxTokens;
  @override
  bool get toolsEnabled;
  @override
  List<String> get enabledTools;

  /// Create a copy of AIServiceConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIServiceConfigImplCopyWith<_$AIServiceConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
