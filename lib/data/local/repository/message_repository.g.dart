// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(messageRepository)
final messageRepositoryProvider = MessageRepositoryProvider._();

final class MessageRepositoryProvider
    extends
        $FunctionalProvider<
          MessageRepository,
          MessageRepository,
          MessageRepository
        >
    with $Provider<MessageRepository> {
  MessageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messageRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messageRepositoryHash();

  @$internal
  @override
  $ProviderElement<MessageRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MessageRepository create(Ref ref) {
    return messageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageRepository>(value),
    );
  }
}

String _$messageRepositoryHash() => r'4812c2756a602cf237205d84a22378e9093ac871';

@ProviderFor(conversation)
final conversationProvider = ConversationFamily._();

final class ConversationProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConversationMessage>>,
          List<ConversationMessage>,
          Stream<List<ConversationMessage>>
        >
    with
        $FutureModifier<List<ConversationMessage>>,
        $StreamProvider<List<ConversationMessage>> {
  ConversationProvider._({
    required ConversationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationHash();

  @override
  String toString() {
    return r'conversationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ConversationMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConversationMessage>> create(Ref ref) {
    final argument = this.argument as String;
    return conversation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationHash() => r'c1c31b797f9c5c0ccdaff70455ed4ca561860717';

final class ConversationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ConversationMessage>>, String> {
  ConversationFamily._()
    : super(
        retry: null,
        name: r'conversationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConversationProvider call(String remoteDeviceId) =>
      ConversationProvider._(argument: remoteDeviceId, from: this);

  @override
  String toString() => r'conversationProvider';
}
