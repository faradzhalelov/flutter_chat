import 'package:flutter_chat/features/chat_list/data/models/chat.dart';
import 'package:flutter_chat/features/chat_list/data/models/chat_member.dart';
import 'package:flutter_chat/features/profile/data/models/user.dart';

/// Abstract chat list repository 
abstract class ChatListRepository {
  /// Gets all chats for the current authenticated user
  Stream<List<ChatModel>> getChatsForCurrentUserStream();
  Future<List<ChatModel>> getChatsForCurrentUser();

  /// Creates a new chat with another user
  /// Returns the chat ID
  Future<String> createChat(String otherUserId);

  /// Deletes a chat and all its messages
  Future<void> deleteChat(String chatId);

  /// Gets all members of a chat
  Future<List<ChatMemberModel>> getChatMembers(String chatId);

  /// Gets a user by their ID
  Future<UserModel> getUserById(String userId);
}
