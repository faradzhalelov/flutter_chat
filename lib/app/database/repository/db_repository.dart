// lib/core/repository/drift_chat_repository.dart
import 'dart:developer';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_chat/app/database/dao/daos.dart';
import 'package:flutter_chat/app/database/db/database.dart';
import 'package:flutter_chat/app/database/provider/db_provider.dart';
import 'package:flutter_chat/app/database/service/db_service.dart';
import 'package:flutter_chat/core/supabase/repository/chat_repository.dart';
import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:flutter_chat/features/chat/data/models/chat.dart';
import 'package:flutter_chat/features/chat/data/models/chat_member.dart';
import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/chat/data/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class DriftChatRepository implements ChatRepository {
  DriftChatRepository(
      this._usersDao, this._chatsDao, this._messagesDao, this._syncService);
  final UsersDao _usersDao;
  final ChatsDao _chatsDao;
  final MessagesDao _messagesDao;
  final SyncService _syncService;

  String get _currentUserId {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    return userId;
  }

  @override
  Stream<List<ChatModel>> getChatsForCurrentUserStream() {
    final userId = _currentUserId;

    // Ensure we're synced first
    _syncService.syncChats(userId);

    return _chatsDao.watchChatsForUser(userId).asyncMap((chats) async {
      final result = <ChatModel>[];

      for (final chat in chats) {
        // Get other members
        final chatMembers = await _chatsDao.watchChatMembers(chat.id).first;

        if (chatMembers.isEmpty) continue;

        // Find other user (for 1:1 chats)
        final otherUser = chatMembers.firstWhere(
          (user) => user.id != userId,
          orElse: () => chatMembers.first,
        );

        // Get last message
        final messagesStream = _messagesDao.watchMessagesForChat(chat.id);
        final messages = await messagesStream.first;
        final lastMessage = messages.isNotEmpty ? messages.last : null;

        // Convert to ChatModel
        final userModel = UserModel(
          id: otherUser.id,
          email: otherUser.email,
          username: otherUser.username,
          avatarUrl: otherUser.avatarUrl,
          createdAt: otherUser.createdAt,
          lastSeen: otherUser.lastSeen,
          isOnline: otherUser.isOnline,
        );

        MessageModel? lastMessageModel;
        if (lastMessage != null) {
          lastMessageModel = MessageModel(
            id: lastMessage.id,
            chatId: lastMessage.chatId,
            userId: lastMessage.userId,
            text: lastMessage.content,
            messageType: AttachmentType.values.byName(lastMessage.messageType),
            attachmentUrl: lastMessage.attachmentUrl,
            attachmentName: lastMessage.attachmentName,
            createdAt: lastMessage.createdAt,
            updatedAt: lastMessage.updatedAt,
            isRead: lastMessage.isRead,
            isMe: lastMessage.userId == userId,
          );
        }

        result.add(ChatModel(
          id: chat.id,
          createdAt: chat.createdAt,
          lastMessageTime: chat.lastMessageAt,
          user: userModel,
          lastMessage: lastMessageModel,
        ));
      }

      // Sort by last message date
      result.sort((a, b) {
        final bTime = b.lastMessageTime;
        final aTime = a.lastMessageTime;
        if (bTime != null && aTime != null) {
          return bTime.compareTo(aTime);
        } else {
          return 0;
        }
      });

      return result;
    });
  }

  @override
  Future<List<ChatModel>> getChatsForCurrentUser() async {
    final userId = _currentUserId;

    // Force sync with Supabase first
    await _syncService.syncChats(userId);

    // Then get from local DB (same logic as stream)
    final chats = await _chatsDao.watchChatsForUser(userId).first;
    final result = <ChatModel>[];

    for (final chat in chats) {
      // Get other members
      final chatMembers = await _chatsDao.watchChatMembers(chat.id).first;

      if (chatMembers.isEmpty) continue;

      // Find other user (for 1:1 chats)
      final otherUser = chatMembers.firstWhere(
        (user) => user.id != userId,
        orElse: () => chatMembers.first,
      );

      // Get last message
      final messagesStream = _messagesDao.watchMessagesForChat(chat.id);
      final messages = await messagesStream.first;
      final lastMessage = messages.isNotEmpty ? messages.last : null;

      // Convert to ChatModel
      final userModel = UserModel(
        id: otherUser.id,
        email: otherUser.email,
        username: otherUser.username,
        avatarUrl: otherUser.avatarUrl,
        createdAt: otherUser.createdAt,
        lastSeen: otherUser.lastSeen,
        isOnline: otherUser.isOnline,
      );

      MessageModel? lastMessageModel;
      if (lastMessage != null) {
        lastMessageModel = MessageModel(
          id: lastMessage.id,
          chatId: lastMessage.chatId,
          userId: lastMessage.userId,
          text: lastMessage.content,
          messageType: AttachmentType.values.byName(lastMessage.messageType),
          attachmentUrl: lastMessage.attachmentUrl,
          attachmentName: lastMessage.attachmentName,
          createdAt: lastMessage.createdAt,
          updatedAt: lastMessage.updatedAt,
          isRead: lastMessage.isRead,
          isMe: lastMessage.userId == userId,
        );
      }

      result.add(ChatModel(
        id: chat.id,
        createdAt: chat.createdAt,
        lastMessageTime: chat.lastMessageAt,
        user: userModel,
        lastMessage: lastMessageModel,
      ));
    }

    // Sort by last message date
  result.sort((a, b) {
        final bTime = b.lastMessageTime;
        final aTime = a.lastMessageTime;
        if (bTime != null && aTime != null) {
          return bTime.compareTo(aTime);
        } else {
          return 0;
        }
      });
    return result;
  }

  @override
  Future<List<MessageModel>> getMessagesForChat(String chatId) async {
    final userId = _currentUserId;

    // Sync messages for this chat
    await _syncService.syncMessagesForChat(chatId);

    // Get messages from local DB
    final messages = await _messagesDao.watchMessagesForChat(chatId).first;

    return messages
        .map((message) => MessageModel(
              id: message.id,
              chatId: message.chatId,
              userId: message.userId,
              text: message.content,
              messageType: AttachmentType.values.byName(message.messageType),
              attachmentUrl: message.attachmentUrl,
              attachmentName: message.attachmentName,
              createdAt: message.createdAt,
              updatedAt: message.updatedAt,
              isRead: message.isRead,
              isMe: message.userId == userId,
            ))
        .toList();
  }

  @override
  Future<String> createChat(String otherUserId) async {
    try {
      final userId = _currentUserId;

      // Check if a chat already exists between these users
      final existingChat = await _findExistingChat(userId, otherUserId);
      if (existingChat != null) return existingChat;

      // Create a new chat in Supabase
      final chatResponse = await supabase
          .from('chats')
          .insert({
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final chatId = chatResponse['id'] as String;

      // Add both users to the chat in Supabase
      await supabase.from('chat_members').insert([
        {'chat_id': chatId, 'user_id': userId},
        {'chat_id': chatId, 'user_id': otherUserId},
      ]);

      // Now sync this chat to the local database
      await _syncService.syncChatMembers(chatId);

      // Create local chat entry
      await _chatsDao.insertChat(
        ChatsTableCompanion.insert(
          id: chatId,
          createdAt: Value(DateTime.now()),
          lastMessageAt: Value(DateTime.now()),
        ),
      );

      // Add both users as members in local DB
      final memberIdCurrent = const Uuid().v4();
      final memberIdOther = const Uuid().v4();

      await _chatsDao.addChatMember(
        ChatMembersTableCompanion.insert(
          id: memberIdCurrent,
          chatId: chatId,
          userId: userId,
          createdAt: Value(DateTime.now()),
        ),
      );

      await _chatsDao.addChatMember(
        ChatMembersTableCompanion.insert(
          id: memberIdOther,
          chatId: chatId,
          userId: otherUserId,
          createdAt: Value(DateTime.now()),
        ),
      );

      // Make sure other user is in local DB
      await _syncService.syncUserById(otherUserId);

      return chatId;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  /// Helper method to find an existing chat between two users
  Future<String?> _findExistingChat(String userId, String otherUserId) async {
    try {
      // First try to find in local DB
      final userChats = await _chatsDao.watchChatsForUser(userId).first;

      for (final chat in userChats) {
        final members = await _chatsDao.watchChatMembers(chat.id).first;

        if (members.length == 2 &&
            members.any((m) => m.id == userId) &&
            members.any((m) => m.id == otherUserId)) {
          return chat.id;
        }
      }

      // If not found in local DB, try Supabase
      final userChatsResponse = await supabase
          .from('chat_members')
          .select('chat_id')
          .eq('user_id', userId);

      final chatIds =
          userChatsResponse.map((item) => item['chat_id'] as String).toList();
      if (chatIds.isEmpty) return null;

      final otherUserChatsResponse = await supabase
          .from('chat_members')
          .select('chat_id')
          .eq('user_id', otherUserId)
          .filter('chat_id', 'in', chatIds);

      if (otherUserChatsResponse.isEmpty) {
        return null;
      }

      final chatId = otherUserChatsResponse[0]['chat_id'] as String;

      // Count members in the chat
      final membersCountResponse =
          await supabase.from('chat_members').select().eq('chat_id', chatId);

      final membersCount = membersCountResponse.length;
      if (membersCount == 2) {
        // Sync this chat to local DB since it exists in Supabase but not locally
        await _syncService.syncChatMembers(chatId);
        return chatId;
      }

      return null;
    } catch (e) {
      log('Error finding existing chat: $e');
      return null;
    }
  }

  @override
  Future<MessageModel> sendTextMessage(String chatId, String text) async {
    try {
      final userId = _currentUserId;

      // Create message data
      final messageId = const Uuid().v4();
      final now = DateTime.now();

      // Create message locally first
      final messageData = MessagesTableCompanion.insert(
        id: messageId,
        chatId: chatId,
        userId: userId,
        content: Value(text),
        messageType: 'text',
        createdAt: Value(now),
        updatedAt: Value(now),
        isRead: const Value(false),
        isSynced: const Value(false), // Will be synced to Supabase
      );

      // Insert locally
      await _messagesDao.insertMessage(messageData);

      // Update chat's last message time
      await _chatsDao.updateChat(
        ChatsTableCompanion(
          id: Value(chatId),
          lastMessageAt: Value(now),
        ),
      );

      // Schedule sync to Supabase
      _syncService.syncUnsentMessages();

      // Get the created message
      final message = await (_messagesDao.select(_messagesDao.messagesTable)
            ..where((m) => m.id.equals(messageId)))
          .getSingle();

      // Return as model
      return MessageModel(
        id: message.id,
        chatId: message.chatId,
        userId: message.userId,
        text: message.content,
        messageType: AttachmentType.values.byName(message.messageType),
        createdAt: message.createdAt,
        updatedAt: message.updatedAt,
        isRead: message.isRead,
        isMe: true,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
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
      throw Exception('Failed to send image message: $e');
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
      throw Exception('Failed to send video message: $e');
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
      throw Exception('Failed to send file message: $e');
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
      throw Exception('Failed to send audio message: $e');
    }
  }

  /// Helper method to upload attachments to Supabase storage
  Future<({String url, String name})> _uploadAttachment(
      File file, String type) async {
    try {
      final userId = _currentUserId;

      final fileName = path.basename(file.path);
      final fileExt = path.extension(fileName);
      final uuid = const Uuid().v4();
      final storagePath = '$type/$userId/$uuid$fileExt';

      await supabase.storage.from('attachments').upload(
            storagePath,
            file,
          );

      final url =
          supabase.storage.from('attachments').getPublicUrl(storagePath);
      return (url: url, name: fileName);
    } catch (e) {
      throw Exception('Failed to upload attachment: $e');
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
      final messageId = const Uuid().v4();
      final now = DateTime.now();

      // Create message locally first
      final messageData = MessagesTableCompanion.insert(
        id: messageId,
        chatId: chatId,
        userId: userId,
        content: const Value(null),
        messageType: messageType,
        attachmentUrl: Value(attachmentUrl),
        attachmentName: Value(attachmentName),
        createdAt: Value(now),
        updatedAt: Value(now),
        isRead: const Value(false),
        isSynced: const Value(false), // Will be synced to Supabase
      );

      // Insert locally
      await _messagesDao.insertMessage(messageData);

      // Update chat's last message time
      await _chatsDao.updateChat(
        ChatsTableCompanion(
          id: Value(chatId),
          lastMessageAt: Value(now),
        ),
      );

      // Schedule sync to Supabase
      await _syncService.syncUnsentMessages();

      // Get the created message
      final message = await (_messagesDao.select(_messagesDao.messagesTable)
            ..where((m) => m.id.equals(messageId)))
          .getSingle();

      // Return as model
      return MessageModel(
        id: message.id,
        chatId: message.chatId,
        userId: message.userId,
        text: message.content,
        messageType: AttachmentType.values.byName(message.messageType),
        attachmentUrl: message.attachmentUrl,
        attachmentName: message.attachmentName,
        createdAt: message.createdAt,
        updatedAt: message.updatedAt,
        isRead: message.isRead,
        isMe: true,
      );
    } catch (e) {
      throw Exception('Failed to send attachment message: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final userId = _currentUserId;

      // Mark as read in local DB
      await _messagesDao.markAllMessagesAsRead(chatId, userId);

      // Also mark as read in Supabase
      await supabase
          .from('messages')
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .not('user_id', 'eq', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  @override
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete from Supabase (will cascade to messages and members)
      await supabase.from('chats').delete().eq('id', chatId);

      // Delete from local database
      await _chatsDao.deleteChat(chatId);
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  @override
  Stream<MessageModel> subscribeToMessages(String chatId) {
    final userId = _currentUserId;

    return _messagesDao.watchMessagesForChat(chatId).map((messages) {
      // Sort messages by created_at
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (messages.isEmpty) {
        // Return an empty stream if no messages
        return MessageModel(
          id: '',
          chatId: chatId,
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isRead: true,
          isMe: true,
        );
      }

      // Return latest message
      final latest = messages.last;
      return MessageModel(
        id: latest.id,
        chatId: latest.chatId,
        userId: latest.userId,
        text: latest.content,
        messageType: AttachmentType.values.byName(latest.messageType),
        attachmentUrl: latest.attachmentUrl,
        attachmentName: latest.attachmentName,
        createdAt: latest.createdAt,
        updatedAt: latest.updatedAt,
        isRead: latest.isRead,
        isMe: latest.userId == userId,
      );
    });
  }

  @override
  Future<List<ChatMemberModel>> getChatMembers(String chatId) async {
    try {
      // Sync members first
      await _syncService.syncChatMembers(chatId);

      // Now get from local DB
      final membersResponse = await _chatsDao.watchChatMembers(chatId).first;

      return membersResponse.map((userData) => ChatMemberModel(
          id: const Uuid().v4(), // Generate a temporary ID
          chatId: chatId,
           createdAt: userData.createdAt, userId: userData.id,
        )).toList();
    } catch (e) {
      throw Exception('Failed to get chat members: $e');
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      // Sync user first
      await _syncService.syncUserById(userId);

      // Get from local DB
      final userData = await _usersDao.getUserById(userId);

      if (userData == null) {
        throw Exception('User not found');
      }

      return UserModel(
        id: userData.id,
        email: userData.email,
        username: userData.username,
        avatarUrl: userData.avatarUrl,
        createdAt: userData.createdAt,
        lastSeen: userData.lastSeen,
        isOnline: userData.isOnline,
      );
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }
}

// Provider for the chat repository
final driftChatRepositoryProvider = Provider<ChatRepository>((ref) {
  final usersDao = ref.watch(usersDaoProvider);
  final chatsDao = ref.watch(chatsDaoProvider);
  final messagesDao = ref.watch(messagesDaoProvider);
  final syncService = ref.watch(syncServiceProvider);

  return DriftChatRepository(usersDao, chatsDao, messagesDao, syncService);
});

// Update this provider to use the Drift implementation
final dbRepositoryProvider = Provider<ChatRepository>((ref) => ref.watch(driftChatRepositoryProvider));
