// features/chat_list/presentation/view_models/chat_list_view_model.dart
import 'dart:async';

import 'package:flutter_chat/core/supabase/repository/supabase_repository.dart';
import 'package:flutter_chat/features/chat/data/models/chat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_list_view_model.g.dart';

@riverpod
class ChatListViewModel extends _$ChatListViewModel {
  StreamSubscription<List<ChatModel>>? _subscription;

  @override
  AsyncValue<List<ChatModel>> build() {
    
    // Initialize the state with loading
    ref.onDispose(() {
      _subscription?.cancel();
    });
    
    _listenToChats();
    
    return const AsyncValue.loading();
  }
  
  void _listenToChats() {
    final repository = ref.read(chatRepositoryProvider);
    
    _subscription?.cancel();
    _subscription = repository.getChatsForCurrentUserStream().listen(
      (chats) {
        state = AsyncValue.data(chats);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error as Object, stackTrace as StackTrace);
      },
    );
  }

  Future<String> createChat(String otherUserId) async {
    final repository = ref.read(chatRepositoryProvider);
    
    state = const AsyncValue.loading();
    
    try {
      final chatId = await repository.createChat(otherUserId);
      // Force an immediate refresh to update UI
      await _refreshChats();
      return chatId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteChat(String chatId) async {
    final repository = ref.read(chatRepositoryProvider);
    
    // Store previous state for rollback if needed
    final previousState = state;
    
    try {
      // Optimistically update UI by removing the chat from the list
      if (state is AsyncData<List<ChatModel>>) {
        final currentChats = (state as AsyncData<List<ChatModel>>).value;
        state = AsyncValue.data(
          currentChats.where((chat) => chat.id != chatId).toList(),
        );
      }
      
      // Perform the actual deletion
      await repository.deleteChat(chatId);
    } catch (error) {
      // Restore previous state if deletion fails
      state = previousState;
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _refreshChats();
  }
  
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

// Provider for creating chats
@riverpod
Future<String> createChat(Ref ref, String otherUserId) async {
  final viewModel = ref.watch(chatListViewModelProvider.notifier);
  return viewModel.createChat(otherUserId);
}