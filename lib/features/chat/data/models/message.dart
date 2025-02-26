import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String chatId,
    required String userId,
    required bool isMe,
    required DateTime createdAt, String? text,
    String? attachmentPath,
    String? attachmentName,
    @Default(AttachmentType.none) AttachmentType attachmentType,
    DateTime? updatedAt,
    @Default(false) bool isRead,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);
  
  // Factory constructor to create from Supabase response
  factory MessageModel.fromSupabase(Map<String, dynamic> data, String currentUserId) => MessageModel(
      id: data['id'] as String,
      chatId: data['chat_id'] as String,
      userId: data['user_id'] as String,
      isMe: data['user_id'] == currentUserId,
      text: data['content'] as String?,
      attachmentPath: data['attachment_url'] as String?,
      attachmentName: data['attachment_name'] as String?,
      attachmentType: _mapMessageTypeToAttachmentType(data['message_type'] as String?),
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : null,
      isRead: data['is_read'] as bool? ?? false,
    );
  
  static AttachmentType _mapMessageTypeToAttachmentType(String? messageType) {
    switch (messageType) {
      case 'image': return AttachmentType.image;
      case 'video': return AttachmentType.video;
      case 'file': return AttachmentType.file;
      case 'audio': return AttachmentType.voice;
      default: return AttachmentType.none;
    }
  }
}