enum MessageType {
  text,
  image,
  video,
  file,
  audio;
}

// Extension method to convert AttachmentType to String
extension MessageTypeExtension on MessageType {
  String toShortString() => toString().split('.').last;

  static MessageType fromString(String? value) {
    if (value == null) return MessageType.text;
    return MessageType.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => MessageType.text,
    );
  }
}
