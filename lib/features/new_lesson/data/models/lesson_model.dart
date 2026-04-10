import 'package:modern_learner_production/features/new_lesson/domain/entities/lesson.dart';

class LessonModel extends NewLesson {
  const LessonModel({
    required super.id,
    required super.userId,
    required super.lessonType,
    required super.contentType,
    required super.difficulty,
    required super.title,
    super.content,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lessonType: _parseType(json['lesson_type'] as String),
      contentType: json['content_type'] as String,
      difficulty: json['difficulty'] as String,
      title: json['title'] as String,
      content: json['content'] as Map<String, dynamic>?,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lesson_type': lessonType.name,
      'content_type': contentType,
      'difficulty': difficulty,
      'title': title,
      if (content != null) 'content': content,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Builds only the fields that should be sent on INSERT (excludes server-set fields).
  Map<String, dynamic> toInsertJson() {
    return {
      'lesson_type': lessonType.name,
      'content_type': contentType,
      'difficulty': difficulty,
      'title': title,
      if (content != null) 'content': content,
      'status': status.name,
    };
  }

  static NewLessonType _parseType(String value) {
    return NewLessonType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NewLessonType.language,
    );
  }

  static NewLessonStatus _parseStatus(String value) {
    return NewLessonStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NewLessonStatus.draft,
    );
  }
}
