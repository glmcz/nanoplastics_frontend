import 'dart:io';

enum AttachmentType { image, video, document, audio }

class IdeaAttachment {
  final String path;
  final String name;
  final String mimeType;
  final AttachmentType type;

  const IdeaAttachment({
    required this.path,
    required this.name,
    required this.mimeType,
    required this.type,
  });

  File get file => File(path);

  /// Icon codepoint for display in chips
  AttachmentType get displayType => type;
}

/// Maps file extension → MIME type string.
String mimeFromExtension(String ext) =>
    const {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'pdf': 'application/pdf',
      'txt': 'text/plain',
      'csv': 'text/csv',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'm4a': 'audio/mp4',
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'ogg': 'audio/ogg',
      'aac': 'audio/aac',
    }[ext.toLowerCase()] ??
    'application/octet-stream';

/// Infers [AttachmentType] from file extension.
AttachmentType attachmentTypeFromExtension(String ext) {
  switch (ext.toLowerCase()) {
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'webp':
      return AttachmentType.image;
    case 'mp4':
    case 'mov':
      return AttachmentType.video;
    case 'm4a':
    case 'mp3':
    case 'wav':
    case 'ogg':
    case 'aac':
      return AttachmentType.audio;
    default:
      return AttachmentType.document;
  }
}
