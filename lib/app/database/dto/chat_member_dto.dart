
// ChatMember DTO
class ChatMemberDto {

  ChatMemberDto({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.createdAt,
    this.isSynced,
  });

  // Create from a map (used by drift)
  factory ChatMemberDto.fromJson(Map<String, dynamic> json) => ChatMemberDto(
    id: json['id'] as String,
    chatId: json['chatId'] as String,
    userId: json['userId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isSynced: json['isSynced'] as bool,
  );

    factory ChatMemberDto.fromSupabase(Map<String, dynamic> json) => ChatMemberDto(
    id: json['id'] as String,
    chatId: json['chat_id'] as String,
    userId: json['user_id'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final String id;
  final String chatId;
  final String userId;
  final DateTime createdAt;
  final bool? isSynced;

  // Convert to a map
  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
    'isSynced': isSynced,
  };

    Map<String, dynamic> toSupabase() => {
    'id': id,
    'chat_id': chatId,
    'user_id': userId,
    'created_at': createdAt.toIso8601String(),
  };

  // Copy with method for creating a new instance with modified properties
  ChatMemberDto copyWith({
    String? id,
    String? chatId,
    String? userId,
    DateTime? createdAt,
    bool? isSynced,
  }) =>
      ChatMemberDto(
        id: id ?? this.id,
        chatId: chatId ?? this.chatId,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        isSynced: isSynced ?? this.isSynced,
      );
}
