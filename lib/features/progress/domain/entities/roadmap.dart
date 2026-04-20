import 'package:equatable/equatable.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';

enum ChapterType {
  lesson,
  checkpoint,
  bossChallenge,
}

enum LessonType {
  vocabulary,
  grammar,
  exercise,
  listening,
  reading,
  conversation,
}

enum LessonStatus {
  locked,
  available,
  inProgress,
  completed,
}

class Roadmap extends Equatable {
  const Roadmap({
    required this.id,
    required this.title,
    required this.description,
    required this.targetLanguage,
    required this.level,
    required this.totalXp,
    required this.estimatedHours,
    required this.chapters,
    this.aiGenerated = false,
    this.voiceProfile,
  });
  final String id;
  final String title;
  final String description;
  final String targetLanguage;
  final String level;
  final int totalXp;
  final int estimatedHours;
  final List<Chapter> chapters;
  final bool aiGenerated;
  final VoiceLessonVoiceProfile? voiceProfile;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        targetLanguage,
        level,
        totalXp,
        estimatedHours,
        chapters,
        aiGenerated,
        voiceProfile,
      ];
}

class Chapter extends Equatable {
  const Chapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.xpReward,
    required this.gemReward,
    required this.prerequisites,
    required this.skills,
    required this.lessons,
    this.pronunciationFocus = '',
    this.audioCues = const [],
    this.speech,
  });
  final String id;
  final int chapterNumber;
  final String title;
  final String description;
  final String icon;
  final ChapterType type;
  final int xpReward;
  final int gemReward;
  final List<String> prerequisites; // Chapter IDs
  final List<String> skills;
  final List<Lesson> lessons;
  final String pronunciationFocus;
  final List<String> audioCues;
  final VoiceSpeechAttributes? speech;

  @override
  List<Object?> get props => [
        id,
        chapterNumber,
        title,
        description,
        icon,
        type,
        xpReward,
        gemReward,
        prerequisites,
        skills,
        lessons,
        pronunciationFocus,
        audioCues,
        speech,
      ];
}

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.xpReward,
    required this.status,
    this.voiceType,
    this.durationMinutes,
    this.audioCues = const [],
    this.speech,
  });
  final String id;
  final String title;
  final LessonType type;
  final String description;
  final int xpReward;
  final LessonStatus status;
  final String? voiceType;
  final int? durationMinutes;
  final List<String> audioCues;
  final VoiceSpeechAttributes? speech;

  Lesson copyWith({LessonStatus? status}) {
    return Lesson(
      id: id,
      title: title,
      type: type,
      description: description,
      xpReward: xpReward,
      status: status ?? this.status,
      voiceType: voiceType,
      durationMinutes: durationMinutes,
      audioCues: audioCues,
      speech: speech,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        description,
        xpReward,
        status,
        voiceType,
        durationMinutes,
        audioCues,
        speech,
      ];
}
