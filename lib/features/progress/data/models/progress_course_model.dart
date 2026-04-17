import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';

/// DTO for [ProgressCourseSelection] ↔ Supabase `user_courses` table.
class ProgressCourseModel {
  const ProgressCourseModel({
    required this.title,
    required this.topic,
    required this.roadmapLanguage,
    required this.level,
    required this.nativeLanguage,
    this.roadmapJson,
  });

  factory ProgressCourseModel.fromRow(Map<String, dynamic> row) =>
      ProgressCourseModel(
        title: row['title'] as String,
        topic: row['topic'] as String,
        roadmapLanguage: row['roadmap_language'] as String,
        level: row['level'] as String,
        nativeLanguage: row['native_language'] as String,
        roadmapJson: row['roadmap_json'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toRow(String userId) => {
        'user_id': userId,
        'title': title,
        'topic': topic,
        'roadmap_language': roadmapLanguage,
        'level': level,
        'native_language': nativeLanguage,
        if (roadmapJson != null) 'roadmap_json': roadmapJson,
      };

  ProgressCourseSelection toEntity() => ProgressCourseSelection(
        title: title,
        topic: topic,
        roadmapLanguage: roadmapLanguage,
        level: level,
        nativeLanguage: nativeLanguage,
        roadmapJson: roadmapJson,
      );

  static ProgressCourseModel fromEntity(ProgressCourseSelection e) =>
      ProgressCourseModel(
        title: e.title,
        topic: e.topic,
        roadmapLanguage: e.roadmapLanguage,
        level: e.level,
        nativeLanguage: e.nativeLanguage,
        roadmapJson: e.roadmapJson,
      );

  final String title;
  final String topic;
  final String roadmapLanguage;
  final String level;
  final String nativeLanguage;
  final Map<String, dynamic>? roadmapJson;
}
