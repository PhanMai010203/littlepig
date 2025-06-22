# 📂 Categories Guide

The **Categories** system is essential for classifying transactions, allowing users to organize their income and expenses effectively. Every transaction is assigned a category, which is crucial for budgeting and analytics.

## 1. Core Concepts

### Category Properties

A `Category` entity has the following key properties:

| Property    | Type      | Description                                                 |
|-------------|-----------|-------------------------------------------------------------|
| `id`        | `int`     | Unique identifier for the category.                         |
| `name`      | `String`  | The name of the category (e.g., "Food", "Salary").          |
| `icon`      | `String`  | An emoji or icon name representing the category.            |
| `color`     | `Color`   | A specific color for visual identification.                 |
| `isExpense` | `bool`    | `true` for expense categories, `false` for income.          |
| `isDefault` | `bool`    | `true` if it's a pre-defined category, `false` for custom.  |
| `syncId`    | `String`  | A unique ID used for data synchronization across devices.   |

### Default Categories

The app comes with a pre-defined set of default categories for common income and expense types. These are defined in the `DefaultCategories` class (`lib/core/constants/default_categories.dart`). Users can also create their own custom categories.

## 2. Key Operations via `CategoryRepository`

All category-related database operations are handled by the `CategoryRepository`.

**Key repository methods:**

- `getAllCategories()`: Fetches all categories (both income and expense).
- `getExpenseCategories()`: Fetches only the expense categories.
- `getIncomeCategories()`: Fetches only the income categories.
- `createCategory(category)`: Creates a new custom category.
- `updateCategory(category)`: Updates an existing category.
- `deleteCategory(id)`: Deletes a category.

```dart
// Example: Fetching all expense categories
final categoryRepository = getIt<CategoryRepository>();
final expenseCategories = await categoryRepository.getExpenseCategories();
```

## 3. Integration & Best Practices

- **Transaction Association**: Every transaction must be linked to a category. This is fundamental for the app's reporting features.
- **Filtering**: Use the `isExpense` flag to separate categories into income and expense groups, which is useful for UI elements like segmented controls.
- **Analytics**: The analytics features heavily rely on categories to aggregate spending and income data. For example, `getTotalByCategory()` in the transaction analytics system uses category IDs.
- **User Customization**: Allow users to create, edit, and delete their own categories to tailor the app to their financial life. Default categories should probably not be editable or deletable. 