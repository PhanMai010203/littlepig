import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/entities/navigation_item.dart';
import '../bloc/navigation_bloc.dart';
import 'adaptive_bottom_navigation.dart';

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
              // Show customization dialog for navigation items
              _showCustomizationDialog(context, index, state);
            },
          ),
        );
      },
    );
  }
  void _showCustomizationDialog(
    BuildContext context,
    int index,
    NavigationState state,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('navigation.customize_title'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('navigation.customize_message'.tr(namedArgs: {'item': state.navigationItems[index].label.tr()})),
            const SizedBox(height: 16),
            ...NavigationItem.allItems
                .where((item) => !state.navigationItems.contains(item))
                .map(
                  (item) => ListTile(
                    leading: Icon(Icons.circle),
                    title: Text(item.label.tr()),
                    onTap: () {
                      context.read<NavigationBloc>().add(
                        NavigationEvent.navigationItemReplaced(index, item),
                      );
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('common.cancel'.tr()),
          ),
        ],
      ),
    );
  }
} 