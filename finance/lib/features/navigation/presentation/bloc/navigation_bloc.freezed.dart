// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'navigation_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NavigationEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int index) navigationIndexChanged,
    required TResult Function(bool isCustomizing) customizeNavigation,
    required TResult Function(int index, NavigationItem newItem)
        navigationItemReplaced,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int index)? navigationIndexChanged,
    TResult? Function(bool isCustomizing)? customizeNavigation,
    TResult? Function(int index, NavigationItem newItem)?
        navigationItemReplaced,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int index)? navigationIndexChanged,
    TResult Function(bool isCustomizing)? customizeNavigation,
    TResult Function(int index, NavigationItem newItem)? navigationItemReplaced,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NavigationIndexChanged value)
        navigationIndexChanged,
    required TResult Function(_CustomizeNavigation value) customizeNavigation,
    required TResult Function(_NavigationItemReplaced value)
        navigationItemReplaced,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NavigationIndexChanged value)? navigationIndexChanged,
    TResult? Function(_CustomizeNavigation value)? customizeNavigation,
    TResult? Function(_NavigationItemReplaced value)? navigationItemReplaced,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NavigationIndexChanged value)? navigationIndexChanged,
    TResult Function(_CustomizeNavigation value)? customizeNavigation,
    TResult Function(_NavigationItemReplaced value)? navigationItemReplaced,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NavigationEventCopyWith<$Res> {
  factory $NavigationEventCopyWith(
          NavigationEvent value, $Res Function(NavigationEvent) then) =
      _$NavigationEventCopyWithImpl<$Res, NavigationEvent>;
}

/// @nodoc
class _$NavigationEventCopyWithImpl<$Res, $Val extends NavigationEvent>
    implements $NavigationEventCopyWith<$Res> {
  _$NavigationEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NavigationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$NavigationIndexChangedImplCopyWith<$Res> {
  factory _$$NavigationIndexChangedImplCopyWith(
          _$NavigationIndexChangedImpl value,
          $Res Function(_$NavigationIndexChangedImpl) then) =
      __$$NavigationIndexChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int index});
}

/// @nodoc
class __$$NavigationIndexChangedImplCopyWithImpl<$Res>
    extends _$NavigationEventCopyWithImpl<$Res, _$NavigationIndexChangedImpl>
    implements _$$NavigationIndexChangedImplCopyWith<$Res> {
  __$$NavigationIndexChangedImplCopyWithImpl(
      _$NavigationIndexChangedImpl _value,
      $Res Function(_$NavigationIndexChangedImpl) _then)
      : super(_value, _then);

  /// Create a copy of NavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
  }) {
    return _then(_$NavigationIndexChangedImpl(
      null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$NavigationIndexChangedImpl implements _NavigationIndexChanged {
  const _$NavigationIndexChangedImpl(this.index);

  @override
  final int index;

  @override
  String toString() {
    return 'NavigationEvent.navigationIndexChanged(index: $index)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigationIndexChangedImpl &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(runtimeType, index);

  /// Create a copy of NavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigationIndexChangedImplCopyWith<_$NavigationIndexChangedImpl>
      get copyWith => __$$NavigationIndexChangedImplCopyWithImpl<
          _$NavigationIndexChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int index) navigationIndexChanged,
    required TResult Function(bool isCustomizing) customizeNavigation,
    required TResult Function(int index, NavigationItem newItem)
        navigationItemReplaced,
  }) {
    return navigationIndexChanged(index);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int index)? navigationIndexChanged,
    TResult? Function(bool isCustomizing)? customizeNavigation,
    TResult? Function(int index, NavigationItem newItem)?
        navigationItemReplaced,
  }) {
    return navigationIndexChanged?.call(index);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int index)? navigationIndexChanged,
    TResult Function(bool isCustomizing)? customizeNavigation,
    TResult Function(int index, NavigationItem newItem)? navigationItemReplaced,
    required TResult orElse(),
  }) {
    if (navigationIndexChanged != null) {
      return navigationIndexChanged(index);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NavigationIndexChanged value)
        navigationIndexChanged,
    required TResult Function(_CustomizeNavigation value) customizeNavigation,
    required TResult Function(_NavigationItemReplaced value)
        navigationItemReplaced,
  }) {
    return navigationIndexChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NavigationIndexChanged value)? navigationIndexChanged,
    TResult? Function(_CustomizeNavigation value)? customizeNavigation,
    TResult? Function(_NavigationItemReplaced value)? navigationItemReplaced,
  }) {
    return navigationIndexChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NavigationIndexChanged value)? navigationIndexChanged,
    TResult Function(_CustomizeNavigation value)? customizeNavigation,
    TResult Function(_NavigationItemReplaced value)? navigationItemReplaced,
    required TResult orElse(),
  }) {
    if (navigationIndexChanged != null) {
      return navigationIndexChanged(this);
    }
    return orElse();
  }
}

abstract class _NavigationIndexChanged implements NavigationEvent {
  const factory _NavigationIndexChanged(final int index) =
      _$NavigationIndexChangedImpl;

  int get index;

  /// Create a copy of NavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NavigationIndexChangedImplCopyWith<_$NavigationIndexChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomizeNavigationImplCopyWith<$Res> {
  factory _$$CustomizeNavigationImplCopyWith(_$CustomizeNavigationImpl value,
          $Res Function(_$CustomizeNavigationImpl) then) =
      __$$CustomizeNavigationImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool isCustomizing});
}

/// @nodoc
class __$$CustomizeNavigationImplCopyWithImpl<$Res>
    extends _$NavigationEventCopyWithImpl<$Res, _$CustomizeNavigationImpl>
    implements _$$CustomizeNavigationImplCopyWith<$Res> {
  __$$CustomizeNavigationImplCopyWithImpl(_$CustomizeNavigationImpl _value,
      $Res Function(_$CustomizeNavigationImpl) _then)
      : super(_value, _then);

  /// Create a copy of NavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCustomizing = null,
  }) {
    return _then(_$CustomizeNavigationImpl(
      null == isCustomizing
          ? _value.isCustomizing
          : isCustomizing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$CustomizeNavigationImpl implements _CustomizeNavigation {
  const _$CustomizeNavigationImpl(this.isCustomizing);

  @override
  final bool isCustomizing;

  @override
  String toString() {
    return 'NavigationEvent.customizeNavigation(isCustomizing: $isCustomizing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomizeNavigationImpl &&
            (identical(other.isCustomizing, isCustomizing) ||
                other.isCustomizing == isCustomizing));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isCustomizing);

  /// Create a copy of NavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomizeNavigationImplCopyWith<_$CustomizeNavigationImpl> get copyWith =>
      __$$CustomizeNavigationImplCopyWithImpl<_$CustomizeNavigationImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int index) navigationIndexChanged,
    required TResult Function(bool isCustomizing) customizeNavigation,
    required TResult Function(int index, NavigationItem newItem)
        navigationItemReplaced,
  }) {
    return customizeNavigation(isCustomizing);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int index)? navigationIndexChanged,
    TResult? Function(bool isCustomizing)? customizeNavigation,
    TResult? Function(int index, NavigationItem newItem)?
        navigationItemReplaced,
  }) {
    return customizeNavigation?.call(isCustomizing);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int index)? navigationIndexChanged,
    TResult Function(bool isCustomizing)? customizeNavigation,
    TResult Function(int index, NavigationItem newItem)? navigationItemReplaced,
    required TResult orElse(),
  }) {
    if (customizeNavigation != null) {
      return customizeNavigation(isCustomizing);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NavigationIndexChanged value)
        navigationIndexChanged,
    required TResult Function(_CustomizeNavigation value) customizeNavigation,
    required TResult Function(_NavigationItemReplaced value)
        navigationItemReplaced,
  }) {
    return customizeNavigation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NavigationIndexChanged value)? navigationIndexChanged,
    TResult? Function(_CustomizeNavigation value)? customizeNavigation,
    TResult? Function(_NavigationItemReplaced value)? navigationItemReplaced,
  }) {
    return customizeNavigation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NavigationIndexChanged value)? navigationIndexChanged,
    TResult Function(_CustomizeNavigation value)? customizeNavigation,
    TResult Function(_NavigationItemReplaced value)? navigationItemReplaced,
    required TResult orElse(),
  }) {
    if (customizeNavigation != null) {
      return customizeNavigation(this);
    }
    return orElse();
  }
}

abstract class _CustomizeNavigation implements NavigationEvent {
  const factory _CustomizeNavigation(final bool isCustomizing) =
      _$CustomizeNavigationImpl;

  bool get isCustomizing;

  /// Create a copy of NavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomizeNavigationImplCopyWith<_$CustomizeNavigationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NavigationItemReplacedImplCopyWith<$Res> {
  factory _$$NavigationItemReplacedImplCopyWith(
          _$NavigationItemReplacedImpl value,
          $Res Function(_$NavigationItemReplacedImpl) then) =
      __$$NavigationItemReplacedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int index, NavigationItem newItem});
}

/// @nodoc
class __$$NavigationItemReplacedImplCopyWithImpl<$Res>
    extends _$NavigationEventCopyWithImpl<$Res, _$NavigationItemReplacedImpl>
    implements _$$NavigationItemReplacedImplCopyWith<$Res> {
  __$$NavigationItemReplacedImplCopyWithImpl(
      _$NavigationItemReplacedImpl _value,
      $Res Function(_$NavigationItemReplacedImpl) _then)
      : super(_value, _then);

  /// Create a copy of NavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? newItem = null,
  }) {
    return _then(_$NavigationItemReplacedImpl(
      null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      null == newItem
          ? _value.newItem
          : newItem // ignore: cast_nullable_to_non_nullable
              as NavigationItem,
    ));
  }
}

/// @nodoc

class _$NavigationItemReplacedImpl implements _NavigationItemReplaced {
  const _$NavigationItemReplacedImpl(this.index, this.newItem);

  @override
  final int index;
  @override
  final NavigationItem newItem;

  @override
  String toString() {
    return 'NavigationEvent.navigationItemReplaced(index: $index, newItem: $newItem)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigationItemReplacedImpl &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.newItem, newItem) || other.newItem == newItem));
  }

  @override
  int get hashCode => Object.hash(runtimeType, index, newItem);

  /// Create a copy of NavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigationItemReplacedImplCopyWith<_$NavigationItemReplacedImpl>
      get copyWith => __$$NavigationItemReplacedImplCopyWithImpl<
          _$NavigationItemReplacedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int index) navigationIndexChanged,
    required TResult Function(bool isCustomizing) customizeNavigation,
    required TResult Function(int index, NavigationItem newItem)
        navigationItemReplaced,
  }) {
    return navigationItemReplaced(index, newItem);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int index)? navigationIndexChanged,
    TResult? Function(bool isCustomizing)? customizeNavigation,
    TResult? Function(int index, NavigationItem newItem)?
        navigationItemReplaced,
  }) {
    return navigationItemReplaced?.call(index, newItem);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int index)? navigationIndexChanged,
    TResult Function(bool isCustomizing)? customizeNavigation,
    TResult Function(int index, NavigationItem newItem)? navigationItemReplaced,
    required TResult orElse(),
  }) {
    if (navigationItemReplaced != null) {
      return navigationItemReplaced(index, newItem);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NavigationIndexChanged value)
        navigationIndexChanged,
    required TResult Function(_CustomizeNavigation value) customizeNavigation,
    required TResult Function(_NavigationItemReplaced value)
        navigationItemReplaced,
  }) {
    return navigationItemReplaced(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NavigationIndexChanged value)? navigationIndexChanged,
    TResult? Function(_CustomizeNavigation value)? customizeNavigation,
    TResult? Function(_NavigationItemReplaced value)? navigationItemReplaced,
  }) {
    return navigationItemReplaced?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NavigationIndexChanged value)? navigationIndexChanged,
    TResult Function(_CustomizeNavigation value)? customizeNavigation,
    TResult Function(_NavigationItemReplaced value)? navigationItemReplaced,
    required TResult orElse(),
  }) {
    if (navigationItemReplaced != null) {
      return navigationItemReplaced(this);
    }
    return orElse();
  }
}

abstract class _NavigationItemReplaced implements NavigationEvent {
  const factory _NavigationItemReplaced(
          final int index, final NavigationItem newItem) =
      _$NavigationItemReplacedImpl;

  int get index;
  NavigationItem get newItem;

  /// Create a copy of NavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NavigationItemReplacedImplCopyWith<_$NavigationItemReplacedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NavigationState {
  int get currentIndex => throw _privateConstructorUsedError;
  List<NavigationItem> get navigationItems =>
      throw _privateConstructorUsedError;
  bool get isCustomizing => throw _privateConstructorUsedError;

  /// Create a copy of NavigationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NavigationStateCopyWith<NavigationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NavigationStateCopyWith<$Res> {
  factory $NavigationStateCopyWith(
          NavigationState value, $Res Function(NavigationState) then) =
      _$NavigationStateCopyWithImpl<$Res, NavigationState>;
  @useResult
  $Res call(
      {int currentIndex,
      List<NavigationItem> navigationItems,
      bool isCustomizing});
}

/// @nodoc
class _$NavigationStateCopyWithImpl<$Res, $Val extends NavigationState>
    implements $NavigationStateCopyWith<$Res> {
  _$NavigationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NavigationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentIndex = null,
    Object? navigationItems = null,
    Object? isCustomizing = null,
  }) {
    return _then(_value.copyWith(
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      navigationItems: null == navigationItems
          ? _value.navigationItems
          : navigationItems // ignore: cast_nullable_to_non_nullable
              as List<NavigationItem>,
      isCustomizing: null == isCustomizing
          ? _value.isCustomizing
          : isCustomizing // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NavigationStateImplCopyWith<$Res>
    implements $NavigationStateCopyWith<$Res> {
  factory _$$NavigationStateImplCopyWith(_$NavigationStateImpl value,
          $Res Function(_$NavigationStateImpl) then) =
      __$$NavigationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentIndex,
      List<NavigationItem> navigationItems,
      bool isCustomizing});
}

/// @nodoc
class __$$NavigationStateImplCopyWithImpl<$Res>
    extends _$NavigationStateCopyWithImpl<$Res, _$NavigationStateImpl>
    implements _$$NavigationStateImplCopyWith<$Res> {
  __$$NavigationStateImplCopyWithImpl(
      _$NavigationStateImpl _value, $Res Function(_$NavigationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NavigationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentIndex = null,
    Object? navigationItems = null,
    Object? isCustomizing = null,
  }) {
    return _then(_$NavigationStateImpl(
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      navigationItems: null == navigationItems
          ? _value._navigationItems
          : navigationItems // ignore: cast_nullable_to_non_nullable
              as List<NavigationItem>,
      isCustomizing: null == isCustomizing
          ? _value.isCustomizing
          : isCustomizing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$NavigationStateImpl implements _NavigationState {
  const _$NavigationStateImpl(
      {required this.currentIndex,
      required final List<NavigationItem> navigationItems,
      required this.isCustomizing})
      : _navigationItems = navigationItems;

  @override
  final int currentIndex;
  final List<NavigationItem> _navigationItems;
  @override
  List<NavigationItem> get navigationItems {
    if (_navigationItems is EqualUnmodifiableListView) return _navigationItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_navigationItems);
  }

  @override
  final bool isCustomizing;

  @override
  String toString() {
    return 'NavigationState(currentIndex: $currentIndex, navigationItems: $navigationItems, isCustomizing: $isCustomizing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigationStateImpl &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            const DeepCollectionEquality()
                .equals(other._navigationItems, _navigationItems) &&
            (identical(other.isCustomizing, isCustomizing) ||
                other.isCustomizing == isCustomizing));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentIndex,
      const DeepCollectionEquality().hash(_navigationItems), isCustomizing);

  /// Create a copy of NavigationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigationStateImplCopyWith<_$NavigationStateImpl> get copyWith =>
      __$$NavigationStateImplCopyWithImpl<_$NavigationStateImpl>(
          this, _$identity);
}

abstract class _NavigationState implements NavigationState {
  const factory _NavigationState(
      {required final int currentIndex,
      required final List<NavigationItem> navigationItems,
      required final bool isCustomizing}) = _$NavigationStateImpl;

  @override
  int get currentIndex;
  @override
  List<NavigationItem> get navigationItems;
  @override
  bool get isCustomizing;

  /// Create a copy of NavigationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NavigationStateImplCopyWith<_$NavigationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
