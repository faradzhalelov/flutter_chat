import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_service.g.dart';


@riverpod
SupabaseClient supabase(Ref ref) => Supabase.instance.client;

class SupabaseService {

  static Future<void> initialize() async {
    await dotenv.load(fileName: "assets/supabase/.env");
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw FileNotFoundError();
    }
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: kDebugMode,
    );
  }
  
  // Access client from anywhere in the app
  static SupabaseClient get client => Supabase.instance.client;
  
  // Access current user
  static User? get currentUser => client.auth.currentUser;
  
  // Authentication methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    
    if (response.user != null) {
      // Create user profile in the users table
      await client.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'username': username,
      });
    }
    
    return response;
  }
  
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) => client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  
  static Future<void> signOut() => client.auth.signOut();
}
