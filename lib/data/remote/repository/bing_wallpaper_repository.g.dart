// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bing_wallpaper_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bingWallpaperStorage)
final bingWallpaperStorageProvider = BingWallpaperStorageProvider._();

final class BingWallpaperStorageProvider
    extends
        $FunctionalProvider<
          BingWallpaperStorage,
          BingWallpaperStorage,
          BingWallpaperStorage
        >
    with $Provider<BingWallpaperStorage> {
  BingWallpaperStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bingWallpaperStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bingWallpaperStorageHash();

  @$internal
  @override
  $ProviderElement<BingWallpaperStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BingWallpaperStorage create(Ref ref) {
    return bingWallpaperStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BingWallpaperStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BingWallpaperStorage>(value),
    );
  }
}

String _$bingWallpaperStorageHash() =>
    r'aefb487eac2abe68a68d0761dcf436b3afe5acda';

@ProviderFor(bingWallpaper)
final bingWallpaperProvider = BingWallpaperProvider._();

final class BingWallpaperProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  BingWallpaperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bingWallpaperProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bingWallpaperHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return bingWallpaper(ref);
  }
}

String _$bingWallpaperHash() => r'c2cfb404db71d285a9844b8c7fd5d3cfda73cd9d';
