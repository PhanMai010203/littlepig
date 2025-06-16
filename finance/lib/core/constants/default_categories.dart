class DefaultCategory {
  final String name;
  final String emoji;
  final int color;
  final bool isExpense;
  final String syncId;

  const DefaultCategory({
    required this.name,
    required this.emoji,
    required this.color,
    required this.isExpense,
    required this.syncId,
  });
}

/// Default categories with emoji icons that work on both iOS and Android
class DefaultCategories {
  static const List<DefaultCategory> incomeCategories = [
    DefaultCategory(
      name: 'Lương - Salary',
      emoji: '💰',
      color: 0xFF4CAF50, // Green
      isExpense: false,
      syncId: 'income-salary',
    ),
    DefaultCategory(
      name: 'Thưởng - Awards',
      emoji: '🏆',
      color: 0xFFFFD700, // Gold
      isExpense: false,
      syncId: 'income-awards',
    ),
    DefaultCategory(
      name: 'Hoàn tiền - Refunds',
      emoji: '💳',
      color: 0xFF2196F3, // Blue
      isExpense: false,
      syncId: 'income-refunds',
    ),
    DefaultCategory(
      name: 'Buôn bán - Sale',
      emoji: '🛒',
      color: 0xFF9C27B0, // Purple
      isExpense: false,
      syncId: 'income-sale',
    ),
    DefaultCategory(
      name: 'Khác - Others',
      emoji: '💼',
      color: 0xFF607D8B, // Blue Grey
      isExpense: false,
      syncId: 'income-others',
    ),
  ];

  static const List<DefaultCategory> expenseCategories = [
    DefaultCategory(
      name: 'Ăn uống - Food',
      emoji: '🍽️',
      color: 0xFFFF6B35, // Orange
      isExpense: true,
      syncId: 'expense-food',
    ),
    DefaultCategory(
      name: 'Làm đẹp - Beauty',
      emoji: '💄',
      color: 0xFFE91E63, // Pink
      isExpense: true,
      syncId: 'expense-beauty',
    ),
    DefaultCategory(
      name: 'Hóa đơn - Bills',
      emoji: '📄',
      color: 0xFFFF9800, // Orange
      isExpense: true,
      syncId: 'expense-bills',
    ),
    DefaultCategory(
      name: 'Quần áo - Clothing',
      emoji: '👕',
      color: 0xFF9C27B0, // Purple
      isExpense: true,
      syncId: 'expense-clothing',
    ),
    DefaultCategory(
      name: 'Học tập - Education',
      emoji: '📚',
      color: 0xFF3F51B5, // Indigo
      isExpense: true,
      syncId: 'expense-education',
    ),
    DefaultCategory(
      name: 'Giải trí - Entertainment',
      emoji: '🎬',
      color: 0xFFE91E63, // Pink
      isExpense: true,
      syncId: 'expense-entertainment',
    ),
    DefaultCategory(
      name: 'Sức khỏe - Health',
      emoji: '🏥',
      color: 0xFFF44336, // Red
      isExpense: true,
      syncId: 'expense-health',
    ),
    DefaultCategory(
      name: 'Gym - Gym',
      emoji: '💪',
      color: 0xFF795548, // Brown
      isExpense: true,
      syncId: 'expense-gym',
    ),
    DefaultCategory(
      name: 'Bảo hiểm - Insurance',
      emoji: '🛡️',
      color: 0xFF607D8B, // Blue Grey
      isExpense: true,
      syncId: 'expense-insurance',
    ),
    DefaultCategory(
      name: 'Mua sắm - Shopping',
      emoji: '🛍️',
      color: 0xFF9C27B0, // Purple
      isExpense: true,
      syncId: 'expense-shopping',
    ),
    DefaultCategory(
      name: 'Ăn vặt - Snacks',
      emoji: '🍿',
      color: 0xFFFF5722, // Deep Orange
      isExpense: true,
      syncId: 'expense-snacks',
    ),
    DefaultCategory(
      name: 'Trả hộ - Paying for someone',
      emoji: '🤝',
      color: 0xFF009688, // Teal
      isExpense: true,
      syncId: 'expense-paying-for-someone',
    ),
    DefaultCategory(
      name: 'Thể thao - Sports',
      emoji: '⚽',
      color: 0xFF4CAF50, // Green
      isExpense: true,
      syncId: 'expense-sports',
    ),
    DefaultCategory(
      name: 'Nhà ở - Home',
      emoji: '🏠',
      color: 0xFF795548, // Brown
      isExpense: true,
      syncId: 'expense-home',
    ),
    DefaultCategory(
      name: 'Chi phí đi lại - Transportation',
      emoji: '🚗',
      color: 0xFF2196F3, // Blue
      isExpense: true,
      syncId: 'expense-transportation',
    ),
    DefaultCategory(
      name: 'Đồ điện tử - Electronics',
      emoji: '📱',
      color: 0xFF673AB7, // Deep Purple
      isExpense: true,
      syncId: 'expense-electronics',
    ),
    DefaultCategory(
      name: 'Khác - Other',
      emoji: '❓',
      color: 0xFF9E9E9E, // Grey
      isExpense: true,
      syncId: 'expense-other',
    ),
  ];

  /// Get all default categories (income + expense)
  static List<DefaultCategory> get allCategories => [
    ...incomeCategories,
    ...expenseCategories,
  ];
}
