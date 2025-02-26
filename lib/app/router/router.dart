// lib/core/router/app_router.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/icons.dart';
import 'package:flutter_chat/core/auth/service/auth_service.dart';
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
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/${SplashView.routePath}',
    debugLogDiagnostics: true,
    navigatorKey: ref.read(routerKeyProvider),
    observers: [
      MyNavigatorObserver(),
    ],
    // Global redirect based on authentication state
   redirect: (context, state) {
  // Для отладки
  log('Current route: ${state.uri.path}, Auth state: ${authState.toString()}');

  // Текущий путь и проверки аутентификации
  final currentPath = state.uri.path;
  final isAuthScreen = currentPath == '/${LoginView.routePath}' ||
      currentPath == '/${RegisterView.routePath}';
  final isSplashScreen = currentPath == '/${SplashView.routePath}';

  // Если состояние аутентификации находится в состоянии загрузки
  if (authState.isLoading) {
    // Если мы не на экране сплеша, перенаправляем на сплеш
    return isSplashScreen ? null : '/${SplashView.routePath}';
  }

  // Если мы на сплеш-экране после загрузки
  if (isSplashScreen) {
    // Перенаправляем в зависимости от наличия пользователя
    return authState.valueOrNull != null ? '/' : '/${LoginView.routePath}';
  }

  // Если не аутентифицирован, пускаем только на экраны входа/регистрации
  if (authState.valueOrNull == null) {
    return isAuthScreen ? null : '/${LoginView.routePath}';
  }

  // Если аутентифицирован и пытается попасть на экран входа/регистрации
  if (authState.valueOrNull != null && isAuthScreen) {
    return '/';
  }

  // Никаких перенаправлений
  return null;
},

    // Error handling
    errorBuilder: (context, state) => Scaffold(
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
    ),

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
          final chatId = state.pathParameters['chatId']!;
          return ChatView(chatId: chatId);
        },
      ),
      GoRoute(
        path: '/${ProfileView.routePath}',
        builder: (context, state) => const ProfileView(),
      ),
    ],
  );
}

/// Provider for router key to force rebuild when needed
@riverpod
GlobalKey<NavigatorState> routerKey(Ref ref) => GlobalKey<NavigatorState>();

/// Provider for navigating programmatically from anywhere
@riverpod
AppNavigator appNavigator(Ref ref) => AppNavigator(ref);

/// Helper class for navigation from anywhere in the app
class AppNavigator {
  AppNavigator(this._ref);

  final Ref _ref;

  /// Get the GoRouter instance
  GoRouter get _router => _ref.read(appRouterProvider);

  /// Navigate to home screen
  void goToHome() => _router.go('/');

  /// Navigate to login screen
  void goToLogin() => _router.go('/${LoginView.routePath}');

  /// Navigate to register screen
  void goToRegister() => _router.go('/${RegisterView.routePath}');

  /// Navigate to chat screen
  void goToChat(String chatId) => _router.go('/${ChatView.routePath}/$chatId');

  /// Navigate to profile screen
  void goToProfile() => _router.go('/${ProfileView.routePath}');

  /// Navigate to splash screen
  void goToSplash() => _router.go('/${SplashView.routePath}');

  /// Go back to previous screen
  void goBack() => _router.pop();
}

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
