import 'package:equatable/equatable.dart';

class ProgressCourseSelection extends Equatable {
  const ProgressCourseSelection({
    required this.title,
    required this.topic,
    required this.roadmapLanguage,
    required this.level,
    required this.nativeLanguage,
    this.roadmapJson,
    this.roadmapGenerated = false,
  });

  final String title;
  final String topic;
  final String roadmapLanguage;
  final String level;
  final String nativeLanguage;
  final Map<String, dynamic>? roadmapJson;
  final bool roadmapGenerated;

  ProgressCourseSelection copyWith({bool? roadmapGenerated}) {
    return ProgressCourseSelection(
      title: title,
      topic: topic,
      roadmapLanguage: roadmapLanguage,
      level: level,
      nativeLanguage: nativeLanguage,
      roadmapJson: roadmapJson,
      roadmapGenerated: roadmapGenerated ?? this.roadmapGenerated,
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
  ];
}
