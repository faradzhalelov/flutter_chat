// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$createChatHash() => r'00a00f951ef520f57f644daa06a0d09bfcc9feb9';

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

/// See also [createChat].
@ProviderFor(createChat)
const createChatProvider = CreateChatFamily();

/// See also [createChat].
class CreateChatFamily extends Family<AsyncValue<String>> {
  /// See also [createChat].
  const CreateChatFamily();

  /// See also [createChat].
  CreateChatProvider call(
    String otherUserId,
  ) {
    return CreateChatProvider(
      otherUserId,
    );
  }

  @override
  CreateChatProvider getProviderOverride(
    covariant CreateChatProvider provider,
  ) {
    return call(
      provider.otherUserId,
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
  String? get name => r'createChatProvider';
}

/// See also [createChat].
class CreateChatProvider extends AutoDisposeFutureProvider<String> {
  /// See also [createChat].
  CreateChatProvider(
    String otherUserId,
  ) : this._internal(
          (ref) => createChat(
            ref as CreateChatRef,
            otherUserId,
          ),
          from: createChatProvider,
          name: r'createChatProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$createChatHash,
          dependencies: CreateChatFamily._dependencies,
          allTransitiveDependencies:
              CreateChatFamily._allTransitiveDependencies,
          otherUserId: otherUserId,
        );

  CreateChatProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.otherUserId,
  }) : super.internal();

  final String otherUserId;

  @override
  Override overrideWith(
    FutureOr<String> Function(CreateChatRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CreateChatProvider._internal(
        (ref) => create(ref as CreateChatRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        otherUserId: otherUserId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _CreateChatProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateChatProvider && other.otherUserId == otherUserId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, otherUserId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CreateChatRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `otherUserId` of this provider.
  String get otherUserId;
}

class _CreateChatProviderElement
    extends AutoDisposeFutureProviderElement<String> with CreateChatRef {
  _CreateChatProviderElement(super.provider);

  @override
  String get otherUserId => (origin as CreateChatProvider).otherUserId;
}

String _$chatListViewModelHash() => r'38f2e16abffcb850cbc0de92e34513a671a311bf';

/// See also [ChatListViewModel].
@ProviderFor(ChatListViewModel)
final chatListViewModelProvider = AutoDisposeNotifierProvider<ChatListViewModel,
    AsyncValue<List<ChatModel>>>.internal(
  ChatListViewModel.new,
  name: r'chatListViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatListViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChatListViewModel = AutoDisposeNotifier<AsyncValue<List<ChatModel>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
