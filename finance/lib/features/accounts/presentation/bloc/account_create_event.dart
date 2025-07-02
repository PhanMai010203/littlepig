import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../currencies/domain/entities/currency.dart';

/// Events for the account creation flow
abstract class AccountCreateEvent extends Equatable {
  const AccountCreateEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the account creation form with default values
class LoadInitialAccountData extends AccountCreateEvent {
  const LoadInitialAccountData();
}

/// Update the account name
class UpdateAccountName extends AccountCreateEvent {
  final String name;

  const UpdateAccountName(this.name);

  @override
  List<Object?> get props => [name];
}

/// Update the beginning balance
class UpdateAccountBalance extends AccountCreateEvent {
  final double balance;

  const UpdateAccountBalance(this.balance);

  @override
  List<Object?> get props => [balance];
}

/// Update the selected currency
class UpdateAccountCurrency extends AccountCreateEvent {
  final Currency currency;

  const UpdateAccountCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

/// Update the selected color
class UpdateAccountColor extends AccountCreateEvent {
  final Color color;

  const UpdateAccountColor(this.color);

  @override
  List<Object?> get props => [color];
}

/// Load available currencies for selection
class LoadAvailableCurrencies extends AccountCreateEvent {
  const LoadAvailableCurrencies();
}

/// Create the account with current form data
class CreateAccount extends AccountCreateEvent {
  const CreateAccount();
}

/// Reset the form to initial state
class ResetAccountForm extends AccountCreateEvent {
  const ResetAccountForm();
}