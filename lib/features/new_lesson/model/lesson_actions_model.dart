enum LessonType { school, voice }

enum LessonStatus { draft, active, completed }

LessonType _lessonTypeFromString(String? value) => switch (value) {
  'voice' => LessonType.voice,
  _ => LessonType.school,
};

LessonStatus _lessonStatusFromString(String? value) => switch (value) {
  'active' => LessonStatus.active,
  'completed' => LessonStatus.completed,
  _ => LessonStatus.draft,
};

class AddLesson {
  const AddLesson({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.lessonType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddLesson.fromRow(Map<String, dynamic> row) => AddLesson(
    id: row['id'] as String,
    userId: row['user_id'] as String,
    title: row['title'] as String? ?? '',
    content: row['content'] is Map
        ? Map<String, dynamic>.from(row['content'] as Map)
        : const {},
    lessonType: _lessonTypeFromString(row['lesson_type'] as String?),
    status: _lessonStatusFromString(row['status'] as String?),
    createdAt: DateTime.parse(row['created_at'] as String),
    updatedAt: DateTime.parse(row['updated_at'] as String),
  );

  Map<String, dynamic> toRow(String userId) => {
    'user_id': userId,
    'title': title,
    'content': content,
    'lesson_type': lessonType.name,
    'status': status.name,
  };

  final String id;
  final String userId;
  final String title;
  final Map<String, dynamic> content;
  final LessonType lessonType;
  final LessonStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddLesson copyWith({
    String? title,
    Map<String, dynamic>? content,
    LessonType? lessonType,
    LessonStatus? status,
  }) => AddLesson(
    id: id,
    userId: userId,
    title: title ?? this.title,
    content: content ?? this.content,
    lessonType: lessonType ?? this.lessonType,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
