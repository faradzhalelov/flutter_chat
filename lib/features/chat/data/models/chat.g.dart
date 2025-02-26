// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatModelImpl _$$ChatModelImplFromJson(Map<String, dynamic> json) =>
    _$ChatModelImpl(
      id: json['id'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMessageTime: json['lastMessageTime'] == null
          ? null
          : DateTime.parse(json['lastMessageTime'] as String),
      lastMessage: json['lastMessage'] == null
          ? null
          : MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ChatModelImplToJson(_$ChatModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastMessageTime': instance.lastMessageTime?.toIso8601String(),
      'lastMessage': instance.lastMessage,
    };
