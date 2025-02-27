// lib/data/repositories/chat_repository.dart
import 'dart:io';

import 'package:flutter_chat/features/chat/data/models/chat.dart';
import 'package:flutter_chat/features/chat/data/models/chat_member.dart';
import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/chat/data/models/user.dart';

/// Abstract chat repository defining all operations required for the chat functionality
abstract class ChatRepository {
  /// Gets all chats for the current authenticated user
  Stream<List<ChatModel>> getChatsForCurrentUserStream();

  Future<List<ChatModel>> getChatsForCurrentUser();

  /// Gets all messages for a specific chat
  Future<List<MessageModel>> getMessagesForChat(String chatId);

  /// Creates a new chat with another user
  /// Returns the chat ID
  Future<String> createChat(String otherUserId);

  /// Sends a text message in a chat
  /// Returns the created message
  Future<MessageModel> sendTextMessage(String chatId, String text);

  /// Sends an image message in a chat
  /// Returns the created message
  Future<MessageModel> sendImageMessage(
      String chatId, String? imageFile, String imageName);

  /// Sends a video message in a chat
  /// Returns the created message
  Future<MessageModel> sendVideoMessage(String chatId, File videoFile);

  /// Sends a file message in a chat
  /// Returns the created message
  Future<MessageModel> sendFileMessage(String chatId, File file);

  /// Sends an audio message in a chat
  /// Returns the created message
  Future<MessageModel> sendAudioMessage(String chatId, File audioFile);

  /// Marks all unread messages in a chat as read
  Future<void> markMessagesAsRead(String chatId);

  /// Deletes a chat and all its messages
  Future<void> deleteChat(String chatId);

  /// Gets a stream of messages for a chat for real-time updates
  Stream<MessageModel> subscribeToMessages(String chatId);

  /// Gets all members of a chat
  Future<List<ChatMemberModel>> getChatMembers(String chatId);

  /// Gets a user by their ID
  Future<UserModel> getUserById(String userId);
}
