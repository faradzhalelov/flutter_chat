
import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/chat/data/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
class ChatModel with _$ChatModel {
  const factory ChatModel({
    required String id,
    required UserModel user, // The other user in the chat
    required DateTime createdAt,
    DateTime? lastMessageTime,
    MessageModel? lastMessage,
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, dynamic> json) => _$ChatModelFromJson(json);
  
  // Factory constructor to create from Supabase response
  factory ChatModel.fromSupabase(
    Map<String, dynamic> chatData,
    UserModel otherUser,
    MessageModel? lastMessage,
  ) => ChatModel(
      id: chatData['id'] as String,
      user: otherUser,
      createdAt: DateTime.parse(chatData['created_at'] as String),
      lastMessageTime: chatData['last_message_at'] != null 
        ? DateTime.parse(chatData['last_message_at'] as String) 
        : null,
      lastMessage: lastMessage,
    );
}