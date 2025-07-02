import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../../../currencies/domain/entities/currency.dart';
import '../../../../services/currency_service.dart';
import 'account_create_event.dart';
import 'account_create_state.dart';

/// BLoC for managing account creation flow
@injectable
class AccountCreateBloc extends Bloc<AccountCreateEvent, AccountCreateState> {
  final AccountRepository _accountRepository;
  final CurrencyService _currencyService;

  // Default account colors (same as budget create page)
  static const List<Color> defaultColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF795548), // Brown
    Color(0xFF009688), // Teal
    Color(0xFFF44336), // Red
  ];

  AccountCreateBloc(
    this._accountRepository,
    this._currencyService,
  ) : super(const AccountCreateLoading()) {
    on<LoadInitialAccountData>(_onLoadInitialData);
    on<UpdateAccountName>(_onUpdateName);
    on<UpdateAccountBalance>(_onUpdateBalance);
    on<UpdateAccountCurrency>(_onUpdateCurrency);
    on<UpdateAccountColor>(_onUpdateColor);
    on<LoadAvailableCurrencies>(_onLoadCurrencies);
    on<CreateAccount>(_onCreateAccount);
    on<ResetAccountForm>(_onResetForm);
  }

  Future<void> _onLoadInitialData(
    LoadInitialAccountData event,
    Emitter<AccountCreateState> emit,
  ) async {
    try {
      emit(const AccountCreateLoading());

      // Load popular currencies
      final currencies = await _currencyService.getPopularCurrencies();
      
      // Set USD as default, fallback to first currency
      Currency? defaultCurrency;
      try {
        defaultCurrency = currencies.firstWhere((c) => c.code == 'USD');
      } catch (e) {
        defaultCurrency = currencies.isNotEmpty ? currencies.first : null;
      }

      // If no USD found and no currencies available, create a mock USD currency
      defaultCurrency ??= const Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
      );

      emit(AccountCreateLoaded(
        selectedColor: defaultColors.first,
        availableCurrencies: currencies,
        selectedCurrency: defaultCurrency,
        nextRequiredField: 'name',
      ));
    } catch (e) {
      emit(AccountCreateError('Failed to load initial data: ${e.toString()}'));
    }
  }

  void _onUpdateName(
    UpdateAccountName event,
    Emitter<AccountCreateState> emit,
  ) {
    if (state is AccountCreateLoaded) {
      final currentState = state as AccountCreateLoaded;
      final validationErrors = Map<String, String>.from(currentState.validationErrors);
      
      // Clear name validation error if name is provided
      if (event.name.isNotEmpty) {
        validationErrors.remove('name');
      } else {
        validationErrors['name'] = 'Account name is required';
      }

      // Calculate next required field
      final nextRequiredField = event.name.isEmpty ? 'name' : null;

      emit(currentState.copyWith(
        name: event.name,
        validationErrors: validationErrors,
        nextRequiredField: nextRequiredField,
      ));
    }
  }

  void _onUpdateBalance(
    UpdateAccountBalance event,
    Emitter<AccountCreateState> emit,
  ) {
    if (state is AccountCreateLoaded) {
      final currentState = state as AccountCreateLoaded;
      emit(currentState.copyWith(balance: event.balance));
    }
  }

  void _onUpdateCurrency(
    UpdateAccountCurrency event,
    Emitter<AccountCreateState> emit,
  ) {
    if (state is AccountCreateLoaded) {
      final currentState = state as AccountCreateLoaded;
      final validationErrors = Map<String, String>.from(currentState.validationErrors);
      
      // Clear currency validation error
      validationErrors.remove('currency');

      emit(currentState.copyWith(
        selectedCurrency: event.currency,
        validationErrors: validationErrors,
      ));
    }
  }

  void _onUpdateColor(
    UpdateAccountColor event,
    Emitter<AccountCreateState> emit,
  ) {
    if (state is AccountCreateLoaded) {
      final currentState = state as AccountCreateLoaded;
      emit(currentState.copyWith(selectedColor: event.color));
    }
  }

  Future<void> _onLoadCurrencies(
    LoadAvailableCurrencies event,
    Emitter<AccountCreateState> emit,
  ) async {
    if (state is AccountCreateLoaded) {
      final currentState = state as AccountCreateLoaded;
      emit(currentState.copyWith(isCurrenciesLoading: true));

      try {
        final currencies = await _currencyService.getPopularCurrencies();
        emit(currentState.copyWith(
          availableCurrencies: currencies,
          isCurrenciesLoading: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isCurrenciesLoading: false));
        emit(AccountCreateError('Failed to load currencies: ${e.toString()}'));
      }
    }
  }

  Future<void> _onCreateAccount(
    CreateAccount event,
    Emitter<AccountCreateState> emit,
  ) async {
    debugPrint('🚀 Starting account creation...');
    
    if (state is AccountCreateLoaded) {
      final currentState = state as AccountCreateLoaded;
      debugPrint('Current state: name="${currentState.name}", balance=${currentState.balance}, currency=${currentState.selectedCurrency?.code}');

      // Validate form - only name is required
      final validationErrors = <String, String>{};
      if (currentState.name.isEmpty) {
        validationErrors['name'] = 'Account name is required';
      }

      if (validationErrors.isNotEmpty) {
        debugPrint('❌ Validation failed: $validationErrors');
        emit(currentState.copyWith(validationErrors: validationErrors));
        return;
      }

      debugPrint('✅ Validation passed, setting isCreating to true');
      emit(currentState.copyWith(isCreating: true));

      try {
        // Create account entity
        final now = DateTime.now();
        final syncId = now.millisecondsSinceEpoch.toString();
        
        final account = Account(
          name: currentState.name.trim(),
          balance: currentState.balance,
          currency: currentState.selectedCurrency?.code ?? 'USD', // Default to USD
          isDefault: false, // Will be handled by repository if it's the first account
          createdAt: now,
          updatedAt: now,
          syncId: syncId,
          color: currentState.selectedColor,
        );

        debugPrint('💾 Creating account: ${account.name} with ${account.currency} ${account.balance}');

        // Save account
        final createdAccount = await _accountRepository.createAccount(account);
        debugPrint('✅ Account created successfully: ${createdAccount.id}');
        
        // Add a small delay to ensure UI state is stable before navigation
        await Future.delayed(const Duration(milliseconds: 100));
        
        emit(AccountCreateSuccess(
          message: 'Account "${createdAccount.name}" created successfully',
          accountName: createdAccount.name,
        ));
        debugPrint('🎉 Success state emitted');
      } catch (e, stackTrace) {
        debugPrint('❌ Account creation failed: $e');
        debugPrint('Stack trace: $stackTrace');
        emit(currentState.copyWith(isCreating: false));
        emit(AccountCreateError('Failed to create account: ${e.toString()}'));
      }
    } else {
      debugPrint('❌ Invalid state: ${state.runtimeType}');
    }
  }

  void _onResetForm(
    ResetAccountForm event,
    Emitter<AccountCreateState> emit,
  ) {
    add(const LoadInitialAccountData());
  }
}