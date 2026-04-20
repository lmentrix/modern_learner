import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_model.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';

class RoadmapModel {
  RoadmapModel({
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

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    int asInt(Object? value, {required String field}) {
      if (value is int) return value;
      if (value is num) return value.round();
      throw FormatException('Invalid "$field" value: $value');
    }

    return RoadmapModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetLanguage: json['targetLanguage'] as String,
      level: json['level'] as String,
      totalXp: asInt(json['totalXp'], field: 'totalXp'),
      estimatedHours: asInt(json['estimatedHours'], field: 'estimatedHours'),
      aiGenerated:
          json['aiGenerated'] as bool? ?? json['ai_generated'] as bool? ?? false,
      voiceProfile: ((json['voiceProfile'] as Map<String, dynamic>?) ??
                  (json['voice_profile'] as Map<String, dynamic>?) ??
                  const <String, dynamic>{})
              .isEmpty
          ? null
          : VoiceLessonVoiceProfile.fromJson(
              (json['voiceProfile'] as Map<String, dynamic>?) ??
                  (json['voice_profile'] as Map<String, dynamic>?) ??
                  const <String, dynamic>{},
            ),
      chapters: (json['chapters'] as List<dynamic>)
          .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
  final String id;
  final String title;
  final String description;
  final String targetLanguage;
  final String level;
  final int totalXp;
  final int estimatedHours;
  final List<ChapterModel> chapters;
  final bool aiGenerated;
  final VoiceLessonVoiceProfile? voiceProfile;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetLanguage': targetLanguage,
      'level': level,
      'totalXp': totalXp,
      'estimatedHours': estimatedHours,
      'ai_generated': aiGenerated,
      if (voiceProfile != null) 'voice_profile': voiceProfile!.toJson(),
      'chapters': chapters.map((c) => c.toJson()).toList(),
    };
  }

  Roadmap toEntity() {
    return Roadmap(
      id: id,
      title: title,
      description: description,
      targetLanguage: targetLanguage,
      level: level,
      totalXp: totalXp,
      estimatedHours: estimatedHours,
      chapters: chapters.map((c) => c.toEntity()).toList(),
      aiGenerated: aiGenerated,
      voiceProfile: voiceProfile,
    );
  }

  static RoadmapModel fromEntity(Roadmap roadmap) {
    return RoadmapModel(
      id: roadmap.id,
      title: roadmap.title,
      description: roadmap.description,
      targetLanguage: roadmap.targetLanguage,
      level: roadmap.level,
      totalXp: roadmap.totalXp,
      estimatedHours: roadmap.estimatedHours,
      chapters: roadmap.chapters
          .map((c) => ChapterModel.fromEntity(c))
          .toList(),
      aiGenerated: roadmap.aiGenerated,
      voiceProfile: roadmap.voiceProfile,
    );
  }
}

class ChapterModel {
  ChapterModel({
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

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as String,
      chapterNumber: json['chapterNumber'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: json['type'] as String,
      xpReward: json['xpReward'] as int,
      gemReward: json['gemReward'] as int,
      prerequisites:
          (json['prerequisites'] as List<dynamic>?)?.cast<String>() ?? [],
      skills:
          (json['skills'] as List<dynamic>?)?.cast<String>() ??
          (json['focusSkills'] as List<dynamic>?)?.cast<String>() ??
          [],
      pronunciationFocus:
          json['pronunciationFocus'] as String? ??
          json['pronunciation_focus'] as String? ??
          '',
      audioCues:
          (json['audioCues'] as List<dynamic>? ??
                  json['audio_cues'] as List<dynamic>? ??
                  [])
              .map((cue) => cue as String)
              .toList(),
      speech: ((json['speech'] as Map<String, dynamic>?) ?? const {}).isEmpty
          ? null
          : VoiceSpeechAttributes.fromJson(
              json['speech'] as Map<String, dynamic>,
            ),
      lessons:
          (json['lessons'] as List<dynamic>?)
              ?.map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  final String id;
  final int chapterNumber;
  final String title;
  final String description;
  final String icon;
  final String type;
  final int xpReward;
  final int gemReward;
  final List<String> prerequisites;
  final List<String> skills;
  final List<LessonModel> lessons;
  final String pronunciationFocus;
  final List<String> audioCues;
  final VoiceSpeechAttributes? speech;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapterNumber': chapterNumber,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type,
      'xpReward': xpReward,
      'gemReward': gemReward,
      'prerequisites': prerequisites,
      'skills': skills,
      if (pronunciationFocus.isNotEmpty)
        'pronunciation_focus': pronunciationFocus,
      'audio_cues': audioCues,
      if (speech != null) 'speech': speech!.toJson(),
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }

  Chapter toEntity() {
    return Chapter(
      id: id,
      chapterNumber: chapterNumber,
      title: title,
      description: description,
      icon: icon,
      type: _parseChapterType(type),
      xpReward: xpReward,
      gemReward: gemReward,
      prerequisites: prerequisites,
      skills: skills,
      lessons: lessons.map((l) => l.toEntity()).toList(),
      pronunciationFocus: pronunciationFocus,
      audioCues: audioCues,
      speech: speech,
    );
  }

  static ChapterType _parseChapterType(String type) {
    switch (type) {
      case 'checkpoint':
        return ChapterType.checkpoint;
      case 'boss_challenge':
      case 'bossChallenge':
        return ChapterType.bossChallenge;
      default:
        return ChapterType.lesson;
    }
  }

  static ChapterModel fromEntity(Chapter chapter) {
    return ChapterModel(
      id: chapter.id,
      chapterNumber: chapter.chapterNumber,
      title: chapter.title,
      description: chapter.description,
      icon: chapter.icon,
      type: chapter.type.name,
      xpReward: chapter.xpReward,
      gemReward: chapter.gemReward,
      prerequisites: chapter.prerequisites,
      skills: chapter.skills,
      lessons: chapter.lessons.map((l) => LessonModel.fromEntity(l)).toList(),
      pronunciationFocus: chapter.pronunciationFocus,
      audioCues: chapter.audioCues,
      speech: chapter.speech,
    );
  }
}
