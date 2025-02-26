// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMemberModelImpl _$$ChatMemberModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatMemberModelImpl(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ChatMemberModelImplToJson(
        _$ChatMemberModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
