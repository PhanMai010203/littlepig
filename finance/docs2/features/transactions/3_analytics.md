# Transactions: Analytics & Search

This guide focuses on how to analyze, query, and search for transactions using the available repository methods.

## Analytics

### Get Total by Category
```dart
// Get total spending for a category (all time)
final categoryTotal = await transactionRepository.getTotalByCategory(
  foodCategoryId,
  null, // from date
  null, // to date
);

// Get category total for specific period
final monthlyFoodSpending = await transactionRepository.getTotalByCategory(
  foodCategoryId,
  DateTime(2024, 6, 1), // June 1st
  DateTime(2024, 6, 30), // June 30th
);
```

### Get Total by Account
```dart
// Get total transactions for an account
final accountTotal = await transactionRepository.getTotalByAccount(
  accountId,
  DateTime(2024, 1, 1), // Year start
  DateTime(2024, 12, 31), // Year end
);
```

### Get Spending by Categories
```dart
// Get spending breakdown by all categories
final spendingBreakdown = await transactionRepository.getSpendingByCategory(
  DateTime(2024, 6, 1),
  DateTime(2024, 6, 30),
);

// spendingBreakdown is Map<int, double> where key is categoryId
for (final entry in spendingBreakdown.entries) {
  final categoryId = entry.key;
  final amount = entry.value;
  print('Category $categoryId: ${amount.toStringAsFixed(2)}');
}
```

## Filtering and Searching

### Filter Transactions Manually
```dart
// Filter transactions by criteria
final allTransactions = await transactionRepository.getAllTransactions();

// Filter by amount range
final largeTransactions = allTransactions.where(
  (t) => t.amount.abs() > 50
).toList();

// Filter by date
final recentTransactions = allTransactions.where(
  (t) => t.date.isAfter(DateTime.now().subtract(Duration(days: 7)))
).toList();

// Filter by type
final incomeTransactions = allTransactions.where((t) => t.isIncome).toList();
final expenseTransactions = allTransactions.where((t) => t.isExpense).toList();

// Filter transactions with notes
final transactionsWithNotes = allTransactions.where(
  (t) => t.note != null && t.note!.isNotEmpty
).toList();
```

### Transaction Search with Notes and Attachments
```dart
// Search transactions by title or notes
Future<List<Transaction>> searchTransactions(String query) async {
  final allTransactions = await transactionRepository.getAllTransactions();
  final searchQuery = query.toLowerCase();
  
  return allTransactions.where((transaction) {
    final title = transaction.title.toLowerCase();
    final note = (transaction.note ?? '').toLowerCase();
    
    return title.contains(searchQuery) || 
           note.contains(searchQuery);
  }).toList();
}

// Search transactions with attachments of specific type
Future<List<Transaction>> searchTransactionsWithImages() async {
  final allTransactions = await transactionRepository.getAllTransactions();
  final transactionsWithImages = <Transaction>[];
  
  for (final transaction in allTransactions) {
    final attachments = await attachmentRepository.getAttachmentsByTransaction(transaction.id!);
    final hasImages = attachments.any((attachment) => attachment.isImage);
    
    if (hasImages) {
      transactionsWithImages.add(transaction);
    }
  }
  
  return transactionsWithImages;
}
```

### Monthly Spending Analysis with Attachments
```dart
// Analyze spending for current month including attachment information
Future<Map<String, dynamic>> getMonthlySpendingAnalysis() async {
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 0);
  
  final spendingByCategory = await transactionRepository.getSpendingByCategory(
    monthStart,
    monthEnd,
  );
  
  final allTransactions = await transactionRepository.getTransactionsByDateRange(
    monthStart,
    monthEnd,
  );
  
  // Count transactions with attachments
  int transactionsWithAttachments = 0;
  for (final transaction in allTransactions) {
    final attachments = await attachmentRepository.getAttachmentsByTransaction(transaction.id!);
    if (attachments.isNotEmpty) {
      transactionsWithAttachments++;
    }
  }
  
  // Convert category IDs to names
  final categorySpending = <String, double>{};
  for (final entry in spendingByCategory.entries) {
    final category = await categoryRepository.getCategoryById(entry.key);
    if (category != null) {
      categorySpending[category.name] = entry.value.abs();
    }
  }
  
  return {
    'spending_by_category': categorySpending,
    'total_transactions': allTransactions.length,
    'transactions_with_attachments': transactionsWithAttachments,
    'attachment_percentage': allTransactions.isNotEmpty 
        ? (transactionsWithAttachments / allTransactions.length * 100).toStringAsFixed(1)
        : '0',
  };
}
``` 