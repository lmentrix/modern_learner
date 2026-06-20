enum UploadFileType { pdf, image, doc, other }

extension UploadFileTypeX on UploadFileType {
  String get value => name; // 'pdf' | 'image' | 'doc' | 'other'

  static UploadFileType fromValue(String? v) => switch (v) {
        'pdf' => UploadFileType.pdf,
        'image' => UploadFileType.image,
        'doc' => UploadFileType.doc,
        _ => UploadFileType.other,
      };
}

class UploadedFileModel {
  const UploadedFileModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.fileType,
    required this.fileSize,
    required this.storagePath,
    required this.content,
    required this.cardColor,
    required this.uploadedAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String subject;
  final UploadFileType fileType;
  final String fileSize;
  final String? storagePath;
  final String content;
  final int cardColor;
  final DateTime uploadedAt;
  final DateTime updatedAt;

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) =>
      UploadedFileModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        fileType: UploadFileTypeX.fromValue(json['file_type'] as String?),
        fileSize: json['file_size'] as String? ?? '',
        storagePath: json['storage_path'] as String?,
        content: json['content'] as String? ?? '',
        cardColor: json['card_color'] as int? ?? 0,
        uploadedAt: DateTime.parse(json['uploaded_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'subject': subject,
        'file_type': fileType.value,
        'file_size': fileSize,
        'storage_path': storagePath,
        'content': content,
        'card_color': cardColor,
      };

  UploadedFileModel copyWith({
    String? title,
    String? subject,
    UploadFileType? fileType,
    String? fileSize,
    String? storagePath,
    String? content,
    int? cardColor,
  }) =>
      UploadedFileModel(
        id: id,
        userId: userId,
        title: title ?? this.title,
        subject: subject ?? this.subject,
        fileType: fileType ?? this.fileType,
        fileSize: fileSize ?? this.fileSize,
        storagePath: storagePath ?? this.storagePath,
        content: content ?? this.content,
        cardColor: cardColor ?? this.cardColor,
        uploadedAt: uploadedAt,
        updatedAt: updatedAt,
      );
}
