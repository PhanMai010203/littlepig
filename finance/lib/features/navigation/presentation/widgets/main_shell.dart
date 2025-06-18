import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/entities/navigation_item.dart';
import '../bloc/navigation_bloc.dart';
import 'adaptive_bottom_navigation.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import 'navigation_customization_content.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: child,
          bottomNavigationBar: AdaptiveBottomNavigation(
            currentIndex: state.currentIndex,
            items: state.navigationItems,
            onTap: (index) {
              // Update navigation state
              context.read<NavigationBloc>().add(
                NavigationEvent.navigationIndexChanged(index),
              );
              
              // Navigate to the selected route
              final route = state.navigationItems[index].routePath;
              context.go(route);
            },
            onLongPress: (index) {
              // Show customization dialog using PopupFramework
              _showCustomizationDialog(context, index, state);
            },
          ),
        );
      },
    );
  }

  /// Phase 5 Enhancement: Enhanced customization dialog with PopupFramework
  void _showCustomizationDialog(
    BuildContext context,
    int index,
    NavigationState state,
  ) {
    final availableItems = NavigationItem.allItems
        .where((item) => !state.navigationItems.contains(item))
        .toList();

    DialogService.showPopup<void>(
      context,
      NavigationCustomizationContent(
        currentIndex: index,
        currentItem: state.navigationItems[index],
        availableItems: availableItems,
        onItemSelected: (newItem) {
          context.read<NavigationBloc>().add(
            NavigationEvent.navigationItemReplaced(index, newItem),
          );
          Navigator.of(context).pop();
        },
      ),
      title: 'navigation.customize_title'.tr(),
      subtitle: 'navigation.customize_message'.tr(
        namedArgs: {'item': state.navigationItems[index].label.tr()},
      ),
      icon: Icons.edit,
      showCloseButton: true,
      barrierDismissible: true,
    );
  }
} 