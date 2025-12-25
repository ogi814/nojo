// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayerStatesTable extends PlayerStates
    with TableInfo<$PlayerStatesTable, PlayerState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _moneyMeta = const VerificationMeta('money');
  @override
  late final GeneratedColumn<int> money = GeneratedColumn<int>(
    'money',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _staminaMeta = const VerificationMeta(
    'stamina',
  );
  @override
  late final GeneratedColumn<double> stamina = GeneratedColumn<double>(
    'stamina',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(100.0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, money, stamina];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('money')) {
      context.handle(
        _moneyMeta,
        money.isAcceptableOrUnknown(data['money']!, _moneyMeta),
      );
    }
    if (data.containsKey('stamina')) {
      context.handle(
        _staminaMeta,
        stamina.isAcceptableOrUnknown(data['stamina']!, _staminaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      money: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}money'],
      )!,
      stamina: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stamina'],
      )!,
    );
  }

  @override
  $PlayerStatesTable createAlias(String alias) {
    return $PlayerStatesTable(attachedDatabase, alias);
  }
}

class PlayerState extends DataClass implements Insertable<PlayerState> {
  final int id;
  final int money;
  final double stamina;
  const PlayerState({
    required this.id,
    required this.money,
    required this.stamina,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['money'] = Variable<int>(money);
    map['stamina'] = Variable<double>(stamina);
    return map;
  }

  PlayerStatesCompanion toCompanion(bool nullToAbsent) {
    return PlayerStatesCompanion(
      id: Value(id),
      money: Value(money),
      stamina: Value(stamina),
    );
  }

  factory PlayerState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerState(
      id: serializer.fromJson<int>(json['id']),
      money: serializer.fromJson<int>(json['money']),
      stamina: serializer.fromJson<double>(json['stamina']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'money': serializer.toJson<int>(money),
      'stamina': serializer.toJson<double>(stamina),
    };
  }

  PlayerState copyWith({int? id, int? money, double? stamina}) => PlayerState(
    id: id ?? this.id,
    money: money ?? this.money,
    stamina: stamina ?? this.stamina,
  );
  PlayerState copyWithCompanion(PlayerStatesCompanion data) {
    return PlayerState(
      id: data.id.present ? data.id.value : this.id,
      money: data.money.present ? data.money.value : this.money,
      stamina: data.stamina.present ? data.stamina.value : this.stamina,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerState(')
          ..write('id: $id, ')
          ..write('money: $money, ')
          ..write('stamina: $stamina')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, money, stamina);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerState &&
          other.id == this.id &&
          other.money == this.money &&
          other.stamina == this.stamina);
}

class PlayerStatesCompanion extends UpdateCompanion<PlayerState> {
  final Value<int> id;
  final Value<int> money;
  final Value<double> stamina;
  const PlayerStatesCompanion({
    this.id = const Value.absent(),
    this.money = const Value.absent(),
    this.stamina = const Value.absent(),
  });
  PlayerStatesCompanion.insert({
    this.id = const Value.absent(),
    this.money = const Value.absent(),
    this.stamina = const Value.absent(),
  });
  static Insertable<PlayerState> custom({
    Expression<int>? id,
    Expression<int>? money,
    Expression<double>? stamina,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (money != null) 'money': money,
      if (stamina != null) 'stamina': stamina,
    });
  }

  PlayerStatesCompanion copyWith({
    Value<int>? id,
    Value<int>? money,
    Value<double>? stamina,
  }) {
    return PlayerStatesCompanion(
      id: id ?? this.id,
      money: money ?? this.money,
      stamina: stamina ?? this.stamina,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (money.present) {
      map['money'] = Variable<int>(money.value);
    }
    if (stamina.present) {
      map['stamina'] = Variable<double>(stamina.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerStatesCompanion(')
          ..write('id: $id, ')
          ..write('money: $money, ')
          ..write('stamina: $stamina')
          ..write(')'))
        .toString();
  }
}

class $InventoryItemsTable extends InventoryItems
    with TableInfo<$InventoryItemsTable, InventoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _itemCodeMeta = const VerificationMeta(
    'itemCode',
  );
  @override
  late final GeneratedColumn<String> itemCode = GeneratedColumn<String>(
    'item_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, itemCode, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_code')) {
      context.handle(
        _itemCodeMeta,
        itemCode.isAcceptableOrUnknown(data['item_code']!, _itemCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemCodeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_code'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $InventoryItemsTable createAlias(String alias) {
    return $InventoryItemsTable(attachedDatabase, alias);
  }
}

class InventoryItem extends DataClass implements Insertable<InventoryItem> {
  final int id;
  final String itemCode;
  final int quantity;
  const InventoryItem({
    required this.id,
    required this.itemCode,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_code'] = Variable<String>(itemCode);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  InventoryItemsCompanion toCompanion(bool nullToAbsent) {
    return InventoryItemsCompanion(
      id: Value(id),
      itemCode: Value(itemCode),
      quantity: Value(quantity),
    );
  }

  factory InventoryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryItem(
      id: serializer.fromJson<int>(json['id']),
      itemCode: serializer.fromJson<String>(json['itemCode']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemCode': serializer.toJson<String>(itemCode),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  InventoryItem copyWith({int? id, String? itemCode, int? quantity}) =>
      InventoryItem(
        id: id ?? this.id,
        itemCode: itemCode ?? this.itemCode,
        quantity: quantity ?? this.quantity,
      );
  InventoryItem copyWithCompanion(InventoryItemsCompanion data) {
    return InventoryItem(
      id: data.id.present ? data.id.value : this.id,
      itemCode: data.itemCode.present ? data.itemCode.value : this.itemCode,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItem(')
          ..write('id: $id, ')
          ..write('itemCode: $itemCode, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemCode, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryItem &&
          other.id == this.id &&
          other.itemCode == this.itemCode &&
          other.quantity == this.quantity);
}

class InventoryItemsCompanion extends UpdateCompanion<InventoryItem> {
  final Value<int> id;
  final Value<String> itemCode;
  final Value<int> quantity;
  const InventoryItemsCompanion({
    this.id = const Value.absent(),
    this.itemCode = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  InventoryItemsCompanion.insert({
    this.id = const Value.absent(),
    required String itemCode,
    required int quantity,
  }) : itemCode = Value(itemCode),
       quantity = Value(quantity);
  static Insertable<InventoryItem> custom({
    Expression<int>? id,
    Expression<String>? itemCode,
    Expression<int>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemCode != null) 'item_code': itemCode,
      if (quantity != null) 'quantity': quantity,
    });
  }

  InventoryItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? itemCode,
    Value<int>? quantity,
  }) {
    return InventoryItemsCompanion(
      id: id ?? this.id,
      itemCode: itemCode ?? this.itemCode,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemCode.present) {
      map['item_code'] = Variable<String>(itemCode.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('itemCode: $itemCode, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

class $FarmPlotsTable extends FarmPlots
    with TableInfo<$FarmPlotsTable, FarmPlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmPlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<int> x = GeneratedColumn<int>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<int> y = GeneratedColumn<int>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cropCodeMeta = const VerificationMeta(
    'cropCode',
  );
  @override
  late final GeneratedColumn<String> cropCode = GeneratedColumn<String>(
    'crop_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _growthStageMeta = const VerificationMeta(
    'growthStage',
  );
  @override
  late final GeneratedColumn<int> growthStage = GeneratedColumn<int>(
    'growth_stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wateredAtMeta = const VerificationMeta(
    'wateredAt',
  );
  @override
  late final GeneratedColumn<String> wateredAt = GeneratedColumn<String>(
    'watered_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    x,
    y,
    cropCode,
    growthStage,
    wateredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_plots';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmPlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('crop_code')) {
      context.handle(
        _cropCodeMeta,
        cropCode.isAcceptableOrUnknown(data['crop_code']!, _cropCodeMeta),
      );
    }
    if (data.containsKey('growth_stage')) {
      context.handle(
        _growthStageMeta,
        growthStage.isAcceptableOrUnknown(
          data['growth_stage']!,
          _growthStageMeta,
        ),
      );
    }
    if (data.containsKey('watered_at')) {
      context.handle(
        _wateredAtMeta,
        wateredAt.isAcceptableOrUnknown(data['watered_at']!, _wateredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmPlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmPlot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}y'],
      )!,
      cropCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop_code'],
      ),
      growthStage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}growth_stage'],
      )!,
      wateredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}watered_at'],
      ),
    );
  }

  @override
  $FarmPlotsTable createAlias(String alias) {
    return $FarmPlotsTable(attachedDatabase, alias);
  }
}

class FarmPlot extends DataClass implements Insertable<FarmPlot> {
  final int id;
  final int x;
  final int y;
  final String? cropCode;
  final int growthStage;
  final String? wateredAt;
  const FarmPlot({
    required this.id,
    required this.x,
    required this.y,
    this.cropCode,
    required this.growthStage,
    this.wateredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['x'] = Variable<int>(x);
    map['y'] = Variable<int>(y);
    if (!nullToAbsent || cropCode != null) {
      map['crop_code'] = Variable<String>(cropCode);
    }
    map['growth_stage'] = Variable<int>(growthStage);
    if (!nullToAbsent || wateredAt != null) {
      map['watered_at'] = Variable<String>(wateredAt);
    }
    return map;
  }

  FarmPlotsCompanion toCompanion(bool nullToAbsent) {
    return FarmPlotsCompanion(
      id: Value(id),
      x: Value(x),
      y: Value(y),
      cropCode: cropCode == null && nullToAbsent
          ? const Value.absent()
          : Value(cropCode),
      growthStage: Value(growthStage),
      wateredAt: wateredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(wateredAt),
    );
  }

  factory FarmPlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmPlot(
      id: serializer.fromJson<int>(json['id']),
      x: serializer.fromJson<int>(json['x']),
      y: serializer.fromJson<int>(json['y']),
      cropCode: serializer.fromJson<String?>(json['cropCode']),
      growthStage: serializer.fromJson<int>(json['growthStage']),
      wateredAt: serializer.fromJson<String?>(json['wateredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'x': serializer.toJson<int>(x),
      'y': serializer.toJson<int>(y),
      'cropCode': serializer.toJson<String?>(cropCode),
      'growthStage': serializer.toJson<int>(growthStage),
      'wateredAt': serializer.toJson<String?>(wateredAt),
    };
  }

  FarmPlot copyWith({
    int? id,
    int? x,
    int? y,
    Value<String?> cropCode = const Value.absent(),
    int? growthStage,
    Value<String?> wateredAt = const Value.absent(),
  }) => FarmPlot(
    id: id ?? this.id,
    x: x ?? this.x,
    y: y ?? this.y,
    cropCode: cropCode.present ? cropCode.value : this.cropCode,
    growthStage: growthStage ?? this.growthStage,
    wateredAt: wateredAt.present ? wateredAt.value : this.wateredAt,
  );
  FarmPlot copyWithCompanion(FarmPlotsCompanion data) {
    return FarmPlot(
      id: data.id.present ? data.id.value : this.id,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      cropCode: data.cropCode.present ? data.cropCode.value : this.cropCode,
      growthStage: data.growthStage.present
          ? data.growthStage.value
          : this.growthStage,
      wateredAt: data.wateredAt.present ? data.wateredAt.value : this.wateredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmPlot(')
          ..write('id: $id, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('cropCode: $cropCode, ')
          ..write('growthStage: $growthStage, ')
          ..write('wateredAt: $wateredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, x, y, cropCode, growthStage, wateredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmPlot &&
          other.id == this.id &&
          other.x == this.x &&
          other.y == this.y &&
          other.cropCode == this.cropCode &&
          other.growthStage == this.growthStage &&
          other.wateredAt == this.wateredAt);
}

class FarmPlotsCompanion extends UpdateCompanion<FarmPlot> {
  final Value<int> id;
  final Value<int> x;
  final Value<int> y;
  final Value<String?> cropCode;
  final Value<int> growthStage;
  final Value<String?> wateredAt;
  const FarmPlotsCompanion({
    this.id = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.cropCode = const Value.absent(),
    this.growthStage = const Value.absent(),
    this.wateredAt = const Value.absent(),
  });
  FarmPlotsCompanion.insert({
    this.id = const Value.absent(),
    required int x,
    required int y,
    this.cropCode = const Value.absent(),
    this.growthStage = const Value.absent(),
    this.wateredAt = const Value.absent(),
  }) : x = Value(x),
       y = Value(y);
  static Insertable<FarmPlot> custom({
    Expression<int>? id,
    Expression<int>? x,
    Expression<int>? y,
    Expression<String>? cropCode,
    Expression<int>? growthStage,
    Expression<String>? wateredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (cropCode != null) 'crop_code': cropCode,
      if (growthStage != null) 'growth_stage': growthStage,
      if (wateredAt != null) 'watered_at': wateredAt,
    });
  }

  FarmPlotsCompanion copyWith({
    Value<int>? id,
    Value<int>? x,
    Value<int>? y,
    Value<String?>? cropCode,
    Value<int>? growthStage,
    Value<String?>? wateredAt,
  }) {
    return FarmPlotsCompanion(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      cropCode: cropCode ?? this.cropCode,
      growthStage: growthStage ?? this.growthStage,
      wateredAt: wateredAt ?? this.wateredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (x.present) {
      map['x'] = Variable<int>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<int>(y.value);
    }
    if (cropCode.present) {
      map['crop_code'] = Variable<String>(cropCode.value);
    }
    if (growthStage.present) {
      map['growth_stage'] = Variable<int>(growthStage.value);
    }
    if (wateredAt.present) {
      map['watered_at'] = Variable<String>(wateredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmPlotsCompanion(')
          ..write('id: $id, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('cropCode: $cropCode, ')
          ..write('growthStage: $growthStage, ')
          ..write('wateredAt: $wateredAt')
          ..write(')'))
        .toString();
  }
}

class $AnimalsTable extends Animals with TableInfo<$AnimalsTable, Animal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeCodeMeta = const VerificationMeta(
    'typeCode',
  );
  @override
  late final GeneratedColumn<String> typeCode = GeneratedColumn<String>(
    'type_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _friendshipMeta = const VerificationMeta(
    'friendship',
  );
  @override
  late final GeneratedColumn<int> friendship = GeneratedColumn<int>(
    'friendship',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, typeCode, name, friendship];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Animal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type_code')) {
      context.handle(
        _typeCodeMeta,
        typeCode.isAcceptableOrUnknown(data['type_code']!, _typeCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('friendship')) {
      context.handle(
        _friendshipMeta,
        friendship.isAcceptableOrUnknown(data['friendship']!, _friendshipMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Animal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Animal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      typeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      friendship: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}friendship'],
      )!,
    );
  }

  @override
  $AnimalsTable createAlias(String alias) {
    return $AnimalsTable(attachedDatabase, alias);
  }
}

class Animal extends DataClass implements Insertable<Animal> {
  final int id;
  final String typeCode;
  final String name;
  final int friendship;
  const Animal({
    required this.id,
    required this.typeCode,
    required this.name,
    required this.friendship,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type_code'] = Variable<String>(typeCode);
    map['name'] = Variable<String>(name);
    map['friendship'] = Variable<int>(friendship);
    return map;
  }

  AnimalsCompanion toCompanion(bool nullToAbsent) {
    return AnimalsCompanion(
      id: Value(id),
      typeCode: Value(typeCode),
      name: Value(name),
      friendship: Value(friendship),
    );
  }

  factory Animal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Animal(
      id: serializer.fromJson<int>(json['id']),
      typeCode: serializer.fromJson<String>(json['typeCode']),
      name: serializer.fromJson<String>(json['name']),
      friendship: serializer.fromJson<int>(json['friendship']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'typeCode': serializer.toJson<String>(typeCode),
      'name': serializer.toJson<String>(name),
      'friendship': serializer.toJson<int>(friendship),
    };
  }

  Animal copyWith({int? id, String? typeCode, String? name, int? friendship}) =>
      Animal(
        id: id ?? this.id,
        typeCode: typeCode ?? this.typeCode,
        name: name ?? this.name,
        friendship: friendship ?? this.friendship,
      );
  Animal copyWithCompanion(AnimalsCompanion data) {
    return Animal(
      id: data.id.present ? data.id.value : this.id,
      typeCode: data.typeCode.present ? data.typeCode.value : this.typeCode,
      name: data.name.present ? data.name.value : this.name,
      friendship: data.friendship.present
          ? data.friendship.value
          : this.friendship,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Animal(')
          ..write('id: $id, ')
          ..write('typeCode: $typeCode, ')
          ..write('name: $name, ')
          ..write('friendship: $friendship')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, typeCode, name, friendship);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Animal &&
          other.id == this.id &&
          other.typeCode == this.typeCode &&
          other.name == this.name &&
          other.friendship == this.friendship);
}

class AnimalsCompanion extends UpdateCompanion<Animal> {
  final Value<int> id;
  final Value<String> typeCode;
  final Value<String> name;
  final Value<int> friendship;
  const AnimalsCompanion({
    this.id = const Value.absent(),
    this.typeCode = const Value.absent(),
    this.name = const Value.absent(),
    this.friendship = const Value.absent(),
  });
  AnimalsCompanion.insert({
    this.id = const Value.absent(),
    required String typeCode,
    required String name,
    this.friendship = const Value.absent(),
  }) : typeCode = Value(typeCode),
       name = Value(name);
  static Insertable<Animal> custom({
    Expression<int>? id,
    Expression<String>? typeCode,
    Expression<String>? name,
    Expression<int>? friendship,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typeCode != null) 'type_code': typeCode,
      if (name != null) 'name': name,
      if (friendship != null) 'friendship': friendship,
    });
  }

  AnimalsCompanion copyWith({
    Value<int>? id,
    Value<String>? typeCode,
    Value<String>? name,
    Value<int>? friendship,
  }) {
    return AnimalsCompanion(
      id: id ?? this.id,
      typeCode: typeCode ?? this.typeCode,
      name: name ?? this.name,
      friendship: friendship ?? this.friendship,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (typeCode.present) {
      map['type_code'] = Variable<String>(typeCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (friendship.present) {
      map['friendship'] = Variable<int>(friendship.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalsCompanion(')
          ..write('id: $id, ')
          ..write('typeCode: $typeCode, ')
          ..write('name: $name, ')
          ..write('friendship: $friendship')
          ..write(')'))
        .toString();
  }
}

class $ItemDefinitionsTable extends ItemDefinitions
    with TableInfo<$ItemDefinitionsTable, ItemDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellPriceMeta = const VerificationMeta(
    'sellPrice',
  );
  @override
  late final GeneratedColumn<int> sellPrice = GeneratedColumn<int>(
    'sell_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    name,
    description,
    sellPrice,
    itemType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('sell_price')) {
      context.handle(
        _sellPriceMeta,
        sellPrice.isAcceptableOrUnknown(data['sell_price']!, _sellPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_sellPriceMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  ItemDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemDefinition(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      sellPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sell_price'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
    );
  }

  @override
  $ItemDefinitionsTable createAlias(String alias) {
    return $ItemDefinitionsTable(attachedDatabase, alias);
  }
}

class ItemDefinition extends DataClass implements Insertable<ItemDefinition> {
  final String code;
  final String name;
  final String description;
  final int sellPrice;
  final String itemType;
  const ItemDefinition({
    required this.code,
    required this.name,
    required this.description,
    required this.sellPrice,
    required this.itemType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['sell_price'] = Variable<int>(sellPrice);
    map['item_type'] = Variable<String>(itemType);
    return map;
  }

  ItemDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return ItemDefinitionsCompanion(
      code: Value(code),
      name: Value(name),
      description: Value(description),
      sellPrice: Value(sellPrice),
      itemType: Value(itemType),
    );
  }

  factory ItemDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemDefinition(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      sellPrice: serializer.fromJson<int>(json['sellPrice']),
      itemType: serializer.fromJson<String>(json['itemType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'sellPrice': serializer.toJson<int>(sellPrice),
      'itemType': serializer.toJson<String>(itemType),
    };
  }

  ItemDefinition copyWith({
    String? code,
    String? name,
    String? description,
    int? sellPrice,
    String? itemType,
  }) => ItemDefinition(
    code: code ?? this.code,
    name: name ?? this.name,
    description: description ?? this.description,
    sellPrice: sellPrice ?? this.sellPrice,
    itemType: itemType ?? this.itemType,
  );
  ItemDefinition copyWithCompanion(ItemDefinitionsCompanion data) {
    return ItemDefinition(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      sellPrice: data.sellPrice.present ? data.sellPrice.value : this.sellPrice,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemDefinition(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('itemType: $itemType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, name, description, sellPrice, itemType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemDefinition &&
          other.code == this.code &&
          other.name == this.name &&
          other.description == this.description &&
          other.sellPrice == this.sellPrice &&
          other.itemType == this.itemType);
}

class ItemDefinitionsCompanion extends UpdateCompanion<ItemDefinition> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> description;
  final Value<int> sellPrice;
  final Value<String> itemType;
  final Value<int> rowid;
  const ItemDefinitionsCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sellPrice = const Value.absent(),
    this.itemType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemDefinitionsCompanion.insert({
    required String code,
    required String name,
    required String description,
    required int sellPrice,
    required String itemType,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       description = Value(description),
       sellPrice = Value(sellPrice),
       itemType = Value(itemType);
  static Insertable<ItemDefinition> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? sellPrice,
    Expression<String>? itemType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (sellPrice != null) 'sell_price': sellPrice,
      if (itemType != null) 'item_type': itemType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemDefinitionsCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String>? description,
    Value<int>? sellPrice,
    Value<String>? itemType,
    Value<int>? rowid,
  }) {
    return ItemDefinitionsCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      sellPrice: sellPrice ?? this.sellPrice,
      itemType: itemType ?? this.itemType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sellPrice.present) {
      map['sell_price'] = Variable<int>(sellPrice.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemDefinitionsCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('itemType: $itemType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayerStatesTable playerStates = $PlayerStatesTable(this);
  late final $InventoryItemsTable inventoryItems = $InventoryItemsTable(this);
  late final $FarmPlotsTable farmPlots = $FarmPlotsTable(this);
  late final $AnimalsTable animals = $AnimalsTable(this);
  late final $ItemDefinitionsTable itemDefinitions = $ItemDefinitionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playerStates,
    inventoryItems,
    farmPlots,
    animals,
    itemDefinitions,
  ];
}

typedef $$PlayerStatesTableCreateCompanionBuilder =
    PlayerStatesCompanion Function({
      Value<int> id,
      Value<int> money,
      Value<double> stamina,
    });
typedef $$PlayerStatesTableUpdateCompanionBuilder =
    PlayerStatesCompanion Function({
      Value<int> id,
      Value<int> money,
      Value<double> stamina,
    });

class $$PlayerStatesTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerStatesTable> {
  $$PlayerStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get money => $composableBuilder(
    column: $table.money,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stamina => $composableBuilder(
    column: $table.stamina,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerStatesTable> {
  $$PlayerStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get money => $composableBuilder(
    column: $table.money,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stamina => $composableBuilder(
    column: $table.stamina,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerStatesTable> {
  $$PlayerStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get money =>
      $composableBuilder(column: $table.money, builder: (column) => column);

  GeneratedColumn<double> get stamina =>
      $composableBuilder(column: $table.stamina, builder: (column) => column);
}

class $$PlayerStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerStatesTable,
          PlayerState,
          $$PlayerStatesTableFilterComposer,
          $$PlayerStatesTableOrderingComposer,
          $$PlayerStatesTableAnnotationComposer,
          $$PlayerStatesTableCreateCompanionBuilder,
          $$PlayerStatesTableUpdateCompanionBuilder,
          (
            PlayerState,
            BaseReferences<_$AppDatabase, $PlayerStatesTable, PlayerState>,
          ),
          PlayerState,
          PrefetchHooks Function()
        > {
  $$PlayerStatesTableTableManager(_$AppDatabase db, $PlayerStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> money = const Value.absent(),
                Value<double> stamina = const Value.absent(),
              }) =>
                  PlayerStatesCompanion(id: id, money: money, stamina: stamina),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> money = const Value.absent(),
                Value<double> stamina = const Value.absent(),
              }) => PlayerStatesCompanion.insert(
                id: id,
                money: money,
                stamina: stamina,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerStatesTable,
      PlayerState,
      $$PlayerStatesTableFilterComposer,
      $$PlayerStatesTableOrderingComposer,
      $$PlayerStatesTableAnnotationComposer,
      $$PlayerStatesTableCreateCompanionBuilder,
      $$PlayerStatesTableUpdateCompanionBuilder,
      (
        PlayerState,
        BaseReferences<_$AppDatabase, $PlayerStatesTable, PlayerState>,
      ),
      PlayerState,
      PrefetchHooks Function()
    >;
typedef $$InventoryItemsTableCreateCompanionBuilder =
    InventoryItemsCompanion Function({
      Value<int> id,
      required String itemCode,
      required int quantity,
    });
typedef $$InventoryItemsTableUpdateCompanionBuilder =
    InventoryItemsCompanion Function({
      Value<int> id,
      Value<String> itemCode,
      Value<int> quantity,
    });

class $$InventoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemCode => $composableBuilder(
    column: $table.itemCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemCode => $composableBuilder(
    column: $table.itemCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemCode =>
      $composableBuilder(column: $table.itemCode, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$InventoryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryItemsTable,
          InventoryItem,
          $$InventoryItemsTableFilterComposer,
          $$InventoryItemsTableOrderingComposer,
          $$InventoryItemsTableAnnotationComposer,
          $$InventoryItemsTableCreateCompanionBuilder,
          $$InventoryItemsTableUpdateCompanionBuilder,
          (
            InventoryItem,
            BaseReferences<_$AppDatabase, $InventoryItemsTable, InventoryItem>,
          ),
          InventoryItem,
          PrefetchHooks Function()
        > {
  $$InventoryItemsTableTableManager(
    _$AppDatabase db,
    $InventoryItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> itemCode = const Value.absent(),
                Value<int> quantity = const Value.absent(),
              }) => InventoryItemsCompanion(
                id: id,
                itemCode: itemCode,
                quantity: quantity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String itemCode,
                required int quantity,
              }) => InventoryItemsCompanion.insert(
                id: id,
                itemCode: itemCode,
                quantity: quantity,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryItemsTable,
      InventoryItem,
      $$InventoryItemsTableFilterComposer,
      $$InventoryItemsTableOrderingComposer,
      $$InventoryItemsTableAnnotationComposer,
      $$InventoryItemsTableCreateCompanionBuilder,
      $$InventoryItemsTableUpdateCompanionBuilder,
      (
        InventoryItem,
        BaseReferences<_$AppDatabase, $InventoryItemsTable, InventoryItem>,
      ),
      InventoryItem,
      PrefetchHooks Function()
    >;
typedef $$FarmPlotsTableCreateCompanionBuilder =
    FarmPlotsCompanion Function({
      Value<int> id,
      required int x,
      required int y,
      Value<String?> cropCode,
      Value<int> growthStage,
      Value<String?> wateredAt,
    });
typedef $$FarmPlotsTableUpdateCompanionBuilder =
    FarmPlotsCompanion Function({
      Value<int> id,
      Value<int> x,
      Value<int> y,
      Value<String?> cropCode,
      Value<int> growthStage,
      Value<String?> wateredAt,
    });

class $$FarmPlotsTableFilterComposer
    extends Composer<_$AppDatabase, $FarmPlotsTable> {
  $$FarmPlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cropCode => $composableBuilder(
    column: $table.cropCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get growthStage => $composableBuilder(
    column: $table.growthStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wateredAt => $composableBuilder(
    column: $table.wateredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FarmPlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmPlotsTable> {
  $$FarmPlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cropCode => $composableBuilder(
    column: $table.cropCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get growthStage => $composableBuilder(
    column: $table.growthStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wateredAt => $composableBuilder(
    column: $table.wateredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmPlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmPlotsTable> {
  $$FarmPlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<int> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<String> get cropCode =>
      $composableBuilder(column: $table.cropCode, builder: (column) => column);

  GeneratedColumn<int> get growthStage => $composableBuilder(
    column: $table.growthStage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wateredAt =>
      $composableBuilder(column: $table.wateredAt, builder: (column) => column);
}

class $$FarmPlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmPlotsTable,
          FarmPlot,
          $$FarmPlotsTableFilterComposer,
          $$FarmPlotsTableOrderingComposer,
          $$FarmPlotsTableAnnotationComposer,
          $$FarmPlotsTableCreateCompanionBuilder,
          $$FarmPlotsTableUpdateCompanionBuilder,
          (FarmPlot, BaseReferences<_$AppDatabase, $FarmPlotsTable, FarmPlot>),
          FarmPlot,
          PrefetchHooks Function()
        > {
  $$FarmPlotsTableTableManager(_$AppDatabase db, $FarmPlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmPlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmPlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmPlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> x = const Value.absent(),
                Value<int> y = const Value.absent(),
                Value<String?> cropCode = const Value.absent(),
                Value<int> growthStage = const Value.absent(),
                Value<String?> wateredAt = const Value.absent(),
              }) => FarmPlotsCompanion(
                id: id,
                x: x,
                y: y,
                cropCode: cropCode,
                growthStage: growthStage,
                wateredAt: wateredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int x,
                required int y,
                Value<String?> cropCode = const Value.absent(),
                Value<int> growthStage = const Value.absent(),
                Value<String?> wateredAt = const Value.absent(),
              }) => FarmPlotsCompanion.insert(
                id: id,
                x: x,
                y: y,
                cropCode: cropCode,
                growthStage: growthStage,
                wateredAt: wateredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmPlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmPlotsTable,
      FarmPlot,
      $$FarmPlotsTableFilterComposer,
      $$FarmPlotsTableOrderingComposer,
      $$FarmPlotsTableAnnotationComposer,
      $$FarmPlotsTableCreateCompanionBuilder,
      $$FarmPlotsTableUpdateCompanionBuilder,
      (FarmPlot, BaseReferences<_$AppDatabase, $FarmPlotsTable, FarmPlot>),
      FarmPlot,
      PrefetchHooks Function()
    >;
typedef $$AnimalsTableCreateCompanionBuilder =
    AnimalsCompanion Function({
      Value<int> id,
      required String typeCode,
      required String name,
      Value<int> friendship,
    });
typedef $$AnimalsTableUpdateCompanionBuilder =
    AnimalsCompanion Function({
      Value<int> id,
      Value<String> typeCode,
      Value<String> name,
      Value<int> friendship,
    });

class $$AnimalsTableFilterComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeCode => $composableBuilder(
    column: $table.typeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get friendship => $composableBuilder(
    column: $table.friendship,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnimalsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeCode => $composableBuilder(
    column: $table.typeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get friendship => $composableBuilder(
    column: $table.friendship,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnimalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get typeCode =>
      $composableBuilder(column: $table.typeCode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get friendship => $composableBuilder(
    column: $table.friendship,
    builder: (column) => column,
  );
}

class $$AnimalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnimalsTable,
          Animal,
          $$AnimalsTableFilterComposer,
          $$AnimalsTableOrderingComposer,
          $$AnimalsTableAnnotationComposer,
          $$AnimalsTableCreateCompanionBuilder,
          $$AnimalsTableUpdateCompanionBuilder,
          (Animal, BaseReferences<_$AppDatabase, $AnimalsTable, Animal>),
          Animal,
          PrefetchHooks Function()
        > {
  $$AnimalsTableTableManager(_$AppDatabase db, $AnimalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> typeCode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> friendship = const Value.absent(),
              }) => AnimalsCompanion(
                id: id,
                typeCode: typeCode,
                name: name,
                friendship: friendship,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String typeCode,
                required String name,
                Value<int> friendship = const Value.absent(),
              }) => AnimalsCompanion.insert(
                id: id,
                typeCode: typeCode,
                name: name,
                friendship: friendship,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnimalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnimalsTable,
      Animal,
      $$AnimalsTableFilterComposer,
      $$AnimalsTableOrderingComposer,
      $$AnimalsTableAnnotationComposer,
      $$AnimalsTableCreateCompanionBuilder,
      $$AnimalsTableUpdateCompanionBuilder,
      (Animal, BaseReferences<_$AppDatabase, $AnimalsTable, Animal>),
      Animal,
      PrefetchHooks Function()
    >;
typedef $$ItemDefinitionsTableCreateCompanionBuilder =
    ItemDefinitionsCompanion Function({
      required String code,
      required String name,
      required String description,
      required int sellPrice,
      required String itemType,
      Value<int> rowid,
    });
typedef $$ItemDefinitionsTableUpdateCompanionBuilder =
    ItemDefinitionsCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<String> description,
      Value<int> sellPrice,
      Value<String> itemType,
      Value<int> rowid,
    });

class $$ItemDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemDefinitionsTable> {
  $$ItemDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellPrice => $composableBuilder(
    column: $table.sellPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemDefinitionsTable> {
  $$ItemDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellPrice => $composableBuilder(
    column: $table.sellPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemDefinitionsTable> {
  $$ItemDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellPrice =>
      $composableBuilder(column: $table.sellPrice, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);
}

class $$ItemDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemDefinitionsTable,
          ItemDefinition,
          $$ItemDefinitionsTableFilterComposer,
          $$ItemDefinitionsTableOrderingComposer,
          $$ItemDefinitionsTableAnnotationComposer,
          $$ItemDefinitionsTableCreateCompanionBuilder,
          $$ItemDefinitionsTableUpdateCompanionBuilder,
          (
            ItemDefinition,
            BaseReferences<
              _$AppDatabase,
              $ItemDefinitionsTable,
              ItemDefinition
            >,
          ),
          ItemDefinition,
          PrefetchHooks Function()
        > {
  $$ItemDefinitionsTableTableManager(
    _$AppDatabase db,
    $ItemDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemDefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemDefinitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> sellPrice = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemDefinitionsCompanion(
                code: code,
                name: name,
                description: description,
                sellPrice: sellPrice,
                itemType: itemType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required String description,
                required int sellPrice,
                required String itemType,
                Value<int> rowid = const Value.absent(),
              }) => ItemDefinitionsCompanion.insert(
                code: code,
                name: name,
                description: description,
                sellPrice: sellPrice,
                itemType: itemType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemDefinitionsTable,
      ItemDefinition,
      $$ItemDefinitionsTableFilterComposer,
      $$ItemDefinitionsTableOrderingComposer,
      $$ItemDefinitionsTableAnnotationComposer,
      $$ItemDefinitionsTableCreateCompanionBuilder,
      $$ItemDefinitionsTableUpdateCompanionBuilder,
      (
        ItemDefinition,
        BaseReferences<_$AppDatabase, $ItemDefinitionsTable, ItemDefinition>,
      ),
      ItemDefinition,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayerStatesTableTableManager get playerStates =>
      $$PlayerStatesTableTableManager(_db, _db.playerStates);
  $$InventoryItemsTableTableManager get inventoryItems =>
      $$InventoryItemsTableTableManager(_db, _db.inventoryItems);
  $$FarmPlotsTableTableManager get farmPlots =>
      $$FarmPlotsTableTableManager(_db, _db.farmPlots);
  $$AnimalsTableTableManager get animals =>
      $$AnimalsTableTableManager(_db, _db.animals);
  $$ItemDefinitionsTableTableManager get itemDefinitions =>
      $$ItemDefinitionsTableTableManager(_db, _db.itemDefinitions);
}
