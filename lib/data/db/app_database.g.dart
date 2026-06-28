// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconCodePointMeta =
      const VerificationMeta('iconCodePoint');
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
      'icon_code_point', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, iconCodePoint, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(Insertable<Room> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
          _iconCodePointMeta,
          iconCodePoint.isAcceptableOrUnknown(
              data['icon_code_point']!, _iconCodePointMeta));
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconCodePoint: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon_code_point'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final String id;
  final String name;
  final int iconCodePoint;
  final int sortOrder;
  final DateTime createdAt;
  const Room(
      {required this.id,
      required this.name,
      required this.iconCodePoint,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      name: Value(name),
      iconCodePoint: Value(iconCodePoint),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Room.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Room copyWith(
          {String? id,
          String? name,
          int? iconCodePoint,
          int? sortOrder,
          DateTime? createdAt}) =>
      Room(
        id: id ?? this.id,
        name: name ?? this.name,
        iconCodePoint: iconCodePoint ?? this.iconCodePoint,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconCodePoint, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconCodePoint == this.iconCodePoint &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> iconCodePoint;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsCompanion.insert({
    required String id,
    required String name,
    required int iconCodePoint,
    required int sortOrder,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        iconCodePoint = Value(iconCodePoint),
        sortOrder = Value(sortOrder),
        createdAt = Value(createdAt);
  static Insertable<Room> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? iconCodePoint,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? iconCodePoint,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return RoomsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicSetMeta =
      const VerificationMeta('topicSet');
  @override
  late final GeneratedColumn<String> topicSet = GeneratedColumn<String>(
      'topic_set', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _topicStateMeta =
      const VerificationMeta('topicState');
  @override
  late final GeneratedColumn<String> topicState = GeneratedColumn<String>(
      'topic_state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastValueMeta =
      const VerificationMeta('lastValue');
  @override
  late final GeneratedColumn<String> lastValue = GeneratedColumn<String>(
      'last_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isOnMeta = const VerificationMeta('isOn');
  @override
  late final GeneratedColumn<bool> isOn = GeneratedColumn<bool>(
      'is_on', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_on" IN (0, 1))'));
  static const VerificationMeta _iconCodePointMeta =
      const VerificationMeta('iconCodePoint');
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
      'icon_code_point', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        roomId,
        name,
        type,
        topicSet,
        topicState,
        lastValue,
        isOn,
        iconCodePoint,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<Device> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('topic_set')) {
      context.handle(_topicSetMeta,
          topicSet.isAcceptableOrUnknown(data['topic_set']!, _topicSetMeta));
    }
    if (data.containsKey('topic_state')) {
      context.handle(
          _topicStateMeta,
          topicState.isAcceptableOrUnknown(
              data['topic_state']!, _topicStateMeta));
    } else if (isInserting) {
      context.missing(_topicStateMeta);
    }
    if (data.containsKey('last_value')) {
      context.handle(_lastValueMeta,
          lastValue.isAcceptableOrUnknown(data['last_value']!, _lastValueMeta));
    }
    if (data.containsKey('is_on')) {
      context.handle(
          _isOnMeta, isOn.isAcceptableOrUnknown(data['is_on']!, _isOnMeta));
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
          _iconCodePointMeta,
          iconCodePoint.isAcceptableOrUnknown(
              data['icon_code_point']!, _iconCodePointMeta));
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      topicSet: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_set']),
      topicState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_state'])!,
      lastValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_value']),
      isOn: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_on']),
      iconCodePoint: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon_code_point'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String roomId;
  final String name;
  final String type;
  final String? topicSet;
  final String topicState;
  final String? lastValue;
  final bool? isOn;
  final int iconCodePoint;
  final DateTime createdAt;
  const Device(
      {required this.id,
      required this.roomId,
      required this.name,
      required this.type,
      this.topicSet,
      required this.topicState,
      this.lastValue,
      this.isOn,
      required this.iconCodePoint,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['room_id'] = Variable<String>(roomId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || topicSet != null) {
      map['topic_set'] = Variable<String>(topicSet);
    }
    map['topic_state'] = Variable<String>(topicState);
    if (!nullToAbsent || lastValue != null) {
      map['last_value'] = Variable<String>(lastValue);
    }
    if (!nullToAbsent || isOn != null) {
      map['is_on'] = Variable<bool>(isOn);
    }
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      roomId: Value(roomId),
      name: Value(name),
      type: Value(type),
      topicSet: topicSet == null && nullToAbsent
          ? const Value.absent()
          : Value(topicSet),
      topicState: Value(topicState),
      lastValue: lastValue == null && nullToAbsent
          ? const Value.absent()
          : Value(lastValue),
      isOn: isOn == null && nullToAbsent ? const Value.absent() : Value(isOn),
      iconCodePoint: Value(iconCodePoint),
      createdAt: Value(createdAt),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      roomId: serializer.fromJson<String>(json['roomId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      topicSet: serializer.fromJson<String?>(json['topicSet']),
      topicState: serializer.fromJson<String>(json['topicState']),
      lastValue: serializer.fromJson<String?>(json['lastValue']),
      isOn: serializer.fromJson<bool?>(json['isOn']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roomId': serializer.toJson<String>(roomId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'topicSet': serializer.toJson<String?>(topicSet),
      'topicState': serializer.toJson<String>(topicState),
      'lastValue': serializer.toJson<String?>(lastValue),
      'isOn': serializer.toJson<bool?>(isOn),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Device copyWith(
          {String? id,
          String? roomId,
          String? name,
          String? type,
          Value<String?> topicSet = const Value.absent(),
          String? topicState,
          Value<String?> lastValue = const Value.absent(),
          Value<bool?> isOn = const Value.absent(),
          int? iconCodePoint,
          DateTime? createdAt}) =>
      Device(
        id: id ?? this.id,
        roomId: roomId ?? this.roomId,
        name: name ?? this.name,
        type: type ?? this.type,
        topicSet: topicSet.present ? topicSet.value : this.topicSet,
        topicState: topicState ?? this.topicState,
        lastValue: lastValue.present ? lastValue.value : this.lastValue,
        isOn: isOn.present ? isOn.value : this.isOn,
        iconCodePoint: iconCodePoint ?? this.iconCodePoint,
        createdAt: createdAt ?? this.createdAt,
      );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      topicSet: data.topicSet.present ? data.topicSet.value : this.topicSet,
      topicState:
          data.topicState.present ? data.topicState.value : this.topicState,
      lastValue: data.lastValue.present ? data.lastValue.value : this.lastValue,
      isOn: data.isOn.present ? data.isOn.value : this.isOn,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('topicSet: $topicSet, ')
          ..write('topicState: $topicState, ')
          ..write('lastValue: $lastValue, ')
          ..write('isOn: $isOn, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roomId, name, type, topicSet, topicState,
      lastValue, isOn, iconCodePoint, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.name == this.name &&
          other.type == this.type &&
          other.topicSet == this.topicSet &&
          other.topicState == this.topicState &&
          other.lastValue == this.lastValue &&
          other.isOn == this.isOn &&
          other.iconCodePoint == this.iconCodePoint &&
          other.createdAt == this.createdAt);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> roomId;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> topicSet;
  final Value<String> topicState;
  final Value<String?> lastValue;
  final Value<bool?> isOn;
  final Value<int> iconCodePoint;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.topicSet = const Value.absent(),
    this.topicState = const Value.absent(),
    this.lastValue = const Value.absent(),
    this.isOn = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String roomId,
    required String name,
    required String type,
    this.topicSet = const Value.absent(),
    required String topicState,
    this.lastValue = const Value.absent(),
    this.isOn = const Value.absent(),
    required int iconCodePoint,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        roomId = Value(roomId),
        name = Value(name),
        type = Value(type),
        topicState = Value(topicState),
        iconCodePoint = Value(iconCodePoint),
        createdAt = Value(createdAt);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? roomId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? topicSet,
    Expression<String>? topicState,
    Expression<String>? lastValue,
    Expression<bool>? isOn,
    Expression<int>? iconCodePoint,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (topicSet != null) 'topic_set': topicSet,
      if (topicState != null) 'topic_state': topicState,
      if (lastValue != null) 'last_value': lastValue,
      if (isOn != null) 'is_on': isOn,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? roomId,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? topicSet,
      Value<String>? topicState,
      Value<String?>? lastValue,
      Value<bool?>? isOn,
      Value<int>? iconCodePoint,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return DevicesCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      type: type ?? this.type,
      topicSet: topicSet ?? this.topicSet,
      topicState: topicState ?? this.topicState,
      lastValue: lastValue ?? this.lastValue,
      isOn: isOn ?? this.isOn,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (topicSet.present) {
      map['topic_set'] = Variable<String>(topicSet.value);
    }
    if (topicState.present) {
      map['topic_state'] = Variable<String>(topicState.value);
    }
    if (lastValue.present) {
      map['last_value'] = Variable<String>(lastValue.value);
    }
    if (isOn.present) {
      map['is_on'] = Variable<bool>(isOn.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('topicSet: $topicSet, ')
          ..write('topicState: $topicState, ')
          ..write('lastValue: $lastValue, ')
          ..write('isOn: $isOn, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [rooms, devices];
}

typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  required String id,
  required String name,
  required int iconCodePoint,
  required int sortOrder,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> iconCodePoint,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RoomsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoomsTable,
    Room,
    $$RoomsTableFilterComposer,
    $$RoomsTableOrderingComposer,
    $$RoomsTableAnnotationComposer,
    $$RoomsTableCreateCompanionBuilder,
    $$RoomsTableUpdateCompanionBuilder,
    (Room, BaseReferences<_$AppDatabase, $RoomsTable, Room>),
    Room,
    PrefetchHooks Function()> {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> iconCodePoint = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomsCompanion(
            id: id,
            name: name,
            iconCodePoint: iconCodePoint,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int iconCodePoint,
            required int sortOrder,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomsCompanion.insert(
            id: id,
            name: name,
            iconCodePoint: iconCodePoint,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RoomsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoomsTable,
    Room,
    $$RoomsTableFilterComposer,
    $$RoomsTableOrderingComposer,
    $$RoomsTableAnnotationComposer,
    $$RoomsTableCreateCompanionBuilder,
    $$RoomsTableUpdateCompanionBuilder,
    (Room, BaseReferences<_$AppDatabase, $RoomsTable, Room>),
    Room,
    PrefetchHooks Function()>;
typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String id,
  required String roomId,
  required String name,
  required String type,
  Value<String?> topicSet,
  required String topicState,
  Value<String?> lastValue,
  Value<bool?> isOn,
  required int iconCodePoint,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> id,
  Value<String> roomId,
  Value<String> name,
  Value<String> type,
  Value<String?> topicSet,
  Value<String> topicState,
  Value<String?> lastValue,
  Value<bool?> isOn,
  Value<int> iconCodePoint,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicSet => $composableBuilder(
      column: $table.topicSet, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicState => $composableBuilder(
      column: $table.topicState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastValue => $composableBuilder(
      column: $table.lastValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOn => $composableBuilder(
      column: $table.isOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicSet => $composableBuilder(
      column: $table.topicSet, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicState => $composableBuilder(
      column: $table.topicState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastValue => $composableBuilder(
      column: $table.lastValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOn => $composableBuilder(
      column: $table.isOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get topicSet =>
      $composableBuilder(column: $table.topicSet, builder: (column) => column);

  GeneratedColumn<String> get topicState => $composableBuilder(
      column: $table.topicState, builder: (column) => column);

  GeneratedColumn<String> get lastValue =>
      $composableBuilder(column: $table.lastValue, builder: (column) => column);

  GeneratedColumn<bool> get isOn =>
      $composableBuilder(column: $table.isOn, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
    Device,
    PrefetchHooks Function()> {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> roomId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> topicSet = const Value.absent(),
            Value<String> topicState = const Value.absent(),
            Value<String?> lastValue = const Value.absent(),
            Value<bool?> isOn = const Value.absent(),
            Value<int> iconCodePoint = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion(
            id: id,
            roomId: roomId,
            name: name,
            type: type,
            topicSet: topicSet,
            topicState: topicState,
            lastValue: lastValue,
            isOn: isOn,
            iconCodePoint: iconCodePoint,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String roomId,
            required String name,
            required String type,
            Value<String?> topicSet = const Value.absent(),
            required String topicState,
            Value<String?> lastValue = const Value.absent(),
            Value<bool?> isOn = const Value.absent(),
            required int iconCodePoint,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            id: id,
            roomId: roomId,
            name: name,
            type: type,
            topicSet: topicSet,
            topicState: topicState,
            lastValue: lastValue,
            isOn: isOn,
            iconCodePoint: iconCodePoint,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
    Device,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
}
