
// Message DTO
class MessageDto {

  MessageDto({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.messageType, required this.createdAt, required this.isRead, this.content,
    this.attachmentUrl,
    this.attachmentName,
    this.updatedAt,
    this.isSynced,
  });

  // Create from a map (used by drift)
  factory MessageDto.fromJson(Map<String, dynamic> json) => MessageDto(
    id: json['id'] as String,
    chatId: json['chatId'] as String,
    userId: json['userId'] as String,
    content: json['content'] as String?,
    messageType: json['messageType'] as String,
    attachmentUrl: json['attachmentUrl'] as String?,
    attachmentName: json['attachmentName'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'] as String) 
        : null,
    isRead: json['isRead'] as bool,
    isSynced: json['isSynced'] as bool,
  );

    factory MessageDto.fromSupabase(Map<String, dynamic> json) => MessageDto(
    id: json['id'] as String,
    chatId: json['chat_id'] as String,
    userId: json['user_id'] as String,
    content: json['content'] as String?,
    messageType: json['message_type'] as String,
    attachmentUrl: json['attachment_url'] as String?,
    attachmentName: json['attachment_name'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at'] as String) 
        : null,
    isRead: json['is_read'] as bool,
  );

  final String id;
  final String chatId;
  final String userId;
  final String? content;
  final String messageType;
  final String? attachmentUrl;
  final String? attachmentName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isRead;
  final bool? isSynced;

  // Convert to a map
  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'userId': userId,
    'content': content,
    'messageType': messageType,
    'attachmentUrl': attachmentUrl,
    'attachmentName': attachmentName,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isRead': isRead,
    'isSynced': isSynced,
  };

    Map<String, dynamic> toSupabase() => {
    'id': id,
    'chat_id': chatId,
    'user_id': userId,
    'content': content,
    'message_type': messageType,
    'attachment_url': attachmentUrl,
    'attachment_name': attachmentName,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'is_read': isRead,
  };

  // Copy with method for creating a new instance with modified properties
  MessageDto copyWith({
    String? id,
    String? chatId,
    String? userId,
    String? content,
    String? messageType,
    String? attachmentUrl,
    String? attachmentName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRead,
    bool? isSynced,
  }) =>
      MessageDto(
        id: id ?? this.id,
        chatId: chatId ?? this.chatId,
        userId: userId ?? this.userId,
        content: content ?? this.content,
        messageType: messageType ?? this.messageType,
        attachmentUrl: attachmentUrl ?? this.attachmentUrl,
        attachmentName: attachmentName ?? this.attachmentName,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isRead: isRead ?? this.isRead,
        isSynced: isSynced ?? this.isSynced,
      );
}