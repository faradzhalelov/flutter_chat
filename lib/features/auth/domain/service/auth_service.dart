// lib/core/services/auth_service.dart
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat/app/database/dto/user_dto.dart';
import 'package:flutter_chat/features/common/splash_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    // Начинаем с попытки получить текущего пользователя
    final currentUser = supabase.Supabase.instance.client.auth.currentUser;

    // Если пользователь уже есть, возвращаем его немедленно
    if (currentUser != null) {
      return AsyncData(currentUser);
    }

    // Подписываемся на изменения состояния аутентификации
    supabase.Supabase.instance.client.auth.onAuthStateChange.listen(
      (event) {
        // Обновляем состояние только при реальных изменениях
        if (event.event == supabase.AuthChangeEvent.signedIn) {
          state = AsyncData(event.session?.user);
        } else if (event.event == supabase.AuthChangeEvent.signedOut) {
          state = const AsyncData(null);
        }
      },
      onError: (e) {
        state = AsyncError(e as Object, StackTrace.current);
      },
    );

    // Возвращаем начальное состояние
    return const AsyncLoading();
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
          'Ошибка авторизации: Пользователь не найден',
        );
      }
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
  Future<void> signOut(BuildContext context) async {
    state = const AsyncLoading();
    try {
      await supabase.Supabase.instance.client.auth.signOut().whenComplete(() {
        state = const AsyncData(null);
        if (context.mounted) {
        context.go('/${SplashView.routePath}');
      }
      });
      
      
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
      rethrow;
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
Future<UserDto> userProfile(Ref ref) async {
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

    return UserDto.fromSupabase(response);
  } catch (e) {
    throw Exception('Failed to load user profile: $e');
  }
}
