// features/chat_list/presentation/view_models/chat_list_view_model.dart
import 'dart:async';
import 'package:flutter_chat/core/supabase/repository/provider/supabase_repository_provider.dart';
import 'package:flutter_chat/features/chat_list/data/models/chat.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_list_view_model.g.dart';

@riverpod
class ChatListViewModel extends _$ChatListViewModel {
  @override
  AsyncValue<List<ChatModel>> build() {
    final repository = ref.watch(supabaseRepositoryProvider);
    repository.subscribeToChats().listen(
      (chats) {
        state = AsyncValue.data(chats);
      },
      onError: (e, s) => state = AsyncError(e as Object, s as StackTrace),
    );
    return const AsyncValue.loading();
  }

  Future<String?> createChat(String otherUserId) async {
    final repository = ref.read(supabaseRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      final chatId = await repository.createChat(otherUserId);
      return chatId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteChat(String chatId) async {
    final repository = ref.read(supabaseRepositoryProvider);
    final previousState = state;
    try {
      await repository.deleteChat(chatId);
      //await refresh();
    } catch (error) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> refresh() async => _refreshChats();

  Future<void> _refreshChats() async {
    final repository = ref.read(supabaseRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      final chats = await repository.getAllChats();
      state = AsyncValue.data(chats);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
