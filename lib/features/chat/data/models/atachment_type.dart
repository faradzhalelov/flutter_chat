enum AttachmentType {
  text,
  image,
  video,
  file,
  audio;

  
}

// Extension method to convert AttachmentType to String
extension AttachmentTypeExtension on AttachmentType {
  String toShortString() => toString().split('.').last;

  static AttachmentType fromString(String? value) {
    if (value == null) return AttachmentType.text;
    return AttachmentType.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => AttachmentType.text,
    );
  }
}
