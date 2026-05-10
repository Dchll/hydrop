// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dio)
final dioProvider = DioFamily._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  DioProvider._({required DioFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @override
  String toString() {
    return r'dioProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    final argument = this.argument as String;
    return dio(ref, baseUrl: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DioProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dioHash() => r'bd8068a43fc9b5399dffb631df7194eef9b54ce9';

final class DioFamily extends $Family
    with $FunctionalFamilyOverride<Dio, String> {
  DioFamily._()
    : super(
        retry: null,
        name: r'dioProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  DioProvider call({required String baseUrl}) =>
      DioProvider._(argument: baseUrl, from: this);

  @override
  String toString() => r'dioProvider';
}
