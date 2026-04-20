import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';

class LessonModel {
  LessonModel({
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

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    int? asInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.round();
      return null;
    }

    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      xpReward: asInt(json['xpReward']) ?? 0,
      status: json['status'] as String? ?? 'locked',
      voiceType:
          json['voiceType'] as String? ?? json['voice_type'] as String?,
      durationMinutes:
          asInt(json['durationMinutes']) ?? asInt(json['duration_minutes']),
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
    );
  }
  final String id;
  final String title;
  final String type;
  final String description;
  final int xpReward;
  final String status;
  final String? voiceType;
  final int? durationMinutes;
  final List<String> audioCues;
  final VoiceSpeechAttributes? speech;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'xpReward': xpReward,
      'status': status,
      if (voiceType != null) 'voice_type': voiceType,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      'audio_cues': audioCues,
      if (speech != null) 'speech': speech!.toJson(),
    };
  }

  Lesson toEntity() {
    return Lesson(
      id: id,
      title: title,
      type: LessonType.values.firstWhere(
        (t) => t.name == type,
        orElse: () => LessonType.exercise,
      ),
      description: description,
      xpReward: xpReward,
      status: LessonStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => LessonStatus.locked,
      ),
      voiceType: voiceType,
      durationMinutes: durationMinutes,
      audioCues: audioCues,
      speech: speech,
    );
  }

  static LessonModel fromEntity(Lesson lesson) {
    return LessonModel(
      id: lesson.id,
      title: lesson.title,
      type: lesson.type.name,
      description: lesson.description,
      xpReward: lesson.xpReward,
      status: lesson.status.name,
      voiceType: lesson.voiceType,
      durationMinutes: lesson.durationMinutes,
      audioCues: lesson.audioCues,
      speech: lesson.speech,
    );
  }
}
