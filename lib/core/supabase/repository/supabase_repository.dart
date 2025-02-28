import 'package:flutter_chat/app/database/db/message_type.dart';
import 'package:flutter_chat/app/database/dto/chat_dto.dart';
import 'package:flutter_chat/app/database/dto/chat_member_dto.dart';
import 'package:flutter_chat/app/database/dto/message_dto.dart';
import 'package:flutter_chat/app/database/dto/user_dto.dart';

abstract class SupabaseRepository {
  ///
  Future<List<MessageDto>> getMessagesForChat(String chatId);

  ///
  Stream<MessageDto> subscribeToMessages(String chatId);

  ///
  Future<List<(ChatDto, UserDto)>> getAllChats();

  ///
  Stream<List<(ChatDto, UserDto)>> subscribeToChats();

  ///
  Future<UserDto> getUser(String userId);

  ///
  Future<String?> createChat(String otherUserId);

  ///
  Future<void> deleteChat(String chatId);

  ///
  Future<List<ChatMemberDto>> getChatMembers(String chatId);

  ///
  Future<void> markMessagesAsRead(String chatId);

  // Delete attachments from storage
  Future<void> deleteAtachmentsFromStorage(List<MessageDto> messages);

  ///
  Future<MessageDto> sendMessage(
    String chatId,
    String? text,
    String? attachmentUrl,
    String? attachmentName,
    MessageType messageType,
  );
}
