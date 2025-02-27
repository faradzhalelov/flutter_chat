import 'package:flutter_chat/app/database/dao/daos.dart';
import 'package:flutter_chat/app/database/db/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

final usersDaoProvider = Provider<UsersDao>((ref) {
  final database = ref.watch(databaseProvider);
  return UsersDao(database);
});

final chatsDaoProvider = Provider<ChatsDao>((ref) {
  final database = ref.watch(databaseProvider);
  return ChatsDao(database);
});

final messagesDaoProvider = Provider<MessagesDao>((ref) {
  final database = ref.watch(databaseProvider);
  return MessagesDao(database);
});