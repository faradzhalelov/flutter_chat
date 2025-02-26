enum AttachmentType {
  none,
  image,
  video,
  file,
  voice
}

// Extension method to convert AttachmentType to String
extension AttachmentTypeExtension on AttachmentType {
  String toShortString() => toString().split('.').last;
  
  static AttachmentType fromString(String? value) {
    if (value == null) return AttachmentType.none;
    return AttachmentType.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => AttachmentType.none,
    );
  }
}
