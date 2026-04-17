import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class VoiceLessonEntity extends Equatable {
  const VoiceLessonEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.duration,
    required this.accentColor,
    required this.emoji,
    required this.level,
    required this.phrases,
    required this.exercises,
  });

  final String id;
  final String title;
  final String subtitle;
  final String topic;
  final String duration;
  final Color accentColor;
  final String emoji;
  final String level;
  final List<VoicePhrase> phrases;
  final List<VoiceExercise> exercises;

  // ── Serialisation ────────────────────────────────────────────────────────

  factory VoiceLessonEntity.fromJson(Map<String, dynamic> json) =>
      VoiceLessonEntity(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Voice Lesson',
        subtitle: json['subtitle'] as String? ?? '',
        topic: json['topic'] as String? ?? '',
        duration: json['duration'] as String? ?? '15 min',
        accentColor: Color(
          (json['accent_color'] as int?) ?? 0xFFB1A0FF,
        ),
        emoji: json['emoji'] as String? ?? '🎤',
        level: json['level'] as String? ?? 'Beginner',
        phrases: (json['phrases'] as List<dynamic>? ?? [])
            .map((p) => VoicePhrase.fromJson(p as Map<String, dynamic>))
            .toList(),
        exercises: (json['exercises'] as List<dynamic>? ?? [])
            .map((e) => VoiceExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'topic': topic,
        'duration': duration,
        // ignore: deprecated_member_use
        'accent_color': accentColor.value,
        'emoji': emoji,
        'level': level,
        'phrases': phrases.map((p) => p.toJson()).toList(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, title, accentColor, emoji];
}

class VoicePhrase extends Equatable {
  const VoicePhrase({
    required this.id,
    required this.text,
    required this.phonetic,
    required this.translation,
    required this.tip,
  });

  final String id;
  final String text;
  final String phonetic;
  final String translation;
  final String tip;

  factory VoicePhrase.fromJson(Map<String, dynamic> json) => VoicePhrase(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        phonetic: json['phonetic'] as String? ?? '',
        translation: json['translation'] as String? ?? '',
        tip: json['tip'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'phonetic': phonetic,
        'translation': translation,
        'tip': tip,
      };

  @override
  List<Object?> get props => [id, text];
}

class VoiceExercise extends Equatable {
  const VoiceExercise({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;

  factory VoiceExercise.fromJson(Map<String, dynamic> json) => VoiceExercise(
        id: json['id'] as String? ?? '',
        question: json['question'] as String? ?? '',
        options: (json['options'] as List<dynamic>? ?? [])
            .map((o) => o as String)
            .toList(),
        correctIndex: (json['correct_index'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correct_index': correctIndex,
      };

  @override
  List<Object?> get props => [id, question];
}
