import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final int? id;
  final String name;
  final double balance;
  final String currency;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final bool isSynced;
  final DateTime? lastSyncAt;
  final String syncId;
  final int version;

  const Account({
    this.id,
    required this.name,
    required this.balance,
    required this.currency,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    required this.isSynced,
    this.lastSyncAt,
    required this.syncId,
    required this.version,
  });

  Account copyWith({
    int? id,
    String? name,
    double? balance,
    String? currency,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deviceId,
    bool? isSynced,
    DateTime? lastSyncAt,
    String? syncId,
    int? version,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncId: syncId ?? this.syncId,
      version: version ?? this.version,
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
        deviceId,
        isSynced,
        lastSyncAt,
        syncId,
        version,
      ];
}
