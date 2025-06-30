import 'package:flutter/material.dart';
import '../entities/transaction.dart';
import '../entities/transaction_card_data.dart';
import '../../../categories/domain/entities/category.dart';

/// Enum for transaction filter options on the homepage
enum TransactionFilter { all, expense, income }

/// Service interface for transaction display logic
/// 
/// This service centralizes all transaction formatting, filtering, and 
/// display data preparation logic, following Clean Architecture principles.
/// It ensures reusability across different UI components.
abstract class TransactionDisplayService {
  /// Prepares transaction data for display in cards
  /// 
  /// Takes raw transactions and categories, then returns a list of 
  /// [TransactionCardData] with all display values pre-calculated.
  /// 
  /// [transactions] List of transactions to process
  /// [categories] Map of category ID to Category entity
  /// [context] BuildContext for accessing theme colors (optional)
  /// 
  /// Returns a list of [TransactionCardData] ready for UI rendering
  Future<List<TransactionCardData>> prepareTransactionCardsData(
    List<Transaction> transactions,
    Map<int, Category> categories, {
    BuildContext? context,
  });

  /// Filters transactions to show only current month's entries
  /// 
  /// [transactions] List of transactions to filter
  /// [currentDate] Optional date to use as "current" (defaults to DateTime.now())
  /// 
  /// Returns filtered list containing only current month transactions
  List<Transaction> filterCurrentMonthTransactions(
    List<Transaction> transactions, {
    DateTime? currentDate,
  });

  /// Filters transactions by type (All, Expense, Income)
  /// 
  /// [transactions] List of transactions to filter
  /// [filter] The filter type to apply
  /// 
  /// Returns filtered list based on the selected filter
  List<Transaction> filterTransactionsByType(
    List<Transaction> transactions,
    TransactionFilter filter,
  );

  /// Calculates the appropriate color for transaction amount display
  /// 
  /// [transaction] The transaction to get color for
  /// [context] BuildContext for accessing theme colors (optional)
  /// 
  /// Returns appropriate color (green for income, red for expense)
  Color calculateAmountColor(Transaction transaction, {BuildContext? context});

  /// Formats transaction amount with proper currency and sign
  /// 
  /// [transaction] The transaction to format
  /// [showSign] Whether to show + or - prefix (defaults to true)
  /// 
  /// Returns formatted amount string
  String formatTransactionAmount(Transaction transaction, {bool showSign = true});

  /// Formats transaction date for display
  /// 
  /// [transaction] The transaction to format date for
  /// [format] Optional date format pattern
  /// 
  /// Returns formatted date string
  String formatTransactionDate(Transaction transaction, {String? format});

  /// Gets category icon with fallback for missing categories
  /// 
  /// [category] The category (can be null)
  /// [isIncome] Whether the transaction is income (for fallback icon)
  /// 
  /// Returns category icon emoji or fallback icon
  String getCategoryIcon(Category? category, bool isIncome);

  /// Gets category color with fallback for missing categories
  /// 
  /// [category] The category (can be null)
  /// [isIncome] Whether the transaction is income (for fallback color)
  /// [context] BuildContext for accessing theme colors (optional)
  /// 
  /// Returns category color with appropriate opacity
  Color getCategoryColor(
    Category? category,
    bool isIncome, {
    BuildContext? context,
  });
}