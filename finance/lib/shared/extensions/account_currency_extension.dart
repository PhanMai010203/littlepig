import '../../features/accounts/domain/entities/account.dart';
import '../../features/currencies/domain/entities/currency.dart';
import '../../features/currencies/domain/repositories/currency_repository.dart';
import '../utils/currency_formatter.dart';

/// Extension to add currency functionality to Account entities
extension AccountCurrencyExtension on Account {
  /// Gets the currency entity for this account
  Future<Currency?> getCurrency(CurrencyRepository currencyRepository) async {
    return await currencyRepository.getCurrencyByCode(currency);
  }

  /// Formats the account balance with currency symbol
  Future<String> formatBalance(
    CurrencyRepository currencyRepository, {
    bool showSymbol = true,
    bool showCode = false,
    bool compact = false,
  }) async {
    final currencyEntity = await getCurrency(currencyRepository);

    if (currencyEntity == null) {
      // Fallback formatting if currency not found
      return '$currency ${balance.toStringAsFixed(2)}';
    }

    return CurrencyFormatter.formatAmount(
      amount: balance,
      currency: currencyEntity,
      showSymbol: showSymbol,
      showCode: showCode,
      compact: compact,
    );
  }

  /// Converts this account's balance to another currency
  Future<double> convertBalanceTo(
    String targetCurrency,
    CurrencyRepository currencyRepository,
  ) async {
    if (currency.toUpperCase() == targetCurrency.toUpperCase()) {
      return balance;
    }

    return await currencyRepository.convertAmount(
      amount: balance,
      fromCurrency: currency,
      toCurrency: targetCurrency,
    );
  }

  /// Gets formatted balance in a specific currency
  Future<String> formatBalanceIn(
    String targetCurrency,
    CurrencyRepository currencyRepository, {
    bool showSymbol = true,
    bool showCode = false,
    bool compact = false,
  }) async {
    final convertedAmount =
        await convertBalanceTo(targetCurrency, currencyRepository);
    final targetCurrencyEntity =
        await currencyRepository.getCurrencyByCode(targetCurrency);

    if (targetCurrencyEntity == null) {
      return '$targetCurrency ${convertedAmount.toStringAsFixed(2)}';
    }

    return CurrencyFormatter.formatAmount(
      amount: convertedAmount,
      currency: targetCurrencyEntity,
      showSymbol: showSymbol,
      showCode: showCode,
      compact: compact,
    );
  }

  /// Checks if this account uses a specific currency
  bool usesCurrency(String currencyCode) {
    return currency.toUpperCase() == currencyCode.toUpperCase();
  }

  /// Updates the account with a new currency (does not perform conversion)
  Account changeCurrency(String newCurrency) {
    return copyWith(currency: newCurrency.toUpperCase());
  }

  /// Creates a new account with currency converted to specified currency
  Future<Account> convertCurrencyTo(
    String targetCurrency,
    CurrencyRepository currencyRepository,
  ) async {
    final convertedBalance =
        await convertBalanceTo(targetCurrency, currencyRepository);

    return copyWith(
      currency: targetCurrency.toUpperCase(),
      balance: convertedBalance,
    );
  }
}
