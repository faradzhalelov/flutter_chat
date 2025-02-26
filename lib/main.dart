import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/app/app.dart';
import 'package:flutter_chat/app/error_app.dart';
import 'package:flutter_chat/core/di/di.dart';
import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Create ProviderContainer for dependency injection
  final container = ProviderContainer();

  //todo: zoneGuard, crash analytics, error handler
  try {
    await SupabaseService.initialize();
    // Initialize dependencies
    DependencyInjection.init(container);
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
  } catch (e) {
    log('Error init main: $e');
    runApp(ErrorApp(e: e));
  }
}
