part of 'navigation_bloc.dart';

@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState({
    required int currentIndex,
    required List<NavigationItem> navigationItems,
    required bool isCustomizing,
  }) = _NavigationState;
}

extension NavigationStateX on NavigationState {
  static NavigationState get initial => const NavigationState(
        currentIndex: 0,
        navigationItems: NavigationItem.defaultItems,
        isCustomizing: false,
      );
}