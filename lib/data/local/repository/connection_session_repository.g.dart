// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_session_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(connectionSessionRepository)
final connectionSessionRepositoryProvider =
    ConnectionSessionRepositoryProvider._();

final class ConnectionSessionRepositoryProvider
    extends
        $FunctionalProvider<
          ConnectionSessionRepository,
          ConnectionSessionRepository,
          ConnectionSessionRepository
        >
    with $Provider<ConnectionSessionRepository> {
  ConnectionSessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionSessionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConnectionSessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectionSessionRepository create(Ref ref) {
    return connectionSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionSessionRepository>(value),
    );
  }
}

String _$connectionSessionRepositoryHash() =>
    r'a4ad22614db6029acbb000b8c6effc10ea57ac66';
