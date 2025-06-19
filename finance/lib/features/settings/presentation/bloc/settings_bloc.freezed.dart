// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SettingsEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSettings,
    required TResult Function(ThemeMode themeMode) themeModeChanged,
    required TResult Function(bool enabled) analyticsToggled,
    required TResult Function(bool enabled) autoBackupToggled,
    required TResult Function(bool enabled) notificationsToggled,
    required TResult Function(bool enabled) hapticFeedbackToggled,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSettings,
    TResult? Function(ThemeMode themeMode)? themeModeChanged,
    TResult? Function(bool enabled)? analyticsToggled,
    TResult? Function(bool enabled)? autoBackupToggled,
    TResult? Function(bool enabled)? notificationsToggled,
    TResult? Function(bool enabled)? hapticFeedbackToggled,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSettings,
    TResult Function(ThemeMode themeMode)? themeModeChanged,
    TResult Function(bool enabled)? analyticsToggled,
    TResult Function(bool enabled)? autoBackupToggled,
    TResult Function(bool enabled)? notificationsToggled,
    TResult Function(bool enabled)? hapticFeedbackToggled,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadSettings value) loadSettings,
    required TResult Function(_ThemeModeChanged value) themeModeChanged,
    required TResult Function(_AnalyticsToggled value) analyticsToggled,
    required TResult Function(_AutoBackupToggled value) autoBackupToggled,
    required TResult Function(_NotificationsToggled value) notificationsToggled,
    required TResult Function(_HapticFeedbackToggled value)
        hapticFeedbackToggled,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadSettings value)? loadSettings,
    TResult? Function(_ThemeModeChanged value)? themeModeChanged,
    TResult? Function(_AnalyticsToggled value)? analyticsToggled,
    TResult? Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult? Function(_NotificationsToggled value)? notificationsToggled,
    TResult? Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadSettings value)? loadSettings,
    TResult Function(_ThemeModeChanged value)? themeModeChanged,
    TResult Function(_AnalyticsToggled value)? analyticsToggled,
    TResult Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult Function(_NotificationsToggled value)? notificationsToggled,
    TResult Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsEventCopyWith<$Res> {
  factory $SettingsEventCopyWith(
          SettingsEvent value, $Res Function(SettingsEvent) then) =
      _$SettingsEventCopyWithImpl<$Res, SettingsEvent>;
}

/// @nodoc
class _$SettingsEventCopyWithImpl<$Res, $Val extends SettingsEvent>
    implements $SettingsEventCopyWith<$Res> {
  _$SettingsEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadSettingsImplCopyWith<$Res> {
  factory _$$LoadSettingsImplCopyWith(
          _$LoadSettingsImpl value, $Res Function(_$LoadSettingsImpl) then) =
      __$$LoadSettingsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadSettingsImplCopyWithImpl<$Res>
    extends _$SettingsEventCopyWithImpl<$Res, _$LoadSettingsImpl>
    implements _$$LoadSettingsImplCopyWith<$Res> {
  __$$LoadSettingsImplCopyWithImpl(
      _$LoadSettingsImpl _value, $Res Function(_$LoadSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadSettingsImpl implements _LoadSettings {
  const _$LoadSettingsImpl();

  @override
  String toString() {
    return 'SettingsEvent.loadSettings()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadSettingsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSettings,
    required TResult Function(ThemeMode themeMode) themeModeChanged,
    required TResult Function(bool enabled) analyticsToggled,
    required TResult Function(bool enabled) autoBackupToggled,
    required TResult Function(bool enabled) notificationsToggled,
    required TResult Function(bool enabled) hapticFeedbackToggled,
  }) {
    return loadSettings();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSettings,
    TResult? Function(ThemeMode themeMode)? themeModeChanged,
    TResult? Function(bool enabled)? analyticsToggled,
    TResult? Function(bool enabled)? autoBackupToggled,
    TResult? Function(bool enabled)? notificationsToggled,
    TResult? Function(bool enabled)? hapticFeedbackToggled,
  }) {
    return loadSettings?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSettings,
    TResult Function(ThemeMode themeMode)? themeModeChanged,
    TResult Function(bool enabled)? analyticsToggled,
    TResult Function(bool enabled)? autoBackupToggled,
    TResult Function(bool enabled)? notificationsToggled,
    TResult Function(bool enabled)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (loadSettings != null) {
      return loadSettings();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadSettings value) loadSettings,
    required TResult Function(_ThemeModeChanged value) themeModeChanged,
    required TResult Function(_AnalyticsToggled value) analyticsToggled,
    required TResult Function(_AutoBackupToggled value) autoBackupToggled,
    required TResult Function(_NotificationsToggled value) notificationsToggled,
    required TResult Function(_HapticFeedbackToggled value)
        hapticFeedbackToggled,
  }) {
    return loadSettings(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadSettings value)? loadSettings,
    TResult? Function(_ThemeModeChanged value)? themeModeChanged,
    TResult? Function(_AnalyticsToggled value)? analyticsToggled,
    TResult? Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult? Function(_NotificationsToggled value)? notificationsToggled,
    TResult? Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
  }) {
    return loadSettings?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadSettings value)? loadSettings,
    TResult Function(_ThemeModeChanged value)? themeModeChanged,
    TResult Function(_AnalyticsToggled value)? analyticsToggled,
    TResult Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult Function(_NotificationsToggled value)? notificationsToggled,
    TResult Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (loadSettings != null) {
      return loadSettings(this);
    }
    return orElse();
  }
}

abstract class _LoadSettings implements SettingsEvent {
  const factory _LoadSettings() = _$LoadSettingsImpl;
}

/// @nodoc
abstract class _$$ThemeModeChangedImplCopyWith<$Res> {
  factory _$$ThemeModeChangedImplCopyWith(_$ThemeModeChangedImpl value,
          $Res Function(_$ThemeModeChangedImpl) then) =
      __$$ThemeModeChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ThemeMode themeMode});
}

/// @nodoc
class __$$ThemeModeChangedImplCopyWithImpl<$Res>
    extends _$SettingsEventCopyWithImpl<$Res, _$ThemeModeChangedImpl>
    implements _$$ThemeModeChangedImplCopyWith<$Res> {
  __$$ThemeModeChangedImplCopyWithImpl(_$ThemeModeChangedImpl _value,
      $Res Function(_$ThemeModeChangedImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
  }) {
    return _then(_$ThemeModeChangedImpl(
      null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
    ));
  }
}

/// @nodoc

class _$ThemeModeChangedImpl implements _ThemeModeChanged {
  const _$ThemeModeChangedImpl(this.themeMode);

  @override
  final ThemeMode themeMode;

  @override
  String toString() {
    return 'SettingsEvent.themeModeChanged(themeMode: $themeMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThemeModeChangedImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, themeMode);

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThemeModeChangedImplCopyWith<_$ThemeModeChangedImpl> get copyWith =>
      __$$ThemeModeChangedImplCopyWithImpl<_$ThemeModeChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSettings,
    required TResult Function(ThemeMode themeMode) themeModeChanged,
    required TResult Function(bool enabled) analyticsToggled,
    required TResult Function(bool enabled) autoBackupToggled,
    required TResult Function(bool enabled) notificationsToggled,
    required TResult Function(bool enabled) hapticFeedbackToggled,
  }) {
    return themeModeChanged(themeMode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSettings,
    TResult? Function(ThemeMode themeMode)? themeModeChanged,
    TResult? Function(bool enabled)? analyticsToggled,
    TResult? Function(bool enabled)? autoBackupToggled,
    TResult? Function(bool enabled)? notificationsToggled,
    TResult? Function(bool enabled)? hapticFeedbackToggled,
  }) {
    return themeModeChanged?.call(themeMode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSettings,
    TResult Function(ThemeMode themeMode)? themeModeChanged,
    TResult Function(bool enabled)? analyticsToggled,
    TResult Function(bool enabled)? autoBackupToggled,
    TResult Function(bool enabled)? notificationsToggled,
    TResult Function(bool enabled)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (themeModeChanged != null) {
      return themeModeChanged(themeMode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadSettings value) loadSettings,
    required TResult Function(_ThemeModeChanged value) themeModeChanged,
    required TResult Function(_AnalyticsToggled value) analyticsToggled,
    required TResult Function(_AutoBackupToggled value) autoBackupToggled,
    required TResult Function(_NotificationsToggled value) notificationsToggled,
    required TResult Function(_HapticFeedbackToggled value)
        hapticFeedbackToggled,
  }) {
    return themeModeChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadSettings value)? loadSettings,
    TResult? Function(_ThemeModeChanged value)? themeModeChanged,
    TResult? Function(_AnalyticsToggled value)? analyticsToggled,
    TResult? Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult? Function(_NotificationsToggled value)? notificationsToggled,
    TResult? Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
  }) {
    return themeModeChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadSettings value)? loadSettings,
    TResult Function(_ThemeModeChanged value)? themeModeChanged,
    TResult Function(_AnalyticsToggled value)? analyticsToggled,
    TResult Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult Function(_NotificationsToggled value)? notificationsToggled,
    TResult Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (themeModeChanged != null) {
      return themeModeChanged(this);
    }
    return orElse();
  }
}

abstract class _ThemeModeChanged implements SettingsEvent {
  const factory _ThemeModeChanged(final ThemeMode themeMode) =
      _$ThemeModeChangedImpl;

  ThemeMode get themeMode;

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThemeModeChangedImplCopyWith<_$ThemeModeChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AnalyticsToggledImplCopyWith<$Res> {
  factory _$$AnalyticsToggledImplCopyWith(_$AnalyticsToggledImpl value,
          $Res Function(_$AnalyticsToggledImpl) then) =
      __$$AnalyticsToggledImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool enabled});
}

/// @nodoc
class __$$AnalyticsToggledImplCopyWithImpl<$Res>
    extends _$SettingsEventCopyWithImpl<$Res, _$AnalyticsToggledImpl>
    implements _$$AnalyticsToggledImplCopyWith<$Res> {
  __$$AnalyticsToggledImplCopyWithImpl(_$AnalyticsToggledImpl _value,
      $Res Function(_$AnalyticsToggledImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
  }) {
    return _then(_$AnalyticsToggledImpl(
      null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AnalyticsToggledImpl implements _AnalyticsToggled {
  const _$AnalyticsToggledImpl(this.enabled);

  @override
  final bool enabled;

  @override
  String toString() {
    return 'SettingsEvent.analyticsToggled(enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsToggledImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enabled);

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsToggledImplCopyWith<_$AnalyticsToggledImpl> get copyWith =>
      __$$AnalyticsToggledImplCopyWithImpl<_$AnalyticsToggledImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSettings,
    required TResult Function(ThemeMode themeMode) themeModeChanged,
    required TResult Function(bool enabled) analyticsToggled,
    required TResult Function(bool enabled) autoBackupToggled,
    required TResult Function(bool enabled) notificationsToggled,
    required TResult Function(bool enabled) hapticFeedbackToggled,
  }) {
    return analyticsToggled(enabled);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSettings,
    TResult? Function(ThemeMode themeMode)? themeModeChanged,
    TResult? Function(bool enabled)? analyticsToggled,
    TResult? Function(bool enabled)? autoBackupToggled,
    TResult? Function(bool enabled)? notificationsToggled,
    TResult? Function(bool enabled)? hapticFeedbackToggled,
  }) {
    return analyticsToggled?.call(enabled);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSettings,
    TResult Function(ThemeMode themeMode)? themeModeChanged,
    TResult Function(bool enabled)? analyticsToggled,
    TResult Function(bool enabled)? autoBackupToggled,
    TResult Function(bool enabled)? notificationsToggled,
    TResult Function(bool enabled)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (analyticsToggled != null) {
      return analyticsToggled(enabled);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadSettings value) loadSettings,
    required TResult Function(_ThemeModeChanged value) themeModeChanged,
    required TResult Function(_AnalyticsToggled value) analyticsToggled,
    required TResult Function(_AutoBackupToggled value) autoBackupToggled,
    required TResult Function(_NotificationsToggled value) notificationsToggled,
    required TResult Function(_HapticFeedbackToggled value)
        hapticFeedbackToggled,
  }) {
    return analyticsToggled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadSettings value)? loadSettings,
    TResult? Function(_ThemeModeChanged value)? themeModeChanged,
    TResult? Function(_AnalyticsToggled value)? analyticsToggled,
    TResult? Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult? Function(_NotificationsToggled value)? notificationsToggled,
    TResult? Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
  }) {
    return analyticsToggled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadSettings value)? loadSettings,
    TResult Function(_ThemeModeChanged value)? themeModeChanged,
    TResult Function(_AnalyticsToggled value)? analyticsToggled,
    TResult Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult Function(_NotificationsToggled value)? notificationsToggled,
    TResult Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (analyticsToggled != null) {
      return analyticsToggled(this);
    }
    return orElse();
  }
}

abstract class _AnalyticsToggled implements SettingsEvent {
  const factory _AnalyticsToggled(final bool enabled) = _$AnalyticsToggledImpl;

  bool get enabled;

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalyticsToggledImplCopyWith<_$AnalyticsToggledImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AutoBackupToggledImplCopyWith<$Res> {
  factory _$$AutoBackupToggledImplCopyWith(_$AutoBackupToggledImpl value,
          $Res Function(_$AutoBackupToggledImpl) then) =
      __$$AutoBackupToggledImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool enabled});
}

/// @nodoc
class __$$AutoBackupToggledImplCopyWithImpl<$Res>
    extends _$SettingsEventCopyWithImpl<$Res, _$AutoBackupToggledImpl>
    implements _$$AutoBackupToggledImplCopyWith<$Res> {
  __$$AutoBackupToggledImplCopyWithImpl(_$AutoBackupToggledImpl _value,
      $Res Function(_$AutoBackupToggledImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
  }) {
    return _then(_$AutoBackupToggledImpl(
      null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AutoBackupToggledImpl implements _AutoBackupToggled {
  const _$AutoBackupToggledImpl(this.enabled);

  @override
  final bool enabled;

  @override
  String toString() {
    return 'SettingsEvent.autoBackupToggled(enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoBackupToggledImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enabled);

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutoBackupToggledImplCopyWith<_$AutoBackupToggledImpl> get copyWith =>
      __$$AutoBackupToggledImplCopyWithImpl<_$AutoBackupToggledImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSettings,
    required TResult Function(ThemeMode themeMode) themeModeChanged,
    required TResult Function(bool enabled) analyticsToggled,
    required TResult Function(bool enabled) autoBackupToggled,
    required TResult Function(bool enabled) notificationsToggled,
    required TResult Function(bool enabled) hapticFeedbackToggled,
  }) {
    return autoBackupToggled(enabled);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSettings,
    TResult? Function(ThemeMode themeMode)? themeModeChanged,
    TResult? Function(bool enabled)? analyticsToggled,
    TResult? Function(bool enabled)? autoBackupToggled,
    TResult? Function(bool enabled)? notificationsToggled,
    TResult? Function(bool enabled)? hapticFeedbackToggled,
  }) {
    return autoBackupToggled?.call(enabled);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSettings,
    TResult Function(ThemeMode themeMode)? themeModeChanged,
    TResult Function(bool enabled)? analyticsToggled,
    TResult Function(bool enabled)? autoBackupToggled,
    TResult Function(bool enabled)? notificationsToggled,
    TResult Function(bool enabled)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (autoBackupToggled != null) {
      return autoBackupToggled(enabled);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadSettings value) loadSettings,
    required TResult Function(_ThemeModeChanged value) themeModeChanged,
    required TResult Function(_AnalyticsToggled value) analyticsToggled,
    required TResult Function(_AutoBackupToggled value) autoBackupToggled,
    required TResult Function(_NotificationsToggled value) notificationsToggled,
    required TResult Function(_HapticFeedbackToggled value)
        hapticFeedbackToggled,
  }) {
    return autoBackupToggled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadSettings value)? loadSettings,
    TResult? Function(_ThemeModeChanged value)? themeModeChanged,
    TResult? Function(_AnalyticsToggled value)? analyticsToggled,
    TResult? Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult? Function(_NotificationsToggled value)? notificationsToggled,
    TResult? Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
  }) {
    return autoBackupToggled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadSettings value)? loadSettings,
    TResult Function(_ThemeModeChanged value)? themeModeChanged,
    TResult Function(_AnalyticsToggled value)? analyticsToggled,
    TResult Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult Function(_NotificationsToggled value)? notificationsToggled,
    TResult Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (autoBackupToggled != null) {
      return autoBackupToggled(this);
    }
    return orElse();
  }
}

abstract class _AutoBackupToggled implements SettingsEvent {
  const factory _AutoBackupToggled(final bool enabled) =
      _$AutoBackupToggledImpl;

  bool get enabled;

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutoBackupToggledImplCopyWith<_$AutoBackupToggledImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotificationsToggledImplCopyWith<$Res> {
  factory _$$NotificationsToggledImplCopyWith(_$NotificationsToggledImpl value,
          $Res Function(_$NotificationsToggledImpl) then) =
      __$$NotificationsToggledImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool enabled});
}

/// @nodoc
class __$$NotificationsToggledImplCopyWithImpl<$Res>
    extends _$SettingsEventCopyWithImpl<$Res, _$NotificationsToggledImpl>
    implements _$$NotificationsToggledImplCopyWith<$Res> {
  __$$NotificationsToggledImplCopyWithImpl(_$NotificationsToggledImpl _value,
      $Res Function(_$NotificationsToggledImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
  }) {
    return _then(_$NotificationsToggledImpl(
      null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$NotificationsToggledImpl implements _NotificationsToggled {
  const _$NotificationsToggledImpl(this.enabled);

  @override
  final bool enabled;

  @override
  String toString() {
    return 'SettingsEvent.notificationsToggled(enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationsToggledImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enabled);

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationsToggledImplCopyWith<_$NotificationsToggledImpl>
      get copyWith =>
          __$$NotificationsToggledImplCopyWithImpl<_$NotificationsToggledImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSettings,
    required TResult Function(ThemeMode themeMode) themeModeChanged,
    required TResult Function(bool enabled) analyticsToggled,
    required TResult Function(bool enabled) autoBackupToggled,
    required TResult Function(bool enabled) notificationsToggled,
    required TResult Function(bool enabled) hapticFeedbackToggled,
  }) {
    return notificationsToggled(enabled);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSettings,
    TResult? Function(ThemeMode themeMode)? themeModeChanged,
    TResult? Function(bool enabled)? analyticsToggled,
    TResult? Function(bool enabled)? autoBackupToggled,
    TResult? Function(bool enabled)? notificationsToggled,
    TResult? Function(bool enabled)? hapticFeedbackToggled,
  }) {
    return notificationsToggled?.call(enabled);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSettings,
    TResult Function(ThemeMode themeMode)? themeModeChanged,
    TResult Function(bool enabled)? analyticsToggled,
    TResult Function(bool enabled)? autoBackupToggled,
    TResult Function(bool enabled)? notificationsToggled,
    TResult Function(bool enabled)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (notificationsToggled != null) {
      return notificationsToggled(enabled);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadSettings value) loadSettings,
    required TResult Function(_ThemeModeChanged value) themeModeChanged,
    required TResult Function(_AnalyticsToggled value) analyticsToggled,
    required TResult Function(_AutoBackupToggled value) autoBackupToggled,
    required TResult Function(_NotificationsToggled value) notificationsToggled,
    required TResult Function(_HapticFeedbackToggled value)
        hapticFeedbackToggled,
  }) {
    return notificationsToggled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadSettings value)? loadSettings,
    TResult? Function(_ThemeModeChanged value)? themeModeChanged,
    TResult? Function(_AnalyticsToggled value)? analyticsToggled,
    TResult? Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult? Function(_NotificationsToggled value)? notificationsToggled,
    TResult? Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
  }) {
    return notificationsToggled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadSettings value)? loadSettings,
    TResult Function(_ThemeModeChanged value)? themeModeChanged,
    TResult Function(_AnalyticsToggled value)? analyticsToggled,
    TResult Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult Function(_NotificationsToggled value)? notificationsToggled,
    TResult Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (notificationsToggled != null) {
      return notificationsToggled(this);
    }
    return orElse();
  }
}

abstract class _NotificationsToggled implements SettingsEvent {
  const factory _NotificationsToggled(final bool enabled) =
      _$NotificationsToggledImpl;

  bool get enabled;

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationsToggledImplCopyWith<_$NotificationsToggledImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$HapticFeedbackToggledImplCopyWith<$Res> {
  factory _$$HapticFeedbackToggledImplCopyWith(
          _$HapticFeedbackToggledImpl value,
          $Res Function(_$HapticFeedbackToggledImpl) then) =
      __$$HapticFeedbackToggledImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool enabled});
}

/// @nodoc
class __$$HapticFeedbackToggledImplCopyWithImpl<$Res>
    extends _$SettingsEventCopyWithImpl<$Res, _$HapticFeedbackToggledImpl>
    implements _$$HapticFeedbackToggledImplCopyWith<$Res> {
  __$$HapticFeedbackToggledImplCopyWithImpl(_$HapticFeedbackToggledImpl _value,
      $Res Function(_$HapticFeedbackToggledImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
  }) {
    return _then(_$HapticFeedbackToggledImpl(
      null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$HapticFeedbackToggledImpl implements _HapticFeedbackToggled {
  const _$HapticFeedbackToggledImpl(this.enabled);

  @override
  final bool enabled;

  @override
  String toString() {
    return 'SettingsEvent.hapticFeedbackToggled(enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HapticFeedbackToggledImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enabled);

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HapticFeedbackToggledImplCopyWith<_$HapticFeedbackToggledImpl>
      get copyWith => __$$HapticFeedbackToggledImplCopyWithImpl<
          _$HapticFeedbackToggledImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSettings,
    required TResult Function(ThemeMode themeMode) themeModeChanged,
    required TResult Function(bool enabled) analyticsToggled,
    required TResult Function(bool enabled) autoBackupToggled,
    required TResult Function(bool enabled) notificationsToggled,
    required TResult Function(bool enabled) hapticFeedbackToggled,
  }) {
    return hapticFeedbackToggled(enabled);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSettings,
    TResult? Function(ThemeMode themeMode)? themeModeChanged,
    TResult? Function(bool enabled)? analyticsToggled,
    TResult? Function(bool enabled)? autoBackupToggled,
    TResult? Function(bool enabled)? notificationsToggled,
    TResult? Function(bool enabled)? hapticFeedbackToggled,
  }) {
    return hapticFeedbackToggled?.call(enabled);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSettings,
    TResult Function(ThemeMode themeMode)? themeModeChanged,
    TResult Function(bool enabled)? analyticsToggled,
    TResult Function(bool enabled)? autoBackupToggled,
    TResult Function(bool enabled)? notificationsToggled,
    TResult Function(bool enabled)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (hapticFeedbackToggled != null) {
      return hapticFeedbackToggled(enabled);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadSettings value) loadSettings,
    required TResult Function(_ThemeModeChanged value) themeModeChanged,
    required TResult Function(_AnalyticsToggled value) analyticsToggled,
    required TResult Function(_AutoBackupToggled value) autoBackupToggled,
    required TResult Function(_NotificationsToggled value) notificationsToggled,
    required TResult Function(_HapticFeedbackToggled value)
        hapticFeedbackToggled,
  }) {
    return hapticFeedbackToggled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadSettings value)? loadSettings,
    TResult? Function(_ThemeModeChanged value)? themeModeChanged,
    TResult? Function(_AnalyticsToggled value)? analyticsToggled,
    TResult? Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult? Function(_NotificationsToggled value)? notificationsToggled,
    TResult? Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
  }) {
    return hapticFeedbackToggled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadSettings value)? loadSettings,
    TResult Function(_ThemeModeChanged value)? themeModeChanged,
    TResult Function(_AnalyticsToggled value)? analyticsToggled,
    TResult Function(_AutoBackupToggled value)? autoBackupToggled,
    TResult Function(_NotificationsToggled value)? notificationsToggled,
    TResult Function(_HapticFeedbackToggled value)? hapticFeedbackToggled,
    required TResult orElse(),
  }) {
    if (hapticFeedbackToggled != null) {
      return hapticFeedbackToggled(this);
    }
    return orElse();
  }
}

abstract class _HapticFeedbackToggled implements SettingsEvent {
  const factory _HapticFeedbackToggled(final bool enabled) =
      _$HapticFeedbackToggledImpl;

  bool get enabled;

  /// Create a copy of SettingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HapticFeedbackToggledImplCopyWith<_$HapticFeedbackToggledImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SettingsState {
  ThemeMode get themeMode => throw _privateConstructorUsedError;
  bool get analyticsEnabled => throw _privateConstructorUsedError;
  bool get autoBackupEnabled => throw _privateConstructorUsedError;
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  bool get hapticFeedbackEnabled => throw _privateConstructorUsedError;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
          SettingsState value, $Res Function(SettingsState) then) =
      _$SettingsStateCopyWithImpl<$Res, SettingsState>;
  @useResult
  $Res call(
      {ThemeMode themeMode,
      bool analyticsEnabled,
      bool autoBackupEnabled,
      bool notificationsEnabled,
      bool hapticFeedbackEnabled});
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res, $Val extends SettingsState>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? analyticsEnabled = null,
    Object? autoBackupEnabled = null,
    Object? notificationsEnabled = null,
    Object? hapticFeedbackEnabled = null,
  }) {
    return _then(_value.copyWith(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      analyticsEnabled: null == analyticsEnabled
          ? _value.analyticsEnabled
          : analyticsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      autoBackupEnabled: null == autoBackupEnabled
          ? _value.autoBackupEnabled
          : autoBackupEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      hapticFeedbackEnabled: null == hapticFeedbackEnabled
          ? _value.hapticFeedbackEnabled
          : hapticFeedbackEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettingsStateImplCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$$SettingsStateImplCopyWith(
          _$SettingsStateImpl value, $Res Function(_$SettingsStateImpl) then) =
      __$$SettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ThemeMode themeMode,
      bool analyticsEnabled,
      bool autoBackupEnabled,
      bool notificationsEnabled,
      bool hapticFeedbackEnabled});
}

/// @nodoc
class __$$SettingsStateImplCopyWithImpl<$Res>
    extends _$SettingsStateCopyWithImpl<$Res, _$SettingsStateImpl>
    implements _$$SettingsStateImplCopyWith<$Res> {
  __$$SettingsStateImplCopyWithImpl(
      _$SettingsStateImpl _value, $Res Function(_$SettingsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? analyticsEnabled = null,
    Object? autoBackupEnabled = null,
    Object? notificationsEnabled = null,
    Object? hapticFeedbackEnabled = null,
  }) {
    return _then(_$SettingsStateImpl(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      analyticsEnabled: null == analyticsEnabled
          ? _value.analyticsEnabled
          : analyticsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      autoBackupEnabled: null == autoBackupEnabled
          ? _value.autoBackupEnabled
          : autoBackupEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      hapticFeedbackEnabled: null == hapticFeedbackEnabled
          ? _value.hapticFeedbackEnabled
          : hapticFeedbackEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SettingsStateImpl implements _SettingsState {
  const _$SettingsStateImpl(
      {required this.themeMode,
      required this.analyticsEnabled,
      required this.autoBackupEnabled,
      required this.notificationsEnabled,
      required this.hapticFeedbackEnabled});

  @override
  final ThemeMode themeMode;
  @override
  final bool analyticsEnabled;
  @override
  final bool autoBackupEnabled;
  @override
  final bool notificationsEnabled;
  @override
  final bool hapticFeedbackEnabled;

  @override
  String toString() {
    return 'SettingsState(themeMode: $themeMode, analyticsEnabled: $analyticsEnabled, autoBackupEnabled: $autoBackupEnabled, notificationsEnabled: $notificationsEnabled, hapticFeedbackEnabled: $hapticFeedbackEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsStateImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.analyticsEnabled, analyticsEnabled) ||
                other.analyticsEnabled == analyticsEnabled) &&
            (identical(other.autoBackupEnabled, autoBackupEnabled) ||
                other.autoBackupEnabled == autoBackupEnabled) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.hapticFeedbackEnabled, hapticFeedbackEnabled) ||
                other.hapticFeedbackEnabled == hapticFeedbackEnabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, themeMode, analyticsEnabled,
      autoBackupEnabled, notificationsEnabled, hapticFeedbackEnabled);

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      __$$SettingsStateImplCopyWithImpl<_$SettingsStateImpl>(this, _$identity);
}

abstract class _SettingsState implements SettingsState {
  const factory _SettingsState(
      {required final ThemeMode themeMode,
      required final bool analyticsEnabled,
      required final bool autoBackupEnabled,
      required final bool notificationsEnabled,
      required final bool hapticFeedbackEnabled}) = _$SettingsStateImpl;

  @override
  ThemeMode get themeMode;
  @override
  bool get analyticsEnabled;
  @override
  bool get autoBackupEnabled;
  @override
  bool get notificationsEnabled;
  @override
  bool get hapticFeedbackEnabled;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
