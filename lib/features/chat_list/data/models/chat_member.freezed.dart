// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMemberModel _$ChatMemberModelFromJson(Map<String, dynamic> json) {
  return _ChatMemberModel.fromJson(json);
}

/// @nodoc
mixin _$ChatMemberModel {
  String get id => throw _privateConstructorUsedError;
  String get chatId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ChatMemberModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMemberModelCopyWith<ChatMemberModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMemberModelCopyWith<$Res> {
  factory $ChatMemberModelCopyWith(
          ChatMemberModel value, $Res Function(ChatMemberModel) then) =
      _$ChatMemberModelCopyWithImpl<$Res, ChatMemberModel>;
  @useResult
  $Res call({String id, String chatId, String userId, DateTime createdAt});
}

/// @nodoc
class _$ChatMemberModelCopyWithImpl<$Res, $Val extends ChatMemberModel>
    implements $ChatMemberModelCopyWith<$Res> {
  _$ChatMemberModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? userId = null,
    Object? createdAt = null,
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMemberModelImplCopyWith<$Res>
    implements $ChatMemberModelCopyWith<$Res> {
  factory _$$ChatMemberModelImplCopyWith(_$ChatMemberModelImpl value,
          $Res Function(_$ChatMemberModelImpl) then) =
      __$$ChatMemberModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String chatId, String userId, DateTime createdAt});
}

/// @nodoc
class __$$ChatMemberModelImplCopyWithImpl<$Res>
    extends _$ChatMemberModelCopyWithImpl<$Res, _$ChatMemberModelImpl>
    implements _$$ChatMemberModelImplCopyWith<$Res> {
  __$$ChatMemberModelImplCopyWithImpl(
      _$ChatMemberModelImpl _value, $Res Function(_$ChatMemberModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? userId = null,
    Object? createdAt = null,
  }) {
    return _then(_$ChatMemberModelImpl(
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMemberModelImpl implements _ChatMemberModel {
  const _$ChatMemberModelImpl(
      {required this.id,
      required this.chatId,
      required this.userId,
      required this.createdAt});

  factory _$ChatMemberModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMemberModelImplFromJson(json);

  @override
  final String id;
  @override
  final String chatId;
  @override
  final String userId;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ChatMemberModel(id: $id, chatId: $chatId, userId: $userId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMemberModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, chatId, userId, createdAt);

  /// Create a copy of ChatMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMemberModelImplCopyWith<_$ChatMemberModelImpl> get copyWith =>
      __$$ChatMemberModelImplCopyWithImpl<_$ChatMemberModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMemberModelImplToJson(
      this,
    );
  }
}

abstract class _ChatMemberModel implements ChatMemberModel {
  const factory _ChatMemberModel(
      {required final String id,
      required final String chatId,
      required final String userId,
      required final DateTime createdAt}) = _$ChatMemberModelImpl;

  factory _ChatMemberModel.fromJson(Map<String, dynamic> json) =
      _$ChatMemberModelImpl.fromJson;

  @override
  String get id;
  @override
  String get chatId;
  @override
  String get userId;
  @override
  DateTime get createdAt;

  /// Create a copy of ChatMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMemberModelImplCopyWith<_$ChatMemberModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
