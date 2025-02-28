
// Chat DTO
class ChatDto {

  ChatDto({
    required this.id,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessageText,
    this.isSynced,
    this.lastMessageType,
    this.lastMessageUserId,
  });

  // Create from a map (used by drift)
  factory ChatDto.fromJson(Map<String, dynamic> json) => ChatDto(
    id: json['id'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastMessageAt: json['lastMessageAt'] != null 
        ? DateTime.parse(json['lastMessageAt'] as String) 
        : null,
    lastMessageText: json['lastMessageText'] as String?,
    lastMessageType: json['lastMessageType'] as String?,
    lastMessageUserId: json['lastMessageUserId'] as String?,
    isSynced: json['isSynced'] as bool,
  );

  factory ChatDto.fromSupabase(Map<String, dynamic> json) => ChatDto(
    id: json['id'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    lastMessageAt: json['last_message_at'] != null 
        ? DateTime.parse(json['last_message_at'] as String) 
        : null,
    lastMessageText: json['last_message_text'] as String?,
    lastMessageType: json['last_message_type'] as String?,
    lastMessageUserId: json['last_messageUser_id'] as String?,
  );

  final String id;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessageText;
  final String? lastMessageType;
  final String? lastMessageUserId;
  final bool? isSynced;

  // Convert to a map
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'lastMessageAt': lastMessageAt?.toIso8601String(),
    'lastMessageText': lastMessageText,
    'lastMessageType': lastMessageType,
    'lastMessageUserId': lastMessageUserId,
    'isSynced': isSynced,
  };

  Map<String, dynamic> toSupabase() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'last_message_at': lastMessageAt?.toIso8601String(),
    'last_message_text': lastMessageText,
    'last_message_type': lastMessageType,
    'last_message_user_id': lastMessageUserId,
  };

  // Copy with method for creating a new instance with modified properties
  ChatDto copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessageText,
    String? lastMessageType,
    String? lastMessageUserId,
    bool? isSynced,
  }) =>
      ChatDto(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        lastMessageText: lastMessageText ?? this.lastMessageText,
        lastMessageType: lastMessageType ?? this.lastMessageType,
        lastMessageUserId: lastMessageUserId ?? this.lastMessageUserId,
        isSynced: isSynced ?? this.isSynced,
      );
}