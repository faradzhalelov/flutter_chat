// lib/data/repositories/chat_repository.dart

import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/profile/data/models/user.dart';

/// Abstract chat repository
abstract class ChatRepository {

  /// Gets all messages for a specific chat
  Future<List<MessageModel>> getMessagesForChat(String chatId);

  /// Gets a stream of messages for a chat for real-time updates
  Stream<MessageModel> subscribeToMessages(String chatId);

  /// Sends a text message in a chat
  /// Returns the created message
  Future<MessageModel> sendTextMessage(String chatId, String text);

  /// Sends an file message in a chat
  /// Returns the created message
  Future<MessageModel> sendFileMessage(
      String chatId, MessageType messageType, String? url, String name,);

  /// Marks all unread messages in a chat as read
  Future<void> markMessagesAsRead(String chatId);

  /// Gets a user by their ID
  Stream<UserModel> getUserStreamById(String userId);
}
