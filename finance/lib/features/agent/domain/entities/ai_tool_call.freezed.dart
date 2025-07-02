// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_tool_call.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AIToolCall _$AIToolCallFromJson(Map<String, dynamic> json) {
  return _AIToolCall.fromJson(json);
}

/// @nodoc
mixin _$AIToolCall {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Map<String, dynamic> get arguments => throw _privateConstructorUsedError;
  bool get isExecuted => throw _privateConstructorUsedError;
  String? get result => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this AIToolCall to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIToolCall
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIToolCallCopyWith<AIToolCall> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIToolCallCopyWith<$Res> {
  factory $AIToolCallCopyWith(
          AIToolCall value, $Res Function(AIToolCall) then) =
      _$AIToolCallCopyWithImpl<$Res, AIToolCall>;
  @useResult
  $Res call(
      {String id,
      String name,
      Map<String, dynamic> arguments,
      bool isExecuted,
      String? result,
      String? error});
}

/// @nodoc
class _$AIToolCallCopyWithImpl<$Res, $Val extends AIToolCall>
    implements $AIToolCallCopyWith<$Res> {
  _$AIToolCallCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIToolCall
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? arguments = null,
    Object? isExecuted = null,
    Object? result = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      arguments: null == arguments
          ? _value.arguments
          : arguments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isExecuted: null == isExecuted
          ? _value.isExecuted
          : isExecuted // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIToolCallImplCopyWith<$Res>
    implements $AIToolCallCopyWith<$Res> {
  factory _$$AIToolCallImplCopyWith(
          _$AIToolCallImpl value, $Res Function(_$AIToolCallImpl) then) =
      __$$AIToolCallImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      Map<String, dynamic> arguments,
      bool isExecuted,
      String? result,
      String? error});
}

/// @nodoc
class __$$AIToolCallImplCopyWithImpl<$Res>
    extends _$AIToolCallCopyWithImpl<$Res, _$AIToolCallImpl>
    implements _$$AIToolCallImplCopyWith<$Res> {
  __$$AIToolCallImplCopyWithImpl(
      _$AIToolCallImpl _value, $Res Function(_$AIToolCallImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIToolCall
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? arguments = null,
    Object? isExecuted = null,
    Object? result = freezed,
    Object? error = freezed,
  }) {
    return _then(_$AIToolCallImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      arguments: null == arguments
          ? _value._arguments
          : arguments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isExecuted: null == isExecuted
          ? _value.isExecuted
          : isExecuted // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIToolCallImpl implements _AIToolCall {
  const _$AIToolCallImpl(
      {required this.id,
      required this.name,
      required final Map<String, dynamic> arguments,
      this.isExecuted = false,
      this.result,
      this.error})
      : _arguments = arguments;

  factory _$AIToolCallImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIToolCallImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final Map<String, dynamic> _arguments;
  @override
  Map<String, dynamic> get arguments {
    if (_arguments is EqualUnmodifiableMapView) return _arguments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_arguments);
  }

  @override
  @JsonKey()
  final bool isExecuted;
  @override
  final String? result;
  @override
  final String? error;

  @override
  String toString() {
    return 'AIToolCall(id: $id, name: $name, arguments: $arguments, isExecuted: $isExecuted, result: $result, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIToolCallImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._arguments, _arguments) &&
            (identical(other.isExecuted, isExecuted) ||
                other.isExecuted == isExecuted) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_arguments),
      isExecuted,
      result,
      error);

  /// Create a copy of AIToolCall
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIToolCallImplCopyWith<_$AIToolCallImpl> get copyWith =>
      __$$AIToolCallImplCopyWithImpl<_$AIToolCallImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIToolCallImplToJson(
      this,
    );
  }
}

abstract class _AIToolCall implements AIToolCall {
  const factory _AIToolCall(
      {required final String id,
      required final String name,
      required final Map<String, dynamic> arguments,
      final bool isExecuted,
      final String? result,
      final String? error}) = _$AIToolCallImpl;

  factory _AIToolCall.fromJson(Map<String, dynamic> json) =
      _$AIToolCallImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  Map<String, dynamic> get arguments;
  @override
  bool get isExecuted;
  @override
  String? get result;
  @override
  String? get error;

  /// Create a copy of AIToolCall
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIToolCallImplCopyWith<_$AIToolCallImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ToolExecutionResult _$ToolExecutionResultFromJson(Map<String, dynamic> json) {
  return _ToolExecutionResult.fromJson(json);
}

/// @nodoc
mixin _$ToolExecutionResult {
  String get toolCallId => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  dynamic get result => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  DateTime? get executedAt => throw _privateConstructorUsedError;

  /// Serializes this ToolExecutionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ToolExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ToolExecutionResultCopyWith<ToolExecutionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToolExecutionResultCopyWith<$Res> {
  factory $ToolExecutionResultCopyWith(
          ToolExecutionResult value, $Res Function(ToolExecutionResult) then) =
      _$ToolExecutionResultCopyWithImpl<$Res, ToolExecutionResult>;
  @useResult
  $Res call(
      {String toolCallId,
      bool success,
      dynamic result,
      String? error,
      DateTime? executedAt});
}

/// @nodoc
class _$ToolExecutionResultCopyWithImpl<$Res, $Val extends ToolExecutionResult>
    implements $ToolExecutionResultCopyWith<$Res> {
  _$ToolExecutionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ToolExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toolCallId = null,
    Object? success = null,
    Object? result = freezed,
    Object? error = freezed,
    Object? executedAt = freezed,
  }) {
    return _then(_value.copyWith(
      toolCallId: null == toolCallId
          ? _value.toolCallId
          : toolCallId // ignore: cast_nullable_to_non_nullable
              as String,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as dynamic,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      executedAt: freezed == executedAt
          ? _value.executedAt
          : executedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ToolExecutionResultImplCopyWith<$Res>
    implements $ToolExecutionResultCopyWith<$Res> {
  factory _$$ToolExecutionResultImplCopyWith(_$ToolExecutionResultImpl value,
          $Res Function(_$ToolExecutionResultImpl) then) =
      __$$ToolExecutionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String toolCallId,
      bool success,
      dynamic result,
      String? error,
      DateTime? executedAt});
}

/// @nodoc
class __$$ToolExecutionResultImplCopyWithImpl<$Res>
    extends _$ToolExecutionResultCopyWithImpl<$Res, _$ToolExecutionResultImpl>
    implements _$$ToolExecutionResultImplCopyWith<$Res> {
  __$$ToolExecutionResultImplCopyWithImpl(_$ToolExecutionResultImpl _value,
      $Res Function(_$ToolExecutionResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ToolExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toolCallId = null,
    Object? success = null,
    Object? result = freezed,
    Object? error = freezed,
    Object? executedAt = freezed,
  }) {
    return _then(_$ToolExecutionResultImpl(
      toolCallId: null == toolCallId
          ? _value.toolCallId
          : toolCallId // ignore: cast_nullable_to_non_nullable
              as String,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as dynamic,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      executedAt: freezed == executedAt
          ? _value.executedAt
          : executedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ToolExecutionResultImpl implements _ToolExecutionResult {
  const _$ToolExecutionResultImpl(
      {required this.toolCallId,
      required this.success,
      this.result,
      this.error,
      this.executedAt});

  factory _$ToolExecutionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToolExecutionResultImplFromJson(json);

  @override
  final String toolCallId;
  @override
  final bool success;
  @override
  final dynamic result;
  @override
  final String? error;
  @override
  final DateTime? executedAt;

  @override
  String toString() {
    return 'ToolExecutionResult(toolCallId: $toolCallId, success: $success, result: $result, error: $error, executedAt: $executedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToolExecutionResultImpl &&
            (identical(other.toolCallId, toolCallId) ||
                other.toolCallId == toolCallId) &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other.result, result) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.executedAt, executedAt) ||
                other.executedAt == executedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, toolCallId, success,
      const DeepCollectionEquality().hash(result), error, executedAt);

  /// Create a copy of ToolExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToolExecutionResultImplCopyWith<_$ToolExecutionResultImpl> get copyWith =>
      __$$ToolExecutionResultImplCopyWithImpl<_$ToolExecutionResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ToolExecutionResultImplToJson(
      this,
    );
  }
}

abstract class _ToolExecutionResult implements ToolExecutionResult {
  const factory _ToolExecutionResult(
      {required final String toolCallId,
      required final bool success,
      final dynamic result,
      final String? error,
      final DateTime? executedAt}) = _$ToolExecutionResultImpl;

  factory _ToolExecutionResult.fromJson(Map<String, dynamic> json) =
      _$ToolExecutionResultImpl.fromJson;

  @override
  String get toolCallId;
  @override
  bool get success;
  @override
  dynamic get result;
  @override
  String? get error;
  @override
  DateTime? get executedAt;

  /// Create a copy of ToolExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToolExecutionResultImplCopyWith<_$ToolExecutionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIToolConfiguration _$AIToolConfigurationFromJson(Map<String, dynamic> json) {
  return _AIToolConfiguration.fromJson(json);
}

/// @nodoc
mixin _$AIToolConfiguration {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  Map<String, dynamic> get schema => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this AIToolConfiguration to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIToolConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIToolConfigurationCopyWith<AIToolConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIToolConfigurationCopyWith<$Res> {
  factory $AIToolConfigurationCopyWith(
          AIToolConfiguration value, $Res Function(AIToolConfiguration) then) =
      _$AIToolConfigurationCopyWithImpl<$Res, AIToolConfiguration>;
  @useResult
  $Res call(
      {String name,
      String description,
      Map<String, dynamic> schema,
      bool enabled,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$AIToolConfigurationCopyWithImpl<$Res, $Val extends AIToolConfiguration>
    implements $AIToolConfigurationCopyWith<$Res> {
  _$AIToolConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIToolConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? schema = null,
    Object? enabled = null,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      schema: null == schema
          ? _value.schema
          : schema // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIToolConfigurationImplCopyWith<$Res>
    implements $AIToolConfigurationCopyWith<$Res> {
  factory _$$AIToolConfigurationImplCopyWith(_$AIToolConfigurationImpl value,
          $Res Function(_$AIToolConfigurationImpl) then) =
      __$$AIToolConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String description,
      Map<String, dynamic> schema,
      bool enabled,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$AIToolConfigurationImplCopyWithImpl<$Res>
    extends _$AIToolConfigurationCopyWithImpl<$Res, _$AIToolConfigurationImpl>
    implements _$$AIToolConfigurationImplCopyWith<$Res> {
  __$$AIToolConfigurationImplCopyWithImpl(_$AIToolConfigurationImpl _value,
      $Res Function(_$AIToolConfigurationImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIToolConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? schema = null,
    Object? enabled = null,
    Object? metadata = freezed,
  }) {
    return _then(_$AIToolConfigurationImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      schema: null == schema
          ? _value._schema
          : schema // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIToolConfigurationImpl implements _AIToolConfiguration {
  const _$AIToolConfigurationImpl(
      {required this.name,
      required this.description,
      required final Map<String, dynamic> schema,
      this.enabled = true,
      final Map<String, dynamic>? metadata})
      : _schema = schema,
        _metadata = metadata;

  factory _$AIToolConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIToolConfigurationImplFromJson(json);

  @override
  final String name;
  @override
  final String description;
  final Map<String, dynamic> _schema;
  @override
  Map<String, dynamic> get schema {
    if (_schema is EqualUnmodifiableMapView) return _schema;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_schema);
  }

  @override
  @JsonKey()
  final bool enabled;
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
    return 'AIToolConfiguration(name: $name, description: $description, schema: $schema, enabled: $enabled, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIToolConfigurationImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._schema, _schema) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      const DeepCollectionEquality().hash(_schema),
      enabled,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AIToolConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIToolConfigurationImplCopyWith<_$AIToolConfigurationImpl> get copyWith =>
      __$$AIToolConfigurationImplCopyWithImpl<_$AIToolConfigurationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIToolConfigurationImplToJson(
      this,
    );
  }
}

abstract class _AIToolConfiguration implements AIToolConfiguration {
  const factory _AIToolConfiguration(
      {required final String name,
      required final String description,
      required final Map<String, dynamic> schema,
      final bool enabled,
      final Map<String, dynamic>? metadata}) = _$AIToolConfigurationImpl;

  factory _AIToolConfiguration.fromJson(Map<String, dynamic> json) =
      _$AIToolConfigurationImpl.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  Map<String, dynamic> get schema;
  @override
  bool get enabled;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AIToolConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIToolConfigurationImplCopyWith<_$AIToolConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
