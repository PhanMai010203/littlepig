import '../entities/currency.dart';
import '../repositories/currency_repository.dart';

/// Use case for getting all currencies
class GetAllCurrencies {
  final CurrencyRepository _repository;

  GetAllCurrencies(this._repository);

  Future<List<Currency>> call() async {
    return await _repository.getAllCurrencies();
  }
}

/// Use case for getting popular currencies
class GetPopularCurrencies {
  final CurrencyRepository _repository;

  GetPopularCurrencies(this._repository);

  Future<List<Currency>> call() async {
    return await _repository.getPopularCurrencies();
  }
}

/// Use case for searching currencies
class SearchCurrencies {
  final CurrencyRepository _repository;

  SearchCurrencies(this._repository);

  Future<List<Currency>> call(String query) async {
    if (query.trim().isEmpty) {
      return await _repository.getPopularCurrencies();
    }
    return await _repository.searchCurrencies(query);
  }
}
