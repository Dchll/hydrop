// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceRepository)
final deviceRepositoryProvider = DeviceRepositoryProvider._();

final class DeviceRepositoryProvider
    extends
        $FunctionalProvider<
          DeviceRepository,
          DeviceRepository,
          DeviceRepository
        >
    with $Provider<DeviceRepository> {
  DeviceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeviceRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceRepository create(Ref ref) {
    return deviceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceRepository>(value),
    );
  }
}

String _$deviceRepositoryHash() => r'eb6eecb2a025e4db9aa23ad5643ec3cda7cb8e39';

@ProviderFor(deviceList)
final deviceListProvider = DeviceListProvider._();

final class DeviceListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeviceSnapshot>>,
          List<DeviceSnapshot>,
          Stream<List<DeviceSnapshot>>
        >
    with
        $FutureModifier<List<DeviceSnapshot>>,
        $StreamProvider<List<DeviceSnapshot>> {
  DeviceListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceListHash();

  @$internal
  @override
  $StreamProviderElement<List<DeviceSnapshot>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DeviceSnapshot>> create(Ref ref) {
    return deviceList(ref);
  }
}

String _$deviceListHash() => r'da1bbba34edb85360bd54f0df3bbdcde8bd51975';

@ProviderFor(deviceSnapshot)
final deviceSnapshotProvider = DeviceSnapshotFamily._();

final class DeviceSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeviceSnapshot?>,
          DeviceSnapshot?,
          Stream<DeviceSnapshot?>
        >
    with $FutureModifier<DeviceSnapshot?>, $StreamProvider<DeviceSnapshot?> {
  DeviceSnapshotProvider._({
    required DeviceSnapshotFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deviceSnapshotProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deviceSnapshotHash();

  @override
  String toString() {
    return r'deviceSnapshotProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DeviceSnapshot?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DeviceSnapshot?> create(Ref ref) {
    final argument = this.argument as String;
    return deviceSnapshot(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceSnapshotProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deviceSnapshotHash() => r'e8a16ee2561dd723155fcf9a906c7e7b41c3e96e';

final class DeviceSnapshotFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DeviceSnapshot?>, String> {
  DeviceSnapshotFamily._()
    : super(
        retry: null,
        name: r'deviceSnapshotProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeviceSnapshotProvider call(String deviceId) =>
      DeviceSnapshotProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'deviceSnapshotProvider';
}
