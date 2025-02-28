// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_pod.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesPodHash() => r'92efa4bd493eb834ec69cd1699cb9ed12756b79a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MessagesPod
    extends BuildlessAutoDisposeAsyncNotifier<List<MessageModel>> {
  late final String chatId;

  FutureOr<List<MessageModel>> build(
    String chatId,
  );
}

/// See also [MessagesPod].
@ProviderFor(MessagesPod)
const messagesPodProvider = MessagesPodFamily();

/// See also [MessagesPod].
class MessagesPodFamily extends Family<AsyncValue<List<MessageModel>>> {
  /// See also [MessagesPod].
  const MessagesPodFamily();

  /// See also [MessagesPod].
  MessagesPodProvider call(
    String chatId,
  ) {
    return MessagesPodProvider(
      chatId,
    );
  }

  @override
  MessagesPodProvider getProviderOverride(
    covariant MessagesPodProvider provider,
  ) {
    return call(
      provider.chatId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesPodProvider';
}

/// See also [MessagesPod].
class MessagesPodProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MessagesPod, List<MessageModel>> {
  /// See also [MessagesPod].
  MessagesPodProvider(
    String chatId,
  ) : this._internal(
          () => MessagesPod()..chatId = chatId,
          from: messagesPodProvider,
          name: r'messagesPodProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messagesPodHash,
          dependencies: MessagesPodFamily._dependencies,
          allTransitiveDependencies:
              MessagesPodFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  MessagesPodProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final String chatId;

  @override
  FutureOr<List<MessageModel>> runNotifierBuild(
    covariant MessagesPod notifier,
  ) {
    return notifier.build(
      chatId,
    );
  }

  @override
  Override overrideWith(MessagesPod Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessagesPodProvider._internal(
        () => create()..chatId = chatId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MessagesPod, List<MessageModel>>
      createElement() {
    return _MessagesPodProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesPodProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesPodRef
    on AutoDisposeAsyncNotifierProviderRef<List<MessageModel>> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _MessagesPodProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MessagesPod,
        List<MessageModel>> with MessagesPodRef {
  _MessagesPodProviderElement(super.provider);

  @override
  String get chatId => (origin as MessagesPodProvider).chatId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
