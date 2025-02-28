import 'package:drift/drift.dart';
import 'package:flutter_chat/app/database/db/database.dart';
import 'package:flutter_chat/app/database/dto/chat_dto.dart';
import 'package:flutter_chat/app/database/dto/message_dto.dart';
import 'package:flutter_chat/app/database/dto/user_dto.dart';

part 'daos.g.dart';

// Users DAO
@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<LocalDatabase> with _$UsersDaoMixin {
UsersDao(super.db);


  Future<List<UserDto>> getAllUsers() => select(users).get();
  
  Stream<List<UserDto>> watchAllUsers() => select(users).watch();
  
  Future<UserDto?> getUserById(String id) => 
      (select(users)..where((u) => u.id.equals(id)))
      .getSingleOrNull();
  
  Future<int> insertUser(UsersCompanion user) => 
      into(users).insert(user, mode: InsertMode.insertOrReplace);
  
  Future<bool> updateUser(UsersCompanion user) => 
      update(users).replace(user);
  
  Future<int> deleteUser(String id) => 
      (delete(users)..where((u) => u.id.equals(id))).go();
}

// Chats DAO
@DriftAccessor(tables: [Chats, ChatMembers, Users])
class ChatsDao extends DatabaseAccessor<LocalDatabase> with _$ChatsDaoMixin {
  ChatsDao(super.db);

 Stream<List<(ChatDto, UserDto)>> watchChatsForUser(String userId) => (select(chatMembers)
      ..where((cm) => cm.userId.equals(userId)))
        .watch()
        .asyncMap((chatMemberData) async {
          // Extract all chat IDs for this user
          final chatIds = chatMemberData
              .map((member) => member.chatId)
              .toList();

          if (chatIds.isEmpty) return <(ChatDto, UserDto)>[];

          // Get all chats with their latest data
          final chatsQuery = select(chats)
            ..where((c) => c.id.isIn(chatIds))
            ..orderBy([(c) => OrderingTerm(expression: c.lastMessageAt, mode: OrderingMode.desc)]);
          
          final chatsData = await chatsQuery.get();

          // Process chats in parallel for better performance
          final futures = chatsData.map((chat) async {
            // Get other members
            final otherMembersQuery = select(chatMembers)
              ..where((cm) => cm.chatId.equals(chat.id) & cm.userId.equals(userId).not());
            
            final otherMembersResponse = await otherMembersQuery.get();

            if (otherMembersResponse.isEmpty) return null;

            // Get other user data
            final otherUserId = otherMembersResponse[0].userId;
            final otherUserQuery = select(users)
              ..where((u) => u.id.equals(otherUserId));
            
            final otherUser = await otherUserQuery.getSingleOrNull();
            if (otherUser == null) return null;
            
            return (chat, otherUser);
          });

          // Wait for all futures and filter out nulls
          final results = await Future.wait(futures);
          return results.whereType<(ChatDto, UserDto)>().toList();
        });
  
  Future<ChatDto?> getChatById(String id) => 
      (select(chats)..where((c) => c.id.equals(id)))
      .getSingleOrNull();
  
  Future<int> insertChat(ChatsCompanion chat) => 
      into(chats).insert(chat, mode: InsertMode.insertOrReplace);
  
  Future<bool> updateChat(ChatsCompanion chat) => 
      update(chats).replace(chat);
  
  Future<int> deleteChat(String id) => 
      (delete(chats)..where((c) => c.id.equals(id))).go();
  
  // ChatDto members methods
  Future<int> addChatMember(ChatMembersCompanion chatMember) => 
      into(chatMembers).insert(chatMember, mode: InsertMode.insertOrReplace);
  
  Future<int> removeChatMember(String chatId, String userId) => 
      (delete(chatMembers)
        ..where((cm) => cm.chatId.equals(chatId) & cm.userId.equals(userId)))
      .go();
  
  Stream<List<UserDto>> watchChatMembers(String chatId) {
    final query = select(users)
      .join([
        innerJoin(chatMembers, chatMembers.userId.equalsExp(users.id)),
      ])
      ..where(chatMembers.chatId.equals(chatId));
    
    return query.map((row) => row.readTable(users)).watch();
  }
}

// Messages DAO
@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<LocalDatabase> with _$MessagesDaoMixin {
  MessagesDao(super.db);

  Stream<List<MessageDto>> watchMessagesForChat(String chatId) => 
      (select(messages)
        ..where((m) => m.chatId.equals(chatId))
        ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
      .watch();
  
  Future<List<MessageDto>> getUnsentMessages() async => 
      (select(messages)..where((m) => m.isSynced.equals(false)))
      .get();

  Future<List<MessageDto>> getMessagesByChatId(String chatId) async =>  (select(messages)
            ..where((m) => m.chatId.equals(chatId)))
          .get();
  
  Future<int> insertMessage(MessagesCompanion message)async => 
      into(messages).insert(message, mode: InsertMode.insertOrReplace);
  
  Future<bool> updateMessage(MessagesCompanion message)async => 
      update(messages).replace(message);
  
  Future<int> markMessageAsRead(String messageId)async => 
      (update(messages)..where((m) => m.id.equals(messageId)))
      .write(const MessagesCompanion(isRead: Value(true)));
  
  Future<int> markAllMessagesAsRead(String chatId, String currentUserId)async => 
    (update(messages)
      ..where((m) => m.chatId.equals(chatId) & 
                     m.userId.equals(currentUserId).not() & 
                     m.isRead.equals(false)))
    .write(const MessagesCompanion(isRead: Value(true)));
    
  Future<int> deleteMessage(String id)async => 
      (delete(messages)..where((m) => m.id.equals(id))).go();
}