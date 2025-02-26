
import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/chat/data/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
class ChatModel with _$ChatModel {
  const factory ChatModel({
    required int id,
    required UserModel user,
    required DateTime createdAt,
    DateTime? lastMessageTime,
    MessageModel? lastMessage,
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, dynamic> json) => _$ChatModelFromJson(json);
}