// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return _MessageModel.fromJson(json);
}

/// @nodoc
mixin _$MessageModel {
  String get id => throw _privateConstructorUsedError;
  String get chatId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  bool get isMe => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  String? get attachmentPath => throw _privateConstructorUsedError;
  String? get attachmentName => throw _privateConstructorUsedError;
  AttachmentType get attachmentType => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageModelCopyWith<MessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageModelCopyWith<$Res> {
  factory $MessageModelCopyWith(
          MessageModel value, $Res Function(MessageModel) then) =
      _$MessageModelCopyWithImpl<$Res, MessageModel>;
  @useResult
  $Res call(
      {String id,
      String chatId,
      String userId,
      bool isMe,
      DateTime createdAt,
      String? text,
      String? attachmentPath,
      String? attachmentName,
      AttachmentType attachmentType,
      DateTime? updatedAt,
      bool isRead});
}

/// @nodoc
class _$MessageModelCopyWithImpl<$Res, $Val extends MessageModel>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? userId = null,
    Object? isMe = null,
    Object? createdAt = null,
    Object? text = freezed,
    Object? attachmentPath = freezed,
    Object? attachmentName = freezed,
    Object? attachmentType = null,
    Object? updatedAt = freezed,
    Object? isRead = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      isMe: null == isMe
          ? _value.isMe
          : isMe // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentPath: freezed == attachmentPath
          ? _value.attachmentPath
          : attachmentPath // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentName: freezed == attachmentName
          ? _value.attachmentName
          : attachmentName // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentType: null == attachmentType
          ? _value.attachmentType
          : attachmentType // ignore: cast_nullable_to_non_nullable
              as AttachmentType,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageModelImplCopyWith<$Res>
    implements $MessageModelCopyWith<$Res> {
  factory _$$MessageModelImplCopyWith(
          _$MessageModelImpl value, $Res Function(_$MessageModelImpl) then) =
      __$$MessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String chatId,
      String userId,
      bool isMe,
      DateTime createdAt,
      String? text,
      String? attachmentPath,
      String? attachmentName,
      AttachmentType attachmentType,
      DateTime? updatedAt,
      bool isRead});
}

/// @nodoc
class __$$MessageModelImplCopyWithImpl<$Res>
    extends _$MessageModelCopyWithImpl<$Res, _$MessageModelImpl>
    implements _$$MessageModelImplCopyWith<$Res> {
  __$$MessageModelImplCopyWithImpl(
      _$MessageModelImpl _value, $Res Function(_$MessageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? userId = null,
    Object? isMe = null,
    Object? createdAt = null,
    Object? text = freezed,
    Object? attachmentPath = freezed,
    Object? attachmentName = freezed,
    Object? attachmentType = null,
    Object? updatedAt = freezed,
    Object? isRead = null,
  }) {
    return _then(_$MessageModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      isMe: null == isMe
          ? _value.isMe
          : isMe // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentPath: freezed == attachmentPath
          ? _value.attachmentPath
          : attachmentPath // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentName: freezed == attachmentName
          ? _value.attachmentName
          : attachmentName // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentType: null == attachmentType
          ? _value.attachmentType
          : attachmentType // ignore: cast_nullable_to_non_nullable
              as AttachmentType,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageModelImpl implements _MessageModel {
  const _$MessageModelImpl(
      {required this.id,
      required this.chatId,
      required this.userId,
      required this.isMe,
      required this.createdAt,
      this.text,
      this.attachmentPath,
      this.attachmentName,
      this.attachmentType = AttachmentType.none,
      this.updatedAt,
      this.isRead = false});

  factory _$MessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageModelImplFromJson(json);

  @override
  final String id;
  @override
  final String chatId;
  @override
  final String userId;
  @override
  final bool isMe;
  @override
  final DateTime createdAt;
  @override
  final String? text;
  @override
  final String? attachmentPath;
  @override
  final String? attachmentName;
  @override
  @JsonKey()
  final AttachmentType attachmentType;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isRead;

  @override
  String toString() {
    return 'MessageModel(id: $id, chatId: $chatId, userId: $userId, isMe: $isMe, createdAt: $createdAt, text: $text, attachmentPath: $attachmentPath, attachmentName: $attachmentName, attachmentType: $attachmentType, updatedAt: $updatedAt, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.isMe, isMe) || other.isMe == isMe) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.attachmentPath, attachmentPath) ||
                other.attachmentPath == attachmentPath) &&
            (identical(other.attachmentName, attachmentName) ||
                other.attachmentName == attachmentName) &&
            (identical(other.attachmentType, attachmentType) ||
                other.attachmentType == attachmentType) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      chatId,
      userId,
      isMe,
      createdAt,
      text,
      attachmentPath,
      attachmentName,
      attachmentType,
      updatedAt,
      isRead);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      __$$MessageModelImplCopyWithImpl<_$MessageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageModelImplToJson(
      this,
    );
  }
}

abstract class _MessageModel implements MessageModel {
  const factory _MessageModel(
      {required final String id,
      required final String chatId,
      required final String userId,
      required final bool isMe,
      required final DateTime createdAt,
      final String? text,
      final String? attachmentPath,
      final String? attachmentName,
      final AttachmentType attachmentType,
      final DateTime? updatedAt,
      final bool isRead}) = _$MessageModelImpl;

  factory _MessageModel.fromJson(Map<String, dynamic> json) =
      _$MessageModelImpl.fromJson;

  @override
  String get id;
  @override
  String get chatId;
  @override
  String get userId;
  @override
  bool get isMe;
  @override
  DateTime get createdAt;
  @override
  String? get text;
  @override
  String? get attachmentPath;
  @override
  String? get attachmentName;
  @override
  AttachmentType get attachmentType;
  @override
  DateTime? get updatedAt;
  @override
  bool get isRead;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
