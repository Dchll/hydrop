// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_address_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceAddressRepository)
final deviceAddressRepositoryProvider = DeviceAddressRepositoryProvider._();

final class DeviceAddressRepositoryProvider
    extends
        $FunctionalProvider<
          DeviceAddressRepository,
          DeviceAddressRepository,
          DeviceAddressRepository
        >
    with $Provider<DeviceAddressRepository> {
  DeviceAddressRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceAddressRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceAddressRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeviceAddressRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceAddressRepository create(Ref ref) {
    return deviceAddressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceAddressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceAddressRepository>(value),
    );
  }
}

String _$deviceAddressRepositoryHash() =>
    r'c36dc99b07a32955040a7b4b42c32a4540ec2b78';

@ProviderFor(deviceAddressList)
final deviceAddressListProvider = DeviceAddressListFamily._();

final class DeviceAddressListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeviceAddressSnapshot>>,
          List<DeviceAddressSnapshot>,
          Stream<List<DeviceAddressSnapshot>>
        >
    with
        $FutureModifier<List<DeviceAddressSnapshot>>,
        $StreamProvider<List<DeviceAddressSnapshot>> {
  DeviceAddressListProvider._({
    required DeviceAddressListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deviceAddressListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deviceAddressListHash();

  @override
  String toString() {
    return r'deviceAddressListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<DeviceAddressSnapshot>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DeviceAddressSnapshot>> create(Ref ref) {
    final argument = this.argument as String;
    return deviceAddressList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceAddressListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deviceAddressListHash() => r'3185473dc148a2631e6581c2d1bc4e757701eefa';

final class DeviceAddressListFamily extends $Family
    with
        $FunctionalFamilyOverride<Stream<List<DeviceAddressSnapshot>>, String> {
  DeviceAddressListFamily._()
    : super(
        retry: null,
        name: r'deviceAddressListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeviceAddressListProvider call(String deviceId) =>
      DeviceAddressListProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'deviceAddressListProvider';
}
