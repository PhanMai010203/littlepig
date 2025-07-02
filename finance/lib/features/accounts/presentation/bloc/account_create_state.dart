import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../currencies/domain/entities/currency.dart';

/// Base state for account creation
abstract class AccountCreateState extends Equatable {
  const AccountCreateState();

  @override
  List<Object?> get props => [];
}

/// Initial loading state
class AccountCreateLoading extends AccountCreateState {
  const AccountCreateLoading();
}

/// Error state with message
class AccountCreateError extends AccountCreateState {
  final String message;

  const AccountCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Main loaded state with form data
class AccountCreateLoaded extends AccountCreateState {
  final String name;
  final double balance;
  final Currency? selectedCurrency;
  final Color selectedColor;
  final List<Currency> availableCurrencies;
  final bool isCurrenciesLoading;
  final bool isCreating;
  final Map<String, String> validationErrors;
  final String? nextRequiredField;

  const AccountCreateLoaded({
    this.name = '',
    this.balance = 0.0,
    this.selectedCurrency,
    required this.selectedColor,
    this.availableCurrencies = const [],
    this.isCurrenciesLoading = false,
    this.isCreating = false,
    this.validationErrors = const {},
    this.nextRequiredField,
  });

  /// Check if the form is valid for submission
  bool get isValid {
    return name.isNotEmpty && validationErrors.isEmpty;
  }


  AccountCreateLoaded copyWith({
    String? name,
    double? balance,
    Currency? selectedCurrency,
    Color? selectedColor,
    List<Currency>? availableCurrencies,
    bool? isCurrenciesLoading,
    bool? isCreating,
    Map<String, String>? validationErrors,
    String? nextRequiredField,
  }) {
    return AccountCreateLoaded(
      name: name ?? this.name,
      balance: balance ?? this.balance,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      selectedColor: selectedColor ?? this.selectedColor,
      availableCurrencies: availableCurrencies ?? this.availableCurrencies,
      isCurrenciesLoading: isCurrenciesLoading ?? this.isCurrenciesLoading,
      isCreating: isCreating ?? this.isCreating,
      validationErrors: validationErrors ?? this.validationErrors,
      nextRequiredField: nextRequiredField,
    );
  }

  @override
  List<Object?> get props => [
        name,
        balance,
        selectedCurrency,
        selectedColor,
        availableCurrencies,
        isCurrenciesLoading,
        isCreating,
        validationErrors,
        nextRequiredField,
      ];
}

/// Success state after account creation
class AccountCreateSuccess extends AccountCreateState {
  final String message;
  final String accountName;

  const AccountCreateSuccess({
    required this.message,
    required this.accountName,
  });

  @override
  List<Object?> get props => [message, accountName];
}