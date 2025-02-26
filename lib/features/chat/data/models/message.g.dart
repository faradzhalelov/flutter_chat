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
      attachmentPath: json['attachmentPath'] as String?,
      attachmentName: json['attachmentName'] as String?,
      attachmentType: $enumDecodeNullable(
              _$AttachmentTypeEnumMap, json['attachmentType']) ??
          AttachmentType.none,
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
      'attachmentPath': instance.attachmentPath,
      'attachmentName': instance.attachmentName,
      'attachmentType': _$AttachmentTypeEnumMap[instance.attachmentType]!,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isRead': instance.isRead,
    };

const _$AttachmentTypeEnumMap = {
  AttachmentType.none: 'none',
  AttachmentType.image: 'image',
  AttachmentType.video: 'video',
  AttachmentType.file: 'file',
  AttachmentType.voice: 'voice',
};
