import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_card_data.dart';
import '../../domain/services/transaction_display_service.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../currencies/domain/repositories/currency_repository.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../currencies/domain/entities/currency.dart';

/// Implementation of the transaction display service
/// 
/// This class contains all the business logic for preparing transaction
/// data for display, following Clean Architecture principles.
@LazySingleton(as: TransactionDisplayService)
class TransactionDisplayServiceImpl implements TransactionDisplayService {
  
  TransactionDisplayServiceImpl(
    this._accountRepository,
    this._currencyRepository,
  );

  final AccountRepository _accountRepository;
  final CurrencyRepository _currencyRepository;

  @override
  Future<List<TransactionCardData>> prepareTransactionCardsData(
    List<Transaction> transactions,
    Map<int, Category> categories, {
    BuildContext? context,
  }) async {
    final List<TransactionCardData> cardData = [];
    
    // Prefetch accounts to avoid repeated DB hits
    final accounts = await _accountRepository.getAllAccounts();
    final Map<int, Account> accountById = {
      for (final acc in accounts) if (acc.id != null) acc.id!: acc,
    };

    // Gather distinct currency codes used by these accounts
    final Set<String> currencyCodes = {
      for (final acc in accounts) acc.currency.toUpperCase(),
    };

    // Prefetch currency entities
    final Map<String, Currency> currencyCache = {};
    for (final code in currencyCodes) {
      final currency = await _currencyRepository.getCurrencyByCode(code);
      if (currency != null) {
        currencyCache[code] = currency;
      }
    }

    for (final transaction in transactions) {
      final category = categories[transaction.categoryId];
      final isIncome = transaction.isIncome;

      // Find currency for this transaction via its account
      final account = accountById[transaction.accountId];
      final currencyCode = account?.currency.toUpperCase() ?? 'USD';
      final currency = currencyCache[currencyCode];

      // Pre-calculate all display values
      final formattedAmount = _formatTransactionAmount(
        transaction,
        currency: currency,
      );
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
    // Deprecated: Kept for backward compatibility. This method now delegates
    // to `_formatTransactionAmount` with a null currency fallback.
    return _formatTransactionAmount(transaction, showSign: showSign);
  }

  /// New internal formatter that supports multi-currency and proper +/- signs.
  String _formatTransactionAmount(
    Transaction transaction, {
    Currency? currency,
    bool showSign = true,
  }) {
    final amount = transaction.amount;

    // Use provided currency entity when available, otherwise fallback to simple
    // currency formatter with the account\'s currency code or '$'.
    String formattedNumber;
    if (currency != null) {
      formattedNumber = CurrencyFormatter.formatAmount(
        amount: amount,
        currency: currency,
        showSymbol: true,
        showCode: false,
        forceSign: showSign,
      );
    } else {
      // This fallback still uses NumberFormat directly, so handle sign manually
      final sign = showSign ? (transaction.isIncome ? '+' : '-') : '';
      formattedNumber = '$sign${NumberFormat.currency(symbol: '\
    }

    // The sign is now handled by CurrencyFormatter.formatAmount when currency is not null.
    // For the fallback case, it\'s handled manually above.
    return formattedNumber;
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
}).format(amount.abs())}';
    }

    // The sign is now handled by CurrencyFormatter.formatAmount when currency is not null.
    // For the fallback case, it\'s handled manually above.
    return formattedNumber;
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