// lib/core/di/dependency_injection.dart
import 'package:flutter_chat/core/supabase/repository/chat_repository.dart';
import 'package:flutter_chat/core/supabase/repository/supabase_repository.dart';
import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A class that registers all dependencies for the application
class DependencyInjection {
  /// Initialize all dependencies
  static void init(ProviderContainer container) {
    // Register services and repositories here if needed
  }

  /// Register chat repository for testing
  static void registerMockChatRepository(ProviderContainer container, ChatRepository mockRepository) {
    container.updateOverrides([
      chatRepositoryProvider.overrideWithValue(mockRepository),
    ]);
  }
  
}

/// Provider for selecting the appropriate chat repository implementation based on environment
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return SupabaseChatRepository(client);
});
