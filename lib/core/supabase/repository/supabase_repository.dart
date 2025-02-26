// lib/data/repositories/supabase_chat_repository.dart
import 'dart:io';

import 'package:flutter_chat/core/supabase/repository/chat_repository.dart';
import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_chat/features/chat/data/models/chat.dart';
import 'package:flutter_chat/features/chat/data/models/chat_member.dart';
import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/chat/data/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Implementation of ChatRepository using Supabase as the backend
class SupabaseChatRepository implements ChatRepository {
  
  SupabaseChatRepository(this._client);
  final SupabaseClient _client;
  
  /// Gets the current user ID or throws an exception if not authenticated
  String get _currentUserId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    return userId;
  }
  
  @override
  Future<List<ChatModel>> getChatsForCurrentUser() async {
    try {
      final userId = _currentUserId;
      
      // Get all chats that the user is a member of
      final chatMembersResponse = await _client
        .from('chat_members')
        .select('chat_id')
        .eq('user_id', userId);
      
      final chatIds = chatMembersResponse.map((item) => item['chat_id'] as String).toList();
      if (chatIds.isEmpty) return [];
      
      // Get chat details - using "in" filter instead of "in_"
      final chatsResponse = await _client
        .from('chats')
        .select()
        .filter('id', 'in', chatIds)
        .order('last_message_at', ascending: false);
      
      final chats = <ChatModel>[];
      
      for (final chatData in chatsResponse) {
        final otherMembersResponse = await _client
          .from('chat_members')
          .select('user_id')
          .eq('chat_id', chatData['id'] as String)
          .neq('user_id', userId);
        
        if (otherMembersResponse.isEmpty) continue;
        
        // Get the other user's details
        final otherUserId = otherMembersResponse[0]['user_id'];
        final userResponse = await _client
          .from('users')
          .select()
          .eq('id', otherUserId as String)
          .single();
        
        // Get the last message
        final lastMessageResponse = await _client
          .from('messages')
          .select()
          .eq('chat_id', chatData['id'] as String)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
        
        final otherUser = UserModel.fromSupabase(userResponse);
        
        MessageModel? lastMessage;
        if (lastMessageResponse != null) {
          lastMessage = MessageModel.fromSupabase(lastMessageResponse, userId);
        }
        
        chats.add(ChatModel.fromSupabase(chatData, otherUser, lastMessage));
      }
      
      return chats;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<List<MessageModel>> getMessagesForChat(String chatId) async {
    try {
      final userId = _currentUserId;
      
      final response = await _client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at');
      
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
      final chatResponse = await _client
        .from('chats')
        .insert({
          'created_at': DateTime.now().toIso8601String(),
          'last_message_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
      
      final chatId = chatResponse['id'] as String;
      
      // Add both users to the chat
      await _client.from('chat_members').insert([
        {'chat_id': chatId, 'user_id': userId},
        {'chat_id': chatId, 'user_id': otherUserId},
      ]);
      
      return chatId;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Helper method to find an existing chat between two users
  Future<String?> _findExistingChat(String userId, String otherUserId) async {
    try {
      // Find chats where the current user is a member
      final userChatsResponse = await _client
        .from('chat_members')
        .select('chat_id')
        .eq('user_id', userId);
      
      final chatIds = userChatsResponse.map((item) => item['chat_id'] as String).toList();
      if (chatIds.isEmpty) return null;
      
      // Find which of those chats the other user is also a member of
      final otherUserChatsResponse = await _client
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
      final membersCountResponse = await _client
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
  Future<MessageModel> sendTextMessage(String chatId, String text) async {
    try {
      final userId = _currentUserId;
      
      final messageData = {
        'chat_id': chatId,
        'user_id': userId,
        'content': text,
        'message_type': 'text',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };
      
      final response = await _client
        .from('messages')
        .insert(messageData)
        .select()
        .single();
      
      await _updateChatLastMessageTime(chatId);
      
      return MessageModel.fromSupabase(response, userId);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<MessageModel> sendImageMessage(String chatId, File imageFile) async {
    try {
      final attachment = await _uploadAttachment(imageFile, 'image');
      return _sendAttachmentMessage(
        chatId: chatId, 
        attachmentUrl: attachment.url,
        attachmentName: attachment.name,
        messageType: 'image',
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<MessageModel> sendVideoMessage(String chatId, File videoFile) async {
    try {
      final attachment = await _uploadAttachment(videoFile, 'video');
      return _sendAttachmentMessage(
        chatId: chatId, 
        attachmentUrl: attachment.url,
        attachmentName: attachment.name,
        messageType: 'video',
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<MessageModel> sendFileMessage(String chatId, File file) async {
    try {
      final attachment = await _uploadAttachment(file, 'file');
      return _sendAttachmentMessage(
        chatId: chatId, 
        attachmentUrl: attachment.url,
        attachmentName: attachment.name,
        messageType: 'file',
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<MessageModel> sendAudioMessage(String chatId, File audioFile) async {
    try {
      final attachment = await _uploadAttachment(audioFile, 'audio');
      return _sendAttachmentMessage(
        chatId: chatId, 
        attachmentUrl: attachment.url,
        attachmentName: attachment.name,
        messageType: 'audio',
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Helper method to upload attachments to Supabase storage
  Future<({String url, String name})> _uploadAttachment(File file, String type) async {
    try {
      final userId = _currentUserId;
      
      final fileName = path.basename(file.path);
      final fileExt = path.extension(fileName);
      final uuid = const Uuid().v4();
      final storagePath = '$type/$userId/$uuid$fileExt';
      
      await _client.storage.from('attachments').upload(
        storagePath,
        file,
      );
      
      final url = _client.storage.from('attachments').getPublicUrl(storagePath);
      return (url: url, name: fileName);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Helper method to send an attachment message
  Future<MessageModel> _sendAttachmentMessage({
    required String chatId,
    required String attachmentUrl,
    required String attachmentName,
    required String messageType,
  }) async {
    try {
      final userId = _currentUserId;
      
      final messageData = {
        'chat_id': chatId,
        'user_id': userId,
        'message_type': messageType,
        'attachment_url': attachmentUrl,
        'attachment_name': attachmentName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };
      
      final response = await _client
        .from('messages')
        .insert(messageData)
        .select()
        .single();
      
      await _updateChatLastMessageTime(chatId);
      
      return MessageModel.fromSupabase(response, userId);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Update the last_message_at timestamp in a chat
  Future<void> _updateChatLastMessageTime(String chatId) async {
    try {
      await _client
        .from('chats')
        .update({
          'last_message_at': DateTime.now().toIso8601String(),
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
      
      await _client
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
      await _client.from('chats').delete().eq('id', chatId);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
Stream<MessageModel> subscribeToMessages(String chatId) {
  try {
    final userId = _currentUserId;
    
    return _client
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
      final response = await _client
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
  Future<UserModel> getUserById(String userId) async {
    try {
      final response = await _client
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

/// Provider for the chat repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return SupabaseChatRepository(client);
});

/// Stream provider for chat list
final chatListStreamProvider = StreamProvider<List<ChatModel>>((ref) async* {
  final repository = ref.watch(chatRepositoryProvider);
  
  // Initial load
  var chats = await repository.getChatsForCurrentUser();
  yield chats;
  
  // Listen to message table changes
  final stream = SupabaseService.client
    .from('messages')
    .stream(primaryKey: ['id'])
    .execute();
  
  // Whenever a new message comes in, refresh the chat list
  await for (final _ in stream) {
    chats = await repository.getChatsForCurrentUser();
    yield chats;
  }
});

/// Stream provider for messages in a specific chat
final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) async* {
  final repository = ref.watch(chatRepositoryProvider);
  
  // Initial load
  var messages = await repository.getMessagesForChat(chatId);
  yield messages;
  
  // Mark messages as read
  await repository.markMessagesAsRead(chatId);
  
  // Listen to new messages for this chat
  final client = SupabaseService.client;
  final stream = client.from('messages')
    .stream(primaryKey: ['id'])
    .eq('chat_id', chatId);
  
  await for (final _ in stream) {
    messages = await repository.getMessagesForChat(chatId);
    yield messages;
    
    // Mark as read whenever new messages arrive
    await repository.markMessagesAsRead(chatId);
  }
});
