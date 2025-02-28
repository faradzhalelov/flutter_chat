import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/chat_list/data/models/chat.dart';
import 'package:flutter_chat/features/chat_list/data/models/chat_member.dart';
import 'package:flutter_chat/features/profile/data/models/user.dart';

abstract class SupabaseRepository {
  ///
  Future<List<MessageModel>> getMessagesForChat(String chatId);

  ///
  Stream<MessageModel> subscribeToMessages(String chatId);

  ///
  Future<List<ChatModel>> getAllChats();

  ///
  Stream<List<ChatModel>> subscribeToChats();

  ///
  Future<UserModel> getUser(String userId);

  ///
  Future<String?> createChat(String otherUserId);

  ///
  Future<void> deleteChat(String chatId);

  ///
  Future<List<ChatMemberModel>> getChatMembers(String chatId);

  ///
  Future<void> markMessagesAsRead(String chatId);

  ///
  Future<MessageModel> sendMessage(
    String chatId,
    String? text,
    String? attachmentUrl,
    String? attachmentName,
    MessageType messageType,
  );
}
