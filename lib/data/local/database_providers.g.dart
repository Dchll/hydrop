// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDataBase)
final appDataBaseProvider = AppDataBaseProvider._();

final class AppDataBaseProvider
    extends $FunctionalProvider<AppDataBase, AppDataBase, AppDataBase>
    with $Provider<AppDataBase> {
  AppDataBaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDataBaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDataBaseHash();

  @$internal
  @override
  $ProviderElement<AppDataBase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDataBase create(Ref ref) {
    return appDataBase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDataBase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDataBase>(value),
    );
  }
}

String _$appDataBaseHash() => r'8589330e7b5b1ae4bf279b6e3f9ded7b2bda4c57';
