// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$UsersDaoMixin on DatabaseAccessor<LocalDatabase> {
  $UsersTable get users => attachedDatabase.users;
}
mixin _$ChatsDaoMixin on DatabaseAccessor<LocalDatabase> {
  $ChatsTable get chats => attachedDatabase.chats;
  $UsersTable get users => attachedDatabase.users;
  $ChatMembersTable get chatMembers => attachedDatabase.chatMembers;
}
mixin _$MessagesDaoMixin on DatabaseAccessor<LocalDatabase> {
  $ChatsTable get chats => attachedDatabase.chats;
  $UsersTable get users => attachedDatabase.users;
  $MessagesTable get messages => attachedDatabase.messages;
}
