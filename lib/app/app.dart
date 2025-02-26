// lib/app.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat/app/router/router.dart';
import 'package:flutter_chat/app/theme/theme.dart';
import 'package:flutter_chat/core/lifecycle/lifecycle.dart';
import 'package:flutter_chat/features/auth/presentation/view/auth_wrapper.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The main application widget that configures theme, localization, and routing.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return AppLifecycleManager(
      child: AuthWrapper(
        child: ErrorHandler(
          child: MaterialApp.router(
            title: 'Flutter Messenger',
            theme: AppTheme.theme,
            // Set up router configuration
            routerConfig: router,
            // Set up localization
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ru', ''), // Russian (primary)
              Locale('en', ''), // English (fallback)
            ],
            // Default locale
            locale: const Locale('ru', ''),
            // Hide debug banner
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}


/// Widget that handles uncaught exceptions in the application.
class ErrorHandler extends StatefulWidget {

  const ErrorHandler({
    required this.child, super.key,
  });
  final Widget child;

  @override
  State<ErrorHandler> createState() => _ErrorHandlerState();
}

class _ErrorHandlerState extends State<ErrorHandler> {
  late Widget _currentWidget;
  
  @override
  void initState() {
    super.initState();
    _currentWidget = widget.child;
    
    // Set up error handling for async errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _handleError(details.exception, details.stack);
    };
    
    // Handle zone errors
    runZonedGuarded(() {}, (error, stack) {
      _handleError(error, stack);
    });
  }
  
  void _handleError(dynamic error, StackTrace? stack) {
    // Only update UI if mounted and not in production
    if (mounted) {
      setState(() {
        _currentWidget = _buildErrorWidget(error, stack);
      });
    }
  }
  
  Widget _buildErrorWidget(dynamic error, StackTrace? stack) => Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Произошла ошибка',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentWidget = widget.child;
                    });
                  },
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  
  @override
  Widget build(BuildContext context) => _currentWidget;
}
