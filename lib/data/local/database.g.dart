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

class $DeviceAddressItemsTable extends DeviceAddressItems
    with TableInfo<$DeviceAddressItemsTable, DeviceAddressItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceAddressItemsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES device_items (device_id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ipAddressMeta = const VerificationMeta(
    'ipAddress',
  );
  @override
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
    'ip_address',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DeviceIpVersion, String>
  ipVersion =
      GeneratedColumn<String>(
        'ip_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DeviceIpVersion>(
        $DeviceAddressItemsTable.$converteripVersion,
      );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interfaceNameMeta = const VerificationMeta(
    'interfaceName',
  );
  @override
  late final GeneratedColumn<String> interfaceName = GeneratedColumn<String>(
    'interface_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _networkSignatureMeta = const VerificationMeta(
    'networkSignature',
  );
  @override
  late final GeneratedColumn<String> networkSignature = GeneratedColumn<String>(
    'network_signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subnetMaskMeta = const VerificationMeta(
    'subnetMask',
  );
  @override
  late final GeneratedColumn<String> subnetMask = GeneratedColumn<String>(
    'subnet_mask',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gatewayAddressMeta = const VerificationMeta(
    'gatewayAddress',
  );
  @override
  late final GeneratedColumn<String> gatewayAddress = GeneratedColumn<String>(
    'gateway_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _broadcastAddressMeta = const VerificationMeta(
    'broadcastAddress',
  );
  @override
  late final GeneratedColumn<String> broadcastAddress = GeneratedColumn<String>(
    'broadcast_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DeviceAddressSource, String>
  source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => DeviceAddressSource.broadcast.name,
      ).withConverter<DeviceAddressSource>(
        $DeviceAddressItemsTable.$convertersource,
      );
  static const VerificationMeta _isReachableMeta = const VerificationMeta(
    'isReachable',
  );
  @override
  late final GeneratedColumn<bool> isReachable = GeneratedColumn<bool>(
    'is_reachable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_reachable" IN (0, 1))',
    ),
    clientDefault: () => false,
  );
  static const VerificationMeta _latencyMsMeta = const VerificationMeta(
    'latencyMs',
  );
  @override
  late final GeneratedColumn<int> latencyMs = GeneratedColumn<int>(
    'latency_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSuccessAt =
      GeneratedColumn<DateTime>(
        'last_success_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastFailureAtMeta = const VerificationMeta(
    'lastFailureAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFailureAt =
      GeneratedColumn<DateTime>(
        'last_failure_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    ipAddress,
    ipVersion,
    port,
    interfaceName,
    networkSignature,
    subnetMask,
    gatewayAddress,
    broadcastAddress,
    source,
    isReachable,
    latencyMs,
    averageTransferSpeedBytesPerSecond,
    lastSeenAt,
    lastSuccessAt,
    lastFailureAt,
    failureReason,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_address_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceAddressItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('ip_address')) {
      context.handle(
        _ipAddressMeta,
        ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta),
      );
    } else if (isInserting) {
      context.missing(_ipAddressMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('interface_name')) {
      context.handle(
        _interfaceNameMeta,
        interfaceName.isAcceptableOrUnknown(
          data['interface_name']!,
          _interfaceNameMeta,
        ),
      );
    }
    if (data.containsKey('network_signature')) {
      context.handle(
        _networkSignatureMeta,
        networkSignature.isAcceptableOrUnknown(
          data['network_signature']!,
          _networkSignatureMeta,
        ),
      );
    }
    if (data.containsKey('subnet_mask')) {
      context.handle(
        _subnetMaskMeta,
        subnetMask.isAcceptableOrUnknown(data['subnet_mask']!, _subnetMaskMeta),
      );
    }
    if (data.containsKey('gateway_address')) {
      context.handle(
        _gatewayAddressMeta,
        gatewayAddress.isAcceptableOrUnknown(
          data['gateway_address']!,
          _gatewayAddressMeta,
        ),
      );
    }
    if (data.containsKey('broadcast_address')) {
      context.handle(
        _broadcastAddressMeta,
        broadcastAddress.isAcceptableOrUnknown(
          data['broadcast_address']!,
          _broadcastAddressMeta,
        ),
      );
    }
    if (data.containsKey('is_reachable')) {
      context.handle(
        _isReachableMeta,
        isReachable.isAcceptableOrUnknown(
          data['is_reachable']!,
          _isReachableMeta,
        ),
      );
    }
    if (data.containsKey('latency_ms')) {
      context.handle(
        _latencyMsMeta,
        latencyMs.isAcceptableOrUnknown(data['latency_ms']!, _latencyMsMeta),
      );
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
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('last_failure_at')) {
      context.handle(
        _lastFailureAtMeta,
        lastFailureAt.isAcceptableOrUnknown(
          data['last_failure_at']!,
          _lastFailureAtMeta,
        ),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
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
  DeviceAddressItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceAddressItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      ipAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ip_address'],
      )!,
      ipVersion: $DeviceAddressItemsTable.$converteripVersion.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ip_version'],
        )!,
      ),
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      interfaceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interface_name'],
      ),
      networkSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network_signature'],
      ),
      subnetMask: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subnet_mask'],
      ),
      gatewayAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gateway_address'],
      ),
      broadcastAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broadcast_address'],
      ),
      source: $DeviceAddressItemsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      isReachable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_reachable'],
      )!,
      latencyMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latency_ms'],
      ),
      averageTransferSpeedBytesPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}average_transfer_speed_bytes_per_second'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_success_at'],
      ),
      lastFailureAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_failure_at'],
      ),
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
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
  $DeviceAddressItemsTable createAlias(String alias) {
    return $DeviceAddressItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DeviceIpVersion, String, String>
  $converteripVersion = const EnumNameConverter<DeviceIpVersion>(
    DeviceIpVersion.values,
  );
  static JsonTypeConverter2<DeviceAddressSource, String, String>
  $convertersource = const EnumNameConverter<DeviceAddressSource>(
    DeviceAddressSource.values,
  );
}

class DeviceAddressItem extends DataClass
    implements Insertable<DeviceAddressItem> {
  final int id;
  final String deviceId;
  final String ipAddress;
  final DeviceIpVersion ipVersion;
  final int port;
  final String? interfaceName;
  final String? networkSignature;
  final String? subnetMask;
  final String? gatewayAddress;
  final String? broadcastAddress;
  final DeviceAddressSource source;
  final bool isReachable;
  final int? latencyMs;
  final int averageTransferSpeedBytesPerSecond;
  final DateTime lastSeenAt;
  final DateTime? lastSuccessAt;
  final DateTime? lastFailureAt;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DeviceAddressItem({
    required this.id,
    required this.deviceId,
    required this.ipAddress,
    required this.ipVersion,
    required this.port,
    this.interfaceName,
    this.networkSignature,
    this.subnetMask,
    this.gatewayAddress,
    this.broadcastAddress,
    required this.source,
    required this.isReachable,
    this.latencyMs,
    required this.averageTransferSpeedBytesPerSecond,
    required this.lastSeenAt,
    this.lastSuccessAt,
    this.lastFailureAt,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['ip_address'] = Variable<String>(ipAddress);
    {
      map['ip_version'] = Variable<String>(
        $DeviceAddressItemsTable.$converteripVersion.toSql(ipVersion),
      );
    }
    map['port'] = Variable<int>(port);
    if (!nullToAbsent || interfaceName != null) {
      map['interface_name'] = Variable<String>(interfaceName);
    }
    if (!nullToAbsent || networkSignature != null) {
      map['network_signature'] = Variable<String>(networkSignature);
    }
    if (!nullToAbsent || subnetMask != null) {
      map['subnet_mask'] = Variable<String>(subnetMask);
    }
    if (!nullToAbsent || gatewayAddress != null) {
      map['gateway_address'] = Variable<String>(gatewayAddress);
    }
    if (!nullToAbsent || broadcastAddress != null) {
      map['broadcast_address'] = Variable<String>(broadcastAddress);
    }
    {
      map['source'] = Variable<String>(
        $DeviceAddressItemsTable.$convertersource.toSql(source),
      );
    }
    map['is_reachable'] = Variable<bool>(isReachable);
    if (!nullToAbsent || latencyMs != null) {
      map['latency_ms'] = Variable<int>(latencyMs);
    }
    map['average_transfer_speed_bytes_per_second'] = Variable<int>(
      averageTransferSpeedBytesPerSecond,
    );
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt);
    }
    if (!nullToAbsent || lastFailureAt != null) {
      map['last_failure_at'] = Variable<DateTime>(lastFailureAt);
    }
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DeviceAddressItemsCompanion toCompanion(bool nullToAbsent) {
    return DeviceAddressItemsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      ipAddress: Value(ipAddress),
      ipVersion: Value(ipVersion),
      port: Value(port),
      interfaceName: interfaceName == null && nullToAbsent
          ? const Value.absent()
          : Value(interfaceName),
      networkSignature: networkSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(networkSignature),
      subnetMask: subnetMask == null && nullToAbsent
          ? const Value.absent()
          : Value(subnetMask),
      gatewayAddress: gatewayAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(gatewayAddress),
      broadcastAddress: broadcastAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(broadcastAddress),
      source: Value(source),
      isReachable: Value(isReachable),
      latencyMs: latencyMs == null && nullToAbsent
          ? const Value.absent()
          : Value(latencyMs),
      averageTransferSpeedBytesPerSecond: Value(
        averageTransferSpeedBytesPerSecond,
      ),
      lastSeenAt: Value(lastSeenAt),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      lastFailureAt: lastFailureAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFailureAt),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DeviceAddressItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceAddressItem(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      ipAddress: serializer.fromJson<String>(json['ipAddress']),
      ipVersion: $DeviceAddressItemsTable.$converteripVersion.fromJson(
        serializer.fromJson<String>(json['ipVersion']),
      ),
      port: serializer.fromJson<int>(json['port']),
      interfaceName: serializer.fromJson<String?>(json['interfaceName']),
      networkSignature: serializer.fromJson<String?>(json['networkSignature']),
      subnetMask: serializer.fromJson<String?>(json['subnetMask']),
      gatewayAddress: serializer.fromJson<String?>(json['gatewayAddress']),
      broadcastAddress: serializer.fromJson<String?>(json['broadcastAddress']),
      source: $DeviceAddressItemsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      isReachable: serializer.fromJson<bool>(json['isReachable']),
      latencyMs: serializer.fromJson<int?>(json['latencyMs']),
      averageTransferSpeedBytesPerSecond: serializer.fromJson<int>(
        json['averageTransferSpeedBytesPerSecond'],
      ),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
      lastSuccessAt: serializer.fromJson<DateTime?>(json['lastSuccessAt']),
      lastFailureAt: serializer.fromJson<DateTime?>(json['lastFailureAt']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'ipAddress': serializer.toJson<String>(ipAddress),
      'ipVersion': serializer.toJson<String>(
        $DeviceAddressItemsTable.$converteripVersion.toJson(ipVersion),
      ),
      'port': serializer.toJson<int>(port),
      'interfaceName': serializer.toJson<String?>(interfaceName),
      'networkSignature': serializer.toJson<String?>(networkSignature),
      'subnetMask': serializer.toJson<String?>(subnetMask),
      'gatewayAddress': serializer.toJson<String?>(gatewayAddress),
      'broadcastAddress': serializer.toJson<String?>(broadcastAddress),
      'source': serializer.toJson<String>(
        $DeviceAddressItemsTable.$convertersource.toJson(source),
      ),
      'isReachable': serializer.toJson<bool>(isReachable),
      'latencyMs': serializer.toJson<int?>(latencyMs),
      'averageTransferSpeedBytesPerSecond': serializer.toJson<int>(
        averageTransferSpeedBytesPerSecond,
      ),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
      'lastSuccessAt': serializer.toJson<DateTime?>(lastSuccessAt),
      'lastFailureAt': serializer.toJson<DateTime?>(lastFailureAt),
      'failureReason': serializer.toJson<String?>(failureReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DeviceAddressItem copyWith({
    int? id,
    String? deviceId,
    String? ipAddress,
    DeviceIpVersion? ipVersion,
    int? port,
    Value<String?> interfaceName = const Value.absent(),
    Value<String?> networkSignature = const Value.absent(),
    Value<String?> subnetMask = const Value.absent(),
    Value<String?> gatewayAddress = const Value.absent(),
    Value<String?> broadcastAddress = const Value.absent(),
    DeviceAddressSource? source,
    bool? isReachable,
    Value<int?> latencyMs = const Value.absent(),
    int? averageTransferSpeedBytesPerSecond,
    DateTime? lastSeenAt,
    Value<DateTime?> lastSuccessAt = const Value.absent(),
    Value<DateTime?> lastFailureAt = const Value.absent(),
    Value<String?> failureReason = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DeviceAddressItem(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    ipAddress: ipAddress ?? this.ipAddress,
    ipVersion: ipVersion ?? this.ipVersion,
    port: port ?? this.port,
    interfaceName: interfaceName.present
        ? interfaceName.value
        : this.interfaceName,
    networkSignature: networkSignature.present
        ? networkSignature.value
        : this.networkSignature,
    subnetMask: subnetMask.present ? subnetMask.value : this.subnetMask,
    gatewayAddress: gatewayAddress.present
        ? gatewayAddress.value
        : this.gatewayAddress,
    broadcastAddress: broadcastAddress.present
        ? broadcastAddress.value
        : this.broadcastAddress,
    source: source ?? this.source,
    isReachable: isReachable ?? this.isReachable,
    latencyMs: latencyMs.present ? latencyMs.value : this.latencyMs,
    averageTransferSpeedBytesPerSecond:
        averageTransferSpeedBytesPerSecond ??
        this.averageTransferSpeedBytesPerSecond,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    lastFailureAt: lastFailureAt.present
        ? lastFailureAt.value
        : this.lastFailureAt,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DeviceAddressItem copyWithCompanion(DeviceAddressItemsCompanion data) {
    return DeviceAddressItem(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      ipVersion: data.ipVersion.present ? data.ipVersion.value : this.ipVersion,
      port: data.port.present ? data.port.value : this.port,
      interfaceName: data.interfaceName.present
          ? data.interfaceName.value
          : this.interfaceName,
      networkSignature: data.networkSignature.present
          ? data.networkSignature.value
          : this.networkSignature,
      subnetMask: data.subnetMask.present
          ? data.subnetMask.value
          : this.subnetMask,
      gatewayAddress: data.gatewayAddress.present
          ? data.gatewayAddress.value
          : this.gatewayAddress,
      broadcastAddress: data.broadcastAddress.present
          ? data.broadcastAddress.value
          : this.broadcastAddress,
      source: data.source.present ? data.source.value : this.source,
      isReachable: data.isReachable.present
          ? data.isReachable.value
          : this.isReachable,
      latencyMs: data.latencyMs.present ? data.latencyMs.value : this.latencyMs,
      averageTransferSpeedBytesPerSecond:
          data.averageTransferSpeedBytesPerSecond.present
          ? data.averageTransferSpeedBytesPerSecond.value
          : this.averageTransferSpeedBytesPerSecond,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      lastFailureAt: data.lastFailureAt.present
          ? data.lastFailureAt.value
          : this.lastFailureAt,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceAddressItem(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('ipVersion: $ipVersion, ')
          ..write('port: $port, ')
          ..write('interfaceName: $interfaceName, ')
          ..write('networkSignature: $networkSignature, ')
          ..write('subnetMask: $subnetMask, ')
          ..write('gatewayAddress: $gatewayAddress, ')
          ..write('broadcastAddress: $broadcastAddress, ')
          ..write('source: $source, ')
          ..write('isReachable: $isReachable, ')
          ..write('latencyMs: $latencyMs, ')
          ..write(
            'averageTransferSpeedBytesPerSecond: $averageTransferSpeedBytesPerSecond, ',
          )
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastFailureAt: $lastFailureAt, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    ipAddress,
    ipVersion,
    port,
    interfaceName,
    networkSignature,
    subnetMask,
    gatewayAddress,
    broadcastAddress,
    source,
    isReachable,
    latencyMs,
    averageTransferSpeedBytesPerSecond,
    lastSeenAt,
    lastSuccessAt,
    lastFailureAt,
    failureReason,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceAddressItem &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.ipAddress == this.ipAddress &&
          other.ipVersion == this.ipVersion &&
          other.port == this.port &&
          other.interfaceName == this.interfaceName &&
          other.networkSignature == this.networkSignature &&
          other.subnetMask == this.subnetMask &&
          other.gatewayAddress == this.gatewayAddress &&
          other.broadcastAddress == this.broadcastAddress &&
          other.source == this.source &&
          other.isReachable == this.isReachable &&
          other.latencyMs == this.latencyMs &&
          other.averageTransferSpeedBytesPerSecond ==
              this.averageTransferSpeedBytesPerSecond &&
          other.lastSeenAt == this.lastSeenAt &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.lastFailureAt == this.lastFailureAt &&
          other.failureReason == this.failureReason &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DeviceAddressItemsCompanion extends UpdateCompanion<DeviceAddressItem> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<String> ipAddress;
  final Value<DeviceIpVersion> ipVersion;
  final Value<int> port;
  final Value<String?> interfaceName;
  final Value<String?> networkSignature;
  final Value<String?> subnetMask;
  final Value<String?> gatewayAddress;
  final Value<String?> broadcastAddress;
  final Value<DeviceAddressSource> source;
  final Value<bool> isReachable;
  final Value<int?> latencyMs;
  final Value<int> averageTransferSpeedBytesPerSecond;
  final Value<DateTime> lastSeenAt;
  final Value<DateTime?> lastSuccessAt;
  final Value<DateTime?> lastFailureAt;
  final Value<String?> failureReason;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DeviceAddressItemsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.ipVersion = const Value.absent(),
    this.port = const Value.absent(),
    this.interfaceName = const Value.absent(),
    this.networkSignature = const Value.absent(),
    this.subnetMask = const Value.absent(),
    this.gatewayAddress = const Value.absent(),
    this.broadcastAddress = const Value.absent(),
    this.source = const Value.absent(),
    this.isReachable = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.averageTransferSpeedBytesPerSecond = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastFailureAt = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DeviceAddressItemsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required String ipAddress,
    required DeviceIpVersion ipVersion,
    required int port,
    this.interfaceName = const Value.absent(),
    this.networkSignature = const Value.absent(),
    this.subnetMask = const Value.absent(),
    this.gatewayAddress = const Value.absent(),
    this.broadcastAddress = const Value.absent(),
    this.source = const Value.absent(),
    this.isReachable = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.averageTransferSpeedBytesPerSecond = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastFailureAt = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : deviceId = Value(deviceId),
       ipAddress = Value(ipAddress),
       ipVersion = Value(ipVersion),
       port = Value(port);
  static Insertable<DeviceAddressItem> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? ipAddress,
    Expression<String>? ipVersion,
    Expression<int>? port,
    Expression<String>? interfaceName,
    Expression<String>? networkSignature,
    Expression<String>? subnetMask,
    Expression<String>? gatewayAddress,
    Expression<String>? broadcastAddress,
    Expression<String>? source,
    Expression<bool>? isReachable,
    Expression<int>? latencyMs,
    Expression<int>? averageTransferSpeedBytesPerSecond,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? lastSuccessAt,
    Expression<DateTime>? lastFailureAt,
    Expression<String>? failureReason,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (ipVersion != null) 'ip_version': ipVersion,
      if (port != null) 'port': port,
      if (interfaceName != null) 'interface_name': interfaceName,
      if (networkSignature != null) 'network_signature': networkSignature,
      if (subnetMask != null) 'subnet_mask': subnetMask,
      if (gatewayAddress != null) 'gateway_address': gatewayAddress,
      if (broadcastAddress != null) 'broadcast_address': broadcastAddress,
      if (source != null) 'source': source,
      if (isReachable != null) 'is_reachable': isReachable,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (averageTransferSpeedBytesPerSecond != null)
        'average_transfer_speed_bytes_per_second':
            averageTransferSpeedBytesPerSecond,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (lastFailureAt != null) 'last_failure_at': lastFailureAt,
      if (failureReason != null) 'failure_reason': failureReason,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DeviceAddressItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<String>? ipAddress,
    Value<DeviceIpVersion>? ipVersion,
    Value<int>? port,
    Value<String?>? interfaceName,
    Value<String?>? networkSignature,
    Value<String?>? subnetMask,
    Value<String?>? gatewayAddress,
    Value<String?>? broadcastAddress,
    Value<DeviceAddressSource>? source,
    Value<bool>? isReachable,
    Value<int?>? latencyMs,
    Value<int>? averageTransferSpeedBytesPerSecond,
    Value<DateTime>? lastSeenAt,
    Value<DateTime?>? lastSuccessAt,
    Value<DateTime?>? lastFailureAt,
    Value<String?>? failureReason,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DeviceAddressItemsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
      ipVersion: ipVersion ?? this.ipVersion,
      port: port ?? this.port,
      interfaceName: interfaceName ?? this.interfaceName,
      networkSignature: networkSignature ?? this.networkSignature,
      subnetMask: subnetMask ?? this.subnetMask,
      gatewayAddress: gatewayAddress ?? this.gatewayAddress,
      broadcastAddress: broadcastAddress ?? this.broadcastAddress,
      source: source ?? this.source,
      isReachable: isReachable ?? this.isReachable,
      latencyMs: latencyMs ?? this.latencyMs,
      averageTransferSpeedBytesPerSecond:
          averageTransferSpeedBytesPerSecond ??
          this.averageTransferSpeedBytesPerSecond,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastFailureAt: lastFailureAt ?? this.lastFailureAt,
      failureReason: failureReason ?? this.failureReason,
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (ipVersion.present) {
      map['ip_version'] = Variable<String>(
        $DeviceAddressItemsTable.$converteripVersion.toSql(ipVersion.value),
      );
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (interfaceName.present) {
      map['interface_name'] = Variable<String>(interfaceName.value);
    }
    if (networkSignature.present) {
      map['network_signature'] = Variable<String>(networkSignature.value);
    }
    if (subnetMask.present) {
      map['subnet_mask'] = Variable<String>(subnetMask.value);
    }
    if (gatewayAddress.present) {
      map['gateway_address'] = Variable<String>(gatewayAddress.value);
    }
    if (broadcastAddress.present) {
      map['broadcast_address'] = Variable<String>(broadcastAddress.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $DeviceAddressItemsTable.$convertersource.toSql(source.value),
      );
    }
    if (isReachable.present) {
      map['is_reachable'] = Variable<bool>(isReachable.value);
    }
    if (latencyMs.present) {
      map['latency_ms'] = Variable<int>(latencyMs.value);
    }
    if (averageTransferSpeedBytesPerSecond.present) {
      map['average_transfer_speed_bytes_per_second'] = Variable<int>(
        averageTransferSpeedBytesPerSecond.value,
      );
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt.value);
    }
    if (lastFailureAt.present) {
      map['last_failure_at'] = Variable<DateTime>(lastFailureAt.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
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
    return (StringBuffer('DeviceAddressItemsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('ipVersion: $ipVersion, ')
          ..write('port: $port, ')
          ..write('interfaceName: $interfaceName, ')
          ..write('networkSignature: $networkSignature, ')
          ..write('subnetMask: $subnetMask, ')
          ..write('gatewayAddress: $gatewayAddress, ')
          ..write('broadcastAddress: $broadcastAddress, ')
          ..write('source: $source, ')
          ..write('isReachable: $isReachable, ')
          ..write('latencyMs: $latencyMs, ')
          ..write(
            'averageTransferSpeedBytesPerSecond: $averageTransferSpeedBytesPerSecond, ',
          )
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastFailureAt: $lastFailureAt, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ConnectionSessionItemsTable extends ConnectionSessionItems
    with TableInfo<$ConnectionSessionItemsTable, ConnectionSessionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConnectionSessionItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES device_items (device_id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _deviceAddressIdMeta = const VerificationMeta(
    'deviceAddressId',
  );
  @override
  late final GeneratedColumn<int> deviceAddressId = GeneratedColumn<int>(
    'device_address_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES device_address_items (id) ON UPDATE CASCADE ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ConnectionSessionState, String>
  state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ConnectionSessionState>(
        $ConnectionSessionItemsTable.$converterstate,
      );
  static const VerificationMeta _protocolVersionMeta = const VerificationMeta(
    'protocolVersion',
  );
  @override
  late final GeneratedColumn<int> protocolVersion = GeneratedColumn<int>(
    'protocol_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _connectedAtMeta = const VerificationMeta(
    'connectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> connectedAt = GeneratedColumn<DateTime>(
    'connected_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastHeartbeatAtMeta = const VerificationMeta(
    'lastHeartbeatAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastHeartbeatAt =
      GeneratedColumn<DateTime>(
        'last_heartbeat_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _disconnectedAtMeta = const VerificationMeta(
    'disconnectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> disconnectedAt =
      GeneratedColumn<DateTime>(
        'disconnected_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    deviceId,
    deviceAddressId,
    state,
    protocolVersion,
    connectedAt,
    lastHeartbeatAt,
    disconnectedAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connection_session_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConnectionSessionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_address_id')) {
      context.handle(
        _deviceAddressIdMeta,
        deviceAddressId.isAcceptableOrUnknown(
          data['device_address_id']!,
          _deviceAddressIdMeta,
        ),
      );
    }
    if (data.containsKey('protocol_version')) {
      context.handle(
        _protocolVersionMeta,
        protocolVersion.isAcceptableOrUnknown(
          data['protocol_version']!,
          _protocolVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_protocolVersionMeta);
    }
    if (data.containsKey('connected_at')) {
      context.handle(
        _connectedAtMeta,
        connectedAt.isAcceptableOrUnknown(
          data['connected_at']!,
          _connectedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_heartbeat_at')) {
      context.handle(
        _lastHeartbeatAtMeta,
        lastHeartbeatAt.isAcceptableOrUnknown(
          data['last_heartbeat_at']!,
          _lastHeartbeatAtMeta,
        ),
      );
    }
    if (data.containsKey('disconnected_at')) {
      context.handle(
        _disconnectedAtMeta,
        disconnectedAt.isAcceptableOrUnknown(
          data['disconnected_at']!,
          _disconnectedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConnectionSessionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConnectionSessionItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceAddressId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_address_id'],
      ),
      state: $ConnectionSessionItemsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      protocolVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protocol_version'],
      )!,
      connectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}connected_at'],
      ),
      lastHeartbeatAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_heartbeat_at'],
      ),
      disconnectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}disconnected_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $ConnectionSessionItemsTable createAlias(String alias) {
    return $ConnectionSessionItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ConnectionSessionState, String, String>
  $converterstate = const EnumNameConverter<ConnectionSessionState>(
    ConnectionSessionState.values,
  );
}

class ConnectionSessionItem extends DataClass
    implements Insertable<ConnectionSessionItem> {
  final int id;
  final String sessionId;
  final String deviceId;
  final int? deviceAddressId;
  final ConnectionSessionState state;
  final int protocolVersion;
  final DateTime? connectedAt;
  final DateTime? lastHeartbeatAt;
  final DateTime? disconnectedAt;
  final String? lastError;
  const ConnectionSessionItem({
    required this.id,
    required this.sessionId,
    required this.deviceId,
    this.deviceAddressId,
    required this.state,
    required this.protocolVersion,
    this.connectedAt,
    this.lastHeartbeatAt,
    this.disconnectedAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deviceAddressId != null) {
      map['device_address_id'] = Variable<int>(deviceAddressId);
    }
    {
      map['state'] = Variable<String>(
        $ConnectionSessionItemsTable.$converterstate.toSql(state),
      );
    }
    map['protocol_version'] = Variable<int>(protocolVersion);
    if (!nullToAbsent || connectedAt != null) {
      map['connected_at'] = Variable<DateTime>(connectedAt);
    }
    if (!nullToAbsent || lastHeartbeatAt != null) {
      map['last_heartbeat_at'] = Variable<DateTime>(lastHeartbeatAt);
    }
    if (!nullToAbsent || disconnectedAt != null) {
      map['disconnected_at'] = Variable<DateTime>(disconnectedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  ConnectionSessionItemsCompanion toCompanion(bool nullToAbsent) {
    return ConnectionSessionItemsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      deviceId: Value(deviceId),
      deviceAddressId: deviceAddressId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceAddressId),
      state: Value(state),
      protocolVersion: Value(protocolVersion),
      connectedAt: connectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(connectedAt),
      lastHeartbeatAt: lastHeartbeatAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastHeartbeatAt),
      disconnectedAt: disconnectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(disconnectedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory ConnectionSessionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConnectionSessionItem(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceAddressId: serializer.fromJson<int?>(json['deviceAddressId']),
      state: $ConnectionSessionItemsTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      protocolVersion: serializer.fromJson<int>(json['protocolVersion']),
      connectedAt: serializer.fromJson<DateTime?>(json['connectedAt']),
      lastHeartbeatAt: serializer.fromJson<DateTime?>(json['lastHeartbeatAt']),
      disconnectedAt: serializer.fromJson<DateTime?>(json['disconnectedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceAddressId': serializer.toJson<int?>(deviceAddressId),
      'state': serializer.toJson<String>(
        $ConnectionSessionItemsTable.$converterstate.toJson(state),
      ),
      'protocolVersion': serializer.toJson<int>(protocolVersion),
      'connectedAt': serializer.toJson<DateTime?>(connectedAt),
      'lastHeartbeatAt': serializer.toJson<DateTime?>(lastHeartbeatAt),
      'disconnectedAt': serializer.toJson<DateTime?>(disconnectedAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  ConnectionSessionItem copyWith({
    int? id,
    String? sessionId,
    String? deviceId,
    Value<int?> deviceAddressId = const Value.absent(),
    ConnectionSessionState? state,
    int? protocolVersion,
    Value<DateTime?> connectedAt = const Value.absent(),
    Value<DateTime?> lastHeartbeatAt = const Value.absent(),
    Value<DateTime?> disconnectedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => ConnectionSessionItem(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    deviceId: deviceId ?? this.deviceId,
    deviceAddressId: deviceAddressId.present
        ? deviceAddressId.value
        : this.deviceAddressId,
    state: state ?? this.state,
    protocolVersion: protocolVersion ?? this.protocolVersion,
    connectedAt: connectedAt.present ? connectedAt.value : this.connectedAt,
    lastHeartbeatAt: lastHeartbeatAt.present
        ? lastHeartbeatAt.value
        : this.lastHeartbeatAt,
    disconnectedAt: disconnectedAt.present
        ? disconnectedAt.value
        : this.disconnectedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  ConnectionSessionItem copyWithCompanion(
    ConnectionSessionItemsCompanion data,
  ) {
    return ConnectionSessionItem(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceAddressId: data.deviceAddressId.present
          ? data.deviceAddressId.value
          : this.deviceAddressId,
      state: data.state.present ? data.state.value : this.state,
      protocolVersion: data.protocolVersion.present
          ? data.protocolVersion.value
          : this.protocolVersion,
      connectedAt: data.connectedAt.present
          ? data.connectedAt.value
          : this.connectedAt,
      lastHeartbeatAt: data.lastHeartbeatAt.present
          ? data.lastHeartbeatAt.value
          : this.lastHeartbeatAt,
      disconnectedAt: data.disconnectedAt.present
          ? data.disconnectedAt.value
          : this.disconnectedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionSessionItem(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceAddressId: $deviceAddressId, ')
          ..write('state: $state, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('lastHeartbeatAt: $lastHeartbeatAt, ')
          ..write('disconnectedAt: $disconnectedAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    deviceId,
    deviceAddressId,
    state,
    protocolVersion,
    connectedAt,
    lastHeartbeatAt,
    disconnectedAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConnectionSessionItem &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.deviceId == this.deviceId &&
          other.deviceAddressId == this.deviceAddressId &&
          other.state == this.state &&
          other.protocolVersion == this.protocolVersion &&
          other.connectedAt == this.connectedAt &&
          other.lastHeartbeatAt == this.lastHeartbeatAt &&
          other.disconnectedAt == this.disconnectedAt &&
          other.lastError == this.lastError);
}

class ConnectionSessionItemsCompanion
    extends UpdateCompanion<ConnectionSessionItem> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<String> deviceId;
  final Value<int?> deviceAddressId;
  final Value<ConnectionSessionState> state;
  final Value<int> protocolVersion;
  final Value<DateTime?> connectedAt;
  final Value<DateTime?> lastHeartbeatAt;
  final Value<DateTime?> disconnectedAt;
  final Value<String?> lastError;
  const ConnectionSessionItemsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceAddressId = const Value.absent(),
    this.state = const Value.absent(),
    this.protocolVersion = const Value.absent(),
    this.connectedAt = const Value.absent(),
    this.lastHeartbeatAt = const Value.absent(),
    this.disconnectedAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  ConnectionSessionItemsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required String deviceId,
    this.deviceAddressId = const Value.absent(),
    required ConnectionSessionState state,
    required int protocolVersion,
    this.connectedAt = const Value.absent(),
    this.lastHeartbeatAt = const Value.absent(),
    this.disconnectedAt = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : sessionId = Value(sessionId),
       deviceId = Value(deviceId),
       state = Value(state),
       protocolVersion = Value(protocolVersion);
  static Insertable<ConnectionSessionItem> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<String>? deviceId,
    Expression<int>? deviceAddressId,
    Expression<String>? state,
    Expression<int>? protocolVersion,
    Expression<DateTime>? connectedAt,
    Expression<DateTime>? lastHeartbeatAt,
    Expression<DateTime>? disconnectedAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceAddressId != null) 'device_address_id': deviceAddressId,
      if (state != null) 'state': state,
      if (protocolVersion != null) 'protocol_version': protocolVersion,
      if (connectedAt != null) 'connected_at': connectedAt,
      if (lastHeartbeatAt != null) 'last_heartbeat_at': lastHeartbeatAt,
      if (disconnectedAt != null) 'disconnected_at': disconnectedAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  ConnectionSessionItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<String>? deviceId,
    Value<int?>? deviceAddressId,
    Value<ConnectionSessionState>? state,
    Value<int>? protocolVersion,
    Value<DateTime?>? connectedAt,
    Value<DateTime?>? lastHeartbeatAt,
    Value<DateTime?>? disconnectedAt,
    Value<String?>? lastError,
  }) {
    return ConnectionSessionItemsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      deviceId: deviceId ?? this.deviceId,
      deviceAddressId: deviceAddressId ?? this.deviceAddressId,
      state: state ?? this.state,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      connectedAt: connectedAt ?? this.connectedAt,
      lastHeartbeatAt: lastHeartbeatAt ?? this.lastHeartbeatAt,
      disconnectedAt: disconnectedAt ?? this.disconnectedAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceAddressId.present) {
      map['device_address_id'] = Variable<int>(deviceAddressId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $ConnectionSessionItemsTable.$converterstate.toSql(state.value),
      );
    }
    if (protocolVersion.present) {
      map['protocol_version'] = Variable<int>(protocolVersion.value);
    }
    if (connectedAt.present) {
      map['connected_at'] = Variable<DateTime>(connectedAt.value);
    }
    if (lastHeartbeatAt.present) {
      map['last_heartbeat_at'] = Variable<DateTime>(lastHeartbeatAt.value);
    }
    if (disconnectedAt.present) {
      map['disconnected_at'] = Variable<DateTime>(disconnectedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionSessionItemsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceAddressId: $deviceAddressId, ')
          ..write('state: $state, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('lastHeartbeatAt: $lastHeartbeatAt, ')
          ..write('disconnectedAt: $disconnectedAt, ')
          ..write('lastError: $lastError')
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
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
  late final GeneratedColumnWithTypeConverter<MessageType, String> messageType =
      GeneratedColumn<String>(
        'message_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => MessageType.text.name,
      ).withConverter<MessageType>($MessageItemsTable.$convertermessageType);
  @override
  late final GeneratedColumnWithTypeConverter<MessageSendStatus, String>
  sendStatus = GeneratedColumn<String>(
    'send_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => MessageSendStatus.pending.name,
  ).withConverter<MessageSendStatus>($MessageItemsTable.$convertersendStatus);
  static const VerificationMeta _localMessageIdMeta = const VerificationMeta(
    'localMessageId',
  );
  @override
  late final GeneratedColumn<String> localMessageId = GeneratedColumn<String>(
    'local_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteMessageIdMeta = const VerificationMeta(
    'remoteMessageId',
  );
  @override
  late final GeneratedColumn<String> remoteMessageId = GeneratedColumn<String>(
    'remote_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteDeviceId,
    textContent,
    createdAt,
    updatedAt,
    direction,
    messageType,
    sendStatus,
    localMessageId,
    remoteMessageId,
    errorMessage,
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('local_message_id')) {
      context.handle(
        _localMessageIdMeta,
        localMessageId.isAcceptableOrUnknown(
          data['local_message_id']!,
          _localMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('remote_message_id')) {
      context.handle(
        _remoteMessageIdMeta,
        remoteMessageId.isAcceptableOrUnknown(
          data['remote_message_id']!,
          _remoteMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
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
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      direction: $MessageItemsTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      messageType: $MessageItemsTable.$convertermessageType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}message_type'],
        )!,
      ),
      sendStatus: $MessageItemsTable.$convertersendStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}send_status'],
        )!,
      ),
      localMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_message_id'],
      ),
      remoteMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_message_id'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
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
  static JsonTypeConverter2<MessageType, String, String> $convertermessageType =
      const EnumNameConverter<MessageType>(MessageType.values);
  static JsonTypeConverter2<MessageSendStatus, String, String>
  $convertersendStatus = const EnumNameConverter<MessageSendStatus>(
    MessageSendStatus.values,
  );
}

class MessageItem extends DataClass implements Insertable<MessageItem> {
  final int id;
  final String remoteDeviceId;
  final String? textContent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MessageDirection direction;
  final MessageType messageType;
  final MessageSendStatus sendStatus;
  final String? localMessageId;
  final String? remoteMessageId;
  final String? errorMessage;
  const MessageItem({
    required this.id,
    required this.remoteDeviceId,
    this.textContent,
    required this.createdAt,
    required this.updatedAt,
    required this.direction,
    required this.messageType,
    required this.sendStatus,
    this.localMessageId,
    this.remoteMessageId,
    this.errorMessage,
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
    map['updated_at'] = Variable<DateTime>(updatedAt);
    {
      map['direction'] = Variable<String>(
        $MessageItemsTable.$converterdirection.toSql(direction),
      );
    }
    {
      map['message_type'] = Variable<String>(
        $MessageItemsTable.$convertermessageType.toSql(messageType),
      );
    }
    {
      map['send_status'] = Variable<String>(
        $MessageItemsTable.$convertersendStatus.toSql(sendStatus),
      );
    }
    if (!nullToAbsent || localMessageId != null) {
      map['local_message_id'] = Variable<String>(localMessageId);
    }
    if (!nullToAbsent || remoteMessageId != null) {
      map['remote_message_id'] = Variable<String>(remoteMessageId);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
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
      updatedAt: Value(updatedAt),
      direction: Value(direction),
      messageType: Value(messageType),
      sendStatus: Value(sendStatus),
      localMessageId: localMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(localMessageId),
      remoteMessageId: remoteMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteMessageId),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
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
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      direction: $MessageItemsTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      messageType: $MessageItemsTable.$convertermessageType.fromJson(
        serializer.fromJson<String>(json['messageType']),
      ),
      sendStatus: $MessageItemsTable.$convertersendStatus.fromJson(
        serializer.fromJson<String>(json['sendStatus']),
      ),
      localMessageId: serializer.fromJson<String?>(json['localMessageId']),
      remoteMessageId: serializer.fromJson<String?>(json['remoteMessageId']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
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
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'direction': serializer.toJson<String>(
        $MessageItemsTable.$converterdirection.toJson(direction),
      ),
      'messageType': serializer.toJson<String>(
        $MessageItemsTable.$convertermessageType.toJson(messageType),
      ),
      'sendStatus': serializer.toJson<String>(
        $MessageItemsTable.$convertersendStatus.toJson(sendStatus),
      ),
      'localMessageId': serializer.toJson<String?>(localMessageId),
      'remoteMessageId': serializer.toJson<String?>(remoteMessageId),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  MessageItem copyWith({
    int? id,
    String? remoteDeviceId,
    Value<String?> textContent = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    MessageDirection? direction,
    MessageType? messageType,
    MessageSendStatus? sendStatus,
    Value<String?> localMessageId = const Value.absent(),
    Value<String?> remoteMessageId = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
  }) => MessageItem(
    id: id ?? this.id,
    remoteDeviceId: remoteDeviceId ?? this.remoteDeviceId,
    textContent: textContent.present ? textContent.value : this.textContent,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    direction: direction ?? this.direction,
    messageType: messageType ?? this.messageType,
    sendStatus: sendStatus ?? this.sendStatus,
    localMessageId: localMessageId.present
        ? localMessageId.value
        : this.localMessageId,
    remoteMessageId: remoteMessageId.present
        ? remoteMessageId.value
        : this.remoteMessageId,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
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
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      direction: data.direction.present ? data.direction.value : this.direction,
      messageType: data.messageType.present
          ? data.messageType.value
          : this.messageType,
      sendStatus: data.sendStatus.present
          ? data.sendStatus.value
          : this.sendStatus,
      localMessageId: data.localMessageId.present
          ? data.localMessageId.value
          : this.localMessageId,
      remoteMessageId: data.remoteMessageId.present
          ? data.remoteMessageId.value
          : this.remoteMessageId,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageItem(')
          ..write('id: $id, ')
          ..write('remoteDeviceId: $remoteDeviceId, ')
          ..write('textContent: $textContent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('direction: $direction, ')
          ..write('messageType: $messageType, ')
          ..write('sendStatus: $sendStatus, ')
          ..write('localMessageId: $localMessageId, ')
          ..write('remoteMessageId: $remoteMessageId, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteDeviceId,
    textContent,
    createdAt,
    updatedAt,
    direction,
    messageType,
    sendStatus,
    localMessageId,
    remoteMessageId,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageItem &&
          other.id == this.id &&
          other.remoteDeviceId == this.remoteDeviceId &&
          other.textContent == this.textContent &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.direction == this.direction &&
          other.messageType == this.messageType &&
          other.sendStatus == this.sendStatus &&
          other.localMessageId == this.localMessageId &&
          other.remoteMessageId == this.remoteMessageId &&
          other.errorMessage == this.errorMessage);
}

class MessageItemsCompanion extends UpdateCompanion<MessageItem> {
  final Value<int> id;
  final Value<String> remoteDeviceId;
  final Value<String?> textContent;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<MessageDirection> direction;
  final Value<MessageType> messageType;
  final Value<MessageSendStatus> sendStatus;
  final Value<String?> localMessageId;
  final Value<String?> remoteMessageId;
  final Value<String?> errorMessage;
  const MessageItemsCompanion({
    this.id = const Value.absent(),
    this.remoteDeviceId = const Value.absent(),
    this.textContent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.direction = const Value.absent(),
    this.messageType = const Value.absent(),
    this.sendStatus = const Value.absent(),
    this.localMessageId = const Value.absent(),
    this.remoteMessageId = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  MessageItemsCompanion.insert({
    this.id = const Value.absent(),
    required String remoteDeviceId,
    this.textContent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required MessageDirection direction,
    this.messageType = const Value.absent(),
    this.sendStatus = const Value.absent(),
    this.localMessageId = const Value.absent(),
    this.remoteMessageId = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : remoteDeviceId = Value(remoteDeviceId),
       direction = Value(direction);
  static Insertable<MessageItem> custom({
    Expression<int>? id,
    Expression<String>? remoteDeviceId,
    Expression<String>? textContent,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? direction,
    Expression<String>? messageType,
    Expression<String>? sendStatus,
    Expression<String>? localMessageId,
    Expression<String>? remoteMessageId,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteDeviceId != null) 'remote_device_id': remoteDeviceId,
      if (textContent != null) 'text_content': textContent,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (direction != null) 'direction': direction,
      if (messageType != null) 'message_type': messageType,
      if (sendStatus != null) 'send_status': sendStatus,
      if (localMessageId != null) 'local_message_id': localMessageId,
      if (remoteMessageId != null) 'remote_message_id': remoteMessageId,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  MessageItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? remoteDeviceId,
    Value<String?>? textContent,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<MessageDirection>? direction,
    Value<MessageType>? messageType,
    Value<MessageSendStatus>? sendStatus,
    Value<String?>? localMessageId,
    Value<String?>? remoteMessageId,
    Value<String?>? errorMessage,
  }) {
    return MessageItemsCompanion(
      id: id ?? this.id,
      remoteDeviceId: remoteDeviceId ?? this.remoteDeviceId,
      textContent: textContent ?? this.textContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      direction: direction ?? this.direction,
      messageType: messageType ?? this.messageType,
      sendStatus: sendStatus ?? this.sendStatus,
      localMessageId: localMessageId ?? this.localMessageId,
      remoteMessageId: remoteMessageId ?? this.remoteMessageId,
      errorMessage: errorMessage ?? this.errorMessage,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $MessageItemsTable.$converterdirection.toSql(direction.value),
      );
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(
        $MessageItemsTable.$convertermessageType.toSql(messageType.value),
      );
    }
    if (sendStatus.present) {
      map['send_status'] = Variable<String>(
        $MessageItemsTable.$convertersendStatus.toSql(sendStatus.value),
      );
    }
    if (localMessageId.present) {
      map['local_message_id'] = Variable<String>(localMessageId.value);
    }
    if (remoteMessageId.present) {
      map['remote_message_id'] = Variable<String>(remoteMessageId.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
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
          ..write('updatedAt: $updatedAt, ')
          ..write('direction: $direction, ')
          ..write('messageType: $messageType, ')
          ..write('sendStatus: $sendStatus, ')
          ..write('localMessageId: $localMessageId, ')
          ..write('remoteMessageId: $remoteMessageId, ')
          ..write('errorMessage: $errorMessage')
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
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
    'attachment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _transferredBytesMeta = const VerificationMeta(
    'transferredBytes',
  );
  @override
  late final GeneratedColumn<int> transferredBytes = GeneratedColumn<int>(
    'transferred_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _checksumSha256Meta = const VerificationMeta(
    'checksumSha256',
  );
  @override
  late final GeneratedColumn<String> checksumSha256 = GeneratedColumn<String>(
    'checksum_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<
    MessageAttachmentTransferStatus,
    String
  >
  transferStatus =
      GeneratedColumn<String>(
        'transfer_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => MessageAttachmentTransferStatus.pending.name,
      ).withConverter<MessageAttachmentTransferStatus>(
        $MessageAttachmentItemsTable.$convertertransferStatus,
      );
  static const VerificationMeta _transferTaskIdMeta = const VerificationMeta(
    'transferTaskId',
  );
  @override
  late final GeneratedColumn<String> transferTaskId = GeneratedColumn<String>(
    'transfer_task_id',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    saveStatus,
    filePath,
    downloadProgress,
    attachmentId,
    fileName,
    mimeType,
    totalBytes,
    transferredBytes,
    checksumSha256,
    thumbnailPath,
    transferStatus,
    transferTaskId,
    createdAt,
    updatedAt,
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
    if (data.containsKey('attachment_id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(
          data['attachment_id']!,
          _attachmentIdMeta,
        ),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('transferred_bytes')) {
      context.handle(
        _transferredBytesMeta,
        transferredBytes.isAcceptableOrUnknown(
          data['transferred_bytes']!,
          _transferredBytesMeta,
        ),
      );
    }
    if (data.containsKey('checksum_sha256')) {
      context.handle(
        _checksumSha256Meta,
        checksumSha256.isAcceptableOrUnknown(
          data['checksum_sha256']!,
          _checksumSha256Meta,
        ),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('transfer_task_id')) {
      context.handle(
        _transferTaskIdMeta,
        transferTaskId.isAcceptableOrUnknown(
          data['transfer_task_id']!,
          _transferTaskIdMeta,
        ),
      );
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
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_id'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      )!,
      transferredBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transferred_bytes'],
      )!,
      checksumSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum_sha256'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      transferStatus: $MessageAttachmentItemsTable.$convertertransferStatus
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}transfer_status'],
            )!,
          ),
      transferTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_task_id'],
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
  $MessageAttachmentItemsTable createAlias(String alias) {
    return $MessageAttachmentItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageAttachmentSaveStatus, String, String>
  $convertersaveStatus = const EnumNameConverter<MessageAttachmentSaveStatus>(
    MessageAttachmentSaveStatus.values,
  );
  static JsonTypeConverter2<MessageAttachmentTransferStatus, String, String>
  $convertertransferStatus =
      const EnumNameConverter<MessageAttachmentTransferStatus>(
        MessageAttachmentTransferStatus.values,
      );
}

class MessageAttachmentItem extends DataClass
    implements Insertable<MessageAttachmentItem> {
  final int id;
  final int messageId;
  final MessageAttachmentSaveStatus saveStatus;
  final String? filePath;
  final int downloadProgress;
  final String? attachmentId;
  final String? fileName;
  final String? mimeType;
  final int totalBytes;
  final int transferredBytes;
  final String? checksumSha256;
  final String? thumbnailPath;
  final MessageAttachmentTransferStatus transferStatus;
  final String? transferTaskId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MessageAttachmentItem({
    required this.id,
    required this.messageId,
    required this.saveStatus,
    this.filePath,
    required this.downloadProgress,
    this.attachmentId,
    this.fileName,
    this.mimeType,
    required this.totalBytes,
    required this.transferredBytes,
    this.checksumSha256,
    this.thumbnailPath,
    required this.transferStatus,
    this.transferTaskId,
    required this.createdAt,
    required this.updatedAt,
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
    if (!nullToAbsent || attachmentId != null) {
      map['attachment_id'] = Variable<String>(attachmentId);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    map['total_bytes'] = Variable<int>(totalBytes);
    map['transferred_bytes'] = Variable<int>(transferredBytes);
    if (!nullToAbsent || checksumSha256 != null) {
      map['checksum_sha256'] = Variable<String>(checksumSha256);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    {
      map['transfer_status'] = Variable<String>(
        $MessageAttachmentItemsTable.$convertertransferStatus.toSql(
          transferStatus,
        ),
      );
    }
    if (!nullToAbsent || transferTaskId != null) {
      map['transfer_task_id'] = Variable<String>(transferTaskId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
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
      attachmentId: attachmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentId),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      totalBytes: Value(totalBytes),
      transferredBytes: Value(transferredBytes),
      checksumSha256: checksumSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(checksumSha256),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      transferStatus: Value(transferStatus),
      transferTaskId: transferTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferTaskId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
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
      attachmentId: serializer.fromJson<String?>(json['attachmentId']),
      fileName: serializer.fromJson<String?>(json['fileName']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      totalBytes: serializer.fromJson<int>(json['totalBytes']),
      transferredBytes: serializer.fromJson<int>(json['transferredBytes']),
      checksumSha256: serializer.fromJson<String?>(json['checksumSha256']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      transferStatus: $MessageAttachmentItemsTable.$convertertransferStatus
          .fromJson(serializer.fromJson<String>(json['transferStatus'])),
      transferTaskId: serializer.fromJson<String?>(json['transferTaskId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
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
      'attachmentId': serializer.toJson<String?>(attachmentId),
      'fileName': serializer.toJson<String?>(fileName),
      'mimeType': serializer.toJson<String?>(mimeType),
      'totalBytes': serializer.toJson<int>(totalBytes),
      'transferredBytes': serializer.toJson<int>(transferredBytes),
      'checksumSha256': serializer.toJson<String?>(checksumSha256),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'transferStatus': serializer.toJson<String>(
        $MessageAttachmentItemsTable.$convertertransferStatus.toJson(
          transferStatus,
        ),
      ),
      'transferTaskId': serializer.toJson<String?>(transferTaskId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MessageAttachmentItem copyWith({
    int? id,
    int? messageId,
    MessageAttachmentSaveStatus? saveStatus,
    Value<String?> filePath = const Value.absent(),
    int? downloadProgress,
    Value<String?> attachmentId = const Value.absent(),
    Value<String?> fileName = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
    int? totalBytes,
    int? transferredBytes,
    Value<String?> checksumSha256 = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    MessageAttachmentTransferStatus? transferStatus,
    Value<String?> transferTaskId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MessageAttachmentItem(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    saveStatus: saveStatus ?? this.saveStatus,
    filePath: filePath.present ? filePath.value : this.filePath,
    downloadProgress: downloadProgress ?? this.downloadProgress,
    attachmentId: attachmentId.present ? attachmentId.value : this.attachmentId,
    fileName: fileName.present ? fileName.value : this.fileName,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    totalBytes: totalBytes ?? this.totalBytes,
    transferredBytes: transferredBytes ?? this.transferredBytes,
    checksumSha256: checksumSha256.present
        ? checksumSha256.value
        : this.checksumSha256,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    transferStatus: transferStatus ?? this.transferStatus,
    transferTaskId: transferTaskId.present
        ? transferTaskId.value
        : this.transferTaskId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
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
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      transferredBytes: data.transferredBytes.present
          ? data.transferredBytes.value
          : this.transferredBytes,
      checksumSha256: data.checksumSha256.present
          ? data.checksumSha256.value
          : this.checksumSha256,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      transferStatus: data.transferStatus.present
          ? data.transferStatus.value
          : this.transferStatus,
      transferTaskId: data.transferTaskId.present
          ? data.transferTaskId.value
          : this.transferTaskId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageAttachmentItem(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('saveStatus: $saveStatus, ')
          ..write('filePath: $filePath, ')
          ..write('downloadProgress: $downloadProgress, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('transferredBytes: $transferredBytes, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('transferStatus: $transferStatus, ')
          ..write('transferTaskId: $transferTaskId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    saveStatus,
    filePath,
    downloadProgress,
    attachmentId,
    fileName,
    mimeType,
    totalBytes,
    transferredBytes,
    checksumSha256,
    thumbnailPath,
    transferStatus,
    transferTaskId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageAttachmentItem &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.saveStatus == this.saveStatus &&
          other.filePath == this.filePath &&
          other.downloadProgress == this.downloadProgress &&
          other.attachmentId == this.attachmentId &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.totalBytes == this.totalBytes &&
          other.transferredBytes == this.transferredBytes &&
          other.checksumSha256 == this.checksumSha256 &&
          other.thumbnailPath == this.thumbnailPath &&
          other.transferStatus == this.transferStatus &&
          other.transferTaskId == this.transferTaskId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MessageAttachmentItemsCompanion
    extends UpdateCompanion<MessageAttachmentItem> {
  final Value<int> id;
  final Value<int> messageId;
  final Value<MessageAttachmentSaveStatus> saveStatus;
  final Value<String?> filePath;
  final Value<int> downloadProgress;
  final Value<String?> attachmentId;
  final Value<String?> fileName;
  final Value<String?> mimeType;
  final Value<int> totalBytes;
  final Value<int> transferredBytes;
  final Value<String?> checksumSha256;
  final Value<String?> thumbnailPath;
  final Value<MessageAttachmentTransferStatus> transferStatus;
  final Value<String?> transferTaskId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MessageAttachmentItemsCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.saveStatus = const Value.absent(),
    this.filePath = const Value.absent(),
    this.downloadProgress = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.transferredBytes = const Value.absent(),
    this.checksumSha256 = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.transferStatus = const Value.absent(),
    this.transferTaskId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MessageAttachmentItemsCompanion.insert({
    this.id = const Value.absent(),
    required int messageId,
    this.saveStatus = const Value.absent(),
    this.filePath = const Value.absent(),
    this.downloadProgress = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.transferredBytes = const Value.absent(),
    this.checksumSha256 = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.transferStatus = const Value.absent(),
    this.transferTaskId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : messageId = Value(messageId);
  static Insertable<MessageAttachmentItem> custom({
    Expression<int>? id,
    Expression<int>? messageId,
    Expression<String>? saveStatus,
    Expression<String>? filePath,
    Expression<int>? downloadProgress,
    Expression<String>? attachmentId,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? totalBytes,
    Expression<int>? transferredBytes,
    Expression<String>? checksumSha256,
    Expression<String>? thumbnailPath,
    Expression<String>? transferStatus,
    Expression<String>? transferTaskId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (saveStatus != null) 'save_status': saveStatus,
      if (filePath != null) 'file_path': filePath,
      if (downloadProgress != null) 'download_progress': downloadProgress,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (transferredBytes != null) 'transferred_bytes': transferredBytes,
      if (checksumSha256 != null) 'checksum_sha256': checksumSha256,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (transferStatus != null) 'transfer_status': transferStatus,
      if (transferTaskId != null) 'transfer_task_id': transferTaskId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MessageAttachmentItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? messageId,
    Value<MessageAttachmentSaveStatus>? saveStatus,
    Value<String?>? filePath,
    Value<int>? downloadProgress,
    Value<String?>? attachmentId,
    Value<String?>? fileName,
    Value<String?>? mimeType,
    Value<int>? totalBytes,
    Value<int>? transferredBytes,
    Value<String?>? checksumSha256,
    Value<String?>? thumbnailPath,
    Value<MessageAttachmentTransferStatus>? transferStatus,
    Value<String?>? transferTaskId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MessageAttachmentItemsCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      saveStatus: saveStatus ?? this.saveStatus,
      filePath: filePath ?? this.filePath,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      attachmentId: attachmentId ?? this.attachmentId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      totalBytes: totalBytes ?? this.totalBytes,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      transferStatus: transferStatus ?? this.transferStatus,
      transferTaskId: transferTaskId ?? this.transferTaskId,
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
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(attachmentId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (transferredBytes.present) {
      map['transferred_bytes'] = Variable<int>(transferredBytes.value);
    }
    if (checksumSha256.present) {
      map['checksum_sha256'] = Variable<String>(checksumSha256.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (transferStatus.present) {
      map['transfer_status'] = Variable<String>(
        $MessageAttachmentItemsTable.$convertertransferStatus.toSql(
          transferStatus.value,
        ),
      );
    }
    if (transferTaskId.present) {
      map['transfer_task_id'] = Variable<String>(transferTaskId.value);
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
    return (StringBuffer('MessageAttachmentItemsCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('saveStatus: $saveStatus, ')
          ..write('filePath: $filePath, ')
          ..write('downloadProgress: $downloadProgress, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('transferredBytes: $transferredBytes, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('transferStatus: $transferStatus, ')
          ..write('transferTaskId: $transferTaskId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
  late final $DeviceAddressItemsTable deviceAddressItems =
      $DeviceAddressItemsTable(this);
  late final $ConnectionSessionItemsTable connectionSessionItems =
      $ConnectionSessionItemsTable(this);
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
  late final Index deviceAddressItemsDeviceId = Index(
    'device_address_items_device_id',
    'CREATE INDEX device_address_items_device_id ON device_address_items (device_id)',
  );
  late final Index deviceAddressItemsNetworkSignature = Index(
    'device_address_items_network_signature',
    'CREATE INDEX device_address_items_network_signature ON device_address_items (network_signature)',
  );
  late final Index deviceAddressItemsIsReachable = Index(
    'device_address_items_is_reachable',
    'CREATE INDEX device_address_items_is_reachable ON device_address_items (is_reachable)',
  );
  late final Index deviceAddressItemsLastSeenAt = Index(
    'device_address_items_last_seen_at',
    'CREATE INDEX device_address_items_last_seen_at ON device_address_items (last_seen_at)',
  );
  late final Index connectionSessionItemsDeviceId = Index(
    'connection_session_items_device_id',
    'CREATE INDEX connection_session_items_device_id ON connection_session_items (device_id)',
  );
  late final Index connectionSessionItemsConnectedAt = Index(
    'connection_session_items_connected_at',
    'CREATE INDEX connection_session_items_connected_at ON connection_session_items (connected_at)',
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
  late final DeviceAddressDao deviceAddressDao = DeviceAddressDao(
    this as AppDataBase,
  );
  late final ConnectionSessionDao connectionSessionDao = ConnectionSessionDao(
    this as AppDataBase,
  );
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
    deviceAddressItems,
    connectionSessionItems,
    settingItems,
    mineItems,
    messageItems,
    messageAttachmentItems,
    pointItems,
    deviceItemsConnectionStatus,
    deviceAddressItemsDeviceId,
    deviceAddressItemsNetworkSignature,
    deviceAddressItemsIsReachable,
    deviceAddressItemsLastSeenAt,
    connectionSessionItemsDeviceId,
    connectionSessionItemsConnectedAt,
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
      result: [TableUpdate('device_address_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'device_items',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('device_address_items', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'device_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('connection_session_items', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'device_items',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('connection_session_items', kind: UpdateKind.update),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'device_address_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('connection_session_items', kind: UpdateKind.update),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'device_address_items',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('connection_session_items', kind: UpdateKind.update),
      ],
    ),
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

  static MultiTypedResultKey<$DeviceAddressItemsTable, List<DeviceAddressItem>>
  _deviceAddressItemsRefsTable(_$AppDataBase db) =>
      MultiTypedResultKey.fromTable(
        db.deviceAddressItems,
        aliasName: $_aliasNameGenerator(
          db.deviceItems.deviceId,
          db.deviceAddressItems.deviceId,
        ),
      );

  $$DeviceAddressItemsTableProcessedTableManager get deviceAddressItemsRefs {
    final manager =
        $$DeviceAddressItemsTableTableManager(
          $_db,
          $_db.deviceAddressItems,
        ).filter(
          (f) =>
              f.deviceId.deviceId.sqlEquals($_itemColumn<String>('device_id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _deviceAddressItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ConnectionSessionItemsTable,
    List<ConnectionSessionItem>
  >
  _connectionSessionItemsRefsTable(_$AppDataBase db) =>
      MultiTypedResultKey.fromTable(
        db.connectionSessionItems,
        aliasName: $_aliasNameGenerator(
          db.deviceItems.deviceId,
          db.connectionSessionItems.deviceId,
        ),
      );

  $$ConnectionSessionItemsTableProcessedTableManager
  get connectionSessionItemsRefs {
    final manager =
        $$ConnectionSessionItemsTableTableManager(
          $_db,
          $_db.connectionSessionItems,
        ).filter(
          (f) =>
              f.deviceId.deviceId.sqlEquals($_itemColumn<String>('device_id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _connectionSessionItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

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

  Expression<bool> deviceAddressItemsRefs(
    Expression<bool> Function($$DeviceAddressItemsTableFilterComposer f) f,
  ) {
    final $$DeviceAddressItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.deviceAddressItems,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceAddressItemsTableFilterComposer(
            $db: $db,
            $table: $db.deviceAddressItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> connectionSessionItemsRefs(
    Expression<bool> Function($$ConnectionSessionItemsTableFilterComposer f) f,
  ) {
    final $$ConnectionSessionItemsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.deviceId,
          referencedTable: $db.connectionSessionItems,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConnectionSessionItemsTableFilterComposer(
                $db: $db,
                $table: $db.connectionSessionItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

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

  Expression<T> deviceAddressItemsRefs<T extends Object>(
    Expression<T> Function($$DeviceAddressItemsTableAnnotationComposer a) f,
  ) {
    final $$DeviceAddressItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.deviceId,
          referencedTable: $db.deviceAddressItems,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DeviceAddressItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.deviceAddressItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> connectionSessionItemsRefs<T extends Object>(
    Expression<T> Function($$ConnectionSessionItemsTableAnnotationComposer a) f,
  ) {
    final $$ConnectionSessionItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.deviceId,
          referencedTable: $db.connectionSessionItems,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConnectionSessionItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.connectionSessionItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

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
          PrefetchHooks Function({
            bool deviceAddressItemsRefs,
            bool connectionSessionItemsRefs,
            bool messageItemsRefs,
          })
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
          prefetchHooksCallback:
              ({
                deviceAddressItemsRefs = false,
                connectionSessionItemsRefs = false,
                messageItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (deviceAddressItemsRefs) db.deviceAddressItems,
                    if (connectionSessionItemsRefs) db.connectionSessionItems,
                    if (messageItemsRefs) db.messageItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (deviceAddressItemsRefs)
                        await $_getPrefetchedData<
                          DeviceItem,
                          $DeviceItemsTable,
                          DeviceAddressItem
                        >(
                          currentTable: table,
                          referencedTable: $$DeviceItemsTableReferences
                              ._deviceAddressItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DeviceItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).deviceAddressItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deviceId == item.deviceId,
                              ),
                          typedResults: items,
                        ),
                      if (connectionSessionItemsRefs)
                        await $_getPrefetchedData<
                          DeviceItem,
                          $DeviceItemsTable,
                          ConnectionSessionItem
                        >(
                          currentTable: table,
                          referencedTable: $$DeviceItemsTableReferences
                              ._connectionSessionItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DeviceItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).connectionSessionItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deviceId == item.deviceId,
                              ),
                          typedResults: items,
                        ),
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
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
      PrefetchHooks Function({
        bool deviceAddressItemsRefs,
        bool connectionSessionItemsRefs,
        bool messageItemsRefs,
      })
    >;
typedef $$DeviceAddressItemsTableCreateCompanionBuilder =
    DeviceAddressItemsCompanion Function({
      Value<int> id,
      required String deviceId,
      required String ipAddress,
      required DeviceIpVersion ipVersion,
      required int port,
      Value<String?> interfaceName,
      Value<String?> networkSignature,
      Value<String?> subnetMask,
      Value<String?> gatewayAddress,
      Value<String?> broadcastAddress,
      Value<DeviceAddressSource> source,
      Value<bool> isReachable,
      Value<int?> latencyMs,
      Value<int> averageTransferSpeedBytesPerSecond,
      Value<DateTime> lastSeenAt,
      Value<DateTime?> lastSuccessAt,
      Value<DateTime?> lastFailureAt,
      Value<String?> failureReason,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$DeviceAddressItemsTableUpdateCompanionBuilder =
    DeviceAddressItemsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<String> ipAddress,
      Value<DeviceIpVersion> ipVersion,
      Value<int> port,
      Value<String?> interfaceName,
      Value<String?> networkSignature,
      Value<String?> subnetMask,
      Value<String?> gatewayAddress,
      Value<String?> broadcastAddress,
      Value<DeviceAddressSource> source,
      Value<bool> isReachable,
      Value<int?> latencyMs,
      Value<int> averageTransferSpeedBytesPerSecond,
      Value<DateTime> lastSeenAt,
      Value<DateTime?> lastSuccessAt,
      Value<DateTime?> lastFailureAt,
      Value<String?> failureReason,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$DeviceAddressItemsTableReferences
    extends
        BaseReferences<
          _$AppDataBase,
          $DeviceAddressItemsTable,
          DeviceAddressItem
        > {
  $$DeviceAddressItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DeviceItemsTable _deviceIdTable(_$AppDataBase db) =>
      db.deviceItems.createAlias(
        $_aliasNameGenerator(
          db.deviceAddressItems.deviceId,
          db.deviceItems.deviceId,
        ),
      );

  $$DeviceItemsTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DeviceItemsTableTableManager(
      $_db,
      $_db.deviceItems,
    ).filter((f) => f.deviceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ConnectionSessionItemsTable,
    List<ConnectionSessionItem>
  >
  _connectionSessionItemsRefsTable(_$AppDataBase db) =>
      MultiTypedResultKey.fromTable(
        db.connectionSessionItems,
        aliasName: $_aliasNameGenerator(
          db.deviceAddressItems.id,
          db.connectionSessionItems.deviceAddressId,
        ),
      );

  $$ConnectionSessionItemsTableProcessedTableManager
  get connectionSessionItemsRefs {
    final manager = $$ConnectionSessionItemsTableTableManager(
      $_db,
      $_db.connectionSessionItems,
    ).filter((f) => f.deviceAddressId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _connectionSessionItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DeviceAddressItemsTableFilterComposer
    extends Composer<_$AppDataBase, $DeviceAddressItemsTable> {
  $$DeviceAddressItemsTableFilterComposer({
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

  ColumnFilters<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DeviceIpVersion, DeviceIpVersion, String>
  get ipVersion => $composableBuilder(
    column: $table.ipVersion,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interfaceName => $composableBuilder(
    column: $table.interfaceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get networkSignature => $composableBuilder(
    column: $table.networkSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subnetMask => $composableBuilder(
    column: $table.subnetMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gatewayAddress => $composableBuilder(
    column: $table.gatewayAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get broadcastAddress => $composableBuilder(
    column: $table.broadcastAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    DeviceAddressSource,
    DeviceAddressSource,
    String
  >
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isReachable => $composableBuilder(
    column: $table.isReachable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get averageTransferSpeedBytesPerSecond =>
      $composableBuilder(
        column: $table.averageTransferSpeedBytesPerSecond,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFailureAt => $composableBuilder(
    column: $table.lastFailureAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
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

  $$DeviceItemsTableFilterComposer get deviceId {
    final $$DeviceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
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

  Expression<bool> connectionSessionItemsRefs(
    Expression<bool> Function($$ConnectionSessionItemsTableFilterComposer f) f,
  ) {
    final $$ConnectionSessionItemsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.connectionSessionItems,
          getReferencedColumn: (t) => t.deviceAddressId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConnectionSessionItemsTableFilterComposer(
                $db: $db,
                $table: $db.connectionSessionItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DeviceAddressItemsTableOrderingComposer
    extends Composer<_$AppDataBase, $DeviceAddressItemsTable> {
  $$DeviceAddressItemsTableOrderingComposer({
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

  ColumnOrderings<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipVersion => $composableBuilder(
    column: $table.ipVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interfaceName => $composableBuilder(
    column: $table.interfaceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get networkSignature => $composableBuilder(
    column: $table.networkSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subnetMask => $composableBuilder(
    column: $table.subnetMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gatewayAddress => $composableBuilder(
    column: $table.gatewayAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get broadcastAddress => $composableBuilder(
    column: $table.broadcastAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReachable => $composableBuilder(
    column: $table.isReachable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get averageTransferSpeedBytesPerSecond =>
      $composableBuilder(
        column: $table.averageTransferSpeedBytesPerSecond,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFailureAt => $composableBuilder(
    column: $table.lastFailureAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
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

  $$DeviceItemsTableOrderingComposer get deviceId {
    final $$DeviceItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
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

class $$DeviceAddressItemsTableAnnotationComposer
    extends Composer<_$AppDataBase, $DeviceAddressItemsTable> {
  $$DeviceAddressItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DeviceIpVersion, String> get ipVersion =>
      $composableBuilder(column: $table.ipVersion, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get interfaceName => $composableBuilder(
    column: $table.interfaceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get networkSignature => $composableBuilder(
    column: $table.networkSignature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subnetMask => $composableBuilder(
    column: $table.subnetMask,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gatewayAddress => $composableBuilder(
    column: $table.gatewayAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get broadcastAddress => $composableBuilder(
    column: $table.broadcastAddress,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DeviceAddressSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get isReachable => $composableBuilder(
    column: $table.isReachable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get latencyMs =>
      $composableBuilder(column: $table.latencyMs, builder: (column) => column);

  GeneratedColumn<int> get averageTransferSpeedBytesPerSecond =>
      $composableBuilder(
        column: $table.averageTransferSpeedBytesPerSecond,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFailureAt => $composableBuilder(
    column: $table.lastFailureAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DeviceItemsTableAnnotationComposer get deviceId {
    final $$DeviceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
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

  Expression<T> connectionSessionItemsRefs<T extends Object>(
    Expression<T> Function($$ConnectionSessionItemsTableAnnotationComposer a) f,
  ) {
    final $$ConnectionSessionItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.connectionSessionItems,
          getReferencedColumn: (t) => t.deviceAddressId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConnectionSessionItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.connectionSessionItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DeviceAddressItemsTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $DeviceAddressItemsTable,
          DeviceAddressItem,
          $$DeviceAddressItemsTableFilterComposer,
          $$DeviceAddressItemsTableOrderingComposer,
          $$DeviceAddressItemsTableAnnotationComposer,
          $$DeviceAddressItemsTableCreateCompanionBuilder,
          $$DeviceAddressItemsTableUpdateCompanionBuilder,
          (DeviceAddressItem, $$DeviceAddressItemsTableReferences),
          DeviceAddressItem,
          PrefetchHooks Function({
            bool deviceId,
            bool connectionSessionItemsRefs,
          })
        > {
  $$DeviceAddressItemsTableTableManager(
    _$AppDataBase db,
    $DeviceAddressItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceAddressItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceAddressItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceAddressItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> ipAddress = const Value.absent(),
                Value<DeviceIpVersion> ipVersion = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String?> interfaceName = const Value.absent(),
                Value<String?> networkSignature = const Value.absent(),
                Value<String?> subnetMask = const Value.absent(),
                Value<String?> gatewayAddress = const Value.absent(),
                Value<String?> broadcastAddress = const Value.absent(),
                Value<DeviceAddressSource> source = const Value.absent(),
                Value<bool> isReachable = const Value.absent(),
                Value<int?> latencyMs = const Value.absent(),
                Value<int> averageTransferSpeedBytesPerSecond =
                    const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<DateTime?> lastFailureAt = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DeviceAddressItemsCompanion(
                id: id,
                deviceId: deviceId,
                ipAddress: ipAddress,
                ipVersion: ipVersion,
                port: port,
                interfaceName: interfaceName,
                networkSignature: networkSignature,
                subnetMask: subnetMask,
                gatewayAddress: gatewayAddress,
                broadcastAddress: broadcastAddress,
                source: source,
                isReachable: isReachable,
                latencyMs: latencyMs,
                averageTransferSpeedBytesPerSecond:
                    averageTransferSpeedBytesPerSecond,
                lastSeenAt: lastSeenAt,
                lastSuccessAt: lastSuccessAt,
                lastFailureAt: lastFailureAt,
                failureReason: failureReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required String ipAddress,
                required DeviceIpVersion ipVersion,
                required int port,
                Value<String?> interfaceName = const Value.absent(),
                Value<String?> networkSignature = const Value.absent(),
                Value<String?> subnetMask = const Value.absent(),
                Value<String?> gatewayAddress = const Value.absent(),
                Value<String?> broadcastAddress = const Value.absent(),
                Value<DeviceAddressSource> source = const Value.absent(),
                Value<bool> isReachable = const Value.absent(),
                Value<int?> latencyMs = const Value.absent(),
                Value<int> averageTransferSpeedBytesPerSecond =
                    const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<DateTime?> lastFailureAt = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DeviceAddressItemsCompanion.insert(
                id: id,
                deviceId: deviceId,
                ipAddress: ipAddress,
                ipVersion: ipVersion,
                port: port,
                interfaceName: interfaceName,
                networkSignature: networkSignature,
                subnetMask: subnetMask,
                gatewayAddress: gatewayAddress,
                broadcastAddress: broadcastAddress,
                source: source,
                isReachable: isReachable,
                latencyMs: latencyMs,
                averageTransferSpeedBytesPerSecond:
                    averageTransferSpeedBytesPerSecond,
                lastSeenAt: lastSeenAt,
                lastSuccessAt: lastSuccessAt,
                lastFailureAt: lastFailureAt,
                failureReason: failureReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeviceAddressItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({deviceId = false, connectionSessionItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (connectionSessionItemsRefs) db.connectionSessionItems,
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
                        if (deviceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.deviceId,
                                    referencedTable:
                                        $$DeviceAddressItemsTableReferences
                                            ._deviceIdTable(db),
                                    referencedColumn:
                                        $$DeviceAddressItemsTableReferences
                                            ._deviceIdTable(db)
                                            .deviceId,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (connectionSessionItemsRefs)
                        await $_getPrefetchedData<
                          DeviceAddressItem,
                          $DeviceAddressItemsTable,
                          ConnectionSessionItem
                        >(
                          currentTable: table,
                          referencedTable: $$DeviceAddressItemsTableReferences
                              ._connectionSessionItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DeviceAddressItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).connectionSessionItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deviceAddressId == item.id,
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

typedef $$DeviceAddressItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $DeviceAddressItemsTable,
      DeviceAddressItem,
      $$DeviceAddressItemsTableFilterComposer,
      $$DeviceAddressItemsTableOrderingComposer,
      $$DeviceAddressItemsTableAnnotationComposer,
      $$DeviceAddressItemsTableCreateCompanionBuilder,
      $$DeviceAddressItemsTableUpdateCompanionBuilder,
      (DeviceAddressItem, $$DeviceAddressItemsTableReferences),
      DeviceAddressItem,
      PrefetchHooks Function({bool deviceId, bool connectionSessionItemsRefs})
    >;
typedef $$ConnectionSessionItemsTableCreateCompanionBuilder =
    ConnectionSessionItemsCompanion Function({
      Value<int> id,
      required String sessionId,
      required String deviceId,
      Value<int?> deviceAddressId,
      required ConnectionSessionState state,
      required int protocolVersion,
      Value<DateTime?> connectedAt,
      Value<DateTime?> lastHeartbeatAt,
      Value<DateTime?> disconnectedAt,
      Value<String?> lastError,
    });
typedef $$ConnectionSessionItemsTableUpdateCompanionBuilder =
    ConnectionSessionItemsCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<String> deviceId,
      Value<int?> deviceAddressId,
      Value<ConnectionSessionState> state,
      Value<int> protocolVersion,
      Value<DateTime?> connectedAt,
      Value<DateTime?> lastHeartbeatAt,
      Value<DateTime?> disconnectedAt,
      Value<String?> lastError,
    });

final class $$ConnectionSessionItemsTableReferences
    extends
        BaseReferences<
          _$AppDataBase,
          $ConnectionSessionItemsTable,
          ConnectionSessionItem
        > {
  $$ConnectionSessionItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DeviceItemsTable _deviceIdTable(_$AppDataBase db) =>
      db.deviceItems.createAlias(
        $_aliasNameGenerator(
          db.connectionSessionItems.deviceId,
          db.deviceItems.deviceId,
        ),
      );

  $$DeviceItemsTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DeviceItemsTableTableManager(
      $_db,
      $_db.deviceItems,
    ).filter((f) => f.deviceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DeviceAddressItemsTable _deviceAddressIdTable(_$AppDataBase db) =>
      db.deviceAddressItems.createAlias(
        $_aliasNameGenerator(
          db.connectionSessionItems.deviceAddressId,
          db.deviceAddressItems.id,
        ),
      );

  $$DeviceAddressItemsTableProcessedTableManager? get deviceAddressId {
    final $_column = $_itemColumn<int>('device_address_id');
    if ($_column == null) return null;
    final manager = $$DeviceAddressItemsTableTableManager(
      $_db,
      $_db.deviceAddressItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceAddressIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConnectionSessionItemsTableFilterComposer
    extends Composer<_$AppDataBase, $ConnectionSessionItemsTable> {
  $$ConnectionSessionItemsTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    ConnectionSessionState,
    ConnectionSessionState,
    String
  >
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastHeartbeatAt => $composableBuilder(
    column: $table.lastHeartbeatAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get disconnectedAt => $composableBuilder(
    column: $table.disconnectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  $$DeviceItemsTableFilterComposer get deviceId {
    final $$DeviceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
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

  $$DeviceAddressItemsTableFilterComposer get deviceAddressId {
    final $$DeviceAddressItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceAddressId,
      referencedTable: $db.deviceAddressItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceAddressItemsTableFilterComposer(
            $db: $db,
            $table: $db.deviceAddressItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConnectionSessionItemsTableOrderingComposer
    extends Composer<_$AppDataBase, $ConnectionSessionItemsTable> {
  $$ConnectionSessionItemsTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastHeartbeatAt => $composableBuilder(
    column: $table.lastHeartbeatAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get disconnectedAt => $composableBuilder(
    column: $table.disconnectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  $$DeviceItemsTableOrderingComposer get deviceId {
    final $$DeviceItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
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

  $$DeviceAddressItemsTableOrderingComposer get deviceAddressId {
    final $$DeviceAddressItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceAddressId,
      referencedTable: $db.deviceAddressItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceAddressItemsTableOrderingComposer(
            $db: $db,
            $table: $db.deviceAddressItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConnectionSessionItemsTableAnnotationComposer
    extends Composer<_$AppDataBase, $ConnectionSessionItemsTable> {
  $$ConnectionSessionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ConnectionSessionState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastHeartbeatAt => $composableBuilder(
    column: $table.lastHeartbeatAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get disconnectedAt => $composableBuilder(
    column: $table.disconnectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  $$DeviceItemsTableAnnotationComposer get deviceId {
    final $$DeviceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
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

  $$DeviceAddressItemsTableAnnotationComposer get deviceAddressId {
    final $$DeviceAddressItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.deviceAddressId,
          referencedTable: $db.deviceAddressItems,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DeviceAddressItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.deviceAddressItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ConnectionSessionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $ConnectionSessionItemsTable,
          ConnectionSessionItem,
          $$ConnectionSessionItemsTableFilterComposer,
          $$ConnectionSessionItemsTableOrderingComposer,
          $$ConnectionSessionItemsTableAnnotationComposer,
          $$ConnectionSessionItemsTableCreateCompanionBuilder,
          $$ConnectionSessionItemsTableUpdateCompanionBuilder,
          (ConnectionSessionItem, $$ConnectionSessionItemsTableReferences),
          ConnectionSessionItem,
          PrefetchHooks Function({bool deviceId, bool deviceAddressId})
        > {
  $$ConnectionSessionItemsTableTableManager(
    _$AppDataBase db,
    $ConnectionSessionItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConnectionSessionItemsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ConnectionSessionItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ConnectionSessionItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int?> deviceAddressId = const Value.absent(),
                Value<ConnectionSessionState> state = const Value.absent(),
                Value<int> protocolVersion = const Value.absent(),
                Value<DateTime?> connectedAt = const Value.absent(),
                Value<DateTime?> lastHeartbeatAt = const Value.absent(),
                Value<DateTime?> disconnectedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => ConnectionSessionItemsCompanion(
                id: id,
                sessionId: sessionId,
                deviceId: deviceId,
                deviceAddressId: deviceAddressId,
                state: state,
                protocolVersion: protocolVersion,
                connectedAt: connectedAt,
                lastHeartbeatAt: lastHeartbeatAt,
                disconnectedAt: disconnectedAt,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required String deviceId,
                Value<int?> deviceAddressId = const Value.absent(),
                required ConnectionSessionState state,
                required int protocolVersion,
                Value<DateTime?> connectedAt = const Value.absent(),
                Value<DateTime?> lastHeartbeatAt = const Value.absent(),
                Value<DateTime?> disconnectedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => ConnectionSessionItemsCompanion.insert(
                id: id,
                sessionId: sessionId,
                deviceId: deviceId,
                deviceAddressId: deviceAddressId,
                state: state,
                protocolVersion: protocolVersion,
                connectedAt: connectedAt,
                lastHeartbeatAt: lastHeartbeatAt,
                disconnectedAt: disconnectedAt,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConnectionSessionItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false, deviceAddressId = false}) {
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
                    if (deviceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deviceId,
                                referencedTable:
                                    $$ConnectionSessionItemsTableReferences
                                        ._deviceIdTable(db),
                                referencedColumn:
                                    $$ConnectionSessionItemsTableReferences
                                        ._deviceIdTable(db)
                                        .deviceId,
                              )
                              as T;
                    }
                    if (deviceAddressId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deviceAddressId,
                                referencedTable:
                                    $$ConnectionSessionItemsTableReferences
                                        ._deviceAddressIdTable(db),
                                referencedColumn:
                                    $$ConnectionSessionItemsTableReferences
                                        ._deviceAddressIdTable(db)
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

typedef $$ConnectionSessionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $ConnectionSessionItemsTable,
      ConnectionSessionItem,
      $$ConnectionSessionItemsTableFilterComposer,
      $$ConnectionSessionItemsTableOrderingComposer,
      $$ConnectionSessionItemsTableAnnotationComposer,
      $$ConnectionSessionItemsTableCreateCompanionBuilder,
      $$ConnectionSessionItemsTableUpdateCompanionBuilder,
      (ConnectionSessionItem, $$ConnectionSessionItemsTableReferences),
      ConnectionSessionItem,
      PrefetchHooks Function({bool deviceId, bool deviceAddressId})
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
      Value<DateTime> updatedAt,
      required MessageDirection direction,
      Value<MessageType> messageType,
      Value<MessageSendStatus> sendStatus,
      Value<String?> localMessageId,
      Value<String?> remoteMessageId,
      Value<String?> errorMessage,
    });
typedef $$MessageItemsTableUpdateCompanionBuilder =
    MessageItemsCompanion Function({
      Value<int> id,
      Value<String> remoteDeviceId,
      Value<String?> textContent,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<MessageDirection> direction,
      Value<MessageType> messageType,
      Value<MessageSendStatus> sendStatus,
      Value<String?> localMessageId,
      Value<String?> remoteMessageId,
      Value<String?> errorMessage,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MessageDirection, MessageDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MessageType, MessageType, String>
  get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MessageSendStatus, MessageSendStatus, String>
  get sendStatus => $composableBuilder(
    column: $table.sendStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get localMessageId => $composableBuilder(
    column: $table.localMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteMessageId => $composableBuilder(
    column: $table.remoteMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sendStatus => $composableBuilder(
    column: $table.sendStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localMessageId => $composableBuilder(
    column: $table.localMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteMessageId => $composableBuilder(
    column: $table.remoteMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageType, String> get messageType =>
      $composableBuilder(
        column: $table.messageType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<MessageSendStatus, String> get sendStatus =>
      $composableBuilder(
        column: $table.sendStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get localMessageId => $composableBuilder(
    column: $table.localMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteMessageId => $composableBuilder(
    column: $table.remoteMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

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
                Value<DateTime> updatedAt = const Value.absent(),
                Value<MessageDirection> direction = const Value.absent(),
                Value<MessageType> messageType = const Value.absent(),
                Value<MessageSendStatus> sendStatus = const Value.absent(),
                Value<String?> localMessageId = const Value.absent(),
                Value<String?> remoteMessageId = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => MessageItemsCompanion(
                id: id,
                remoteDeviceId: remoteDeviceId,
                textContent: textContent,
                createdAt: createdAt,
                updatedAt: updatedAt,
                direction: direction,
                messageType: messageType,
                sendStatus: sendStatus,
                localMessageId: localMessageId,
                remoteMessageId: remoteMessageId,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String remoteDeviceId,
                Value<String?> textContent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required MessageDirection direction,
                Value<MessageType> messageType = const Value.absent(),
                Value<MessageSendStatus> sendStatus = const Value.absent(),
                Value<String?> localMessageId = const Value.absent(),
                Value<String?> remoteMessageId = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => MessageItemsCompanion.insert(
                id: id,
                remoteDeviceId: remoteDeviceId,
                textContent: textContent,
                createdAt: createdAt,
                updatedAt: updatedAt,
                direction: direction,
                messageType: messageType,
                sendStatus: sendStatus,
                localMessageId: localMessageId,
                remoteMessageId: remoteMessageId,
                errorMessage: errorMessage,
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
      Value<String?> attachmentId,
      Value<String?> fileName,
      Value<String?> mimeType,
      Value<int> totalBytes,
      Value<int> transferredBytes,
      Value<String?> checksumSha256,
      Value<String?> thumbnailPath,
      Value<MessageAttachmentTransferStatus> transferStatus,
      Value<String?> transferTaskId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$MessageAttachmentItemsTableUpdateCompanionBuilder =
    MessageAttachmentItemsCompanion Function({
      Value<int> id,
      Value<int> messageId,
      Value<MessageAttachmentSaveStatus> saveStatus,
      Value<String?> filePath,
      Value<int> downloadProgress,
      Value<String?> attachmentId,
      Value<String?> fileName,
      Value<String?> mimeType,
      Value<int> totalBytes,
      Value<int> transferredBytes,
      Value<String?> checksumSha256,
      Value<String?> thumbnailPath,
      Value<MessageAttachmentTransferStatus> transferStatus,
      Value<String?> transferTaskId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
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

  ColumnFilters<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transferredBytes => $composableBuilder(
    column: $table.transferredBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    MessageAttachmentTransferStatus,
    MessageAttachmentTransferStatus,
    String
  >
  get transferStatus => $composableBuilder(
    column: $table.transferStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get transferTaskId => $composableBuilder(
    column: $table.transferTaskId,
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

  ColumnOrderings<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transferredBytes => $composableBuilder(
    column: $table.transferredBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferStatus => $composableBuilder(
    column: $table.transferStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferTaskId => $composableBuilder(
    column: $table.transferTaskId,
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

  GeneratedColumn<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get transferredBytes => $composableBuilder(
    column: $table.transferredBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MessageAttachmentTransferStatus, String>
  get transferStatus => $composableBuilder(
    column: $table.transferStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transferTaskId => $composableBuilder(
    column: $table.transferTaskId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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
                Value<String?> attachmentId = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<int> transferredBytes = const Value.absent(),
                Value<String?> checksumSha256 = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<MessageAttachmentTransferStatus> transferStatus =
                    const Value.absent(),
                Value<String?> transferTaskId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MessageAttachmentItemsCompanion(
                id: id,
                messageId: messageId,
                saveStatus: saveStatus,
                filePath: filePath,
                downloadProgress: downloadProgress,
                attachmentId: attachmentId,
                fileName: fileName,
                mimeType: mimeType,
                totalBytes: totalBytes,
                transferredBytes: transferredBytes,
                checksumSha256: checksumSha256,
                thumbnailPath: thumbnailPath,
                transferStatus: transferStatus,
                transferTaskId: transferTaskId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int messageId,
                Value<MessageAttachmentSaveStatus> saveStatus =
                    const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<int> downloadProgress = const Value.absent(),
                Value<String?> attachmentId = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<int> transferredBytes = const Value.absent(),
                Value<String?> checksumSha256 = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<MessageAttachmentTransferStatus> transferStatus =
                    const Value.absent(),
                Value<String?> transferTaskId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MessageAttachmentItemsCompanion.insert(
                id: id,
                messageId: messageId,
                saveStatus: saveStatus,
                filePath: filePath,
                downloadProgress: downloadProgress,
                attachmentId: attachmentId,
                fileName: fileName,
                mimeType: mimeType,
                totalBytes: totalBytes,
                transferredBytes: transferredBytes,
                checksumSha256: checksumSha256,
                thumbnailPath: thumbnailPath,
                transferStatus: transferStatus,
                transferTaskId: transferTaskId,
                createdAt: createdAt,
                updatedAt: updatedAt,
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
  $$DeviceAddressItemsTableTableManager get deviceAddressItems =>
      $$DeviceAddressItemsTableTableManager(_db, _db.deviceAddressItems);
  $$ConnectionSessionItemsTableTableManager get connectionSessionItems =>
      $$ConnectionSessionItemsTableTableManager(
        _db,
        _db.connectionSessionItems,
      );
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
