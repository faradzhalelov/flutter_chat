import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// Include tables
part 'database.g.dart';

// Users table
class UsersTable extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get username => text()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSeen => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Chats table
class ChatsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastMessageAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// Chat members table
class ChatMembersTable extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text().references(ChatsTable, #id)();
  TextColumn get userId => text().references(UsersTable, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {chatId, userId}
  ];
}

// Messages table
class MessagesTable extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text().references(ChatsTable, #id)();
  TextColumn get userId => text().references(UsersTable, #id)();
  TextColumn get content => text().nullable()();
  TextColumn get messageType => text()();
  TextColumn get attachmentUrl => text().nullable()();
  TextColumn get attachmentName => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [UsersTable, ChatsTable, ChatMembersTable, MessagesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (Migrator m) => m.createAll(),
      onUpgrade: (Migrator m, int from, int to) async {
        // Migrations will be added here in the future
      },
    );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'flutter_chat.db'));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sure the folder exists
    if (!await dbFolder.exists()) {
      await dbFolder.create(recursive: true);
    }

    // Open the database
    return NativeDatabase(file);
  });
