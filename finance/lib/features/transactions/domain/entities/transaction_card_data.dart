import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'transaction.dart';
import '../../../categories/domain/entities/category.dart';

/// Lightweight view-model for transaction display data on the homepage
/// 
/// This class pre-calculates all display values to eliminate complex 
/// calculations in widgets, following the Clean Architecture pattern
/// established in the budget refactor.
class TransactionCardData extends Equatable {
  /// The original transaction entity
  final Transaction transaction;
  
  /// Associated category (can be null if category doesn't exist)
  final Category? category;
  
  /// Pre-formatted amount string with currency symbol and proper formatting
  final String formattedAmount;
  
  /// Pre-formatted date string for display
  final String formattedDate;
  
  /// Color for the amount text (green for income, red for expense)
  final Color amountColor;
  
  /// Background color for the category icon circle
  final Color categoryColor;
  
  /// Category icon emoji or fallback icon
  final String categoryIcon;
  
  /// Whether this transaction is income (amount > 0)
  final bool isIncome;
  
  /// Whether this transaction has a note
  final bool hasNote;
  
  /// Note text for display (truncated if needed)
  final String? displayNote;

  const TransactionCardData({
    required this.transaction,
    required this.category,
    required this.formattedAmount,
    required this.formattedDate,
    required this.amountColor,
    required this.categoryColor,
    required this.categoryIcon,
    required this.isIncome,
    required this.hasNote,
    this.displayNote,
  });

  /// Creates a copy of this TransactionCardData with updated values
  TransactionCardData copyWith({
    Transaction? transaction,
    Category? category,
    String? formattedAmount,
    String? formattedDate,
    Color? amountColor,
    Color? categoryColor,
    String? categoryIcon,
    bool? isIncome,
    bool? hasNote,
    String? displayNote,
  }) {
    return TransactionCardData(
      transaction: transaction ?? this.transaction,
      category: category ?? this.category,
      formattedAmount: formattedAmount ?? this.formattedAmount,
      formattedDate: formattedDate ?? this.formattedDate,
      amountColor: amountColor ?? this.amountColor,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      isIncome: isIncome ?? this.isIncome,
      hasNote: hasNote ?? this.hasNote,
      displayNote: displayNote ?? this.displayNote,
    );
  }

  @override
  List<Object?> get props => [
        transaction,
        category,
        formattedAmount,
        formattedDate,
        amountColor,
        categoryColor,
        categoryIcon,
        isIncome,
        hasNote,
        displayNote,
      ];

  @override
  String toString() {
    return 'TransactionCardData(transaction: ${transaction.id}, '
        'amount: $formattedAmount, '
        'category: ${category?.name}, '
        'isIncome: $isIncome)';
  }
}