// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FarmsTable extends Farms with TableInfo<$FarmsTable, Farm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _weekStartDayMeta = const VerificationMeta(
    'weekStartDay',
  );
  @override
  late final GeneratedColumn<int> weekStartDay = GeneratedColumn<int>(
    'week_start_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Asia/Kolkata'),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    revision,
    serverSeq,
    syncStatus,
    id,
    name,
    weekStartDay,
    timezone,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Farm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('week_start_day')) {
      context.handle(
        _weekStartDayMeta,
        weekStartDay.isAcceptableOrUnknown(
          data['week_start_day']!,
          _weekStartDayMeta,
        ),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Farm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Farm(
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      weekStartDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_start_day'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FarmsTable createAlias(String alias) {
    return $FarmsTable(attachedDatabase, alias);
  }
}

class Farm extends DataClass implements Insertable<Farm> {
  final int revision;
  final int serverSeq;
  final int syncStatus;
  final String id;
  final String name;
  final int weekStartDay;
  final String timezone;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Farm({
    required this.revision,
    required this.serverSeq,
    required this.syncStatus,
    required this.id,
    required this.name,
    required this.weekStartDay,
    required this.timezone,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision'] = Variable<int>(revision);
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['week_start_day'] = Variable<int>(weekStartDay);
    map['timezone'] = Variable<String>(timezone);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FarmsCompanion toCompanion(bool nullToAbsent) {
    return FarmsCompanion(
      revision: Value(revision),
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      id: Value(id),
      name: Value(name),
      weekStartDay: Value(weekStartDay),
      timezone: Value(timezone),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Farm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Farm(
      revision: serializer.fromJson<int>(json['revision']),
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      weekStartDay: serializer.fromJson<int>(json['week_start_day']),
      timezone: serializer.fromJson<String>(json['timezone']),
      createdBy: serializer.fromJson<String>(json['created_by']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revision': serializer.toJson<int>(revision),
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'week_start_day': serializer.toJson<int>(weekStartDay),
      'timezone': serializer.toJson<String>(timezone),
      'created_by': serializer.toJson<String>(createdBy),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Farm copyWith({
    int? revision,
    int? serverSeq,
    int? syncStatus,
    String? id,
    String? name,
    int? weekStartDay,
    String? timezone,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Farm(
    revision: revision ?? this.revision,
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    id: id ?? this.id,
    name: name ?? this.name,
    weekStartDay: weekStartDay ?? this.weekStartDay,
    timezone: timezone ?? this.timezone,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Farm copyWithCompanion(FarmsCompanion data) {
    return Farm(
      revision: data.revision.present ? data.revision.value : this.revision,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      weekStartDay: data.weekStartDay.present
          ? data.weekStartDay.value
          : this.weekStartDay,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Farm(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weekStartDay: $weekStartDay, ')
          ..write('timezone: $timezone, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    revision,
    serverSeq,
    syncStatus,
    id,
    name,
    weekStartDay,
    timezone,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Farm &&
          other.revision == this.revision &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.id == this.id &&
          other.name == this.name &&
          other.weekStartDay == this.weekStartDay &&
          other.timezone == this.timezone &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FarmsCompanion extends UpdateCompanion<Farm> {
  final Value<int> revision;
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> id;
  final Value<String> name;
  final Value<int> weekStartDay;
  final Value<String> timezone;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FarmsCompanion({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.weekStartDay = const Value.absent(),
    this.timezone = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmsCompanion.insert({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String id,
    required String name,
    this.weekStartDay = const Value.absent(),
    this.timezone = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Farm> custom({
    Expression<int>? revision,
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? weekStartDay,
    Expression<String>? timezone,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revision != null) 'revision': revision,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (weekStartDay != null) 'week_start_day': weekStartDay,
      if (timezone != null) 'timezone': timezone,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmsCompanion copyWith({
    Value<int>? revision,
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? id,
    Value<String>? name,
    Value<int>? weekStartDay,
    Value<String>? timezone,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FarmsCompanion(
      revision: revision ?? this.revision,
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      id: id ?? this.id,
      name: name ?? this.name,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      timezone: timezone ?? this.timezone,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (weekStartDay.present) {
      map['week_start_day'] = Variable<int>(weekStartDay.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmsCompanion(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weekStartDay: $weekStartDay, ')
          ..write('timezone: $timezone, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmMembersTable extends FarmMembers
    with TableInfo<$FarmMembersTable, FarmMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameKnMeta = const VerificationMeta(
    'displayNameKn',
  );
  @override
  late final GeneratedColumn<String> displayNameKn = GeneratedColumn<String>(
    'display_name_kn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedWorkerIdMeta = const VerificationMeta(
    'linkedWorkerId',
  );
  @override
  late final GeneratedColumn<String> linkedWorkerId = GeneratedColumn<String>(
    'linked_worker_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invitedByMeta = const VerificationMeta(
    'invitedBy',
  );
  @override
  late final GeneratedColumn<String> invitedBy = GeneratedColumn<String>(
    'invited_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    userId,
    email,
    role,
    status,
    fullName,
    displayNameKn,
    linkedWorkerId,
    invitedBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('display_name_kn')) {
      context.handle(
        _displayNameKnMeta,
        displayNameKn.isAcceptableOrUnknown(
          data['display_name_kn']!,
          _displayNameKnMeta,
        ),
      );
    }
    if (data.containsKey('linked_worker_id')) {
      context.handle(
        _linkedWorkerIdMeta,
        linkedWorkerId.isAcceptableOrUnknown(
          data['linked_worker_id']!,
          _linkedWorkerIdMeta,
        ),
      );
    }
    if (data.containsKey('invited_by')) {
      context.handle(
        _invitedByMeta,
        invitedBy.isAcceptableOrUnknown(data['invited_by']!, _invitedByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmMember(
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      displayNameKn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name_kn'],
      ),
      linkedWorkerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_worker_id'],
      ),
      invitedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invited_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FarmMembersTable createAlias(String alias) {
    return $FarmMembersTable(attachedDatabase, alias);
  }
}

class FarmMember extends DataClass implements Insertable<FarmMember> {
  final int revision;
  final int serverSeq;
  final int syncStatus;
  final String id;
  final String farmId;
  final String? userId;
  final String email;
  final String role;
  final String status;
  final String fullName;
  final String? displayNameKn;
  final String? linkedWorkerId;
  final String? invitedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FarmMember({
    required this.revision,
    required this.serverSeq,
    required this.syncStatus,
    required this.id,
    required this.farmId,
    this.userId,
    required this.email,
    required this.role,
    required this.status,
    required this.fullName,
    this.displayNameKn,
    this.linkedWorkerId,
    this.invitedBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision'] = Variable<int>(revision);
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    map['status'] = Variable<String>(status);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || displayNameKn != null) {
      map['display_name_kn'] = Variable<String>(displayNameKn);
    }
    if (!nullToAbsent || linkedWorkerId != null) {
      map['linked_worker_id'] = Variable<String>(linkedWorkerId);
    }
    if (!nullToAbsent || invitedBy != null) {
      map['invited_by'] = Variable<String>(invitedBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FarmMembersCompanion toCompanion(bool nullToAbsent) {
    return FarmMembersCompanion(
      revision: Value(revision),
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      id: Value(id),
      farmId: Value(farmId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      email: Value(email),
      role: Value(role),
      status: Value(status),
      fullName: Value(fullName),
      displayNameKn: displayNameKn == null && nullToAbsent
          ? const Value.absent()
          : Value(displayNameKn),
      linkedWorkerId: linkedWorkerId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedWorkerId),
      invitedBy: invitedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(invitedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FarmMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmMember(
      revision: serializer.fromJson<int>(json['revision']),
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      userId: serializer.fromJson<String?>(json['user_id']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      status: serializer.fromJson<String>(json['status']),
      fullName: serializer.fromJson<String>(json['full_name']),
      displayNameKn: serializer.fromJson<String?>(json['display_name_kn']),
      linkedWorkerId: serializer.fromJson<String?>(json['linked_worker_id']),
      invitedBy: serializer.fromJson<String?>(json['invited_by']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revision': serializer.toJson<int>(revision),
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'id': serializer.toJson<String>(id),
      'farm_id': serializer.toJson<String>(farmId),
      'user_id': serializer.toJson<String?>(userId),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'status': serializer.toJson<String>(status),
      'full_name': serializer.toJson<String>(fullName),
      'display_name_kn': serializer.toJson<String?>(displayNameKn),
      'linked_worker_id': serializer.toJson<String?>(linkedWorkerId),
      'invited_by': serializer.toJson<String?>(invitedBy),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FarmMember copyWith({
    int? revision,
    int? serverSeq,
    int? syncStatus,
    String? id,
    String? farmId,
    Value<String?> userId = const Value.absent(),
    String? email,
    String? role,
    String? status,
    String? fullName,
    Value<String?> displayNameKn = const Value.absent(),
    Value<String?> linkedWorkerId = const Value.absent(),
    Value<String?> invitedBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FarmMember(
    revision: revision ?? this.revision,
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    userId: userId.present ? userId.value : this.userId,
    email: email ?? this.email,
    role: role ?? this.role,
    status: status ?? this.status,
    fullName: fullName ?? this.fullName,
    displayNameKn: displayNameKn.present
        ? displayNameKn.value
        : this.displayNameKn,
    linkedWorkerId: linkedWorkerId.present
        ? linkedWorkerId.value
        : this.linkedWorkerId,
    invitedBy: invitedBy.present ? invitedBy.value : this.invitedBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FarmMember copyWithCompanion(FarmMembersCompanion data) {
    return FarmMember(
      revision: data.revision.present ? data.revision.value : this.revision,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      userId: data.userId.present ? data.userId.value : this.userId,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      status: data.status.present ? data.status.value : this.status,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      displayNameKn: data.displayNameKn.present
          ? data.displayNameKn.value
          : this.displayNameKn,
      linkedWorkerId: data.linkedWorkerId.present
          ? data.linkedWorkerId.value
          : this.linkedWorkerId,
      invitedBy: data.invitedBy.present ? data.invitedBy.value : this.invitedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmMember(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('fullName: $fullName, ')
          ..write('displayNameKn: $displayNameKn, ')
          ..write('linkedWorkerId: $linkedWorkerId, ')
          ..write('invitedBy: $invitedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    userId,
    email,
    role,
    status,
    fullName,
    displayNameKn,
    linkedWorkerId,
    invitedBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmMember &&
          other.revision == this.revision &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.userId == this.userId &&
          other.email == this.email &&
          other.role == this.role &&
          other.status == this.status &&
          other.fullName == this.fullName &&
          other.displayNameKn == this.displayNameKn &&
          other.linkedWorkerId == this.linkedWorkerId &&
          other.invitedBy == this.invitedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FarmMembersCompanion extends UpdateCompanion<FarmMember> {
  final Value<int> revision;
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> id;
  final Value<String> farmId;
  final Value<String?> userId;
  final Value<String> email;
  final Value<String> role;
  final Value<String> status;
  final Value<String> fullName;
  final Value<String?> displayNameKn;
  final Value<String?> linkedWorkerId;
  final Value<String?> invitedBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FarmMembersCompanion({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.fullName = const Value.absent(),
    this.displayNameKn = const Value.absent(),
    this.linkedWorkerId = const Value.absent(),
    this.invitedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmMembersCompanion.insert({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String id,
    required String farmId,
    this.userId = const Value.absent(),
    required String email,
    required String role,
    required String status,
    required String fullName,
    this.displayNameKn = const Value.absent(),
    this.linkedWorkerId = const Value.absent(),
    this.invitedBy = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       email = Value(email),
       role = Value(role),
       status = Value(status),
       fullName = Value(fullName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FarmMember> custom({
    Expression<int>? revision,
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? userId,
    Expression<String>? email,
    Expression<String>? role,
    Expression<String>? status,
    Expression<String>? fullName,
    Expression<String>? displayNameKn,
    Expression<String>? linkedWorkerId,
    Expression<String>? invitedBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revision != null) 'revision': revision,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (fullName != null) 'full_name': fullName,
      if (displayNameKn != null) 'display_name_kn': displayNameKn,
      if (linkedWorkerId != null) 'linked_worker_id': linkedWorkerId,
      if (invitedBy != null) 'invited_by': invitedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmMembersCompanion copyWith({
    Value<int>? revision,
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? id,
    Value<String>? farmId,
    Value<String?>? userId,
    Value<String>? email,
    Value<String>? role,
    Value<String>? status,
    Value<String>? fullName,
    Value<String?>? displayNameKn,
    Value<String?>? linkedWorkerId,
    Value<String?>? invitedBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FarmMembersCompanion(
      revision: revision ?? this.revision,
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      displayNameKn: displayNameKn ?? this.displayNameKn,
      linkedWorkerId: linkedWorkerId ?? this.linkedWorkerId,
      invitedBy: invitedBy ?? this.invitedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (displayNameKn.present) {
      map['display_name_kn'] = Variable<String>(displayNameKn.value);
    }
    if (linkedWorkerId.present) {
      map['linked_worker_id'] = Variable<String>(linkedWorkerId.value);
    }
    if (invitedBy.present) {
      map['invited_by'] = Variable<String>(invitedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmMembersCompanion(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('fullName: $fullName, ')
          ..write('displayNameKn: $displayNameKn, ')
          ..write('linkedWorkerId: $linkedWorkerId, ')
          ..write('invitedBy: $invitedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkersTable extends Workers with TableInfo<$WorkersTable, Worker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKnMeta = const VerificationMeta('nameKn');
  @override
  late final GeneratedColumn<String> nameKn = GeneratedColumn<String>(
    'name_kn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultWagePaiseMeta = const VerificationMeta(
    'defaultWagePaise',
  );
  @override
  late final GeneratedColumn<int> defaultWagePaise = GeneratedColumn<int>(
    'default_wage_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLeaderMeta = const VerificationMeta(
    'isLeader',
  );
  @override
  late final GeneratedColumn<bool> isLeader = GeneratedColumn<bool>(
    'is_leader',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_leader" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    nameKn,
    nameEn,
    phone,
    defaultWagePaise,
    notes,
    isLeader,
    status,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Worker> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('name_kn')) {
      context.handle(
        _nameKnMeta,
        nameKn.isAcceptableOrUnknown(data['name_kn']!, _nameKnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKnMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('default_wage_paise')) {
      context.handle(
        _defaultWagePaiseMeta,
        defaultWagePaise.isAcceptableOrUnknown(
          data['default_wage_paise']!,
          _defaultWagePaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultWagePaiseMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_leader')) {
      context.handle(
        _isLeaderMeta,
        isLeader.isAcceptableOrUnknown(data['is_leader']!, _isLeaderMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Worker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Worker(
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      nameKn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_kn'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      defaultWagePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_wage_paise'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isLeader: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_leader'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkersTable createAlias(String alias) {
    return $WorkersTable(attachedDatabase, alias);
  }
}

class Worker extends DataClass implements Insertable<Worker> {
  final int revision;
  final int serverSeq;
  final int syncStatus;
  final String id;
  final String farmId;
  final String nameKn;
  final String? nameEn;
  final String? phone;
  final int defaultWagePaise;
  final String? notes;
  final bool isLeader;
  final String status;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Worker({
    required this.revision,
    required this.serverSeq,
    required this.syncStatus,
    required this.id,
    required this.farmId,
    required this.nameKn,
    this.nameEn,
    this.phone,
    required this.defaultWagePaise,
    this.notes,
    required this.isLeader,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision'] = Variable<int>(revision);
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['name_kn'] = Variable<String>(nameKn);
    if (!nullToAbsent || nameEn != null) {
      map['name_en'] = Variable<String>(nameEn);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['default_wage_paise'] = Variable<int>(defaultWagePaise);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_leader'] = Variable<bool>(isLeader);
    map['status'] = Variable<String>(status);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkersCompanion toCompanion(bool nullToAbsent) {
    return WorkersCompanion(
      revision: Value(revision),
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      id: Value(id),
      farmId: Value(farmId),
      nameKn: Value(nameKn),
      nameEn: nameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(nameEn),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      defaultWagePaise: Value(defaultWagePaise),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isLeader: Value(isLeader),
      status: Value(status),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Worker.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Worker(
      revision: serializer.fromJson<int>(json['revision']),
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      nameKn: serializer.fromJson<String>(json['name_kn']),
      nameEn: serializer.fromJson<String?>(json['name_en']),
      phone: serializer.fromJson<String?>(json['phone']),
      defaultWagePaise: serializer.fromJson<int>(json['default_wage_paise']),
      notes: serializer.fromJson<String?>(json['notes']),
      isLeader: serializer.fromJson<bool>(json['is_leader']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<String>(json['created_by']),
      updatedBy: serializer.fromJson<String>(json['updated_by']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revision': serializer.toJson<int>(revision),
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'id': serializer.toJson<String>(id),
      'farm_id': serializer.toJson<String>(farmId),
      'name_kn': serializer.toJson<String>(nameKn),
      'name_en': serializer.toJson<String?>(nameEn),
      'phone': serializer.toJson<String?>(phone),
      'default_wage_paise': serializer.toJson<int>(defaultWagePaise),
      'notes': serializer.toJson<String?>(notes),
      'is_leader': serializer.toJson<bool>(isLeader),
      'status': serializer.toJson<String>(status),
      'created_by': serializer.toJson<String>(createdBy),
      'updated_by': serializer.toJson<String>(updatedBy),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Worker copyWith({
    int? revision,
    int? serverSeq,
    int? syncStatus,
    String? id,
    String? farmId,
    String? nameKn,
    Value<String?> nameEn = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    int? defaultWagePaise,
    Value<String?> notes = const Value.absent(),
    bool? isLeader,
    String? status,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Worker(
    revision: revision ?? this.revision,
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    nameKn: nameKn ?? this.nameKn,
    nameEn: nameEn.present ? nameEn.value : this.nameEn,
    phone: phone.present ? phone.value : this.phone,
    defaultWagePaise: defaultWagePaise ?? this.defaultWagePaise,
    notes: notes.present ? notes.value : this.notes,
    isLeader: isLeader ?? this.isLeader,
    status: status ?? this.status,
    createdBy: createdBy ?? this.createdBy,
    updatedBy: updatedBy ?? this.updatedBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Worker copyWithCompanion(WorkersCompanion data) {
    return Worker(
      revision: data.revision.present ? data.revision.value : this.revision,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      nameKn: data.nameKn.present ? data.nameKn.value : this.nameKn,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      phone: data.phone.present ? data.phone.value : this.phone,
      defaultWagePaise: data.defaultWagePaise.present
          ? data.defaultWagePaise.value
          : this.defaultWagePaise,
      notes: data.notes.present ? data.notes.value : this.notes,
      isLeader: data.isLeader.present ? data.isLeader.value : this.isLeader,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Worker(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('nameKn: $nameKn, ')
          ..write('nameEn: $nameEn, ')
          ..write('phone: $phone, ')
          ..write('defaultWagePaise: $defaultWagePaise, ')
          ..write('notes: $notes, ')
          ..write('isLeader: $isLeader, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    nameKn,
    nameEn,
    phone,
    defaultWagePaise,
    notes,
    isLeader,
    status,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Worker &&
          other.revision == this.revision &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.nameKn == this.nameKn &&
          other.nameEn == this.nameEn &&
          other.phone == this.phone &&
          other.defaultWagePaise == this.defaultWagePaise &&
          other.notes == this.notes &&
          other.isLeader == this.isLeader &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkersCompanion extends UpdateCompanion<Worker> {
  final Value<int> revision;
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> nameKn;
  final Value<String?> nameEn;
  final Value<String?> phone;
  final Value<int> defaultWagePaise;
  final Value<String?> notes;
  final Value<bool> isLeader;
  final Value<String> status;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkersCompanion({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.nameKn = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.phone = const Value.absent(),
    this.defaultWagePaise = const Value.absent(),
    this.notes = const Value.absent(),
    this.isLeader = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkersCompanion.insert({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String id,
    required String farmId,
    required String nameKn,
    this.nameEn = const Value.absent(),
    this.phone = const Value.absent(),
    required int defaultWagePaise,
    this.notes = const Value.absent(),
    this.isLeader = const Value.absent(),
    this.status = const Value.absent(),
    required String createdBy,
    required String updatedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       nameKn = Value(nameKn),
       defaultWagePaise = Value(defaultWagePaise),
       createdBy = Value(createdBy),
       updatedBy = Value(updatedBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Worker> custom({
    Expression<int>? revision,
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? nameKn,
    Expression<String>? nameEn,
    Expression<String>? phone,
    Expression<int>? defaultWagePaise,
    Expression<String>? notes,
    Expression<bool>? isLeader,
    Expression<String>? status,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revision != null) 'revision': revision,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (nameKn != null) 'name_kn': nameKn,
      if (nameEn != null) 'name_en': nameEn,
      if (phone != null) 'phone': phone,
      if (defaultWagePaise != null) 'default_wage_paise': defaultWagePaise,
      if (notes != null) 'notes': notes,
      if (isLeader != null) 'is_leader': isLeader,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkersCompanion copyWith({
    Value<int>? revision,
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? nameKn,
    Value<String?>? nameEn,
    Value<String?>? phone,
    Value<int>? defaultWagePaise,
    Value<String?>? notes,
    Value<bool>? isLeader,
    Value<String>? status,
    Value<String>? createdBy,
    Value<String>? updatedBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkersCompanion(
      revision: revision ?? this.revision,
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      nameKn: nameKn ?? this.nameKn,
      nameEn: nameEn ?? this.nameEn,
      phone: phone ?? this.phone,
      defaultWagePaise: defaultWagePaise ?? this.defaultWagePaise,
      notes: notes ?? this.notes,
      isLeader: isLeader ?? this.isLeader,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (nameKn.present) {
      map['name_kn'] = Variable<String>(nameKn.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (defaultWagePaise.present) {
      map['default_wage_paise'] = Variable<int>(defaultWagePaise.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isLeader.present) {
      map['is_leader'] = Variable<bool>(isLeader.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkersCompanion(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('nameKn: $nameKn, ')
          ..write('nameEn: $nameEn, ')
          ..write('phone: $phone, ')
          ..write('defaultWagePaise: $defaultWagePaise, ')
          ..write('notes: $notes, ')
          ..write('isLeader: $isLeader, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkerGroupsTable extends WorkerGroups
    with TableInfo<$WorkerGroupsTable, WorkerGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkerGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
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
  static const VerificationMeta _leaderWorkerIdMeta = const VerificationMeta(
    'leaderWorkerId',
  );
  @override
  late final GeneratedColumn<String> leaderWorkerId = GeneratedColumn<String>(
    'leader_worker_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    name,
    leaderWorkerId,
    status,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'worker_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkerGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('leader_worker_id')) {
      context.handle(
        _leaderWorkerIdMeta,
        leaderWorkerId.isAcceptableOrUnknown(
          data['leader_worker_id']!,
          _leaderWorkerIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkerGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkerGroup(
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      leaderWorkerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leader_worker_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkerGroupsTable createAlias(String alias) {
    return $WorkerGroupsTable(attachedDatabase, alias);
  }
}

class WorkerGroup extends DataClass implements Insertable<WorkerGroup> {
  final int revision;
  final int serverSeq;
  final int syncStatus;
  final String id;
  final String farmId;
  final String name;
  final String? leaderWorkerId;
  final String status;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WorkerGroup({
    required this.revision,
    required this.serverSeq,
    required this.syncStatus,
    required this.id,
    required this.farmId,
    required this.name,
    this.leaderWorkerId,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision'] = Variable<int>(revision);
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || leaderWorkerId != null) {
      map['leader_worker_id'] = Variable<String>(leaderWorkerId);
    }
    map['status'] = Variable<String>(status);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkerGroupsCompanion toCompanion(bool nullToAbsent) {
    return WorkerGroupsCompanion(
      revision: Value(revision),
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      id: Value(id),
      farmId: Value(farmId),
      name: Value(name),
      leaderWorkerId: leaderWorkerId == null && nullToAbsent
          ? const Value.absent()
          : Value(leaderWorkerId),
      status: Value(status),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkerGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkerGroup(
      revision: serializer.fromJson<int>(json['revision']),
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      name: serializer.fromJson<String>(json['name']),
      leaderWorkerId: serializer.fromJson<String?>(json['leader_worker_id']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<String>(json['created_by']),
      updatedBy: serializer.fromJson<String>(json['updated_by']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revision': serializer.toJson<int>(revision),
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'id': serializer.toJson<String>(id),
      'farm_id': serializer.toJson<String>(farmId),
      'name': serializer.toJson<String>(name),
      'leader_worker_id': serializer.toJson<String?>(leaderWorkerId),
      'status': serializer.toJson<String>(status),
      'created_by': serializer.toJson<String>(createdBy),
      'updated_by': serializer.toJson<String>(updatedBy),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkerGroup copyWith({
    int? revision,
    int? serverSeq,
    int? syncStatus,
    String? id,
    String? farmId,
    String? name,
    Value<String?> leaderWorkerId = const Value.absent(),
    String? status,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkerGroup(
    revision: revision ?? this.revision,
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    name: name ?? this.name,
    leaderWorkerId: leaderWorkerId.present
        ? leaderWorkerId.value
        : this.leaderWorkerId,
    status: status ?? this.status,
    createdBy: createdBy ?? this.createdBy,
    updatedBy: updatedBy ?? this.updatedBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkerGroup copyWithCompanion(WorkerGroupsCompanion data) {
    return WorkerGroup(
      revision: data.revision.present ? data.revision.value : this.revision,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      name: data.name.present ? data.name.value : this.name,
      leaderWorkerId: data.leaderWorkerId.present
          ? data.leaderWorkerId.value
          : this.leaderWorkerId,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkerGroup(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('leaderWorkerId: $leaderWorkerId, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    name,
    leaderWorkerId,
    status,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkerGroup &&
          other.revision == this.revision &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.name == this.name &&
          other.leaderWorkerId == this.leaderWorkerId &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkerGroupsCompanion extends UpdateCompanion<WorkerGroup> {
  final Value<int> revision;
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> name;
  final Value<String?> leaderWorkerId;
  final Value<String> status;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkerGroupsCompanion({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.name = const Value.absent(),
    this.leaderWorkerId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkerGroupsCompanion.insert({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String id,
    required String farmId,
    required String name,
    this.leaderWorkerId = const Value.absent(),
    this.status = const Value.absent(),
    required String createdBy,
    required String updatedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       name = Value(name),
       createdBy = Value(createdBy),
       updatedBy = Value(updatedBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkerGroup> custom({
    Expression<int>? revision,
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? name,
    Expression<String>? leaderWorkerId,
    Expression<String>? status,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revision != null) 'revision': revision,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (name != null) 'name': name,
      if (leaderWorkerId != null) 'leader_worker_id': leaderWorkerId,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkerGroupsCompanion copyWith({
    Value<int>? revision,
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? name,
    Value<String?>? leaderWorkerId,
    Value<String>? status,
    Value<String>? createdBy,
    Value<String>? updatedBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkerGroupsCompanion(
      revision: revision ?? this.revision,
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      leaderWorkerId: leaderWorkerId ?? this.leaderWorkerId,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (leaderWorkerId.present) {
      map['leader_worker_id'] = Variable<String>(leaderWorkerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkerGroupsCompanion(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('leaderWorkerId: $leaderWorkerId, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkerGroupMembershipsTable extends WorkerGroupMemberships
    with TableInfo<$WorkerGroupMembershipsTable, GroupMembership> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkerGroupMembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workerIdMeta = const VerificationMeta(
    'workerId',
  );
  @override
  late final GeneratedColumn<String> workerId = GeneratedColumn<String>(
    'worker_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverSeq,
    syncStatus,
    farmId,
    groupId,
    workerId,
    active,
    updatedBy,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'worker_group_memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupMembership> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('worker_id')) {
      context.handle(
        _workerIdMeta,
        workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, workerId};
  @override
  GroupMembership map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMembership(
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      workerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}worker_id'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkerGroupMembershipsTable createAlias(String alias) {
    return $WorkerGroupMembershipsTable(attachedDatabase, alias);
  }
}

class GroupMembership extends DataClass implements Insertable<GroupMembership> {
  final int serverSeq;
  final int syncStatus;
  final String farmId;
  final String groupId;
  final String workerId;
  final bool active;
  final String updatedBy;
  final DateTime updatedAt;
  const GroupMembership({
    required this.serverSeq,
    required this.syncStatus,
    required this.farmId,
    required this.groupId,
    required this.workerId,
    required this.active,
    required this.updatedBy,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['farm_id'] = Variable<String>(farmId);
    map['group_id'] = Variable<String>(groupId);
    map['worker_id'] = Variable<String>(workerId);
    map['active'] = Variable<bool>(active);
    map['updated_by'] = Variable<String>(updatedBy);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkerGroupMembershipsCompanion toCompanion(bool nullToAbsent) {
    return WorkerGroupMembershipsCompanion(
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      farmId: Value(farmId),
      groupId: Value(groupId),
      workerId: Value(workerId),
      active: Value(active),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
    );
  }

  factory GroupMembership.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMembership(
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      groupId: serializer.fromJson<String>(json['group_id']),
      workerId: serializer.fromJson<String>(json['worker_id']),
      active: serializer.fromJson<bool>(json['active']),
      updatedBy: serializer.fromJson<String>(json['updated_by']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'farm_id': serializer.toJson<String>(farmId),
      'group_id': serializer.toJson<String>(groupId),
      'worker_id': serializer.toJson<String>(workerId),
      'active': serializer.toJson<bool>(active),
      'updated_by': serializer.toJson<String>(updatedBy),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GroupMembership copyWith({
    int? serverSeq,
    int? syncStatus,
    String? farmId,
    String? groupId,
    String? workerId,
    bool? active,
    String? updatedBy,
    DateTime? updatedAt,
  }) => GroupMembership(
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    farmId: farmId ?? this.farmId,
    groupId: groupId ?? this.groupId,
    workerId: workerId ?? this.workerId,
    active: active ?? this.active,
    updatedBy: updatedBy ?? this.updatedBy,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GroupMembership copyWithCompanion(WorkerGroupMembershipsCompanion data) {
    return GroupMembership(
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      active: data.active.present ? data.active.value : this.active,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembership(')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('farmId: $farmId, ')
          ..write('groupId: $groupId, ')
          ..write('workerId: $workerId, ')
          ..write('active: $active, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverSeq,
    syncStatus,
    farmId,
    groupId,
    workerId,
    active,
    updatedBy,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMembership &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.farmId == this.farmId &&
          other.groupId == this.groupId &&
          other.workerId == this.workerId &&
          other.active == this.active &&
          other.updatedBy == this.updatedBy &&
          other.updatedAt == this.updatedAt);
}

class WorkerGroupMembershipsCompanion extends UpdateCompanion<GroupMembership> {
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> farmId;
  final Value<String> groupId;
  final Value<String> workerId;
  final Value<bool> active;
  final Value<String> updatedBy;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkerGroupMembershipsCompanion({
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.farmId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.workerId = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkerGroupMembershipsCompanion.insert({
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String farmId,
    required String groupId,
    required String workerId,
    this.active = const Value.absent(),
    required String updatedBy,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : farmId = Value(farmId),
       groupId = Value(groupId),
       workerId = Value(workerId),
       updatedBy = Value(updatedBy),
       updatedAt = Value(updatedAt);
  static Insertable<GroupMembership> custom({
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? farmId,
    Expression<String>? groupId,
    Expression<String>? workerId,
    Expression<bool>? active,
    Expression<String>? updatedBy,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (farmId != null) 'farm_id': farmId,
      if (groupId != null) 'group_id': groupId,
      if (workerId != null) 'worker_id': workerId,
      if (active != null) 'active': active,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkerGroupMembershipsCompanion copyWith({
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? farmId,
    Value<String>? groupId,
    Value<String>? workerId,
    Value<bool>? active,
    Value<String>? updatedBy,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkerGroupMembershipsCompanion(
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      farmId: farmId ?? this.farmId,
      groupId: groupId ?? this.groupId,
      workerId: workerId ?? this.workerId,
      active: active ?? this.active,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<String>(workerId.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkerGroupMembershipsCompanion(')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('farmId: $farmId, ')
          ..write('groupId: $groupId, ')
          ..write('workerId: $workerId, ')
          ..write('active: $active, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceTable extends Attendance
    with TableInfo<$AttendanceTable, AttendanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workerIdMeta = const VerificationMeta(
    'workerId',
  );
  @override
  late final GeneratedColumn<String> workerId = GeneratedColumn<String>(
    'worker_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workDateMeta = const VerificationMeta(
    'workDate',
  );
  @override
  late final GeneratedColumn<String> workDate = GeneratedColumn<String>(
    'work_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitsMilliMeta = const VerificationMeta(
    'unitsMilli',
  );
  @override
  late final GeneratedColumn<int> unitsMilli = GeneratedColumn<int>(
    'units_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratePaiseMeta = const VerificationMeta(
    'ratePaise',
  );
  @override
  late final GeneratedColumn<int> ratePaise = GeneratedColumn<int>(
    'rate_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnedPaiseMeta = const VerificationMeta(
    'earnedPaise',
  );
  @override
  late final GeneratedColumn<int> earnedPaise = GeneratedColumn<int>(
    'earned_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedByMeta = const VerificationMeta(
    'recordedBy',
  );
  @override
  late final GeneratedColumn<String> recordedBy = GeneratedColumn<String>(
    'recorded_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceDeviceIdMeta = const VerificationMeta(
    'sourceDeviceId',
  );
  @override
  late final GeneratedColumn<String> sourceDeviceId = GeneratedColumn<String>(
    'source_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    workerId,
    workDate,
    unitsMilli,
    ratePaise,
    earnedPaise,
    notes,
    recordedBy,
    updatedBy,
    sourceDeviceId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('worker_id')) {
      context.handle(
        _workerIdMeta,
        workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('work_date')) {
      context.handle(
        _workDateMeta,
        workDate.isAcceptableOrUnknown(data['work_date']!, _workDateMeta),
      );
    } else if (isInserting) {
      context.missing(_workDateMeta);
    }
    if (data.containsKey('units_milli')) {
      context.handle(
        _unitsMilliMeta,
        unitsMilli.isAcceptableOrUnknown(data['units_milli']!, _unitsMilliMeta),
      );
    } else if (isInserting) {
      context.missing(_unitsMilliMeta);
    }
    if (data.containsKey('rate_paise')) {
      context.handle(
        _ratePaiseMeta,
        ratePaise.isAcceptableOrUnknown(data['rate_paise']!, _ratePaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_ratePaiseMeta);
    }
    if (data.containsKey('earned_paise')) {
      context.handle(
        _earnedPaiseMeta,
        earnedPaise.isAcceptableOrUnknown(
          data['earned_paise']!,
          _earnedPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_earnedPaiseMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('recorded_by')) {
      context.handle(
        _recordedByMeta,
        recordedBy.isAcceptableOrUnknown(data['recorded_by']!, _recordedByMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('source_device_id')) {
      context.handle(
        _sourceDeviceIdMeta,
        sourceDeviceId.isAcceptableOrUnknown(
          data['source_device_id']!,
          _sourceDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {farmId, workerId, workDate},
  ];
  @override
  AttendanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceRow(
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      workerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}worker_id'],
      )!,
      workDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_date'],
      )!,
      unitsMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_milli'],
      )!,
      ratePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_paise'],
      )!,
      earnedPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}earned_paise'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      recordedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded_by'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      sourceDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AttendanceTable createAlias(String alias) {
    return $AttendanceTable(attachedDatabase, alias);
  }
}

class AttendanceRow extends DataClass implements Insertable<AttendanceRow> {
  final int revision;
  final int serverSeq;
  final int syncStatus;
  final String id;
  final String farmId;
  final String workerId;
  final String workDate;
  final int unitsMilli;
  final int ratePaise;
  final int earnedPaise;
  final String? notes;
  final String recordedBy;
  final String updatedBy;
  final String? sourceDeviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AttendanceRow({
    required this.revision,
    required this.serverSeq,
    required this.syncStatus,
    required this.id,
    required this.farmId,
    required this.workerId,
    required this.workDate,
    required this.unitsMilli,
    required this.ratePaise,
    required this.earnedPaise,
    this.notes,
    required this.recordedBy,
    required this.updatedBy,
    this.sourceDeviceId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision'] = Variable<int>(revision);
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['worker_id'] = Variable<String>(workerId);
    map['work_date'] = Variable<String>(workDate);
    map['units_milli'] = Variable<int>(unitsMilli);
    map['rate_paise'] = Variable<int>(ratePaise);
    map['earned_paise'] = Variable<int>(earnedPaise);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['recorded_by'] = Variable<String>(recordedBy);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || sourceDeviceId != null) {
      map['source_device_id'] = Variable<String>(sourceDeviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AttendanceCompanion toCompanion(bool nullToAbsent) {
    return AttendanceCompanion(
      revision: Value(revision),
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      id: Value(id),
      farmId: Value(farmId),
      workerId: Value(workerId),
      workDate: Value(workDate),
      unitsMilli: Value(unitsMilli),
      ratePaise: Value(ratePaise),
      earnedPaise: Value(earnedPaise),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      recordedBy: Value(recordedBy),
      updatedBy: Value(updatedBy),
      sourceDeviceId: sourceDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDeviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AttendanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceRow(
      revision: serializer.fromJson<int>(json['revision']),
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      workerId: serializer.fromJson<String>(json['worker_id']),
      workDate: serializer.fromJson<String>(json['work_date']),
      unitsMilli: serializer.fromJson<int>(json['units_milli']),
      ratePaise: serializer.fromJson<int>(json['rate_paise']),
      earnedPaise: serializer.fromJson<int>(json['earned_paise']),
      notes: serializer.fromJson<String?>(json['notes']),
      recordedBy: serializer.fromJson<String>(json['recorded_by']),
      updatedBy: serializer.fromJson<String>(json['updated_by']),
      sourceDeviceId: serializer.fromJson<String?>(json['source_device_id']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revision': serializer.toJson<int>(revision),
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'id': serializer.toJson<String>(id),
      'farm_id': serializer.toJson<String>(farmId),
      'worker_id': serializer.toJson<String>(workerId),
      'work_date': serializer.toJson<String>(workDate),
      'units_milli': serializer.toJson<int>(unitsMilli),
      'rate_paise': serializer.toJson<int>(ratePaise),
      'earned_paise': serializer.toJson<int>(earnedPaise),
      'notes': serializer.toJson<String?>(notes),
      'recorded_by': serializer.toJson<String>(recordedBy),
      'updated_by': serializer.toJson<String>(updatedBy),
      'source_device_id': serializer.toJson<String?>(sourceDeviceId),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AttendanceRow copyWith({
    int? revision,
    int? serverSeq,
    int? syncStatus,
    String? id,
    String? farmId,
    String? workerId,
    String? workDate,
    int? unitsMilli,
    int? ratePaise,
    int? earnedPaise,
    Value<String?> notes = const Value.absent(),
    String? recordedBy,
    String? updatedBy,
    Value<String?> sourceDeviceId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AttendanceRow(
    revision: revision ?? this.revision,
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    workerId: workerId ?? this.workerId,
    workDate: workDate ?? this.workDate,
    unitsMilli: unitsMilli ?? this.unitsMilli,
    ratePaise: ratePaise ?? this.ratePaise,
    earnedPaise: earnedPaise ?? this.earnedPaise,
    notes: notes.present ? notes.value : this.notes,
    recordedBy: recordedBy ?? this.recordedBy,
    updatedBy: updatedBy ?? this.updatedBy,
    sourceDeviceId: sourceDeviceId.present
        ? sourceDeviceId.value
        : this.sourceDeviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AttendanceRow copyWithCompanion(AttendanceCompanion data) {
    return AttendanceRow(
      revision: data.revision.present ? data.revision.value : this.revision,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      workDate: data.workDate.present ? data.workDate.value : this.workDate,
      unitsMilli: data.unitsMilli.present
          ? data.unitsMilli.value
          : this.unitsMilli,
      ratePaise: data.ratePaise.present ? data.ratePaise.value : this.ratePaise,
      earnedPaise: data.earnedPaise.present
          ? data.earnedPaise.value
          : this.earnedPaise,
      notes: data.notes.present ? data.notes.value : this.notes,
      recordedBy: data.recordedBy.present
          ? data.recordedBy.value
          : this.recordedBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      sourceDeviceId: data.sourceDeviceId.present
          ? data.sourceDeviceId.value
          : this.sourceDeviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRow(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('workerId: $workerId, ')
          ..write('workDate: $workDate, ')
          ..write('unitsMilli: $unitsMilli, ')
          ..write('ratePaise: $ratePaise, ')
          ..write('earnedPaise: $earnedPaise, ')
          ..write('notes: $notes, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    workerId,
    workDate,
    unitsMilli,
    ratePaise,
    earnedPaise,
    notes,
    recordedBy,
    updatedBy,
    sourceDeviceId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceRow &&
          other.revision == this.revision &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.workerId == this.workerId &&
          other.workDate == this.workDate &&
          other.unitsMilli == this.unitsMilli &&
          other.ratePaise == this.ratePaise &&
          other.earnedPaise == this.earnedPaise &&
          other.notes == this.notes &&
          other.recordedBy == this.recordedBy &&
          other.updatedBy == this.updatedBy &&
          other.sourceDeviceId == this.sourceDeviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AttendanceCompanion extends UpdateCompanion<AttendanceRow> {
  final Value<int> revision;
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> workerId;
  final Value<String> workDate;
  final Value<int> unitsMilli;
  final Value<int> ratePaise;
  final Value<int> earnedPaise;
  final Value<String?> notes;
  final Value<String> recordedBy;
  final Value<String> updatedBy;
  final Value<String?> sourceDeviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AttendanceCompanion({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.workerId = const Value.absent(),
    this.workDate = const Value.absent(),
    this.unitsMilli = const Value.absent(),
    this.ratePaise = const Value.absent(),
    this.earnedPaise = const Value.absent(),
    this.notes = const Value.absent(),
    this.recordedBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceCompanion.insert({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String id,
    required String farmId,
    required String workerId,
    required String workDate,
    required int unitsMilli,
    required int ratePaise,
    required int earnedPaise,
    this.notes = const Value.absent(),
    required String recordedBy,
    required String updatedBy,
    this.sourceDeviceId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       workerId = Value(workerId),
       workDate = Value(workDate),
       unitsMilli = Value(unitsMilli),
       ratePaise = Value(ratePaise),
       earnedPaise = Value(earnedPaise),
       recordedBy = Value(recordedBy),
       updatedBy = Value(updatedBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AttendanceRow> custom({
    Expression<int>? revision,
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? workerId,
    Expression<String>? workDate,
    Expression<int>? unitsMilli,
    Expression<int>? ratePaise,
    Expression<int>? earnedPaise,
    Expression<String>? notes,
    Expression<String>? recordedBy,
    Expression<String>? updatedBy,
    Expression<String>? sourceDeviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revision != null) 'revision': revision,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (workerId != null) 'worker_id': workerId,
      if (workDate != null) 'work_date': workDate,
      if (unitsMilli != null) 'units_milli': unitsMilli,
      if (ratePaise != null) 'rate_paise': ratePaise,
      if (earnedPaise != null) 'earned_paise': earnedPaise,
      if (notes != null) 'notes': notes,
      if (recordedBy != null) 'recorded_by': recordedBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceCompanion copyWith({
    Value<int>? revision,
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? workerId,
    Value<String>? workDate,
    Value<int>? unitsMilli,
    Value<int>? ratePaise,
    Value<int>? earnedPaise,
    Value<String?>? notes,
    Value<String>? recordedBy,
    Value<String>? updatedBy,
    Value<String?>? sourceDeviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AttendanceCompanion(
      revision: revision ?? this.revision,
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      workerId: workerId ?? this.workerId,
      workDate: workDate ?? this.workDate,
      unitsMilli: unitsMilli ?? this.unitsMilli,
      ratePaise: ratePaise ?? this.ratePaise,
      earnedPaise: earnedPaise ?? this.earnedPaise,
      notes: notes ?? this.notes,
      recordedBy: recordedBy ?? this.recordedBy,
      updatedBy: updatedBy ?? this.updatedBy,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<String>(workerId.value);
    }
    if (workDate.present) {
      map['work_date'] = Variable<String>(workDate.value);
    }
    if (unitsMilli.present) {
      map['units_milli'] = Variable<int>(unitsMilli.value);
    }
    if (ratePaise.present) {
      map['rate_paise'] = Variable<int>(ratePaise.value);
    }
    if (earnedPaise.present) {
      map['earned_paise'] = Variable<int>(earnedPaise.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (recordedBy.present) {
      map['recorded_by'] = Variable<String>(recordedBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (sourceDeviceId.present) {
      map['source_device_id'] = Variable<String>(sourceDeviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceCompanion(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('workerId: $workerId, ')
          ..write('workDate: $workDate, ')
          ..write('unitsMilli: $unitsMilli, ')
          ..write('ratePaise: $ratePaise, ')
          ..write('earnedPaise: $earnedPaise, ')
          ..write('notes: $notes, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkTypesTable extends WorkTypes
    with TableInfo<$WorkTypesTable, WorkType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKnMeta = const VerificationMeta('nameKn');
  @override
  late final GeneratedColumn<String> nameKn = GeneratedColumn<String>(
    'name_kn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    code,
    nameKn,
    nameEn,
    active,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name_kn')) {
      context.handle(
        _nameKnMeta,
        nameKn.isAcceptableOrUnknown(data['name_kn']!, _nameKnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKnMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkType(
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      nameKn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_kn'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkTypesTable createAlias(String alias) {
    return $WorkTypesTable(attachedDatabase, alias);
  }
}

class WorkType extends DataClass implements Insertable<WorkType> {
  final int revision;
  final int serverSeq;
  final int syncStatus;
  final String id;
  final String farmId;
  final String code;
  final String nameKn;
  final String nameEn;
  final bool active;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WorkType({
    required this.revision,
    required this.serverSeq,
    required this.syncStatus,
    required this.id,
    required this.farmId,
    required this.code,
    required this.nameKn,
    required this.nameEn,
    required this.active,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision'] = Variable<int>(revision);
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['code'] = Variable<String>(code);
    map['name_kn'] = Variable<String>(nameKn);
    map['name_en'] = Variable<String>(nameEn);
    map['active'] = Variable<bool>(active);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkTypesCompanion toCompanion(bool nullToAbsent) {
    return WorkTypesCompanion(
      revision: Value(revision),
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      id: Value(id),
      farmId: Value(farmId),
      code: Value(code),
      nameKn: Value(nameKn),
      nameEn: Value(nameEn),
      active: Value(active),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkType(
      revision: serializer.fromJson<int>(json['revision']),
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      code: serializer.fromJson<String>(json['code']),
      nameKn: serializer.fromJson<String>(json['name_kn']),
      nameEn: serializer.fromJson<String>(json['name_en']),
      active: serializer.fromJson<bool>(json['active']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revision': serializer.toJson<int>(revision),
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'id': serializer.toJson<String>(id),
      'farm_id': serializer.toJson<String>(farmId),
      'code': serializer.toJson<String>(code),
      'name_kn': serializer.toJson<String>(nameKn),
      'name_en': serializer.toJson<String>(nameEn),
      'active': serializer.toJson<bool>(active),
      'sort_order': serializer.toJson<int>(sortOrder),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkType copyWith({
    int? revision,
    int? serverSeq,
    int? syncStatus,
    String? id,
    String? farmId,
    String? code,
    String? nameKn,
    String? nameEn,
    bool? active,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkType(
    revision: revision ?? this.revision,
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    code: code ?? this.code,
    nameKn: nameKn ?? this.nameKn,
    nameEn: nameEn ?? this.nameEn,
    active: active ?? this.active,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkType copyWithCompanion(WorkTypesCompanion data) {
    return WorkType(
      revision: data.revision.present ? data.revision.value : this.revision,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      code: data.code.present ? data.code.value : this.code,
      nameKn: data.nameKn.present ? data.nameKn.value : this.nameKn,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      active: data.active.present ? data.active.value : this.active,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkType(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('code: $code, ')
          ..write('nameKn: $nameKn, ')
          ..write('nameEn: $nameEn, ')
          ..write('active: $active, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    code,
    nameKn,
    nameEn,
    active,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkType &&
          other.revision == this.revision &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.code == this.code &&
          other.nameKn == this.nameKn &&
          other.nameEn == this.nameEn &&
          other.active == this.active &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkTypesCompanion extends UpdateCompanion<WorkType> {
  final Value<int> revision;
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> code;
  final Value<String> nameKn;
  final Value<String> nameEn;
  final Value<bool> active;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkTypesCompanion({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.code = const Value.absent(),
    this.nameKn = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.active = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkTypesCompanion.insert({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String id,
    required String farmId,
    required String code,
    required String nameKn,
    required String nameEn,
    this.active = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       code = Value(code),
       nameKn = Value(nameKn),
       nameEn = Value(nameEn),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkType> custom({
    Expression<int>? revision,
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? code,
    Expression<String>? nameKn,
    Expression<String>? nameEn,
    Expression<bool>? active,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revision != null) 'revision': revision,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (code != null) 'code': code,
      if (nameKn != null) 'name_kn': nameKn,
      if (nameEn != null) 'name_en': nameEn,
      if (active != null) 'active': active,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkTypesCompanion copyWith({
    Value<int>? revision,
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? code,
    Value<String>? nameKn,
    Value<String>? nameEn,
    Value<bool>? active,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkTypesCompanion(
      revision: revision ?? this.revision,
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      code: code ?? this.code,
      nameKn: nameKn ?? this.nameKn,
      nameEn: nameEn ?? this.nameEn,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nameKn.present) {
      map['name_kn'] = Variable<String>(nameKn.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkTypesCompanion(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('code: $code, ')
          ..write('nameKn: $nameKn, ')
          ..write('nameEn: $nameEn, ')
          ..write('active: $active, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkAssignmentsTable extends WorkAssignments
    with TableInfo<$WorkAssignmentsTable, WorkAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workDateMeta = const VerificationMeta(
    'workDate',
  );
  @override
  late final GeneratedColumn<String> workDate = GeneratedColumn<String>(
    'work_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workTypeIdMeta = const VerificationMeta(
    'workTypeId',
  );
  @override
  late final GeneratedColumn<String> workTypeId = GeneratedColumn<String>(
    'work_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldNameMeta = const VerificationMeta(
    'fieldName',
  );
  @override
  late final GeneratedColumn<String> fieldName = GeneratedColumn<String>(
    'field_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedByMeta = const VerificationMeta(
    'assignedBy',
  );
  @override
  late final GeneratedColumn<String> assignedBy = GeneratedColumn<String>(
    'assigned_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    workDate,
    workTypeId,
    fieldName,
    description,
    status,
    notes,
    assignedBy,
    updatedBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkAssignment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('work_date')) {
      context.handle(
        _workDateMeta,
        workDate.isAcceptableOrUnknown(data['work_date']!, _workDateMeta),
      );
    } else if (isInserting) {
      context.missing(_workDateMeta);
    }
    if (data.containsKey('work_type_id')) {
      context.handle(
        _workTypeIdMeta,
        workTypeId.isAcceptableOrUnknown(
          data['work_type_id']!,
          _workTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workTypeIdMeta);
    }
    if (data.containsKey('field_name')) {
      context.handle(
        _fieldNameMeta,
        fieldName.isAcceptableOrUnknown(data['field_name']!, _fieldNameMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('assigned_by')) {
      context.handle(
        _assignedByMeta,
        assignedBy.isAcceptableOrUnknown(data['assigned_by']!, _assignedByMeta),
      );
    } else if (isInserting) {
      context.missing(_assignedByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkAssignment(
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      workDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_date'],
      )!,
      workTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_type_id'],
      )!,
      fieldName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_name'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      assignedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_by'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkAssignmentsTable createAlias(String alias) {
    return $WorkAssignmentsTable(attachedDatabase, alias);
  }
}

class WorkAssignment extends DataClass implements Insertable<WorkAssignment> {
  final int revision;
  final int serverSeq;
  final int syncStatus;
  final String id;
  final String farmId;
  final String workDate;
  final String workTypeId;
  final String? fieldName;
  final String? description;
  final String status;
  final String? notes;
  final String assignedBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WorkAssignment({
    required this.revision,
    required this.serverSeq,
    required this.syncStatus,
    required this.id,
    required this.farmId,
    required this.workDate,
    required this.workTypeId,
    this.fieldName,
    this.description,
    required this.status,
    this.notes,
    required this.assignedBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision'] = Variable<int>(revision);
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['work_date'] = Variable<String>(workDate);
    map['work_type_id'] = Variable<String>(workTypeId);
    if (!nullToAbsent || fieldName != null) {
      map['field_name'] = Variable<String>(fieldName);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['assigned_by'] = Variable<String>(assignedBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return WorkAssignmentsCompanion(
      revision: Value(revision),
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      id: Value(id),
      farmId: Value(farmId),
      workDate: Value(workDate),
      workTypeId: Value(workTypeId),
      fieldName: fieldName == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      assignedBy: Value(assignedBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkAssignment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkAssignment(
      revision: serializer.fromJson<int>(json['revision']),
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      workDate: serializer.fromJson<String>(json['work_date']),
      workTypeId: serializer.fromJson<String>(json['work_type_id']),
      fieldName: serializer.fromJson<String?>(json['field_name']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      assignedBy: serializer.fromJson<String>(json['assigned_by']),
      updatedBy: serializer.fromJson<String>(json['updated_by']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revision': serializer.toJson<int>(revision),
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'id': serializer.toJson<String>(id),
      'farm_id': serializer.toJson<String>(farmId),
      'work_date': serializer.toJson<String>(workDate),
      'work_type_id': serializer.toJson<String>(workTypeId),
      'field_name': serializer.toJson<String?>(fieldName),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'assigned_by': serializer.toJson<String>(assignedBy),
      'updated_by': serializer.toJson<String>(updatedBy),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkAssignment copyWith({
    int? revision,
    int? serverSeq,
    int? syncStatus,
    String? id,
    String? farmId,
    String? workDate,
    String? workTypeId,
    Value<String?> fieldName = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
    String? assignedBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkAssignment(
    revision: revision ?? this.revision,
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    workDate: workDate ?? this.workDate,
    workTypeId: workTypeId ?? this.workTypeId,
    fieldName: fieldName.present ? fieldName.value : this.fieldName,
    description: description.present ? description.value : this.description,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    assignedBy: assignedBy ?? this.assignedBy,
    updatedBy: updatedBy ?? this.updatedBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkAssignment copyWithCompanion(WorkAssignmentsCompanion data) {
    return WorkAssignment(
      revision: data.revision.present ? data.revision.value : this.revision,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      workDate: data.workDate.present ? data.workDate.value : this.workDate,
      workTypeId: data.workTypeId.present
          ? data.workTypeId.value
          : this.workTypeId,
      fieldName: data.fieldName.present ? data.fieldName.value : this.fieldName,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      assignedBy: data.assignedBy.present
          ? data.assignedBy.value
          : this.assignedBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkAssignment(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('workDate: $workDate, ')
          ..write('workTypeId: $workTypeId, ')
          ..write('fieldName: $fieldName, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('assignedBy: $assignedBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    workDate,
    workTypeId,
    fieldName,
    description,
    status,
    notes,
    assignedBy,
    updatedBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkAssignment &&
          other.revision == this.revision &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.workDate == this.workDate &&
          other.workTypeId == this.workTypeId &&
          other.fieldName == this.fieldName &&
          other.description == this.description &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.assignedBy == this.assignedBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkAssignmentsCompanion extends UpdateCompanion<WorkAssignment> {
  final Value<int> revision;
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> workDate;
  final Value<String> workTypeId;
  final Value<String?> fieldName;
  final Value<String?> description;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String> assignedBy;
  final Value<String> updatedBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkAssignmentsCompanion({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.workDate = const Value.absent(),
    this.workTypeId = const Value.absent(),
    this.fieldName = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.assignedBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkAssignmentsCompanion.insert({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String id,
    required String farmId,
    required String workDate,
    required String workTypeId,
    this.fieldName = const Value.absent(),
    this.description = const Value.absent(),
    required String status,
    this.notes = const Value.absent(),
    required String assignedBy,
    required String updatedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       workDate = Value(workDate),
       workTypeId = Value(workTypeId),
       status = Value(status),
       assignedBy = Value(assignedBy),
       updatedBy = Value(updatedBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkAssignment> custom({
    Expression<int>? revision,
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? workDate,
    Expression<String>? workTypeId,
    Expression<String>? fieldName,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? assignedBy,
    Expression<String>? updatedBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revision != null) 'revision': revision,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (workDate != null) 'work_date': workDate,
      if (workTypeId != null) 'work_type_id': workTypeId,
      if (fieldName != null) 'field_name': fieldName,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (assignedBy != null) 'assigned_by': assignedBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkAssignmentsCompanion copyWith({
    Value<int>? revision,
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? workDate,
    Value<String>? workTypeId,
    Value<String?>? fieldName,
    Value<String?>? description,
    Value<String>? status,
    Value<String?>? notes,
    Value<String>? assignedBy,
    Value<String>? updatedBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkAssignmentsCompanion(
      revision: revision ?? this.revision,
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      workDate: workDate ?? this.workDate,
      workTypeId: workTypeId ?? this.workTypeId,
      fieldName: fieldName ?? this.fieldName,
      description: description ?? this.description,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      assignedBy: assignedBy ?? this.assignedBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (workDate.present) {
      map['work_date'] = Variable<String>(workDate.value);
    }
    if (workTypeId.present) {
      map['work_type_id'] = Variable<String>(workTypeId.value);
    }
    if (fieldName.present) {
      map['field_name'] = Variable<String>(fieldName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (assignedBy.present) {
      map['assigned_by'] = Variable<String>(assignedBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkAssignmentsCompanion(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('workDate: $workDate, ')
          ..write('workTypeId: $workTypeId, ')
          ..write('fieldName: $fieldName, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('assignedBy: $assignedBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkAssignmentWorkersTable extends WorkAssignmentWorkers
    with TableInfo<$WorkAssignmentWorkersTable, AssignmentWorker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkAssignmentWorkersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignmentIdMeta = const VerificationMeta(
    'assignmentId',
  );
  @override
  late final GeneratedColumn<String> assignmentId = GeneratedColumn<String>(
    'assignment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workerIdMeta = const VerificationMeta(
    'workerId',
  );
  @override
  late final GeneratedColumn<String> workerId = GeneratedColumn<String>(
    'worker_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _removedMeta = const VerificationMeta(
    'removed',
  );
  @override
  late final GeneratedColumn<bool> removed = GeneratedColumn<bool>(
    'removed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("removed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverSeq,
    syncStatus,
    farmId,
    assignmentId,
    workerId,
    removed,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_assignment_workers';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssignmentWorker> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('assignment_id')) {
      context.handle(
        _assignmentIdMeta,
        assignmentId.isAcceptableOrUnknown(
          data['assignment_id']!,
          _assignmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assignmentIdMeta);
    }
    if (data.containsKey('worker_id')) {
      context.handle(
        _workerIdMeta,
        workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('removed')) {
      context.handle(
        _removedMeta,
        removed.isAcceptableOrUnknown(data['removed']!, _removedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assignmentId, workerId};
  @override
  AssignmentWorker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssignmentWorker(
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      assignmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignment_id'],
      )!,
      workerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}worker_id'],
      )!,
      removed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}removed'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkAssignmentWorkersTable createAlias(String alias) {
    return $WorkAssignmentWorkersTable(attachedDatabase, alias);
  }
}

class AssignmentWorker extends DataClass
    implements Insertable<AssignmentWorker> {
  final int serverSeq;
  final int syncStatus;
  final String farmId;
  final String assignmentId;
  final String workerId;
  final bool removed;
  final DateTime updatedAt;
  const AssignmentWorker({
    required this.serverSeq,
    required this.syncStatus,
    required this.farmId,
    required this.assignmentId,
    required this.workerId,
    required this.removed,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['farm_id'] = Variable<String>(farmId);
    map['assignment_id'] = Variable<String>(assignmentId);
    map['worker_id'] = Variable<String>(workerId);
    map['removed'] = Variable<bool>(removed);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkAssignmentWorkersCompanion toCompanion(bool nullToAbsent) {
    return WorkAssignmentWorkersCompanion(
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      farmId: Value(farmId),
      assignmentId: Value(assignmentId),
      workerId: Value(workerId),
      removed: Value(removed),
      updatedAt: Value(updatedAt),
    );
  }

  factory AssignmentWorker.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssignmentWorker(
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      assignmentId: serializer.fromJson<String>(json['assignment_id']),
      workerId: serializer.fromJson<String>(json['worker_id']),
      removed: serializer.fromJson<bool>(json['removed']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'farm_id': serializer.toJson<String>(farmId),
      'assignment_id': serializer.toJson<String>(assignmentId),
      'worker_id': serializer.toJson<String>(workerId),
      'removed': serializer.toJson<bool>(removed),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AssignmentWorker copyWith({
    int? serverSeq,
    int? syncStatus,
    String? farmId,
    String? assignmentId,
    String? workerId,
    bool? removed,
    DateTime? updatedAt,
  }) => AssignmentWorker(
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    farmId: farmId ?? this.farmId,
    assignmentId: assignmentId ?? this.assignmentId,
    workerId: workerId ?? this.workerId,
    removed: removed ?? this.removed,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AssignmentWorker copyWithCompanion(WorkAssignmentWorkersCompanion data) {
    return AssignmentWorker(
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      removed: data.removed.present ? data.removed.value : this.removed,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentWorker(')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('farmId: $farmId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('workerId: $workerId, ')
          ..write('removed: $removed, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverSeq,
    syncStatus,
    farmId,
    assignmentId,
    workerId,
    removed,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssignmentWorker &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.farmId == this.farmId &&
          other.assignmentId == this.assignmentId &&
          other.workerId == this.workerId &&
          other.removed == this.removed &&
          other.updatedAt == this.updatedAt);
}

class WorkAssignmentWorkersCompanion extends UpdateCompanion<AssignmentWorker> {
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> farmId;
  final Value<String> assignmentId;
  final Value<String> workerId;
  final Value<bool> removed;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkAssignmentWorkersCompanion({
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.farmId = const Value.absent(),
    this.assignmentId = const Value.absent(),
    this.workerId = const Value.absent(),
    this.removed = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkAssignmentWorkersCompanion.insert({
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String farmId,
    required String assignmentId,
    required String workerId,
    this.removed = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : farmId = Value(farmId),
       assignmentId = Value(assignmentId),
       workerId = Value(workerId),
       updatedAt = Value(updatedAt);
  static Insertable<AssignmentWorker> custom({
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? farmId,
    Expression<String>? assignmentId,
    Expression<String>? workerId,
    Expression<bool>? removed,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (farmId != null) 'farm_id': farmId,
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (workerId != null) 'worker_id': workerId,
      if (removed != null) 'removed': removed,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkAssignmentWorkersCompanion copyWith({
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? farmId,
    Value<String>? assignmentId,
    Value<String>? workerId,
    Value<bool>? removed,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkAssignmentWorkersCompanion(
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      farmId: farmId ?? this.farmId,
      assignmentId: assignmentId ?? this.assignmentId,
      workerId: workerId ?? this.workerId,
      removed: removed ?? this.removed,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (assignmentId.present) {
      map['assignment_id'] = Variable<String>(assignmentId.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<String>(workerId.value);
    }
    if (removed.present) {
      map['removed'] = Variable<bool>(removed.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkAssignmentWorkersCompanion(')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('farmId: $farmId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('workerId: $workerId, ')
          ..write('removed: $removed, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinancialTransactionsTable extends FinancialTransactions
    with TableInfo<$FinancialTransactionsTable, LedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workerIdMeta = const VerificationMeta(
    'workerId',
  );
  @override
  late final GeneratedColumn<String> workerId = GeneratedColumn<String>(
    'worker_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leaderWorkerIdMeta = const VerificationMeta(
    'leaderWorkerId',
  );
  @override
  late final GeneratedColumn<String> leaderWorkerId = GeneratedColumn<String>(
    'leader_worker_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReversalMeta = const VerificationMeta(
    'isReversal',
  );
  @override
  late final GeneratedColumn<bool> isReversal = GeneratedColumn<bool>(
    'is_reversal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_reversal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reversesIdMeta = const VerificationMeta(
    'reversesId',
  );
  @override
  late final GeneratedColumn<String> reversesId = GeneratedColumn<String>(
    'reverses_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relatedEntryIdMeta = const VerificationMeta(
    'relatedEntryId',
  );
  @override
  late final GeneratedColumn<String> relatedEntryId = GeneratedColumn<String>(
    'related_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidByMeta = const VerificationMeta('paidBy');
  @override
  late final GeneratedColumn<String> paidBy = GeneratedColumn<String>(
    'paid_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidByNameMeta = const VerificationMeta(
    'paidByName',
  );
  @override
  late final GeneratedColumn<String> paidByName = GeneratedColumn<String>(
    'paid_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedByMeta = const VerificationMeta(
    'recordedBy',
  );
  @override
  late final GeneratedColumn<String> recordedBy = GeneratedColumn<String>(
    'recorded_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedByNameMeta = const VerificationMeta(
    'recordedByName',
  );
  @override
  late final GeneratedColumn<String> recordedByName = GeneratedColumn<String>(
    'recorded_by_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceDeviceIdMeta = const VerificationMeta(
    'sourceDeviceId',
  );
  @override
  late final GeneratedColumn<String> sourceDeviceId = GeneratedColumn<String>(
    'source_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverSeq,
    syncStatus,
    id,
    farmId,
    entryType,
    workerId,
    leaderWorkerId,
    amountPaise,
    isReversal,
    reversesId,
    relatedEntryId,
    businessDate,
    occurredAt,
    method,
    reference,
    notes,
    paidBy,
    paidByName,
    recordedBy,
    recordedByName,
    sourceDeviceId,
    opId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('worker_id')) {
      context.handle(
        _workerIdMeta,
        workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('leader_worker_id')) {
      context.handle(
        _leaderWorkerIdMeta,
        leaderWorkerId.isAcceptableOrUnknown(
          data['leader_worker_id']!,
          _leaderWorkerIdMeta,
        ),
      );
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('is_reversal')) {
      context.handle(
        _isReversalMeta,
        isReversal.isAcceptableOrUnknown(data['is_reversal']!, _isReversalMeta),
      );
    }
    if (data.containsKey('reverses_id')) {
      context.handle(
        _reversesIdMeta,
        reversesId.isAcceptableOrUnknown(data['reverses_id']!, _reversesIdMeta),
      );
    }
    if (data.containsKey('related_entry_id')) {
      context.handle(
        _relatedEntryIdMeta,
        relatedEntryId.isAcceptableOrUnknown(
          data['related_entry_id']!,
          _relatedEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('paid_by')) {
      context.handle(
        _paidByMeta,
        paidBy.isAcceptableOrUnknown(data['paid_by']!, _paidByMeta),
      );
    }
    if (data.containsKey('paid_by_name')) {
      context.handle(
        _paidByNameMeta,
        paidByName.isAcceptableOrUnknown(
          data['paid_by_name']!,
          _paidByNameMeta,
        ),
      );
    }
    if (data.containsKey('recorded_by')) {
      context.handle(
        _recordedByMeta,
        recordedBy.isAcceptableOrUnknown(data['recorded_by']!, _recordedByMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedByMeta);
    }
    if (data.containsKey('recorded_by_name')) {
      context.handle(
        _recordedByNameMeta,
        recordedByName.isAcceptableOrUnknown(
          data['recorded_by_name']!,
          _recordedByNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordedByNameMeta);
    }
    if (data.containsKey('source_device_id')) {
      context.handle(
        _sourceDeviceIdMeta,
        sourceDeviceId.isAcceptableOrUnknown(
          data['source_device_id']!,
          _sourceDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntry(
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_type'],
      )!,
      workerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}worker_id'],
      )!,
      leaderWorkerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leader_worker_id'],
      ),
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      isReversal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_reversal'],
      )!,
      reversesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_id'],
      ),
      relatedEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_entry_id'],
      ),
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      paidBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_by'],
      ),
      paidByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_by_name'],
      ),
      recordedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded_by'],
      )!,
      recordedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded_by_name'],
      )!,
      sourceDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device_id'],
      ),
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FinancialTransactionsTable createAlias(String alias) {
    return $FinancialTransactionsTable(attachedDatabase, alias);
  }
}

class LedgerEntry extends DataClass implements Insertable<LedgerEntry> {
  final int serverSeq;
  final int syncStatus;
  final String id;
  final String farmId;
  final String entryType;
  final String workerId;
  final String? leaderWorkerId;
  final int amountPaise;
  final bool isReversal;
  final String? reversesId;
  final String? relatedEntryId;
  final String businessDate;
  final DateTime occurredAt;
  final String method;
  final String? reference;
  final String? notes;
  final String? paidBy;
  final String? paidByName;
  final String recordedBy;
  final String recordedByName;
  final String? sourceDeviceId;
  final String? opId;
  final DateTime createdAt;
  const LedgerEntry({
    required this.serverSeq,
    required this.syncStatus,
    required this.id,
    required this.farmId,
    required this.entryType,
    required this.workerId,
    this.leaderWorkerId,
    required this.amountPaise,
    required this.isReversal,
    this.reversesId,
    this.relatedEntryId,
    required this.businessDate,
    required this.occurredAt,
    required this.method,
    this.reference,
    this.notes,
    this.paidBy,
    this.paidByName,
    required this.recordedBy,
    required this.recordedByName,
    this.sourceDeviceId,
    this.opId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['entry_type'] = Variable<String>(entryType);
    map['worker_id'] = Variable<String>(workerId);
    if (!nullToAbsent || leaderWorkerId != null) {
      map['leader_worker_id'] = Variable<String>(leaderWorkerId);
    }
    map['amount_paise'] = Variable<int>(amountPaise);
    map['is_reversal'] = Variable<bool>(isReversal);
    if (!nullToAbsent || reversesId != null) {
      map['reverses_id'] = Variable<String>(reversesId);
    }
    if (!nullToAbsent || relatedEntryId != null) {
      map['related_entry_id'] = Variable<String>(relatedEntryId);
    }
    map['business_date'] = Variable<String>(businessDate);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || paidBy != null) {
      map['paid_by'] = Variable<String>(paidBy);
    }
    if (!nullToAbsent || paidByName != null) {
      map['paid_by_name'] = Variable<String>(paidByName);
    }
    map['recorded_by'] = Variable<String>(recordedBy);
    map['recorded_by_name'] = Variable<String>(recordedByName);
    if (!nullToAbsent || sourceDeviceId != null) {
      map['source_device_id'] = Variable<String>(sourceDeviceId);
    }
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FinancialTransactionsCompanion toCompanion(bool nullToAbsent) {
    return FinancialTransactionsCompanion(
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      id: Value(id),
      farmId: Value(farmId),
      entryType: Value(entryType),
      workerId: Value(workerId),
      leaderWorkerId: leaderWorkerId == null && nullToAbsent
          ? const Value.absent()
          : Value(leaderWorkerId),
      amountPaise: Value(amountPaise),
      isReversal: Value(isReversal),
      reversesId: reversesId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesId),
      relatedEntryId: relatedEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedEntryId),
      businessDate: Value(businessDate),
      occurredAt: Value(occurredAt),
      method: Value(method),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      paidBy: paidBy == null && nullToAbsent
          ? const Value.absent()
          : Value(paidBy),
      paidByName: paidByName == null && nullToAbsent
          ? const Value.absent()
          : Value(paidByName),
      recordedBy: Value(recordedBy),
      recordedByName: Value(recordedByName),
      sourceDeviceId: sourceDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDeviceId),
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      createdAt: Value(createdAt),
    );
  }

  factory LedgerEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntry(
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      entryType: serializer.fromJson<String>(json['entry_type']),
      workerId: serializer.fromJson<String>(json['worker_id']),
      leaderWorkerId: serializer.fromJson<String?>(json['leader_worker_id']),
      amountPaise: serializer.fromJson<int>(json['amount_paise']),
      isReversal: serializer.fromJson<bool>(json['is_reversal']),
      reversesId: serializer.fromJson<String?>(json['reverses_id']),
      relatedEntryId: serializer.fromJson<String?>(json['related_entry_id']),
      businessDate: serializer.fromJson<String>(json['business_date']),
      occurredAt: serializer.fromJson<DateTime>(json['occurred_at']),
      method: serializer.fromJson<String>(json['method']),
      reference: serializer.fromJson<String?>(json['reference']),
      notes: serializer.fromJson<String?>(json['notes']),
      paidBy: serializer.fromJson<String?>(json['paid_by']),
      paidByName: serializer.fromJson<String?>(json['paid_by_name']),
      recordedBy: serializer.fromJson<String>(json['recorded_by']),
      recordedByName: serializer.fromJson<String>(json['recorded_by_name']),
      sourceDeviceId: serializer.fromJson<String?>(json['source_device_id']),
      opId: serializer.fromJson<String?>(json['op_id']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'id': serializer.toJson<String>(id),
      'farm_id': serializer.toJson<String>(farmId),
      'entry_type': serializer.toJson<String>(entryType),
      'worker_id': serializer.toJson<String>(workerId),
      'leader_worker_id': serializer.toJson<String?>(leaderWorkerId),
      'amount_paise': serializer.toJson<int>(amountPaise),
      'is_reversal': serializer.toJson<bool>(isReversal),
      'reverses_id': serializer.toJson<String?>(reversesId),
      'related_entry_id': serializer.toJson<String?>(relatedEntryId),
      'business_date': serializer.toJson<String>(businessDate),
      'occurred_at': serializer.toJson<DateTime>(occurredAt),
      'method': serializer.toJson<String>(method),
      'reference': serializer.toJson<String?>(reference),
      'notes': serializer.toJson<String?>(notes),
      'paid_by': serializer.toJson<String?>(paidBy),
      'paid_by_name': serializer.toJson<String?>(paidByName),
      'recorded_by': serializer.toJson<String>(recordedBy),
      'recorded_by_name': serializer.toJson<String>(recordedByName),
      'source_device_id': serializer.toJson<String?>(sourceDeviceId),
      'op_id': serializer.toJson<String?>(opId),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  LedgerEntry copyWith({
    int? serverSeq,
    int? syncStatus,
    String? id,
    String? farmId,
    String? entryType,
    String? workerId,
    Value<String?> leaderWorkerId = const Value.absent(),
    int? amountPaise,
    bool? isReversal,
    Value<String?> reversesId = const Value.absent(),
    Value<String?> relatedEntryId = const Value.absent(),
    String? businessDate,
    DateTime? occurredAt,
    String? method,
    Value<String?> reference = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> paidBy = const Value.absent(),
    Value<String?> paidByName = const Value.absent(),
    String? recordedBy,
    String? recordedByName,
    Value<String?> sourceDeviceId = const Value.absent(),
    Value<String?> opId = const Value.absent(),
    DateTime? createdAt,
  }) => LedgerEntry(
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    entryType: entryType ?? this.entryType,
    workerId: workerId ?? this.workerId,
    leaderWorkerId: leaderWorkerId.present
        ? leaderWorkerId.value
        : this.leaderWorkerId,
    amountPaise: amountPaise ?? this.amountPaise,
    isReversal: isReversal ?? this.isReversal,
    reversesId: reversesId.present ? reversesId.value : this.reversesId,
    relatedEntryId: relatedEntryId.present
        ? relatedEntryId.value
        : this.relatedEntryId,
    businessDate: businessDate ?? this.businessDate,
    occurredAt: occurredAt ?? this.occurredAt,
    method: method ?? this.method,
    reference: reference.present ? reference.value : this.reference,
    notes: notes.present ? notes.value : this.notes,
    paidBy: paidBy.present ? paidBy.value : this.paidBy,
    paidByName: paidByName.present ? paidByName.value : this.paidByName,
    recordedBy: recordedBy ?? this.recordedBy,
    recordedByName: recordedByName ?? this.recordedByName,
    sourceDeviceId: sourceDeviceId.present
        ? sourceDeviceId.value
        : this.sourceDeviceId,
    opId: opId.present ? opId.value : this.opId,
    createdAt: createdAt ?? this.createdAt,
  );
  LedgerEntry copyWithCompanion(FinancialTransactionsCompanion data) {
    return LedgerEntry(
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      leaderWorkerId: data.leaderWorkerId.present
          ? data.leaderWorkerId.value
          : this.leaderWorkerId,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      isReversal: data.isReversal.present
          ? data.isReversal.value
          : this.isReversal,
      reversesId: data.reversesId.present
          ? data.reversesId.value
          : this.reversesId,
      relatedEntryId: data.relatedEntryId.present
          ? data.relatedEntryId.value
          : this.relatedEntryId,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      method: data.method.present ? data.method.value : this.method,
      reference: data.reference.present ? data.reference.value : this.reference,
      notes: data.notes.present ? data.notes.value : this.notes,
      paidBy: data.paidBy.present ? data.paidBy.value : this.paidBy,
      paidByName: data.paidByName.present
          ? data.paidByName.value
          : this.paidByName,
      recordedBy: data.recordedBy.present
          ? data.recordedBy.value
          : this.recordedBy,
      recordedByName: data.recordedByName.present
          ? data.recordedByName.value
          : this.recordedByName,
      sourceDeviceId: data.sourceDeviceId.present
          ? data.sourceDeviceId.value
          : this.sourceDeviceId,
      opId: data.opId.present ? data.opId.value : this.opId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntry(')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('entryType: $entryType, ')
          ..write('workerId: $workerId, ')
          ..write('leaderWorkerId: $leaderWorkerId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('isReversal: $isReversal, ')
          ..write('reversesId: $reversesId, ')
          ..write('relatedEntryId: $relatedEntryId, ')
          ..write('businessDate: $businessDate, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('paidBy: $paidBy, ')
          ..write('paidByName: $paidByName, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('recordedByName: $recordedByName, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('opId: $opId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    serverSeq,
    syncStatus,
    id,
    farmId,
    entryType,
    workerId,
    leaderWorkerId,
    amountPaise,
    isReversal,
    reversesId,
    relatedEntryId,
    businessDate,
    occurredAt,
    method,
    reference,
    notes,
    paidBy,
    paidByName,
    recordedBy,
    recordedByName,
    sourceDeviceId,
    opId,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntry &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.entryType == this.entryType &&
          other.workerId == this.workerId &&
          other.leaderWorkerId == this.leaderWorkerId &&
          other.amountPaise == this.amountPaise &&
          other.isReversal == this.isReversal &&
          other.reversesId == this.reversesId &&
          other.relatedEntryId == this.relatedEntryId &&
          other.businessDate == this.businessDate &&
          other.occurredAt == this.occurredAt &&
          other.method == this.method &&
          other.reference == this.reference &&
          other.notes == this.notes &&
          other.paidBy == this.paidBy &&
          other.paidByName == this.paidByName &&
          other.recordedBy == this.recordedBy &&
          other.recordedByName == this.recordedByName &&
          other.sourceDeviceId == this.sourceDeviceId &&
          other.opId == this.opId &&
          other.createdAt == this.createdAt);
}

class FinancialTransactionsCompanion extends UpdateCompanion<LedgerEntry> {
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> entryType;
  final Value<String> workerId;
  final Value<String?> leaderWorkerId;
  final Value<int> amountPaise;
  final Value<bool> isReversal;
  final Value<String?> reversesId;
  final Value<String?> relatedEntryId;
  final Value<String> businessDate;
  final Value<DateTime> occurredAt;
  final Value<String> method;
  final Value<String?> reference;
  final Value<String?> notes;
  final Value<String?> paidBy;
  final Value<String?> paidByName;
  final Value<String> recordedBy;
  final Value<String> recordedByName;
  final Value<String?> sourceDeviceId;
  final Value<String?> opId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FinancialTransactionsCompanion({
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.workerId = const Value.absent(),
    this.leaderWorkerId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.isReversal = const Value.absent(),
    this.reversesId = const Value.absent(),
    this.relatedEntryId = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.method = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.paidBy = const Value.absent(),
    this.paidByName = const Value.absent(),
    this.recordedBy = const Value.absent(),
    this.recordedByName = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.opId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialTransactionsCompanion.insert({
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String id,
    required String farmId,
    required String entryType,
    required String workerId,
    this.leaderWorkerId = const Value.absent(),
    required int amountPaise,
    this.isReversal = const Value.absent(),
    this.reversesId = const Value.absent(),
    this.relatedEntryId = const Value.absent(),
    required String businessDate,
    required DateTime occurredAt,
    required String method,
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.paidBy = const Value.absent(),
    this.paidByName = const Value.absent(),
    required String recordedBy,
    required String recordedByName,
    this.sourceDeviceId = const Value.absent(),
    this.opId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       entryType = Value(entryType),
       workerId = Value(workerId),
       amountPaise = Value(amountPaise),
       businessDate = Value(businessDate),
       occurredAt = Value(occurredAt),
       method = Value(method),
       recordedBy = Value(recordedBy),
       recordedByName = Value(recordedByName),
       createdAt = Value(createdAt);
  static Insertable<LedgerEntry> custom({
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? entryType,
    Expression<String>? workerId,
    Expression<String>? leaderWorkerId,
    Expression<int>? amountPaise,
    Expression<bool>? isReversal,
    Expression<String>? reversesId,
    Expression<String>? relatedEntryId,
    Expression<String>? businessDate,
    Expression<DateTime>? occurredAt,
    Expression<String>? method,
    Expression<String>? reference,
    Expression<String>? notes,
    Expression<String>? paidBy,
    Expression<String>? paidByName,
    Expression<String>? recordedBy,
    Expression<String>? recordedByName,
    Expression<String>? sourceDeviceId,
    Expression<String>? opId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (entryType != null) 'entry_type': entryType,
      if (workerId != null) 'worker_id': workerId,
      if (leaderWorkerId != null) 'leader_worker_id': leaderWorkerId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (isReversal != null) 'is_reversal': isReversal,
      if (reversesId != null) 'reverses_id': reversesId,
      if (relatedEntryId != null) 'related_entry_id': relatedEntryId,
      if (businessDate != null) 'business_date': businessDate,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (method != null) 'method': method,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
      if (paidBy != null) 'paid_by': paidBy,
      if (paidByName != null) 'paid_by_name': paidByName,
      if (recordedBy != null) 'recorded_by': recordedBy,
      if (recordedByName != null) 'recorded_by_name': recordedByName,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (opId != null) 'op_id': opId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialTransactionsCompanion copyWith({
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? entryType,
    Value<String>? workerId,
    Value<String?>? leaderWorkerId,
    Value<int>? amountPaise,
    Value<bool>? isReversal,
    Value<String?>? reversesId,
    Value<String?>? relatedEntryId,
    Value<String>? businessDate,
    Value<DateTime>? occurredAt,
    Value<String>? method,
    Value<String?>? reference,
    Value<String?>? notes,
    Value<String?>? paidBy,
    Value<String?>? paidByName,
    Value<String>? recordedBy,
    Value<String>? recordedByName,
    Value<String?>? sourceDeviceId,
    Value<String?>? opId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FinancialTransactionsCompanion(
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      entryType: entryType ?? this.entryType,
      workerId: workerId ?? this.workerId,
      leaderWorkerId: leaderWorkerId ?? this.leaderWorkerId,
      amountPaise: amountPaise ?? this.amountPaise,
      isReversal: isReversal ?? this.isReversal,
      reversesId: reversesId ?? this.reversesId,
      relatedEntryId: relatedEntryId ?? this.relatedEntryId,
      businessDate: businessDate ?? this.businessDate,
      occurredAt: occurredAt ?? this.occurredAt,
      method: method ?? this.method,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      paidBy: paidBy ?? this.paidBy,
      paidByName: paidByName ?? this.paidByName,
      recordedBy: recordedBy ?? this.recordedBy,
      recordedByName: recordedByName ?? this.recordedByName,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      opId: opId ?? this.opId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<String>(workerId.value);
    }
    if (leaderWorkerId.present) {
      map['leader_worker_id'] = Variable<String>(leaderWorkerId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (isReversal.present) {
      map['is_reversal'] = Variable<bool>(isReversal.value);
    }
    if (reversesId.present) {
      map['reverses_id'] = Variable<String>(reversesId.value);
    }
    if (relatedEntryId.present) {
      map['related_entry_id'] = Variable<String>(relatedEntryId.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (paidBy.present) {
      map['paid_by'] = Variable<String>(paidBy.value);
    }
    if (paidByName.present) {
      map['paid_by_name'] = Variable<String>(paidByName.value);
    }
    if (recordedBy.present) {
      map['recorded_by'] = Variable<String>(recordedBy.value);
    }
    if (recordedByName.present) {
      map['recorded_by_name'] = Variable<String>(recordedByName.value);
    }
    if (sourceDeviceId.present) {
      map['source_device_id'] = Variable<String>(sourceDeviceId.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
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
    return (StringBuffer('FinancialTransactionsCompanion(')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('entryType: $entryType, ')
          ..write('workerId: $workerId, ')
          ..write('leaderWorkerId: $leaderWorkerId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('isReversal: $isReversal, ')
          ..write('reversesId: $reversesId, ')
          ..write('relatedEntryId: $relatedEntryId, ')
          ..write('businessDate: $businessDate, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('paidBy: $paidBy, ')
          ..write('paidByName: $paidByName, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('recordedByName: $recordedByName, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('opId: $opId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettlementsTable extends Settlements
    with TableInfo<$SettlementsTable, Settlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<String> weekStart = GeneratedColumn<String>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekEndMeta = const VerificationMeta(
    'weekEnd',
  );
  @override
  late final GeneratedColumn<String> weekEnd = GeneratedColumn<String>(
    'week_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _needsReviewMeta = const VerificationMeta(
    'needsReview',
  );
  @override
  late final GeneratedColumn<bool> needsReview = GeneratedColumn<bool>(
    'needs_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _closedByMeta = const VerificationMeta(
    'closedBy',
  );
  @override
  late final GeneratedColumn<String> closedBy = GeneratedColumn<String>(
    'closed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedByNameMeta = const VerificationMeta(
    'closedByName',
  );
  @override
  late final GeneratedColumn<String> closedByName = GeneratedColumn<String>(
    'closed_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    weekStart,
    weekEnd,
    status,
    needsReview,
    closedBy,
    closedByName,
    closedAt,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Settlement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('week_end')) {
      context.handle(
        _weekEndMeta,
        weekEnd.isAcceptableOrUnknown(data['week_end']!, _weekEndMeta),
      );
    } else if (isInserting) {
      context.missing(_weekEndMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('needs_review')) {
      context.handle(
        _needsReviewMeta,
        needsReview.isAcceptableOrUnknown(
          data['needs_review']!,
          _needsReviewMeta,
        ),
      );
    }
    if (data.containsKey('closed_by')) {
      context.handle(
        _closedByMeta,
        closedBy.isAcceptableOrUnknown(data['closed_by']!, _closedByMeta),
      );
    }
    if (data.containsKey('closed_by_name')) {
      context.handle(
        _closedByNameMeta,
        closedByName.isAcceptableOrUnknown(
          data['closed_by_name']!,
          _closedByNameMeta,
        ),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {farmId, weekStart},
  ];
  @override
  Settlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Settlement(
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start'],
      )!,
      weekEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_end'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      needsReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_review'],
      )!,
      closedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by'],
      ),
      closedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_name'],
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SettlementsTable createAlias(String alias) {
    return $SettlementsTable(attachedDatabase, alias);
  }
}

class Settlement extends DataClass implements Insertable<Settlement> {
  final int revision;
  final int serverSeq;
  final int syncStatus;
  final String id;
  final String farmId;
  final String weekStart;
  final String weekEnd;
  final String status;
  final bool needsReview;
  final String? closedBy;
  final String? closedByName;
  final DateTime? closedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Settlement({
    required this.revision,
    required this.serverSeq,
    required this.syncStatus,
    required this.id,
    required this.farmId,
    required this.weekStart,
    required this.weekEnd,
    required this.status,
    required this.needsReview,
    this.closedBy,
    this.closedByName,
    this.closedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision'] = Variable<int>(revision);
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['week_start'] = Variable<String>(weekStart);
    map['week_end'] = Variable<String>(weekEnd);
    map['status'] = Variable<String>(status);
    map['needs_review'] = Variable<bool>(needsReview);
    if (!nullToAbsent || closedBy != null) {
      map['closed_by'] = Variable<String>(closedBy);
    }
    if (!nullToAbsent || closedByName != null) {
      map['closed_by_name'] = Variable<String>(closedByName);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettlementsCompanion toCompanion(bool nullToAbsent) {
    return SettlementsCompanion(
      revision: Value(revision),
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      id: Value(id),
      farmId: Value(farmId),
      weekStart: Value(weekStart),
      weekEnd: Value(weekEnd),
      status: Value(status),
      needsReview: Value(needsReview),
      closedBy: closedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(closedBy),
      closedByName: closedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(closedByName),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Settlement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Settlement(
      revision: serializer.fromJson<int>(json['revision']),
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      weekStart: serializer.fromJson<String>(json['week_start']),
      weekEnd: serializer.fromJson<String>(json['week_end']),
      status: serializer.fromJson<String>(json['status']),
      needsReview: serializer.fromJson<bool>(json['needs_review']),
      closedBy: serializer.fromJson<String?>(json['closed_by']),
      closedByName: serializer.fromJson<String?>(json['closed_by_name']),
      closedAt: serializer.fromJson<DateTime?>(json['closed_at']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revision': serializer.toJson<int>(revision),
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'id': serializer.toJson<String>(id),
      'farm_id': serializer.toJson<String>(farmId),
      'week_start': serializer.toJson<String>(weekStart),
      'week_end': serializer.toJson<String>(weekEnd),
      'status': serializer.toJson<String>(status),
      'needs_review': serializer.toJson<bool>(needsReview),
      'closed_by': serializer.toJson<String?>(closedBy),
      'closed_by_name': serializer.toJson<String?>(closedByName),
      'closed_at': serializer.toJson<DateTime?>(closedAt),
      'notes': serializer.toJson<String?>(notes),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Settlement copyWith({
    int? revision,
    int? serverSeq,
    int? syncStatus,
    String? id,
    String? farmId,
    String? weekStart,
    String? weekEnd,
    String? status,
    bool? needsReview,
    Value<String?> closedBy = const Value.absent(),
    Value<String?> closedByName = const Value.absent(),
    Value<DateTime?> closedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Settlement(
    revision: revision ?? this.revision,
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    weekStart: weekStart ?? this.weekStart,
    weekEnd: weekEnd ?? this.weekEnd,
    status: status ?? this.status,
    needsReview: needsReview ?? this.needsReview,
    closedBy: closedBy.present ? closedBy.value : this.closedBy,
    closedByName: closedByName.present ? closedByName.value : this.closedByName,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Settlement copyWithCompanion(SettlementsCompanion data) {
    return Settlement(
      revision: data.revision.present ? data.revision.value : this.revision,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      weekEnd: data.weekEnd.present ? data.weekEnd.value : this.weekEnd,
      status: data.status.present ? data.status.value : this.status,
      needsReview: data.needsReview.present
          ? data.needsReview.value
          : this.needsReview,
      closedBy: data.closedBy.present ? data.closedBy.value : this.closedBy,
      closedByName: data.closedByName.present
          ? data.closedByName.value
          : this.closedByName,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Settlement(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('weekStart: $weekStart, ')
          ..write('weekEnd: $weekEnd, ')
          ..write('status: $status, ')
          ..write('needsReview: $needsReview, ')
          ..write('closedBy: $closedBy, ')
          ..write('closedByName: $closedByName, ')
          ..write('closedAt: $closedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    revision,
    serverSeq,
    syncStatus,
    id,
    farmId,
    weekStart,
    weekEnd,
    status,
    needsReview,
    closedBy,
    closedByName,
    closedAt,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Settlement &&
          other.revision == this.revision &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.weekStart == this.weekStart &&
          other.weekEnd == this.weekEnd &&
          other.status == this.status &&
          other.needsReview == this.needsReview &&
          other.closedBy == this.closedBy &&
          other.closedByName == this.closedByName &&
          other.closedAt == this.closedAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SettlementsCompanion extends UpdateCompanion<Settlement> {
  final Value<int> revision;
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> weekStart;
  final Value<String> weekEnd;
  final Value<String> status;
  final Value<bool> needsReview;
  final Value<String?> closedBy;
  final Value<String?> closedByName;
  final Value<DateTime?> closedAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettlementsCompanion({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.weekEnd = const Value.absent(),
    this.status = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.closedByName = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettlementsCompanion.insert({
    this.revision = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String id,
    required String farmId,
    required String weekStart,
    required String weekEnd,
    required String status,
    this.needsReview = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.closedByName = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       weekStart = Value(weekStart),
       weekEnd = Value(weekEnd),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Settlement> custom({
    Expression<int>? revision,
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? weekStart,
    Expression<String>? weekEnd,
    Expression<String>? status,
    Expression<bool>? needsReview,
    Expression<String>? closedBy,
    Expression<String>? closedByName,
    Expression<DateTime>? closedAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revision != null) 'revision': revision,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (weekStart != null) 'week_start': weekStart,
      if (weekEnd != null) 'week_end': weekEnd,
      if (status != null) 'status': status,
      if (needsReview != null) 'needs_review': needsReview,
      if (closedBy != null) 'closed_by': closedBy,
      if (closedByName != null) 'closed_by_name': closedByName,
      if (closedAt != null) 'closed_at': closedAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettlementsCompanion copyWith({
    Value<int>? revision,
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? weekStart,
    Value<String>? weekEnd,
    Value<String>? status,
    Value<bool>? needsReview,
    Value<String?>? closedBy,
    Value<String?>? closedByName,
    Value<DateTime?>? closedAt,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SettlementsCompanion(
      revision: revision ?? this.revision,
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      status: status ?? this.status,
      needsReview: needsReview ?? this.needsReview,
      closedBy: closedBy ?? this.closedBy,
      closedByName: closedByName ?? this.closedByName,
      closedAt: closedAt ?? this.closedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<String>(weekStart.value);
    }
    if (weekEnd.present) {
      map['week_end'] = Variable<String>(weekEnd.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (needsReview.present) {
      map['needs_review'] = Variable<bool>(needsReview.value);
    }
    if (closedBy.present) {
      map['closed_by'] = Variable<String>(closedBy.value);
    }
    if (closedByName.present) {
      map['closed_by_name'] = Variable<String>(closedByName.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementsCompanion(')
          ..write('revision: $revision, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('weekStart: $weekStart, ')
          ..write('weekEnd: $weekEnd, ')
          ..write('status: $status, ')
          ..write('needsReview: $needsReview, ')
          ..write('closedBy: $closedBy, ')
          ..write('closedByName: $closedByName, ')
          ..write('closedAt: $closedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettlementItemsTable extends SettlementItems
    with TableInfo<$SettlementItemsTable, SettlementItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettlementItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settlementIdMeta = const VerificationMeta(
    'settlementId',
  );
  @override
  late final GeneratedColumn<String> settlementId = GeneratedColumn<String>(
    'settlement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workerIdMeta = const VerificationMeta(
    'workerId',
  );
  @override
  late final GeneratedColumn<String> workerId = GeneratedColumn<String>(
    'worker_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitsMilliMeta = const VerificationMeta(
    'unitsMilli',
  );
  @override
  late final GeneratedColumn<int> unitsMilli = GeneratedColumn<int>(
    'units_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _openingPaiseMeta = const VerificationMeta(
    'openingPaise',
  );
  @override
  late final GeneratedColumn<int> openingPaise = GeneratedColumn<int>(
    'opening_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _grossPaiseMeta = const VerificationMeta(
    'grossPaise',
  );
  @override
  late final GeneratedColumn<int> grossPaise = GeneratedColumn<int>(
    'gross_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _additionsPaiseMeta = const VerificationMeta(
    'additionsPaise',
  );
  @override
  late final GeneratedColumn<int> additionsPaise = GeneratedColumn<int>(
    'additions_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _advancesPaiseMeta = const VerificationMeta(
    'advancesPaise',
  );
  @override
  late final GeneratedColumn<int> advancesPaise = GeneratedColumn<int>(
    'advances_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _directPaidPaiseMeta = const VerificationMeta(
    'directPaidPaise',
  );
  @override
  late final GeneratedColumn<int> directPaidPaise = GeneratedColumn<int>(
    'direct_paid_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _leaderPaidPaiseMeta = const VerificationMeta(
    'leaderPaidPaise',
  );
  @override
  late final GeneratedColumn<int> leaderPaidPaise = GeneratedColumn<int>(
    'leader_paid_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _closingPaiseMeta = const VerificationMeta(
    'closingPaise',
  );
  @override
  late final GeneratedColumn<int> closingPaise = GeneratedColumn<int>(
    'closing_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverSeq,
    syncStatus,
    farmId,
    settlementId,
    workerId,
    unitsMilli,
    openingPaise,
    grossPaise,
    additionsPaise,
    advancesPaise,
    directPaidPaise,
    leaderPaidPaise,
    closingPaise,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlement_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettlementItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('settlement_id')) {
      context.handle(
        _settlementIdMeta,
        settlementId.isAcceptableOrUnknown(
          data['settlement_id']!,
          _settlementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settlementIdMeta);
    }
    if (data.containsKey('worker_id')) {
      context.handle(
        _workerIdMeta,
        workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('units_milli')) {
      context.handle(
        _unitsMilliMeta,
        unitsMilli.isAcceptableOrUnknown(data['units_milli']!, _unitsMilliMeta),
      );
    }
    if (data.containsKey('opening_paise')) {
      context.handle(
        _openingPaiseMeta,
        openingPaise.isAcceptableOrUnknown(
          data['opening_paise']!,
          _openingPaiseMeta,
        ),
      );
    }
    if (data.containsKey('gross_paise')) {
      context.handle(
        _grossPaiseMeta,
        grossPaise.isAcceptableOrUnknown(data['gross_paise']!, _grossPaiseMeta),
      );
    }
    if (data.containsKey('additions_paise')) {
      context.handle(
        _additionsPaiseMeta,
        additionsPaise.isAcceptableOrUnknown(
          data['additions_paise']!,
          _additionsPaiseMeta,
        ),
      );
    }
    if (data.containsKey('advances_paise')) {
      context.handle(
        _advancesPaiseMeta,
        advancesPaise.isAcceptableOrUnknown(
          data['advances_paise']!,
          _advancesPaiseMeta,
        ),
      );
    }
    if (data.containsKey('direct_paid_paise')) {
      context.handle(
        _directPaidPaiseMeta,
        directPaidPaise.isAcceptableOrUnknown(
          data['direct_paid_paise']!,
          _directPaidPaiseMeta,
        ),
      );
    }
    if (data.containsKey('leader_paid_paise')) {
      context.handle(
        _leaderPaidPaiseMeta,
        leaderPaidPaise.isAcceptableOrUnknown(
          data['leader_paid_paise']!,
          _leaderPaidPaiseMeta,
        ),
      );
    }
    if (data.containsKey('closing_paise')) {
      context.handle(
        _closingPaiseMeta,
        closingPaise.isAcceptableOrUnknown(
          data['closing_paise']!,
          _closingPaiseMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settlementId, workerId};
  @override
  SettlementItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettlementItem(
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      settlementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settlement_id'],
      )!,
      workerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}worker_id'],
      )!,
      unitsMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_milli'],
      )!,
      openingPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_paise'],
      )!,
      grossPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_paise'],
      )!,
      additionsPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}additions_paise'],
      )!,
      advancesPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}advances_paise'],
      )!,
      directPaidPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}direct_paid_paise'],
      )!,
      leaderPaidPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leader_paid_paise'],
      )!,
      closingPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closing_paise'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SettlementItemsTable createAlias(String alias) {
    return $SettlementItemsTable(attachedDatabase, alias);
  }
}

class SettlementItem extends DataClass implements Insertable<SettlementItem> {
  final int serverSeq;
  final int syncStatus;
  final String farmId;
  final String settlementId;
  final String workerId;
  final int unitsMilli;
  final int openingPaise;
  final int grossPaise;
  final int additionsPaise;
  final int advancesPaise;
  final int directPaidPaise;
  final int leaderPaidPaise;
  final int closingPaise;
  final DateTime updatedAt;
  const SettlementItem({
    required this.serverSeq,
    required this.syncStatus,
    required this.farmId,
    required this.settlementId,
    required this.workerId,
    required this.unitsMilli,
    required this.openingPaise,
    required this.grossPaise,
    required this.additionsPaise,
    required this.advancesPaise,
    required this.directPaidPaise,
    required this.leaderPaidPaise,
    required this.closingPaise,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['farm_id'] = Variable<String>(farmId);
    map['settlement_id'] = Variable<String>(settlementId);
    map['worker_id'] = Variable<String>(workerId);
    map['units_milli'] = Variable<int>(unitsMilli);
    map['opening_paise'] = Variable<int>(openingPaise);
    map['gross_paise'] = Variable<int>(grossPaise);
    map['additions_paise'] = Variable<int>(additionsPaise);
    map['advances_paise'] = Variable<int>(advancesPaise);
    map['direct_paid_paise'] = Variable<int>(directPaidPaise);
    map['leader_paid_paise'] = Variable<int>(leaderPaidPaise);
    map['closing_paise'] = Variable<int>(closingPaise);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettlementItemsCompanion toCompanion(bool nullToAbsent) {
    return SettlementItemsCompanion(
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      farmId: Value(farmId),
      settlementId: Value(settlementId),
      workerId: Value(workerId),
      unitsMilli: Value(unitsMilli),
      openingPaise: Value(openingPaise),
      grossPaise: Value(grossPaise),
      additionsPaise: Value(additionsPaise),
      advancesPaise: Value(advancesPaise),
      directPaidPaise: Value(directPaidPaise),
      leaderPaidPaise: Value(leaderPaidPaise),
      closingPaise: Value(closingPaise),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettlementItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettlementItem(
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      settlementId: serializer.fromJson<String>(json['settlement_id']),
      workerId: serializer.fromJson<String>(json['worker_id']),
      unitsMilli: serializer.fromJson<int>(json['units_milli']),
      openingPaise: serializer.fromJson<int>(json['opening_paise']),
      grossPaise: serializer.fromJson<int>(json['gross_paise']),
      additionsPaise: serializer.fromJson<int>(json['additions_paise']),
      advancesPaise: serializer.fromJson<int>(json['advances_paise']),
      directPaidPaise: serializer.fromJson<int>(json['direct_paid_paise']),
      leaderPaidPaise: serializer.fromJson<int>(json['leader_paid_paise']),
      closingPaise: serializer.fromJson<int>(json['closing_paise']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'farm_id': serializer.toJson<String>(farmId),
      'settlement_id': serializer.toJson<String>(settlementId),
      'worker_id': serializer.toJson<String>(workerId),
      'units_milli': serializer.toJson<int>(unitsMilli),
      'opening_paise': serializer.toJson<int>(openingPaise),
      'gross_paise': serializer.toJson<int>(grossPaise),
      'additions_paise': serializer.toJson<int>(additionsPaise),
      'advances_paise': serializer.toJson<int>(advancesPaise),
      'direct_paid_paise': serializer.toJson<int>(directPaidPaise),
      'leader_paid_paise': serializer.toJson<int>(leaderPaidPaise),
      'closing_paise': serializer.toJson<int>(closingPaise),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SettlementItem copyWith({
    int? serverSeq,
    int? syncStatus,
    String? farmId,
    String? settlementId,
    String? workerId,
    int? unitsMilli,
    int? openingPaise,
    int? grossPaise,
    int? additionsPaise,
    int? advancesPaise,
    int? directPaidPaise,
    int? leaderPaidPaise,
    int? closingPaise,
    DateTime? updatedAt,
  }) => SettlementItem(
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    farmId: farmId ?? this.farmId,
    settlementId: settlementId ?? this.settlementId,
    workerId: workerId ?? this.workerId,
    unitsMilli: unitsMilli ?? this.unitsMilli,
    openingPaise: openingPaise ?? this.openingPaise,
    grossPaise: grossPaise ?? this.grossPaise,
    additionsPaise: additionsPaise ?? this.additionsPaise,
    advancesPaise: advancesPaise ?? this.advancesPaise,
    directPaidPaise: directPaidPaise ?? this.directPaidPaise,
    leaderPaidPaise: leaderPaidPaise ?? this.leaderPaidPaise,
    closingPaise: closingPaise ?? this.closingPaise,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SettlementItem copyWithCompanion(SettlementItemsCompanion data) {
    return SettlementItem(
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      settlementId: data.settlementId.present
          ? data.settlementId.value
          : this.settlementId,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      unitsMilli: data.unitsMilli.present
          ? data.unitsMilli.value
          : this.unitsMilli,
      openingPaise: data.openingPaise.present
          ? data.openingPaise.value
          : this.openingPaise,
      grossPaise: data.grossPaise.present
          ? data.grossPaise.value
          : this.grossPaise,
      additionsPaise: data.additionsPaise.present
          ? data.additionsPaise.value
          : this.additionsPaise,
      advancesPaise: data.advancesPaise.present
          ? data.advancesPaise.value
          : this.advancesPaise,
      directPaidPaise: data.directPaidPaise.present
          ? data.directPaidPaise.value
          : this.directPaidPaise,
      leaderPaidPaise: data.leaderPaidPaise.present
          ? data.leaderPaidPaise.value
          : this.leaderPaidPaise,
      closingPaise: data.closingPaise.present
          ? data.closingPaise.value
          : this.closingPaise,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettlementItem(')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('farmId: $farmId, ')
          ..write('settlementId: $settlementId, ')
          ..write('workerId: $workerId, ')
          ..write('unitsMilli: $unitsMilli, ')
          ..write('openingPaise: $openingPaise, ')
          ..write('grossPaise: $grossPaise, ')
          ..write('additionsPaise: $additionsPaise, ')
          ..write('advancesPaise: $advancesPaise, ')
          ..write('directPaidPaise: $directPaidPaise, ')
          ..write('leaderPaidPaise: $leaderPaidPaise, ')
          ..write('closingPaise: $closingPaise, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverSeq,
    syncStatus,
    farmId,
    settlementId,
    workerId,
    unitsMilli,
    openingPaise,
    grossPaise,
    additionsPaise,
    advancesPaise,
    directPaidPaise,
    leaderPaidPaise,
    closingPaise,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettlementItem &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.farmId == this.farmId &&
          other.settlementId == this.settlementId &&
          other.workerId == this.workerId &&
          other.unitsMilli == this.unitsMilli &&
          other.openingPaise == this.openingPaise &&
          other.grossPaise == this.grossPaise &&
          other.additionsPaise == this.additionsPaise &&
          other.advancesPaise == this.advancesPaise &&
          other.directPaidPaise == this.directPaidPaise &&
          other.leaderPaidPaise == this.leaderPaidPaise &&
          other.closingPaise == this.closingPaise &&
          other.updatedAt == this.updatedAt);
}

class SettlementItemsCompanion extends UpdateCompanion<SettlementItem> {
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> farmId;
  final Value<String> settlementId;
  final Value<String> workerId;
  final Value<int> unitsMilli;
  final Value<int> openingPaise;
  final Value<int> grossPaise;
  final Value<int> additionsPaise;
  final Value<int> advancesPaise;
  final Value<int> directPaidPaise;
  final Value<int> leaderPaidPaise;
  final Value<int> closingPaise;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettlementItemsCompanion({
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.farmId = const Value.absent(),
    this.settlementId = const Value.absent(),
    this.workerId = const Value.absent(),
    this.unitsMilli = const Value.absent(),
    this.openingPaise = const Value.absent(),
    this.grossPaise = const Value.absent(),
    this.additionsPaise = const Value.absent(),
    this.advancesPaise = const Value.absent(),
    this.directPaidPaise = const Value.absent(),
    this.leaderPaidPaise = const Value.absent(),
    this.closingPaise = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettlementItemsCompanion.insert({
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String farmId,
    required String settlementId,
    required String workerId,
    this.unitsMilli = const Value.absent(),
    this.openingPaise = const Value.absent(),
    this.grossPaise = const Value.absent(),
    this.additionsPaise = const Value.absent(),
    this.advancesPaise = const Value.absent(),
    this.directPaidPaise = const Value.absent(),
    this.leaderPaidPaise = const Value.absent(),
    this.closingPaise = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : farmId = Value(farmId),
       settlementId = Value(settlementId),
       workerId = Value(workerId),
       updatedAt = Value(updatedAt);
  static Insertable<SettlementItem> custom({
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? farmId,
    Expression<String>? settlementId,
    Expression<String>? workerId,
    Expression<int>? unitsMilli,
    Expression<int>? openingPaise,
    Expression<int>? grossPaise,
    Expression<int>? additionsPaise,
    Expression<int>? advancesPaise,
    Expression<int>? directPaidPaise,
    Expression<int>? leaderPaidPaise,
    Expression<int>? closingPaise,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (farmId != null) 'farm_id': farmId,
      if (settlementId != null) 'settlement_id': settlementId,
      if (workerId != null) 'worker_id': workerId,
      if (unitsMilli != null) 'units_milli': unitsMilli,
      if (openingPaise != null) 'opening_paise': openingPaise,
      if (grossPaise != null) 'gross_paise': grossPaise,
      if (additionsPaise != null) 'additions_paise': additionsPaise,
      if (advancesPaise != null) 'advances_paise': advancesPaise,
      if (directPaidPaise != null) 'direct_paid_paise': directPaidPaise,
      if (leaderPaidPaise != null) 'leader_paid_paise': leaderPaidPaise,
      if (closingPaise != null) 'closing_paise': closingPaise,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettlementItemsCompanion copyWith({
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? farmId,
    Value<String>? settlementId,
    Value<String>? workerId,
    Value<int>? unitsMilli,
    Value<int>? openingPaise,
    Value<int>? grossPaise,
    Value<int>? additionsPaise,
    Value<int>? advancesPaise,
    Value<int>? directPaidPaise,
    Value<int>? leaderPaidPaise,
    Value<int>? closingPaise,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SettlementItemsCompanion(
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      farmId: farmId ?? this.farmId,
      settlementId: settlementId ?? this.settlementId,
      workerId: workerId ?? this.workerId,
      unitsMilli: unitsMilli ?? this.unitsMilli,
      openingPaise: openingPaise ?? this.openingPaise,
      grossPaise: grossPaise ?? this.grossPaise,
      additionsPaise: additionsPaise ?? this.additionsPaise,
      advancesPaise: advancesPaise ?? this.advancesPaise,
      directPaidPaise: directPaidPaise ?? this.directPaidPaise,
      leaderPaidPaise: leaderPaidPaise ?? this.leaderPaidPaise,
      closingPaise: closingPaise ?? this.closingPaise,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (settlementId.present) {
      map['settlement_id'] = Variable<String>(settlementId.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<String>(workerId.value);
    }
    if (unitsMilli.present) {
      map['units_milli'] = Variable<int>(unitsMilli.value);
    }
    if (openingPaise.present) {
      map['opening_paise'] = Variable<int>(openingPaise.value);
    }
    if (grossPaise.present) {
      map['gross_paise'] = Variable<int>(grossPaise.value);
    }
    if (additionsPaise.present) {
      map['additions_paise'] = Variable<int>(additionsPaise.value);
    }
    if (advancesPaise.present) {
      map['advances_paise'] = Variable<int>(advancesPaise.value);
    }
    if (directPaidPaise.present) {
      map['direct_paid_paise'] = Variable<int>(directPaidPaise.value);
    }
    if (leaderPaidPaise.present) {
      map['leader_paid_paise'] = Variable<int>(leaderPaidPaise.value);
    }
    if (closingPaise.present) {
      map['closing_paise'] = Variable<int>(closingPaise.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementItemsCompanion(')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('farmId: $farmId, ')
          ..write('settlementId: $settlementId, ')
          ..write('workerId: $workerId, ')
          ..write('unitsMilli: $unitsMilli, ')
          ..write('openingPaise: $openingPaise, ')
          ..write('grossPaise: $grossPaise, ')
          ..write('additionsPaise: $additionsPaise, ')
          ..write('advancesPaise: $advancesPaise, ')
          ..write('directPaidPaise: $directPaidPaise, ')
          ..write('leaderPaidPaise: $leaderPaidPaise, ')
          ..write('closingPaise: $closingPaise, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditEventsTable extends AuditEvents
    with TableInfo<$AuditEventsTable, AuditEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorNameMeta = const VerificationMeta(
    'actorName',
  );
  @override
  late final GeneratedColumn<String> actorName = GeneratedColumn<String>(
    'actor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beforeDataMeta = const VerificationMeta(
    'beforeData',
  );
  @override
  late final GeneratedColumn<String> beforeData = GeneratedColumn<String>(
    'before_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterDataMeta = const VerificationMeta(
    'afterData',
  );
  @override
  late final GeneratedColumn<String> afterData = GeneratedColumn<String>(
    'after_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceDeviceIdMeta = const VerificationMeta(
    'sourceDeviceId',
  );
  @override
  late final GeneratedColumn<String> sourceDeviceId = GeneratedColumn<String>(
    'source_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverSeq,
    syncStatus,
    id,
    farmId,
    action,
    entityType,
    entityId,
    actorId,
    actorName,
    beforeData,
    afterData,
    sourceDeviceId,
    opId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('actor_name')) {
      context.handle(
        _actorNameMeta,
        actorName.isAcceptableOrUnknown(data['actor_name']!, _actorNameMeta),
      );
    }
    if (data.containsKey('before_data')) {
      context.handle(
        _beforeDataMeta,
        beforeData.isAcceptableOrUnknown(data['before_data']!, _beforeDataMeta),
      );
    }
    if (data.containsKey('after_data')) {
      context.handle(
        _afterDataMeta,
        afterData.isAcceptableOrUnknown(data['after_data']!, _afterDataMeta),
      );
    }
    if (data.containsKey('source_device_id')) {
      context.handle(
        _sourceDeviceIdMeta,
        sourceDeviceId.isAcceptableOrUnknown(
          data['source_device_id']!,
          _sourceDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditEvent(
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      actorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_name'],
      ),
      beforeData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_data'],
      ),
      afterData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_data'],
      ),
      sourceDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device_id'],
      ),
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuditEventsTable createAlias(String alias) {
    return $AuditEventsTable(attachedDatabase, alias);
  }
}

class AuditEvent extends DataClass implements Insertable<AuditEvent> {
  final int serverSeq;
  final int syncStatus;
  final String id;
  final String farmId;
  final String action;
  final String entityType;
  final String? entityId;
  final String actorId;
  final String? actorName;
  final String? beforeData;
  final String? afterData;
  final String? sourceDeviceId;
  final String? opId;
  final DateTime createdAt;
  const AuditEvent({
    required this.serverSeq,
    required this.syncStatus,
    required this.id,
    required this.farmId,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.actorId,
    this.actorName,
    this.beforeData,
    this.afterData,
    this.sourceDeviceId,
    this.opId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_seq'] = Variable<int>(serverSeq);
    map['sync_status'] = Variable<int>(syncStatus);
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['actor_id'] = Variable<String>(actorId);
    if (!nullToAbsent || actorName != null) {
      map['actor_name'] = Variable<String>(actorName);
    }
    if (!nullToAbsent || beforeData != null) {
      map['before_data'] = Variable<String>(beforeData);
    }
    if (!nullToAbsent || afterData != null) {
      map['after_data'] = Variable<String>(afterData);
    }
    if (!nullToAbsent || sourceDeviceId != null) {
      map['source_device_id'] = Variable<String>(sourceDeviceId);
    }
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuditEventsCompanion toCompanion(bool nullToAbsent) {
    return AuditEventsCompanion(
      serverSeq: Value(serverSeq),
      syncStatus: Value(syncStatus),
      id: Value(id),
      farmId: Value(farmId),
      action: Value(action),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      actorId: Value(actorId),
      actorName: actorName == null && nullToAbsent
          ? const Value.absent()
          : Value(actorName),
      beforeData: beforeData == null && nullToAbsent
          ? const Value.absent()
          : Value(beforeData),
      afterData: afterData == null && nullToAbsent
          ? const Value.absent()
          : Value(afterData),
      sourceDeviceId: sourceDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDeviceId),
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      createdAt: Value(createdAt),
    );
  }

  factory AuditEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditEvent(
      serverSeq: serializer.fromJson<int>(json['server_seq']),
      syncStatus: serializer.fromJson<int>(json['sync_status']),
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entity_type']),
      entityId: serializer.fromJson<String?>(json['entity_id']),
      actorId: serializer.fromJson<String>(json['actor_id']),
      actorName: serializer.fromJson<String?>(json['actor_name']),
      beforeData: serializer.fromJson<String?>(json['before_data']),
      afterData: serializer.fromJson<String?>(json['after_data']),
      sourceDeviceId: serializer.fromJson<String?>(json['source_device_id']),
      opId: serializer.fromJson<String?>(json['op_id']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server_seq': serializer.toJson<int>(serverSeq),
      'sync_status': serializer.toJson<int>(syncStatus),
      'id': serializer.toJson<String>(id),
      'farm_id': serializer.toJson<String>(farmId),
      'action': serializer.toJson<String>(action),
      'entity_type': serializer.toJson<String>(entityType),
      'entity_id': serializer.toJson<String?>(entityId),
      'actor_id': serializer.toJson<String>(actorId),
      'actor_name': serializer.toJson<String?>(actorName),
      'before_data': serializer.toJson<String?>(beforeData),
      'after_data': serializer.toJson<String?>(afterData),
      'source_device_id': serializer.toJson<String?>(sourceDeviceId),
      'op_id': serializer.toJson<String?>(opId),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditEvent copyWith({
    int? serverSeq,
    int? syncStatus,
    String? id,
    String? farmId,
    String? action,
    String? entityType,
    Value<String?> entityId = const Value.absent(),
    String? actorId,
    Value<String?> actorName = const Value.absent(),
    Value<String?> beforeData = const Value.absent(),
    Value<String?> afterData = const Value.absent(),
    Value<String?> sourceDeviceId = const Value.absent(),
    Value<String?> opId = const Value.absent(),
    DateTime? createdAt,
  }) => AuditEvent(
    serverSeq: serverSeq ?? this.serverSeq,
    syncStatus: syncStatus ?? this.syncStatus,
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    action: action ?? this.action,
    entityType: entityType ?? this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    actorId: actorId ?? this.actorId,
    actorName: actorName.present ? actorName.value : this.actorName,
    beforeData: beforeData.present ? beforeData.value : this.beforeData,
    afterData: afterData.present ? afterData.value : this.afterData,
    sourceDeviceId: sourceDeviceId.present
        ? sourceDeviceId.value
        : this.sourceDeviceId,
    opId: opId.present ? opId.value : this.opId,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditEvent copyWithCompanion(AuditEventsCompanion data) {
    return AuditEvent(
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      action: data.action.present ? data.action.value : this.action,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      actorName: data.actorName.present ? data.actorName.value : this.actorName,
      beforeData: data.beforeData.present
          ? data.beforeData.value
          : this.beforeData,
      afterData: data.afterData.present ? data.afterData.value : this.afterData,
      sourceDeviceId: data.sourceDeviceId.present
          ? data.sourceDeviceId.value
          : this.sourceDeviceId,
      opId: data.opId.present ? data.opId.value : this.opId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditEvent(')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('actorId: $actorId, ')
          ..write('actorName: $actorName, ')
          ..write('beforeData: $beforeData, ')
          ..write('afterData: $afterData, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('opId: $opId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverSeq,
    syncStatus,
    id,
    farmId,
    action,
    entityType,
    entityId,
    actorId,
    actorName,
    beforeData,
    afterData,
    sourceDeviceId,
    opId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditEvent &&
          other.serverSeq == this.serverSeq &&
          other.syncStatus == this.syncStatus &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.actorId == this.actorId &&
          other.actorName == this.actorName &&
          other.beforeData == this.beforeData &&
          other.afterData == this.afterData &&
          other.sourceDeviceId == this.sourceDeviceId &&
          other.opId == this.opId &&
          other.createdAt == this.createdAt);
}

class AuditEventsCompanion extends UpdateCompanion<AuditEvent> {
  final Value<int> serverSeq;
  final Value<int> syncStatus;
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String?> entityId;
  final Value<String> actorId;
  final Value<String?> actorName;
  final Value<String?> beforeData;
  final Value<String?> afterData;
  final Value<String?> sourceDeviceId;
  final Value<String?> opId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AuditEventsCompanion({
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.actorName = const Value.absent(),
    this.beforeData = const Value.absent(),
    this.afterData = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.opId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditEventsCompanion.insert({
    this.serverSeq = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String id,
    required String farmId,
    required String action,
    required String entityType,
    this.entityId = const Value.absent(),
    required String actorId,
    this.actorName = const Value.absent(),
    this.beforeData = const Value.absent(),
    this.afterData = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.opId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       action = Value(action),
       entityType = Value(entityType),
       actorId = Value(actorId),
       createdAt = Value(createdAt);
  static Insertable<AuditEvent> custom({
    Expression<int>? serverSeq,
    Expression<int>? syncStatus,
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? actorId,
    Expression<String>? actorName,
    Expression<String>? beforeData,
    Expression<String>? afterData,
    Expression<String>? sourceDeviceId,
    Expression<String>? opId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverSeq != null) 'server_seq': serverSeq,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (actorId != null) 'actor_id': actorId,
      if (actorName != null) 'actor_name': actorName,
      if (beforeData != null) 'before_data': beforeData,
      if (afterData != null) 'after_data': afterData,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (opId != null) 'op_id': opId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditEventsCompanion copyWith({
    Value<int>? serverSeq,
    Value<int>? syncStatus,
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? action,
    Value<String>? entityType,
    Value<String?>? entityId,
    Value<String>? actorId,
    Value<String?>? actorName,
    Value<String?>? beforeData,
    Value<String?>? afterData,
    Value<String?>? sourceDeviceId,
    Value<String?>? opId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AuditEventsCompanion(
      serverSeq: serverSeq ?? this.serverSeq,
      syncStatus: syncStatus ?? this.syncStatus,
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      beforeData: beforeData ?? this.beforeData,
      afterData: afterData ?? this.afterData,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      opId: opId ?? this.opId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (actorName.present) {
      map['actor_name'] = Variable<String>(actorName.value);
    }
    if (beforeData.present) {
      map['before_data'] = Variable<String>(beforeData.value);
    }
    if (afterData.present) {
      map['after_data'] = Variable<String>(afterData.value);
    }
    if (sourceDeviceId.present) {
      map['source_device_id'] = Variable<String>(sourceDeviceId.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
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
    return (StringBuffer('AuditEventsCompanion(')
          ..write('serverSeq: $serverSeq, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('actorId: $actorId, ')
          ..write('actorName: $actorName, ')
          ..write('beforeData: $beforeData, ')
          ..write('afterData: $afterData, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('opId: $opId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxOpsTable extends OutboxOps
    with TableInfo<$OutboxOpsTable, OutboxOp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictDataMeta = const VerificationMeta(
    'conflictData',
  );
  @override
  late final GeneratedColumn<String> conflictData = GeneratedColumn<String>(
    'conflict_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    opId,
    farmId,
    actorId,
    deviceId,
    opType,
    entityTable,
    entityId,
    payload,
    status,
    attempts,
    nextAttemptAt,
    lastErrorCode,
    conflictData,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxOp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('conflict_data')) {
      context.handle(
        _conflictDataMeta,
        conflictData.isAcceptableOrUnknown(
          data['conflict_data']!,
          _conflictDataMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxOp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxOp(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      conflictData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_data'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $OutboxOpsTable createAlias(String alias) {
    return $OutboxOpsTable(attachedDatabase, alias);
  }
}

class OutboxOp extends DataClass implements Insertable<OutboxOp> {
  final int seq;
  final String opId;
  final String farmId;
  final String actorId;
  final String deviceId;
  final String opType;
  final String entityTable;
  final String entityId;
  final String payload;
  final String status;
  final int attempts;
  final DateTime? nextAttemptAt;
  final String? lastErrorCode;
  final String? conflictData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;
  const OutboxOp({
    required this.seq,
    required this.opId,
    required this.farmId,
    required this.actorId,
    required this.deviceId,
    required this.opType,
    required this.entityTable,
    required this.entityId,
    required this.payload,
    required this.status,
    required this.attempts,
    this.nextAttemptAt,
    this.lastErrorCode,
    this.conflictData,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['op_id'] = Variable<String>(opId);
    map['farm_id'] = Variable<String>(farmId);
    map['actor_id'] = Variable<String>(actorId);
    map['device_id'] = Variable<String>(deviceId);
    map['op_type'] = Variable<String>(opType);
    map['entity_table'] = Variable<String>(entityTable);
    map['entity_id'] = Variable<String>(entityId);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || conflictData != null) {
      map['conflict_data'] = Variable<String>(conflictData);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  OutboxOpsCompanion toCompanion(bool nullToAbsent) {
    return OutboxOpsCompanion(
      seq: Value(seq),
      opId: Value(opId),
      farmId: Value(farmId),
      actorId: Value(actorId),
      deviceId: Value(deviceId),
      opType: Value(opType),
      entityTable: Value(entityTable),
      entityId: Value(entityId),
      payload: Value(payload),
      status: Value(status),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      conflictData: conflictData == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictData),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory OutboxOp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxOp(
      seq: serializer.fromJson<int>(json['seq']),
      opId: serializer.fromJson<String>(json['op_id']),
      farmId: serializer.fromJson<String>(json['farm_id']),
      actorId: serializer.fromJson<String>(json['actor_id']),
      deviceId: serializer.fromJson<String>(json['device_id']),
      opType: serializer.fromJson<String>(json['op_type']),
      entityTable: serializer.fromJson<String>(json['entity_table']),
      entityId: serializer.fromJson<String>(json['entity_id']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['next_attempt_at']),
      lastErrorCode: serializer.fromJson<String?>(json['last_error_code']),
      conflictData: serializer.fromJson<String?>(json['conflict_data']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
      syncedAt: serializer.fromJson<DateTime?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'op_id': serializer.toJson<String>(opId),
      'farm_id': serializer.toJson<String>(farmId),
      'actor_id': serializer.toJson<String>(actorId),
      'device_id': serializer.toJson<String>(deviceId),
      'op_type': serializer.toJson<String>(opType),
      'entity_table': serializer.toJson<String>(entityTable),
      'entity_id': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'next_attempt_at': serializer.toJson<DateTime?>(nextAttemptAt),
      'last_error_code': serializer.toJson<String?>(lastErrorCode),
      'conflict_data': serializer.toJson<String?>(conflictData),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
      'synced_at': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  OutboxOp copyWith({
    int? seq,
    String? opId,
    String? farmId,
    String? actorId,
    String? deviceId,
    String? opType,
    String? entityTable,
    String? entityId,
    String? payload,
    String? status,
    int? attempts,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
    Value<String?> conflictData = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => OutboxOp(
    seq: seq ?? this.seq,
    opId: opId ?? this.opId,
    farmId: farmId ?? this.farmId,
    actorId: actorId ?? this.actorId,
    deviceId: deviceId ?? this.deviceId,
    opType: opType ?? this.opType,
    entityTable: entityTable ?? this.entityTable,
    entityId: entityId ?? this.entityId,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    conflictData: conflictData.present ? conflictData.value : this.conflictData,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  OutboxOp copyWithCompanion(OutboxOpsCompanion data) {
    return OutboxOp(
      seq: data.seq.present ? data.seq.value : this.seq,
      opId: data.opId.present ? data.opId.value : this.opId,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      opType: data.opType.present ? data.opType.value : this.opType,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      conflictData: data.conflictData.present
          ? data.conflictData.value
          : this.conflictData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOp(')
          ..write('seq: $seq, ')
          ..write('opId: $opId, ')
          ..write('farmId: $farmId, ')
          ..write('actorId: $actorId, ')
          ..write('deviceId: $deviceId, ')
          ..write('opType: $opType, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('conflictData: $conflictData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    opId,
    farmId,
    actorId,
    deviceId,
    opType,
    entityTable,
    entityId,
    payload,
    status,
    attempts,
    nextAttemptAt,
    lastErrorCode,
    conflictData,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxOp &&
          other.seq == this.seq &&
          other.opId == this.opId &&
          other.farmId == this.farmId &&
          other.actorId == this.actorId &&
          other.deviceId == this.deviceId &&
          other.opType == this.opType &&
          other.entityTable == this.entityTable &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastErrorCode == this.lastErrorCode &&
          other.conflictData == this.conflictData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class OutboxOpsCompanion extends UpdateCompanion<OutboxOp> {
  final Value<int> seq;
  final Value<String> opId;
  final Value<String> farmId;
  final Value<String> actorId;
  final Value<String> deviceId;
  final Value<String> opType;
  final Value<String> entityTable;
  final Value<String> entityId;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> attempts;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastErrorCode;
  final Value<String?> conflictData;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> syncedAt;
  const OutboxOpsCompanion({
    this.seq = const Value.absent(),
    this.opId = const Value.absent(),
    this.farmId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.opType = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.conflictData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  OutboxOpsCompanion.insert({
    this.seq = const Value.absent(),
    required String opId,
    required String farmId,
    required String actorId,
    required String deviceId,
    required String opType,
    required String entityTable,
    required String entityId,
    required String payload,
    required String status,
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.conflictData = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncedAt = const Value.absent(),
  }) : opId = Value(opId),
       farmId = Value(farmId),
       actorId = Value(actorId),
       deviceId = Value(deviceId),
       opType = Value(opType),
       entityTable = Value(entityTable),
       entityId = Value(entityId),
       payload = Value(payload),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OutboxOp> custom({
    Expression<int>? seq,
    Expression<String>? opId,
    Expression<String>? farmId,
    Expression<String>? actorId,
    Expression<String>? deviceId,
    Expression<String>? opType,
    Expression<String>? entityTable,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastErrorCode,
    Expression<String>? conflictData,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (opId != null) 'op_id': opId,
      if (farmId != null) 'farm_id': farmId,
      if (actorId != null) 'actor_id': actorId,
      if (deviceId != null) 'device_id': deviceId,
      if (opType != null) 'op_type': opType,
      if (entityTable != null) 'entity_table': entityTable,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (conflictData != null) 'conflict_data': conflictData,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  OutboxOpsCompanion copyWith({
    Value<int>? seq,
    Value<String>? opId,
    Value<String>? farmId,
    Value<String>? actorId,
    Value<String>? deviceId,
    Value<String>? opType,
    Value<String>? entityTable,
    Value<String>? entityId,
    Value<String>? payload,
    Value<String>? status,
    Value<int>? attempts,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastErrorCode,
    Value<String?>? conflictData,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? syncedAt,
  }) {
    return OutboxOpsCompanion(
      seq: seq ?? this.seq,
      opId: opId ?? this.opId,
      farmId: farmId ?? this.farmId,
      actorId: actorId ?? this.actorId,
      deviceId: deviceId ?? this.deviceId,
      opType: opType ?? this.opType,
      entityTable: entityTable ?? this.entityTable,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      conflictData: conflictData ?? this.conflictData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (conflictData.present) {
      map['conflict_data'] = Variable<String>(conflictData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOpsCompanion(')
          ..write('seq: $seq, ')
          ..write('opId: $opId, ')
          ..write('farmId: $farmId, ')
          ..write('actorId: $actorId, ')
          ..write('deviceId: $deviceId, ')
          ..write('opType: $opType, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('conflictData: $conflictData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $ServerShadowsTable extends ServerShadows
    with TableInfo<$ServerShadowsTable, ServerShadow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServerShadowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tblMeta = const VerificationMeta('tbl');
  @override
  late final GeneratedColumn<String> tbl = GeneratedColumn<String>(
    'tbl',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowKeyMeta = const VerificationMeta('rowKey');
  @override
  late final GeneratedColumn<String> rowKey = GeneratedColumn<String>(
    'row_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tbl, rowKey, data, serverSeq];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'server_shadows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerShadow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tbl')) {
      context.handle(
        _tblMeta,
        tbl.isAcceptableOrUnknown(data['tbl']!, _tblMeta),
      );
    } else if (isInserting) {
      context.missing(_tblMeta);
    }
    if (data.containsKey('row_key')) {
      context.handle(
        _rowKeyMeta,
        rowKey.isAcceptableOrUnknown(data['row_key']!, _rowKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_rowKeyMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    } else if (isInserting) {
      context.missing(_serverSeqMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tbl, rowKey};
  @override
  ServerShadow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerShadow(
      tbl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tbl'],
      )!,
      rowKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_key'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
    );
  }

  @override
  $ServerShadowsTable createAlias(String alias) {
    return $ServerShadowsTable(attachedDatabase, alias);
  }
}

class ServerShadow extends DataClass implements Insertable<ServerShadow> {
  final String tbl;
  final String rowKey;
  final String data;
  final int serverSeq;
  const ServerShadow({
    required this.tbl,
    required this.rowKey,
    required this.data,
    required this.serverSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tbl'] = Variable<String>(tbl);
    map['row_key'] = Variable<String>(rowKey);
    map['data'] = Variable<String>(data);
    map['server_seq'] = Variable<int>(serverSeq);
    return map;
  }

  ServerShadowsCompanion toCompanion(bool nullToAbsent) {
    return ServerShadowsCompanion(
      tbl: Value(tbl),
      rowKey: Value(rowKey),
      data: Value(data),
      serverSeq: Value(serverSeq),
    );
  }

  factory ServerShadow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerShadow(
      tbl: serializer.fromJson<String>(json['tbl']),
      rowKey: serializer.fromJson<String>(json['row_key']),
      data: serializer.fromJson<String>(json['data']),
      serverSeq: serializer.fromJson<int>(json['server_seq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tbl': serializer.toJson<String>(tbl),
      'row_key': serializer.toJson<String>(rowKey),
      'data': serializer.toJson<String>(data),
      'server_seq': serializer.toJson<int>(serverSeq),
    };
  }

  ServerShadow copyWith({
    String? tbl,
    String? rowKey,
    String? data,
    int? serverSeq,
  }) => ServerShadow(
    tbl: tbl ?? this.tbl,
    rowKey: rowKey ?? this.rowKey,
    data: data ?? this.data,
    serverSeq: serverSeq ?? this.serverSeq,
  );
  ServerShadow copyWithCompanion(ServerShadowsCompanion data) {
    return ServerShadow(
      tbl: data.tbl.present ? data.tbl.value : this.tbl,
      rowKey: data.rowKey.present ? data.rowKey.value : this.rowKey,
      data: data.data.present ? data.data.value : this.data,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerShadow(')
          ..write('tbl: $tbl, ')
          ..write('rowKey: $rowKey, ')
          ..write('data: $data, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tbl, rowKey, data, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerShadow &&
          other.tbl == this.tbl &&
          other.rowKey == this.rowKey &&
          other.data == this.data &&
          other.serverSeq == this.serverSeq);
}

class ServerShadowsCompanion extends UpdateCompanion<ServerShadow> {
  final Value<String> tbl;
  final Value<String> rowKey;
  final Value<String> data;
  final Value<int> serverSeq;
  final Value<int> rowid;
  const ServerShadowsCompanion({
    this.tbl = const Value.absent(),
    this.rowKey = const Value.absent(),
    this.data = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServerShadowsCompanion.insert({
    required String tbl,
    required String rowKey,
    required String data,
    required int serverSeq,
    this.rowid = const Value.absent(),
  }) : tbl = Value(tbl),
       rowKey = Value(rowKey),
       data = Value(data),
       serverSeq = Value(serverSeq);
  static Insertable<ServerShadow> custom({
    Expression<String>? tbl,
    Expression<String>? rowKey,
    Expression<String>? data,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tbl != null) 'tbl': tbl,
      if (rowKey != null) 'row_key': rowKey,
      if (data != null) 'data': data,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServerShadowsCompanion copyWith({
    Value<String>? tbl,
    Value<String>? rowKey,
    Value<String>? data,
    Value<int>? serverSeq,
    Value<int>? rowid,
  }) {
    return ServerShadowsCompanion(
      tbl: tbl ?? this.tbl,
      rowKey: rowKey ?? this.rowKey,
      data: data ?? this.data,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tbl.present) {
      map['tbl'] = Variable<String>(tbl.value);
    }
    if (rowKey.present) {
      map['row_key'] = Variable<String>(rowKey.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerShadowsCompanion(')
          ..write('tbl: $tbl, ')
          ..write('rowKey: $rowKey, ')
          ..write('data: $data, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KvEntriesTable extends KvEntries
    with TableInfo<$KvEntriesTable, KvEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KvEntriesTable createAlias(String alias) {
    return $KvEntriesTable(attachedDatabase, alias);
  }
}

class KvEntry extends DataClass implements Insertable<KvEntry> {
  final String key;
  final String value;
  const KvEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KvEntriesCompanion toCompanion(bool nullToAbsent) {
    return KvEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory KvEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KvEntry copyWith({String? key, String? value}) =>
      KvEntry(key: key ?? this.key, value: value ?? this.value);
  KvEntry copyWithCompanion(KvEntriesCompanion data) {
    return KvEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvEntry && other.key == this.key && other.value == this.value);
}

class KvEntriesCompanion extends UpdateCompanion<KvEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KvEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KvEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KvEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $FarmsTable farms = $FarmsTable(this);
  late final $FarmMembersTable farmMembers = $FarmMembersTable(this);
  late final $WorkersTable workers = $WorkersTable(this);
  late final $WorkerGroupsTable workerGroups = $WorkerGroupsTable(this);
  late final $WorkerGroupMembershipsTable workerGroupMemberships =
      $WorkerGroupMembershipsTable(this);
  late final $AttendanceTable attendance = $AttendanceTable(this);
  late final $WorkTypesTable workTypes = $WorkTypesTable(this);
  late final $WorkAssignmentsTable workAssignments = $WorkAssignmentsTable(
    this,
  );
  late final $WorkAssignmentWorkersTable workAssignmentWorkers =
      $WorkAssignmentWorkersTable(this);
  late final $FinancialTransactionsTable financialTransactions =
      $FinancialTransactionsTable(this);
  late final $SettlementsTable settlements = $SettlementsTable(this);
  late final $SettlementItemsTable settlementItems = $SettlementItemsTable(
    this,
  );
  late final $AuditEventsTable auditEvents = $AuditEventsTable(this);
  late final $OutboxOpsTable outboxOps = $OutboxOpsTable(this);
  late final $ServerShadowsTable serverShadows = $ServerShadowsTable(this);
  late final $KvEntriesTable kvEntries = $KvEntriesTable(this);
  late final Index workersFarmStatusIdx = Index(
    'workers_farm_status_idx',
    'CREATE INDEX workers_farm_status_idx ON workers (farm_id, status)',
  );
  late final Index wgmWorkerIdx = Index(
    'wgm_worker_idx',
    'CREATE INDEX wgm_worker_idx ON worker_group_memberships (worker_id)',
  );
  late final Index attendanceDateIdx = Index(
    'attendance_date_idx',
    'CREATE INDEX attendance_date_idx ON attendance (farm_id, work_date)',
  );
  late final Index attendanceWorkerIdx = Index(
    'attendance_worker_idx',
    'CREATE INDEX attendance_worker_idx ON attendance (worker_id, work_date)',
  );
  late final Index workAssignmentsDateIdx = Index(
    'work_assignments_date_idx',
    'CREATE INDEX work_assignments_date_idx ON work_assignments (farm_id, work_date)',
  );
  late final Index wawWorkerIdx = Index(
    'waw_worker_idx',
    'CREATE INDEX waw_worker_idx ON work_assignment_workers (worker_id)',
  );
  late final Index ftWorkerDateIdx = Index(
    'ft_worker_date_idx',
    'CREATE INDEX ft_worker_date_idx ON financial_transactions (farm_id, worker_id, business_date)',
  );
  late final Index ftDateIdx = Index(
    'ft_date_idx',
    'CREATE INDEX ft_date_idx ON financial_transactions (farm_id, business_date)',
  );
  late final Index ftLeaderIdx = Index(
    'ft_leader_idx',
    'CREATE INDEX ft_leader_idx ON financial_transactions (leader_worker_id)',
  );
  late final Index ftReversesIdx = Index(
    'ft_reverses_idx',
    'CREATE INDEX ft_reverses_idx ON financial_transactions (reverses_id)',
  );
  late final Index auditEntityIdx = Index(
    'audit_entity_idx',
    'CREATE INDEX audit_entity_idx ON audit_events (entity_id)',
  );
  late final Index outboxStatusIdx = Index(
    'outbox_status_idx',
    'CREATE INDEX outbox_status_idx ON outbox_ops (status, seq)',
  );
  late final Index outboxEntityIdx = Index(
    'outbox_entity_idx',
    'CREATE INDEX outbox_entity_idx ON outbox_ops (entity_table, entity_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    farms,
    farmMembers,
    workers,
    workerGroups,
    workerGroupMemberships,
    attendance,
    workTypes,
    workAssignments,
    workAssignmentWorkers,
    financialTransactions,
    settlements,
    settlementItems,
    auditEvents,
    outboxOps,
    serverShadows,
    kvEntries,
    workersFarmStatusIdx,
    wgmWorkerIdx,
    attendanceDateIdx,
    attendanceWorkerIdx,
    workAssignmentsDateIdx,
    wawWorkerIdx,
    ftWorkerDateIdx,
    ftDateIdx,
    ftLeaderIdx,
    ftReversesIdx,
    auditEntityIdx,
    outboxStatusIdx,
    outboxEntityIdx,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
