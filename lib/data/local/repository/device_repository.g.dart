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

String _$deviceRepositoryHash() => r'7c57e6f9ef14d940d961e84cf6b1abc900d884a1';

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
