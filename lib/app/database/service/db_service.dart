import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/app/database/dao/daos.dart';
import 'package:flutter_chat/app/database/db/database.dart';
import 'package:flutter_chat/core/supabase/service/file_upload_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SyncService {

  SyncService(this._supabaseClient, this._localDb, this._fileUploadService);
  final SupabaseClient _supabaseClient;
  final LocalDatabase _localDb;
  final FileUploadService _fileUploadService;
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _chatsSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _chatMembersSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _usersSubscription;
  
  bool _isSyncing = false;
  
  // Initialize sync service
  void initialize() {
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((result) {
      if (result.contains(ConnectivityResult.none)) {
        syncData();
      }
    });
    
    // Initial sync
    syncData();
    
    // Listen for Supabase realtime updates
    _setupRealtimeSubscriptions();
  }
  
  // Set up realtime subscriptions to Supabase tables
  void _setupRealtimeSubscriptions() {
    // Messages subscription
    _messagesSubscription = _supabaseClient
        .from('messages')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      _handleNewMessages(data);
    });
    
    // Chats subscription
    _chatsSubscription = _supabaseClient
        .from('chats')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      _handleNewChats(data);
    });
    
    // Chat members subscription
    _chatMembersSubscription = _supabaseClient
        .from('chat_members')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      _handleNewChatMembers(data);
    });
    
    // Users subscription
    _usersSubscription = _supabaseClient
        .from('users')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      _handleNewUsers(data);
    });
  }
  
  // Handle new messages from Supabase
  Future<void> _handleNewMessages(List<Map<String, dynamic>> data) async {
    for (final message in data) {
      await _localDb.saveMessage(MessagesCompanion.insert(
        id: message['id'] as String,
        chatId: message['chat_id'] as String,
        userId: message['user_id'] as String,
        content: Value<String?>(message['content'] as String?),
        messageType: message['message_type'] as String,
        attachmentUrl: Value<String?>(message['attachment_url'] as String?),
        attachmentName: Value<String?>(message['attachment_name'] as String?),
        createdAt: DateTime.parse(message['created_at'] as String),
        updatedAt: DateTime.parse(message['updated_at'] as String),
        isRead: Value<bool>(message['is_read'] as bool? ?? false),
        isSynced: const Value(true),
      ),);
    }
  }
  
  // Handle new chats from Supabase
  Future<void> _handleNewChats(List<Map<String, dynamic>> data) async {
    for (final chat in data) {
      await _localDb.saveChat(ChatsCompanion.insert(
        id: chat['id'] as String,
        createdAt: DateTime.parse(chat['created_at'] as String),
        lastMessageAt: DateTime.parse(chat['last_message_at'] as String),
        isSynced: const Value(true),
      ),);
    }
  }
  
  // Handle new chat members from Supabase
  Future<void> _handleNewChatMembers(List<Map<String, dynamic>> data) async {
    for (final member in data) {
      await _localDb.saveChatMember(ChatMembersCompanion.insert(
        id: member['id'] as String,
        chatId: member['chat_id'] as String,
        userId: member['user_id'] as String,
        createdAt: DateTime.parse(member['created_at'] as String),
        isSynced: const Value(true),
      ),);
    }
  }
  
  // Handle new users from Supabase
  Future<void> _handleNewUsers(List<Map<String, dynamic>> data) async {
    for (final user in data) {
      await _localDb.saveUser(UsersCompanion.insert(
        id: user['id'] as String,
        email: user['email'] as String,
        username: user['username'] as String,
        avatarUrl: Value<String?>(user['avatar_url'] as String?),
        createdAt: DateTime.parse(user['created_at'] as String),
        isOnline: Value<bool>(user['is_online'] as bool? ?? false),
      ),);
    }
  }
  
  // Sync all local data with Supabase
  Future<void> syncData() async {
    if (_isSyncing) return;
    
    try {
      _isSyncing = true;
      
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return;
      }
      
      // Sync unsynced chats
      await _syncChats();
      
      // Sync unsynced chat members
      await _syncChatMembers();
      
      // Sync unsynced messages
      await _syncMessages();
      
      // Sync unsynced files
      await _fileUploadService.syncUnsyncedFiles();
      
    } catch (e) {
      debugPrint('Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  // Sync chats
  Future<void> _syncChats() async {
    final unsyncedChats = await _localDb.getUnsyncedChats();
    
    for (final chat in unsyncedChats) {
      try {
        // Insert or update in Supabase
        await _supabaseClient
            .from('chats')
            .upsert({
              'id': chat.id,
              'created_at': chat.createdAt.toIso8601String(),
              'last_message_at': chat.lastMessageAt.toIso8601String(),
            });
        
        // Mark as synced
        await _localDb.markChatAsSynced(chat.id);
      } catch (e) {
        debugPrint('Error syncing chat ${chat.id}: $e');
      }
    }
  }
  
  // Sync chat members
  Future<void> _syncChatMembers() async {
    final unsyncedMembers = await _localDb.getUnsyncedChatMembers();
    
    for (final member in unsyncedMembers) {
      try {
        // Insert or update in Supabase
        await _supabaseClient
            .from('chat_members')
            .upsert({
              'id': member.id,
              'chat_id': member.chatId,
              'user_id': member.userId,
              'created_at': member.createdAt.toIso8601String(),
            });
        
        // Mark as synced
        await _localDb.markChatMemberAsSynced(member.id);
      } catch (e) {
        debugPrint('Error syncing chat member ${member.id}: $e');
      }
    }
  }
  
  // Sync messages
  Future<void> _syncMessages() async {
    final unsyncedMessages = await _localDb.getUnsyncedMessages();
    
    for (final message in unsyncedMessages) {
      try {
        // Skip messages with attachments, they'll be handled by the file upload service
        if (message.attachmentUrl != null && 
            message.attachmentUrl!.startsWith('file://') && 
            message.messageType != 'text') {
          continue;
        }
        
        // Insert or update in Supabase
        await _supabaseClient
            .from('messages')
            .upsert({
              'id': message.id,
              'chat_id': message.chatId,
              'user_id': message.userId,
              'content': message.content,
              'message_type': message.messageType,
              'attachment_url': message.attachmentUrl,
              'attachment_name': message.attachmentName,
              'created_at': message.createdAt.toIso8601String(),
              'updated_at': message.updatedAt.toIso8601String(),
              'is_read': message.isRead,
            });
        
        // Mark as synced
        await _localDb.markMessageAsSynced(message.id);
      } catch (e) {
        debugPrint('Error syncing message ${message.id}: $e');
      }
    }
  }
  
  // Create a new text message (locally and ready for sync)
  Future<String> createLocalTextMessage({
    required String chatId,
    required String userId,
    required String content,
  }) async {
    final messageId = const Uuid().v4();
    final now = DateTime.now();
    
    // Save to local DB
    await _localDb.saveMessage(MessagesCompanion.insert(
      id: messageId,
      chatId: chatId,
      userId: userId,
      content: Value(content),
      messageType: 'text',
      attachmentUrl: const Value(null),
      attachmentName: const Value(null),
      createdAt: now,
      updatedAt: now,
      isRead: const Value(false),
      isSynced: const Value(false), // Not synced yet
    ),);
    
    // Update chat's last message timestamp
    await _localDb.saveChat(ChatsCompanion(
      id: Value(chatId),
      lastMessageAt: Value(now),
      isSynced: const Value(false), // Mark chat for sync
    ),);
    
    // Trigger sync if connected
    await syncData();
    
    return messageId;
  }
  
  // Create a new local message with attachment (ready for sync)
  Future<String> createLocalAttachmentMessage({
    required String chatId,
    required String userId,
    required String messageType,
    required String localFilePath,
    required String fileName,
    String? content,
  }) async {
    final messageId = const Uuid().v4();
    final now = DateTime.now();
    
    // Save to local DB with file:// prefix to indicate it needs uploading
    await _localDb.saveMessage(MessagesCompanion.insert(
      id: messageId,
      chatId: chatId,
      userId: userId,
      content: Value(content),
      messageType: messageType,
      attachmentUrl: Value('file://$localFilePath'),
      attachmentName: Value(fileName),
      createdAt: now,
      updatedAt: now,
      isRead: const Value(false),
      isSynced: const Value(false), // Not synced yet
    ),);
    
    // Update chat's last message timestamp
    await _localDb.saveChat(ChatsCompanion(
      id: Value(chatId),
      lastMessageAt: Value(now),
      isSynced: const Value(false), // Mark chat for sync
    ),);
    
    // Trigger sync if connected
    await syncData();
    
    return messageId;
  }
  
  // Create a new chat
  Future<String> createNewChat({
    required List<String> memberIds,
  }) async {
    final chatId = const Uuid().v4();
    final now = DateTime.now();
    
    // Create chat locally
    await _localDb.saveChat(ChatsCompanion.insert(
      id: chatId,
      createdAt: now,
      lastMessageAt: now,
      isSynced: const Value(false),
    ),);
    
    // Add all members
    for (final userId in memberIds) {
      final membershipId = const Uuid().v4();
      
      await _localDb.saveChatMember(ChatMembersCompanion.insert(
        id: membershipId,
        chatId: chatId,
        userId: userId,
        createdAt: now,
        isSynced: const Value(false),
      ),);
    }
    
    // Trigger sync if connected
    await syncData();
    
    return chatId;
  }
  
  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      // Update locally
      await _localDb.markMessageAsRead(messageId);
      
      // Update in Supabase
      await _supabaseClient
          .from('messages')
          .update({'is_read': true})
          .eq('id', messageId);
    } catch (e) {
      debugPrint('Error marking message as read: $e');
    }
  }
  
  // Mark all messages in chat as read
  Future<void> markAllMessagesAsRead(String chatId, String currentUserId) async {
    try {
      // Update locally
      final messageDao = MessagesDao(_localDb);
      await messageDao.markAllMessagesAsRead(chatId, currentUserId);
      
      // Update in Supabase
      await _supabaseClient
          .from('messages')
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .neq('user_id', currentUserId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error marking all messages as read: $e');
    }
  }
  
  // Update user online status
  Future<void> updateUserOnlineStatus(String userId, {required bool isOnline}) async {
    try {
      final now = DateTime.now();
      
      // Update locally
      await _localDb.saveUser(UsersCompanion(
        id: Value(userId),
        isOnline: Value(isOnline),
      ),);
      
      // Update in Supabase
      await _supabaseClient
          .from('users')
          .update({
            'is_online': isOnline,
            'last_seen': now.toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user online status: $e');
    }
  }
  
  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      // Get message details first to handle attachment deletion
      final message = await (
        _localDb.select(_localDb.messages)..where((m) => m.id.equals(messageId))
      ).getSingleOrNull();
      
      if (message != null && message.attachmentUrl != null) {
        // If message has an attachment, try to delete it from storage
        if (!message.attachmentUrl!.startsWith('file://')) {
          try {
            // Parse bucket and path from URL
            final uri = Uri.parse(message.attachmentUrl!);
            final pathSegments = uri.pathSegments;
            
            if (pathSegments.length >= 3) {
              final bucketName = pathSegments[1]; // Usually 'image', 'video', etc.
              final filePath = pathSegments.sublist(2).join('/');
              
              // Delete from Supabase storage
              await _supabaseClient
                  .storage
                  .from(bucketName)
                  .remove([filePath]);
            }
          } catch (e) {
            debugPrint('Error deleting attachment from storage: $e');
          }
        }
      }
      final messageDao = MessagesDao(_localDb); await messageDao.deleteMessage(messageId);
      
      // Delete from Supabase
      await _supabaseClient
          .from('messages')
          .delete()
          .eq('id', messageId);
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }
  
  // Delete chat and all associated messages
  Future<void> deleteChat(String chatId) async {
    try {
      // Get all messages for chat
      final messages = await (
        _localDb.select(_localDb.messages)..where((m) => m.chatId.equals(chatId))
      ).get();
      
      // Delete attachments from storage
      for (final message in messages) {
        if (message.attachmentUrl != null && !message.attachmentUrl!.startsWith('file://')) {
          try {
            // Parse bucket and path from URL
            final uri = Uri.parse(message.attachmentUrl!);
            final pathSegments = uri.pathSegments;
            
            if (pathSegments.length >= 3) {
              final bucketName = pathSegments[1];
              final filePath = pathSegments.sublist(2).join('/');
              
              // Delete from Supabase storage
              await _supabaseClient
                  .storage
                  .from(bucketName)
                  .remove([filePath]);
            }
          } catch (e) {
            debugPrint('Error deleting attachment from storage: $e');
          }
        }
      }
      
      // Delete chat and all related data (cascade should handle messages and members)
      final chatDao = ChatsDao(_localDb); 
      await chatDao.deleteChat(chatId);

      // Delete from Supabase (cascade should handle messages and members)
      await _supabaseClient
          .from('chats')
          .delete()
          .eq('id', chatId);
    } catch (e) {
      debugPrint('Error deleting chat: $e');
    }
  }
  
  // Clean up resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _messagesSubscription?.cancel();
    _chatsSubscription?.cancel();
    _chatMembersSubscription?.cancel();
    _usersSubscription?.cancel();
  }
}