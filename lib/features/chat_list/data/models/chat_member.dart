
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_member.freezed.dart';
part 'chat_member.g.dart';

@freezed
class ChatMemberModel with _$ChatMemberModel {
  const factory ChatMemberModel({
    required String id,
    required String chatId,
    required String userId,
    required DateTime createdAt,
  }) = _ChatMemberModel;

  factory ChatMemberModel.fromJson(Map<String, dynamic> json) => _$ChatMemberModelFromJson(json);
  
  // Factory constructor to create from Supabase response
  factory ChatMemberModel.fromSupabase(Map<String, dynamic> data) => ChatMemberModel(
      id: data['id'] as String,
      chatId: data['chat_id'] as String,
      userId: data['user_id'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
}