// lib/data/repositories/supabase_chat_repository.dart

import 'package:flutter_chat/core/supabase/repository/supabase_repository.dart';
import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/chat_list/data/models/chat.dart';
import 'package:flutter_chat/features/chat_list/data/models/chat_member.dart';
import 'package:flutter_chat/features/profile/data/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of ChatRepository using Supabase as the backend
class SupabaseRepositoryImpl implements SupabaseRepository  {
  
  
  /// Gets the current user ID or throws an exception if not authenticated
  String get _currentUserId {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    return userId;
  }
  
  @override
  Stream<List<ChatModel>> subscribeToChats() {
    try {
      final userId = _currentUserId;
      
      // Listen to both chats and chat_members to catch all updates
      return supabase
        .from('chat_members')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((event) => event)
        .asyncMap((chatMemberData) async {
          // Extract all chat IDs for this user
          final chatIds = chatMemberData
              .map((item) => item['chat_id'] as String)
              .toList();
          
          if (chatIds.isEmpty) return <ChatModel>[];
          
          // Get all chats with their latest data
          final chatsResponse = await supabase
              .from('chats')
              .select()
              .filter('id', 'in', chatIds);
          
          // Process chats in parallel for better performance
          final futures = chatsResponse.map((chatData) async {
            final chatId = chatData['id'] as String;
            
            // Get other members
            final otherMembersResponse = await supabase
                .from('chat_members')
                .select('user_id')
                .eq('chat_id', chatId)
                .neq('user_id', userId);
            
            if (otherMembersResponse.isEmpty) return null;
            
            // Get other user data
            final otherUserId = otherMembersResponse[0]['user_id'] as String;
            final otherUser = await getUser(otherUserId);
            
            return ChatModel.fromSupabase(chatData, otherUser);
          });
          
          // Wait for all futures and filter out nulls
          final results = await Future.wait(futures);
          return results.whereType<ChatModel>().toList();
        });
    } catch (e) {
      throw _handleError(e);
    }
  }

@override
Future<List<ChatModel>> getAllChats() async {
  try {
    final userId = _currentUserId;
    
    // Get all chat memberships for the current user
    final chatMemberData = await supabase
      .from('chat_members')
      .select()
      .eq('user_id', userId);
    
    // Extract chat IDs
    final chatIds = chatMemberData
      .map((item) => item['chat_id'] as String)
      .toList();
    
    if (chatIds.isEmpty) return [];
    
    // Get all chats with their latest data
    final chatsResponse = await supabase
      .from('chats')
      .select()
      .filter('id', 'in', chatIds);
    
    // Process chats in parallel for better performance
    final futures = chatsResponse.map((chatData) async {
      final chatId = chatData['id'] as String;
      
      // Get other members
      final otherMembersResponse = await supabase
        .from('chat_members')
        .select('user_id')
        .eq('chat_id', chatId)
        .neq('user_id', userId);
      
      if (otherMembersResponse.isEmpty) return null;
      
      // Get other user data
      final otherUserId = otherMembersResponse[0]['user_id'] as String;
      final otherUser = await getUser(otherUserId);
      
      return ChatModel.fromSupabase(chatData, otherUser);
    });
    
    // Wait for all futures and filter out nulls
    final results = await Future.wait(futures);
    return results.whereType<ChatModel>().toList();
  } catch (e) {
    throw _handleError(e);
  }
}

  @override
  Future<List<MessageModel>> getMessagesForChat(String chatId) async {
    try {
      final userId = _currentUserId;
      
      final response = await supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId);
      
      return response
        .whereType<Map<String, dynamic>>()
        .map((messageData) => 
          MessageModel.fromSupabase(messageData, userId),
        ).toList();

    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<String> createChat(String otherUserId) async {
    try {
      final userId = _currentUserId;
      // Check if a chat already exists between these users
      final existingChat = await _findExistingChat(userId, otherUserId);
      if (existingChat != null) return existingChat;

      // Create a new chat
      final chatResponse = await supabase
          .from('chats')
          .insert({
            'created_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select()
          .single();

      final chatId = chatResponse['id'] as String;

      // Add both users to the chat (this should trigger the stream)
      await supabase.from('chat_members').insert([
        {'chat_id': chatId, 'user_id': userId},
        {'chat_id': chatId, 'user_id': otherUserId},
      ]);

      // To be extra sure, send a dummy update to the chat
      await Future.delayed(const Duration(milliseconds: 100), () {});
      await supabase.from('chats').update({}).eq('id', chatId);

      return chatId;
    } catch (e) {
      throw _handleError(e);
    }
  }

  
  /// Helper method to find an existing chat between two users
  Future<String?> _findExistingChat(String userId, String otherUserId) async {
    try {
      // Find chats where the current user is a member
      final userChatsResponse = await supabase
        .from('chat_members')
        .select('chat_id')
        .eq('user_id', userId);
      
      final chatIds = userChatsResponse.map((item) => item['chat_id'] as String).toList();
      if (chatIds.isEmpty) return null;
      
      // Find which of those chats the other user is also a member of
      final otherUserChatsResponse = await supabase
        .from('chat_members')
        .select('chat_id')
        .eq('user_id', otherUserId)
        .filter('chat_id', 'in', chatIds);
      
      if (otherUserChatsResponse.isEmpty) {
        return null;
      }
      
      // Check if this is a 1:1 chat (only 2 members)
      final chatId = otherUserChatsResponse[0]['chat_id'] as String;
      
      // Count members in the chat
      final membersCountResponse = await supabase
        .from('chat_members')
        .select()
        .eq('chat_id', chatId);
      
      final membersCount = membersCountResponse.length;
      if (membersCount == 2) {
        return chatId;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<MessageModel> sendMessage(String chatId, String? text, String? attachmentUrl,String? attachmentName,MessageType messageType) async {
    try {
      final userId = _currentUserId;
      
      final messageData = {
        'chat_id': chatId,
        'user_id': userId,
        'content': text ?? '',
        'message_type': messageType.name,
        'attachment_url' : attachmentUrl,
        'attachment_name' : attachmentName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };
      
      final response = await supabase
        .from('messages')
        .insert(messageData)
        .select()
        .single();
      
      await _updateChat(chatId, userId, text,messageType);
      
      return MessageModel.fromSupabase(response, userId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update the last_message_at timestamp in a chat
  Future<void> _updateChat(String chatId, String userId, String? text, MessageType messageType) async {
    try {
      await supabase
        .from('chats')
        .update({
          'last_message_at': DateTime.now().toIso8601String(),
          'last_message_text' : text,
          'last_message_type' : messageType.name,
          'last_message_user_id': userId,
        })
        .eq('id', chatId);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final userId = _currentUserId;
      
      await supabase
        .from('messages')
        .update({'is_read': true})
        .eq('chat_id', chatId)
        .neq('user_id', userId)
        .eq('is_read', false);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<void> deleteChat(String chatId) async {
    try {
      // This will cascade delete all messages and chat_members due to FK constraints
      await supabase.from('chats').delete().eq('id', chatId);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Stream<MessageModel> subscribeToMessages(String chatId) {
    try {
      final userId = _currentUserId;
      
      return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .map((event) {
          if (event is Map<String, dynamic>) {
            return MessageModel.fromSupabase(event as Map<String, dynamic>, userId);
          } 
          // For other Supabase versions where event is a RealtimeMessage
          else if (event.isNotEmpty) {
            return MessageModel.fromSupabase(event.first, userId);
          } else {
            throw Exception('Invalid message format in stream: ${event.runtimeType}');
          }
        });
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<List<ChatMemberModel>> getChatMembers(String chatId) async {
    try {
      final response = await supabase
        .from('chat_members')
        .select()
        .eq('chat_id', chatId);
      
      return response
        .whereType<Map<String, dynamic>>()
        .map((data) => 
          ChatMemberModel.fromSupabase(data),
        ).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<UserModel> getUser(String userId) async {
    try {
      final response = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();
      
      return UserModel.fromSupabase(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

    
  /// Handles errors from Supabase and converts them to more user-friendly exceptions
  Exception _handleError(dynamic error) {
    if (error is PostgrestException) {
      return Exception('Database error: ${error.message}');
    } else if (error is StorageException) {
      return Exception('Storage error: ${error.message}');
    } else if (error is AuthException) {
      return Exception('Authentication error: ${error.message}');
    } else {
      return Exception('Unexpected error: $error');
    }
  }
  

}
