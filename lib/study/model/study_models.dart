class StudyNote {
  const StudyNote({
    required this.id,
    required this.title,
    required this.subject,
    required this.preview,
    required this.body,
    required this.createdAt,
    required this.tagColor,
    required this.readMinutes,
    this.markedRanges = const [],
  });

  final String id;
  final String title;
  final String subject;
  final String preview;
  final String body;
  final String createdAt;
  final int tagColor;
  final int readMinutes;
  final List<MarkedRange> markedRanges;
}

class MarkedRange {
  const MarkedRange({required this.start, required this.end, required this.note});
  final int start;
  final int end;
  final String note;
}

enum AiAction { explain, imagine, takeNote }
