// features/chat_list/presentation/view_models/chat_list_view_model.dart
import 'dart:async';

import 'package:flutter_chat/core/supabase/repository/supabase_repository.dart';
import 'package:flutter_chat/features/chat/data/models/chat.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_list_view_model.g.dart';

@riverpod
class ChatListViewModel extends _$ChatListViewModel {
  @override
  AsyncValue<List<ChatModel>> build() {
    final repository = ref.read(chatRepositoryProvider);
    repository.getChatsForCurrentUserStream().listen((chats) {
      state =  AsyncValue.data(chats);
    }, onError: (e,s) => state = AsyncError(e as Object, s as StackTrace),);
    return const AsyncValue.loading();
  }

  Future<String> createChat(String otherUserId) async {
    final repository = ref.read(chatRepositoryProvider);
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
    final repository = ref.read(chatRepositoryProvider);
    final previousState = state;

    try {
      if (state is AsyncData<List<ChatModel>>) {
        final currentChats = (state as AsyncData<List<ChatModel>>).value;
        state = AsyncValue.data(
          currentChats.where((chat) => chat.id != chatId).toList(),
        );
      }
      await repository.deleteChat(chatId);
    } catch (error) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> refresh() async => _refreshChats();
  
  Future<void> _refreshChats() async {
    final repository = ref.read(chatRepositoryProvider);
    state = const AsyncValue.loading();
    
    try {
      final chats = await repository.getChatsForCurrentUser();
      state = AsyncValue.data(chats);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

}
