import 'package:equatable/equatable.dart';

enum ProgressCourseType { voice, school }

ProgressCourseType progressCourseTypeFromString(String? value) {
  switch ((value ?? '').trim().toLowerCase()) {
    case 'voice':
    case 'language':
      return ProgressCourseType.voice;
    default:
      return ProgressCourseType.school;
  }
}

extension ProgressCourseTypePresentation on ProgressCourseType {
  String get badgeLabel =>
      this == ProgressCourseType.voice ? 'VOICE LESSON' : 'SCHOOL LESSON';

  String get sourceLabel =>
      this == ProgressCourseType.voice ? 'Voice lesson' : 'School lesson';

  String get badgeEmoji => this == ProgressCourseType.voice ? '🎙️' : '📘';
}

class ProgressCourseSelection extends Equatable {
  const ProgressCourseSelection({
    required this.title,
    required this.topic,
    required this.roadmapLanguage,
    required this.level,
    required this.nativeLanguage,
    this.roadmapJson,
    this.roadmapGenerated = false,
    this.courseType = ProgressCourseType.school,
  });

  final String title;
  final String topic;
  final String roadmapLanguage;
  final String level;
  final String nativeLanguage;
  final Map<String, dynamic>? roadmapJson;
  final bool roadmapGenerated;
  final ProgressCourseType courseType;

  String get xpKey =>
      [title, topic, level, nativeLanguage, courseType.name].join('::');

  ProgressCourseSelection copyWith({
    Map<String, dynamic>? roadmapJson,
    bool? roadmapGenerated,
    ProgressCourseType? courseType,
  }) {
    return ProgressCourseSelection(
      title: title,
      topic: topic,
      roadmapLanguage: roadmapLanguage,
      level: level,
      nativeLanguage: nativeLanguage,
      roadmapJson: roadmapJson ?? this.roadmapJson,
      roadmapGenerated: roadmapGenerated ?? this.roadmapGenerated,
      courseType: courseType ?? this.courseType,
    );
  }

  @override
  List<Object?> get props => [
    title,
    topic,
    roadmapLanguage,
    level,
    nativeLanguage,
    roadmapJson,
    roadmapGenerated,
    courseType,
  ];
}

String progressCourseXpKey(ProgressCourseSelection course) {
  return [
    course.title,
    course.topic,
    course.level,
    course.nativeLanguage,
    course.courseType.name,
  ].join('::');
}
