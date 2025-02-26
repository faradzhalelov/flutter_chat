import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

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
  
  
  // Access current user
  static User? get currentUser => supabase.auth.currentUser;
  
  // Authentication methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    
    if (response.user != null) {
      // Create user profile in the users table
      await supabase.from('users').insert({
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
  }) => supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  
  static Future<void> signOut() => supabase.auth.signOut();
}
