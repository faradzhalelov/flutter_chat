import 'package:drift/drift.dart';
import 'package:flutter_chat/app/database/db/database.dart';

part 'daos.g.dart';

// Users DAO
@DriftAccessor(tables: [UsersTable])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(AppDatabase db) : super(db);

  Future<List<UsersTableData>> getAllUsers() => select(usersTable).get();
  
  Stream<List<UsersTableData>> watchAllUsers() => select(usersTable).watch();
  
  Future<UsersTableData?> getUserById(String id) => 
      (select(usersTable)..where((u) => u.id.equals(id)))
      .getSingleOrNull();
  
  Future<int> insertUser(UsersTableCompanion user) => 
      into(usersTable).insert(user, mode: InsertMode.insertOrReplace);
  
  Future<bool> updateUser(UsersTableCompanion user) => 
      update(usersTable).replace(user);
  
  Future<int> deleteUser(String id) => 
      (delete(usersTable)..where((u) => u.id.equals(id))).go();
}

// Chats DAO
@DriftAccessor(tables: [ChatsTable, ChatMembersTable, UsersTable])
class ChatsDao extends DatabaseAccessor<AppDatabase> with _$ChatsDaoMixin {
  ChatsDao(AppDatabase db) : super(db);

  Stream<List<ChatsTableData>> watchChatsForUser(String userId) {
    final query = select(chatsTable)
      .join([
        innerJoin(chatMembersTable, chatMembersTable.chatId.equalsExp(chatsTable.id)),
      ])
      ..where(chatMembersTable.userId.equals(userId))
      ..orderBy([OrderingTerm.desc(chatsTable.lastMessageAt)]);
    
    return query.map((row) => row.readTable(chatsTable)).watch();
  }
  
  Future<ChatsTableData?> getChatById(String id) => 
      (select(chatsTable)..where((c) => c.id.equals(id)))
      .getSingleOrNull();
  
  Future<int> insertChat(ChatsTableCompanion chat) => 
      into(chatsTable).insert(chat, mode: InsertMode.insertOrReplace);
  
  Future<bool> updateChat(ChatsTableCompanion chat) => 
      update(chatsTable).replace(chat);
  
  Future<int> deleteChat(String id) => 
      (delete(chatsTable)..where((c) => c.id.equals(id))).go();
  
  // Chat members methods
  Future<int> addChatMember(ChatMembersTableCompanion chatMember) => 
      into(chatMembersTable).insert(chatMember, mode: InsertMode.insertOrReplace);
  
  Future<int> removeChatMember(String chatId, String userId) => 
      (delete(chatMembersTable)
        ..where((cm) => cm.chatId.equals(chatId) & cm.userId.equals(userId)))
      .go();
  
  Stream<List<UsersTableData>> watchChatMembers(String chatId) {
    final query = select(usersTable)
      .join([
        innerJoin(chatMembersTable, chatMembersTable.userId.equalsExp(usersTable.id)),
      ])
      ..where(chatMembersTable.chatId.equals(chatId));
    
    return query.map((row) => row.readTable(usersTable)).watch();
  }
}

// Messages DAO
@DriftAccessor(tables: [MessagesTable])
class MessagesDao extends DatabaseAccessor<AppDatabase> with _$MessagesDaoMixin {
  MessagesDao(AppDatabase db) : super(db);

  Stream<List<MessagesTableData>> watchMessagesForChat(String chatId) => 
      (select(messagesTable)
        ..where((m) => m.chatId.equals(chatId))
        ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
      .watch();
  
  Future<List<MessagesTableData>> getUnsentMessages() => 
      (select(messagesTable)..where((m) => m.isSynced.equals(false)))
      .get();
  
  Future<int> insertMessage(MessagesTableCompanion message) => 
      into(messagesTable).insert(message, mode: InsertMode.insertOrReplace);
  
  Future<bool> updateMessage(MessagesTableCompanion message) => 
      update(messagesTable).replace(message);
  
  Future<int> markMessageAsRead(String messageId) => 
      (update(messagesTable)..where((m) => m.id.equals(messageId)))
      .write(const MessagesTableCompanion(isRead: Value(true)));
  
 Future<int> markAllMessagesAsRead(String chatId, String currentUserId) => 
    (update(messagesTable)
      ..where((m) => m.chatId.equals(chatId) & 
                     m.userId.equals(currentUserId).not() & 
                     m.isRead.equals(false),))

    .write(const MessagesTableCompanion(isRead: Value(true)));
  Future<int> deleteMessage(String id) => 
      (delete(messagesTable)..where((m) => m.id.equals(id))).go();
}