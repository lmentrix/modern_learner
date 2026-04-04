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

  @override
  List<Object?> get props => [id, question];
}
