// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mine_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mineRepository)
final mineRepositoryProvider = MineRepositoryProvider._();

final class MineRepositoryProvider
    extends $FunctionalProvider<MineRepository, MineRepository, MineRepository>
    with $Provider<MineRepository> {
  MineRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mineRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mineRepositoryHash();

  @$internal
  @override
  $ProviderElement<MineRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MineRepository create(Ref ref) {
    return mineRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MineRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MineRepository>(value),
    );
  }
}

String _$mineRepositoryHash() => r'929b6dde504c173be1cdb8b9f407f69c3768eccc';

@ProviderFor(mineProfile)
final mineProfileProvider = MineProfileProvider._();

final class MineProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<MineProfile?>,
          MineProfile?,
          Stream<MineProfile?>
        >
    with $FutureModifier<MineProfile?>, $StreamProvider<MineProfile?> {
  MineProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mineProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mineProfileHash();

  @$internal
  @override
  $StreamProviderElement<MineProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MineProfile?> create(Ref ref) {
    return mineProfile(ref);
  }
}

String _$mineProfileHash() => r'2df5625419f3202283ac2b8c1f9e72c09d784f10';
