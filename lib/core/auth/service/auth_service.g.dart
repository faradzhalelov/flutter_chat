// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authSessionStreamHash() => r'93d0395d9fac24d208f58d035cbb9fd9ef804061';

/// Provider for the current auth session
///
/// Copied from [authSessionStream].
@ProviderFor(authSessionStream)
final authSessionStreamProvider =
    AutoDisposeStreamProvider<supabase.AuthState>.internal(
  authSessionStream,
  name: r'authSessionStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authSessionStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthSessionStreamRef = AutoDisposeStreamProviderRef<supabase.AuthState>;
String _$currentUserHash() => r'8f5cdcb515448310f4746c702ba53d2d23a4cff0';

/// Provider for the current auth user
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<supabase.User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<supabase.User?>;
String _$userProfileHash() => r'16f41a87dc097b01de08e5292fbc98b6719e653c';

/// Provider for current user profile data
///
/// Copied from [userProfile].
@ProviderFor(userProfile)
final userProfileProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  userProfile,
  name: r'userProfileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$authStateHash() => r'699b9b1a7efef5014999fbf4403a13eb8755a5ef';

/// Provider for auth state to manage authentication
///
/// Copied from [AuthState].
@ProviderFor(AuthState)
final authStateProvider =
    AutoDisposeNotifierProvider<AuthState, AsyncValue<supabase.User?>>.internal(
  AuthState.new,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthState = AutoDisposeNotifier<AsyncValue<supabase.User?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
