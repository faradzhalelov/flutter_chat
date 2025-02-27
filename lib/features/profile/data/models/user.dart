
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';


@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String username,
    required DateTime createdAt, 
    @Default(false) bool isOnline,
    String? avatarUrl,
    
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  // Factory constructor to create from Supabase response
  factory UserModel.fromSupabase(Map<String, dynamic> data) => UserModel(
      id: data['id'] as String,
      email: data['email'] as String,
      username: data['username'] as String, // username in Supabase maps to name in our model
      avatarUrl: data['avatar_url'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      isOnline: data['is_online'] as bool? ?? false,
    );
}
