// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DeviceItemsTable extends DeviceItems
    with TableInfo<$DeviceItemsTable, DeviceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _infoMeta = const VerificationMeta('info');
  @override
  late final GeneratedColumn<String> info = GeneratedColumn<String>(
    'info',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 400,
    ),
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, info, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('info')) {
      context.handle(
        _infoMeta,
        info.isAcceptableOrUnknown(data['info']!, _infoMeta),
      );
    } else if (isInserting) {
      context.missing(_infoMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      info: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}info'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $DeviceItemsTable createAlias(String alias) {
    return $DeviceItemsTable(attachedDatabase, alias);
  }
}

class DeviceItem extends DataClass implements Insertable<DeviceItem> {
  final int id;
  final String name;
  final String info;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const DeviceItem({
    required this.id,
    required this.name,
    required this.info,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['info'] = Variable<String>(info);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  DeviceItemsCompanion toCompanion(bool nullToAbsent) {
    return DeviceItemsCompanion(
      id: Value(id),
      name: Value(name),
      info: Value(info),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DeviceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      info: serializer.fromJson<String>(json['info']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'info': serializer.toJson<String>(info),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  DeviceItem copyWith({
    int? id,
    String? name,
    String? info,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => DeviceItem(
    id: id ?? this.id,
    name: name ?? this.name,
    info: info ?? this.info,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DeviceItem copyWithCompanion(DeviceItemsCompanion data) {
    return DeviceItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      info: data.info.present ? data.info.value : this.info,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('info: $info, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, info, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.info == this.info &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DeviceItemsCompanion extends UpdateCompanion<DeviceItem> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> info;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  const DeviceItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.info = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DeviceItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String info,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       info = Value(info);
  static Insertable<DeviceItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? info,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (info != null) 'info': info,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DeviceItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? info,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return DeviceItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      info: info ?? this.info,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (info.present) {
      map['info'] = Variable<String>(info.value);
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
    return (StringBuffer('DeviceItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('info: $info, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SettingItemsTable extends SettingItems
    with TableInfo<$SettingItemsTable, SettingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, state];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
    );
  }

  @override
  $SettingItemsTable createAlias(String alias) {
    return $SettingItemsTable(attachedDatabase, alias);
  }
}

class SettingItem extends DataClass implements Insertable<SettingItem> {
  final int id;
  final String name;
  final String state;
  const SettingItem({
    required this.id,
    required this.name,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['state'] = Variable<String>(state);
    return map;
  }

  SettingItemsCompanion toCompanion(bool nullToAbsent) {
    return SettingItemsCompanion(
      id: Value(id),
      name: Value(name),
      state: Value(state),
    );
  }

  factory SettingItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'state': serializer.toJson<String>(state),
    };
  }

  SettingItem copyWith({int? id, String? name, String? state}) => SettingItem(
    id: id ?? this.id,
    name: name ?? this.name,
    state: state ?? this.state,
  );
  SettingItem copyWithCompanion(SettingItemsCompanion data) {
    return SettingItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.state == this.state);
}

class SettingItemsCompanion extends UpdateCompanion<SettingItem> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> state;
  const SettingItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.state = const Value.absent(),
  });
  SettingItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String state,
  }) : name = Value(name),
       state = Value(state);
  static Insertable<SettingItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? state,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (state != null) 'state': state,
    });
  }

  SettingItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? state,
  }) {
    return SettingItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
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
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDataBase extends GeneratedDatabase {
  _$AppDataBase(QueryExecutor e) : super(e);
  $AppDataBaseManager get managers => $AppDataBaseManager(this);
  late final $DeviceItemsTable deviceItems = $DeviceItemsTable(this);
  late final $SettingItemsTable settingItems = $SettingItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    deviceItems,
    settingItems,
  ];
}

typedef $$DeviceItemsTableCreateCompanionBuilder =
    DeviceItemsCompanion Function({
      Value<int> id,
      required String name,
      required String info,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$DeviceItemsTableUpdateCompanionBuilder =
    DeviceItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> info,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
    });

class $$DeviceItemsTableFilterComposer
    extends Composer<_$AppDataBase, $DeviceItemsTable> {
  $$DeviceItemsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get info => $composableBuilder(
    column: $table.info,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceItemsTableOrderingComposer
    extends Composer<_$AppDataBase, $DeviceItemsTable> {
  $$DeviceItemsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get info => $composableBuilder(
    column: $table.info,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceItemsTableAnnotationComposer
    extends Composer<_$AppDataBase, $DeviceItemsTable> {
  $$DeviceItemsTableAnnotationComposer({
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

  GeneratedColumn<String> get info =>
      $composableBuilder(column: $table.info, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DeviceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $DeviceItemsTable,
          DeviceItem,
          $$DeviceItemsTableFilterComposer,
          $$DeviceItemsTableOrderingComposer,
          $$DeviceItemsTableAnnotationComposer,
          $$DeviceItemsTableCreateCompanionBuilder,
          $$DeviceItemsTableUpdateCompanionBuilder,
          (
            DeviceItem,
            BaseReferences<_$AppDataBase, $DeviceItemsTable, DeviceItem>,
          ),
          DeviceItem,
          PrefetchHooks Function()
        > {
  $$DeviceItemsTableTableManager(_$AppDataBase db, $DeviceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> info = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => DeviceItemsCompanion(
                id: id,
                name: name,
                info: info,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String info,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => DeviceItemsCompanion.insert(
                id: id,
                name: name,
                info: info,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $DeviceItemsTable,
      DeviceItem,
      $$DeviceItemsTableFilterComposer,
      $$DeviceItemsTableOrderingComposer,
      $$DeviceItemsTableAnnotationComposer,
      $$DeviceItemsTableCreateCompanionBuilder,
      $$DeviceItemsTableUpdateCompanionBuilder,
      (
        DeviceItem,
        BaseReferences<_$AppDataBase, $DeviceItemsTable, DeviceItem>,
      ),
      DeviceItem,
      PrefetchHooks Function()
    >;
typedef $$SettingItemsTableCreateCompanionBuilder =
    SettingItemsCompanion Function({
      Value<int> id,
      required String name,
      required String state,
    });
typedef $$SettingItemsTableUpdateCompanionBuilder =
    SettingItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> state,
    });

class $$SettingItemsTableFilterComposer
    extends Composer<_$AppDataBase, $SettingItemsTable> {
  $$SettingItemsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingItemsTableOrderingComposer
    extends Composer<_$AppDataBase, $SettingItemsTable> {
  $$SettingItemsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingItemsTableAnnotationComposer
    extends Composer<_$AppDataBase, $SettingItemsTable> {
  $$SettingItemsTableAnnotationComposer({
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

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);
}

class $$SettingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $SettingItemsTable,
          SettingItem,
          $$SettingItemsTableFilterComposer,
          $$SettingItemsTableOrderingComposer,
          $$SettingItemsTableAnnotationComposer,
          $$SettingItemsTableCreateCompanionBuilder,
          $$SettingItemsTableUpdateCompanionBuilder,
          (
            SettingItem,
            BaseReferences<_$AppDataBase, $SettingItemsTable, SettingItem>,
          ),
          SettingItem,
          PrefetchHooks Function()
        > {
  $$SettingItemsTableTableManager(_$AppDataBase db, $SettingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> state = const Value.absent(),
              }) => SettingItemsCompanion(id: id, name: name, state: state),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String state,
              }) => SettingItemsCompanion.insert(
                id: id,
                name: name,
                state: state,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $SettingItemsTable,
      SettingItem,
      $$SettingItemsTableFilterComposer,
      $$SettingItemsTableOrderingComposer,
      $$SettingItemsTableAnnotationComposer,
      $$SettingItemsTableCreateCompanionBuilder,
      $$SettingItemsTableUpdateCompanionBuilder,
      (
        SettingItem,
        BaseReferences<_$AppDataBase, $SettingItemsTable, SettingItem>,
      ),
      SettingItem,
      PrefetchHooks Function()
    >;

class $AppDataBaseManager {
  final _$AppDataBase _db;
  $AppDataBaseManager(this._db);
  $$DeviceItemsTableTableManager get deviceItems =>
      $$DeviceItemsTableTableManager(_db, _db.deviceItems);
  $$SettingItemsTableTableManager get settingItems =>
      $$SettingItemsTableTableManager(_db, _db.settingItems);
}
