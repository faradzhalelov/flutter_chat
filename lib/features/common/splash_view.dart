import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/core/auth/service/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashView extends ConsumerWidget {
  const SplashView({super.key});
    static const String routePath = 'splash';


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The router will automatically redirect based on auth state
    // after 2 seconds when authStateProvider is built
    ref.listen(authStateProvider, (_, __) {});
    
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
                Icons.chat_bubble_rounded,
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
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}