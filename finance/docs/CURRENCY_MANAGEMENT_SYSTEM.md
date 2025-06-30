# Currency Management System - Usage Guide

## Basic Setup

```dart
import 'package:finance/services/currency_service.dart';
import 'package:finance/features/currencies/domain/repositories/currency_repository.dart';
import 'package:finance/core/di/injection.dart';

// Get the currency service
final currencyService = getIt<CurrencyService>();
```

## Currency Information

### Get All Currencies
```dart
// Get all 180+ supported currencies
final currencies = await currencyService.getAllCurrencies();
print('Found ${currencies.length} currencies');
```

### Get Popular Currencies
```dart
// Get commonly used currencies (USD, EUR, GBP, etc.)
final popularCurrencies = await currencyService.getPopularCurrencies();
```

### Search Currencies
```dart
// Search by name, code, or country
final dollarCurrencies = await currencyService.searchCurrencies('Dollar');
final europeanCurrencies = await currencyService.searchCurrencies('Europe');
```

### Get Specific Currency
```dart
// Get currency by code
final usd = await currencyService.getCurrency('USD');
if (usd != null) {
  print('${usd.name} (${usd.code}): ${usd.symbol}');
}
```

### Check Currency Support
```dart
// Verify if a currency is supported
final isSupported = await currencyService.isCurrencySupported('EUR');
```

## Currency Formatting

### Basic Formatting
```dart
// Format with symbol: $1,234.56
final formatted = await currencyService.formatAmount(
  amount: 1234.56, 
  currencyCode: 'USD'
);

// Format with code: 1,234.56 USD
final withCode = await currencyService.formatAmount(
  amount: 1234.56,
  currencyCode: 'USD',
  showSymbol: false,
  showCode: true,
);

// Compact formatting: $1.2K
final compact = await currencyService.formatAmount(
  amount: 1234.56,
  currencyCode: 'USD',
  compact: true,
);

// Force sign: +$1,234.56
final withSign = await currencyService.formatAmount(
  amount: 1234.56,
  currencyCode: 'USD',
  forceSign: true,
);
```

### Parse Amount from String
```dart
// Parse currency string back to number
final amount = await currencyService.parseAmount('$1,234.56', 'USD');
// Returns: 1234.56
```

### Currency Display Information
```dart
// Get currency symbol and code for display
final display = await currencyService.getCurrencyDisplay(
  currencyCode: 'EUR',
  useNativeSymbol: true,
  showCode: true,
);
// Returns: "€ (EUR)"
```

## Exchange Rates and Conversion

### Convert Between Currencies
```dart
// Convert using current exchange rates
final converted = await currencyService.convertAmount(
  amount: 100.0,
  fromCurrency: 'USD',
  toCurrency: 'EUR',
);
print('$100 USD = €${converted.toStringAsFixed(2)} EUR');
```

### Get Exchange Rates
```dart
// Get specific exchange rate
final rate = await currencyService.getExchangeRate(
  fromCurrency: 'USD',
  toCurrency: 'EUR',
);

// Get all current exchange rates
final allRates = await currencyService.getAllExchangeRates();
```

### Custom Exchange Rates
```dart
// Set custom exchange rate
await currencyService.setCustomExchangeRate(
  fromCurrency: 'USD',
  toCurrency: 'EUR',
  rate: 0.85,
);

// Get all custom rates
final customRates = await currencyService.getCustomExchangeRates();

// Remove custom rate
await currencyService.removeCustomExchangeRate(
  fromCurrency: 'USD',
  toCurrency: 'EUR',
);
```

### Exchange Rate Management
```dart
// Refresh rates from remote API
final success = await currencyService.refreshExchangeRates();

// Check when rates were last updated
final lastUpdate = await currencyService.getLastExchangeRateUpdate();
if (lastUpdate != null) {
  print('Rates last updated: $lastUpdate');
}
```

## Account Integration

### Account Currencies
```dart
// Get currencies used by all accounts
final accountCurrencies = await currencyService.getAccountCurrencies();

// Get exchange rates for account currencies
final accountRates = await currencyService.getAccountExchangeRates(
  baseCurrency: 'USD',
);
```

### Total Balance Calculations
```dart
// Get total balance across all accounts in specific currency
final totalInUSD = await currencyService.getTotalBalanceInCurrency('USD');

// Get formatted total balance
final formattedTotal = await currencyService.getFormattedTotalBalance(
  targetCurrency: 'USD',
  showSymbol: true,
);
```

## Advanced Usage

### Using Repository Directly
```dart
// For advanced operations, use repository directly
final repository = getIt<CurrencyRepository>();

// Set custom exchange rate
await repository.setCustomExchangeRate('USD', 'EUR', 0.85);

// Convert with specific amount
final converted = await repository.convertAmount(
  amount: 100.0,
  fromCurrency: 'USD',
  toCurrency: 'EUR',
);
```

### Error Handling
```dart
try {
  final converted = await currencyService.convertAmount(
    amount: 100.0,
    fromCurrency: 'USD',
    toCurrency: 'XYZ', // Invalid currency
  );
} catch (e) {
  print('Conversion failed: $e');
  // Handle error - maybe show fallback or error message
}
```

### Offline Support
```dart
// The system automatically handles offline scenarios:
// 1. Uses cached exchange rates (up to 7 days old)
// 2. Falls back to static rates for major currencies
// 3. Currency metadata always available (stored locally)

// Check if we're using cached/fallback data
final lastUpdate = await currencyService.getLastExchangeRateUpdate();
final isStale = lastUpdate == null || 
  DateTime.now().difference(lastUpdate).inHours > 6;

if (isStale) {
  // Show "offline" or "cached data" indicator in UI
}
```

## Best Practices

1. **Cache Service Instance**: Get CurrencyService once and reuse
2. **Handle Errors**: Always wrap currency operations in try-catch
3. **Offline Indicators**: Show users when using cached/offline data
4. **Format Consistently**: Use the service's formatting methods for consistency
5. **Validate Input**: Check currency support before operations
6. **Update Regularly**: Refresh exchange rates periodically

## Common Patterns

### Currency Selector Widget
```dart
// Get popular currencies for dropdown/selector
final popularCurrencies = await currencyService.getPopularCurrencies();
final currencyItems = popularCurrencies.map((currency) => 
  DropdownMenuItem(
    value: currency.code,
    child: Text('${currency.symbol} ${currency.code} - ${currency.name}'),
  ),
).toList();
```

### Amount Input with Formatting
```dart
// Format user input as they type
Future<String> formatAmountInput(String input, String currencyCode) async {
  final amount = double.tryParse(input.replaceAll(',', ''));
  if (amount != null) {
    return await currencyService.formatAmount(
      amount: amount,
      currencyCode: currencyCode,
    );
  }
  return input;
}
```

### Multi-Currency Balance Display
```dart
// Show balances in user's preferred currency
final accounts = await accountRepository.getAllAccounts();
for (final account in accounts) {
  final convertedBalance = await currencyService.convertAmount(
    amount: account.balance,
    fromCurrency: account.currency,
    toCurrency: userPreferredCurrency,
  );
  
  final formatted = await currencyService.formatAmount(
    amount: convertedBalance,
    currencyCode: userPreferredCurrency,
  );
  
  print('${account.name}: $formatted');
}
```

