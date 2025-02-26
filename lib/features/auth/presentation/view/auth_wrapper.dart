// lib/presentation/auth/view/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_chat/features/auth/presentation/view_model/auth_listener.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A wrapper widget that initializes the auth listener
class AuthWrapper extends ConsumerWidget {
  
  const AuthWrapper({
    required this.child, super.key,
  });
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize auth listener
    ref.watch(authListenerProvider);
    
    // Return the child widget
    return child;
  }
}