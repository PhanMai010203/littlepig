import 'package:equatable/equatable.dart';

enum BudgetPeriod { daily, weekly, monthly, yearly }

class Budget extends Equatable {
  final int? id;
  final String name;
  final double amount;
  final double spent;
  final int? categoryId;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final bool isSynced;
  final DateTime? lastSyncAt;
  final String syncId;
  final int version;

  const Budget({
    this.id,
    required this.name,
    required this.amount,
    required this.spent,
    this.categoryId,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    required this.isSynced,
    this.lastSyncAt,
    required this.syncId,
    required this.version,
  });

  Budget copyWith({
    int? id,
    String? name,
    double? amount,
    double? spent,
    int? categoryId,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deviceId,
    bool? isSynced,
    DateTime? lastSyncAt,
    String? syncId,
    int? version,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      categoryId: categoryId ?? this.categoryId,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncId: syncId ?? this.syncId,
      version: version ?? this.version,
    );
  }

  double get remaining => amount - spent;
  double get percentageSpent => spent / amount;
  bool get isOverBudget => spent > amount;

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        spent,
        categoryId,
        period,
        startDate,
        endDate,
        isActive,
        createdAt,
        updatedAt,
        deviceId,
        isSynced,
        lastSyncAt,
        syncId,
        version,
      ];
}
