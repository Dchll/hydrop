// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pointRepository)
final pointRepositoryProvider = PointRepositoryProvider._();

final class PointRepositoryProvider
    extends
        $FunctionalProvider<PointRepository, PointRepository, PointRepository>
    with $Provider<PointRepository> {
  PointRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pointRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pointRepositoryHash();

  @$internal
  @override
  $ProviderElement<PointRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PointRepository create(Ref ref) {
    return pointRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PointRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PointRepository>(value),
    );
  }
}

String _$pointRepositoryHash() => r'0f474d010f9e6da946dc6957c7801ee54e3718b2';

@ProviderFor(usageStats)
final usageStatsProvider = UsageStatsProvider._();

final class UsageStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<UsageStats>,
          UsageStats,
          Stream<UsageStats>
        >
    with $FutureModifier<UsageStats>, $StreamProvider<UsageStats> {
  UsageStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usageStatsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usageStatsHash();

  @$internal
  @override
  $StreamProviderElement<UsageStats> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UsageStats> create(Ref ref) {
    return usageStats(ref);
  }
}

String _$usageStatsHash() => r'a9bb467acb14f449ecdcfd10a56c633ff8b741c7';
