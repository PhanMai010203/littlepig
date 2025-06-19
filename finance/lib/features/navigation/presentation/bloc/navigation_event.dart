part of 'navigation_bloc.dart';

@freezed
class NavigationEvent with _$NavigationEvent {
  const factory NavigationEvent.navigationIndexChanged(int index) =
      _NavigationIndexChanged;
  const factory NavigationEvent.customizeNavigation(bool isCustomizing) =
      _CustomizeNavigation;
  const factory NavigationEvent.navigationItemReplaced(
    int index,
    NavigationItem newItem,
  ) = _NavigationItemReplaced;
}
