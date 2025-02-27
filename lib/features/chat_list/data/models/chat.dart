
import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:flutter_chat/features/profile/data/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
class ChatModel with _$ChatModel {
  const factory ChatModel({
    required String id,
    required UserModel user, // The other user in the chat
    required DateTime createdAt,
    DateTime? lastMessageAt,
    String? lastMessageText,
    bool? lastMessageIsMe,
    MessageType? lastMessageType,
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, dynamic> json) => _$ChatModelFromJson(json);
  
  // Factory constructor to create from Supabase response
  factory ChatModel.fromSupabase(
    Map<String, dynamic> chatData,
    UserModel otherUser,
  ) => ChatModel(
      id: chatData['id'] as String,
      user: otherUser,
      createdAt: DateTime.parse(chatData['created_at'] as String),
      lastMessageAt: chatData['last_message_at'] != null 
        ? DateTime.parse(chatData['last_message_at'] as String) 
        : null,
      lastMessageText: chatData['last_message_text'] as String?,
      lastMessageType:  chatData['last_message_type'] != null ? MessageType.values.byName(chatData['last_message_type'] as String) : null,
      lastMessageIsMe: chatData['last_message_is_me'] as bool? ?? false,
    );
}