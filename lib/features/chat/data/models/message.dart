import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required int id,
    required int chatId,
    required bool isMe,
    String? text,
    String? attachmentPath,
    @Default(AttachmentType.none) AttachmentType attachmentType,
    required DateTime createdAt,
    @Default(false) bool isRead,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);
}
