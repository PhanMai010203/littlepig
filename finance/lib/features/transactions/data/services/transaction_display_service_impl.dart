import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_card_data.dart';
import '../../domain/services/transaction_display_service.dart';
import '../../../categories/domain/entities/category.dart';

/// Implementation of the transaction display service
/// 
/// This class contains all the business logic for preparing transaction
/// data for display, following Clean Architecture principles.
@LazySingleton(as: TransactionDisplayService)
class TransactionDisplayServiceImpl implements TransactionDisplayService {
  
  @override
  Future<List<TransactionCardData>> prepareTransactionCardsData(
    List<Transaction> transactions,
    Map<int, Category> categories, {
    BuildContext? context,
  }) async {
    final List<TransactionCardData> cardData = [];
    
    for (final transaction in transactions) {
      final category = categories[transaction.categoryId];
      final isIncome = transaction.isIncome;
      
      // Pre-calculate all display values
      final formattedAmount = formatTransactionAmount(transaction);
      final formattedDate = formatTransactionDate(transaction);
      final amountColor = calculateAmountColor(transaction, context: context);
      final categoryColor = getCategoryColor(category, isIncome, context: context);
      final categoryIcon = getCategoryIcon(category, isIncome);
      final hasNote = transaction.note != null && transaction.note!.isNotEmpty;
      final displayNote = hasNote ? _truncateNote(transaction.note!) : null;
      
      cardData.add(TransactionCardData(
        transaction: transaction,
        category: category,
        formattedAmount: formattedAmount,
        formattedDate: formattedDate,
        amountColor: amountColor,
        categoryColor: categoryColor,
        categoryIcon: categoryIcon,
        isIncome: isIncome,
        hasNote: hasNote,
        displayNote: displayNote,
      ));
    }
    
    return cardData;
  }

  @override
  List<Transaction> filterCurrentMonthTransactions(
    List<Transaction> transactions, {
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    
    return transactions.where((transaction) {
      return transaction.date.isAfter(currentMonth.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(nextMonth);
    }).toList();
  }

  @override
  List<Transaction> filterTransactionsByType(
    List<Transaction> transactions,
    TransactionFilter filter,
  ) {
    switch (filter) {
      case TransactionFilter.all:
        return transactions;
      case TransactionFilter.expense:
        return transactions.where((t) => t.isExpense).toList();
      case TransactionFilter.income:
        return transactions.where((t) => t.isIncome).toList();
    }
  }

  @override
  Color calculateAmountColor(Transaction transaction, {BuildContext? context}) {
    if (transaction.isIncome) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  String formatTransactionAmount(Transaction transaction, {bool showSign = true}) {
    final amount = transaction.amount.abs(); // Always show positive number
    final sign = showSign ? (transaction.isIncome ? '+' : '') : '';
    return '$sign${NumberFormat.currency(symbol: '\$').format(amount)}';
  }

  @override
  String formatTransactionDate(Transaction transaction, {String? format}) {
    final formatter = DateFormat(format ?? 'MMM d');
    return formatter.format(transaction.date);
  }

  @override
  String getCategoryIcon(Category? category, bool isIncome) {
    if (category != null) {
      return category.icon;
    }
    
    // Fallback icons for missing categories
    return isIncome ? '💰' : '💸';
  }

  @override
  Color getCategoryColor(
    Category? category,
    bool isIncome, {
    BuildContext? context,
  }) {
    if (category != null) {
      return category.color.withValues(alpha: 0.15);
    }
    
    // Fallback colors for missing categories
    if (isIncome) {
      return Colors.green.withValues(alpha: 0.1);
    } else {
      return Colors.red.withValues(alpha: 0.1);
    }
  }

  /// Helper method to truncate notes for display
  String _truncateNote(String note, {int maxLength = 50}) {
    if (note.length <= maxLength) {
      return note;
    }
    return '${note.substring(0, maxLength)}...';
  }
}