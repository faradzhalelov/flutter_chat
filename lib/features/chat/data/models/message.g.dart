// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageModelImpl _$$MessageModelImplFromJson(Map<String, dynamic> json) =>
    _$MessageModelImpl(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      userId: json['userId'] as String,
      isMe: json['isMe'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      text: json['text'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentName: json['attachmentName'] as String?,
      messageType:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['messageType']) ??
              MessageType.text,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$$MessageModelImplToJson(_$MessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'userId': instance.userId,
      'isMe': instance.isMe,
      'createdAt': instance.createdAt.toIso8601String(),
      'text': instance.text,
      'attachmentUrl': instance.attachmentUrl,
      'attachmentName': instance.attachmentName,
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isRead': instance.isRead,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.file: 'file',
  MessageType.audio: 'audio',
};
