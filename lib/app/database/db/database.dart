import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// Define tables
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get username => text()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Chats extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastMessageAt => dateTime()();
  TextColumn get lastMessageText => text().nullable()();
  TextColumn get lastMessageType => text().nullable()();
  BoolColumn get lastMessageIsMe => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class ChatMembers extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text().references(Chats, #id)();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text().references(Chats, #id)();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get content => text().nullable()();
  TextColumn get messageType => text()();
  TextColumn get attachmentUrl => text().nullable()();
  TextColumn get attachmentName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Database class
@DriftDatabase(tables: [Users, Chats, ChatMembers, Messages])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  // User operations
  Future<void> saveUser(UsersCompanion user) => into(users).insert(
    user,
    mode: InsertMode.insertOrReplace,
  );

  Future<List<User>> getAllUsers() => select(users).get();
  
  Stream<User?> watchUser(String userId) => 
    (select(users)..where((u) => u.id.equals(userId)))
      .watchSingleOrNull();
  
  // Chat operations
  Future<void> saveChat(ChatsCompanion chat) => into(chats).insert(
    chat,
    mode: InsertMode.insertOrReplace,
  );
  
  Future<List<Chat>> getAllChats() => select(chats).get();
  
  Stream<List<Chat>> watchAllChats() => select(chats).watch();
  
  // Chat members operations
  Future<void> saveChatMember(ChatMembersCompanion member) => into(chatMembers).insert(
    member,
    mode: InsertMode.insertOrReplace,
  );
  
  Future<List<ChatMember>> getChatMembers(String chatId) => 
    (select(chatMembers)..where((cm) => cm.chatId.equals(chatId))).get();
  
  Stream<List<ChatMember>> watchChatMembers(String chatId) => 
    (select(chatMembers)..where((cm) => cm.chatId.equals(chatId))).watch();
  
  // Message operations
  Future<void> saveMessage(MessagesCompanion message) => into(messages).insert(
    message,
    mode: InsertMode.insertOrReplace,
  );
  
  Future<List<Message>> getChatMessages(String chatId) => 
    (select(messages)
      ..where((m) => m.chatId.equals(chatId))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)]))
      .get();
  
  Stream<List<Message>> watchChatMessages(String chatId) => 
    (select(messages)
      ..where((m) => m.chatId.equals(chatId))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)]))
      .watch();
  
  // Get unsynced messages with attachments for syncing
  Future<List<Message>> getUnsyncedMessagesWithAttachments() => 
    (select(messages)
      ..where((m) => m.isSynced.equals(false) & m.attachmentUrl.isNotNull()))
      .get();
  
  // Mark message as read
  Future<void> markMessageAsRead(String messageId) => 
    (update(messages)..where((m) => m.id.equals(messageId)))
      .write(const MessagesCompanion(isRead: Value(true)));
  
  // Update message attachment URL after syncing
  Future<void> updateMessageAttachmentUrl(String messageId, String url, bool synced) => 
    (update(messages)..where((m) => m.id.equals(messageId)))
      .write(MessagesCompanion(
        attachmentUrl: Value(url),
        isSynced: Value(synced),
      ));
  
  // Get all unsynced items for syncing
  Future<List<Chat>> getUnsyncedChats() => 
    (select(chats)..where((c) => c.isSynced.equals(false))).get();
  
  Future<List<ChatMember>> getUnsyncedChatMembers() => 
    (select(chatMembers)..where((cm) => cm.isSynced.equals(false))).get();
  
  Future<List<Message>> getUnsyncedMessages() => 
    (select(messages)..where((m) => m.isSynced.equals(false))).get();
  
  // Mark item as synced
  Future<void> markChatAsSynced(String chatId) => 
    (update(chats)..where((c) => c.id.equals(chatId)))
      .write(const ChatsCompanion(isSynced: Value(true)));
  
  Future<void> markChatMemberAsSynced(String membershipId) => 
    (update(chatMembers)..where((cm) => cm.id.equals(membershipId)))
      .write(const ChatMembersCompanion(isSynced: Value(true)));
  
  Future<void> markMessageAsSynced(String messageId) => 
    (update(messages)..where((m) => m.id.equals(messageId)))
      .write(const MessagesCompanion(isSynced: Value(true)));
}

// Database connection
LazyDatabase _openConnection() => LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'chat_db.sqlite'));
    return NativeDatabase(file);
  });

  