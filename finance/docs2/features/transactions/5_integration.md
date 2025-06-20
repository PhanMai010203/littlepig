# Transactions: Integration & Best Practices

This guide covers topics related to integrating the transaction system with other parts of the application, such as synchronization, error handling, and UI development.

## Sync Operations

### Get Unsynced Data
```dart
// Get transactions that haven't been synced to cloud
final unsyncedTransactions = await transactionRepository.getUnsyncedTransactions();
print('${unsyncedTransactions.length} transactions need syncing');

// Get attachments that haven't been synced
final unsyncedAttachments = await attachmentRepository.getUnsyncedAttachments();
print('${unsyncedAttachments.length} attachments need syncing');
```

### Mark as Synced
```dart
// Mark transaction as synced (typically done by sync service)
await transactionRepository.markAsSynced(
  transaction.syncId,
  DateTime.now(),
);

// Mark attachment as synced
await attachmentRepository.markAsSynced(
  attachment.syncId,
  DateTime.now(),
);
```

### Insert from Sync
```dart
// Insert or update transaction from cloud sync
await transactionRepository.insertOrUpdateFromSync(remoteTransaction);

// Insert or update attachment from cloud sync
await attachmentRepository.insertOrUpdateFromSync(remoteAttachment);
```

## Error Handling

### Handle Repository Errors
```dart
try {
  final transaction = await transactionRepository.createTransaction(newTransaction);
  print('Transaction created successfully');
} catch (e) {
  print('Failed to create transaction: $e');
  // Handle error - maybe show user feedback
}

try {
  final attachments = await filePickerService.addAttachments(transactionId);
  print('Attachments added successfully');
} catch (e) {
  print('Failed to add attachments: $e');
  // Maybe user denied Google Drive permission or file access
}
```

### Validate Before Operations
```dart
// Validate transaction data before creating
bool isValidTransaction(Transaction transaction) {
  if (transaction.title.trim().isEmpty) return false;
  if (transaction.amount == 0) return false;
  if (transaction.categoryId <= 0) return false;
  if (transaction.accountId <= 0) return false;
  return true;
}

if (isValidTransaction(newTransaction)) {
  await transactionRepository.createTransaction(newTransaction);
} else {
  print('Invalid transaction data');
}
```

## Best Practices

1. **Always Set Device ID**: Ensure transactions have proper device ID for sync
2. **Use Descriptive Titles**: Make transaction purposes clear
3. **Leverage Notes Field**: Use notes for additional context and information
4. **Consistent Amount Signs**: Negative for expenses, positive for income
5. **Handle Sync Status**: Check sync status for conflict resolution
6. **Validate Categories/Accounts**: Ensure referenced IDs exist
7. **Use Date Ranges**: Optimize queries with date filtering
8. **Batch Analytics**: Use repository analytics methods instead of manual calculations
9. **Google Drive Authorization**: Always check authorization before adding attachments
10. **Handle File Failures Gracefully**: Implement proper error handling for file operations

## Common Patterns

### Transaction Form Validation
```dart
class TransactionValidator {
  static String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Title is required';
    }
    if (title.length > 255) {
      return 'Title too long';
    }
    return null;
  }
  
  static String? validateAmount(String? amount) {
    if (amount == null || amount.isEmpty) {
      return 'Amount is required';
    }
    final value = double.tryParse(amount);
    if (value == null || value == 0) {
      return 'Invalid amount';
    }
    return null;
  }
  
  static String? validateNote(String? note) {
    if (note != null && note.length > 1000) {
      return 'Note too long (max 1000 characters)';
    }
    return null;
  }
}
```

### Transaction List Widget Helper
```dart
// Helper for displaying transactions in UI
String formatTransactionForDisplay(Transaction transaction) {
  final sign = transaction.isIncome ? '+' : '';
  final amount = '${sign}${transaction.amount.toStringAsFixed(2)}';
  final date = DateFormat('MMM dd, yyyy').format(transaction.date);
  final hasAttachments = transaction.id != null; // Would need to check in real scenario
  final attachmentIndicator = hasAttachments ? '📎' : '';
  final noteIndicator = transaction.note?.isNotEmpty == true ? '📝' : '';
  
  return '${transaction.title} • $amount • $date $attachmentIndicator$noteIndicator';
}
```

### Attachment Management Widget Helper
```dart
// Helper for managing attachments in UI
class AttachmentHelper {
  static String getAttachmentIcon(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return '🖼️';
      case AttachmentType.document:
        return '📄';
      case AttachmentType.other:
        return '📎';
    }
  }
  
  static String formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown size';
    
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
  
  static Color getAttachmentStatusColor(Attachment attachment) {
    if (!attachment.isAvailable) return Colors.red;
    if (!attachment.isUploaded) return Colors.orange;
    return Colors.green;
  }
}
```

## Migration and Backward Compatibility

The advanced transaction features are designed to be backward compatible:

- Existing transactions will have default values:
  - `transactionType`: `TransactionType.expense` (if amount < 0) or `TransactionType.income` (if amount > 0)
  - `recurrence`: `TransactionRecurrence.none`
  - `transactionState`: `TransactionState.completed`
  - `paid`: `false`
  - All other advanced fields: `null`

- Old code will continue to work without modifications
- New features are opt-in by setting the appropriate enum values
- Database migration (schema version 4) automatically adds the new fields with safe defaults 