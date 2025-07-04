// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'currency_display_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CurrencyDisplayEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String accountCurrency, String accountId)
        accountCurrencyChanged,
    required TResult Function(String displayCurrency) displayCurrencyChanged,
    required TResult Function() refreshExchangeRates,
    required TResult Function(String? initialCurrency) initialize,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String accountCurrency, String accountId)?
        accountCurrencyChanged,
    TResult? Function(String displayCurrency)? displayCurrencyChanged,
    TResult? Function()? refreshExchangeRates,
    TResult? Function(String? initialCurrency)? initialize,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String accountCurrency, String accountId)?
        accountCurrencyChanged,
    TResult Function(String displayCurrency)? displayCurrencyChanged,
    TResult Function()? refreshExchangeRates,
    TResult Function(String? initialCurrency)? initialize,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AccountCurrencyChanged value)
        accountCurrencyChanged,
    required TResult Function(_DisplayCurrencyChanged value)
        displayCurrencyChanged,
    required TResult Function(_RefreshExchangeRates value) refreshExchangeRates,
    required TResult Function(_Initialize value) initialize,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AccountCurrencyChanged value)? accountCurrencyChanged,
    TResult? Function(_DisplayCurrencyChanged value)? displayCurrencyChanged,
    TResult? Function(_RefreshExchangeRates value)? refreshExchangeRates,
    TResult? Function(_Initialize value)? initialize,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AccountCurrencyChanged value)? accountCurrencyChanged,
    TResult Function(_DisplayCurrencyChanged value)? displayCurrencyChanged,
    TResult Function(_RefreshExchangeRates value)? refreshExchangeRates,
    TResult Function(_Initialize value)? initialize,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrencyDisplayEventCopyWith<$Res> {
  factory $CurrencyDisplayEventCopyWith(CurrencyDisplayEvent value,
          $Res Function(CurrencyDisplayEvent) then) =
      _$CurrencyDisplayEventCopyWithImpl<$Res, CurrencyDisplayEvent>;
}

/// @nodoc
class _$CurrencyDisplayEventCopyWithImpl<$Res,
        $Val extends CurrencyDisplayEvent>
    implements $CurrencyDisplayEventCopyWith<$Res> {
  _$CurrencyDisplayEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurrencyDisplayEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AccountCurrencyChangedImplCopyWith<$Res> {
  factory _$$AccountCurrencyChangedImplCopyWith(
          _$AccountCurrencyChangedImpl value,
          $Res Function(_$AccountCurrencyChangedImpl) then) =
      __$$AccountCurrencyChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String accountCurrency, String accountId});
}

/// @nodoc
class __$$AccountCurrencyChangedImplCopyWithImpl<$Res>
    extends _$CurrencyDisplayEventCopyWithImpl<$Res,
        _$AccountCurrencyChangedImpl>
    implements _$$AccountCurrencyChangedImplCopyWith<$Res> {
  __$$AccountCurrencyChangedImplCopyWithImpl(
      _$AccountCurrencyChangedImpl _value,
      $Res Function(_$AccountCurrencyChangedImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurrencyDisplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountCurrency = null,
    Object? accountId = null,
  }) {
    return _then(_$AccountCurrencyChangedImpl(
      accountCurrency: null == accountCurrency
          ? _value.accountCurrency
          : accountCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AccountCurrencyChangedImpl implements _AccountCurrencyChanged {
  const _$AccountCurrencyChangedImpl(
      {required this.accountCurrency, required this.accountId});

  @override
  final String accountCurrency;
  @override
  final String accountId;

  @override
  String toString() {
    return 'CurrencyDisplayEvent.accountCurrencyChanged(accountCurrency: $accountCurrency, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountCurrencyChangedImpl &&
            (identical(other.accountCurrency, accountCurrency) ||
                other.accountCurrency == accountCurrency) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, accountCurrency, accountId);

  /// Create a copy of CurrencyDisplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountCurrencyChangedImplCopyWith<_$AccountCurrencyChangedImpl>
      get copyWith => __$$AccountCurrencyChangedImplCopyWithImpl<
          _$AccountCurrencyChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String accountCurrency, String accountId)
        accountCurrencyChanged,
    required TResult Function(String displayCurrency) displayCurrencyChanged,
    required TResult Function() refreshExchangeRates,
    required TResult Function(String? initialCurrency) initialize,
  }) {
    return accountCurrencyChanged(accountCurrency, accountId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String accountCurrency, String accountId)?
        accountCurrencyChanged,
    TResult? Function(String displayCurrency)? displayCurrencyChanged,
    TResult? Function()? refreshExchangeRates,
    TResult? Function(String? initialCurrency)? initialize,
  }) {
    return accountCurrencyChanged?.call(accountCurrency, accountId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String accountCurrency, String accountId)?
        accountCurrencyChanged,
    TResult Function(String displayCurrency)? displayCurrencyChanged,
    TResult Function()? refreshExchangeRates,
    TResult Function(String? initialCurrency)? initialize,
    required TResult orElse(),
  }) {
    if (accountCurrencyChanged != null) {
      return accountCurrencyChanged(accountCurrency, accountId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AccountCurrencyChanged value)
        accountCurrencyChanged,
    required TResult Function(_DisplayCurrencyChanged value)
        displayCurrencyChanged,
    required TResult Function(_RefreshExchangeRates value) refreshExchangeRates,
    required TResult Function(_Initialize value) initialize,
  }) {
    return accountCurrencyChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AccountCurrencyChanged value)? accountCurrencyChanged,
    TResult? Function(_DisplayCurrencyChanged value)? displayCurrencyChanged,
    TResult? Function(_RefreshExchangeRates value)? refreshExchangeRates,
    TResult? Function(_Initialize value)? initialize,
  }) {
    return accountCurrencyChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AccountCurrencyChanged value)? accountCurrencyChanged,
    TResult Function(_DisplayCurrencyChanged value)? displayCurrencyChanged,
    TResult Function(_RefreshExchangeRates value)? refreshExchangeRates,
    TResult Function(_Initialize value)? initialize,
    required TResult orElse(),
  }) {
    if (accountCurrencyChanged != null) {
      return accountCurrencyChanged(this);
    }
    return orElse();
  }
}

abstract class _AccountCurrencyChanged implements CurrencyDisplayEvent {
  const factory _AccountCurrencyChanged(
      {required final String accountCurrency,
      required final String accountId}) = _$AccountCurrencyChangedImpl;

  String get accountCurrency;
  String get accountId;

  /// Create a copy of CurrencyDisplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountCurrencyChangedImplCopyWith<_$AccountCurrencyChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DisplayCurrencyChangedImplCopyWith<$Res> {
  factory _$$DisplayCurrencyChangedImplCopyWith(
          _$DisplayCurrencyChangedImpl value,
          $Res Function(_$DisplayCurrencyChangedImpl) then) =
      __$$DisplayCurrencyChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String displayCurrency});
}

/// @nodoc
class __$$DisplayCurrencyChangedImplCopyWithImpl<$Res>
    extends _$CurrencyDisplayEventCopyWithImpl<$Res,
        _$DisplayCurrencyChangedImpl>
    implements _$$DisplayCurrencyChangedImplCopyWith<$Res> {
  __$$DisplayCurrencyChangedImplCopyWithImpl(
      _$DisplayCurrencyChangedImpl _value,
      $Res Function(_$DisplayCurrencyChangedImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurrencyDisplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayCurrency = null,
  }) {
    return _then(_$DisplayCurrencyChangedImpl(
      displayCurrency: null == displayCurrency
          ? _value.displayCurrency
          : displayCurrency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DisplayCurrencyChangedImpl implements _DisplayCurrencyChanged {
  const _$DisplayCurrencyChangedImpl({required this.displayCurrency});

  @override
  final String displayCurrency;

  @override
  String toString() {
    return 'CurrencyDisplayEvent.displayCurrencyChanged(displayCurrency: $displayCurrency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisplayCurrencyChangedImpl &&
            (identical(other.displayCurrency, displayCurrency) ||
                other.displayCurrency == displayCurrency));
  }

  @override
  int get hashCode => Object.hash(runtimeType, displayCurrency);

  /// Create a copy of CurrencyDisplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisplayCurrencyChangedImplCopyWith<_$DisplayCurrencyChangedImpl>
      get copyWith => __$$DisplayCurrencyChangedImplCopyWithImpl<
          _$DisplayCurrencyChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String accountCurrency, String accountId)
        accountCurrencyChanged,
    required TResult Function(String displayCurrency) displayCurrencyChanged,
    required TResult Function() refreshExchangeRates,
    required TResult Function(String? initialCurrency) initialize,
  }) {
    return displayCurrencyChanged(displayCurrency);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String accountCurrency, String accountId)?
        accountCurrencyChanged,
    TResult? Function(String displayCurrency)? displayCurrencyChanged,
    TResult? Function()? refreshExchangeRates,
    TResult? Function(String? initialCurrency)? initialize,
  }) {
    return displayCurrencyChanged?.call(displayCurrency);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String accountCurrency, String accountId)?
        accountCurrencyChanged,
    TResult Function(String displayCurrency)? displayCurrencyChanged,
    TResult Function()? refreshExchangeRates,
    TResult Function(String? initialCurrency)? initialize,
    required TResult orElse(),
  }) {
    if (displayCurrencyChanged != null) {
      return displayCurrencyChanged(displayCurrency);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AccountCurrencyChanged value)
        accountCurrencyChanged,
    required TResult Function(_DisplayCurrencyChanged value)
        displayCurrencyChanged,
    required TResult Function(_RefreshExchangeRates value) refreshExchangeRates,
    required TResult Function(_Initialize value) initialize,
  }) {
    return displayCurrencyChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AccountCurrencyChanged value)? accountCurrencyChanged,
    TResult? Function(_DisplayCurrencyChanged value)? displayCurrencyChanged,
    TResult? Function(_RefreshExchangeRates value)? refreshExchangeRates,
    TResult? Function(_Initialize value)? initialize,
  }) {
    return displayCurrencyChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AccountCurrencyChanged value)? accountCurrencyChanged,
    TResult Function(_DisplayCurrencyChanged value)? displayCurrencyChanged,
    TResult Function(_RefreshExchangeRates value)? refreshExchangeRates,
    TResult Function(_Initialize value)? initialize,
    required TResult orElse(),
  }) {
    if (displayCurrencyChanged != null) {
      return displayCurrencyChanged(this);
    }
    return orElse();
  }
}

abstract class _DisplayCurrencyChanged implements CurrencyDisplayEvent {
  const factory _DisplayCurrencyChanged(
      {required final String displayCurrency}) = _$DisplayCurrencyChangedImpl;

  String get displayCurrency;

  /// Create a copy of CurrencyDisplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisplayCurrencyChangedImplCopyWith<_$DisplayCurrencyChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RefreshExchangeRatesImplCopyWith<$Res> {
  factory _$$RefreshExchangeRatesImplCopyWith(_$RefreshExchangeRatesImpl value,
          $Res Function(_$RefreshExchangeRatesImpl) then) =
      __$$RefreshExchangeRatesImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RefreshExchangeRatesImplCopyWithImpl<$Res>
    extends _$CurrencyDisplayEventCopyWithImpl<$Res, _$RefreshExchangeRatesImpl>
    implements _$$RefreshExchangeRatesImplCopyWith<$Res> {
  __$$RefreshExchangeRatesImplCopyWithImpl(_$RefreshExchangeRatesImpl _value,
      $Res Function(_$RefreshExchangeRatesImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurrencyDisplayEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RefreshExchangeRatesImpl implements _RefreshExchangeRates {
  const _$RefreshExchangeRatesImpl();

  @override
  String toString() {
    return 'CurrencyDisplayEvent.refreshExchangeRates()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefreshExchangeRatesImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String accountCurrency, String accountId)
        accountCurrencyChanged,
    required TResult Function(String displayCurrency) displayCurrencyChanged,
    required TResult Function() refreshExchangeRates,
    required TResult Function(String? initialCurrency) initialize,
  }) {
    return refreshExchangeRates();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String accountCurrency, String accountId)?
        accountCurrencyChanged,
    TResult? Function(String displayCurrency)? displayCurrencyChanged,
    TResult? Function()? refreshExchangeRates,
    TResult? Function(String? initialCurrency)? initialize,
  }) {
    return refreshExchangeRates?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String accountCurrency, String accountId)?
        accountCurrencyChanged,
    TResult Function(String displayCurrency)? displayCurrencyChanged,
    TResult Function()? refreshExchangeRates,
    TResult Function(String? initialCurrency)? initialize,
    required TResult orElse(),
  }) {
    if (refreshExchangeRates != null) {
      return refreshExchangeRates();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AccountCurrencyChanged value)
        accountCurrencyChanged,
    required TResult Function(_DisplayCurrencyChanged value)
        displayCurrencyChanged,
    required TResult Function(_RefreshExchangeRates value) refreshExchangeRates,
    required TResult Function(_Initialize value) initialize,
  }) {
    return refreshExchangeRates(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AccountCurrencyChanged value)? accountCurrencyChanged,
    TResult? Function(_DisplayCurrencyChanged value)? displayCurrencyChanged,
    TResult? Function(_RefreshExchangeRates value)? refreshExchangeRates,
    TResult? Function(_Initialize value)? initialize,
  }) {
    return refreshExchangeRates?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AccountCurrencyChanged value)? accountCurrencyChanged,
    TResult Function(_DisplayCurrencyChanged value)? displayCurrencyChanged,
    TResult Function(_RefreshExchangeRates value)? refreshExchangeRates,
    TResult Function(_Initialize value)? initialize,
    required TResult orElse(),
  }) {
    if (refreshExchangeRates != null) {
      return refreshExchangeRates(this);
    }
    return orElse();
  }
}

abstract class _RefreshExchangeRates implements CurrencyDisplayEvent {
  const factory _RefreshExchangeRates() = _$RefreshExchangeRatesImpl;
}

/// @nodoc
abstract class _$$InitializeImplCopyWith<$Res> {
  factory _$$InitializeImplCopyWith(
          _$InitializeImpl value, $Res Function(_$InitializeImpl) then) =
      __$$InitializeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? initialCurrency});
}

/// @nodoc
class __$$InitializeImplCopyWithImpl<$Res>
    extends _$CurrencyDisplayEventCopyWithImpl<$Res, _$InitializeImpl>
    implements _$$InitializeImplCopyWith<$Res> {
  __$$InitializeImplCopyWithImpl(
      _$InitializeImpl _value, $Res Function(_$InitializeImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurrencyDisplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? initialCurrency = freezed,
  }) {
    return _then(_$InitializeImpl(
      initialCurrency: freezed == initialCurrency
          ? _value.initialCurrency
          : initialCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$InitializeImpl implements _Initialize {
  const _$InitializeImpl({this.initialCurrency});

  @override
  final String? initialCurrency;

  @override
  String toString() {
    return 'CurrencyDisplayEvent.initialize(initialCurrency: $initialCurrency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitializeImpl &&
            (identical(other.initialCurrency, initialCurrency) ||
                other.initialCurrency == initialCurrency));
  }

  @override
  int get hashCode => Object.hash(runtimeType, initialCurrency);

  /// Create a copy of CurrencyDisplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InitializeImplCopyWith<_$InitializeImpl> get copyWith =>
      __$$InitializeImplCopyWithImpl<_$InitializeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String accountCurrency, String accountId)
        accountCurrencyChanged,
    required TResult Function(String displayCurrency) displayCurrencyChanged,
    required TResult Function() refreshExchangeRates,
    required TResult Function(String? initialCurrency) initialize,
  }) {
    return initialize(initialCurrency);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String accountCurrency, String accountId)?
        accountCurrencyChanged,
    TResult? Function(String displayCurrency)? displayCurrencyChanged,
    TResult? Function()? refreshExchangeRates,
    TResult? Function(String? initialCurrency)? initialize,
  }) {
    return initialize?.call(initialCurrency);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String accountCurrency, String accountId)?
        accountCurrencyChanged,
    TResult Function(String displayCurrency)? displayCurrencyChanged,
    TResult Function()? refreshExchangeRates,
    TResult Function(String? initialCurrency)? initialize,
    required TResult orElse(),
  }) {
    if (initialize != null) {
      return initialize(initialCurrency);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AccountCurrencyChanged value)
        accountCurrencyChanged,
    required TResult Function(_DisplayCurrencyChanged value)
        displayCurrencyChanged,
    required TResult Function(_RefreshExchangeRates value) refreshExchangeRates,
    required TResult Function(_Initialize value) initialize,
  }) {
    return initialize(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AccountCurrencyChanged value)? accountCurrencyChanged,
    TResult? Function(_DisplayCurrencyChanged value)? displayCurrencyChanged,
    TResult? Function(_RefreshExchangeRates value)? refreshExchangeRates,
    TResult? Function(_Initialize value)? initialize,
  }) {
    return initialize?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AccountCurrencyChanged value)? accountCurrencyChanged,
    TResult Function(_DisplayCurrencyChanged value)? displayCurrencyChanged,
    TResult Function(_RefreshExchangeRates value)? refreshExchangeRates,
    TResult Function(_Initialize value)? initialize,
    required TResult orElse(),
  }) {
    if (initialize != null) {
      return initialize(this);
    }
    return orElse();
  }
}

abstract class _Initialize implements CurrencyDisplayEvent {
  const factory _Initialize({final String? initialCurrency}) = _$InitializeImpl;

  String? get initialCurrency;

  /// Create a copy of CurrencyDisplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InitializeImplCopyWith<_$InitializeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CurrencyDisplayState {
  String get displayCurrency => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  Map<String, double> get conversionRatesCache =>
      throw _privateConstructorUsedError;
  DateTime? get lastRateUpdate => throw _privateConstructorUsedError;
  String? get selectedAccountId => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of CurrencyDisplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurrencyDisplayStateCopyWith<CurrencyDisplayState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrencyDisplayStateCopyWith<$Res> {
  factory $CurrencyDisplayStateCopyWith(CurrencyDisplayState value,
          $Res Function(CurrencyDisplayState) then) =
      _$CurrencyDisplayStateCopyWithImpl<$Res, CurrencyDisplayState>;
  @useResult
  $Res call(
      {String displayCurrency,
      bool isLoading,
      Map<String, double> conversionRatesCache,
      DateTime? lastRateUpdate,
      String? selectedAccountId,
      String? errorMessage});
}

/// @nodoc
class _$CurrencyDisplayStateCopyWithImpl<$Res,
        $Val extends CurrencyDisplayState>
    implements $CurrencyDisplayStateCopyWith<$Res> {
  _$CurrencyDisplayStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurrencyDisplayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayCurrency = null,
    Object? isLoading = null,
    Object? conversionRatesCache = null,
    Object? lastRateUpdate = freezed,
    Object? selectedAccountId = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      displayCurrency: null == displayCurrency
          ? _value.displayCurrency
          : displayCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      conversionRatesCache: null == conversionRatesCache
          ? _value.conversionRatesCache
          : conversionRatesCache // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      lastRateUpdate: freezed == lastRateUpdate
          ? _value.lastRateUpdate
          : lastRateUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      selectedAccountId: freezed == selectedAccountId
          ? _value.selectedAccountId
          : selectedAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CurrencyDisplayStateImplCopyWith<$Res>
    implements $CurrencyDisplayStateCopyWith<$Res> {
  factory _$$CurrencyDisplayStateImplCopyWith(_$CurrencyDisplayStateImpl value,
          $Res Function(_$CurrencyDisplayStateImpl) then) =
      __$$CurrencyDisplayStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String displayCurrency,
      bool isLoading,
      Map<String, double> conversionRatesCache,
      DateTime? lastRateUpdate,
      String? selectedAccountId,
      String? errorMessage});
}

/// @nodoc
class __$$CurrencyDisplayStateImplCopyWithImpl<$Res>
    extends _$CurrencyDisplayStateCopyWithImpl<$Res, _$CurrencyDisplayStateImpl>
    implements _$$CurrencyDisplayStateImplCopyWith<$Res> {
  __$$CurrencyDisplayStateImplCopyWithImpl(_$CurrencyDisplayStateImpl _value,
      $Res Function(_$CurrencyDisplayStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurrencyDisplayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayCurrency = null,
    Object? isLoading = null,
    Object? conversionRatesCache = null,
    Object? lastRateUpdate = freezed,
    Object? selectedAccountId = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$CurrencyDisplayStateImpl(
      displayCurrency: null == displayCurrency
          ? _value.displayCurrency
          : displayCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      conversionRatesCache: null == conversionRatesCache
          ? _value._conversionRatesCache
          : conversionRatesCache // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      lastRateUpdate: freezed == lastRateUpdate
          ? _value.lastRateUpdate
          : lastRateUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      selectedAccountId: freezed == selectedAccountId
          ? _value.selectedAccountId
          : selectedAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CurrencyDisplayStateImpl implements _CurrencyDisplayState {
  const _$CurrencyDisplayStateImpl(
      {required this.displayCurrency,
      required this.isLoading,
      required final Map<String, double> conversionRatesCache,
      required this.lastRateUpdate,
      this.selectedAccountId,
      this.errorMessage})
      : _conversionRatesCache = conversionRatesCache;

  @override
  final String displayCurrency;
  @override
  final bool isLoading;
  final Map<String, double> _conversionRatesCache;
  @override
  Map<String, double> get conversionRatesCache {
    if (_conversionRatesCache is EqualUnmodifiableMapView)
      return _conversionRatesCache;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_conversionRatesCache);
  }

  @override
  final DateTime? lastRateUpdate;
  @override
  final String? selectedAccountId;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'CurrencyDisplayState(displayCurrency: $displayCurrency, isLoading: $isLoading, conversionRatesCache: $conversionRatesCache, lastRateUpdate: $lastRateUpdate, selectedAccountId: $selectedAccountId, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrencyDisplayStateImpl &&
            (identical(other.displayCurrency, displayCurrency) ||
                other.displayCurrency == displayCurrency) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality()
                .equals(other._conversionRatesCache, _conversionRatesCache) &&
            (identical(other.lastRateUpdate, lastRateUpdate) ||
                other.lastRateUpdate == lastRateUpdate) &&
            (identical(other.selectedAccountId, selectedAccountId) ||
                other.selectedAccountId == selectedAccountId) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      displayCurrency,
      isLoading,
      const DeepCollectionEquality().hash(_conversionRatesCache),
      lastRateUpdate,
      selectedAccountId,
      errorMessage);

  /// Create a copy of CurrencyDisplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrencyDisplayStateImplCopyWith<_$CurrencyDisplayStateImpl>
      get copyWith =>
          __$$CurrencyDisplayStateImplCopyWithImpl<_$CurrencyDisplayStateImpl>(
              this, _$identity);
}

abstract class _CurrencyDisplayState implements CurrencyDisplayState {
  const factory _CurrencyDisplayState(
      {required final String displayCurrency,
      required final bool isLoading,
      required final Map<String, double> conversionRatesCache,
      required final DateTime? lastRateUpdate,
      final String? selectedAccountId,
      final String? errorMessage}) = _$CurrencyDisplayStateImpl;

  @override
  String get displayCurrency;
  @override
  bool get isLoading;
  @override
  Map<String, double> get conversionRatesCache;
  @override
  DateTime? get lastRateUpdate;
  @override
  String? get selectedAccountId;
  @override
  String? get errorMessage;

  /// Create a copy of CurrencyDisplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurrencyDisplayStateImplCopyWith<_$CurrencyDisplayStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
