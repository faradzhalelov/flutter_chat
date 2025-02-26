
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';


@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String name,
    required DateTime createdAt, 
    String? avatarUrl,
    String? phoneNumber,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}