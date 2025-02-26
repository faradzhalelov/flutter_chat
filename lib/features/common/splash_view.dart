import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/app/theme/icons.dart';
import 'package:flutter_chat/core/auth/service/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashView extends ConsumerWidget {
  const SplashView({super.key});
  static const String routePath = 'splash';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes
    ref.listen(authStateProvider, (previous, current) {
      // The router will handle redirects based on auth state
      // This listener is important to ensure the provider is watched
    });
    
    // Deliberately not starting a timer or redirect here
    // The router will handle redirects after auth state is determined
    
    return Scaffold(
      backgroundColor: AppColors.headerBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.myMessageBubble,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icomoon.messageFill,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            
            // App name
            const Text(
              'Flutter Messenger',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Tagline
            const Text(
              'Общайтесь без границ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            
            // Always show loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}