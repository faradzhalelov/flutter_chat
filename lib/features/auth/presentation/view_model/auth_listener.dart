
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
  
  // Methods to handle auth events...
  // lib/presentation/auth/viewmodel/auth_listener.dart

// Methods to handle auth events
void _handleSignIn() {
  // Navigate to home screen
  ref.read(appNavigatorProvider).goToHome();
  
  // Show welcome toast message
  _showToast('Добро пожаловать!');
  
  // Update user's online status
  _updateUserStatus(true);
}

void _handleSignOut() {
  // Navigation will happen automatically due to router redirect
  
  // Show goodbye toast message
  _showToast('Вы вышли из аккаунта');
  
  // Update user's status to offline before signing out
  _updateUserStatus(false);
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
      // Update user status in database
      await Supabase.instance.client
        .from('users')
        .update({
          'last_seen': DateTime.now().toIso8601String(),
          'is_online': isOnline,
        })
        .eq('id', user.id);
    }
  } catch (e) {
    // Silently handle errors
    debugPrint('Error updating user status: $e');
  }
}
}
