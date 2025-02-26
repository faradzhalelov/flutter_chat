// lib/core/services/auth_service.dart
import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

part 'auth_service.g.dart';

/// Provider for the current auth session
@riverpod
Stream<supabase.AuthState> authSessionStream(Ref ref) =>
    supabase.Supabase.instance.client.auth.onAuthStateChange;

/// Provider for the current auth user
@riverpod
supabase.User? currentUser(Ref ref) {
  final authState = ref.watch(authSessionStreamProvider).valueOrNull;
  return authState?.session?.user;
}

/// Provider for auth state to manage authentication
@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<supabase.User?> build() {
    final authStream = ref.watch(authSessionStreamProvider);

    // Set initial state based on current auth stream value
    return authStream.when(
      data: (authState) => AsyncData(authState.session?.user),
      loading: () => const AsyncLoading(),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
    );
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    log('signIn start');
    state = const AsyncLoading();
    
    try {
      final response =
          await supabase.Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AsyncData(response.user);
        log('signIn response success:${response.user}');
      } else {
        state = AsyncError(
          'Failed to sign in: No user returned',
          StackTrace.current,
        );
        throw const supabase.AuthException(
            'Ошибка авторизации: Пользователь не найден',);
      }
      log('signIn finish');
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await supabase.Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user != null) {
        // Create user profile in the users table
        await supabase.Supabase.instance.client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'username': username,
          'created_at': DateTime.now().toIso8601String(),
          'last_seen': DateTime.now().toIso8601String(),
        });

        state = AsyncData(response.user);
      } else {
        state = AsyncError(
          'Failed to sign up: No user returned',
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = const AsyncLoading();

    try {
      await supabase.Supabase.instance.client.auth.signOut();
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();

    try {
      await supabase.Supabase.instance.client.auth.resetPasswordForEmail(email);
      state = state; // Keep the current state
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required String username,
    File? avatarFile,
  }) async {
    state = const AsyncLoading();

    try {
      final user = state.valueOrNull;
      if (user == null) {
        state = AsyncError('Not authenticated', StackTrace.current);
        return;
      }

      String? avatarUrl;

      // Upload avatar if provided
      if (avatarFile != null) {
        final fileExt = path.extension(avatarFile.path);
        final fileName = '${user.id}$fileExt';

        await supabase.Supabase.instance.client.storage.from('avatars').upload(
              fileName,
              avatarFile,
              fileOptions: const supabase.FileOptions(upsert: true),
            );

        avatarUrl = supabase.Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);
      }

      // Update user profile
      await supabase.Supabase.instance.client.from('users').update({
        'username': username,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'last_seen': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      // Return the current user
      state = AsyncData(user);
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
    }
  }

  /// Helper method to handle auth errors
  String _handleAuthError(dynamic error) {
    if (error is supabase.AuthException) {
      return 'Authentication error: ${error.message}';
    } else {
      return 'Unexpected error: $error';
    }
  }
}

/// Provider for current user profile data
@riverpod
Future<Map<String, dynamic>> userProfile(Ref ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    throw Exception('Not authenticated');
  }

  try {
    final response = await supabase.Supabase.instance.client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return response;
  } catch (e) {
    throw Exception('Failed to load user profile: $e');
  }
}
