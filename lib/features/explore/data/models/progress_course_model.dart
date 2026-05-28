import 'package:modern_learner_production/core/models/progress_course_selection.dart';

/// DTO for [ProgressCourseSelection] ↔ Supabase `user_courses` table.
class ProgressCourseModel {
  const ProgressCourseModel({
    required this.title,
    required this.topic,
    required this.roadmapLanguage,
    required this.level,
    required this.nativeLanguage,
    this.id,
    this.roadmapJson,
    this.courseType = ProgressCourseType.school,
  });

  factory ProgressCourseModel.fromRow(Map<String, dynamic> row) =>
      ProgressCourseModel(
        id: row['id'] as String?,
        title: row['title'] as String,
        topic: row['topic'] as String,
        roadmapLanguage: row['roadmap_language'] as String,
        level: row['level'] as String,
        nativeLanguage: row['native_language'] as String,
        roadmapJson: row['roadmap_json'] is Map
            ? Map<String, dynamic>.from(row['roadmap_json'] as Map)
            : null,
        courseType: _inferCourseType(
          row['lesson_type'] as String?,
          row['roadmap_json'] is Map
              ? Map<String, dynamic>.from(row['roadmap_json'] as Map)
              : null,
        ),
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
    courseType: courseType,
    courseId: id,
  );

  static ProgressCourseModel fromEntity(ProgressCourseSelection e) =>
      ProgressCourseModel(
        id: e.courseId,
        title: e.title,
        topic: e.topic,
        roadmapLanguage: e.roadmapLanguage,
        level: e.level,
        nativeLanguage: e.nativeLanguage,
        roadmapJson: e.roadmapJson,
        courseType: e.courseType,
      );

  final String? id;
  final String title;
  final String topic;
  final String roadmapLanguage;
  final String level;
  final String nativeLanguage;
  final Map<String, dynamic>? roadmapJson;
  final ProgressCourseType courseType;

  static ProgressCourseType _inferCourseType(
    String? rawValue,
    Map<String, dynamic>? roadmapJson,
  ) {
    if ((rawValue ?? '').trim().isNotEmpty) {
      return progressCourseTypeFromString(rawValue);
    }

    if (roadmapJson == null) {
      return ProgressCourseType.school;
    }

    final basePayload = _extractBaseRoadmapPayload(roadmapJson);

    if (basePayload['voiceProfile'] is Map<String, dynamic> ||
        basePayload['voice_profile'] is Map<String, dynamic>) {
      return ProgressCourseType.voice;
    }

    final chapters = basePayload['chapters'];
    if (chapters is! List<dynamic>) {
      return ProgressCourseType.school;
    }

    for (final chapter in chapters.whereType<Map<dynamic, dynamic>>()) {
      final lessons = chapter['lessons'];
      if (lessons is! List<dynamic>) {
        continue;
      }

      for (final lesson in lessons.whereType<Map<dynamic, dynamic>>()) {
        final voiceType = (lesson['voiceType'] ?? lesson['voice_type'])
            ?.toString();
        if ((voiceType ?? '').trim().isNotEmpty) {
          return ProgressCourseType.voice;
        }
      }
    }

    return ProgressCourseType.school;
  }

  static Map<String, dynamic> _extractBaseRoadmapPayload(
    Map<String, dynamic> raw,
  ) {
    final roadmap = _unwrapNestedMap(raw, 'roadmap');
    if (roadmap != null) {
      final nestedData = _unwrapNestedMap(roadmap, 'data');
      return nestedData ?? roadmap;
    }

    final data = _unwrapNestedMap(raw, 'data');
    return data ?? raw;
  }

  static Map<String, dynamic>? _unwrapNestedMap(
    Map<String, dynamic> raw,
    String key,
  ) {
    final nested = raw[key];
    if (nested is Map<String, dynamic>) return nested;
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return null;
  }
}
