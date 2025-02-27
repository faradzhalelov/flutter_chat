import 'package:drift/drift.dart';
import 'package:flutter_chat/app/database/db/database.dart';

part 'daos.g.dart';

// Users DAO
@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<LocalDatabase> with _$UsersDaoMixin {
UsersDao(super.db);


  Future<List<User>> getAllUsers() => select(users).get();
  
  Stream<List<User>> watchAllUsers() => select(users).watch();
  
  Future<User?> getUserById(String id) => 
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

  Stream<List<Chat>> watchChatsForUser(String userId) {
    final query = select(chats)
      .join([
        innerJoin(chatMembers, chatMembers.chatId.equalsExp(chats.id)),
      ])
      ..where(chatMembers.userId.equals(userId))
      ..orderBy([OrderingTerm.desc(chats.lastMessageAt)]);
    
    return query.map((row) => row.readTable(chats)).watch();
  }
  
  Future<Chat?> getChatById(String id) => 
      (select(chats)..where((c) => c.id.equals(id)))
      .getSingleOrNull();
  
  Future<int> insertChat(ChatsCompanion chat) => 
      into(chats).insert(chat, mode: InsertMode.insertOrReplace);
  
  Future<bool> updateChat(ChatsCompanion chat) => 
      update(chats).replace(chat);
  
  Future<int> deleteChat(String id) => 
      (delete(chats)..where((c) => c.id.equals(id))).go();
  
  // Chat members methods
  Future<int> addChatMember(ChatMembersCompanion chatMember) => 
      into(chatMembers).insert(chatMember, mode: InsertMode.insertOrReplace);
  
  Future<int> removeChatMember(String chatId, String userId) => 
      (delete(chatMembers)
        ..where((cm) => cm.chatId.equals(chatId) & cm.userId.equals(userId)))
      .go();
  
  Stream<List<User>> watchChatMembers(String chatId) {
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

  Stream<List<Message>> watchMessagesForChat(String chatId) => 
      (select(messages)
        ..where((m) => m.chatId.equals(chatId))
        ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
      .watch();
  
  Future<List<Message>> getUnsentMessages() => 
      (select(messages)..where((m) => m.isSynced.equals(false)))
      .get();
  
  Future<int> insertMessage(MessagesCompanion message) => 
      into(messages).insert(message, mode: InsertMode.insertOrReplace);
  
  Future<bool> updateMessage(MessagesCompanion message) => 
      update(messages).replace(message);
  
  Future<int> markMessageAsRead(String messageId) => 
      (update(messages)..where((m) => m.id.equals(messageId)))
      .write(const MessagesCompanion(isRead: Value(true)));
  
  Future<int> markAllMessagesAsRead(String chatId, String currentUserId) => 
    (update(messages)
      ..where((m) => m.chatId.equals(chatId) & 
                     m.userId.equals(currentUserId).not() & 
                     m.isRead.equals(false)))
    .write(const MessagesCompanion(isRead: Value(true)));
    
  Future<int> deleteMessage(String id) => 
      (delete(messages)..where((m) => m.id.equals(id))).go();
}