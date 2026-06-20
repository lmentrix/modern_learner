class NoteModel {
  const NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.preview,
    required this.body,
    required this.tagColor,
    required this.readMinutes,
    required this.markedRanges,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String subject;
  final String preview;
  final String body;
  final int tagColor;
  final int readMinutes;
  final List<MarkedRangeModel> markedRanges;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        preview: json['preview'] as String? ?? '',
        body: json['body'] as String? ?? '',
        tagColor: json['tag_color'] as int? ?? 0,
        readMinutes: json['read_minutes'] as int? ?? 0,
        markedRanges: ((json['marked_ranges'] as List<dynamic>?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(MarkedRangeModel.fromJson)
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'subject': subject,
        'preview': preview,
        'body': body,
        'tag_color': tagColor,
        'read_minutes': readMinutes,
        'marked_ranges': markedRanges.map((r) => r.toJson()).toList(),
      };

  NoteModel copyWith({
    String? title,
    String? subject,
    String? preview,
    String? body,
    int? tagColor,
    int? readMinutes,
    List<MarkedRangeModel>? markedRanges,
  }) =>
      NoteModel(
        id: id,
        userId: userId,
        title: title ?? this.title,
        subject: subject ?? this.subject,
        preview: preview ?? this.preview,
        body: body ?? this.body,
        tagColor: tagColor ?? this.tagColor,
        readMinutes: readMinutes ?? this.readMinutes,
        markedRanges: markedRanges ?? this.markedRanges,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

class MarkedRangeModel {
  const MarkedRangeModel({
    required this.start,
    required this.end,
    required this.note,
  });

  final int start;
  final int end;
  final String note;

  factory MarkedRangeModel.fromJson(Map<String, dynamic> json) =>
      MarkedRangeModel(
        start: json['start'] as int? ?? 0,
        end: json['end'] as int? ?? 0,
        note: json['note'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'start': start, 'end': end, 'note': note};
}
