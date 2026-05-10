import 'package:drift/drift.dart';
import 'package:hydrop/data/local/model/device/device.dart';

enum ConnectionSessionState { connecting, ready, disconnected, failed }

@TableIndex(name: 'connection_session_items_device_id', columns: {#deviceId})
@TableIndex(
  name: 'connection_session_items_connected_at',
  columns: {#connectedAt},
)
class ConnectionSessionItems extends Table {
  late final id = integer().autoIncrement()();
  late final sessionId = text().withLength(min: 1, max: 128).unique()();
  late final deviceId = text()
      .withLength(min: 1, max: 128)
      .references(
        DeviceItems,
        #deviceId,
        onDelete: KeyAction.cascade,
        onUpdate: KeyAction.cascade,
      )();
  late final deviceAddressId = integer().nullable().references(
    DeviceAddressItems,
    #id,
    onDelete: KeyAction.setNull,
    onUpdate: KeyAction.cascade,
  )();
  late final state = textEnum<ConnectionSessionState>()();
  late final protocolVersion = integer()();
  late final connectedAt = dateTime().nullable()();
  late final lastHeartbeatAt = dateTime().nullable()();
  late final disconnectedAt = dateTime().nullable()();
  late final lastError = text().nullable()();
}
