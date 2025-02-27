// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$UsersDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
}
mixin _$ChatsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChatsTableTable get chatsTable => attachedDatabase.chatsTable;
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $ChatMembersTableTable get chatMembersTable =>
      attachedDatabase.chatMembersTable;
}
mixin _$MessagesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChatsTableTable get chatsTable => attachedDatabase.chatsTable;
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $MessagesTableTable get messagesTable => attachedDatabase.messagesTable;
}
