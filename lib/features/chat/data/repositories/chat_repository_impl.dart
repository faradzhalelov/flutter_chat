import 'dart:developer';

import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/chat/data/repositories/chat_repository.dart';
import 'package:flutter_chat/features/profile/data/models/user.dart';

class ChatRepositoryImpl implements ChatRepository {
  @override
  Future<List<MessageModel>> getMessagesForChat(String chatId) async {
    try {
      return [];
    } catch (e) {
      log('getMessagesForChat error: $e');
      rethrow;
    }
  }

  @override
  Stream<UserModel> getUserStreamById(String userId) {
    try {
      return const Stream.empty();
    } catch (e) {
      log('getUserStreamById error: $e');
      rethrow;
    }
  }

  @override
  Future<void> markMessagesAsRead(String chatId) async {
    try {} catch (e) {
      log('markMessagesAsRead error: $e');
      rethrow;
    }
  }

  @override
  Future<MessageModel> sendFileMessage(
      String chatId, MessageType messageType, String? url, String name) async {
    try {
      return MessageModel(
          id: 'id',
          chatId: chatId,
          userId: 'userId',
          isMe: false,
          createdAt: DateTime.now());
    } catch (e) {
      log('sendFileMessage error: $e');
      rethrow;
    }
  }

  @override
  Future<MessageModel> sendTextMessage(String chatId, String text) async {
     try {
      return MessageModel(
          id: 'id',
          chatId: chatId,
          userId: 'userId',
          isMe: false,
          createdAt: DateTime.now());
    } catch (e) {
      log('sendTextMessage error: $e');
      rethrow;
    }
  }

  @override
  Stream<MessageModel> subscribeToMessages(String chatId) {
      try {
      return const Stream.empty();
    } catch (e) {
      log('subscribeToMessages error: $e');
      rethrow;
    }
  }
}
