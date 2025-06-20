// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTableTable extends CategoriesTable
    with TableInfo<$CategoriesTableTable, CategoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isExpenseMeta =
      const VerificationMeta('isExpense');
  @override
  late final GeneratedColumn<bool> isExpense = GeneratedColumn<bool>(
      'is_expense', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_expense" IN (0, 1))'));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        icon,
        color,
        isExpense,
        isDefault,
        createdAt,
        updatedAt,
        syncId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
      Insertable<CategoriesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_expense')) {
      context.handle(_isExpenseMeta,
          isExpense.isAcceptableOrUnknown(data['is_expense']!, _isExpenseMeta));
    } else if (isInserting) {
      context.missing(_isExpenseMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      isExpense: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_expense'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
    );
  }

  @override
  $CategoriesTableTable createAlias(String alias) {
    return $CategoriesTableTable(attachedDatabase, alias);
  }
}

class CategoriesTableData extends DataClass
    implements Insertable<CategoriesTableData> {
  final int id;
  final String name;
  final String icon;
  final int color;
  final bool isExpense;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncId;
  const CategoriesTableData(
      {required this.id,
      required this.name,
      required this.icon,
      required this.color,
      required this.isExpense,
      required this.isDefault,
      required this.createdAt,
      required this.updatedAt,
      required this.syncId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    map['is_expense'] = Variable<bool>(isExpense);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_id'] = Variable<String>(syncId);
    return map;
  }

  CategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      isExpense: Value(isExpense),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncId: Value(syncId),
    );
  }

  factory CategoriesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriesTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      isExpense: serializer.fromJson<bool>(json['isExpense']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncId: serializer.fromJson<String>(json['syncId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'isExpense': serializer.toJson<bool>(isExpense),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncId': serializer.toJson<String>(syncId),
    };
  }

  CategoriesTableData copyWith(
          {int? id,
          String? name,
          String? icon,
          int? color,
          bool? isExpense,
          bool? isDefault,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncId}) =>
      CategoriesTableData(
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
  CategoriesTableData copyWithCompanion(CategoriesTableCompanion data) {
    return CategoriesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isExpense: data.isExpense.present ? data.isExpense.value : this.isExpense,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isExpense: $isExpense, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncId: $syncId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, color, isExpense, isDefault,
      createdAt, updatedAt, syncId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isExpense == this.isExpense &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncId == this.syncId);
}

class CategoriesTableCompanion extends UpdateCompanion<CategoriesTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> color;
  final Value<bool> isExpense;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncId;
  const CategoriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncId = const Value.absent(),
  });
  CategoriesTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String icon,
    required int color,
    required bool isExpense,
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String syncId,
  })  : name = Value(name),
        icon = Value(icon),
        color = Value(color),
        isExpense = Value(isExpense),
        syncId = Value(syncId);
  static Insertable<CategoriesTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<bool>? isExpense,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isExpense != null) 'is_expense': isExpense,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncId != null) 'sync_id': syncId,
    });
  }

  CategoriesTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? icon,
      Value<int>? color,
      Value<bool>? isExpense,
      Value<bool>? isDefault,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncId}) {
    return CategoriesTableCompanion(
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
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isExpense.present) {
      map['is_expense'] = Variable<bool>(isExpense.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isExpense: $isExpense, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncId: $syncId')
          ..write(')'))
        .toString();
  }
}

class $AccountsTableTable extends AccountsTable
    with TableInfo<$AccountsTableTable, AccountsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
      'balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 3),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USD'));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFF9E9E9E));
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        balance,
        currency,
        isDefault,
        createdAt,
        updatedAt,
        color,
        syncId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<AccountsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
    );
  }

  @override
  $AccountsTableTable createAlias(String alias) {
    return $AccountsTableTable(attachedDatabase, alias);
  }
}

class AccountsTableData extends DataClass
    implements Insertable<AccountsTableData> {
  final int id;
  final String name;
  final double balance;
  final String currency;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int color;
  final String syncId;
  const AccountsTableData(
      {required this.id,
      required this.name,
      required this.balance,
      required this.currency,
      required this.isDefault,
      required this.createdAt,
      required this.updatedAt,
      required this.color,
      required this.syncId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['balance'] = Variable<double>(balance);
    map['currency'] = Variable<String>(currency);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['color'] = Variable<int>(color);
    map['sync_id'] = Variable<String>(syncId);
    return map;
  }

  AccountsTableCompanion toCompanion(bool nullToAbsent) {
    return AccountsTableCompanion(
      id: Value(id),
      name: Value(name),
      balance: Value(balance),
      currency: Value(currency),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      color: Value(color),
      syncId: Value(syncId),
    );
  }

  factory AccountsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountsTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      balance: serializer.fromJson<double>(json['balance']),
      currency: serializer.fromJson<String>(json['currency']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      color: serializer.fromJson<int>(json['color']),
      syncId: serializer.fromJson<String>(json['syncId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'balance': serializer.toJson<double>(balance),
      'currency': serializer.toJson<String>(currency),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'color': serializer.toJson<int>(color),
      'syncId': serializer.toJson<String>(syncId),
    };
  }

  AccountsTableData copyWith(
          {int? id,
          String? name,
          double? balance,
          String? currency,
          bool? isDefault,
          DateTime? createdAt,
          DateTime? updatedAt,
          int? color,
          String? syncId}) =>
      AccountsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        currency: currency ?? this.currency,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        color: color ?? this.color,
        syncId: syncId ?? this.syncId,
      );
  AccountsTableData copyWithCompanion(AccountsTableCompanion data) {
    return AccountsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      balance: data.balance.present ? data.balance.value : this.balance,
      currency: data.currency.present ? data.currency.value : this.currency,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      color: data.color.present ? data.color.value : this.color,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('color: $color, ')
          ..write('syncId: $syncId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, balance, currency, isDefault,
      createdAt, updatedAt, color, syncId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.balance == this.balance &&
          other.currency == this.currency &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.color == this.color &&
          other.syncId == this.syncId);
}

class AccountsTableCompanion extends UpdateCompanion<AccountsTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> balance;
  final Value<String> currency;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> color;
  final Value<String> syncId;
  const AccountsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.balance = const Value.absent(),
    this.currency = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.color = const Value.absent(),
    this.syncId = const Value.absent(),
  });
  AccountsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.balance = const Value.absent(),
    this.currency = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.color = const Value.absent(),
    required String syncId,
  })  : name = Value(name),
        syncId = Value(syncId);
  static Insertable<AccountsTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? balance,
    Expression<String>? currency,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? color,
    Expression<String>? syncId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (balance != null) 'balance': balance,
      if (currency != null) 'currency': currency,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (color != null) 'color': color,
      if (syncId != null) 'sync_id': syncId,
    });
  }

  AccountsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? balance,
      Value<String>? currency,
      Value<bool>? isDefault,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? color,
      Value<String>? syncId}) {
    return AccountsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      syncId: syncId ?? this.syncId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('color: $color, ')
          ..write('syncId: $syncId')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _transactionTypeMeta =
      const VerificationMeta('transactionType');
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
      'transaction_type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('expense'));
  static const VerificationMeta _specialTypeMeta =
      const VerificationMeta('specialType');
  @override
  late final GeneratedColumn<String> specialType = GeneratedColumn<String>(
      'special_type', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _recurrenceMeta =
      const VerificationMeta('recurrence');
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
      'recurrence', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _periodLengthMeta =
      const VerificationMeta('periodLength');
  @override
  late final GeneratedColumn<int> periodLength = GeneratedColumn<int>(
      'period_length', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _originalDateDueMeta =
      const VerificationMeta('originalDateDue');
  @override
  late final GeneratedColumn<DateTime> originalDateDue =
      GeneratedColumn<DateTime>('original_date_due', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _transactionStateMeta =
      const VerificationMeta('transactionState');
  @override
  late final GeneratedColumn<String> transactionState = GeneratedColumn<String>(
      'transaction_state', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('completed'));
  static const VerificationMeta _paidMeta = const VerificationMeta('paid');
  @override
  late final GeneratedColumn<bool> paid = GeneratedColumn<bool>(
      'paid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("paid" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _skipPaidMeta =
      const VerificationMeta('skipPaid');
  @override
  late final GeneratedColumn<bool> skipPaid = GeneratedColumn<bool>(
      'skip_paid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("skip_paid" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAnotherFutureTransactionMeta =
      const VerificationMeta('createdAnotherFutureTransaction');
  @override
  late final GeneratedColumn<bool> createdAnotherFutureTransaction =
      GeneratedColumn<bool>(
          'created_another_future_transaction', aliasedName, true,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("created_another_future_transaction" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _objectiveLoanFkMeta =
      const VerificationMeta('objectiveLoanFk');
  @override
  late final GeneratedColumn<String> objectiveLoanFk = GeneratedColumn<String>(
      'objective_loan_fk', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _remainingAmountMeta =
      const VerificationMeta('remainingAmount');
  @override
  late final GeneratedColumn<double> remainingAmount = GeneratedColumn<double>(
      'remaining_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _parentTransactionIdMeta =
      const VerificationMeta('parentTransactionId');
  @override
  late final GeneratedColumn<int> parentTransactionId = GeneratedColumn<int>(
      'parent_transaction_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        note,
        amount,
        categoryId,
        accountId,
        date,
        createdAt,
        updatedAt,
        transactionType,
        specialType,
        recurrence,
        periodLength,
        endDate,
        originalDateDue,
        transactionState,
        paid,
        skipPaid,
        createdAnotherFutureTransaction,
        objectiveLoanFk,
        syncId,
        remainingAmount,
        parentTransactionId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
          _transactionTypeMeta,
          transactionType.isAcceptableOrUnknown(
              data['transaction_type']!, _transactionTypeMeta));
    }
    if (data.containsKey('special_type')) {
      context.handle(
          _specialTypeMeta,
          specialType.isAcceptableOrUnknown(
              data['special_type']!, _specialTypeMeta));
    }
    if (data.containsKey('recurrence')) {
      context.handle(
          _recurrenceMeta,
          recurrence.isAcceptableOrUnknown(
              data['recurrence']!, _recurrenceMeta));
    }
    if (data.containsKey('period_length')) {
      context.handle(
          _periodLengthMeta,
          periodLength.isAcceptableOrUnknown(
              data['period_length']!, _periodLengthMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('original_date_due')) {
      context.handle(
          _originalDateDueMeta,
          originalDateDue.isAcceptableOrUnknown(
              data['original_date_due']!, _originalDateDueMeta));
    }
    if (data.containsKey('transaction_state')) {
      context.handle(
          _transactionStateMeta,
          transactionState.isAcceptableOrUnknown(
              data['transaction_state']!, _transactionStateMeta));
    }
    if (data.containsKey('paid')) {
      context.handle(
          _paidMeta, paid.isAcceptableOrUnknown(data['paid']!, _paidMeta));
    }
    if (data.containsKey('skip_paid')) {
      context.handle(_skipPaidMeta,
          skipPaid.isAcceptableOrUnknown(data['skip_paid']!, _skipPaidMeta));
    }
    if (data.containsKey('created_another_future_transaction')) {
      context.handle(
          _createdAnotherFutureTransactionMeta,
          createdAnotherFutureTransaction.isAcceptableOrUnknown(
              data['created_another_future_transaction']!,
              _createdAnotherFutureTransactionMeta));
    }
    if (data.containsKey('objective_loan_fk')) {
      context.handle(
          _objectiveLoanFkMeta,
          objectiveLoanFk.isAcceptableOrUnknown(
              data['objective_loan_fk']!, _objectiveLoanFkMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('remaining_amount')) {
      context.handle(
          _remainingAmountMeta,
          remainingAmount.isAcceptableOrUnknown(
              data['remaining_amount']!, _remainingAmountMeta));
    }
    if (data.containsKey('parent_transaction_id')) {
      context.handle(
          _parentTransactionIdMeta,
          parentTransactionId.isAcceptableOrUnknown(
              data['parent_transaction_id']!, _parentTransactionIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      transactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_type'])!,
      specialType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}special_type']),
      recurrence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence'])!,
      periodLength: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_length']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      originalDateDue: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}original_date_due']),
      transactionState: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_state'])!,
      paid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}paid'])!,
      skipPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}skip_paid'])!,
      createdAnotherFutureTransaction: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}created_another_future_transaction']),
      objectiveLoanFk: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}objective_loan_fk']),
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
      remainingAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}remaining_amount']),
      parentTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}parent_transaction_id']),
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }
}

class TransactionsTableData extends DataClass
    implements Insertable<TransactionsTableData> {
  final int id;
  final String title;
  final String? note;
  final double amount;
  final int categoryId;
  final int accountId;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String transactionType;
  final String? specialType;
  final String recurrence;
  final int? periodLength;
  final DateTime? endDate;
  final DateTime? originalDateDue;
  final String transactionState;
  final bool paid;
  final bool skipPaid;
  final bool? createdAnotherFutureTransaction;
  final String? objectiveLoanFk;
  final String syncId;
  final double? remainingAmount;
  final int? parentTransactionId;
  const TransactionsTableData(
      {required this.id,
      required this.title,
      this.note,
      required this.amount,
      required this.categoryId,
      required this.accountId,
      required this.date,
      required this.createdAt,
      required this.updatedAt,
      required this.transactionType,
      this.specialType,
      required this.recurrence,
      this.periodLength,
      this.endDate,
      this.originalDateDue,
      required this.transactionState,
      required this.paid,
      required this.skipPaid,
      this.createdAnotherFutureTransaction,
      this.objectiveLoanFk,
      required this.syncId,
      this.remainingAmount,
      this.parentTransactionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['amount'] = Variable<double>(amount);
    map['category_id'] = Variable<int>(categoryId);
    map['account_id'] = Variable<int>(accountId);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['transaction_type'] = Variable<String>(transactionType);
    if (!nullToAbsent || specialType != null) {
      map['special_type'] = Variable<String>(specialType);
    }
    map['recurrence'] = Variable<String>(recurrence);
    if (!nullToAbsent || periodLength != null) {
      map['period_length'] = Variable<int>(periodLength);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || originalDateDue != null) {
      map['original_date_due'] = Variable<DateTime>(originalDateDue);
    }
    map['transaction_state'] = Variable<String>(transactionState);
    map['paid'] = Variable<bool>(paid);
    map['skip_paid'] = Variable<bool>(skipPaid);
    if (!nullToAbsent || createdAnotherFutureTransaction != null) {
      map['created_another_future_transaction'] =
          Variable<bool>(createdAnotherFutureTransaction);
    }
    if (!nullToAbsent || objectiveLoanFk != null) {
      map['objective_loan_fk'] = Variable<String>(objectiveLoanFk);
    }
    map['sync_id'] = Variable<String>(syncId);
    if (!nullToAbsent || remainingAmount != null) {
      map['remaining_amount'] = Variable<double>(remainingAmount);
    }
    if (!nullToAbsent || parentTransactionId != null) {
      map['parent_transaction_id'] = Variable<int>(parentTransactionId);
    }
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      amount: Value(amount),
      categoryId: Value(categoryId),
      accountId: Value(accountId),
      date: Value(date),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      transactionType: Value(transactionType),
      specialType: specialType == null && nullToAbsent
          ? const Value.absent()
          : Value(specialType),
      recurrence: Value(recurrence),
      periodLength: periodLength == null && nullToAbsent
          ? const Value.absent()
          : Value(periodLength),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      originalDateDue: originalDateDue == null && nullToAbsent
          ? const Value.absent()
          : Value(originalDateDue),
      transactionState: Value(transactionState),
      paid: Value(paid),
      skipPaid: Value(skipPaid),
      createdAnotherFutureTransaction:
          createdAnotherFutureTransaction == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAnotherFutureTransaction),
      objectiveLoanFk: objectiveLoanFk == null && nullToAbsent
          ? const Value.absent()
          : Value(objectiveLoanFk),
      syncId: Value(syncId),
      remainingAmount: remainingAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(remainingAmount),
      parentTransactionId: parentTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTransactionId),
    );
  }

  factory TransactionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionsTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      accountId: serializer.fromJson<int>(json['accountId']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      specialType: serializer.fromJson<String?>(json['specialType']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      periodLength: serializer.fromJson<int?>(json['periodLength']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      originalDateDue: serializer.fromJson<DateTime?>(json['originalDateDue']),
      transactionState: serializer.fromJson<String>(json['transactionState']),
      paid: serializer.fromJson<bool>(json['paid']),
      skipPaid: serializer.fromJson<bool>(json['skipPaid']),
      createdAnotherFutureTransaction:
          serializer.fromJson<bool?>(json['createdAnotherFutureTransaction']),
      objectiveLoanFk: serializer.fromJson<String?>(json['objectiveLoanFk']),
      syncId: serializer.fromJson<String>(json['syncId']),
      remainingAmount: serializer.fromJson<double?>(json['remainingAmount']),
      parentTransactionId:
          serializer.fromJson<int?>(json['parentTransactionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<int>(categoryId),
      'accountId': serializer.toJson<int>(accountId),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'transactionType': serializer.toJson<String>(transactionType),
      'specialType': serializer.toJson<String?>(specialType),
      'recurrence': serializer.toJson<String>(recurrence),
      'periodLength': serializer.toJson<int?>(periodLength),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'originalDateDue': serializer.toJson<DateTime?>(originalDateDue),
      'transactionState': serializer.toJson<String>(transactionState),
      'paid': serializer.toJson<bool>(paid),
      'skipPaid': serializer.toJson<bool>(skipPaid),
      'createdAnotherFutureTransaction':
          serializer.toJson<bool?>(createdAnotherFutureTransaction),
      'objectiveLoanFk': serializer.toJson<String?>(objectiveLoanFk),
      'syncId': serializer.toJson<String>(syncId),
      'remainingAmount': serializer.toJson<double?>(remainingAmount),
      'parentTransactionId': serializer.toJson<int?>(parentTransactionId),
    };
  }

  TransactionsTableData copyWith(
          {int? id,
          String? title,
          Value<String?> note = const Value.absent(),
          double? amount,
          int? categoryId,
          int? accountId,
          DateTime? date,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? transactionType,
          Value<String?> specialType = const Value.absent(),
          String? recurrence,
          Value<int?> periodLength = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          Value<DateTime?> originalDateDue = const Value.absent(),
          String? transactionState,
          bool? paid,
          bool? skipPaid,
          Value<bool?> createdAnotherFutureTransaction = const Value.absent(),
          Value<String?> objectiveLoanFk = const Value.absent(),
          String? syncId,
          Value<double?> remainingAmount = const Value.absent(),
          Value<int?> parentTransactionId = const Value.absent()}) =>
      TransactionsTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        note: note.present ? note.value : this.note,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        accountId: accountId ?? this.accountId,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        transactionType: transactionType ?? this.transactionType,
        specialType: specialType.present ? specialType.value : this.specialType,
        recurrence: recurrence ?? this.recurrence,
        periodLength:
            periodLength.present ? periodLength.value : this.periodLength,
        endDate: endDate.present ? endDate.value : this.endDate,
        originalDateDue: originalDateDue.present
            ? originalDateDue.value
            : this.originalDateDue,
        transactionState: transactionState ?? this.transactionState,
        paid: paid ?? this.paid,
        skipPaid: skipPaid ?? this.skipPaid,
        createdAnotherFutureTransaction: createdAnotherFutureTransaction.present
            ? createdAnotherFutureTransaction.value
            : this.createdAnotherFutureTransaction,
        objectiveLoanFk: objectiveLoanFk.present
            ? objectiveLoanFk.value
            : this.objectiveLoanFk,
        syncId: syncId ?? this.syncId,
        remainingAmount: remainingAmount.present
            ? remainingAmount.value
            : this.remainingAmount,
        parentTransactionId: parentTransactionId.present
            ? parentTransactionId.value
            : this.parentTransactionId,
      );
  TransactionsTableData copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      specialType:
          data.specialType.present ? data.specialType.value : this.specialType,
      recurrence:
          data.recurrence.present ? data.recurrence.value : this.recurrence,
      periodLength: data.periodLength.present
          ? data.periodLength.value
          : this.periodLength,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      originalDateDue: data.originalDateDue.present
          ? data.originalDateDue.value
          : this.originalDateDue,
      transactionState: data.transactionState.present
          ? data.transactionState.value
          : this.transactionState,
      paid: data.paid.present ? data.paid.value : this.paid,
      skipPaid: data.skipPaid.present ? data.skipPaid.value : this.skipPaid,
      createdAnotherFutureTransaction:
          data.createdAnotherFutureTransaction.present
              ? data.createdAnotherFutureTransaction.value
              : this.createdAnotherFutureTransaction,
      objectiveLoanFk: data.objectiveLoanFk.present
          ? data.objectiveLoanFk.value
          : this.objectiveLoanFk,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      remainingAmount: data.remainingAmount.present
          ? data.remainingAmount.value
          : this.remainingAmount,
      parentTransactionId: data.parentTransactionId.present
          ? data.parentTransactionId.value
          : this.parentTransactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('transactionType: $transactionType, ')
          ..write('specialType: $specialType, ')
          ..write('recurrence: $recurrence, ')
          ..write('periodLength: $periodLength, ')
          ..write('endDate: $endDate, ')
          ..write('originalDateDue: $originalDateDue, ')
          ..write('transactionState: $transactionState, ')
          ..write('paid: $paid, ')
          ..write('skipPaid: $skipPaid, ')
          ..write(
              'createdAnotherFutureTransaction: $createdAnotherFutureTransaction, ')
          ..write('objectiveLoanFk: $objectiveLoanFk, ')
          ..write('syncId: $syncId, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('parentTransactionId: $parentTransactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        note,
        amount,
        categoryId,
        accountId,
        date,
        createdAt,
        updatedAt,
        transactionType,
        specialType,
        recurrence,
        periodLength,
        endDate,
        originalDateDue,
        transactionState,
        paid,
        skipPaid,
        createdAnotherFutureTransaction,
        objectiveLoanFk,
        syncId,
        remainingAmount,
        parentTransactionId
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.note == this.note &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.transactionType == this.transactionType &&
          other.specialType == this.specialType &&
          other.recurrence == this.recurrence &&
          other.periodLength == this.periodLength &&
          other.endDate == this.endDate &&
          other.originalDateDue == this.originalDateDue &&
          other.transactionState == this.transactionState &&
          other.paid == this.paid &&
          other.skipPaid == this.skipPaid &&
          other.createdAnotherFutureTransaction ==
              this.createdAnotherFutureTransaction &&
          other.objectiveLoanFk == this.objectiveLoanFk &&
          other.syncId == this.syncId &&
          other.remainingAmount == this.remainingAmount &&
          other.parentTransactionId == this.parentTransactionId);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> note;
  final Value<double> amount;
  final Value<int> categoryId;
  final Value<int> accountId;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> transactionType;
  final Value<String?> specialType;
  final Value<String> recurrence;
  final Value<int?> periodLength;
  final Value<DateTime?> endDate;
  final Value<DateTime?> originalDateDue;
  final Value<String> transactionState;
  final Value<bool> paid;
  final Value<bool> skipPaid;
  final Value<bool?> createdAnotherFutureTransaction;
  final Value<String?> objectiveLoanFk;
  final Value<String> syncId;
  final Value<double?> remainingAmount;
  final Value<int?> parentTransactionId;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.specialType = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.endDate = const Value.absent(),
    this.originalDateDue = const Value.absent(),
    this.transactionState = const Value.absent(),
    this.paid = const Value.absent(),
    this.skipPaid = const Value.absent(),
    this.createdAnotherFutureTransaction = const Value.absent(),
    this.objectiveLoanFk = const Value.absent(),
    this.syncId = const Value.absent(),
    this.remainingAmount = const Value.absent(),
    this.parentTransactionId = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.note = const Value.absent(),
    required double amount,
    required int categoryId,
    required int accountId,
    required DateTime date,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.specialType = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.endDate = const Value.absent(),
    this.originalDateDue = const Value.absent(),
    this.transactionState = const Value.absent(),
    this.paid = const Value.absent(),
    this.skipPaid = const Value.absent(),
    this.createdAnotherFutureTransaction = const Value.absent(),
    this.objectiveLoanFk = const Value.absent(),
    required String syncId,
    this.remainingAmount = const Value.absent(),
    this.parentTransactionId = const Value.absent(),
  })  : title = Value(title),
        amount = Value(amount),
        categoryId = Value(categoryId),
        accountId = Value(accountId),
        date = Value(date),
        syncId = Value(syncId);
  static Insertable<TransactionsTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? note,
    Expression<double>? amount,
    Expression<int>? categoryId,
    Expression<int>? accountId,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? transactionType,
    Expression<String>? specialType,
    Expression<String>? recurrence,
    Expression<int>? periodLength,
    Expression<DateTime>? endDate,
    Expression<DateTime>? originalDateDue,
    Expression<String>? transactionState,
    Expression<bool>? paid,
    Expression<bool>? skipPaid,
    Expression<bool>? createdAnotherFutureTransaction,
    Expression<String>? objectiveLoanFk,
    Expression<String>? syncId,
    Expression<double>? remainingAmount,
    Expression<int>? parentTransactionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (transactionType != null) 'transaction_type': transactionType,
      if (specialType != null) 'special_type': specialType,
      if (recurrence != null) 'recurrence': recurrence,
      if (periodLength != null) 'period_length': periodLength,
      if (endDate != null) 'end_date': endDate,
      if (originalDateDue != null) 'original_date_due': originalDateDue,
      if (transactionState != null) 'transaction_state': transactionState,
      if (paid != null) 'paid': paid,
      if (skipPaid != null) 'skip_paid': skipPaid,
      if (createdAnotherFutureTransaction != null)
        'created_another_future_transaction': createdAnotherFutureTransaction,
      if (objectiveLoanFk != null) 'objective_loan_fk': objectiveLoanFk,
      if (syncId != null) 'sync_id': syncId,
      if (remainingAmount != null) 'remaining_amount': remainingAmount,
      if (parentTransactionId != null)
        'parent_transaction_id': parentTransactionId,
    });
  }

  TransactionsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? note,
      Value<double>? amount,
      Value<int>? categoryId,
      Value<int>? accountId,
      Value<DateTime>? date,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? transactionType,
      Value<String?>? specialType,
      Value<String>? recurrence,
      Value<int?>? periodLength,
      Value<DateTime?>? endDate,
      Value<DateTime?>? originalDateDue,
      Value<String>? transactionState,
      Value<bool>? paid,
      Value<bool>? skipPaid,
      Value<bool?>? createdAnotherFutureTransaction,
      Value<String?>? objectiveLoanFk,
      Value<String>? syncId,
      Value<double?>? remainingAmount,
      Value<int?>? parentTransactionId}) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionType: transactionType ?? this.transactionType,
      specialType: specialType ?? this.specialType,
      recurrence: recurrence ?? this.recurrence,
      periodLength: periodLength ?? this.periodLength,
      endDate: endDate ?? this.endDate,
      originalDateDue: originalDateDue ?? this.originalDateDue,
      transactionState: transactionState ?? this.transactionState,
      paid: paid ?? this.paid,
      skipPaid: skipPaid ?? this.skipPaid,
      createdAnotherFutureTransaction: createdAnotherFutureTransaction ??
          this.createdAnotherFutureTransaction,
      objectiveLoanFk: objectiveLoanFk ?? this.objectiveLoanFk,
      syncId: syncId ?? this.syncId,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      parentTransactionId: parentTransactionId ?? this.parentTransactionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (specialType.present) {
      map['special_type'] = Variable<String>(specialType.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (periodLength.present) {
      map['period_length'] = Variable<int>(periodLength.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (originalDateDue.present) {
      map['original_date_due'] = Variable<DateTime>(originalDateDue.value);
    }
    if (transactionState.present) {
      map['transaction_state'] = Variable<String>(transactionState.value);
    }
    if (paid.present) {
      map['paid'] = Variable<bool>(paid.value);
    }
    if (skipPaid.present) {
      map['skip_paid'] = Variable<bool>(skipPaid.value);
    }
    if (createdAnotherFutureTransaction.present) {
      map['created_another_future_transaction'] =
          Variable<bool>(createdAnotherFutureTransaction.value);
    }
    if (objectiveLoanFk.present) {
      map['objective_loan_fk'] = Variable<String>(objectiveLoanFk.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (remainingAmount.present) {
      map['remaining_amount'] = Variable<double>(remainingAmount.value);
    }
    if (parentTransactionId.present) {
      map['parent_transaction_id'] = Variable<int>(parentTransactionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('transactionType: $transactionType, ')
          ..write('specialType: $specialType, ')
          ..write('recurrence: $recurrence, ')
          ..write('periodLength: $periodLength, ')
          ..write('endDate: $endDate, ')
          ..write('originalDateDue: $originalDateDue, ')
          ..write('transactionState: $transactionState, ')
          ..write('paid: $paid, ')
          ..write('skipPaid: $skipPaid, ')
          ..write(
              'createdAnotherFutureTransaction: $createdAnotherFutureTransaction, ')
          ..write('objectiveLoanFk: $objectiveLoanFk, ')
          ..write('syncId: $syncId, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('parentTransactionId: $parentTransactionId')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTableTable extends BudgetsTable
    with TableInfo<$BudgetsTableTable, BudgetTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _spentMeta = const VerificationMeta('spent');
  @override
  late final GeneratedColumn<double> spent = GeneratedColumn<double>(
      'spent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _budgetTransactionFiltersMeta =
      const VerificationMeta('budgetTransactionFilters');
  @override
  late final GeneratedColumn<String> budgetTransactionFilters =
      GeneratedColumn<String>('budget_transaction_filters', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _excludeDebtCreditInstallmentsMeta =
      const VerificationMeta('excludeDebtCreditInstallments');
  @override
  late final GeneratedColumn<bool> excludeDebtCreditInstallments =
      GeneratedColumn<bool>(
          'exclude_debt_credit_installments', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("exclude_debt_credit_installments" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _excludeObjectiveInstallmentsMeta =
      const VerificationMeta('excludeObjectiveInstallments');
  @override
  late final GeneratedColumn<bool> excludeObjectiveInstallments =
      GeneratedColumn<bool>(
          'exclude_objective_installments', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("exclude_objective_installments" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _walletFksMeta =
      const VerificationMeta('walletFks');
  @override
  late final GeneratedColumn<String> walletFks = GeneratedColumn<String>(
      'wallet_fks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencyFksMeta =
      const VerificationMeta('currencyFks');
  @override
  late final GeneratedColumn<String> currencyFks = GeneratedColumn<String>(
      'currency_fks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sharedReferenceBudgetPkMeta =
      const VerificationMeta('sharedReferenceBudgetPk');
  @override
  late final GeneratedColumn<String> sharedReferenceBudgetPk =
      GeneratedColumn<String>('shared_reference_budget_pk', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _budgetFksExcludeMeta =
      const VerificationMeta('budgetFksExclude');
  @override
  late final GeneratedColumn<String> budgetFksExclude = GeneratedColumn<String>(
      'budget_fks_exclude', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _normalizeToCurrencyMeta =
      const VerificationMeta('normalizeToCurrency');
  @override
  late final GeneratedColumn<String> normalizeToCurrency =
      GeneratedColumn<String>('normalize_to_currency', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isIncomeBudgetMeta =
      const VerificationMeta('isIncomeBudget');
  @override
  late final GeneratedColumn<bool> isIncomeBudget = GeneratedColumn<bool>(
      'is_income_budget', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_income_budget" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _includeTransferInOutWithSameCurrencyMeta =
      const VerificationMeta('includeTransferInOutWithSameCurrency');
  @override
  late final GeneratedColumn<bool> includeTransferInOutWithSameCurrency =
      GeneratedColumn<bool>(
          'include_transfer_in_out_with_same_currency', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("include_transfer_in_out_with_same_currency" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _includeUpcomingTransactionFromBudgetMeta =
      const VerificationMeta('includeUpcomingTransactionFromBudget');
  @override
  late final GeneratedColumn<bool> includeUpcomingTransactionFromBudget =
      GeneratedColumn<bool>(
          'include_upcoming_transaction_from_budget', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("include_upcoming_transaction_from_budget" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _dateCreatedOriginalMeta =
      const VerificationMeta('dateCreatedOriginal');
  @override
  late final GeneratedColumn<DateTime> dateCreatedOriginal =
      GeneratedColumn<DateTime>('date_created_original', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
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
        syncId,
        budgetTransactionFilters,
        excludeDebtCreditInstallments,
        excludeObjectiveInstallments,
        walletFks,
        currencyFks,
        sharedReferenceBudgetPk,
        budgetFksExclude,
        normalizeToCurrency,
        isIncomeBudget,
        includeTransferInOutWithSameCurrency,
        includeUpcomingTransactionFromBudget,
        dateCreatedOriginal
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<BudgetTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('spent')) {
      context.handle(
          _spentMeta, spent.isAcceptableOrUnknown(data['spent']!, _spentMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('budget_transaction_filters')) {
      context.handle(
          _budgetTransactionFiltersMeta,
          budgetTransactionFilters.isAcceptableOrUnknown(
              data['budget_transaction_filters']!,
              _budgetTransactionFiltersMeta));
    }
    if (data.containsKey('exclude_debt_credit_installments')) {
      context.handle(
          _excludeDebtCreditInstallmentsMeta,
          excludeDebtCreditInstallments.isAcceptableOrUnknown(
              data['exclude_debt_credit_installments']!,
              _excludeDebtCreditInstallmentsMeta));
    }
    if (data.containsKey('exclude_objective_installments')) {
      context.handle(
          _excludeObjectiveInstallmentsMeta,
          excludeObjectiveInstallments.isAcceptableOrUnknown(
              data['exclude_objective_installments']!,
              _excludeObjectiveInstallmentsMeta));
    }
    if (data.containsKey('wallet_fks')) {
      context.handle(_walletFksMeta,
          walletFks.isAcceptableOrUnknown(data['wallet_fks']!, _walletFksMeta));
    }
    if (data.containsKey('currency_fks')) {
      context.handle(
          _currencyFksMeta,
          currencyFks.isAcceptableOrUnknown(
              data['currency_fks']!, _currencyFksMeta));
    }
    if (data.containsKey('shared_reference_budget_pk')) {
      context.handle(
          _sharedReferenceBudgetPkMeta,
          sharedReferenceBudgetPk.isAcceptableOrUnknown(
              data['shared_reference_budget_pk']!,
              _sharedReferenceBudgetPkMeta));
    }
    if (data.containsKey('budget_fks_exclude')) {
      context.handle(
          _budgetFksExcludeMeta,
          budgetFksExclude.isAcceptableOrUnknown(
              data['budget_fks_exclude']!, _budgetFksExcludeMeta));
    }
    if (data.containsKey('normalize_to_currency')) {
      context.handle(
          _normalizeToCurrencyMeta,
          normalizeToCurrency.isAcceptableOrUnknown(
              data['normalize_to_currency']!, _normalizeToCurrencyMeta));
    }
    if (data.containsKey('is_income_budget')) {
      context.handle(
          _isIncomeBudgetMeta,
          isIncomeBudget.isAcceptableOrUnknown(
              data['is_income_budget']!, _isIncomeBudgetMeta));
    }
    if (data.containsKey('include_transfer_in_out_with_same_currency')) {
      context.handle(
          _includeTransferInOutWithSameCurrencyMeta,
          includeTransferInOutWithSameCurrency.isAcceptableOrUnknown(
              data['include_transfer_in_out_with_same_currency']!,
              _includeTransferInOutWithSameCurrencyMeta));
    }
    if (data.containsKey('include_upcoming_transaction_from_budget')) {
      context.handle(
          _includeUpcomingTransactionFromBudgetMeta,
          includeUpcomingTransactionFromBudget.isAcceptableOrUnknown(
              data['include_upcoming_transaction_from_budget']!,
              _includeUpcomingTransactionFromBudgetMeta));
    }
    if (data.containsKey('date_created_original')) {
      context.handle(
          _dateCreatedOriginalMeta,
          dateCreatedOriginal.isAcceptableOrUnknown(
              data['date_created_original']!, _dateCreatedOriginalMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      spent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}spent'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
      budgetTransactionFilters: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}budget_transaction_filters']),
      excludeDebtCreditInstallments: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}exclude_debt_credit_installments'])!,
      excludeObjectiveInstallments: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}exclude_objective_installments'])!,
      walletFks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_fks']),
      currencyFks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_fks']),
      sharedReferenceBudgetPk: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}shared_reference_budget_pk']),
      budgetFksExclude: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}budget_fks_exclude']),
      normalizeToCurrency: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalize_to_currency']),
      isIncomeBudget: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_income_budget'])!,
      includeTransferInOutWithSameCurrency: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data[
              '${effectivePrefix}include_transfer_in_out_with_same_currency'])!,
      includeUpcomingTransactionFromBudget: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}include_upcoming_transaction_from_budget'])!,
      dateCreatedOriginal: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}date_created_original']),
    );
  }

  @override
  $BudgetsTableTable createAlias(String alias) {
    return $BudgetsTableTable(attachedDatabase, alias);
  }
}

class BudgetTableData extends DataClass implements Insertable<BudgetTableData> {
  final int id;
  final String name;
  final double amount;
  final double spent;
  final int? categoryId;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncId;
  final String? budgetTransactionFilters;
  final bool excludeDebtCreditInstallments;
  final bool excludeObjectiveInstallments;
  final String? walletFks;
  final String? currencyFks;
  final String? sharedReferenceBudgetPk;
  final String? budgetFksExclude;
  final String? normalizeToCurrency;
  final bool isIncomeBudget;
  final bool includeTransferInOutWithSameCurrency;
  final bool includeUpcomingTransactionFromBudget;
  final DateTime? dateCreatedOriginal;
  const BudgetTableData(
      {required this.id,
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
      required this.syncId,
      this.budgetTransactionFilters,
      required this.excludeDebtCreditInstallments,
      required this.excludeObjectiveInstallments,
      this.walletFks,
      this.currencyFks,
      this.sharedReferenceBudgetPk,
      this.budgetFksExclude,
      this.normalizeToCurrency,
      required this.isIncomeBudget,
      required this.includeTransferInOutWithSameCurrency,
      required this.includeUpcomingTransactionFromBudget,
      this.dateCreatedOriginal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['spent'] = Variable<double>(spent);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['period'] = Variable<String>(period);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_id'] = Variable<String>(syncId);
    if (!nullToAbsent || budgetTransactionFilters != null) {
      map['budget_transaction_filters'] =
          Variable<String>(budgetTransactionFilters);
    }
    map['exclude_debt_credit_installments'] =
        Variable<bool>(excludeDebtCreditInstallments);
    map['exclude_objective_installments'] =
        Variable<bool>(excludeObjectiveInstallments);
    if (!nullToAbsent || walletFks != null) {
      map['wallet_fks'] = Variable<String>(walletFks);
    }
    if (!nullToAbsent || currencyFks != null) {
      map['currency_fks'] = Variable<String>(currencyFks);
    }
    if (!nullToAbsent || sharedReferenceBudgetPk != null) {
      map['shared_reference_budget_pk'] =
          Variable<String>(sharedReferenceBudgetPk);
    }
    if (!nullToAbsent || budgetFksExclude != null) {
      map['budget_fks_exclude'] = Variable<String>(budgetFksExclude);
    }
    if (!nullToAbsent || normalizeToCurrency != null) {
      map['normalize_to_currency'] = Variable<String>(normalizeToCurrency);
    }
    map['is_income_budget'] = Variable<bool>(isIncomeBudget);
    map['include_transfer_in_out_with_same_currency'] =
        Variable<bool>(includeTransferInOutWithSameCurrency);
    map['include_upcoming_transaction_from_budget'] =
        Variable<bool>(includeUpcomingTransactionFromBudget);
    if (!nullToAbsent || dateCreatedOriginal != null) {
      map['date_created_original'] = Variable<DateTime>(dateCreatedOriginal);
    }
    return map;
  }

  BudgetsTableCompanion toCompanion(bool nullToAbsent) {
    return BudgetsTableCompanion(
      id: Value(id),
      name: Value(name),
      amount: Value(amount),
      spent: Value(spent),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      period: Value(period),
      startDate: Value(startDate),
      endDate: Value(endDate),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncId: Value(syncId),
      budgetTransactionFilters: budgetTransactionFilters == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetTransactionFilters),
      excludeDebtCreditInstallments: Value(excludeDebtCreditInstallments),
      excludeObjectiveInstallments: Value(excludeObjectiveInstallments),
      walletFks: walletFks == null && nullToAbsent
          ? const Value.absent()
          : Value(walletFks),
      currencyFks: currencyFks == null && nullToAbsent
          ? const Value.absent()
          : Value(currencyFks),
      sharedReferenceBudgetPk: sharedReferenceBudgetPk == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedReferenceBudgetPk),
      budgetFksExclude: budgetFksExclude == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetFksExclude),
      normalizeToCurrency: normalizeToCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizeToCurrency),
      isIncomeBudget: Value(isIncomeBudget),
      includeTransferInOutWithSameCurrency:
          Value(includeTransferInOutWithSameCurrency),
      includeUpcomingTransactionFromBudget:
          Value(includeUpcomingTransactionFromBudget),
      dateCreatedOriginal: dateCreatedOriginal == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCreatedOriginal),
    );
  }

  factory BudgetTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      spent: serializer.fromJson<double>(json['spent']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncId: serializer.fromJson<String>(json['syncId']),
      budgetTransactionFilters:
          serializer.fromJson<String?>(json['budgetTransactionFilters']),
      excludeDebtCreditInstallments:
          serializer.fromJson<bool>(json['excludeDebtCreditInstallments']),
      excludeObjectiveInstallments:
          serializer.fromJson<bool>(json['excludeObjectiveInstallments']),
      walletFks: serializer.fromJson<String?>(json['walletFks']),
      currencyFks: serializer.fromJson<String?>(json['currencyFks']),
      sharedReferenceBudgetPk:
          serializer.fromJson<String?>(json['sharedReferenceBudgetPk']),
      budgetFksExclude: serializer.fromJson<String?>(json['budgetFksExclude']),
      normalizeToCurrency:
          serializer.fromJson<String?>(json['normalizeToCurrency']),
      isIncomeBudget: serializer.fromJson<bool>(json['isIncomeBudget']),
      includeTransferInOutWithSameCurrency: serializer
          .fromJson<bool>(json['includeTransferInOutWithSameCurrency']),
      includeUpcomingTransactionFromBudget: serializer
          .fromJson<bool>(json['includeUpcomingTransactionFromBudget']),
      dateCreatedOriginal:
          serializer.fromJson<DateTime?>(json['dateCreatedOriginal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'spent': serializer.toJson<double>(spent),
      'categoryId': serializer.toJson<int?>(categoryId),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncId': serializer.toJson<String>(syncId),
      'budgetTransactionFilters':
          serializer.toJson<String?>(budgetTransactionFilters),
      'excludeDebtCreditInstallments':
          serializer.toJson<bool>(excludeDebtCreditInstallments),
      'excludeObjectiveInstallments':
          serializer.toJson<bool>(excludeObjectiveInstallments),
      'walletFks': serializer.toJson<String?>(walletFks),
      'currencyFks': serializer.toJson<String?>(currencyFks),
      'sharedReferenceBudgetPk':
          serializer.toJson<String?>(sharedReferenceBudgetPk),
      'budgetFksExclude': serializer.toJson<String?>(budgetFksExclude),
      'normalizeToCurrency': serializer.toJson<String?>(normalizeToCurrency),
      'isIncomeBudget': serializer.toJson<bool>(isIncomeBudget),
      'includeTransferInOutWithSameCurrency':
          serializer.toJson<bool>(includeTransferInOutWithSameCurrency),
      'includeUpcomingTransactionFromBudget':
          serializer.toJson<bool>(includeUpcomingTransactionFromBudget),
      'dateCreatedOriginal': serializer.toJson<DateTime?>(dateCreatedOriginal),
    };
  }

  BudgetTableData copyWith(
          {int? id,
          String? name,
          double? amount,
          double? spent,
          Value<int?> categoryId = const Value.absent(),
          String? period,
          DateTime? startDate,
          DateTime? endDate,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncId,
          Value<String?> budgetTransactionFilters = const Value.absent(),
          bool? excludeDebtCreditInstallments,
          bool? excludeObjectiveInstallments,
          Value<String?> walletFks = const Value.absent(),
          Value<String?> currencyFks = const Value.absent(),
          Value<String?> sharedReferenceBudgetPk = const Value.absent(),
          Value<String?> budgetFksExclude = const Value.absent(),
          Value<String?> normalizeToCurrency = const Value.absent(),
          bool? isIncomeBudget,
          bool? includeTransferInOutWithSameCurrency,
          bool? includeUpcomingTransactionFromBudget,
          Value<DateTime?> dateCreatedOriginal = const Value.absent()}) =>
      BudgetTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        spent: spent ?? this.spent,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        period: period ?? this.period,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncId: syncId ?? this.syncId,
        budgetTransactionFilters: budgetTransactionFilters.present
            ? budgetTransactionFilters.value
            : this.budgetTransactionFilters,
        excludeDebtCreditInstallments:
            excludeDebtCreditInstallments ?? this.excludeDebtCreditInstallments,
        excludeObjectiveInstallments:
            excludeObjectiveInstallments ?? this.excludeObjectiveInstallments,
        walletFks: walletFks.present ? walletFks.value : this.walletFks,
        currencyFks: currencyFks.present ? currencyFks.value : this.currencyFks,
        sharedReferenceBudgetPk: sharedReferenceBudgetPk.present
            ? sharedReferenceBudgetPk.value
            : this.sharedReferenceBudgetPk,
        budgetFksExclude: budgetFksExclude.present
            ? budgetFksExclude.value
            : this.budgetFksExclude,
        normalizeToCurrency: normalizeToCurrency.present
            ? normalizeToCurrency.value
            : this.normalizeToCurrency,
        isIncomeBudget: isIncomeBudget ?? this.isIncomeBudget,
        includeTransferInOutWithSameCurrency:
            includeTransferInOutWithSameCurrency ??
                this.includeTransferInOutWithSameCurrency,
        includeUpcomingTransactionFromBudget:
            includeUpcomingTransactionFromBudget ??
                this.includeUpcomingTransactionFromBudget,
        dateCreatedOriginal: dateCreatedOriginal.present
            ? dateCreatedOriginal.value
            : this.dateCreatedOriginal,
      );
  BudgetTableData copyWithCompanion(BudgetsTableCompanion data) {
    return BudgetTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      spent: data.spent.present ? data.spent.value : this.spent,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      budgetTransactionFilters: data.budgetTransactionFilters.present
          ? data.budgetTransactionFilters.value
          : this.budgetTransactionFilters,
      excludeDebtCreditInstallments: data.excludeDebtCreditInstallments.present
          ? data.excludeDebtCreditInstallments.value
          : this.excludeDebtCreditInstallments,
      excludeObjectiveInstallments: data.excludeObjectiveInstallments.present
          ? data.excludeObjectiveInstallments.value
          : this.excludeObjectiveInstallments,
      walletFks: data.walletFks.present ? data.walletFks.value : this.walletFks,
      currencyFks:
          data.currencyFks.present ? data.currencyFks.value : this.currencyFks,
      sharedReferenceBudgetPk: data.sharedReferenceBudgetPk.present
          ? data.sharedReferenceBudgetPk.value
          : this.sharedReferenceBudgetPk,
      budgetFksExclude: data.budgetFksExclude.present
          ? data.budgetFksExclude.value
          : this.budgetFksExclude,
      normalizeToCurrency: data.normalizeToCurrency.present
          ? data.normalizeToCurrency.value
          : this.normalizeToCurrency,
      isIncomeBudget: data.isIncomeBudget.present
          ? data.isIncomeBudget.value
          : this.isIncomeBudget,
      includeTransferInOutWithSameCurrency:
          data.includeTransferInOutWithSameCurrency.present
              ? data.includeTransferInOutWithSameCurrency.value
              : this.includeTransferInOutWithSameCurrency,
      includeUpcomingTransactionFromBudget:
          data.includeUpcomingTransactionFromBudget.present
              ? data.includeUpcomingTransactionFromBudget.value
              : this.includeUpcomingTransactionFromBudget,
      dateCreatedOriginal: data.dateCreatedOriginal.present
          ? data.dateCreatedOriginal.value
          : this.dateCreatedOriginal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('spent: $spent, ')
          ..write('categoryId: $categoryId, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncId: $syncId, ')
          ..write('budgetTransactionFilters: $budgetTransactionFilters, ')
          ..write(
              'excludeDebtCreditInstallments: $excludeDebtCreditInstallments, ')
          ..write(
              'excludeObjectiveInstallments: $excludeObjectiveInstallments, ')
          ..write('walletFks: $walletFks, ')
          ..write('currencyFks: $currencyFks, ')
          ..write('sharedReferenceBudgetPk: $sharedReferenceBudgetPk, ')
          ..write('budgetFksExclude: $budgetFksExclude, ')
          ..write('normalizeToCurrency: $normalizeToCurrency, ')
          ..write('isIncomeBudget: $isIncomeBudget, ')
          ..write(
              'includeTransferInOutWithSameCurrency: $includeTransferInOutWithSameCurrency, ')
          ..write(
              'includeUpcomingTransactionFromBudget: $includeUpcomingTransactionFromBudget, ')
          ..write('dateCreatedOriginal: $dateCreatedOriginal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
        syncId,
        budgetTransactionFilters,
        excludeDebtCreditInstallments,
        excludeObjectiveInstallments,
        walletFks,
        currencyFks,
        sharedReferenceBudgetPk,
        budgetFksExclude,
        normalizeToCurrency,
        isIncomeBudget,
        includeTransferInOutWithSameCurrency,
        includeUpcomingTransactionFromBudget,
        dateCreatedOriginal
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.spent == this.spent &&
          other.categoryId == this.categoryId &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncId == this.syncId &&
          other.budgetTransactionFilters == this.budgetTransactionFilters &&
          other.excludeDebtCreditInstallments ==
              this.excludeDebtCreditInstallments &&
          other.excludeObjectiveInstallments ==
              this.excludeObjectiveInstallments &&
          other.walletFks == this.walletFks &&
          other.currencyFks == this.currencyFks &&
          other.sharedReferenceBudgetPk == this.sharedReferenceBudgetPk &&
          other.budgetFksExclude == this.budgetFksExclude &&
          other.normalizeToCurrency == this.normalizeToCurrency &&
          other.isIncomeBudget == this.isIncomeBudget &&
          other.includeTransferInOutWithSameCurrency ==
              this.includeTransferInOutWithSameCurrency &&
          other.includeUpcomingTransactionFromBudget ==
              this.includeUpcomingTransactionFromBudget &&
          other.dateCreatedOriginal == this.dateCreatedOriginal);
}

class BudgetsTableCompanion extends UpdateCompanion<BudgetTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> amount;
  final Value<double> spent;
  final Value<int?> categoryId;
  final Value<String> period;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncId;
  final Value<String?> budgetTransactionFilters;
  final Value<bool> excludeDebtCreditInstallments;
  final Value<bool> excludeObjectiveInstallments;
  final Value<String?> walletFks;
  final Value<String?> currencyFks;
  final Value<String?> sharedReferenceBudgetPk;
  final Value<String?> budgetFksExclude;
  final Value<String?> normalizeToCurrency;
  final Value<bool> isIncomeBudget;
  final Value<bool> includeTransferInOutWithSameCurrency;
  final Value<bool> includeUpcomingTransactionFromBudget;
  final Value<DateTime?> dateCreatedOriginal;
  const BudgetsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.spent = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncId = const Value.absent(),
    this.budgetTransactionFilters = const Value.absent(),
    this.excludeDebtCreditInstallments = const Value.absent(),
    this.excludeObjectiveInstallments = const Value.absent(),
    this.walletFks = const Value.absent(),
    this.currencyFks = const Value.absent(),
    this.sharedReferenceBudgetPk = const Value.absent(),
    this.budgetFksExclude = const Value.absent(),
    this.normalizeToCurrency = const Value.absent(),
    this.isIncomeBudget = const Value.absent(),
    this.includeTransferInOutWithSameCurrency = const Value.absent(),
    this.includeUpcomingTransactionFromBudget = const Value.absent(),
    this.dateCreatedOriginal = const Value.absent(),
  });
  BudgetsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double amount,
    this.spent = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String syncId,
    this.budgetTransactionFilters = const Value.absent(),
    this.excludeDebtCreditInstallments = const Value.absent(),
    this.excludeObjectiveInstallments = const Value.absent(),
    this.walletFks = const Value.absent(),
    this.currencyFks = const Value.absent(),
    this.sharedReferenceBudgetPk = const Value.absent(),
    this.budgetFksExclude = const Value.absent(),
    this.normalizeToCurrency = const Value.absent(),
    this.isIncomeBudget = const Value.absent(),
    this.includeTransferInOutWithSameCurrency = const Value.absent(),
    this.includeUpcomingTransactionFromBudget = const Value.absent(),
    this.dateCreatedOriginal = const Value.absent(),
  })  : name = Value(name),
        amount = Value(amount),
        period = Value(period),
        startDate = Value(startDate),
        endDate = Value(endDate),
        syncId = Value(syncId);
  static Insertable<BudgetTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<double>? spent,
    Expression<int>? categoryId,
    Expression<String>? period,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncId,
    Expression<String>? budgetTransactionFilters,
    Expression<bool>? excludeDebtCreditInstallments,
    Expression<bool>? excludeObjectiveInstallments,
    Expression<String>? walletFks,
    Expression<String>? currencyFks,
    Expression<String>? sharedReferenceBudgetPk,
    Expression<String>? budgetFksExclude,
    Expression<String>? normalizeToCurrency,
    Expression<bool>? isIncomeBudget,
    Expression<bool>? includeTransferInOutWithSameCurrency,
    Expression<bool>? includeUpcomingTransactionFromBudget,
    Expression<DateTime>? dateCreatedOriginal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (spent != null) 'spent': spent,
      if (categoryId != null) 'category_id': categoryId,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncId != null) 'sync_id': syncId,
      if (budgetTransactionFilters != null)
        'budget_transaction_filters': budgetTransactionFilters,
      if (excludeDebtCreditInstallments != null)
        'exclude_debt_credit_installments': excludeDebtCreditInstallments,
      if (excludeObjectiveInstallments != null)
        'exclude_objective_installments': excludeObjectiveInstallments,
      if (walletFks != null) 'wallet_fks': walletFks,
      if (currencyFks != null) 'currency_fks': currencyFks,
      if (sharedReferenceBudgetPk != null)
        'shared_reference_budget_pk': sharedReferenceBudgetPk,
      if (budgetFksExclude != null) 'budget_fks_exclude': budgetFksExclude,
      if (normalizeToCurrency != null)
        'normalize_to_currency': normalizeToCurrency,
      if (isIncomeBudget != null) 'is_income_budget': isIncomeBudget,
      if (includeTransferInOutWithSameCurrency != null)
        'include_transfer_in_out_with_same_currency':
            includeTransferInOutWithSameCurrency,
      if (includeUpcomingTransactionFromBudget != null)
        'include_upcoming_transaction_from_budget':
            includeUpcomingTransactionFromBudget,
      if (dateCreatedOriginal != null)
        'date_created_original': dateCreatedOriginal,
    });
  }

  BudgetsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? amount,
      Value<double>? spent,
      Value<int?>? categoryId,
      Value<String>? period,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncId,
      Value<String?>? budgetTransactionFilters,
      Value<bool>? excludeDebtCreditInstallments,
      Value<bool>? excludeObjectiveInstallments,
      Value<String?>? walletFks,
      Value<String?>? currencyFks,
      Value<String?>? sharedReferenceBudgetPk,
      Value<String?>? budgetFksExclude,
      Value<String?>? normalizeToCurrency,
      Value<bool>? isIncomeBudget,
      Value<bool>? includeTransferInOutWithSameCurrency,
      Value<bool>? includeUpcomingTransactionFromBudget,
      Value<DateTime?>? dateCreatedOriginal}) {
    return BudgetsTableCompanion(
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
      syncId: syncId ?? this.syncId,
      budgetTransactionFilters:
          budgetTransactionFilters ?? this.budgetTransactionFilters,
      excludeDebtCreditInstallments:
          excludeDebtCreditInstallments ?? this.excludeDebtCreditInstallments,
      excludeObjectiveInstallments:
          excludeObjectiveInstallments ?? this.excludeObjectiveInstallments,
      walletFks: walletFks ?? this.walletFks,
      currencyFks: currencyFks ?? this.currencyFks,
      sharedReferenceBudgetPk:
          sharedReferenceBudgetPk ?? this.sharedReferenceBudgetPk,
      budgetFksExclude: budgetFksExclude ?? this.budgetFksExclude,
      normalizeToCurrency: normalizeToCurrency ?? this.normalizeToCurrency,
      isIncomeBudget: isIncomeBudget ?? this.isIncomeBudget,
      includeTransferInOutWithSameCurrency:
          includeTransferInOutWithSameCurrency ??
              this.includeTransferInOutWithSameCurrency,
      includeUpcomingTransactionFromBudget:
          includeUpcomingTransactionFromBudget ??
              this.includeUpcomingTransactionFromBudget,
      dateCreatedOriginal: dateCreatedOriginal ?? this.dateCreatedOriginal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (spent.present) {
      map['spent'] = Variable<double>(spent.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (budgetTransactionFilters.present) {
      map['budget_transaction_filters'] =
          Variable<String>(budgetTransactionFilters.value);
    }
    if (excludeDebtCreditInstallments.present) {
      map['exclude_debt_credit_installments'] =
          Variable<bool>(excludeDebtCreditInstallments.value);
    }
    if (excludeObjectiveInstallments.present) {
      map['exclude_objective_installments'] =
          Variable<bool>(excludeObjectiveInstallments.value);
    }
    if (walletFks.present) {
      map['wallet_fks'] = Variable<String>(walletFks.value);
    }
    if (currencyFks.present) {
      map['currency_fks'] = Variable<String>(currencyFks.value);
    }
    if (sharedReferenceBudgetPk.present) {
      map['shared_reference_budget_pk'] =
          Variable<String>(sharedReferenceBudgetPk.value);
    }
    if (budgetFksExclude.present) {
      map['budget_fks_exclude'] = Variable<String>(budgetFksExclude.value);
    }
    if (normalizeToCurrency.present) {
      map['normalize_to_currency'] =
          Variable<String>(normalizeToCurrency.value);
    }
    if (isIncomeBudget.present) {
      map['is_income_budget'] = Variable<bool>(isIncomeBudget.value);
    }
    if (includeTransferInOutWithSameCurrency.present) {
      map['include_transfer_in_out_with_same_currency'] =
          Variable<bool>(includeTransferInOutWithSameCurrency.value);
    }
    if (includeUpcomingTransactionFromBudget.present) {
      map['include_upcoming_transaction_from_budget'] =
          Variable<bool>(includeUpcomingTransactionFromBudget.value);
    }
    if (dateCreatedOriginal.present) {
      map['date_created_original'] =
          Variable<DateTime>(dateCreatedOriginal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('spent: $spent, ')
          ..write('categoryId: $categoryId, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncId: $syncId, ')
          ..write('budgetTransactionFilters: $budgetTransactionFilters, ')
          ..write(
              'excludeDebtCreditInstallments: $excludeDebtCreditInstallments, ')
          ..write(
              'excludeObjectiveInstallments: $excludeObjectiveInstallments, ')
          ..write('walletFks: $walletFks, ')
          ..write('currencyFks: $currencyFks, ')
          ..write('sharedReferenceBudgetPk: $sharedReferenceBudgetPk, ')
          ..write('budgetFksExclude: $budgetFksExclude, ')
          ..write('normalizeToCurrency: $normalizeToCurrency, ')
          ..write('isIncomeBudget: $isIncomeBudget, ')
          ..write(
              'includeTransferInOutWithSameCurrency: $includeTransferInOutWithSameCurrency, ')
          ..write(
              'includeUpcomingTransactionFromBudget: $includeUpcomingTransactionFromBudget, ')
          ..write('dateCreatedOriginal: $dateCreatedOriginal')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTableTable extends SyncMetadataTable
    with TableInfo<$SyncMetadataTableTable, SyncMetadataTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, key, value, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
      Insertable<SyncMetadataTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetadataTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SyncMetadataTableTable createAlias(String alias) {
    return $SyncMetadataTableTable(attachedDatabase, alias);
  }
}

class SyncMetadataTableData extends DataClass
    implements Insertable<SyncMetadataTableData> {
  final int id;
  final String key;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncMetadataTableData(
      {required this.id,
      required this.key,
      required this.value,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataTableCompanion(
      id: Value(id),
      key: Value(key),
      value: Value(value),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncMetadataTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataTableData(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncMetadataTableData copyWith(
          {int? id,
          String? key,
          String? value,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SyncMetadataTableData(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncMetadataTableData copyWithCompanion(SyncMetadataTableCompanion data) {
    return SyncMetadataTableData(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataTableData(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, value, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataTableData &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncMetadataTableCompanion
    extends UpdateCompanion<SyncMetadataTableData> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SyncMetadataTableCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SyncMetadataTableCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String value,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SyncMetadataTableData> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SyncMetadataTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? key,
      Value<String>? value,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SyncMetadataTableCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataTableCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTableTable extends AttachmentsTable
    with TableInfo<$AttachmentsTableTable, AttachmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (id)'));
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _googleDriveFileIdMeta =
      const VerificationMeta('googleDriveFileId');
  @override
  late final GeneratedColumn<String> googleDriveFileId =
      GeneratedColumn<String>('google_drive_file_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _googleDriveLinkMeta =
      const VerificationMeta('googleDriveLink');
  @override
  late final GeneratedColumn<String> googleDriveLink = GeneratedColumn<String>(
      'google_drive_link', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeBytesMeta =
      const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
      'file_size_bytes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isUploadedMeta =
      const VerificationMeta('isUploaded');
  @override
  late final GeneratedColumn<bool> isUploaded = GeneratedColumn<bool>(
      'is_uploaded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_uploaded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isCapturedFromCameraMeta =
      const VerificationMeta('isCapturedFromCamera');
  @override
  late final GeneratedColumn<bool> isCapturedFromCamera = GeneratedColumn<bool>(
      'is_captured_from_camera', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_captured_from_camera" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _localCacheExpiryMeta =
      const VerificationMeta('localCacheExpiry');
  @override
  late final GeneratedColumn<DateTime> localCacheExpiry =
      GeneratedColumn<DateTime>('local_cache_expiry', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        fileName,
        filePath,
        googleDriveFileId,
        googleDriveLink,
        type,
        mimeType,
        fileSizeBytes,
        createdAt,
        updatedAt,
        isUploaded,
        isDeleted,
        isCapturedFromCamera,
        localCacheExpiry,
        syncId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
      Insertable<AttachmentsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    }
    if (data.containsKey('google_drive_file_id')) {
      context.handle(
          _googleDriveFileIdMeta,
          googleDriveFileId.isAcceptableOrUnknown(
              data['google_drive_file_id']!, _googleDriveFileIdMeta));
    }
    if (data.containsKey('google_drive_link')) {
      context.handle(
          _googleDriveLinkMeta,
          googleDriveLink.isAcceptableOrUnknown(
              data['google_drive_link']!, _googleDriveLinkMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
          _fileSizeBytesMeta,
          fileSizeBytes.isAcceptableOrUnknown(
              data['file_size_bytes']!, _fileSizeBytesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_uploaded')) {
      context.handle(
          _isUploadedMeta,
          isUploaded.isAcceptableOrUnknown(
              data['is_uploaded']!, _isUploadedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('is_captured_from_camera')) {
      context.handle(
          _isCapturedFromCameraMeta,
          isCapturedFromCamera.isAcceptableOrUnknown(
              data['is_captured_from_camera']!, _isCapturedFromCameraMeta));
    }
    if (data.containsKey('local_cache_expiry')) {
      context.handle(
          _localCacheExpiryMeta,
          localCacheExpiry.isAcceptableOrUnknown(
              data['local_cache_expiry']!, _localCacheExpiryMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path']),
      googleDriveFileId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}google_drive_file_id']),
      googleDriveLink: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}google_drive_link']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type']),
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isUploaded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_uploaded'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isCapturedFromCamera: attachedDatabase.typeMapping.read(DriftSqlType.bool,
          data['${effectivePrefix}is_captured_from_camera'])!,
      localCacheExpiry: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_cache_expiry']),
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
    );
  }

  @override
  $AttachmentsTableTable createAlias(String alias) {
    return $AttachmentsTableTable(attachedDatabase, alias);
  }
}

class AttachmentsTableData extends DataClass
    implements Insertable<AttachmentsTableData> {
  final int id;
  final int transactionId;
  final String fileName;
  final String? filePath;
  final String? googleDriveFileId;
  final String? googleDriveLink;
  final int type;
  final String? mimeType;
  final int? fileSizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isUploaded;
  final bool isDeleted;
  final bool isCapturedFromCamera;
  final DateTime? localCacheExpiry;
  final String syncId;
  const AttachmentsTableData(
      {required this.id,
      required this.transactionId,
      required this.fileName,
      this.filePath,
      this.googleDriveFileId,
      this.googleDriveLink,
      required this.type,
      this.mimeType,
      this.fileSizeBytes,
      required this.createdAt,
      required this.updatedAt,
      required this.isUploaded,
      required this.isDeleted,
      required this.isCapturedFromCamera,
      this.localCacheExpiry,
      required this.syncId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || googleDriveFileId != null) {
      map['google_drive_file_id'] = Variable<String>(googleDriveFileId);
    }
    if (!nullToAbsent || googleDriveLink != null) {
      map['google_drive_link'] = Variable<String>(googleDriveLink);
    }
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || fileSizeBytes != null) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_uploaded'] = Variable<bool>(isUploaded);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_captured_from_camera'] = Variable<bool>(isCapturedFromCamera);
    if (!nullToAbsent || localCacheExpiry != null) {
      map['local_cache_expiry'] = Variable<DateTime>(localCacheExpiry);
    }
    map['sync_id'] = Variable<String>(syncId);
    return map;
  }

  AttachmentsTableCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsTableCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      fileName: Value(fileName),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      googleDriveFileId: googleDriveFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(googleDriveFileId),
      googleDriveLink: googleDriveLink == null && nullToAbsent
          ? const Value.absent()
          : Value(googleDriveLink),
      type: Value(type),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      fileSizeBytes: fileSizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSizeBytes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isUploaded: Value(isUploaded),
      isDeleted: Value(isDeleted),
      isCapturedFromCamera: Value(isCapturedFromCamera),
      localCacheExpiry: localCacheExpiry == null && nullToAbsent
          ? const Value.absent()
          : Value(localCacheExpiry),
      syncId: Value(syncId),
    );
  }

  factory AttachmentsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentsTableData(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      googleDriveFileId:
          serializer.fromJson<String?>(json['googleDriveFileId']),
      googleDriveLink: serializer.fromJson<String?>(json['googleDriveLink']),
      type: serializer.fromJson<int>(json['type']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      fileSizeBytes: serializer.fromJson<int?>(json['fileSizeBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isUploaded: serializer.fromJson<bool>(json['isUploaded']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isCapturedFromCamera:
          serializer.fromJson<bool>(json['isCapturedFromCamera']),
      localCacheExpiry:
          serializer.fromJson<DateTime?>(json['localCacheExpiry']),
      syncId: serializer.fromJson<String>(json['syncId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String?>(filePath),
      'googleDriveFileId': serializer.toJson<String?>(googleDriveFileId),
      'googleDriveLink': serializer.toJson<String?>(googleDriveLink),
      'type': serializer.toJson<int>(type),
      'mimeType': serializer.toJson<String?>(mimeType),
      'fileSizeBytes': serializer.toJson<int?>(fileSizeBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isUploaded': serializer.toJson<bool>(isUploaded),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isCapturedFromCamera': serializer.toJson<bool>(isCapturedFromCamera),
      'localCacheExpiry': serializer.toJson<DateTime?>(localCacheExpiry),
      'syncId': serializer.toJson<String>(syncId),
    };
  }

  AttachmentsTableData copyWith(
          {int? id,
          int? transactionId,
          String? fileName,
          Value<String?> filePath = const Value.absent(),
          Value<String?> googleDriveFileId = const Value.absent(),
          Value<String?> googleDriveLink = const Value.absent(),
          int? type,
          Value<String?> mimeType = const Value.absent(),
          Value<int?> fileSizeBytes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isUploaded,
          bool? isDeleted,
          bool? isCapturedFromCamera,
          Value<DateTime?> localCacheExpiry = const Value.absent(),
          String? syncId}) =>
      AttachmentsTableData(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        fileName: fileName ?? this.fileName,
        filePath: filePath.present ? filePath.value : this.filePath,
        googleDriveFileId: googleDriveFileId.present
            ? googleDriveFileId.value
            : this.googleDriveFileId,
        googleDriveLink: googleDriveLink.present
            ? googleDriveLink.value
            : this.googleDriveLink,
        type: type ?? this.type,
        mimeType: mimeType.present ? mimeType.value : this.mimeType,
        fileSizeBytes:
            fileSizeBytes.present ? fileSizeBytes.value : this.fileSizeBytes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isUploaded: isUploaded ?? this.isUploaded,
        isDeleted: isDeleted ?? this.isDeleted,
        isCapturedFromCamera: isCapturedFromCamera ?? this.isCapturedFromCamera,
        localCacheExpiry: localCacheExpiry.present
            ? localCacheExpiry.value
            : this.localCacheExpiry,
        syncId: syncId ?? this.syncId,
      );
  AttachmentsTableData copyWithCompanion(AttachmentsTableCompanion data) {
    return AttachmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      googleDriveFileId: data.googleDriveFileId.present
          ? data.googleDriveFileId.value
          : this.googleDriveFileId,
      googleDriveLink: data.googleDriveLink.present
          ? data.googleDriveLink.value
          : this.googleDriveLink,
      type: data.type.present ? data.type.value : this.type,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isUploaded:
          data.isUploaded.present ? data.isUploaded.value : this.isUploaded,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isCapturedFromCamera: data.isCapturedFromCamera.present
          ? data.isCapturedFromCamera.value
          : this.isCapturedFromCamera,
      localCacheExpiry: data.localCacheExpiry.present
          ? data.localCacheExpiry.value
          : this.localCacheExpiry,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsTableData(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('googleDriveFileId: $googleDriveFileId, ')
          ..write('googleDriveLink: $googleDriveLink, ')
          ..write('type: $type, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isCapturedFromCamera: $isCapturedFromCamera, ')
          ..write('localCacheExpiry: $localCacheExpiry, ')
          ..write('syncId: $syncId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transactionId,
      fileName,
      filePath,
      googleDriveFileId,
      googleDriveLink,
      type,
      mimeType,
      fileSizeBytes,
      createdAt,
      updatedAt,
      isUploaded,
      isDeleted,
      isCapturedFromCamera,
      localCacheExpiry,
      syncId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentsTableData &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.googleDriveFileId == this.googleDriveFileId &&
          other.googleDriveLink == this.googleDriveLink &&
          other.type == this.type &&
          other.mimeType == this.mimeType &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isUploaded == this.isUploaded &&
          other.isDeleted == this.isDeleted &&
          other.isCapturedFromCamera == this.isCapturedFromCamera &&
          other.localCacheExpiry == this.localCacheExpiry &&
          other.syncId == this.syncId);
}

class AttachmentsTableCompanion extends UpdateCompanion<AttachmentsTableData> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<String> fileName;
  final Value<String?> filePath;
  final Value<String?> googleDriveFileId;
  final Value<String?> googleDriveLink;
  final Value<int> type;
  final Value<String?> mimeType;
  final Value<int?> fileSizeBytes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isUploaded;
  final Value<bool> isDeleted;
  final Value<bool> isCapturedFromCamera;
  final Value<DateTime?> localCacheExpiry;
  final Value<String> syncId;
  const AttachmentsTableCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.googleDriveFileId = const Value.absent(),
    this.googleDriveLink = const Value.absent(),
    this.type = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isUploaded = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isCapturedFromCamera = const Value.absent(),
    this.localCacheExpiry = const Value.absent(),
    this.syncId = const Value.absent(),
  });
  AttachmentsTableCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required String fileName,
    this.filePath = const Value.absent(),
    this.googleDriveFileId = const Value.absent(),
    this.googleDriveLink = const Value.absent(),
    required int type,
    this.mimeType = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isUploaded = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isCapturedFromCamera = const Value.absent(),
    this.localCacheExpiry = const Value.absent(),
    required String syncId,
  })  : transactionId = Value(transactionId),
        fileName = Value(fileName),
        type = Value(type),
        syncId = Value(syncId);
  static Insertable<AttachmentsTableData> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<String>? googleDriveFileId,
    Expression<String>? googleDriveLink,
    Expression<int>? type,
    Expression<String>? mimeType,
    Expression<int>? fileSizeBytes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isUploaded,
    Expression<bool>? isDeleted,
    Expression<bool>? isCapturedFromCamera,
    Expression<DateTime>? localCacheExpiry,
    Expression<String>? syncId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (googleDriveFileId != null) 'google_drive_file_id': googleDriveFileId,
      if (googleDriveLink != null) 'google_drive_link': googleDriveLink,
      if (type != null) 'type': type,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isUploaded != null) 'is_uploaded': isUploaded,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isCapturedFromCamera != null)
        'is_captured_from_camera': isCapturedFromCamera,
      if (localCacheExpiry != null) 'local_cache_expiry': localCacheExpiry,
      if (syncId != null) 'sync_id': syncId,
    });
  }

  AttachmentsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<String>? fileName,
      Value<String?>? filePath,
      Value<String?>? googleDriveFileId,
      Value<String?>? googleDriveLink,
      Value<int>? type,
      Value<String?>? mimeType,
      Value<int?>? fileSizeBytes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isUploaded,
      Value<bool>? isDeleted,
      Value<bool>? isCapturedFromCamera,
      Value<DateTime?>? localCacheExpiry,
      Value<String>? syncId}) {
    return AttachmentsTableCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      googleDriveFileId: googleDriveFileId ?? this.googleDriveFileId,
      googleDriveLink: googleDriveLink ?? this.googleDriveLink,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isUploaded: isUploaded ?? this.isUploaded,
      isDeleted: isDeleted ?? this.isDeleted,
      isCapturedFromCamera: isCapturedFromCamera ?? this.isCapturedFromCamera,
      localCacheExpiry: localCacheExpiry ?? this.localCacheExpiry,
      syncId: syncId ?? this.syncId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (googleDriveFileId.present) {
      map['google_drive_file_id'] = Variable<String>(googleDriveFileId.value);
    }
    if (googleDriveLink.present) {
      map['google_drive_link'] = Variable<String>(googleDriveLink.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isUploaded.present) {
      map['is_uploaded'] = Variable<bool>(isUploaded.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isCapturedFromCamera.present) {
      map['is_captured_from_camera'] =
          Variable<bool>(isCapturedFromCamera.value);
    }
    if (localCacheExpiry.present) {
      map['local_cache_expiry'] = Variable<DateTime>(localCacheExpiry.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('googleDriveFileId: $googleDriveFileId, ')
          ..write('googleDriveLink: $googleDriveLink, ')
          ..write('type: $type, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isCapturedFromCamera: $isCapturedFromCamera, ')
          ..write('localCacheExpiry: $localCacheExpiry, ')
          ..write('syncId: $syncId')
          ..write(')'))
        .toString();
  }
}

class $SyncEventLogTableTable extends SyncEventLogTable
    with TableInfo<$SyncEventLogTableTable, SyncEventLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncEventLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tableNameFieldMeta =
      const VerificationMeta('tableNameField');
  @override
  late final GeneratedColumn<String> tableNameField = GeneratedColumn<String>(
      'table_name_field', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordIdMeta =
      const VerificationMeta('recordId');
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
      'record_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sequenceNumberMeta =
      const VerificationMeta('sequenceNumber');
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
      'sequence_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        eventId,
        deviceId,
        tableNameField,
        recordId,
        operation,
        data,
        timestamp,
        sequenceNumber,
        hash,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_event_log';
  @override
  VerificationContext validateIntegrity(Insertable<SyncEventLogData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('table_name_field')) {
      context.handle(
          _tableNameFieldMeta,
          tableNameField.isAcceptableOrUnknown(
              data['table_name_field']!, _tableNameFieldMeta));
    } else if (isInserting) {
      context.missing(_tableNameFieldMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(_recordIdMeta,
          recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta));
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('sequence_number')) {
      context.handle(
          _sequenceNumberMeta,
          sequenceNumber.isAcceptableOrUnknown(
              data['sequence_number']!, _sequenceNumberMeta));
    } else if (isInserting) {
      context.missing(_sequenceNumberMeta);
    }
    if (data.containsKey('hash')) {
      context.handle(
          _hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncEventLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncEventLogData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      tableNameField: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}table_name_field'])!,
      recordId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      sequenceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence_number'])!,
      hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hash'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $SyncEventLogTableTable createAlias(String alias) {
    return $SyncEventLogTableTable(attachedDatabase, alias);
  }
}

class SyncEventLogData extends DataClass
    implements Insertable<SyncEventLogData> {
  final int id;
  final String eventId;
  final String deviceId;
  final String tableNameField;
  final String recordId;
  final String operation;
  final String data;
  final DateTime timestamp;
  final int sequenceNumber;
  final String hash;
  final bool isSynced;
  const SyncEventLogData(
      {required this.id,
      required this.eventId,
      required this.deviceId,
      required this.tableNameField,
      required this.recordId,
      required this.operation,
      required this.data,
      required this.timestamp,
      required this.sequenceNumber,
      required this.hash,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<String>(eventId);
    map['device_id'] = Variable<String>(deviceId);
    map['table_name_field'] = Variable<String>(tableNameField);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    map['data'] = Variable<String>(data);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['sequence_number'] = Variable<int>(sequenceNumber);
    map['hash'] = Variable<String>(hash);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  SyncEventLogTableCompanion toCompanion(bool nullToAbsent) {
    return SyncEventLogTableCompanion(
      id: Value(id),
      eventId: Value(eventId),
      deviceId: Value(deviceId),
      tableNameField: Value(tableNameField),
      recordId: Value(recordId),
      operation: Value(operation),
      data: Value(data),
      timestamp: Value(timestamp),
      sequenceNumber: Value(sequenceNumber),
      hash: Value(hash),
      isSynced: Value(isSynced),
    );
  }

  factory SyncEventLogData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncEventLogData(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      tableNameField: serializer.fromJson<String>(json['tableNameField']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      data: serializer.fromJson<String>(json['data']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      sequenceNumber: serializer.fromJson<int>(json['sequenceNumber']),
      hash: serializer.fromJson<String>(json['hash']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<String>(eventId),
      'deviceId': serializer.toJson<String>(deviceId),
      'tableNameField': serializer.toJson<String>(tableNameField),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'data': serializer.toJson<String>(data),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'sequenceNumber': serializer.toJson<int>(sequenceNumber),
      'hash': serializer.toJson<String>(hash),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  SyncEventLogData copyWith(
          {int? id,
          String? eventId,
          String? deviceId,
          String? tableNameField,
          String? recordId,
          String? operation,
          String? data,
          DateTime? timestamp,
          int? sequenceNumber,
          String? hash,
          bool? isSynced}) =>
      SyncEventLogData(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        deviceId: deviceId ?? this.deviceId,
        tableNameField: tableNameField ?? this.tableNameField,
        recordId: recordId ?? this.recordId,
        operation: operation ?? this.operation,
        data: data ?? this.data,
        timestamp: timestamp ?? this.timestamp,
        sequenceNumber: sequenceNumber ?? this.sequenceNumber,
        hash: hash ?? this.hash,
        isSynced: isSynced ?? this.isSynced,
      );
  SyncEventLogData copyWithCompanion(SyncEventLogTableCompanion data) {
    return SyncEventLogData(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      tableNameField: data.tableNameField.present
          ? data.tableNameField.value
          : this.tableNameField,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      data: data.data.present ? data.data.value : this.data,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
      hash: data.hash.present ? data.hash.value : this.hash,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncEventLogData(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('deviceId: $deviceId, ')
          ..write('tableNameField: $tableNameField, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('timestamp: $timestamp, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('hash: $hash, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eventId, deviceId, tableNameField,
      recordId, operation, data, timestamp, sequenceNumber, hash, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncEventLogData &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.deviceId == this.deviceId &&
          other.tableNameField == this.tableNameField &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.data == this.data &&
          other.timestamp == this.timestamp &&
          other.sequenceNumber == this.sequenceNumber &&
          other.hash == this.hash &&
          other.isSynced == this.isSynced);
}

class SyncEventLogTableCompanion extends UpdateCompanion<SyncEventLogData> {
  final Value<int> id;
  final Value<String> eventId;
  final Value<String> deviceId;
  final Value<String> tableNameField;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<String> data;
  final Value<DateTime> timestamp;
  final Value<int> sequenceNumber;
  final Value<String> hash;
  final Value<bool> isSynced;
  const SyncEventLogTableCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.tableNameField = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.data = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.hash = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  SyncEventLogTableCompanion.insert({
    this.id = const Value.absent(),
    required String eventId,
    required String deviceId,
    required String tableNameField,
    required String recordId,
    required String operation,
    required String data,
    required DateTime timestamp,
    required int sequenceNumber,
    required String hash,
    this.isSynced = const Value.absent(),
  })  : eventId = Value(eventId),
        deviceId = Value(deviceId),
        tableNameField = Value(tableNameField),
        recordId = Value(recordId),
        operation = Value(operation),
        data = Value(data),
        timestamp = Value(timestamp),
        sequenceNumber = Value(sequenceNumber),
        hash = Value(hash);
  static Insertable<SyncEventLogData> custom({
    Expression<int>? id,
    Expression<String>? eventId,
    Expression<String>? deviceId,
    Expression<String>? tableNameField,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? data,
    Expression<DateTime>? timestamp,
    Expression<int>? sequenceNumber,
    Expression<String>? hash,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (deviceId != null) 'device_id': deviceId,
      if (tableNameField != null) 'table_name_field': tableNameField,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (data != null) 'data': data,
      if (timestamp != null) 'timestamp': timestamp,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (hash != null) 'hash': hash,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  SyncEventLogTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? eventId,
      Value<String>? deviceId,
      Value<String>? tableNameField,
      Value<String>? recordId,
      Value<String>? operation,
      Value<String>? data,
      Value<DateTime>? timestamp,
      Value<int>? sequenceNumber,
      Value<String>? hash,
      Value<bool>? isSynced}) {
    return SyncEventLogTableCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      deviceId: deviceId ?? this.deviceId,
      tableNameField: tableNameField ?? this.tableNameField,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      hash: hash ?? this.hash,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (tableNameField.present) {
      map['table_name_field'] = Variable<String>(tableNameField.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncEventLogTableCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('deviceId: $deviceId, ')
          ..write('tableNameField: $tableNameField, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('timestamp: $timestamp, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('hash: $hash, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTableTable extends SyncStateTable
    with TableInfo<$SyncStateTableTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastSyncTimeMeta =
      const VerificationMeta('lastSyncTime');
  @override
  late final GeneratedColumn<DateTime> lastSyncTime = GeneratedColumn<DateTime>(
      'last_sync_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastSequenceNumberMeta =
      const VerificationMeta('lastSequenceNumber');
  @override
  late final GeneratedColumn<int> lastSequenceNumber = GeneratedColumn<int>(
      'last_sequence_number', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('idle'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, deviceId, lastSyncTime, lastSequenceNumber, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('last_sync_time')) {
      context.handle(
          _lastSyncTimeMeta,
          lastSyncTime.isAcceptableOrUnknown(
              data['last_sync_time']!, _lastSyncTimeMeta));
    } else if (isInserting) {
      context.missing(_lastSyncTimeMeta);
    }
    if (data.containsKey('last_sequence_number')) {
      context.handle(
          _lastSequenceNumberMeta,
          lastSequenceNumber.isAcceptableOrUnknown(
              data['last_sequence_number']!, _lastSequenceNumberMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      lastSyncTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_sync_time'])!,
      lastSequenceNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_sequence_number'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $SyncStateTableTable createAlias(String alias) {
    return $SyncStateTableTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final int id;
  final String deviceId;
  final DateTime lastSyncTime;
  final int lastSequenceNumber;
  final String status;
  const SyncStateData(
      {required this.id,
      required this.deviceId,
      required this.lastSyncTime,
      required this.lastSequenceNumber,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['last_sync_time'] = Variable<DateTime>(lastSyncTime);
    map['last_sequence_number'] = Variable<int>(lastSequenceNumber);
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncStateTableCompanion toCompanion(bool nullToAbsent) {
    return SyncStateTableCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      lastSyncTime: Value(lastSyncTime),
      lastSequenceNumber: Value(lastSequenceNumber),
      status: Value(status),
    );
  }

  factory SyncStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      lastSyncTime: serializer.fromJson<DateTime>(json['lastSyncTime']),
      lastSequenceNumber: serializer.fromJson<int>(json['lastSequenceNumber']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'lastSyncTime': serializer.toJson<DateTime>(lastSyncTime),
      'lastSequenceNumber': serializer.toJson<int>(lastSequenceNumber),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncStateData copyWith(
          {int? id,
          String? deviceId,
          DateTime? lastSyncTime,
          int? lastSequenceNumber,
          String? status}) =>
      SyncStateData(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        lastSyncTime: lastSyncTime ?? this.lastSyncTime,
        lastSequenceNumber: lastSequenceNumber ?? this.lastSequenceNumber,
        status: status ?? this.status,
      );
  SyncStateData copyWithCompanion(SyncStateTableCompanion data) {
    return SyncStateData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      lastSyncTime: data.lastSyncTime.present
          ? data.lastSyncTime.value
          : this.lastSyncTime,
      lastSequenceNumber: data.lastSequenceNumber.present
          ? data.lastSequenceNumber.value
          : this.lastSequenceNumber,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('lastSequenceNumber: $lastSequenceNumber, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, lastSyncTime, lastSequenceNumber, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.lastSyncTime == this.lastSyncTime &&
          other.lastSequenceNumber == this.lastSequenceNumber &&
          other.status == this.status);
}

class SyncStateTableCompanion extends UpdateCompanion<SyncStateData> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> lastSyncTime;
  final Value<int> lastSequenceNumber;
  final Value<String> status;
  const SyncStateTableCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.lastSyncTime = const Value.absent(),
    this.lastSequenceNumber = const Value.absent(),
    this.status = const Value.absent(),
  });
  SyncStateTableCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime lastSyncTime,
    this.lastSequenceNumber = const Value.absent(),
    this.status = const Value.absent(),
  })  : deviceId = Value(deviceId),
        lastSyncTime = Value(lastSyncTime);
  static Insertable<SyncStateData> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? lastSyncTime,
    Expression<int>? lastSequenceNumber,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (lastSyncTime != null) 'last_sync_time': lastSyncTime,
      if (lastSequenceNumber != null)
        'last_sequence_number': lastSequenceNumber,
      if (status != null) 'status': status,
    });
  }

  SyncStateTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? deviceId,
      Value<DateTime>? lastSyncTime,
      Value<int>? lastSequenceNumber,
      Value<String>? status}) {
    return SyncStateTableCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSequenceNumber: lastSequenceNumber ?? this.lastSequenceNumber,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (lastSyncTime.present) {
      map['last_sync_time'] = Variable<DateTime>(lastSyncTime.value);
    }
    if (lastSequenceNumber.present) {
      map['last_sequence_number'] = Variable<int>(lastSequenceNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateTableCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('lastSequenceNumber: $lastSequenceNumber, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $TransactionBudgetsTableTable extends TransactionBudgetsTable
    with TableInfo<$TransactionBudgetsTableTable, TransactionBudgetTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionBudgetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (id)'));
  static const VerificationMeta _budgetIdMeta =
      const VerificationMeta('budgetId');
  @override
  late final GeneratedColumn<int> budgetId = GeneratedColumn<int>(
      'budget_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES budgets (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, transactionId, budgetId, amount, createdAt, updatedAt, syncId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_budgets';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionBudgetTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('budget_id')) {
      context.handle(_budgetIdMeta,
          budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta));
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionBudgetTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionBudgetTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      budgetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}budget_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
    );
  }

  @override
  $TransactionBudgetsTableTable createAlias(String alias) {
    return $TransactionBudgetsTableTable(attachedDatabase, alias);
  }
}

class TransactionBudgetTableData extends DataClass
    implements Insertable<TransactionBudgetTableData> {
  final int id;
  final int transactionId;
  final int budgetId;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncId;
  const TransactionBudgetTableData(
      {required this.id,
      required this.transactionId,
      required this.budgetId,
      required this.amount,
      required this.createdAt,
      required this.updatedAt,
      required this.syncId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['budget_id'] = Variable<int>(budgetId);
    map['amount'] = Variable<double>(amount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_id'] = Variable<String>(syncId);
    return map;
  }

  TransactionBudgetsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionBudgetsTableCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      budgetId: Value(budgetId),
      amount: Value(amount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncId: Value(syncId),
    );
  }

  factory TransactionBudgetTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionBudgetTableData(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      budgetId: serializer.fromJson<int>(json['budgetId']),
      amount: serializer.fromJson<double>(json['amount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncId: serializer.fromJson<String>(json['syncId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'budgetId': serializer.toJson<int>(budgetId),
      'amount': serializer.toJson<double>(amount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncId': serializer.toJson<String>(syncId),
    };
  }

  TransactionBudgetTableData copyWith(
          {int? id,
          int? transactionId,
          int? budgetId,
          double? amount,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncId}) =>
      TransactionBudgetTableData(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        budgetId: budgetId ?? this.budgetId,
        amount: amount ?? this.amount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncId: syncId ?? this.syncId,
      );
  TransactionBudgetTableData copyWithCompanion(
      TransactionBudgetsTableCompanion data) {
    return TransactionBudgetTableData(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      amount: data.amount.present ? data.amount.value : this.amount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionBudgetTableData(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('budgetId: $budgetId, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncId: $syncId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, transactionId, budgetId, amount, createdAt, updatedAt, syncId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionBudgetTableData &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.budgetId == this.budgetId &&
          other.amount == this.amount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncId == this.syncId);
}

class TransactionBudgetsTableCompanion
    extends UpdateCompanion<TransactionBudgetTableData> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> budgetId;
  final Value<double> amount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncId;
  const TransactionBudgetsTableCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncId = const Value.absent(),
  });
  TransactionBudgetsTableCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int budgetId,
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String syncId,
  })  : transactionId = Value(transactionId),
        budgetId = Value(budgetId),
        syncId = Value(syncId);
  static Insertable<TransactionBudgetTableData> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? budgetId,
    Expression<double>? amount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (budgetId != null) 'budget_id': budgetId,
      if (amount != null) 'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncId != null) 'sync_id': syncId,
    });
  }

  TransactionBudgetsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<int>? budgetId,
      Value<double>? amount,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncId}) {
    return TransactionBudgetsTableCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      budgetId: budgetId ?? this.budgetId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncId: syncId ?? this.syncId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<int>(budgetId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionBudgetsTableCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('budgetId: $budgetId, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncId: $syncId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTableTable categoriesTable =
      $CategoriesTableTable(this);
  late final $AccountsTableTable accountsTable = $AccountsTableTable(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $BudgetsTableTable budgetsTable = $BudgetsTableTable(this);
  late final $SyncMetadataTableTable syncMetadataTable =
      $SyncMetadataTableTable(this);
  late final $AttachmentsTableTable attachmentsTable =
      $AttachmentsTableTable(this);
  late final $SyncEventLogTableTable syncEventLogTable =
      $SyncEventLogTableTable(this);
  late final $SyncStateTableTable syncStateTable = $SyncStateTableTable(this);
  late final $TransactionBudgetsTableTable transactionBudgetsTable =
      $TransactionBudgetsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categoriesTable,
        accountsTable,
        transactionsTable,
        budgetsTable,
        syncMetadataTable,
        attachmentsTable,
        syncEventLogTable,
        syncStateTable,
        transactionBudgetsTable
      ];
}

typedef $$CategoriesTableTableCreateCompanionBuilder = CategoriesTableCompanion
    Function({
  Value<int> id,
  required String name,
  required String icon,
  required int color,
  required bool isExpense,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String syncId,
});
typedef $$CategoriesTableTableUpdateCompanionBuilder = CategoriesTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<int> color,
  Value<bool> isExpense,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncId,
});

final class $$CategoriesTableTableReferences extends BaseReferences<
    _$AppDatabase, $CategoriesTableTable, CategoriesTableData> {
  $$CategoriesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTableTable,
      List<TransactionsTableData>> _transactionsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.transactionsTable,
          aliasName: $_aliasNameGenerator(
              db.categoriesTable.id, db.transactionsTable.categoryId));

  $$TransactionsTableTableProcessedTableManager get transactionsTableRefs {
    final manager =
        $$TransactionsTableTableTableManager($_db, $_db.transactionsTable)
            .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BudgetsTableTable, List<BudgetTableData>>
      _budgetsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.budgetsTable,
              aliasName: $_aliasNameGenerator(
                  db.categoriesTable.id, db.budgetsTable.categoryId));

  $$BudgetsTableTableProcessedTableManager get budgetsTableRefs {
    final manager = $$BudgetsTableTableTableManager($_db, $_db.budgetsTable)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isExpense => $composableBuilder(
      column: $table.isExpense, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsTableRefs(
      Expression<bool> Function($$TransactionsTableTableFilterComposer f) f) {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableFilterComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> budgetsTableRefs(
      Expression<bool> Function($$BudgetsTableTableFilterComposer f) f) {
    final $$BudgetsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgetsTable,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableTableFilterComposer(
              $db: $db,
              $table: $db.budgetsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isExpense => $composableBuilder(
      column: $table.isExpense, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isExpense =>
      $composableBuilder(column: $table.isExpense, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  Expression<T> transactionsTableRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableTableAnnotationComposer a) f) {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transactionsTable,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> budgetsTableRefs<T extends Object>(
      Expression<T> Function($$BudgetsTableTableAnnotationComposer a) f) {
    final $$BudgetsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgetsTable,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.budgetsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTableTable,
    CategoriesTableData,
    $$CategoriesTableTableFilterComposer,
    $$CategoriesTableTableOrderingComposer,
    $$CategoriesTableTableAnnotationComposer,
    $$CategoriesTableTableCreateCompanionBuilder,
    $$CategoriesTableTableUpdateCompanionBuilder,
    (CategoriesTableData, $$CategoriesTableTableReferences),
    CategoriesTableData,
    PrefetchHooks Function(
        {bool transactionsTableRefs, bool budgetsTableRefs})> {
  $$CategoriesTableTableTableManager(
      _$AppDatabase db, $CategoriesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<bool> isExpense = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncId = const Value.absent(),
          }) =>
              CategoriesTableCompanion(
            id: id,
            name: name,
            icon: icon,
            color: color,
            isExpense: isExpense,
            isDefault: isDefault,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncId: syncId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String icon,
            required int color,
            required bool isExpense,
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            required String syncId,
          }) =>
              CategoriesTableCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            color: color,
            isExpense: isExpense,
            isDefault: isDefault,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncId: syncId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {transactionsTableRefs = false, budgetsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsTableRefs) db.transactionsTable,
                if (budgetsTableRefs) db.budgetsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsTableRefs)
                    await $_getPrefetchedData<CategoriesTableData,
                            $CategoriesTableTable, TransactionsTableData>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableTableReferences
                            ._transactionsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableTableReferences(db, table, p0)
                                .transactionsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (budgetsTableRefs)
                    await $_getPrefetchedData<CategoriesTableData,
                            $CategoriesTableTable, BudgetTableData>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableTableReferences
                            ._budgetsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableTableReferences(db, table, p0)
                                .budgetsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTableTable,
    CategoriesTableData,
    $$CategoriesTableTableFilterComposer,
    $$CategoriesTableTableOrderingComposer,
    $$CategoriesTableTableAnnotationComposer,
    $$CategoriesTableTableCreateCompanionBuilder,
    $$CategoriesTableTableUpdateCompanionBuilder,
    (CategoriesTableData, $$CategoriesTableTableReferences),
    CategoriesTableData,
    PrefetchHooks Function(
        {bool transactionsTableRefs, bool budgetsTableRefs})>;
typedef $$AccountsTableTableCreateCompanionBuilder = AccountsTableCompanion
    Function({
  Value<int> id,
  required String name,
  Value<double> balance,
  Value<String> currency,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> color,
  required String syncId,
});
typedef $$AccountsTableTableUpdateCompanionBuilder = AccountsTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<double> balance,
  Value<String> currency,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> color,
  Value<String> syncId,
});

final class $$AccountsTableTableReferences extends BaseReferences<_$AppDatabase,
    $AccountsTableTable, AccountsTableData> {
  $$AccountsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTableTable,
      List<TransactionsTableData>> _transactionsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.transactionsTable,
          aliasName: $_aliasNameGenerator(
              db.accountsTable.id, db.transactionsTable.accountId));

  $$TransactionsTableTableProcessedTableManager get transactionsTableRefs {
    final manager =
        $$TransactionsTableTableTableManager($_db, $_db.transactionsTable)
            .filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsTableRefs(
      Expression<bool> Function($$TransactionsTableTableFilterComposer f) f) {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableFilterComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  Expression<T> transactionsTableRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableTableAnnotationComposer a) f) {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transactionsTable,
            getReferencedColumn: (t) => t.accountId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$AccountsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTableTable,
    AccountsTableData,
    $$AccountsTableTableFilterComposer,
    $$AccountsTableTableOrderingComposer,
    $$AccountsTableTableAnnotationComposer,
    $$AccountsTableTableCreateCompanionBuilder,
    $$AccountsTableTableUpdateCompanionBuilder,
    (AccountsTableData, $$AccountsTableTableReferences),
    AccountsTableData,
    PrefetchHooks Function({bool transactionsTableRefs})> {
  $$AccountsTableTableTableManager(_$AppDatabase db, $AccountsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<String> syncId = const Value.absent(),
          }) =>
              AccountsTableCompanion(
            id: id,
            name: name,
            balance: balance,
            currency: currency,
            isDefault: isDefault,
            createdAt: createdAt,
            updatedAt: updatedAt,
            color: color,
            syncId: syncId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<double> balance = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> color = const Value.absent(),
            required String syncId,
          }) =>
              AccountsTableCompanion.insert(
            id: id,
            name: name,
            balance: balance,
            currency: currency,
            isDefault: isDefault,
            createdAt: createdAt,
            updatedAt: updatedAt,
            color: color,
            syncId: syncId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AccountsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsTableRefs) db.transactionsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsTableRefs)
                    await $_getPrefetchedData<AccountsTableData,
                            $AccountsTableTable, TransactionsTableData>(
                        currentTable: table,
                        referencedTable: $$AccountsTableTableReferences
                            ._transactionsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableTableReferences(db, table, p0)
                                .transactionsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTableTable,
    AccountsTableData,
    $$AccountsTableTableFilterComposer,
    $$AccountsTableTableOrderingComposer,
    $$AccountsTableTableAnnotationComposer,
    $$AccountsTableTableCreateCompanionBuilder,
    $$AccountsTableTableUpdateCompanionBuilder,
    (AccountsTableData, $$AccountsTableTableReferences),
    AccountsTableData,
    PrefetchHooks Function({bool transactionsTableRefs})>;
typedef $$TransactionsTableTableCreateCompanionBuilder
    = TransactionsTableCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> note,
  required double amount,
  required int categoryId,
  required int accountId,
  required DateTime date,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> transactionType,
  Value<String?> specialType,
  Value<String> recurrence,
  Value<int?> periodLength,
  Value<DateTime?> endDate,
  Value<DateTime?> originalDateDue,
  Value<String> transactionState,
  Value<bool> paid,
  Value<bool> skipPaid,
  Value<bool?> createdAnotherFutureTransaction,
  Value<String?> objectiveLoanFk,
  required String syncId,
  Value<double?> remainingAmount,
  Value<int?> parentTransactionId,
});
typedef $$TransactionsTableTableUpdateCompanionBuilder
    = TransactionsTableCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> note,
  Value<double> amount,
  Value<int> categoryId,
  Value<int> accountId,
  Value<DateTime> date,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> transactionType,
  Value<String?> specialType,
  Value<String> recurrence,
  Value<int?> periodLength,
  Value<DateTime?> endDate,
  Value<DateTime?> originalDateDue,
  Value<String> transactionState,
  Value<bool> paid,
  Value<bool> skipPaid,
  Value<bool?> createdAnotherFutureTransaction,
  Value<String?> objectiveLoanFk,
  Value<String> syncId,
  Value<double?> remainingAmount,
  Value<int?> parentTransactionId,
});

final class $$TransactionsTableTableReferences extends BaseReferences<
    _$AppDatabase, $TransactionsTableTable, TransactionsTableData> {
  $$TransactionsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTableTable _categoryIdTable(_$AppDatabase db) =>
      db.categoriesTable.createAlias($_aliasNameGenerator(
          db.transactionsTable.categoryId, db.categoriesTable.id));

  $$CategoriesTableTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager =
        $$CategoriesTableTableTableManager($_db, $_db.categoriesTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTableTable _accountIdTable(_$AppDatabase db) =>
      db.accountsTable.createAlias($_aliasNameGenerator(
          db.transactionsTable.accountId, db.accountsTable.id));

  $$AccountsTableTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableTableManager($_db, $_db.accountsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTableTable _parentTransactionIdTable(_$AppDatabase db) =>
      db.transactionsTable.createAlias($_aliasNameGenerator(
          db.transactionsTable.parentTransactionId, db.transactionsTable.id));

  $$TransactionsTableTableProcessedTableManager? get parentTransactionId {
    final $_column = $_itemColumn<int>('parent_transaction_id');
    if ($_column == null) return null;
    final manager =
        $$TransactionsTableTableTableManager($_db, $_db.transactionsTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$AttachmentsTableTable, List<AttachmentsTableData>>
      _attachmentsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.attachmentsTable,
              aliasName: $_aliasNameGenerator(
                  db.transactionsTable.id, db.attachmentsTable.transactionId));

  $$AttachmentsTableTableProcessedTableManager get attachmentsTableRefs {
    final manager = $$AttachmentsTableTableTableManager(
            $_db, $_db.attachmentsTable)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_attachmentsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TransactionBudgetsTableTable,
      List<TransactionBudgetTableData>> _transactionBudgetsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.transactionBudgetsTable,
          aliasName: $_aliasNameGenerator(db.transactionsTable.id,
              db.transactionBudgetsTable.transactionId));

  $$TransactionBudgetsTableTableProcessedTableManager
      get transactionBudgetsTableRefs {
    final manager = $$TransactionBudgetsTableTableTableManager(
            $_db, $_db.transactionBudgetsTable)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionBudgetsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specialType => $composableBuilder(
      column: $table.specialType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get periodLength => $composableBuilder(
      column: $table.periodLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get originalDateDue => $composableBuilder(
      column: $table.originalDateDue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionState => $composableBuilder(
      column: $table.transactionState,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get paid => $composableBuilder(
      column: $table.paid, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get skipPaid => $composableBuilder(
      column: $table.skipPaid, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get createdAnotherFutureTransaction => $composableBuilder(
      column: $table.createdAnotherFutureTransaction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get objectiveLoanFk => $composableBuilder(
      column: $table.objectiveLoanFk,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get remainingAmount => $composableBuilder(
      column: $table.remainingAmount,
      builder: (column) => ColumnFilters(column));

  $$CategoriesTableTableFilterComposer get categoryId {
    final $$CategoriesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableTableFilterComposer(
              $db: $db,
              $table: $db.categoriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableTableFilterComposer get accountId {
    final $$AccountsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accountsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableTableFilterComposer(
              $db: $db,
              $table: $db.accountsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableTableFilterComposer get parentTransactionId {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentTransactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableFilterComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> attachmentsTableRefs(
      Expression<bool> Function($$AttachmentsTableTableFilterComposer f) f) {
    final $$AttachmentsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attachmentsTable,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableTableFilterComposer(
              $db: $db,
              $table: $db.attachmentsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> transactionBudgetsTableRefs(
      Expression<bool> Function($$TransactionBudgetsTableTableFilterComposer f)
          f) {
    final $$TransactionBudgetsTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transactionBudgetsTable,
            getReferencedColumn: (t) => t.transactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionBudgetsTableTableFilterComposer(
                  $db: $db,
                  $table: $db.transactionBudgetsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specialType => $composableBuilder(
      column: $table.specialType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get periodLength => $composableBuilder(
      column: $table.periodLength,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get originalDateDue => $composableBuilder(
      column: $table.originalDateDue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionState => $composableBuilder(
      column: $table.transactionState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get paid => $composableBuilder(
      column: $table.paid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get skipPaid => $composableBuilder(
      column: $table.skipPaid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get createdAnotherFutureTransaction =>
      $composableBuilder(
          column: $table.createdAnotherFutureTransaction,
          builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get objectiveLoanFk => $composableBuilder(
      column: $table.objectiveLoanFk,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get remainingAmount => $composableBuilder(
      column: $table.remainingAmount,
      builder: (column) => ColumnOrderings(column));

  $$CategoriesTableTableOrderingComposer get categoryId {
    final $$CategoriesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableTableOrderingComposer(
              $db: $db,
              $table: $db.categoriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableTableOrderingComposer get accountId {
    final $$AccountsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accountsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableTableOrderingComposer(
              $db: $db,
              $table: $db.accountsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableTableOrderingComposer get parentTransactionId {
    final $$TransactionsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentTransactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableOrderingComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
      column: $table.transactionType, builder: (column) => column);

  GeneratedColumn<String> get specialType => $composableBuilder(
      column: $table.specialType, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => column);

  GeneratedColumn<int> get periodLength => $composableBuilder(
      column: $table.periodLength, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get originalDateDue => $composableBuilder(
      column: $table.originalDateDue, builder: (column) => column);

  GeneratedColumn<String> get transactionState => $composableBuilder(
      column: $table.transactionState, builder: (column) => column);

  GeneratedColumn<bool> get paid =>
      $composableBuilder(column: $table.paid, builder: (column) => column);

  GeneratedColumn<bool> get skipPaid =>
      $composableBuilder(column: $table.skipPaid, builder: (column) => column);

  GeneratedColumn<bool> get createdAnotherFutureTransaction =>
      $composableBuilder(
          column: $table.createdAnotherFutureTransaction,
          builder: (column) => column);

  GeneratedColumn<String> get objectiveLoanFk => $composableBuilder(
      column: $table.objectiveLoanFk, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<double> get remainingAmount => $composableBuilder(
      column: $table.remainingAmount, builder: (column) => column);

  $$CategoriesTableTableAnnotationComposer get categoryId {
    final $$CategoriesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.categoriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableTableAnnotationComposer get accountId {
    final $$AccountsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accountsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.accountsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableTableAnnotationComposer get parentTransactionId {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.parentTransactionId,
            referencedTable: $db.transactionsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> attachmentsTableRefs<T extends Object>(
      Expression<T> Function($$AttachmentsTableTableAnnotationComposer a) f) {
    final $$AttachmentsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attachmentsTable,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.attachmentsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> transactionBudgetsTableRefs<T extends Object>(
      Expression<T> Function($$TransactionBudgetsTableTableAnnotationComposer a)
          f) {
    final $$TransactionBudgetsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transactionBudgetsTable,
            getReferencedColumn: (t) => t.transactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionBudgetsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionBudgetsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTableTable,
    TransactionsTableData,
    $$TransactionsTableTableFilterComposer,
    $$TransactionsTableTableOrderingComposer,
    $$TransactionsTableTableAnnotationComposer,
    $$TransactionsTableTableCreateCompanionBuilder,
    $$TransactionsTableTableUpdateCompanionBuilder,
    (TransactionsTableData, $$TransactionsTableTableReferences),
    TransactionsTableData,
    PrefetchHooks Function(
        {bool categoryId,
        bool accountId,
        bool parentTransactionId,
        bool attachmentsTableRefs,
        bool transactionBudgetsTableRefs})> {
  $$TransactionsTableTableTableManager(
      _$AppDatabase db, $TransactionsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int> accountId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String?> specialType = const Value.absent(),
            Value<String> recurrence = const Value.absent(),
            Value<int?> periodLength = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<DateTime?> originalDateDue = const Value.absent(),
            Value<String> transactionState = const Value.absent(),
            Value<bool> paid = const Value.absent(),
            Value<bool> skipPaid = const Value.absent(),
            Value<bool?> createdAnotherFutureTransaction = const Value.absent(),
            Value<String?> objectiveLoanFk = const Value.absent(),
            Value<String> syncId = const Value.absent(),
            Value<double?> remainingAmount = const Value.absent(),
            Value<int?> parentTransactionId = const Value.absent(),
          }) =>
              TransactionsTableCompanion(
            id: id,
            title: title,
            note: note,
            amount: amount,
            categoryId: categoryId,
            accountId: accountId,
            date: date,
            createdAt: createdAt,
            updatedAt: updatedAt,
            transactionType: transactionType,
            specialType: specialType,
            recurrence: recurrence,
            periodLength: periodLength,
            endDate: endDate,
            originalDateDue: originalDateDue,
            transactionState: transactionState,
            paid: paid,
            skipPaid: skipPaid,
            createdAnotherFutureTransaction: createdAnotherFutureTransaction,
            objectiveLoanFk: objectiveLoanFk,
            syncId: syncId,
            remainingAmount: remainingAmount,
            parentTransactionId: parentTransactionId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> note = const Value.absent(),
            required double amount,
            required int categoryId,
            required int accountId,
            required DateTime date,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String?> specialType = const Value.absent(),
            Value<String> recurrence = const Value.absent(),
            Value<int?> periodLength = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<DateTime?> originalDateDue = const Value.absent(),
            Value<String> transactionState = const Value.absent(),
            Value<bool> paid = const Value.absent(),
            Value<bool> skipPaid = const Value.absent(),
            Value<bool?> createdAnotherFutureTransaction = const Value.absent(),
            Value<String?> objectiveLoanFk = const Value.absent(),
            required String syncId,
            Value<double?> remainingAmount = const Value.absent(),
            Value<int?> parentTransactionId = const Value.absent(),
          }) =>
              TransactionsTableCompanion.insert(
            id: id,
            title: title,
            note: note,
            amount: amount,
            categoryId: categoryId,
            accountId: accountId,
            date: date,
            createdAt: createdAt,
            updatedAt: updatedAt,
            transactionType: transactionType,
            specialType: specialType,
            recurrence: recurrence,
            periodLength: periodLength,
            endDate: endDate,
            originalDateDue: originalDateDue,
            transactionState: transactionState,
            paid: paid,
            skipPaid: skipPaid,
            createdAnotherFutureTransaction: createdAnotherFutureTransaction,
            objectiveLoanFk: objectiveLoanFk,
            syncId: syncId,
            remainingAmount: remainingAmount,
            parentTransactionId: parentTransactionId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              accountId = false,
              parentTransactionId = false,
              attachmentsTableRefs = false,
              transactionBudgetsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (attachmentsTableRefs) db.attachmentsTable,
                if (transactionBudgetsTableRefs) db.transactionBudgetsTable
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$TransactionsTableTableReferences._categoryIdTable(db),
                    referencedColumn: $$TransactionsTableTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable:
                        $$TransactionsTableTableReferences._accountIdTable(db),
                    referencedColumn: $$TransactionsTableTableReferences
                        ._accountIdTable(db)
                        .id,
                  ) as T;
                }
                if (parentTransactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentTransactionId,
                    referencedTable: $$TransactionsTableTableReferences
                        ._parentTransactionIdTable(db),
                    referencedColumn: $$TransactionsTableTableReferences
                        ._parentTransactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attachmentsTableRefs)
                    await $_getPrefetchedData<TransactionsTableData,
                            $TransactionsTableTable, AttachmentsTableData>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableTableReferences
                            ._attachmentsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableTableReferences(db, table, p0)
                                .attachmentsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items),
                  if (transactionBudgetsTableRefs)
                    await $_getPrefetchedData<
                            TransactionsTableData,
                            $TransactionsTableTable,
                            TransactionBudgetTableData>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableTableReferences
                            ._transactionBudgetsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableTableReferences(db, table, p0)
                                .transactionBudgetsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTableTable,
    TransactionsTableData,
    $$TransactionsTableTableFilterComposer,
    $$TransactionsTableTableOrderingComposer,
    $$TransactionsTableTableAnnotationComposer,
    $$TransactionsTableTableCreateCompanionBuilder,
    $$TransactionsTableTableUpdateCompanionBuilder,
    (TransactionsTableData, $$TransactionsTableTableReferences),
    TransactionsTableData,
    PrefetchHooks Function(
        {bool categoryId,
        bool accountId,
        bool parentTransactionId,
        bool attachmentsTableRefs,
        bool transactionBudgetsTableRefs})>;
typedef $$BudgetsTableTableCreateCompanionBuilder = BudgetsTableCompanion
    Function({
  Value<int> id,
  required String name,
  required double amount,
  Value<double> spent,
  Value<int?> categoryId,
  required String period,
  required DateTime startDate,
  required DateTime endDate,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String syncId,
  Value<String?> budgetTransactionFilters,
  Value<bool> excludeDebtCreditInstallments,
  Value<bool> excludeObjectiveInstallments,
  Value<String?> walletFks,
  Value<String?> currencyFks,
  Value<String?> sharedReferenceBudgetPk,
  Value<String?> budgetFksExclude,
  Value<String?> normalizeToCurrency,
  Value<bool> isIncomeBudget,
  Value<bool> includeTransferInOutWithSameCurrency,
  Value<bool> includeUpcomingTransactionFromBudget,
  Value<DateTime?> dateCreatedOriginal,
});
typedef $$BudgetsTableTableUpdateCompanionBuilder = BudgetsTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<double> amount,
  Value<double> spent,
  Value<int?> categoryId,
  Value<String> period,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncId,
  Value<String?> budgetTransactionFilters,
  Value<bool> excludeDebtCreditInstallments,
  Value<bool> excludeObjectiveInstallments,
  Value<String?> walletFks,
  Value<String?> currencyFks,
  Value<String?> sharedReferenceBudgetPk,
  Value<String?> budgetFksExclude,
  Value<String?> normalizeToCurrency,
  Value<bool> isIncomeBudget,
  Value<bool> includeTransferInOutWithSameCurrency,
  Value<bool> includeUpcomingTransactionFromBudget,
  Value<DateTime?> dateCreatedOriginal,
});

final class $$BudgetsTableTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTableTable, BudgetTableData> {
  $$BudgetsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTableTable _categoryIdTable(_$AppDatabase db) =>
      db.categoriesTable.createAlias($_aliasNameGenerator(
          db.budgetsTable.categoryId, db.categoriesTable.id));

  $$CategoriesTableTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager =
        $$CategoriesTableTableTableManager($_db, $_db.categoriesTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TransactionBudgetsTableTable,
      List<TransactionBudgetTableData>> _transactionBudgetsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.transactionBudgetsTable,
          aliasName: $_aliasNameGenerator(
              db.budgetsTable.id, db.transactionBudgetsTable.budgetId));

  $$TransactionBudgetsTableTableProcessedTableManager
      get transactionBudgetsTableRefs {
    final manager = $$TransactionBudgetsTableTableTableManager(
            $_db, $_db.transactionBudgetsTable)
        .filter((f) => f.budgetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionBudgetsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BudgetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTableTable> {
  $$BudgetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get spent => $composableBuilder(
      column: $table.spent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get budgetTransactionFilters => $composableBuilder(
      column: $table.budgetTransactionFilters,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get excludeDebtCreditInstallments => $composableBuilder(
      column: $table.excludeDebtCreditInstallments,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get excludeObjectiveInstallments => $composableBuilder(
      column: $table.excludeObjectiveInstallments,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get walletFks => $composableBuilder(
      column: $table.walletFks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyFks => $composableBuilder(
      column: $table.currencyFks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sharedReferenceBudgetPk => $composableBuilder(
      column: $table.sharedReferenceBudgetPk,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get budgetFksExclude => $composableBuilder(
      column: $table.budgetFksExclude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get normalizeToCurrency => $composableBuilder(
      column: $table.normalizeToCurrency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isIncomeBudget => $composableBuilder(
      column: $table.isIncomeBudget,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get includeTransferInOutWithSameCurrency =>
      $composableBuilder(
          column: $table.includeTransferInOutWithSameCurrency,
          builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get includeUpcomingTransactionFromBudget =>
      $composableBuilder(
          column: $table.includeUpcomingTransactionFromBudget,
          builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateCreatedOriginal => $composableBuilder(
      column: $table.dateCreatedOriginal,
      builder: (column) => ColumnFilters(column));

  $$CategoriesTableTableFilterComposer get categoryId {
    final $$CategoriesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableTableFilterComposer(
              $db: $db,
              $table: $db.categoriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> transactionBudgetsTableRefs(
      Expression<bool> Function($$TransactionBudgetsTableTableFilterComposer f)
          f) {
    final $$TransactionBudgetsTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transactionBudgetsTable,
            getReferencedColumn: (t) => t.budgetId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionBudgetsTableTableFilterComposer(
                  $db: $db,
                  $table: $db.transactionBudgetsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$BudgetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTableTable> {
  $$BudgetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get spent => $composableBuilder(
      column: $table.spent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get budgetTransactionFilters => $composableBuilder(
      column: $table.budgetTransactionFilters,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get excludeDebtCreditInstallments => $composableBuilder(
      column: $table.excludeDebtCreditInstallments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get excludeObjectiveInstallments => $composableBuilder(
      column: $table.excludeObjectiveInstallments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get walletFks => $composableBuilder(
      column: $table.walletFks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyFks => $composableBuilder(
      column: $table.currencyFks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sharedReferenceBudgetPk => $composableBuilder(
      column: $table.sharedReferenceBudgetPk,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get budgetFksExclude => $composableBuilder(
      column: $table.budgetFksExclude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get normalizeToCurrency => $composableBuilder(
      column: $table.normalizeToCurrency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isIncomeBudget => $composableBuilder(
      column: $table.isIncomeBudget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get includeTransferInOutWithSameCurrency =>
      $composableBuilder(
          column: $table.includeTransferInOutWithSameCurrency,
          builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get includeUpcomingTransactionFromBudget =>
      $composableBuilder(
          column: $table.includeUpcomingTransactionFromBudget,
          builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateCreatedOriginal => $composableBuilder(
      column: $table.dateCreatedOriginal,
      builder: (column) => ColumnOrderings(column));

  $$CategoriesTableTableOrderingComposer get categoryId {
    final $$CategoriesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableTableOrderingComposer(
              $db: $db,
              $table: $db.categoriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTableTable> {
  $$BudgetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get spent =>
      $composableBuilder(column: $table.spent, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get budgetTransactionFilters => $composableBuilder(
      column: $table.budgetTransactionFilters, builder: (column) => column);

  GeneratedColumn<bool> get excludeDebtCreditInstallments => $composableBuilder(
      column: $table.excludeDebtCreditInstallments,
      builder: (column) => column);

  GeneratedColumn<bool> get excludeObjectiveInstallments => $composableBuilder(
      column: $table.excludeObjectiveInstallments, builder: (column) => column);

  GeneratedColumn<String> get walletFks =>
      $composableBuilder(column: $table.walletFks, builder: (column) => column);

  GeneratedColumn<String> get currencyFks => $composableBuilder(
      column: $table.currencyFks, builder: (column) => column);

  GeneratedColumn<String> get sharedReferenceBudgetPk => $composableBuilder(
      column: $table.sharedReferenceBudgetPk, builder: (column) => column);

  GeneratedColumn<String> get budgetFksExclude => $composableBuilder(
      column: $table.budgetFksExclude, builder: (column) => column);

  GeneratedColumn<String> get normalizeToCurrency => $composableBuilder(
      column: $table.normalizeToCurrency, builder: (column) => column);

  GeneratedColumn<bool> get isIncomeBudget => $composableBuilder(
      column: $table.isIncomeBudget, builder: (column) => column);

  GeneratedColumn<bool> get includeTransferInOutWithSameCurrency =>
      $composableBuilder(
          column: $table.includeTransferInOutWithSameCurrency,
          builder: (column) => column);

  GeneratedColumn<bool> get includeUpcomingTransactionFromBudget =>
      $composableBuilder(
          column: $table.includeUpcomingTransactionFromBudget,
          builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreatedOriginal => $composableBuilder(
      column: $table.dateCreatedOriginal, builder: (column) => column);

  $$CategoriesTableTableAnnotationComposer get categoryId {
    final $$CategoriesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.categoriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> transactionBudgetsTableRefs<T extends Object>(
      Expression<T> Function($$TransactionBudgetsTableTableAnnotationComposer a)
          f) {
    final $$TransactionBudgetsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transactionBudgetsTable,
            getReferencedColumn: (t) => t.budgetId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionBudgetsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionBudgetsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$BudgetsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetsTableTable,
    BudgetTableData,
    $$BudgetsTableTableFilterComposer,
    $$BudgetsTableTableOrderingComposer,
    $$BudgetsTableTableAnnotationComposer,
    $$BudgetsTableTableCreateCompanionBuilder,
    $$BudgetsTableTableUpdateCompanionBuilder,
    (BudgetTableData, $$BudgetsTableTableReferences),
    BudgetTableData,
    PrefetchHooks Function(
        {bool categoryId, bool transactionBudgetsTableRefs})> {
  $$BudgetsTableTableTableManager(_$AppDatabase db, $BudgetsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<double> spent = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncId = const Value.absent(),
            Value<String?> budgetTransactionFilters = const Value.absent(),
            Value<bool> excludeDebtCreditInstallments = const Value.absent(),
            Value<bool> excludeObjectiveInstallments = const Value.absent(),
            Value<String?> walletFks = const Value.absent(),
            Value<String?> currencyFks = const Value.absent(),
            Value<String?> sharedReferenceBudgetPk = const Value.absent(),
            Value<String?> budgetFksExclude = const Value.absent(),
            Value<String?> normalizeToCurrency = const Value.absent(),
            Value<bool> isIncomeBudget = const Value.absent(),
            Value<bool> includeTransferInOutWithSameCurrency =
                const Value.absent(),
            Value<bool> includeUpcomingTransactionFromBudget =
                const Value.absent(),
            Value<DateTime?> dateCreatedOriginal = const Value.absent(),
          }) =>
              BudgetsTableCompanion(
            id: id,
            name: name,
            amount: amount,
            spent: spent,
            categoryId: categoryId,
            period: period,
            startDate: startDate,
            endDate: endDate,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncId: syncId,
            budgetTransactionFilters: budgetTransactionFilters,
            excludeDebtCreditInstallments: excludeDebtCreditInstallments,
            excludeObjectiveInstallments: excludeObjectiveInstallments,
            walletFks: walletFks,
            currencyFks: currencyFks,
            sharedReferenceBudgetPk: sharedReferenceBudgetPk,
            budgetFksExclude: budgetFksExclude,
            normalizeToCurrency: normalizeToCurrency,
            isIncomeBudget: isIncomeBudget,
            includeTransferInOutWithSameCurrency:
                includeTransferInOutWithSameCurrency,
            includeUpcomingTransactionFromBudget:
                includeUpcomingTransactionFromBudget,
            dateCreatedOriginal: dateCreatedOriginal,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required double amount,
            Value<double> spent = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            required String period,
            required DateTime startDate,
            required DateTime endDate,
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            required String syncId,
            Value<String?> budgetTransactionFilters = const Value.absent(),
            Value<bool> excludeDebtCreditInstallments = const Value.absent(),
            Value<bool> excludeObjectiveInstallments = const Value.absent(),
            Value<String?> walletFks = const Value.absent(),
            Value<String?> currencyFks = const Value.absent(),
            Value<String?> sharedReferenceBudgetPk = const Value.absent(),
            Value<String?> budgetFksExclude = const Value.absent(),
            Value<String?> normalizeToCurrency = const Value.absent(),
            Value<bool> isIncomeBudget = const Value.absent(),
            Value<bool> includeTransferInOutWithSameCurrency =
                const Value.absent(),
            Value<bool> includeUpcomingTransactionFromBudget =
                const Value.absent(),
            Value<DateTime?> dateCreatedOriginal = const Value.absent(),
          }) =>
              BudgetsTableCompanion.insert(
            id: id,
            name: name,
            amount: amount,
            spent: spent,
            categoryId: categoryId,
            period: period,
            startDate: startDate,
            endDate: endDate,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncId: syncId,
            budgetTransactionFilters: budgetTransactionFilters,
            excludeDebtCreditInstallments: excludeDebtCreditInstallments,
            excludeObjectiveInstallments: excludeObjectiveInstallments,
            walletFks: walletFks,
            currencyFks: currencyFks,
            sharedReferenceBudgetPk: sharedReferenceBudgetPk,
            budgetFksExclude: budgetFksExclude,
            normalizeToCurrency: normalizeToCurrency,
            isIncomeBudget: isIncomeBudget,
            includeTransferInOutWithSameCurrency:
                includeTransferInOutWithSameCurrency,
            includeUpcomingTransactionFromBudget:
                includeUpcomingTransactionFromBudget,
            dateCreatedOriginal: dateCreatedOriginal,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BudgetsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false, transactionBudgetsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionBudgetsTableRefs) db.transactionBudgetsTable
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$BudgetsTableTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$BudgetsTableTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionBudgetsTableRefs)
                    await $_getPrefetchedData<BudgetTableData,
                            $BudgetsTableTable, TransactionBudgetTableData>(
                        currentTable: table,
                        referencedTable: $$BudgetsTableTableReferences
                            ._transactionBudgetsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BudgetsTableTableReferences(db, table, p0)
                                .transactionBudgetsTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.budgetId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BudgetsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetsTableTable,
    BudgetTableData,
    $$BudgetsTableTableFilterComposer,
    $$BudgetsTableTableOrderingComposer,
    $$BudgetsTableTableAnnotationComposer,
    $$BudgetsTableTableCreateCompanionBuilder,
    $$BudgetsTableTableUpdateCompanionBuilder,
    (BudgetTableData, $$BudgetsTableTableReferences),
    BudgetTableData,
    PrefetchHooks Function(
        {bool categoryId, bool transactionBudgetsTableRefs})>;
typedef $$SyncMetadataTableTableCreateCompanionBuilder
    = SyncMetadataTableCompanion Function({
  Value<int> id,
  required String key,
  required String value,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$SyncMetadataTableTableUpdateCompanionBuilder
    = SyncMetadataTableCompanion Function({
  Value<int> id,
  Value<String> key,
  Value<String> value,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$SyncMetadataTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncMetadataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncMetadataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncMetadataTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncMetadataTableTable,
    SyncMetadataTableData,
    $$SyncMetadataTableTableFilterComposer,
    $$SyncMetadataTableTableOrderingComposer,
    $$SyncMetadataTableTableAnnotationComposer,
    $$SyncMetadataTableTableCreateCompanionBuilder,
    $$SyncMetadataTableTableUpdateCompanionBuilder,
    (
      SyncMetadataTableData,
      BaseReferences<_$AppDatabase, $SyncMetadataTableTable,
          SyncMetadataTableData>
    ),
    SyncMetadataTableData,
    PrefetchHooks Function()> {
  $$SyncMetadataTableTableTableManager(
      _$AppDatabase db, $SyncMetadataTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SyncMetadataTableCompanion(
            id: id,
            key: key,
            value: value,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String key,
            required String value,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SyncMetadataTableCompanion.insert(
            id: id,
            key: key,
            value: value,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetadataTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncMetadataTableTable,
    SyncMetadataTableData,
    $$SyncMetadataTableTableFilterComposer,
    $$SyncMetadataTableTableOrderingComposer,
    $$SyncMetadataTableTableAnnotationComposer,
    $$SyncMetadataTableTableCreateCompanionBuilder,
    $$SyncMetadataTableTableUpdateCompanionBuilder,
    (
      SyncMetadataTableData,
      BaseReferences<_$AppDatabase, $SyncMetadataTableTable,
          SyncMetadataTableData>
    ),
    SyncMetadataTableData,
    PrefetchHooks Function()>;
typedef $$AttachmentsTableTableCreateCompanionBuilder
    = AttachmentsTableCompanion Function({
  Value<int> id,
  required int transactionId,
  required String fileName,
  Value<String?> filePath,
  Value<String?> googleDriveFileId,
  Value<String?> googleDriveLink,
  required int type,
  Value<String?> mimeType,
  Value<int?> fileSizeBytes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isUploaded,
  Value<bool> isDeleted,
  Value<bool> isCapturedFromCamera,
  Value<DateTime?> localCacheExpiry,
  required String syncId,
});
typedef $$AttachmentsTableTableUpdateCompanionBuilder
    = AttachmentsTableCompanion Function({
  Value<int> id,
  Value<int> transactionId,
  Value<String> fileName,
  Value<String?> filePath,
  Value<String?> googleDriveFileId,
  Value<String?> googleDriveLink,
  Value<int> type,
  Value<String?> mimeType,
  Value<int?> fileSizeBytes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isUploaded,
  Value<bool> isDeleted,
  Value<bool> isCapturedFromCamera,
  Value<DateTime?> localCacheExpiry,
  Value<String> syncId,
});

final class $$AttachmentsTableTableReferences extends BaseReferences<
    _$AppDatabase, $AttachmentsTableTable, AttachmentsTableData> {
  $$AttachmentsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTableTable _transactionIdTable(_$AppDatabase db) =>
      db.transactionsTable.createAlias($_aliasNameGenerator(
          db.attachmentsTable.transactionId, db.transactionsTable.id));

  $$TransactionsTableTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager =
        $$TransactionsTableTableTableManager($_db, $_db.transactionsTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AttachmentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTableTable> {
  $$AttachmentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get googleDriveFileId => $composableBuilder(
      column: $table.googleDriveFileId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get googleDriveLink => $composableBuilder(
      column: $table.googleDriveLink,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCapturedFromCamera => $composableBuilder(
      column: $table.isCapturedFromCamera,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localCacheExpiry => $composableBuilder(
      column: $table.localCacheExpiry,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  $$TransactionsTableTableFilterComposer get transactionId {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableFilterComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttachmentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTableTable> {
  $$AttachmentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get googleDriveFileId => $composableBuilder(
      column: $table.googleDriveFileId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get googleDriveLink => $composableBuilder(
      column: $table.googleDriveLink,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCapturedFromCamera => $composableBuilder(
      column: $table.isCapturedFromCamera,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localCacheExpiry => $composableBuilder(
      column: $table.localCacheExpiry,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));

  $$TransactionsTableTableOrderingComposer get transactionId {
    final $$TransactionsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableOrderingComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttachmentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTableTable> {
  $$AttachmentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get googleDriveFileId => $composableBuilder(
      column: $table.googleDriveFileId, builder: (column) => column);

  GeneratedColumn<String> get googleDriveLink => $composableBuilder(
      column: $table.googleDriveLink, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isCapturedFromCamera => $composableBuilder(
      column: $table.isCapturedFromCamera, builder: (column) => column);

  GeneratedColumn<DateTime> get localCacheExpiry => $composableBuilder(
      column: $table.localCacheExpiry, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  $$TransactionsTableTableAnnotationComposer get transactionId {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.transactionId,
            referencedTable: $db.transactionsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$AttachmentsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttachmentsTableTable,
    AttachmentsTableData,
    $$AttachmentsTableTableFilterComposer,
    $$AttachmentsTableTableOrderingComposer,
    $$AttachmentsTableTableAnnotationComposer,
    $$AttachmentsTableTableCreateCompanionBuilder,
    $$AttachmentsTableTableUpdateCompanionBuilder,
    (AttachmentsTableData, $$AttachmentsTableTableReferences),
    AttachmentsTableData,
    PrefetchHooks Function({bool transactionId})> {
  $$AttachmentsTableTableTableManager(
      _$AppDatabase db, $AttachmentsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<String?> googleDriveFileId = const Value.absent(),
            Value<String?> googleDriveLink = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isUploaded = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isCapturedFromCamera = const Value.absent(),
            Value<DateTime?> localCacheExpiry = const Value.absent(),
            Value<String> syncId = const Value.absent(),
          }) =>
              AttachmentsTableCompanion(
            id: id,
            transactionId: transactionId,
            fileName: fileName,
            filePath: filePath,
            googleDriveFileId: googleDriveFileId,
            googleDriveLink: googleDriveLink,
            type: type,
            mimeType: mimeType,
            fileSizeBytes: fileSizeBytes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isUploaded: isUploaded,
            isDeleted: isDeleted,
            isCapturedFromCamera: isCapturedFromCamera,
            localCacheExpiry: localCacheExpiry,
            syncId: syncId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required String fileName,
            Value<String?> filePath = const Value.absent(),
            Value<String?> googleDriveFileId = const Value.absent(),
            Value<String?> googleDriveLink = const Value.absent(),
            required int type,
            Value<String?> mimeType = const Value.absent(),
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isUploaded = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isCapturedFromCamera = const Value.absent(),
            Value<DateTime?> localCacheExpiry = const Value.absent(),
            required String syncId,
          }) =>
              AttachmentsTableCompanion.insert(
            id: id,
            transactionId: transactionId,
            fileName: fileName,
            filePath: filePath,
            googleDriveFileId: googleDriveFileId,
            googleDriveLink: googleDriveLink,
            type: type,
            mimeType: mimeType,
            fileSizeBytes: fileSizeBytes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isUploaded: isUploaded,
            isDeleted: isDeleted,
            isCapturedFromCamera: isCapturedFromCamera,
            localCacheExpiry: localCacheExpiry,
            syncId: syncId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AttachmentsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable: $$AttachmentsTableTableReferences
                        ._transactionIdTable(db),
                    referencedColumn: $$AttachmentsTableTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AttachmentsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttachmentsTableTable,
    AttachmentsTableData,
    $$AttachmentsTableTableFilterComposer,
    $$AttachmentsTableTableOrderingComposer,
    $$AttachmentsTableTableAnnotationComposer,
    $$AttachmentsTableTableCreateCompanionBuilder,
    $$AttachmentsTableTableUpdateCompanionBuilder,
    (AttachmentsTableData, $$AttachmentsTableTableReferences),
    AttachmentsTableData,
    PrefetchHooks Function({bool transactionId})>;
typedef $$SyncEventLogTableTableCreateCompanionBuilder
    = SyncEventLogTableCompanion Function({
  Value<int> id,
  required String eventId,
  required String deviceId,
  required String tableNameField,
  required String recordId,
  required String operation,
  required String data,
  required DateTime timestamp,
  required int sequenceNumber,
  required String hash,
  Value<bool> isSynced,
});
typedef $$SyncEventLogTableTableUpdateCompanionBuilder
    = SyncEventLogTableCompanion Function({
  Value<int> id,
  Value<String> eventId,
  Value<String> deviceId,
  Value<String> tableNameField,
  Value<String> recordId,
  Value<String> operation,
  Value<String> data,
  Value<DateTime> timestamp,
  Value<int> sequenceNumber,
  Value<String> hash,
  Value<bool> isSynced,
});

class $$SyncEventLogTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncEventLogTableTable> {
  $$SyncEventLogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tableNameField => $composableBuilder(
      column: $table.tableNameField,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
      column: $table.sequenceNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));
}

class $$SyncEventLogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncEventLogTableTable> {
  $$SyncEventLogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tableNameField => $composableBuilder(
      column: $table.tableNameField,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
      column: $table.sequenceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));
}

class $$SyncEventLogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncEventLogTableTable> {
  $$SyncEventLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get tableNameField => $composableBuilder(
      column: $table.tableNameField, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
      column: $table.sequenceNumber, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$SyncEventLogTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncEventLogTableTable,
    SyncEventLogData,
    $$SyncEventLogTableTableFilterComposer,
    $$SyncEventLogTableTableOrderingComposer,
    $$SyncEventLogTableTableAnnotationComposer,
    $$SyncEventLogTableTableCreateCompanionBuilder,
    $$SyncEventLogTableTableUpdateCompanionBuilder,
    (
      SyncEventLogData,
      BaseReferences<_$AppDatabase, $SyncEventLogTableTable, SyncEventLogData>
    ),
    SyncEventLogData,
    PrefetchHooks Function()> {
  $$SyncEventLogTableTableTableManager(
      _$AppDatabase db, $SyncEventLogTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncEventLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncEventLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncEventLogTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> eventId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> tableNameField = const Value.absent(),
            Value<String> recordId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> sequenceNumber = const Value.absent(),
            Value<String> hash = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              SyncEventLogTableCompanion(
            id: id,
            eventId: eventId,
            deviceId: deviceId,
            tableNameField: tableNameField,
            recordId: recordId,
            operation: operation,
            data: data,
            timestamp: timestamp,
            sequenceNumber: sequenceNumber,
            hash: hash,
            isSynced: isSynced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String eventId,
            required String deviceId,
            required String tableNameField,
            required String recordId,
            required String operation,
            required String data,
            required DateTime timestamp,
            required int sequenceNumber,
            required String hash,
            Value<bool> isSynced = const Value.absent(),
          }) =>
              SyncEventLogTableCompanion.insert(
            id: id,
            eventId: eventId,
            deviceId: deviceId,
            tableNameField: tableNameField,
            recordId: recordId,
            operation: operation,
            data: data,
            timestamp: timestamp,
            sequenceNumber: sequenceNumber,
            hash: hash,
            isSynced: isSynced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncEventLogTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncEventLogTableTable,
    SyncEventLogData,
    $$SyncEventLogTableTableFilterComposer,
    $$SyncEventLogTableTableOrderingComposer,
    $$SyncEventLogTableTableAnnotationComposer,
    $$SyncEventLogTableTableCreateCompanionBuilder,
    $$SyncEventLogTableTableUpdateCompanionBuilder,
    (
      SyncEventLogData,
      BaseReferences<_$AppDatabase, $SyncEventLogTableTable, SyncEventLogData>
    ),
    SyncEventLogData,
    PrefetchHooks Function()>;
typedef $$SyncStateTableTableCreateCompanionBuilder = SyncStateTableCompanion
    Function({
  Value<int> id,
  required String deviceId,
  required DateTime lastSyncTime,
  Value<int> lastSequenceNumber,
  Value<String> status,
});
typedef $$SyncStateTableTableUpdateCompanionBuilder = SyncStateTableCompanion
    Function({
  Value<int> id,
  Value<String> deviceId,
  Value<DateTime> lastSyncTime,
  Value<int> lastSequenceNumber,
  Value<String> status,
});

class $$SyncStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncTime => $composableBuilder(
      column: $table.lastSyncTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastSequenceNumber => $composableBuilder(
      column: $table.lastSequenceNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$SyncStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncTime => $composableBuilder(
      column: $table.lastSyncTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastSequenceNumber => $composableBuilder(
      column: $table.lastSequenceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$SyncStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncTime => $composableBuilder(
      column: $table.lastSyncTime, builder: (column) => column);

  GeneratedColumn<int> get lastSequenceNumber => $composableBuilder(
      column: $table.lastSequenceNumber, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncStateTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncStateTableTable,
    SyncStateData,
    $$SyncStateTableTableFilterComposer,
    $$SyncStateTableTableOrderingComposer,
    $$SyncStateTableTableAnnotationComposer,
    $$SyncStateTableTableCreateCompanionBuilder,
    $$SyncStateTableTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$AppDatabase, $SyncStateTableTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()> {
  $$SyncStateTableTableTableManager(
      _$AppDatabase db, $SyncStateTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> lastSyncTime = const Value.absent(),
            Value<int> lastSequenceNumber = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              SyncStateTableCompanion(
            id: id,
            deviceId: deviceId,
            lastSyncTime: lastSyncTime,
            lastSequenceNumber: lastSequenceNumber,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String deviceId,
            required DateTime lastSyncTime,
            Value<int> lastSequenceNumber = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              SyncStateTableCompanion.insert(
            id: id,
            deviceId: deviceId,
            lastSyncTime: lastSyncTime,
            lastSequenceNumber: lastSequenceNumber,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStateTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncStateTableTable,
    SyncStateData,
    $$SyncStateTableTableFilterComposer,
    $$SyncStateTableTableOrderingComposer,
    $$SyncStateTableTableAnnotationComposer,
    $$SyncStateTableTableCreateCompanionBuilder,
    $$SyncStateTableTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$AppDatabase, $SyncStateTableTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()>;
typedef $$TransactionBudgetsTableTableCreateCompanionBuilder
    = TransactionBudgetsTableCompanion Function({
  Value<int> id,
  required int transactionId,
  required int budgetId,
  Value<double> amount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String syncId,
});
typedef $$TransactionBudgetsTableTableUpdateCompanionBuilder
    = TransactionBudgetsTableCompanion Function({
  Value<int> id,
  Value<int> transactionId,
  Value<int> budgetId,
  Value<double> amount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncId,
});

final class $$TransactionBudgetsTableTableReferences extends BaseReferences<
    _$AppDatabase, $TransactionBudgetsTableTable, TransactionBudgetTableData> {
  $$TransactionBudgetsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTableTable _transactionIdTable(_$AppDatabase db) =>
      db.transactionsTable.createAlias($_aliasNameGenerator(
          db.transactionBudgetsTable.transactionId, db.transactionsTable.id));

  $$TransactionsTableTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager =
        $$TransactionsTableTableTableManager($_db, $_db.transactionsTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BudgetsTableTable _budgetIdTable(_$AppDatabase db) =>
      db.budgetsTable.createAlias($_aliasNameGenerator(
          db.transactionBudgetsTable.budgetId, db.budgetsTable.id));

  $$BudgetsTableTableProcessedTableManager get budgetId {
    final $_column = $_itemColumn<int>('budget_id')!;

    final manager = $$BudgetsTableTableTableManager($_db, $_db.budgetsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_budgetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TransactionBudgetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionBudgetsTableTable> {
  $$TransactionBudgetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  $$TransactionsTableTableFilterComposer get transactionId {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableFilterComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BudgetsTableTableFilterComposer get budgetId {
    final $$BudgetsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgetsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableTableFilterComposer(
              $db: $db,
              $table: $db.budgetsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionBudgetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionBudgetsTableTable> {
  $$TransactionBudgetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));

  $$TransactionsTableTableOrderingComposer get transactionId {
    final $$TransactionsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableOrderingComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BudgetsTableTableOrderingComposer get budgetId {
    final $$BudgetsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgetsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableTableOrderingComposer(
              $db: $db,
              $table: $db.budgetsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionBudgetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionBudgetsTableTable> {
  $$TransactionBudgetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  $$TransactionsTableTableAnnotationComposer get transactionId {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.transactionId,
            referencedTable: $db.transactionsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$BudgetsTableTableAnnotationComposer get budgetId {
    final $$BudgetsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgetsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.budgetsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionBudgetsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionBudgetsTableTable,
    TransactionBudgetTableData,
    $$TransactionBudgetsTableTableFilterComposer,
    $$TransactionBudgetsTableTableOrderingComposer,
    $$TransactionBudgetsTableTableAnnotationComposer,
    $$TransactionBudgetsTableTableCreateCompanionBuilder,
    $$TransactionBudgetsTableTableUpdateCompanionBuilder,
    (TransactionBudgetTableData, $$TransactionBudgetsTableTableReferences),
    TransactionBudgetTableData,
    PrefetchHooks Function({bool transactionId, bool budgetId})> {
  $$TransactionBudgetsTableTableTableManager(
      _$AppDatabase db, $TransactionBudgetsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionBudgetsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionBudgetsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionBudgetsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<int> budgetId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncId = const Value.absent(),
          }) =>
              TransactionBudgetsTableCompanion(
            id: id,
            transactionId: transactionId,
            budgetId: budgetId,
            amount: amount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncId: syncId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required int budgetId,
            Value<double> amount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            required String syncId,
          }) =>
              TransactionBudgetsTableCompanion.insert(
            id: id,
            transactionId: transactionId,
            budgetId: budgetId,
            amount: amount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncId: syncId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionBudgetsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false, budgetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable: $$TransactionBudgetsTableTableReferences
                        ._transactionIdTable(db),
                    referencedColumn: $$TransactionBudgetsTableTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }
                if (budgetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.budgetId,
                    referencedTable: $$TransactionBudgetsTableTableReferences
                        ._budgetIdTable(db),
                    referencedColumn: $$TransactionBudgetsTableTableReferences
                        ._budgetIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TransactionBudgetsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TransactionBudgetsTableTable,
        TransactionBudgetTableData,
        $$TransactionBudgetsTableTableFilterComposer,
        $$TransactionBudgetsTableTableOrderingComposer,
        $$TransactionBudgetsTableTableAnnotationComposer,
        $$TransactionBudgetsTableTableCreateCompanionBuilder,
        $$TransactionBudgetsTableTableUpdateCompanionBuilder,
        (TransactionBudgetTableData, $$TransactionBudgetsTableTableReferences),
        TransactionBudgetTableData,
        PrefetchHooks Function({bool transactionId, bool budgetId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(_db, _db.categoriesTable);
  $$AccountsTableTableTableManager get accountsTable =>
      $$AccountsTableTableTableManager(_db, _db.accountsTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$BudgetsTableTableTableManager get budgetsTable =>
      $$BudgetsTableTableTableManager(_db, _db.budgetsTable);
  $$SyncMetadataTableTableTableManager get syncMetadataTable =>
      $$SyncMetadataTableTableTableManager(_db, _db.syncMetadataTable);
  $$AttachmentsTableTableTableManager get attachmentsTable =>
      $$AttachmentsTableTableTableManager(_db, _db.attachmentsTable);
  $$SyncEventLogTableTableTableManager get syncEventLogTable =>
      $$SyncEventLogTableTableTableManager(_db, _db.syncEventLogTable);
  $$SyncStateTableTableTableManager get syncStateTable =>
      $$SyncStateTableTableTableManager(_db, _db.syncStateTable);
  $$TransactionBudgetsTableTableTableManager get transactionBudgetsTable =>
      $$TransactionBudgetsTableTableTableManager(
          _db, _db.transactionBudgetsTable);
}
