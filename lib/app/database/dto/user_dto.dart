
// User DTO
class UserDto {

  UserDto({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt, required this.isOnline, this.avatarUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'] as String,
    email: json['email'] as String,
    username: json['username'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isOnline: json['isOnline'] as bool,
  );

  factory UserDto.fromSupabase(Map<String, dynamic> json) => UserDto(
    id: json['id'] as String,
    email: json['email'] as String,
    username: json['username'] as String,
    avatarUrl: json['avatar_url'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    isOnline: json['is_online'] as bool,
  );

  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isOnline;

  // Convert to a map
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
    'isOnline': isOnline,
  };

    // Convert to a map
  Map<String, dynamic> toSupabase() => {
    'id': id,
    'email': email,
    'username': username,
    'avatar_url': avatarUrl,
    'created_at': createdAt.toIso8601String(),
    'is_online': isOnline,
  };

  // Copy with method for creating a new instance with modified properties
  UserDto copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isOnline,
  }) =>
      UserDto(
        id: id ?? this.id,
        email: email ?? this.email,
        username: username ?? this.username,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt ?? this.createdAt,
        isOnline: isOnline ?? this.isOnline,
      );
}
