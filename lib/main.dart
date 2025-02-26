import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat/app/app.dart';
import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //TODO: zoneGuard, crash analytics, error handler
  try {
    await SupabaseService.initialize();
  } catch (e) {
    log('Error init main: $e');
  }
  runApp(const ProviderScope(child: MyApp()));
}
