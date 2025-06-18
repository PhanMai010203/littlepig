import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final int? id;
  final String name;
  final String icon;
  final Color color;
  final bool isExpense;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncId;

  const Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isExpense,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    required this.syncId,
  });

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    Color? color,
    bool? isExpense,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isExpense: isExpense ?? this.isExpense,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncId: syncId ?? this.syncId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        color,
        isExpense,
        isDefault,
        createdAt,
        updatedAt,
        syncId,
      ];
}
