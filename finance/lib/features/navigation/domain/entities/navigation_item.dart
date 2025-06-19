import 'package:equatable/equatable.dart';

class NavigationItem extends Equatable {
  const NavigationItem({
    required this.id,
    required this.label,
    required this.iconPath,
    required this.routePath,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String iconPath;
  final String routePath;
  final bool isDefault;

  NavigationItem copyWith({
    String? id,
    String? label,
    String? iconPath,
    String? routePath,
    bool? isDefault,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      label: label ?? this.label,
      iconPath: iconPath ?? this.iconPath,
      routePath: routePath ?? this.routePath,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [id, label, iconPath, routePath, isDefault];

  // Default navigation items
  static const NavigationItem home = NavigationItem(
    id: 'home',
    label: 'navigation.home',
    iconPath: 'assets/icons/icon_home.svg',
    routePath: '/',
    isDefault: true,
  );

  static const NavigationItem transactions = NavigationItem(
    id: 'transactions',
    label: 'navigation.transactions',
    iconPath: 'assets/icons/icon_transactions.svg',
    routePath: '/transactions',
    isDefault: true,
  );

  static const NavigationItem budgets = NavigationItem(
    id: 'budgets',
    label: 'navigation.budgets',
    iconPath: 'assets/icons/icon_budget.svg',
    routePath: '/budgets',
    isDefault: true,
  );

  static const NavigationItem more = NavigationItem(
    id: 'more',
    label: 'navigation.more',
    iconPath: 'assets/icons/icon_more.svg',
    routePath: '/more',
    isDefault: true,
  );

  // Additional navigation items for customization
  static const NavigationItem goals = NavigationItem(
    id: 'goals',
    label: 'Goals',
    iconPath: 'assets/icons/icon_goals.svg',
    routePath: '/goals',
  );

  static const NavigationItem analytics = NavigationItem(
    id: 'analytics',
    label: 'Analytics',
    iconPath: 'assets/icons/icon_analytics.svg',
    routePath: '/analytics',
  );

  static const NavigationItem profile = NavigationItem(
    id: 'profile',
    label: 'Profile',
    iconPath: 'assets/icons/icon_profile.svg',
    routePath: '/profile',
  );

  static const NavigationItem notifications = NavigationItem(
    id: 'notifications',
    label: 'Notifications',
    iconPath: 'assets/icons/icon_notifications.svg',
    routePath: '/notifications',
  );

  // Get all available navigation items
  static const List<NavigationItem> allItems = [
    home,
    transactions,
    budgets,
    more,
    goals,
    analytics,
    profile,
    notifications,
  ];

  // Get default navigation items
  static const List<NavigationItem> defaultItems = [
    home,
    transactions,
    budgets,
    more,
  ];
}
