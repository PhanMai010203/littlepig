import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final String? note;
  final double amount;
  final int categoryId;
  final int accountId;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final bool isSynced;
  final DateTime? lastSyncAt;
  final String syncId;
  final int version;

  const Transaction({
    this.id,
    required this.title,
    this.description,
    this.note,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    required this.isSynced,
    this.lastSyncAt,
    required this.syncId,
    required this.version,
  });

  Transaction copyWith({
    int? id,
    String? title,
    String? description,
    String? note,
    double? amount,
    int? categoryId,
    int? accountId,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deviceId,
    bool? isSynced,
    DateTime? lastSyncAt,
    String? syncId,
    int? version,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncId: syncId ?? this.syncId,
      version: version ?? this.version,
    );
  }

  bool get isIncome => amount > 0;
  bool get isExpense => amount < 0;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        note,
        amount,
        categoryId,
        accountId,
        date,
        createdAt,
        updatedAt,
        deviceId,
        isSynced,
        lastSyncAt,
        syncId,
        version,
      ];
}
