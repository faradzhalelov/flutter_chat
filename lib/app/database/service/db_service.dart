import 'dart:async';
import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:flutter_chat/app/database/dao/daos.dart';
import 'package:flutter_chat/app/database/db/database.dart';
import 'package:flutter_chat/app/database/provider/db_provider.dart';
import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_chat/features/chat/data/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class SyncService {
  SyncService(this._usersDao, this._chatsDao, this._messagesDao);

  final UsersDao _usersDao;
  final ChatsDao _chatsDao;
  final MessagesDao _messagesDao;
StreamSubscription<List<Map<String, dynamic>>>? _chatMembersSubscription;
StreamSubscription<List<Map<String, dynamic>>>? _messagesSubscription;

  // Initialize sync service and set up subscriptions
  Future<void> initialize(String currentUserId) async {
    await syncUserData(currentUserId);
    listenForRemoteChanges(currentUserId);
    await syncUnsentMessages();
  }

  // Sync user data from Supabase to local DB
  Future<void> syncUserData(String userId) async {
    try {
      // Get current user data from Supabase
      final response =
          await supabase.from('users').select().eq('id', userId).single();

      final userData = UserModel.fromSupabase(response);

      // Store or update in local DB
      await _usersDao.insertUser(
        UsersTableCompanion(
          id: Value(userData.id),
          email: Value(userData.email),
          username: Value(userData.username),
          avatarUrl: Value(userData.avatarUrl),
          lastSeen: Value(DateTime.now()),
          isOnline: const Value(true),
        ),
      );
    } catch (e) {
      log('Error syncing user data: $e');
    }
  }

  // Sync all chats for a user
  Future<void> syncChats(String userId) async {
    try {
      // Get chat memberships from Supabase
      final chatMembersResponse = await supabase
          .from('chat_members')
          .select('chat_id')
          .eq('user_id', userId);

      final chatIds =
          chatMembersResponse.map((item) => item['chat_id'] as String).toList();

      if (chatIds.isEmpty) return;

      // Get chat details
      final chatsResponse =
          await supabase.from('chats').select().filter('id', 'in', chatIds);

      // Save chats to local DB
      for (final chatData in chatsResponse) {
        final chatId = chatData['id'] as String;

        // Save chat
        await _chatsDao.insertChat(
          ChatsTableCompanion(
            id: Value(chatId),
            createdAt: Value(DateTime.parse(chatData['created_at'] as String)),
            lastMessageAt:
                Value(DateTime.parse(chatData['last_message_at'] as String)),
          ),
        );

        // Get and save chat members
        await syncChatMembers(chatId);

        // Get and save messages
        await syncMessagesForChat(chatId);
      }
    } catch (e) {
      log('Error syncing chats: $e');
    }
  }

  // Sync chat members for a specific chat
  Future<void> syncChatMembers(String chatId) async {
    try {
      final membersResponse = await supabase
          .from('chat_members')
          .select('id, user_id, created_at')
          .eq('chat_id', chatId);

      for (final memberData in membersResponse) {
        // Save chat member
        await _chatsDao.addChatMember(
          ChatMembersTableCompanion(
            id: Value(memberData['id'] as String),
            chatId: Value(chatId),
            userId: Value(memberData['user_id'] as String),
            createdAt:
                Value(DateTime.parse(memberData['created_at'] as String)),
          ),
        );

        // Fetch and save user data if not already present
        await syncUserById(memberData['user_id'] as String);
      }
    } catch (e) {
      log('Error syncing chat members: $e');
    }
  }

  // Sync user by ID
  Future<void> syncUserById(String userId) async {
    try {
      // Check if user already exists in local DB
      final existingUser = await _usersDao.getUserById(userId);
      if (existingUser != null) return;

      // Get user from Supabase
      final userResponse =
          await supabase.from('users').select().eq('id', userId).single();

      // Save to local DB
      await _usersDao.insertUser(
        UsersTableCompanion(
          id: Value(userResponse['id'] as String),
          email: Value(userResponse['email'] as String),
          username: Value(userResponse['username'] as String),
          avatarUrl: Value(userResponse['avatar_url'] as String?),
          createdAt:
              Value(DateTime.parse(userResponse['created_at'] as String)),
          lastSeen: Value(DateTime.parse(userResponse['last_seen'] as String)),
          isOnline: Value(userResponse['is_online'] as bool? ?? false),
        ),
      );
    } catch (e) {
      log('Error syncing user: $e');
    }
  }

  // Sync messages for a specific chat
  Future<void> syncMessagesForChat(String chatId) async {
    try {
      final messagesResponse = await supabase
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at');

      for (final messageData in messagesResponse) {
        await _messagesDao.insertMessage(
          MessagesTableCompanion(
            id: Value(messageData['id'] as String),
            chatId: Value(chatId),
            userId: Value(messageData['user_id'] as String),
            content: Value(messageData['content'] as String?),
            messageType: Value(messageData['message_type'] as String),
            attachmentUrl: Value(messageData['attachment_url'] as String?),
            attachmentName: Value(messageData['attachment_name'] as String?),
            createdAt:
                Value(DateTime.parse(messageData['created_at'] as String)),
            updatedAt:
                Value(DateTime.parse(messageData['updated_at'] as String)),
            isRead: Value(messageData['is_read'] as bool? ?? false),
            isSynced: const Value(true),
          ),
        );
      }
    } catch (e) {
      log('Error syncing messages: $e');
    }
  }

  // Listen for remote changes via Supabase realtime
  void listenForRemoteChanges(String currentUserId) {
    // Listen for chat member changes (new chats)
    _chatMembersSubscription = supabase
        .from('chat_members')
        .stream(primaryKey: ['id'])
        .eq('user_id', currentUserId)
        .listen((event) {
          for (final member in event) {
            final chatId = member['chat_id'] as String;
            syncChatMembers(chatId);
            syncMessagesForChat(chatId);
          }
        }, onError: (e) {
          log('Error in chat members subscription: $e');
        });

    // Listen for new messages
    _messagesSubscription =
        supabase.from('messages').stream(primaryKey: ['id']).listen((event) {
      for (final message in event) {
        _messagesDao.insertMessage(
          MessagesTableCompanion(
            id: Value(message['id'] as String),
            chatId: Value(message['chat_id'] as String),
            userId: Value(message['user_id'] as String),
            content: Value(message['content'] as String?),
            messageType: Value(message['message_type'] as String),
            attachmentUrl: Value(message['attachment_url'] as String?),
            attachmentName: Value(message['attachment_name'] as String?),
            createdAt: Value(DateTime.parse(message['created_at'] as String)),
            updatedAt: Value(DateTime.parse(message['updated_at'] as String)),
            isRead: Value(message['is_read'] as bool? ?? false),
            isSynced: const Value(true),
          ),
        );
      }
    }, onError: (e) {
      log('Error in messages subscription: $e');
    });
  }

  // Sync any unsent messages to Supabase
  Future<void> syncUnsentMessages() async {
    try {
      final unsentMessages = await _messagesDao.getUnsentMessages();

      for (final message in unsentMessages) {
        try {
          // Prepare message data for Supabase
          final messageData = {
            'id': message.id,
            'chat_id': message.chatId,
            'user_id': message.userId,
            'message_type': message.messageType,
            'created_at': message.createdAt.toIso8601String(),
            'updated_at': message.updatedAt.toIso8601String(),
            'is_read': message.isRead,
          };

          // Add optional fields
          if (message.content != null) {
            messageData['content'] = message.content!;
          }

          if (message.attachmentUrl != null) {
            messageData['attachment_url'] = message.attachmentUrl!;
          }

          if (message.attachmentName != null) {
            messageData['attachment_name'] = message.attachmentName!;
          }

          // Send to Supabase
          await supabase.from('messages').upsert(messageData);

          // Mark as synced
          await _messagesDao.updateMessage(
            MessagesTableCompanion(
              id: Value(message.id),
              isSynced: const Value(true),
            ),
          );

          // Update chat's last message timestamp
          await supabase.from('chats').update({
            'last_message_at': message.createdAt.toIso8601String(),
          }).eq('id', message.chatId);

          await _chatsDao.updateChat(
            ChatsTableCompanion(
              id: Value(message.chatId),
              lastMessageAt: Value(message.createdAt),
            ),
          );
        } catch (e) {
          log('Error syncing message ${message.id}: $e');
        }
      }
    } catch (e) {
      log('Error in syncUnsentMessages: $e');
    }
  }

  // Create a new message locally and queue for sync
  // Corrected createLocalMessage method
Future<MessagesTableData> createLocalMessage({
  required String chatId,
  required String userId,
  required String messageType,
  String? content,
  String? attachmentUrl,
  String? attachmentName,
}) async {
  final id = const Uuid().v4();
  final now = DateTime.now();
  
  final message = MessagesTableCompanion.insert(
    id: id,
    chatId: chatId,
    userId: userId,
    content: Value(content),
    messageType: messageType,
    attachmentUrl: Value(attachmentUrl),
    attachmentName: Value(attachmentName),
    createdAt: Value(now),
    updatedAt: Value(now),
    isRead: const Value(false),
    isSynced: const Value(false), // Mark as not synced yet
  );
  
  await _messagesDao.insertMessage(message);
  
  // Update chat's last message timestamp
  await _chatsDao.updateChat(
    ChatsTableCompanion(
      id: Value(chatId),
      lastMessageAt: Value(now),
    ),
  );
  
  // Schedule sync
  await syncUnsentMessages();
  
  // Return the created message - properly getting a single result
  return (_messagesDao.select(_messagesDao.messagesTable)
    ..where((m) => m.id.equals(id)))
    .getSingle();
}

  // Cleanup subscriptions
  void dispose() {
    _chatMembersSubscription?.cancel();
    _messagesSubscription?.cancel();
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final usersDao = ref.watch(usersDaoProvider);
  final chatsDao = ref.watch(chatsDaoProvider);
  final messagesDao = ref.watch(messagesDaoProvider);

  final syncService = SyncService(usersDao, chatsDao, messagesDao);

  ref.onDispose(() {
    syncService.dispose();
  });

  return syncService;
});

// Provider to initialize sync service
final syncServiceInitProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  final syncService = ref.watch(syncServiceProvider);
  await syncService.initialize(userId);
});
