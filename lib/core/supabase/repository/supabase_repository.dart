import 'dart:io';

import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:flutter_chat/features/chat/data/models/chat.dart';
import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/chat/data/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseChatRepository {
  
  SupabaseChatRepository(this._client);
  final SupabaseClient _client;
  
  // Get all chats for current user
  Future<List<ChatModel>> getChatsForCurrentUser() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    
    // Get all chats that the user is a member of
    final response = await _client
      .from('chat_members')
      .select('chat_id')
      .eq('user_id', userId);
    
    final chatIds = (response as List).map((item) => item['chat_id'] as String).toList();
    if (chatIds.isEmpty) return [];
    
    // Get chat details with last message
    final chatsResponse = await _client
      .from('chats')
      .select('*, chat_members!inner(user_id)')
      .in_('id', chatIds)
      .order('last_message_at', ascending: false);
    
    final chats = <ChatModel>[];
    
    for (final chat in chatsResponse) {
      // Get other members of the chat (for 1:1 chats, this is the other user)
      final otherMembers = await _client
        .from('chat_members')
        .select('user_id')
        .eq('chat_id', chat['id'])
        .neq('user_id', userId);
      
      if (otherMembers.isEmpty) continue;
      
      // Get the other user's details
      final otherUserId = otherMembers[0]['user_id'];
      final userResponse = await _client
        .from('users')
        .select()
        .eq('id', otherUserId)
        .single();
      
      // Get the last message
      final lastMessageResponse = await _client
        .from('messages')
        .select()
        .eq('chat_id', chat['id'])
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
      
      final otherUser = UserModel(
        id: userResponse['id'] as int,
        name: userResponse['username'] as String,
        avatarUrl: userResponse['avatar_url'] as String?,
        email: userResponse['email'] as String,
        createdAt: DateTime.parse(userResponse['created_at'] as String),
      );
      
      MessageModel? lastMessage;
      if (lastMessageResponse != null) {
        lastMessage = MessageModel(
          id: lastMessageResponse['id'],
          chatId: lastMessageResponse['chat_id'],
          isMe: lastMessageResponse['user_id'] == userId,
          text: lastMessageResponse['content'],
          attachmentPath: lastMessageResponse['attachment_url'],
          attachmentType: _mapMessageTypeToAttachmentType(lastMessageResponse['message_type']),
          createdAt: DateTime.parse(lastMessageResponse['created_at']),
          isRead: lastMessageResponse['is_read'],
        );
      }
      
      chats.add(ChatModel(
        id: chat['id'],
        user: otherUser,
        createdAt: DateTime.parse(chat['created_at']),
        lastMessageTime: lastMessage?.createdAt,
        lastMessage: lastMessage,
      ));
    }
    
    return chats;
  }
  
  // Get all messages for a chat
  Future<List<MessageModel>> getMessagesForChat(String chatId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    
    final response = await _client
      .from('messages')
      .select()
      .eq('chat_id', chatId)
      .order('created_at');
    
    return (response as List).map((message) => MessageModel(
      id: message['id'],
      chatId: message['chat_id'],
      isMe: message['user_id'] == userId,
      text: message['content'],
      attachmentPath: message['attachment_url'],
      attachmentType: _mapMessageTypeToAttachmentType(message['message_type']),
      createdAt: DateTime.parse(message['created_at']),
      isRead: message['is_read'],
    )).toList();
  }
  
  // Create a new chat with a user
  Future<String> createChat(String otherUserId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    
    // Check if a chat already exists between these users
    final existingChat = await _findExistingChat(userId, otherUserId);
    if (existingChat != null) return existingChat;
    
    // Create a new chat
    final chatResponse = await _client
      .from('chats')
      .insert({})
      .select('id')
      .single();
    
    final chatId = chatResponse['id'] as String;
    
    // Add both users to the chat
    await _client.from('chat_members').insert([
      {'chat_id': chatId, 'user_id': userId},
      {'chat_id': chatId, 'user_id': otherUserId},
    ]);
    
    return chatId;
  }
  
  // Helper method to find existing chat
  Future<String?> _findExistingChat(String userId, String otherUserId) async {
    // Find chats where both users are members
    final response = await _client
      .from('chat_members')
      .select('chat_id')
      .eq('user_id', userId);
    
    final chatIds = (response as List).map((item) => item['chat_id'] as String).toList();
    if (chatIds.isEmpty) return null;
    
    final otherUserChats = await _client
      .from('chat_members')
      .select('chat_id')
      .eq('user_id', otherUserId)
      .in_('chat_id', chatIds);
    
    if (otherUserChats.isEmpty) return null;
    
    // Check if this is a 1:1 chat (only 2 members)
    final chatId = otherUserChats[0]['chat_id'];
    final membersCount = await _client
      .from('chat_members')
      .select('id', { 'count': 'exact' })
      .eq('chat_id', chatId);
    
    if (membersCount.count == 2) {
      return chatId;
    }
    
    return null;
  }
  
  // Send a text message
  Future<void> sendTextMessage(String chatId, String text) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    
    await _client.from('messages').insert({
      'chat_id': chatId,
      'user_id': userId,
      'content': text,
      'message_type': 'text',
    });
    
    await _updateChatLastMessageTime(chatId);
  }
  
  // Send an image message
  Future<void> sendImageMessage(String chatId, File imageFile) async {
    final attachment = await _uploadAttachment(imageFile, 'image');
    await _sendAttachmentMessage(
      chatId: chatId, 
      attachmentUrl: attachment.url,
      attachmentName: attachment.name,
      messageType: 'image',
    );
  }
  
  // Send a video message
  Future<void> sendVideoMessage(String chatId, File videoFile) async {
    final attachment = await _uploadAttachment(videoFile, 'video');
    await _sendAttachmentMessage(
      chatId: chatId, 
      attachmentUrl: attachment.url,
      attachmentName: attachment.name,
      messageType: 'video',
    );
  }
  
  // Send a file message
  Future<void> sendFileMessage(String chatId, File file) async {
    final attachment = await _uploadAttachment(file, 'file');
    await _sendAttachmentMessage(
      chatId: chatId, 
      attachmentUrl: attachment.url,
      attachmentName: attachment.name,
      messageType: 'file',
    );
  }
  
  // Send an audio message
  Future<void> sendAudioMessage(String chatId, File audioFile) async {
    final attachment = await _uploadAttachment(audioFile, 'audio');
    await _sendAttachmentMessage(
      chatId: chatId, 
      attachmentUrl: attachment.url,
      attachmentName: attachment.name,
      messageType: 'audio',
    );
  }
  
  // Helper method to upload attachments
  Future<({String url, String name})> _uploadAttachment(File file, String type) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    
    final fileName = path.basename(file.path);
    final fileExt = path.extension(fileName);
    final uuid = const Uuid().v4();
    final storagePath = '$type/$userId/$uuid$fileExt';
    
    await _client.storage.from('attachments').upload(
      storagePath,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    
    final url = _client.storage.from('attachments').getPublicUrl(storagePath);
    return (url: url, name: fileName);
  }
  
  // Helper method to send attachment message
  Future<void> _sendAttachmentMessage({
    required String chatId,
    required String attachmentUrl,
    required String attachmentName,
    required String messageType,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    
    await _client.from('messages').insert({
      'chat_id': chatId,
      'user_id': userId,
      'message_type': messageType,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
    });
    
    await _updateChatLastMessageTime(chatId);
  }
  
  // Update last_message_at in chat
  Future<void> _updateChatLastMessageTime(String chatId) async {
    await _client
      .from('chats')
      .update({'last_message_at': DateTime.now().toIso8601String()})
      .eq('id', chatId);
  }
  
  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    
    await _client
      .from('messages')
      .update({'is_read': true})
      .eq('chat_id', chatId)
      .neq('user_id', userId)
      .eq('is_read', false);
  }
  
  // Delete a chat
  Future<void> deleteChat(String chatId) async {
    await _client.from('chats').delete().eq('id', chatId);
  }
  
  // Subscribe to new messages in a chat
  Stream<MessageModel> subscribeToMessages(String chatId) {
    final userId = _client.auth.currentUser?.id;
    
    return _client
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('chat_id', chatId)
      .order('created_at')
      .map((event) => MessageModel(
        id: event['id'],
        chatId: event['chat_id'],
        isMe: event['user_id'] == userId,
        text: event['content'],
        attachmentPath: event['attachment_url'],
        attachmentType: _mapMessageTypeToAttachmentType(event['message_type']),
        createdAt: DateTime.parse(event['created_at']),
        isRead: event['is_read'],
      ));
  }
  
  // Map message type from database to app enum
  AttachmentType _mapMessageTypeToAttachmentType(String? messageType) {
    switch (messageType) {
      case 'image': return AttachmentType.image;
      case 'video': return AttachmentType.video;
      case 'file': return AttachmentType.file;
      case 'audio': return AttachmentType.voice;
      default: return AttachmentType.none;
    }
  }
}

final supabaseChatRepositoryProvider = Provider<SupabaseChatRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return SupabaseChatRepository(client);
});

// Provider for streaming chat list updates
final chatListStreamProvider = StreamProvider<List<ChatModel>>((ref) async* {
  final repository = ref.watch(supabaseChatRepositoryProvider);
  
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

// Provider for messages in a specific chat
final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) async* {
  final repository = ref.watch(supabaseChatRepositoryProvider);
  
  // Initial load
  var messages = await repository.getMessagesForChat(chatId);
  yield messages;
  
  // Mark messages as read
  await repository.markMessagesAsRead(chatId);
  
  // Listen to new messages
  final stream = repository.subscribeToMessages(chatId);
  
  await for (final message in stream) {
    messages = await repository.getMessagesForChat(chatId);
    yield messages;
    
    // Mark as read whenever new messages arrive
    await repository.markMessagesAsRead(chatId);
  }
});