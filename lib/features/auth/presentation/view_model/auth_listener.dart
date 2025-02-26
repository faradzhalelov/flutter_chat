import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat/app/router/router.dart';
import 'package:flutter_chat/core/auth/service/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_listener.g.dart';

@Riverpod(keepAlive: true)
class AuthListener extends _$AuthListener {
  @override
  void build() {
    // Listen to auth state changes
    ref.listen(authStateProvider, _handleAuthStateChange);
  }
  
  void _handleAuthStateChange(AsyncValue<dynamic>? previous, AsyncValue<dynamic> current) {
    current.whenData((user) {
      final wasLoggedIn = previous?.valueOrNull != null;
      final isLoggedIn = user != null;
      
      // Handle sign in/out events
      if (!wasLoggedIn && isLoggedIn) {
        _handleSignIn();
      }
      
      if (wasLoggedIn && !isLoggedIn) {
        _handleSignOut();
      }
    });
  }
  
  // Handle sign-in event
  void _handleSignIn() {
    // First navigate to home screen
    ref.read(appNavigatorProvider).goToHome();
    
    // Show welcome toast message
    _showToast('Добро пожаловать!');
    
    // Update user's online status in the background
    _updateUserStatus(true);
  }
  
  // Handle sign-out event
  void _handleSignOut() {
    // First update user's status to offline before proceeding
    // But don't wait for it to complete - fire and forget
    _updateUserStatus(false);
    
    // Navigation will happen automatically due to router redirect
    
    // Show goodbye toast message
    _showToast('Вы вышли из аккаунта');
  }
  
  void _showToast(String message) {
    // Get the current context from scaffold messenger
    final context = ref.read(routerKeyProvider).currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  Future<void> _updateUserStatus(bool isOnline) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        // Set a timeout for the operation
        // Set a timeout using Future.timeout instead
        await Future.delayed(Duration.zero, () {}).timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw TimeoutException('Request timed out'),
          
        );
        
        await Supabase.instance.client
          .from('users')
          .update({
            'last_seen': DateTime.now().toIso8601String(),
            'is_online': isOnline,
          })
          .eq('id', user.id);
      }
    } catch (e) {
      // Log the error but don't let it affect the user experience
      debugPrint('Error updating user status: $e');
      
      // If it's a connection error during sign-in, we can retry once with a delay
      // but only during sign-in (when isOnline is true)
      if (isOnline) {
        await _retryUpdateUserStatus(isOnline);
      }
    }
  }
  
  // Retry the user status update after a delay
  Future<void> _retryUpdateUserStatus(bool isOnline) async {
    try {
      // Wait a bit for network to stabilize
      await Future.delayed(const Duration(seconds: 2), () {});
      
      final user = ref.read(currentUserProvider);
      if (user != null) {
        // Set a timeout using Future.timeout
        await Future.delayed(Duration.zero, () {}).timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw TimeoutException('Request timed out'),
        );
        
        await Supabase.instance.client
          .from('users')
          .update({
            'last_seen': DateTime.now().toIso8601String(),
            'is_online': isOnline,
          })
          .eq('id', user.id);
      }
    } catch (e) {
      // Log but ignore the error on retry
      debugPrint('Retry failed to update user status: $e');
    }
  }
}