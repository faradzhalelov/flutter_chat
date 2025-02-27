import 'dart:developer';

import 'package:flutter_chat/features/chat_list/data/models/chat.dart';
import 'package:flutter_chat/features/chat_list/data/models/chat_member.dart';
import 'package:flutter_chat/features/chat_list/data/repositories/chat_list_repository.dart';
import 'package:flutter_chat/features/profile/data/models/user.dart';

class ChatListRepositoryImpl implements ChatListRepository {
  @override
  Future<String> createChat(String otherUserId) async {
    try {
      final createdChat = '';
      //create chat in db
      //create chat in supabase
      return createdChat;
    } catch (e) {
      log('createChat error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteChat(String chatId) async {
    try {
      //delete chat in db
      //delete chat in supabase
    } catch (e) {
      log('deleteChat error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ChatMemberModel>> getChatMembers(String chatId) async {
    try {
      //load members from supabase
      //add in drift
      //return chat members
      return [];
    } catch (e) {
      log('getChatMembers error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ChatModel>> getChatsForCurrentUser() async {
   try {
      //load chats from supabase
      //update in drift
      //return chats
      return [];
    } catch (e) {
      log('getChatsForCurrentUser error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<ChatModel>> getChatsForCurrentUserStream()  {
    try {
      //load chats from supabase
      //update in drift
      //return chats
      return const Stream.empty();
    } catch (e) {
      log('getChatsForCurrentUserStream error: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
     try {
      //load chats from supabase
      //update in drift
      //return chats
      return UserModel(id: 'id', email: 'email', username: 'username', createdAt: DateTime.now());
    } catch (e) {
      log('getUserById error: $e');
      rethrow;
    }
  }
}
