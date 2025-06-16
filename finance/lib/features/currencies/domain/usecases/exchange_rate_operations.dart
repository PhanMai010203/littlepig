import '../entities/exchange_rate.dart';
import '../repositories/currency_repository.dart';

/// Use case for converting currency amounts
class ConvertCurrency {
  final CurrencyRepository _repository;

  ConvertCurrency(this._repository);

  Future<double> call({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    // If converting to same currency, return original amount
    if (fromCurrency.toUpperCase() == toCurrency.toUpperCase()) {
      return amount;
    }

    return await _repository.convertAmount(
      amount: amount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );
  }
}

/// Use case for getting exchange rates
class GetExchangeRates {
  final CurrencyRepository _repository;

  GetExchangeRates(this._repository);

  Future<Map<String, ExchangeRate>> call() async {
    return await _repository.getExchangeRates();
  }
}

/// Use case for setting custom exchange rate
class SetCustomExchangeRate {
  final CurrencyRepository _repository;

  SetCustomExchangeRate(this._repository);

  Future<void> call({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
  }) async {
    if (rate <= 0) {
      throw ArgumentError('Exchange rate must be positive');
    }

    await _repository.setCustomExchangeRate(fromCurrency, toCurrency, rate);
  }
}

/// Use case for refreshing exchange rates
class RefreshExchangeRates {
  final CurrencyRepository _repository;

  RefreshExchangeRates(this._repository);

  Future<bool> call() async {
    return await _repository.refreshExchangeRates();
  }
}
