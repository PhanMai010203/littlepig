import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../services/currency_service.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';

part 'currency_display_event.dart';
part 'currency_display_state.dart';
part 'currency_display_bloc.freezed.dart';

/// BLoC for managing global currency display state
/// 
/// This manages which currency all financial amounts should be displayed in
/// across the app. When user switches accounts, this updates the display
/// currency and triggers UI updates with converted amounts.
@lazySingleton
class CurrencyDisplayBloc extends Bloc<CurrencyDisplayEvent, CurrencyDisplayState> {
  final CurrencyService _currencyService;
  final CurrencyRepository _currencyRepository;
  final AccountRepository _accountRepository;

  CurrencyDisplayBloc(
    this._currencyService,
    this._currencyRepository,
    this._accountRepository,
  ) : super(CurrencyDisplayStateX.initial) {
    on<_AccountCurrencyChanged>(_onAccountCurrencyChanged);
    on<_DisplayCurrencyChanged>(_onDisplayCurrencyChanged);
    on<_RefreshExchangeRates>(_onRefreshExchangeRates);
    on<_Initialize>(_onInitialize);
  }

  /// Handle account currency change (when user selects different account)
  Future<void> _onAccountCurrencyChanged(
    _AccountCurrencyChanged event,
    Emitter<CurrencyDisplayState> emit,
  ) async {
    print('💱 CurrencyDisplayBloc - Account currency changed: ${event.accountCurrency}, accountId: ${event.accountId}');
    print('💱 Current state before change - displayCurrency: ${state.displayCurrency}, selectedAccountId: ${state.selectedAccountId}');
    await _updateDisplayCurrency(
      event.accountCurrency,
      emit,
      selectedAccountId: event.accountId,
    );
    print('💱 State after change - displayCurrency: ${state.displayCurrency}, selectedAccountId: ${state.selectedAccountId}');
  }

  /// Handle manual display currency change
  Future<void> _onDisplayCurrencyChanged(
    _DisplayCurrencyChanged event,
    Emitter<CurrencyDisplayState> emit,
  ) async {
    await _updateDisplayCurrency(event.displayCurrency, emit);
  }

  /// Handle exchange rate refresh
  Future<void> _onRefreshExchangeRates(
    _RefreshExchangeRates event,
    Emitter<CurrencyDisplayState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    try {
      // Refresh exchange rates from remote
      await _currencyRepository.refreshExchangeRates();
      
      // Rebuild cache with fresh rates
      await _updateConversionCache(state.displayCurrency, emit);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh exchange rates: ${e.toString()}',
      ));
    }
  }

  /// Handle initialization with optional initial currency
  Future<void> _onInitialize(
    _Initialize event,
    Emitter<CurrencyDisplayState> emit,
  ) async {
    String initialCurrency = event.initialCurrency ?? 'USD';
    
    // Try to get the selected account's currency first, then fallback to first account
    if (event.initialCurrency == null) {
      try {
        final accounts = await _accountRepository.getAllAccounts();
        if (accounts.isNotEmpty) {
          // Check if there's a default/selected account
          final selectedAccount = accounts.firstWhere(
            (account) => account.isDefault,
            orElse: () => accounts.first,
          );
          initialCurrency = selectedAccount.currency;
          print('💱 CurrencyDisplayBloc initialized with currency: $initialCurrency from account: ${selectedAccount.name}');
        }
      } catch (e) {
        // Fallback to USD if we can't get accounts
        print('💱 CurrencyDisplayBloc initialization failed, using USD: $e');
        initialCurrency = 'USD';
      }
    }
    
    await _updateDisplayCurrency(initialCurrency, emit);
  }

  /// Core method to update display currency and refresh conversion cache
  Future<void> _updateDisplayCurrency(
    String newCurrency,
    Emitter<CurrencyDisplayState> emit, {
    String? selectedAccountId,
  }) async {
    print('💱 _updateDisplayCurrency called: newCurrency=$newCurrency, selectedAccountId=$selectedAccountId');
    print('💱 Current state: displayCurrency=${state.displayCurrency}, selectedAccountId=${state.selectedAccountId}');
    
    if (newCurrency == state.displayCurrency && selectedAccountId == state.selectedAccountId) {
      print('💱 No change needed, returning early');
      return; // No change needed
    }

    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      displayCurrency: newCurrency,
      selectedAccountId: selectedAccountId ?? state.selectedAccountId,
    ));
    print('💱 Currency display state updated to: $newCurrency');

    await _updateConversionCache(newCurrency, emit);
  }

  /// Update the conversion rates cache for the new display currency
  Future<void> _updateConversionCache(
    String displayCurrency,
    Emitter<CurrencyDisplayState> emit,
  ) async {
    try {
      // Get all exchange rates
      final exchangeRates = await _currencyRepository.getExchangeRates();
      
      // Build conversion rates cache
      final conversionRatesCache = <String, double>{};
      
      for (final entry in exchangeRates.entries) {
        final targetCurrency = entry.key;
        final rate = entry.value;
        
        if (displayCurrency == 'USD') {
          // Display currency is USD, so rate is direct
          conversionRatesCache[targetCurrency] = 1.0 / rate.rate;
        } else if (targetCurrency == displayCurrency) {
          // We have direct rate to display currency
          conversionRatesCache['USD'] = rate.rate;
        } else {
          // Convert via USD: source -> USD -> display
          final usdToDisplay = exchangeRates[displayCurrency];
          if (usdToDisplay != null) {
            conversionRatesCache[targetCurrency] = (1.0 / rate.rate) * usdToDisplay.rate;
          }
        }
      }
      
      // Ensure same currency has rate of 1.0
      conversionRatesCache[displayCurrency] = 1.0;

      emit(state.copyWith(
        isLoading: false,
        conversionRatesCache: conversionRatesCache,
        lastRateUpdate: DateTime.now(),
        errorMessage: null,
      ));
      print('💱 Conversion cache updated for $displayCurrency - cache size: ${conversionRatesCache.length}');
      print('💱 Sample rates: ${conversionRatesCache.entries.take(3).map((e) => '${e.key}: ${e.value}').join(', ')}');
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update conversion rates: ${e.toString()}',
      ));
    }
  }

  /// Get converted amount from any currency to display currency
  double convertToDisplayCurrency(double amount, String fromCurrency) {
    if (fromCurrency == state.displayCurrency) return amount;
    
    final rate = state.getConversionRate(fromCurrency);
    if (rate == null) return amount; // Fallback to original amount
    
    return amount * rate;
  }

  /// Format amount in display currency
  Future<String> formatInDisplayCurrency(
    double amount,
    String fromCurrency, {
    bool showSymbol = true,
    bool showCode = false,
    bool compact = false,
  }) async {
    print('💱 formatInDisplayCurrency called: amount=$amount, fromCurrency=$fromCurrency, displayCurrency=${state.displayCurrency}');
    final convertedAmount = convertToDisplayCurrency(amount, fromCurrency);
    print('💱 Converted amount: $convertedAmount');
    
    final formatted = await _currencyService.formatAmount(
      amount: convertedAmount,
      currencyCode: state.displayCurrency,
      showSymbol: showSymbol,
      showCode: showCode,
      compact: compact,
    );
    print('💱 Formatted result: $formatted');
    return formatted;
  }
}
