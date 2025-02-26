// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supabaseChatViewModelHash() =>
    r'b1e02095bee8afc6888218ed1731ff2fb3e02c25';

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

abstract class _$SupabaseChatViewModel
    extends BuildlessAutoDisposeAsyncNotifier<void> {
  late final String chatId;

  FutureOr<void> build(
    String chatId,
  );
}

/// See also [SupabaseChatViewModel].
@ProviderFor(SupabaseChatViewModel)
const supabaseChatViewModelProvider = SupabaseChatViewModelFamily();

/// See also [SupabaseChatViewModel].
class SupabaseChatViewModelFamily extends Family<AsyncValue<void>> {
  /// See also [SupabaseChatViewModel].
  const SupabaseChatViewModelFamily();

  /// See also [SupabaseChatViewModel].
  SupabaseChatViewModelProvider call(
    String chatId,
  ) {
    return SupabaseChatViewModelProvider(
      chatId,
    );
  }

  @override
  SupabaseChatViewModelProvider getProviderOverride(
    covariant SupabaseChatViewModelProvider provider,
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
  String? get name => r'supabaseChatViewModelProvider';
}

/// See also [SupabaseChatViewModel].
class SupabaseChatViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SupabaseChatViewModel, void> {
  /// See also [SupabaseChatViewModel].
  SupabaseChatViewModelProvider(
    String chatId,
  ) : this._internal(
          () => SupabaseChatViewModel()..chatId = chatId,
          from: supabaseChatViewModelProvider,
          name: r'supabaseChatViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$supabaseChatViewModelHash,
          dependencies: SupabaseChatViewModelFamily._dependencies,
          allTransitiveDependencies:
              SupabaseChatViewModelFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  SupabaseChatViewModelProvider._internal(
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
  FutureOr<void> runNotifierBuild(
    covariant SupabaseChatViewModel notifier,
  ) {
    return notifier.build(
      chatId,
    );
  }

  @override
  Override overrideWith(SupabaseChatViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: SupabaseChatViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<SupabaseChatViewModel, void>
      createElement() {
    return _SupabaseChatViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SupabaseChatViewModelProvider && other.chatId == chatId;
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
mixin SupabaseChatViewModelRef on AutoDisposeAsyncNotifierProviderRef<void> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _SupabaseChatViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SupabaseChatViewModel, void>
    with SupabaseChatViewModelRef {
  _SupabaseChatViewModelProviderElement(super.provider);

  @override
  String get chatId => (origin as SupabaseChatViewModelProvider).chatId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
