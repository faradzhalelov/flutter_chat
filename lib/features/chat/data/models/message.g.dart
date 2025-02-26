// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageModelImpl _$$MessageModelImplFromJson(Map<String, dynamic> json) =>
    _$MessageModelImpl(
      id: (json['id'] as num).toInt(),
      chatId: (json['chatId'] as num).toInt(),
      isMe: json['isMe'] as bool,
      text: json['text'] as String?,
      attachmentPath: json['attachmentPath'] as String?,
      attachmentType: $enumDecodeNullable(
              _$AttachmentTypeEnumMap, json['attachmentType']) ??
          AttachmentType.none,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$$MessageModelImplToJson(_$MessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'isMe': instance.isMe,
      'text': instance.text,
      'attachmentPath': instance.attachmentPath,
      'attachmentType': _$AttachmentTypeEnumMap[instance.attachmentType]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
    };

const _$AttachmentTypeEnumMap = {
  AttachmentType.none: 'none',
  AttachmentType.image: 'image',
  AttachmentType.video: 'video',
  AttachmentType.file: 'file',
  AttachmentType.voice: 'voice',
};
