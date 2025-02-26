import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/app/app.dart';
import 'package:flutter_chat/app/error_app.dart';
import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  //todo: zoneGuard, crash analytics, error handler
  try {
    await SupabaseService.initialize();
    runApp(
      const ProviderScope(
        child:  MyApp(),
      ),
    );
  } catch (e) {
    log('Error init main: $e');
    runApp(ErrorApp(e: e));
  }
}
