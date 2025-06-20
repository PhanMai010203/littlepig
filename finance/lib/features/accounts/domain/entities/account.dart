import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Account extends Equatable {
  final int? id;
  final String name;
  final double balance;
  final String currency;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncId;
  final Color color;

  const Account({
    this.id,
    required this.name,
    required this.balance,
    required this.currency,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    required this.syncId,
    required this.color,
  });

  Account copyWith({
    int? id,
    String? name,
    double? balance,
    String? currency,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncId,
    Color? color,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncId: syncId ?? this.syncId,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        balance,
        currency,
        isDefault,
        createdAt,
        updatedAt,
        syncId,
        color,
      ];
}
