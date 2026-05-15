import 'package:modern_learner_production/core/models/progress_course_selection.dart';

class AllLessonsLesson {
  const AllLessonsLesson({
    required this.id,
    required this.lessonType,
    required this.contentType,
    required this.difficulty,
    required this.title,
    required this.status,
    this.content,
  });

  factory AllLessonsLesson.fromMap(Map<String, dynamic> map) =>
      AllLessonsLesson(
        id: map['id'] as String,
        lessonType: map['lesson_type'] as String? ?? 'school',
        contentType: map['content_type'] as String? ?? '',
        difficulty: map['difficulty'] as String? ?? 'Beginner',
        title: map['title'] as String? ?? '',
        status: map['status'] as String? ?? 'draft',
        content: map['content'] == null
            ? null
            : Map<String, dynamic>.from(map['content'] as Map),
      );

  final String id;
  final String lessonType;
  final String contentType;
  final String difficulty;
  final String title;
  final String status;
  final Map<String, dynamic>? content;

  String get topic {
    final value = content?['topic'] as String?;
    if (value != null && value.trim().isNotEmpty) return value.trim();
    return contentType;
  }

  String get subtitle => topic.isNotEmpty ? topic : contentType;

  String get emoji {
    if (lessonType == 'language') return '🎤';
    switch (contentType.toLowerCase()) {
      case 'science':
        return '🔬';
      case 'math':
      case 'mathematics':
        return '📐';
      case 'history':
        return '📜';
      case 'biology':
        return '🌱';
      case 'chemistry':
        return '⚗️';
      case 'physics':
        return '⚡';
      case 'english':
        return '✍️';
      case 'geography':
        return '🌍';
      case 'music':
        return '🎵';
      default:
        return '📚';
    }
  }

  String get duration {
    switch (difficulty) {
      case 'Advanced':
        return '30 min';
      case 'Intermediate':
        return '20 min';
      default:
        return '15 min';
    }
  }

  double get progress => status == 'completed' ? 1.0 : 0.0;

  ProgressCourseSelection toCourseSelection() {
    final roadmapJson = content?['roadmap'] is Map
        ? Map<String, dynamic>.from(content!['roadmap'] as Map)
        : null;
    final courseType = lessonType == 'language'
        ? ProgressCourseType.voice
        : ProgressCourseType.school;

    if (roadmapJson != null) {
      roadmapJson['courseType'] ??= courseType.name;
      roadmapJson['lessonType'] ??= lessonType;
    }

    return ProgressCourseSelection(
      title: title,
      topic: topic,
      roadmapLanguage:
          (content?['roadmapLanguage'] as String?)?.trim().isNotEmpty == true
          ? (content!['roadmapLanguage'] as String).trim()
          : contentType,
      level: ((content?['level'] as String?) ?? difficulty.toLowerCase())
          .toLowerCase(),
      nativeLanguage:
          (content?['nativeLanguage'] as String?)?.trim().isNotEmpty == true
          ? (content!['nativeLanguage'] as String).trim()
          : 'English',
      roadmapJson: roadmapJson,
      courseType: courseType,
    );
  }
}
