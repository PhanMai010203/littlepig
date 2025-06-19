import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/navigation_item.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';
part 'navigation_bloc.freezed.dart';

@injectable
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationStateX.initial) {
    on<_NavigationIndexChanged>(_onNavigationIndexChanged);
    on<_CustomizeNavigation>(_onCustomizeNavigation);
    on<_NavigationItemReplaced>(_onNavigationItemReplaced);
  }

  void _onNavigationIndexChanged(
    _NavigationIndexChanged event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }

  void _onCustomizeNavigation(
    _CustomizeNavigation event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(isCustomizing: event.isCustomizing));
  }

  void _onNavigationItemReplaced(
    _NavigationItemReplaced event,
    Emitter<NavigationState> emit,
  ) {
    final updatedItems = List<NavigationItem>.from(state.navigationItems);
    updatedItems[event.index] = event.newItem;

    emit(state.copyWith(
      navigationItems: updatedItems,
      isCustomizing: false,
    ));
  }
}
