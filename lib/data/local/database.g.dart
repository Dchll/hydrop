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
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DeviceConnectionStatus, String>
  connectionStatus =
      GeneratedColumn<String>(
        'connection_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => DeviceConnectionStatus.disconnected.name,
      ).withConverter<DeviceConnectionStatus>(
        $DeviceItemsTable.$converterconnectionStatus,
      );
  static const VerificationMeta _averageTransferSpeedBytesPerSecondMeta =
      const VerificationMeta('averageTransferSpeedBytesPerSecond');
  @override
  late final GeneratedColumn<int> averageTransferSpeedBytesPerSecond =
      GeneratedColumn<int>(
        'average_transfer_speed_bytes_per_second',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        clientDefault: () => 0,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    deviceId,
    connectionStatus,
    averageTransferSpeedBytesPerSecond,
  ];
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
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('average_transfer_speed_bytes_per_second')) {
      context.handle(
        _averageTransferSpeedBytesPerSecondMeta,
        averageTransferSpeedBytesPerSecond.isAcceptableOrUnknown(
          data['average_transfer_speed_bytes_per_second']!,
          _averageTransferSpeedBytesPerSecondMeta,
        ),
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
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      connectionStatus: $DeviceItemsTable.$converterconnectionStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}connection_status'],
        )!,
      ),
      averageTransferSpeedBytesPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}average_transfer_speed_bytes_per_second'],
      )!,
    );
  }

  @override
  $DeviceItemsTable createAlias(String alias) {
    return $DeviceItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DeviceConnectionStatus, String, String>
  $converterconnectionStatus = const EnumNameConverter<DeviceConnectionStatus>(
    DeviceConnectionStatus.values,
  );
}

class DeviceItem extends DataClass implements Insertable<DeviceItem> {
  final int id;
  final String displayName;
  final String deviceId;
  final DeviceConnectionStatus connectionStatus;
  final int averageTransferSpeedBytesPerSecond;
  const DeviceItem({
    required this.id,
    required this.displayName,
    required this.deviceId,
    required this.connectionStatus,
    required this.averageTransferSpeedBytesPerSecond,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['device_id'] = Variable<String>(deviceId);
    {
      map['connection_status'] = Variable<String>(
        $DeviceItemsTable.$converterconnectionStatus.toSql(connectionStatus),
      );
    }
    map['average_transfer_speed_bytes_per_second'] = Variable<int>(
      averageTransferSpeedBytesPerSecond,
    );
    return map;
  }

  DeviceItemsCompanion toCompanion(bool nullToAbsent) {
    return DeviceItemsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      deviceId: Value(deviceId),
      connectionStatus: Value(connectionStatus),
      averageTransferSpeedBytesPerSecond: Value(
        averageTransferSpeedBytesPerSecond,
      ),
    );
  }

  factory DeviceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceItem(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      connectionStatus: $DeviceItemsTable.$converterconnectionStatus.fromJson(
        serializer.fromJson<String>(json['connectionStatus']),
      ),
      averageTransferSpeedBytesPerSecond: serializer.fromJson<int>(
        json['averageTransferSpeedBytesPerSecond'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'deviceId': serializer.toJson<String>(deviceId),
      'connectionStatus': serializer.toJson<String>(
        $DeviceItemsTable.$converterconnectionStatus.toJson(connectionStatus),
      ),
      'averageTransferSpeedBytesPerSecond': serializer.toJson<int>(
        averageTransferSpeedBytesPerSecond,
      ),
    };
  }

  DeviceItem copyWith({
    int? id,
    String? displayName,
    String? deviceId,
    DeviceConnectionStatus? connectionStatus,
    int? averageTransferSpeedBytesPerSecond,
  }) => DeviceItem(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    deviceId: deviceId ?? this.deviceId,
    connectionStatus: connectionStatus ?? this.connectionStatus,
    averageTransferSpeedBytesPerSecond:
        averageTransferSpeedBytesPerSecond ??
        this.averageTransferSpeedBytesPerSecond,
  );
  DeviceItem copyWithCompanion(DeviceItemsCompanion data) {
    return DeviceItem(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      connectionStatus: data.connectionStatus.present
          ? data.connectionStatus.value
          : this.connectionStatus,
      averageTransferSpeedBytesPerSecond:
          data.averageTransferSpeedBytesPerSecond.present
          ? data.averageTransferSpeedBytesPerSecond.value
          : this.averageTransferSpeedBytesPerSecond,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceItem(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('deviceId: $deviceId, ')
          ..write('connectionStatus: $connectionStatus, ')
          ..write(
            'averageTransferSpeedBytesPerSecond: $averageTransferSpeedBytesPerSecond',
          )
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    deviceId,
    connectionStatus,
    averageTransferSpeedBytesPerSecond,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceItem &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.deviceId == this.deviceId &&
          other.connectionStatus == this.connectionStatus &&
          other.averageTransferSpeedBytesPerSecond ==
              this.averageTransferSpeedBytesPerSecond);
}

class DeviceItemsCompanion extends UpdateCompanion<DeviceItem> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<String> deviceId;
  final Value<DeviceConnectionStatus> connectionStatus;
  final Value<int> averageTransferSpeedBytesPerSecond;
  const DeviceItemsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.connectionStatus = const Value.absent(),
    this.averageTransferSpeedBytesPerSecond = const Value.absent(),
  });
  DeviceItemsCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    required String deviceId,
    this.connectionStatus = const Value.absent(),
    this.averageTransferSpeedBytesPerSecond = const Value.absent(),
  }) : displayName = Value(displayName),
       deviceId = Value(deviceId);
  static Insertable<DeviceItem> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<String>? deviceId,
    Expression<String>? connectionStatus,
    Expression<int>? averageTransferSpeedBytesPerSecond,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (deviceId != null) 'device_id': deviceId,
      if (connectionStatus != null) 'connection_status': connectionStatus,
      if (averageTransferSpeedBytesPerSecond != null)
        'average_transfer_speed_bytes_per_second':
            averageTransferSpeedBytesPerSecond,
    });
  }

  DeviceItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<String>? deviceId,
    Value<DeviceConnectionStatus>? connectionStatus,
    Value<int>? averageTransferSpeedBytesPerSecond,
  }) {
    return DeviceItemsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      deviceId: deviceId ?? this.deviceId,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      averageTransferSpeedBytesPerSecond:
          averageTransferSpeedBytesPerSecond ??
          this.averageTransferSpeedBytesPerSecond,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (connectionStatus.present) {
      map['connection_status'] = Variable<String>(
        $DeviceItemsTable.$converterconnectionStatus.toSql(
          connectionStatus.value,
        ),
      );
    }
    if (averageTransferSpeedBytesPerSecond.present) {
      map['average_transfer_speed_bytes_per_second'] = Variable<int>(
        averageTransferSpeedBytesPerSecond.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceItemsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('deviceId: $deviceId, ')
          ..write('connectionStatus: $connectionStatus, ')
          ..write(
            'averageTransferSpeedBytesPerSecond: $averageTransferSpeedBytesPerSecond',
          )
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
  @override
  late final GeneratedColumnWithTypeConverter<AppThemeMode, String> themeMode =
      GeneratedColumn<String>(
        'theme_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => AppThemeMode.system.name,
      ).withConverter<AppThemeMode>($SettingItemsTable.$converterthemeMode);
  static const VerificationMeta _transferEncryptionEnabledMeta =
      const VerificationMeta('transferEncryptionEnabled');
  @override
  late final GeneratedColumn<bool> transferEncryptionEnabled =
      GeneratedColumn<bool>(
        'transfer_encryption_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("transfer_encryption_enabled" IN (0, 1))',
        ),
        clientDefault: () => false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    transferEncryptionEnabled,
  ];
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
    if (data.containsKey('transfer_encryption_enabled')) {
      context.handle(
        _transferEncryptionEnabledMeta,
        transferEncryptionEnabled.isAcceptableOrUnknown(
          data['transfer_encryption_enabled']!,
          _transferEncryptionEnabledMeta,
        ),
      );
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
      themeMode: $SettingItemsTable.$converterthemeMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme_mode'],
        )!,
      ),
      transferEncryptionEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}transfer_encryption_enabled'],
      )!,
    );
  }

  @override
  $SettingItemsTable createAlias(String alias) {
    return $SettingItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AppThemeMode, String, String> $converterthemeMode =
      const EnumNameConverter<AppThemeMode>(AppThemeMode.values);
}

class SettingItem extends DataClass implements Insertable<SettingItem> {
  final int id;
  final AppThemeMode themeMode;
  final bool transferEncryptionEnabled;
  const SettingItem({
    required this.id,
    required this.themeMode,
    required this.transferEncryptionEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['theme_mode'] = Variable<String>(
        $SettingItemsTable.$converterthemeMode.toSql(themeMode),
      );
    }
    map['transfer_encryption_enabled'] = Variable<bool>(
      transferEncryptionEnabled,
    );
    return map;
  }

  SettingItemsCompanion toCompanion(bool nullToAbsent) {
    return SettingItemsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      transferEncryptionEnabled: Value(transferEncryptionEnabled),
    );
  }

  factory SettingItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingItem(
      id: serializer.fromJson<int>(json['id']),
      themeMode: $SettingItemsTable.$converterthemeMode.fromJson(
        serializer.fromJson<String>(json['themeMode']),
      ),
      transferEncryptionEnabled: serializer.fromJson<bool>(
        json['transferEncryptionEnabled'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(
        $SettingItemsTable.$converterthemeMode.toJson(themeMode),
      ),
      'transferEncryptionEnabled': serializer.toJson<bool>(
        transferEncryptionEnabled,
      ),
    };
  }

  SettingItem copyWith({
    int? id,
    AppThemeMode? themeMode,
    bool? transferEncryptionEnabled,
  }) => SettingItem(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    transferEncryptionEnabled:
        transferEncryptionEnabled ?? this.transferEncryptionEnabled,
  );
  SettingItem copyWithCompanion(SettingItemsCompanion data) {
    return SettingItem(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      transferEncryptionEnabled: data.transferEncryptionEnabled.present
          ? data.transferEncryptionEnabled.value
          : this.transferEncryptionEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingItem(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('transferEncryptionEnabled: $transferEncryptionEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, themeMode, transferEncryptionEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingItem &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.transferEncryptionEnabled == this.transferEncryptionEnabled);
}

class SettingItemsCompanion extends UpdateCompanion<SettingItem> {
  final Value<int> id;
  final Value<AppThemeMode> themeMode;
  final Value<bool> transferEncryptionEnabled;
  const SettingItemsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.transferEncryptionEnabled = const Value.absent(),
  });
  SettingItemsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.transferEncryptionEnabled = const Value.absent(),
  });
  static Insertable<SettingItem> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<bool>? transferEncryptionEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (transferEncryptionEnabled != null)
        'transfer_encryption_enabled': transferEncryptionEnabled,
    });
  }

  SettingItemsCompanion copyWith({
    Value<int>? id,
    Value<AppThemeMode>? themeMode,
    Value<bool>? transferEncryptionEnabled,
  }) {
    return SettingItemsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      transferEncryptionEnabled:
          transferEncryptionEnabled ?? this.transferEncryptionEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(
        $SettingItemsTable.$converterthemeMode.toSql(themeMode.value),
      );
    }
    if (transferEncryptionEnabled.present) {
      map['transfer_encryption_enabled'] = Variable<bool>(
        transferEncryptionEnabled.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingItemsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('transferEncryptionEnabled: $transferEncryptionEnabled')
          ..write(')'))
        .toString();
  }
}

class $MineItemsTable extends MineItems
    with TableInfo<$MineItemsTable, MineItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MineItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, displayName, deviceId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mine_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MineItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MineItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MineItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  $MineItemsTable createAlias(String alias) {
    return $MineItemsTable(attachedDatabase, alias);
  }
}

class MineItem extends DataClass implements Insertable<MineItem> {
  final int id;
  final String displayName;
  final String deviceId;
  const MineItem({
    required this.id,
    required this.displayName,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  MineItemsCompanion toCompanion(bool nullToAbsent) {
    return MineItemsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      deviceId: Value(deviceId),
    );
  }

  factory MineItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MineItem(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  MineItem copyWith({int? id, String? displayName, String? deviceId}) =>
      MineItem(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        deviceId: deviceId ?? this.deviceId,
      );
  MineItem copyWithCompanion(MineItemsCompanion data) {
    return MineItem(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MineItem(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MineItem &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.deviceId == this.deviceId);
}

class MineItemsCompanion extends UpdateCompanion<MineItem> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<String> deviceId;
  const MineItemsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.deviceId = const Value.absent(),
  });
  MineItemsCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    required String deviceId,
  }) : displayName = Value(displayName),
       deviceId = Value(deviceId);
  static Insertable<MineItem> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<String>? deviceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (deviceId != null) 'device_id': deviceId,
    });
  }

  MineItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<String>? deviceId,
  }) {
    return MineItemsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MineItemsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }
}

class $MessageItemsTable extends MessageItems
    with TableInfo<$MessageItemsTable, MessageItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _remoteDeviceIdMeta = const VerificationMeta(
    'remoteDeviceId',
  );
  @override
  late final GeneratedColumn<String> remoteDeviceId = GeneratedColumn<String>(
    'remote_device_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES device_items (device_id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
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
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MessageDirection, String>
  direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MessageDirection>($MessageItemsTable.$converterdirection);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteDeviceId,
    textContent,
    createdAt,
    direction,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_device_id')) {
      context.handle(
        _remoteDeviceIdMeta,
        remoteDeviceId.isAcceptableOrUnknown(
          data['remote_device_id']!,
          _remoteDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteDeviceIdMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_device_id'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      direction: $MessageItemsTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
    );
  }

  @override
  $MessageItemsTable createAlias(String alias) {
    return $MessageItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageDirection, String, String>
  $converterdirection = const EnumNameConverter<MessageDirection>(
    MessageDirection.values,
  );
}

class MessageItem extends DataClass implements Insertable<MessageItem> {
  final int id;
  final String remoteDeviceId;
  final String? textContent;
  final DateTime createdAt;
  final MessageDirection direction;
  const MessageItem({
    required this.id,
    required this.remoteDeviceId,
    this.textContent,
    required this.createdAt,
    required this.direction,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['remote_device_id'] = Variable<String>(remoteDeviceId);
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['direction'] = Variable<String>(
        $MessageItemsTable.$converterdirection.toSql(direction),
      );
    }
    return map;
  }

  MessageItemsCompanion toCompanion(bool nullToAbsent) {
    return MessageItemsCompanion(
      id: Value(id),
      remoteDeviceId: Value(remoteDeviceId),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      createdAt: Value(createdAt),
      direction: Value(direction),
    );
  }

  factory MessageItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageItem(
      id: serializer.fromJson<int>(json['id']),
      remoteDeviceId: serializer.fromJson<String>(json['remoteDeviceId']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      direction: $MessageItemsTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteDeviceId': serializer.toJson<String>(remoteDeviceId),
      'textContent': serializer.toJson<String?>(textContent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'direction': serializer.toJson<String>(
        $MessageItemsTable.$converterdirection.toJson(direction),
      ),
    };
  }

  MessageItem copyWith({
    int? id,
    String? remoteDeviceId,
    Value<String?> textContent = const Value.absent(),
    DateTime? createdAt,
    MessageDirection? direction,
  }) => MessageItem(
    id: id ?? this.id,
    remoteDeviceId: remoteDeviceId ?? this.remoteDeviceId,
    textContent: textContent.present ? textContent.value : this.textContent,
    createdAt: createdAt ?? this.createdAt,
    direction: direction ?? this.direction,
  );
  MessageItem copyWithCompanion(MessageItemsCompanion data) {
    return MessageItem(
      id: data.id.present ? data.id.value : this.id,
      remoteDeviceId: data.remoteDeviceId.present
          ? data.remoteDeviceId.value
          : this.remoteDeviceId,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      direction: data.direction.present ? data.direction.value : this.direction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageItem(')
          ..write('id: $id, ')
          ..write('remoteDeviceId: $remoteDeviceId, ')
          ..write('textContent: $textContent, ')
          ..write('createdAt: $createdAt, ')
          ..write('direction: $direction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, remoteDeviceId, textContent, createdAt, direction);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageItem &&
          other.id == this.id &&
          other.remoteDeviceId == this.remoteDeviceId &&
          other.textContent == this.textContent &&
          other.createdAt == this.createdAt &&
          other.direction == this.direction);
}

class MessageItemsCompanion extends UpdateCompanion<MessageItem> {
  final Value<int> id;
  final Value<String> remoteDeviceId;
  final Value<String?> textContent;
  final Value<DateTime> createdAt;
  final Value<MessageDirection> direction;
  const MessageItemsCompanion({
    this.id = const Value.absent(),
    this.remoteDeviceId = const Value.absent(),
    this.textContent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.direction = const Value.absent(),
  });
  MessageItemsCompanion.insert({
    this.id = const Value.absent(),
    required String remoteDeviceId,
    this.textContent = const Value.absent(),
    this.createdAt = const Value.absent(),
    required MessageDirection direction,
  }) : remoteDeviceId = Value(remoteDeviceId),
       direction = Value(direction);
  static Insertable<MessageItem> custom({
    Expression<int>? id,
    Expression<String>? remoteDeviceId,
    Expression<String>? textContent,
    Expression<DateTime>? createdAt,
    Expression<String>? direction,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteDeviceId != null) 'remote_device_id': remoteDeviceId,
      if (textContent != null) 'text_content': textContent,
      if (createdAt != null) 'created_at': createdAt,
      if (direction != null) 'direction': direction,
    });
  }

  MessageItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? remoteDeviceId,
    Value<String?>? textContent,
    Value<DateTime>? createdAt,
    Value<MessageDirection>? direction,
  }) {
    return MessageItemsCompanion(
      id: id ?? this.id,
      remoteDeviceId: remoteDeviceId ?? this.remoteDeviceId,
      textContent: textContent ?? this.textContent,
      createdAt: createdAt ?? this.createdAt,
      direction: direction ?? this.direction,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteDeviceId.present) {
      map['remote_device_id'] = Variable<String>(remoteDeviceId.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $MessageItemsTable.$converterdirection.toSql(direction.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageItemsCompanion(')
          ..write('id: $id, ')
          ..write('remoteDeviceId: $remoteDeviceId, ')
          ..write('textContent: $textContent, ')
          ..write('createdAt: $createdAt, ')
          ..write('direction: $direction')
          ..write(')'))
        .toString();
  }
}

class $MessageAttachmentItemsTable extends MessageAttachmentItems
    with TableInfo<$MessageAttachmentItemsTable, MessageAttachmentItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageAttachmentItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES message_items (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<
    MessageAttachmentSaveStatus,
    String
  >
  saveStatus =
      GeneratedColumn<String>(
        'save_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => MessageAttachmentSaveStatus.pending.name,
      ).withConverter<MessageAttachmentSaveStatus>(
        $MessageAttachmentItemsTable.$convertersaveStatus,
      );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadProgressMeta = const VerificationMeta(
    'downloadProgress',
  );
  @override
  late final GeneratedColumn<int> downloadProgress = GeneratedColumn<int>(
    'download_progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL CHECK (download_progress BETWEEN 0 AND 100)',
    clientDefault: () => 0,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    saveStatus,
    filePath,
    downloadProgress,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_attachment_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageAttachmentItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('download_progress')) {
      context.handle(
        _downloadProgressMeta,
        downloadProgress.isAcceptableOrUnknown(
          data['download_progress']!,
          _downloadProgressMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageAttachmentItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageAttachmentItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      )!,
      saveStatus: $MessageAttachmentItemsTable.$convertersaveStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}save_status'],
        )!,
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      downloadProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}download_progress'],
      )!,
    );
  }

  @override
  $MessageAttachmentItemsTable createAlias(String alias) {
    return $MessageAttachmentItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageAttachmentSaveStatus, String, String>
  $convertersaveStatus = const EnumNameConverter<MessageAttachmentSaveStatus>(
    MessageAttachmentSaveStatus.values,
  );
}

class MessageAttachmentItem extends DataClass
    implements Insertable<MessageAttachmentItem> {
  final int id;
  final int messageId;
  final MessageAttachmentSaveStatus saveStatus;
  final String? filePath;
  final int downloadProgress;
  const MessageAttachmentItem({
    required this.id,
    required this.messageId,
    required this.saveStatus,
    this.filePath,
    required this.downloadProgress,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<int>(messageId);
    {
      map['save_status'] = Variable<String>(
        $MessageAttachmentItemsTable.$convertersaveStatus.toSql(saveStatus),
      );
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    map['download_progress'] = Variable<int>(downloadProgress);
    return map;
  }

  MessageAttachmentItemsCompanion toCompanion(bool nullToAbsent) {
    return MessageAttachmentItemsCompanion(
      id: Value(id),
      messageId: Value(messageId),
      saveStatus: Value(saveStatus),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      downloadProgress: Value(downloadProgress),
    );
  }

  factory MessageAttachmentItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageAttachmentItem(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<int>(json['messageId']),
      saveStatus: $MessageAttachmentItemsTable.$convertersaveStatus.fromJson(
        serializer.fromJson<String>(json['saveStatus']),
      ),
      filePath: serializer.fromJson<String?>(json['filePath']),
      downloadProgress: serializer.fromJson<int>(json['downloadProgress']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<int>(messageId),
      'saveStatus': serializer.toJson<String>(
        $MessageAttachmentItemsTable.$convertersaveStatus.toJson(saveStatus),
      ),
      'filePath': serializer.toJson<String?>(filePath),
      'downloadProgress': serializer.toJson<int>(downloadProgress),
    };
  }

  MessageAttachmentItem copyWith({
    int? id,
    int? messageId,
    MessageAttachmentSaveStatus? saveStatus,
    Value<String?> filePath = const Value.absent(),
    int? downloadProgress,
  }) => MessageAttachmentItem(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    saveStatus: saveStatus ?? this.saveStatus,
    filePath: filePath.present ? filePath.value : this.filePath,
    downloadProgress: downloadProgress ?? this.downloadProgress,
  );
  MessageAttachmentItem copyWithCompanion(
    MessageAttachmentItemsCompanion data,
  ) {
    return MessageAttachmentItem(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      saveStatus: data.saveStatus.present
          ? data.saveStatus.value
          : this.saveStatus,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      downloadProgress: data.downloadProgress.present
          ? data.downloadProgress.value
          : this.downloadProgress,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageAttachmentItem(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('saveStatus: $saveStatus, ')
          ..write('filePath: $filePath, ')
          ..write('downloadProgress: $downloadProgress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, messageId, saveStatus, filePath, downloadProgress);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageAttachmentItem &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.saveStatus == this.saveStatus &&
          other.filePath == this.filePath &&
          other.downloadProgress == this.downloadProgress);
}

class MessageAttachmentItemsCompanion
    extends UpdateCompanion<MessageAttachmentItem> {
  final Value<int> id;
  final Value<int> messageId;
  final Value<MessageAttachmentSaveStatus> saveStatus;
  final Value<String?> filePath;
  final Value<int> downloadProgress;
  const MessageAttachmentItemsCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.saveStatus = const Value.absent(),
    this.filePath = const Value.absent(),
    this.downloadProgress = const Value.absent(),
  });
  MessageAttachmentItemsCompanion.insert({
    this.id = const Value.absent(),
    required int messageId,
    this.saveStatus = const Value.absent(),
    this.filePath = const Value.absent(),
    this.downloadProgress = const Value.absent(),
  }) : messageId = Value(messageId);
  static Insertable<MessageAttachmentItem> custom({
    Expression<int>? id,
    Expression<int>? messageId,
    Expression<String>? saveStatus,
    Expression<String>? filePath,
    Expression<int>? downloadProgress,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (saveStatus != null) 'save_status': saveStatus,
      if (filePath != null) 'file_path': filePath,
      if (downloadProgress != null) 'download_progress': downloadProgress,
    });
  }

  MessageAttachmentItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? messageId,
    Value<MessageAttachmentSaveStatus>? saveStatus,
    Value<String?>? filePath,
    Value<int>? downloadProgress,
  }) {
    return MessageAttachmentItemsCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      saveStatus: saveStatus ?? this.saveStatus,
      filePath: filePath ?? this.filePath,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (saveStatus.present) {
      map['save_status'] = Variable<String>(
        $MessageAttachmentItemsTable.$convertersaveStatus.toSql(
          saveStatus.value,
        ),
      );
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (downloadProgress.present) {
      map['download_progress'] = Variable<int>(downloadProgress.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageAttachmentItemsCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('saveStatus: $saveStatus, ')
          ..write('filePath: $filePath, ')
          ..write('downloadProgress: $downloadProgress')
          ..write(')'))
        .toString();
  }
}

class $PointItemsTable extends PointItems
    with TableInfo<$PointItemsTable, PointItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PointItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _firstLaunchAtMeta = const VerificationMeta(
    'firstLaunchAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstLaunchAt =
      GeneratedColumn<DateTime>(
        'first_launch_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        clientDefault: DateTime.now,
      );
  static const VerificationMeta _chattedDeviceCountMeta =
      const VerificationMeta('chattedDeviceCount');
  @override
  late final GeneratedColumn<int> chattedDeviceCount = GeneratedColumn<int>(
    'chatted_device_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _discoveredDeviceCountMeta =
      const VerificationMeta('discoveredDeviceCount');
  @override
  late final GeneratedColumn<int> discoveredDeviceCount = GeneratedColumn<int>(
    'discovered_device_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _sentTextCharacterCountMeta =
      const VerificationMeta('sentTextCharacterCount');
  @override
  late final GeneratedColumn<int> sentTextCharacterCount = GeneratedColumn<int>(
    'sent_text_character_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _sentFileBytesMeta = const VerificationMeta(
    'sentFileBytes',
  );
  @override
  late final GeneratedColumn<int> sentFileBytes = GeneratedColumn<int>(
    'sent_file_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firstLaunchAt,
    chattedDeviceCount,
    discoveredDeviceCount,
    sentTextCharacterCount,
    sentFileBytes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'point_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PointItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('first_launch_at')) {
      context.handle(
        _firstLaunchAtMeta,
        firstLaunchAt.isAcceptableOrUnknown(
          data['first_launch_at']!,
          _firstLaunchAtMeta,
        ),
      );
    }
    if (data.containsKey('chatted_device_count')) {
      context.handle(
        _chattedDeviceCountMeta,
        chattedDeviceCount.isAcceptableOrUnknown(
          data['chatted_device_count']!,
          _chattedDeviceCountMeta,
        ),
      );
    }
    if (data.containsKey('discovered_device_count')) {
      context.handle(
        _discoveredDeviceCountMeta,
        discoveredDeviceCount.isAcceptableOrUnknown(
          data['discovered_device_count']!,
          _discoveredDeviceCountMeta,
        ),
      );
    }
    if (data.containsKey('sent_text_character_count')) {
      context.handle(
        _sentTextCharacterCountMeta,
        sentTextCharacterCount.isAcceptableOrUnknown(
          data['sent_text_character_count']!,
          _sentTextCharacterCountMeta,
        ),
      );
    }
    if (data.containsKey('sent_file_bytes')) {
      context.handle(
        _sentFileBytesMeta,
        sentFileBytes.isAcceptableOrUnknown(
          data['sent_file_bytes']!,
          _sentFileBytesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PointItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PointItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      firstLaunchAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_launch_at'],
      )!,
      chattedDeviceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chatted_device_count'],
      )!,
      discoveredDeviceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discovered_device_count'],
      )!,
      sentTextCharacterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sent_text_character_count'],
      )!,
      sentFileBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sent_file_bytes'],
      )!,
    );
  }

  @override
  $PointItemsTable createAlias(String alias) {
    return $PointItemsTable(attachedDatabase, alias);
  }
}

class PointItem extends DataClass implements Insertable<PointItem> {
  final int id;
  final DateTime firstLaunchAt;
  final int chattedDeviceCount;
  final int discoveredDeviceCount;
  final int sentTextCharacterCount;
  final int sentFileBytes;
  const PointItem({
    required this.id,
    required this.firstLaunchAt,
    required this.chattedDeviceCount,
    required this.discoveredDeviceCount,
    required this.sentTextCharacterCount,
    required this.sentFileBytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['first_launch_at'] = Variable<DateTime>(firstLaunchAt);
    map['chatted_device_count'] = Variable<int>(chattedDeviceCount);
    map['discovered_device_count'] = Variable<int>(discoveredDeviceCount);
    map['sent_text_character_count'] = Variable<int>(sentTextCharacterCount);
    map['sent_file_bytes'] = Variable<int>(sentFileBytes);
    return map;
  }

  PointItemsCompanion toCompanion(bool nullToAbsent) {
    return PointItemsCompanion(
      id: Value(id),
      firstLaunchAt: Value(firstLaunchAt),
      chattedDeviceCount: Value(chattedDeviceCount),
      discoveredDeviceCount: Value(discoveredDeviceCount),
      sentTextCharacterCount: Value(sentTextCharacterCount),
      sentFileBytes: Value(sentFileBytes),
    );
  }

  factory PointItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PointItem(
      id: serializer.fromJson<int>(json['id']),
      firstLaunchAt: serializer.fromJson<DateTime>(json['firstLaunchAt']),
      chattedDeviceCount: serializer.fromJson<int>(json['chattedDeviceCount']),
      discoveredDeviceCount: serializer.fromJson<int>(
        json['discoveredDeviceCount'],
      ),
      sentTextCharacterCount: serializer.fromJson<int>(
        json['sentTextCharacterCount'],
      ),
      sentFileBytes: serializer.fromJson<int>(json['sentFileBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firstLaunchAt': serializer.toJson<DateTime>(firstLaunchAt),
      'chattedDeviceCount': serializer.toJson<int>(chattedDeviceCount),
      'discoveredDeviceCount': serializer.toJson<int>(discoveredDeviceCount),
      'sentTextCharacterCount': serializer.toJson<int>(sentTextCharacterCount),
      'sentFileBytes': serializer.toJson<int>(sentFileBytes),
    };
  }

  PointItem copyWith({
    int? id,
    DateTime? firstLaunchAt,
    int? chattedDeviceCount,
    int? discoveredDeviceCount,
    int? sentTextCharacterCount,
    int? sentFileBytes,
  }) => PointItem(
    id: id ?? this.id,
    firstLaunchAt: firstLaunchAt ?? this.firstLaunchAt,
    chattedDeviceCount: chattedDeviceCount ?? this.chattedDeviceCount,
    discoveredDeviceCount: discoveredDeviceCount ?? this.discoveredDeviceCount,
    sentTextCharacterCount:
        sentTextCharacterCount ?? this.sentTextCharacterCount,
    sentFileBytes: sentFileBytes ?? this.sentFileBytes,
  );
  PointItem copyWithCompanion(PointItemsCompanion data) {
    return PointItem(
      id: data.id.present ? data.id.value : this.id,
      firstLaunchAt: data.firstLaunchAt.present
          ? data.firstLaunchAt.value
          : this.firstLaunchAt,
      chattedDeviceCount: data.chattedDeviceCount.present
          ? data.chattedDeviceCount.value
          : this.chattedDeviceCount,
      discoveredDeviceCount: data.discoveredDeviceCount.present
          ? data.discoveredDeviceCount.value
          : this.discoveredDeviceCount,
      sentTextCharacterCount: data.sentTextCharacterCount.present
          ? data.sentTextCharacterCount.value
          : this.sentTextCharacterCount,
      sentFileBytes: data.sentFileBytes.present
          ? data.sentFileBytes.value
          : this.sentFileBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PointItem(')
          ..write('id: $id, ')
          ..write('firstLaunchAt: $firstLaunchAt, ')
          ..write('chattedDeviceCount: $chattedDeviceCount, ')
          ..write('discoveredDeviceCount: $discoveredDeviceCount, ')
          ..write('sentTextCharacterCount: $sentTextCharacterCount, ')
          ..write('sentFileBytes: $sentFileBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firstLaunchAt,
    chattedDeviceCount,
    discoveredDeviceCount,
    sentTextCharacterCount,
    sentFileBytes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointItem &&
          other.id == this.id &&
          other.firstLaunchAt == this.firstLaunchAt &&
          other.chattedDeviceCount == this.chattedDeviceCount &&
          other.discoveredDeviceCount == this.discoveredDeviceCount &&
          other.sentTextCharacterCount == this.sentTextCharacterCount &&
          other.sentFileBytes == this.sentFileBytes);
}

class PointItemsCompanion extends UpdateCompanion<PointItem> {
  final Value<int> id;
  final Value<DateTime> firstLaunchAt;
  final Value<int> chattedDeviceCount;
  final Value<int> discoveredDeviceCount;
  final Value<int> sentTextCharacterCount;
  final Value<int> sentFileBytes;
  const PointItemsCompanion({
    this.id = const Value.absent(),
    this.firstLaunchAt = const Value.absent(),
    this.chattedDeviceCount = const Value.absent(),
    this.discoveredDeviceCount = const Value.absent(),
    this.sentTextCharacterCount = const Value.absent(),
    this.sentFileBytes = const Value.absent(),
  });
  PointItemsCompanion.insert({
    this.id = const Value.absent(),
    this.firstLaunchAt = const Value.absent(),
    this.chattedDeviceCount = const Value.absent(),
    this.discoveredDeviceCount = const Value.absent(),
    this.sentTextCharacterCount = const Value.absent(),
    this.sentFileBytes = const Value.absent(),
  });
  static Insertable<PointItem> custom({
    Expression<int>? id,
    Expression<DateTime>? firstLaunchAt,
    Expression<int>? chattedDeviceCount,
    Expression<int>? discoveredDeviceCount,
    Expression<int>? sentTextCharacterCount,
    Expression<int>? sentFileBytes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstLaunchAt != null) 'first_launch_at': firstLaunchAt,
      if (chattedDeviceCount != null)
        'chatted_device_count': chattedDeviceCount,
      if (discoveredDeviceCount != null)
        'discovered_device_count': discoveredDeviceCount,
      if (sentTextCharacterCount != null)
        'sent_text_character_count': sentTextCharacterCount,
      if (sentFileBytes != null) 'sent_file_bytes': sentFileBytes,
    });
  }

  PointItemsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? firstLaunchAt,
    Value<int>? chattedDeviceCount,
    Value<int>? discoveredDeviceCount,
    Value<int>? sentTextCharacterCount,
    Value<int>? sentFileBytes,
  }) {
    return PointItemsCompanion(
      id: id ?? this.id,
      firstLaunchAt: firstLaunchAt ?? this.firstLaunchAt,
      chattedDeviceCount: chattedDeviceCount ?? this.chattedDeviceCount,
      discoveredDeviceCount:
          discoveredDeviceCount ?? this.discoveredDeviceCount,
      sentTextCharacterCount:
          sentTextCharacterCount ?? this.sentTextCharacterCount,
      sentFileBytes: sentFileBytes ?? this.sentFileBytes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firstLaunchAt.present) {
      map['first_launch_at'] = Variable<DateTime>(firstLaunchAt.value);
    }
    if (chattedDeviceCount.present) {
      map['chatted_device_count'] = Variable<int>(chattedDeviceCount.value);
    }
    if (discoveredDeviceCount.present) {
      map['discovered_device_count'] = Variable<int>(
        discoveredDeviceCount.value,
      );
    }
    if (sentTextCharacterCount.present) {
      map['sent_text_character_count'] = Variable<int>(
        sentTextCharacterCount.value,
      );
    }
    if (sentFileBytes.present) {
      map['sent_file_bytes'] = Variable<int>(sentFileBytes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PointItemsCompanion(')
          ..write('id: $id, ')
          ..write('firstLaunchAt: $firstLaunchAt, ')
          ..write('chattedDeviceCount: $chattedDeviceCount, ')
          ..write('discoveredDeviceCount: $discoveredDeviceCount, ')
          ..write('sentTextCharacterCount: $sentTextCharacterCount, ')
          ..write('sentFileBytes: $sentFileBytes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDataBase extends GeneratedDatabase {
  _$AppDataBase(QueryExecutor e) : super(e);
  $AppDataBaseManager get managers => $AppDataBaseManager(this);
  late final $DeviceItemsTable deviceItems = $DeviceItemsTable(this);
  late final $SettingItemsTable settingItems = $SettingItemsTable(this);
  late final $MineItemsTable mineItems = $MineItemsTable(this);
  late final $MessageItemsTable messageItems = $MessageItemsTable(this);
  late final $MessageAttachmentItemsTable messageAttachmentItems =
      $MessageAttachmentItemsTable(this);
  late final $PointItemsTable pointItems = $PointItemsTable(this);
  late final Index deviceItemsConnectionStatus = Index(
    'device_items_connection_status',
    'CREATE INDEX device_items_connection_status ON device_items (connection_status)',
  );
  late final Index messageItemsRemoteDeviceId = Index(
    'message_items_remote_device_id',
    'CREATE INDEX message_items_remote_device_id ON message_items (remote_device_id)',
  );
  late final Index messageItemsCreatedAt = Index(
    'message_items_created_at',
    'CREATE INDEX message_items_created_at ON message_items (created_at)',
  );
  late final Index messageAttachmentItemsMessageId = Index(
    'message_attachment_items_message_id',
    'CREATE INDEX message_attachment_items_message_id ON message_attachment_items (message_id)',
  );
  late final DeviceDao deviceDao = DeviceDao(this as AppDataBase);
  late final MessageDao messageDao = MessageDao(this as AppDataBase);
  late final SettingDao settingDao = SettingDao(this as AppDataBase);
  late final MineDao mineDao = MineDao(this as AppDataBase);
  late final PointDao pointDao = PointDao(this as AppDataBase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    deviceItems,
    settingItems,
    mineItems,
    messageItems,
    messageAttachmentItems,
    pointItems,
    deviceItemsConnectionStatus,
    messageItemsRemoteDeviceId,
    messageItemsCreatedAt,
    messageAttachmentItemsMessageId,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'device_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('message_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'device_items',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('message_items', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'message_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('message_attachment_items', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'message_items',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('message_attachment_items', kind: UpdateKind.update),
      ],
    ),
  ]);
}

typedef $$DeviceItemsTableCreateCompanionBuilder =
    DeviceItemsCompanion Function({
      Value<int> id,
      required String displayName,
      required String deviceId,
      Value<DeviceConnectionStatus> connectionStatus,
      Value<int> averageTransferSpeedBytesPerSecond,
    });
typedef $$DeviceItemsTableUpdateCompanionBuilder =
    DeviceItemsCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<String> deviceId,
      Value<DeviceConnectionStatus> connectionStatus,
      Value<int> averageTransferSpeedBytesPerSecond,
    });

final class $$DeviceItemsTableReferences
    extends BaseReferences<_$AppDataBase, $DeviceItemsTable, DeviceItem> {
  $$DeviceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MessageItemsTable, List<MessageItem>>
  _messageItemsRefsTable(_$AppDataBase db) => MultiTypedResultKey.fromTable(
    db.messageItems,
    aliasName: $_aliasNameGenerator(
      db.deviceItems.deviceId,
      db.messageItems.remoteDeviceId,
    ),
  );

  $$MessageItemsTableProcessedTableManager get messageItemsRefs {
    final manager = $$MessageItemsTableTableManager($_db, $_db.messageItems)
        .filter(
          (f) => f.remoteDeviceId.deviceId.sqlEquals(
            $_itemColumn<String>('device_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_messageItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    DeviceConnectionStatus,
    DeviceConnectionStatus,
    String
  >
  get connectionStatus => $composableBuilder(
    column: $table.connectionStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get averageTransferSpeedBytesPerSecond =>
      $composableBuilder(
        column: $table.averageTransferSpeedBytesPerSecond,
        builder: (column) => ColumnFilters(column),
      );

  Expression<bool> messageItemsRefs(
    Expression<bool> Function($$MessageItemsTableFilterComposer f) f,
  ) {
    final $$MessageItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.messageItems,
      getReferencedColumn: (t) => t.remoteDeviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageItemsTableFilterComposer(
            $db: $db,
            $table: $db.messageItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectionStatus => $composableBuilder(
    column: $table.connectionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get averageTransferSpeedBytesPerSecond =>
      $composableBuilder(
        column: $table.averageTransferSpeedBytesPerSecond,
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

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DeviceConnectionStatus, String>
  get connectionStatus => $composableBuilder(
    column: $table.connectionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get averageTransferSpeedBytesPerSecond =>
      $composableBuilder(
        column: $table.averageTransferSpeedBytesPerSecond,
        builder: (column) => column,
      );

  Expression<T> messageItemsRefs<T extends Object>(
    Expression<T> Function($$MessageItemsTableAnnotationComposer a) f,
  ) {
    final $$MessageItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.messageItems,
      getReferencedColumn: (t) => t.remoteDeviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.messageItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (DeviceItem, $$DeviceItemsTableReferences),
          DeviceItem,
          PrefetchHooks Function({bool messageItemsRefs})
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
                Value<String> displayName = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DeviceConnectionStatus> connectionStatus =
                    const Value.absent(),
                Value<int> averageTransferSpeedBytesPerSecond =
                    const Value.absent(),
              }) => DeviceItemsCompanion(
                id: id,
                displayName: displayName,
                deviceId: deviceId,
                connectionStatus: connectionStatus,
                averageTransferSpeedBytesPerSecond:
                    averageTransferSpeedBytesPerSecond,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                required String deviceId,
                Value<DeviceConnectionStatus> connectionStatus =
                    const Value.absent(),
                Value<int> averageTransferSpeedBytesPerSecond =
                    const Value.absent(),
              }) => DeviceItemsCompanion.insert(
                id: id,
                displayName: displayName,
                deviceId: deviceId,
                connectionStatus: connectionStatus,
                averageTransferSpeedBytesPerSecond:
                    averageTransferSpeedBytesPerSecond,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeviceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (messageItemsRefs) db.messageItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messageItemsRefs)
                    await $_getPrefetchedData<
                      DeviceItem,
                      $DeviceItemsTable,
                      MessageItem
                    >(
                      currentTable: table,
                      referencedTable: $$DeviceItemsTableReferences
                          ._messageItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DeviceItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).messageItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.remoteDeviceId == item.deviceId,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (DeviceItem, $$DeviceItemsTableReferences),
      DeviceItem,
      PrefetchHooks Function({bool messageItemsRefs})
    >;
typedef $$SettingItemsTableCreateCompanionBuilder =
    SettingItemsCompanion Function({
      Value<int> id,
      Value<AppThemeMode> themeMode,
      Value<bool> transferEncryptionEnabled,
    });
typedef $$SettingItemsTableUpdateCompanionBuilder =
    SettingItemsCompanion Function({
      Value<int> id,
      Value<AppThemeMode> themeMode,
      Value<bool> transferEncryptionEnabled,
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

  ColumnWithTypeConverterFilters<AppThemeMode, AppThemeMode, String>
  get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get transferEncryptionEnabled => $composableBuilder(
    column: $table.transferEncryptionEnabled,
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

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get transferEncryptionEnabled => $composableBuilder(
    column: $table.transferEncryptionEnabled,
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

  GeneratedColumnWithTypeConverter<AppThemeMode, String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get transferEncryptionEnabled => $composableBuilder(
    column: $table.transferEncryptionEnabled,
    builder: (column) => column,
  );
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
                Value<AppThemeMode> themeMode = const Value.absent(),
                Value<bool> transferEncryptionEnabled = const Value.absent(),
              }) => SettingItemsCompanion(
                id: id,
                themeMode: themeMode,
                transferEncryptionEnabled: transferEncryptionEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<AppThemeMode> themeMode = const Value.absent(),
                Value<bool> transferEncryptionEnabled = const Value.absent(),
              }) => SettingItemsCompanion.insert(
                id: id,
                themeMode: themeMode,
                transferEncryptionEnabled: transferEncryptionEnabled,
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
typedef $$MineItemsTableCreateCompanionBuilder =
    MineItemsCompanion Function({
      Value<int> id,
      required String displayName,
      required String deviceId,
    });
typedef $$MineItemsTableUpdateCompanionBuilder =
    MineItemsCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<String> deviceId,
    });

class $$MineItemsTableFilterComposer
    extends Composer<_$AppDataBase, $MineItemsTable> {
  $$MineItemsTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MineItemsTableOrderingComposer
    extends Composer<_$AppDataBase, $MineItemsTable> {
  $$MineItemsTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MineItemsTableAnnotationComposer
    extends Composer<_$AppDataBase, $MineItemsTable> {
  $$MineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$MineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $MineItemsTable,
          MineItem,
          $$MineItemsTableFilterComposer,
          $$MineItemsTableOrderingComposer,
          $$MineItemsTableAnnotationComposer,
          $$MineItemsTableCreateCompanionBuilder,
          $$MineItemsTableUpdateCompanionBuilder,
          (MineItem, BaseReferences<_$AppDataBase, $MineItemsTable, MineItem>),
          MineItem,
          PrefetchHooks Function()
        > {
  $$MineItemsTableTableManager(_$AppDataBase db, $MineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
              }) => MineItemsCompanion(
                id: id,
                displayName: displayName,
                deviceId: deviceId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                required String deviceId,
              }) => MineItemsCompanion.insert(
                id: id,
                displayName: displayName,
                deviceId: deviceId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $MineItemsTable,
      MineItem,
      $$MineItemsTableFilterComposer,
      $$MineItemsTableOrderingComposer,
      $$MineItemsTableAnnotationComposer,
      $$MineItemsTableCreateCompanionBuilder,
      $$MineItemsTableUpdateCompanionBuilder,
      (MineItem, BaseReferences<_$AppDataBase, $MineItemsTable, MineItem>),
      MineItem,
      PrefetchHooks Function()
    >;
typedef $$MessageItemsTableCreateCompanionBuilder =
    MessageItemsCompanion Function({
      Value<int> id,
      required String remoteDeviceId,
      Value<String?> textContent,
      Value<DateTime> createdAt,
      required MessageDirection direction,
    });
typedef $$MessageItemsTableUpdateCompanionBuilder =
    MessageItemsCompanion Function({
      Value<int> id,
      Value<String> remoteDeviceId,
      Value<String?> textContent,
      Value<DateTime> createdAt,
      Value<MessageDirection> direction,
    });

final class $$MessageItemsTableReferences
    extends BaseReferences<_$AppDataBase, $MessageItemsTable, MessageItem> {
  $$MessageItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DeviceItemsTable _remoteDeviceIdTable(_$AppDataBase db) =>
      db.deviceItems.createAlias(
        $_aliasNameGenerator(
          db.messageItems.remoteDeviceId,
          db.deviceItems.deviceId,
        ),
      );

  $$DeviceItemsTableProcessedTableManager get remoteDeviceId {
    final $_column = $_itemColumn<String>('remote_device_id')!;

    final manager = $$DeviceItemsTableTableManager(
      $_db,
      $_db.deviceItems,
    ).filter((f) => f.deviceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_remoteDeviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $MessageAttachmentItemsTable,
    List<MessageAttachmentItem>
  >
  _messageAttachmentItemsRefsTable(_$AppDataBase db) =>
      MultiTypedResultKey.fromTable(
        db.messageAttachmentItems,
        aliasName: $_aliasNameGenerator(
          db.messageItems.id,
          db.messageAttachmentItems.messageId,
        ),
      );

  $$MessageAttachmentItemsTableProcessedTableManager
  get messageAttachmentItemsRefs {
    final manager = $$MessageAttachmentItemsTableTableManager(
      $_db,
      $_db.messageAttachmentItems,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _messageAttachmentItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MessageItemsTableFilterComposer
    extends Composer<_$AppDataBase, $MessageItemsTable> {
  $$MessageItemsTableFilterComposer({
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

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MessageDirection, MessageDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$DeviceItemsTableFilterComposer get remoteDeviceId {
    final $$DeviceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.remoteDeviceId,
      referencedTable: $db.deviceItems,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceItemsTableFilterComposer(
            $db: $db,
            $table: $db.deviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> messageAttachmentItemsRefs(
    Expression<bool> Function($$MessageAttachmentItemsTableFilterComposer f) f,
  ) {
    final $$MessageAttachmentItemsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.messageAttachmentItems,
          getReferencedColumn: (t) => t.messageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MessageAttachmentItemsTableFilterComposer(
                $db: $db,
                $table: $db.messageAttachmentItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MessageItemsTableOrderingComposer
    extends Composer<_$AppDataBase, $MessageItemsTable> {
  $$MessageItemsTableOrderingComposer({
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

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  $$DeviceItemsTableOrderingComposer get remoteDeviceId {
    final $$DeviceItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.remoteDeviceId,
      referencedTable: $db.deviceItems,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceItemsTableOrderingComposer(
            $db: $db,
            $table: $db.deviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageItemsTableAnnotationComposer
    extends Composer<_$AppDataBase, $MessageItemsTable> {
  $$MessageItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  $$DeviceItemsTableAnnotationComposer get remoteDeviceId {
    final $$DeviceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.remoteDeviceId,
      referencedTable: $db.deviceItems,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.deviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> messageAttachmentItemsRefs<T extends Object>(
    Expression<T> Function($$MessageAttachmentItemsTableAnnotationComposer a) f,
  ) {
    final $$MessageAttachmentItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.messageAttachmentItems,
          getReferencedColumn: (t) => t.messageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MessageAttachmentItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.messageAttachmentItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MessageItemsTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $MessageItemsTable,
          MessageItem,
          $$MessageItemsTableFilterComposer,
          $$MessageItemsTableOrderingComposer,
          $$MessageItemsTableAnnotationComposer,
          $$MessageItemsTableCreateCompanionBuilder,
          $$MessageItemsTableUpdateCompanionBuilder,
          (MessageItem, $$MessageItemsTableReferences),
          MessageItem,
          PrefetchHooks Function({
            bool remoteDeviceId,
            bool messageAttachmentItemsRefs,
          })
        > {
  $$MessageItemsTableTableManager(_$AppDataBase db, $MessageItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> remoteDeviceId = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<MessageDirection> direction = const Value.absent(),
              }) => MessageItemsCompanion(
                id: id,
                remoteDeviceId: remoteDeviceId,
                textContent: textContent,
                createdAt: createdAt,
                direction: direction,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String remoteDeviceId,
                Value<String?> textContent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required MessageDirection direction,
              }) => MessageItemsCompanion.insert(
                id: id,
                remoteDeviceId: remoteDeviceId,
                textContent: textContent,
                createdAt: createdAt,
                direction: direction,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessageItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({remoteDeviceId = false, messageAttachmentItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (messageAttachmentItemsRefs) db.messageAttachmentItems,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (remoteDeviceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.remoteDeviceId,
                                    referencedTable:
                                        $$MessageItemsTableReferences
                                            ._remoteDeviceIdTable(db),
                                    referencedColumn:
                                        $$MessageItemsTableReferences
                                            ._remoteDeviceIdTable(db)
                                            .deviceId,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (messageAttachmentItemsRefs)
                        await $_getPrefetchedData<
                          MessageItem,
                          $MessageItemsTable,
                          MessageAttachmentItem
                        >(
                          currentTable: table,
                          referencedTable: $$MessageItemsTableReferences
                              ._messageAttachmentItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MessageItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).messageAttachmentItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messageId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MessageItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $MessageItemsTable,
      MessageItem,
      $$MessageItemsTableFilterComposer,
      $$MessageItemsTableOrderingComposer,
      $$MessageItemsTableAnnotationComposer,
      $$MessageItemsTableCreateCompanionBuilder,
      $$MessageItemsTableUpdateCompanionBuilder,
      (MessageItem, $$MessageItemsTableReferences),
      MessageItem,
      PrefetchHooks Function({
        bool remoteDeviceId,
        bool messageAttachmentItemsRefs,
      })
    >;
typedef $$MessageAttachmentItemsTableCreateCompanionBuilder =
    MessageAttachmentItemsCompanion Function({
      Value<int> id,
      required int messageId,
      Value<MessageAttachmentSaveStatus> saveStatus,
      Value<String?> filePath,
      Value<int> downloadProgress,
    });
typedef $$MessageAttachmentItemsTableUpdateCompanionBuilder =
    MessageAttachmentItemsCompanion Function({
      Value<int> id,
      Value<int> messageId,
      Value<MessageAttachmentSaveStatus> saveStatus,
      Value<String?> filePath,
      Value<int> downloadProgress,
    });

final class $$MessageAttachmentItemsTableReferences
    extends
        BaseReferences<
          _$AppDataBase,
          $MessageAttachmentItemsTable,
          MessageAttachmentItem
        > {
  $$MessageAttachmentItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MessageItemsTable _messageIdTable(_$AppDataBase db) =>
      db.messageItems.createAlias(
        $_aliasNameGenerator(
          db.messageAttachmentItems.messageId,
          db.messageItems.id,
        ),
      );

  $$MessageItemsTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<int>('message_id')!;

    final manager = $$MessageItemsTableTableManager(
      $_db,
      $_db.messageItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessageAttachmentItemsTableFilterComposer
    extends Composer<_$AppDataBase, $MessageAttachmentItemsTable> {
  $$MessageAttachmentItemsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<
    MessageAttachmentSaveStatus,
    MessageAttachmentSaveStatus,
    String
  >
  get saveStatus => $composableBuilder(
    column: $table.saveStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadProgress => $composableBuilder(
    column: $table.downloadProgress,
    builder: (column) => ColumnFilters(column),
  );

  $$MessageItemsTableFilterComposer get messageId {
    final $$MessageItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messageItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageItemsTableFilterComposer(
            $db: $db,
            $table: $db.messageItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageAttachmentItemsTableOrderingComposer
    extends Composer<_$AppDataBase, $MessageAttachmentItemsTable> {
  $$MessageAttachmentItemsTableOrderingComposer({
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

  ColumnOrderings<String> get saveStatus => $composableBuilder(
    column: $table.saveStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadProgress => $composableBuilder(
    column: $table.downloadProgress,
    builder: (column) => ColumnOrderings(column),
  );

  $$MessageItemsTableOrderingComposer get messageId {
    final $$MessageItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messageItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageItemsTableOrderingComposer(
            $db: $db,
            $table: $db.messageItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageAttachmentItemsTableAnnotationComposer
    extends Composer<_$AppDataBase, $MessageAttachmentItemsTable> {
  $$MessageAttachmentItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageAttachmentSaveStatus, String>
  get saveStatus => $composableBuilder(
    column: $table.saveStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get downloadProgress => $composableBuilder(
    column: $table.downloadProgress,
    builder: (column) => column,
  );

  $$MessageItemsTableAnnotationComposer get messageId {
    final $$MessageItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messageItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.messageItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageAttachmentItemsTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $MessageAttachmentItemsTable,
          MessageAttachmentItem,
          $$MessageAttachmentItemsTableFilterComposer,
          $$MessageAttachmentItemsTableOrderingComposer,
          $$MessageAttachmentItemsTableAnnotationComposer,
          $$MessageAttachmentItemsTableCreateCompanionBuilder,
          $$MessageAttachmentItemsTableUpdateCompanionBuilder,
          (MessageAttachmentItem, $$MessageAttachmentItemsTableReferences),
          MessageAttachmentItem,
          PrefetchHooks Function({bool messageId})
        > {
  $$MessageAttachmentItemsTableTableManager(
    _$AppDataBase db,
    $MessageAttachmentItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageAttachmentItemsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MessageAttachmentItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MessageAttachmentItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> messageId = const Value.absent(),
                Value<MessageAttachmentSaveStatus> saveStatus =
                    const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<int> downloadProgress = const Value.absent(),
              }) => MessageAttachmentItemsCompanion(
                id: id,
                messageId: messageId,
                saveStatus: saveStatus,
                filePath: filePath,
                downloadProgress: downloadProgress,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int messageId,
                Value<MessageAttachmentSaveStatus> saveStatus =
                    const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<int> downloadProgress = const Value.absent(),
              }) => MessageAttachmentItemsCompanion.insert(
                id: id,
                messageId: messageId,
                saveStatus: saveStatus,
                filePath: filePath,
                downloadProgress: downloadProgress,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessageAttachmentItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (messageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.messageId,
                                referencedTable:
                                    $$MessageAttachmentItemsTableReferences
                                        ._messageIdTable(db),
                                referencedColumn:
                                    $$MessageAttachmentItemsTableReferences
                                        ._messageIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MessageAttachmentItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $MessageAttachmentItemsTable,
      MessageAttachmentItem,
      $$MessageAttachmentItemsTableFilterComposer,
      $$MessageAttachmentItemsTableOrderingComposer,
      $$MessageAttachmentItemsTableAnnotationComposer,
      $$MessageAttachmentItemsTableCreateCompanionBuilder,
      $$MessageAttachmentItemsTableUpdateCompanionBuilder,
      (MessageAttachmentItem, $$MessageAttachmentItemsTableReferences),
      MessageAttachmentItem,
      PrefetchHooks Function({bool messageId})
    >;
typedef $$PointItemsTableCreateCompanionBuilder =
    PointItemsCompanion Function({
      Value<int> id,
      Value<DateTime> firstLaunchAt,
      Value<int> chattedDeviceCount,
      Value<int> discoveredDeviceCount,
      Value<int> sentTextCharacterCount,
      Value<int> sentFileBytes,
    });
typedef $$PointItemsTableUpdateCompanionBuilder =
    PointItemsCompanion Function({
      Value<int> id,
      Value<DateTime> firstLaunchAt,
      Value<int> chattedDeviceCount,
      Value<int> discoveredDeviceCount,
      Value<int> sentTextCharacterCount,
      Value<int> sentFileBytes,
    });

class $$PointItemsTableFilterComposer
    extends Composer<_$AppDataBase, $PointItemsTable> {
  $$PointItemsTableFilterComposer({
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

  ColumnFilters<DateTime> get firstLaunchAt => $composableBuilder(
    column: $table.firstLaunchAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chattedDeviceCount => $composableBuilder(
    column: $table.chattedDeviceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discoveredDeviceCount => $composableBuilder(
    column: $table.discoveredDeviceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentTextCharacterCount => $composableBuilder(
    column: $table.sentTextCharacterCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentFileBytes => $composableBuilder(
    column: $table.sentFileBytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PointItemsTableOrderingComposer
    extends Composer<_$AppDataBase, $PointItemsTable> {
  $$PointItemsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get firstLaunchAt => $composableBuilder(
    column: $table.firstLaunchAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chattedDeviceCount => $composableBuilder(
    column: $table.chattedDeviceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discoveredDeviceCount => $composableBuilder(
    column: $table.discoveredDeviceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentTextCharacterCount => $composableBuilder(
    column: $table.sentTextCharacterCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentFileBytes => $composableBuilder(
    column: $table.sentFileBytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PointItemsTableAnnotationComposer
    extends Composer<_$AppDataBase, $PointItemsTable> {
  $$PointItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get firstLaunchAt => $composableBuilder(
    column: $table.firstLaunchAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chattedDeviceCount => $composableBuilder(
    column: $table.chattedDeviceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discoveredDeviceCount => $composableBuilder(
    column: $table.discoveredDeviceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sentTextCharacterCount => $composableBuilder(
    column: $table.sentTextCharacterCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sentFileBytes => $composableBuilder(
    column: $table.sentFileBytes,
    builder: (column) => column,
  );
}

class $$PointItemsTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $PointItemsTable,
          PointItem,
          $$PointItemsTableFilterComposer,
          $$PointItemsTableOrderingComposer,
          $$PointItemsTableAnnotationComposer,
          $$PointItemsTableCreateCompanionBuilder,
          $$PointItemsTableUpdateCompanionBuilder,
          (
            PointItem,
            BaseReferences<_$AppDataBase, $PointItemsTable, PointItem>,
          ),
          PointItem,
          PrefetchHooks Function()
        > {
  $$PointItemsTableTableManager(_$AppDataBase db, $PointItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PointItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PointItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PointItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> firstLaunchAt = const Value.absent(),
                Value<int> chattedDeviceCount = const Value.absent(),
                Value<int> discoveredDeviceCount = const Value.absent(),
                Value<int> sentTextCharacterCount = const Value.absent(),
                Value<int> sentFileBytes = const Value.absent(),
              }) => PointItemsCompanion(
                id: id,
                firstLaunchAt: firstLaunchAt,
                chattedDeviceCount: chattedDeviceCount,
                discoveredDeviceCount: discoveredDeviceCount,
                sentTextCharacterCount: sentTextCharacterCount,
                sentFileBytes: sentFileBytes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> firstLaunchAt = const Value.absent(),
                Value<int> chattedDeviceCount = const Value.absent(),
                Value<int> discoveredDeviceCount = const Value.absent(),
                Value<int> sentTextCharacterCount = const Value.absent(),
                Value<int> sentFileBytes = const Value.absent(),
              }) => PointItemsCompanion.insert(
                id: id,
                firstLaunchAt: firstLaunchAt,
                chattedDeviceCount: chattedDeviceCount,
                discoveredDeviceCount: discoveredDeviceCount,
                sentTextCharacterCount: sentTextCharacterCount,
                sentFileBytes: sentFileBytes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PointItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $PointItemsTable,
      PointItem,
      $$PointItemsTableFilterComposer,
      $$PointItemsTableOrderingComposer,
      $$PointItemsTableAnnotationComposer,
      $$PointItemsTableCreateCompanionBuilder,
      $$PointItemsTableUpdateCompanionBuilder,
      (PointItem, BaseReferences<_$AppDataBase, $PointItemsTable, PointItem>),
      PointItem,
      PrefetchHooks Function()
    >;

class $AppDataBaseManager {
  final _$AppDataBase _db;
  $AppDataBaseManager(this._db);
  $$DeviceItemsTableTableManager get deviceItems =>
      $$DeviceItemsTableTableManager(_db, _db.deviceItems);
  $$SettingItemsTableTableManager get settingItems =>
      $$SettingItemsTableTableManager(_db, _db.settingItems);
  $$MineItemsTableTableManager get mineItems =>
      $$MineItemsTableTableManager(_db, _db.mineItems);
  $$MessageItemsTableTableManager get messageItems =>
      $$MessageItemsTableTableManager(_db, _db.messageItems);
  $$MessageAttachmentItemsTableTableManager get messageAttachmentItems =>
      $$MessageAttachmentItemsTableTableManager(
        _db,
        _db.messageAttachmentItems,
      );
  $$PointItemsTableTableManager get pointItems =>
      $$PointItemsTableTableManager(_db, _db.pointItems);
}
