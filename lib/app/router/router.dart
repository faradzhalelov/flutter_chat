// lib/core/router/app_router.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat/app/database/dto/user_dto.dart';
import 'package:flutter_chat/app/theme/icons.dart';
import 'package:flutter_chat/app/theme/text_styles.dart';
import 'package:flutter_chat/features/auth/presentation/view/login_view.dart';
import 'package:flutter_chat/features/auth/presentation/view/register_view.dart';
import 'package:flutter_chat/features/chat/presentation/view/chat_view.dart';
import 'package:flutter_chat/features/chat_list/presentation/view/chat_list_view.dart';
import 'package:flutter_chat/features/common/splash_view.dart';
import 'package:flutter_chat/features/profile/presentation/view/profile_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// Router configuration for the app using GoRouter
@riverpod
GoRouter appRouter(Ref ref) => GoRouter(
    initialLocation: '/${SplashView.routePath}',
    debugLogDiagnostics: true,
    navigatorKey: ref.watch(routerKeyProvider),
    observers: [
      MyNavigatorObserver(),
    ],

    // Error handling
    errorBuilder: (context, state) => ErrorView(state),

    // Define routes
    routes: [
      // Splash screen route - always accessible
      GoRoute(
        path: '/${SplashView.routePath}',
        builder: (context, state) => const SplashView(),
      ),

      // Authentication routes
      GoRoute(
        path: '/${LoginView.routePath}',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/${RegisterView.routePath}',
        builder: (context, state) => const RegisterView(),
      ),

      // Main app routes
      GoRoute(
        path: '/',
        builder: (context, state) => const ChatListView(),
      ),
      GoRoute(
        path: '/${ChatView.routePath}/:chatId',
        builder: (context, state) {
          final pathParameters = state.pathParameters;
          final extra = state.extra as Map<String, dynamic>?;
          final chatId = pathParameters['chatId']!;
          final otherUser = extra?['otherUser'] as UserDto?;
          return ChatView(chatId: chatId, otherUser: otherUser,);
        },
      ),
      GoRoute(
        path: '/${ProfileView.routePath}',
        builder: (context, state) => const ProfileView(),
      ),
    ],
  );

/// Provider for router key to force rebuild when needed
@riverpod
GlobalKey<NavigatorState> routerKey(Ref ref) => GlobalKey<NavigatorState>();



class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    log('Pushed route: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    log('Popped route: ${route.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    log('Removed route: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    log('Replaced route: ${newRoute?.settings.name}');
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView(this.state, {super.key});
  final GoRouterState state;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icomoon.error,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Страница не найдена: ${state.uri.path}',
                style: AppTextStyles.medium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/'),
                child: const Text('Вернуться на главную'),
              ),
            ],
          ),
        ),
      );
}
