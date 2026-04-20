// ignore_for_file: sort_constructors_first

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class VoiceLessonEntity extends Equatable {
  const VoiceLessonEntity({
    required this.id,
    required this.title,
    required this.topic,
    required this.duration,
    required this.accentColor,
    required this.emoji,
    required this.level,
    required this.phrases,
    required this.exercises,
    this.subtitle = '',
    this.description = '',
    this.aiGenerated = false,
    this.voiceProfile = const VoiceLessonVoiceProfile.defaultProfile(),
    this.pronunciationTips = const [],
    this.practicePhrases = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String topic;
  final String duration;
  final Color accentColor;
  final String emoji;
  final String level;
  final bool aiGenerated;
  final VoiceLessonVoiceProfile voiceProfile;
  final List<VoicePhrase> phrases;
  final List<VoiceExercise> exercises;
  final List<VoicePronunciationTip> pronunciationTips;
  final List<String> practicePhrases;

  // ── Serialisation ────────────────────────────────────────────────────────

  factory VoiceLessonEntity.fromJson(
    Map<String, dynamic> json,
  ) => VoiceLessonEntity(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? 'Voice Lesson',
    subtitle: json['subtitle'] as String? ?? '',
    description: json['description'] as String? ?? '',
    topic: json['topic'] as String? ?? '',
    duration: json['duration'] as String? ?? '15 min',
    accentColor: Color(
      (json['accentColor'] as int?) ??
          (json['accent_color'] as int?) ??
          0xFFB1A0FF,
    ),
    emoji: json['emoji'] as String? ?? '🎤',
    level: json['level'] as String? ?? 'Beginner',
    aiGenerated:
        json['aiGenerated'] as bool? ?? json['ai_generated'] as bool? ?? false,
    voiceProfile: VoiceLessonVoiceProfile.fromJson(
      (json['voiceProfile'] as Map<String, dynamic>?) ??
          (json['voice_profile'] as Map<String, dynamic>?) ??
          const <String, dynamic>{},
    ),
    phrases: (json['phrases'] as List<dynamic>? ?? [])
        .map((p) => VoicePhrase.fromJson(p as Map<String, dynamic>))
        .toList(),
    exercises: (json['exercises'] as List<dynamic>? ?? [])
        .map((e) => VoiceExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
    pronunciationTips:
        (json['pronunciationTips'] as List<dynamic>? ??
                json['pronunciation_tips'] as List<dynamic>? ??
                [])
            .map(
              (tip) =>
                  VoicePronunciationTip.fromJson(tip as Map<String, dynamic>),
            )
            .toList(),
    practicePhrases:
        (json['practicePhrases'] as List<dynamic>? ??
                json['practice_phrases'] as List<dynamic>? ??
                [])
            .map((phrase) => phrase as String)
            .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'topic': topic,
    'duration': duration,
    // ignore: deprecated_member_use
    'accent_color': accentColor.value,
    'emoji': emoji,
    'level': level,
    'ai_generated': aiGenerated,
    'voice_profile': voiceProfile.toJson(),
    'phrases': phrases.map((p) => p.toJson()).toList(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'pronunciation_tips': pronunciationTips.map((tip) => tip.toJson()).toList(),
    'practice_phrases': practicePhrases,
  };

  VoiceSpeechAttributes resolvePhraseSpeech(VoicePhrase phrase) {
    return phrase.speech ?? phrase.buildFallbackSpeech(voiceProfile);
  }

  @override
  List<Object?> get props => [
    id,
    title,
    accentColor,
    emoji,
    aiGenerated,
    voiceProfile,
  ];
}

class VoiceLessonVoiceProfile extends Equatable {
  const VoiceLessonVoiceProfile({
    required this.provider,
    required this.disclosure,
    required this.model,
    required this.voice,
    required this.languageType,
    required this.style,
  });

  const VoiceLessonVoiceProfile.defaultProfile()
    : provider = 'qwen',
      disclosure = 'AI-generated voice',
      model = 'qwen3-tts-instruct-flash',
      voice = 'Cherry',
      languageType = 'Auto',
      style = 'Clear, encouraging, and easy to follow for language learners.';

  final String provider;
  final String disclosure;
  final String model;
  final String voice;
  final String languageType;
  final String style;

  factory VoiceLessonVoiceProfile.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return const VoiceLessonVoiceProfile.defaultProfile();
    }

    return VoiceLessonVoiceProfile(
      provider: json['provider'] as String? ?? 'qwen',
      disclosure: json['disclosure'] as String? ?? 'AI-generated voice',
      model: json['model'] as String? ?? 'qwen3-tts-instruct-flash',
      voice: json['voice'] as String? ?? 'Cherry',
      languageType:
          json['languageType'] as String? ??
          json['language_type'] as String? ??
          'Auto',
      style: json['style'] as String? ?? json['instructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'disclosure': disclosure,
    'model': model,
    'voice': voice,
    'language_type': languageType,
    'style': style,
  };

  VoiceSpeechAttributes toSpeech({required String text, String? instructions}) {
    final mergedInstructions = <String>[
      if (style.trim().isNotEmpty) style.trim(),
      if (instructions != null && instructions.trim().isNotEmpty)
        instructions.trim(),
    ].join(' ');

    return VoiceSpeechAttributes(
      provider: provider,
      model: model,
      voice: voice,
      languageType: languageType,
      text: text,
      instructions: mergedInstructions.isEmpty ? null : mergedInstructions,
      optimizeInstructions: mergedInstructions.isNotEmpty,
    );
  }

  @override
  List<Object?> get props => [
    provider,
    disclosure,
    model,
    voice,
    languageType,
    style,
  ];
}

class VoiceSpeechAttributes extends Equatable {
  const VoiceSpeechAttributes({
    required this.provider,
    required this.model,
    required this.voice,
    required this.languageType,
    required this.text,
    this.instructions,
    this.optimizeInstructions,
    this.stream = false,
  });

  final String provider;
  final String model;
  final String voice;
  final String languageType;
  final String text;
  final String? instructions;
  final bool? optimizeInstructions;
  final bool stream;

  factory VoiceSpeechAttributes.fromJson(Map<String, dynamic> json) =>
      VoiceSpeechAttributes(
        provider: json['provider'] as String? ?? 'qwen',
        model: json['model'] as String? ?? 'qwen3-tts-instruct-flash',
        voice: json['voice'] as String? ?? 'Cherry',
        languageType:
            json['languageType'] as String? ??
            json['language_type'] as String? ??
            'Auto',
        text: json['text'] as String? ?? '',
        instructions: json['instructions'] as String?,
        optimizeInstructions:
            json['optimizeInstructions'] as bool? ??
            json['optimize_instructions'] as bool?,
        stream: json['stream'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'model': model,
    'voice': voice,
    'language_type': languageType,
    'text': text,
    if (instructions != null && instructions!.isNotEmpty)
      'instructions': instructions,
    if (optimizeInstructions != null)
      'optimize_instructions': optimizeInstructions,
    'stream': stream,
  };

  Map<String, dynamic> toRequestJson() => {
    'model': model,
    'voice': voice,
    'text': text,
    'language_type': languageType,
    if (instructions != null && instructions!.isNotEmpty)
      'instructions': instructions,
    if (optimizeInstructions != null)
      'optimize_instructions': optimizeInstructions,
    if (stream) 'stream': true,
  };

  @override
  List<Object?> get props => [
    provider,
    model,
    voice,
    languageType,
    text,
    instructions,
    optimizeInstructions,
    stream,
  ];
}

class VoicePhrase extends Equatable {
  const VoicePhrase({
    required this.id,
    required this.text,
    required this.phonetic,
    required this.translation,
    required this.tip,
    this.audioCues = const [],
    this.speech,
  });

  final String id;
  final String text;
  final String phonetic;
  final String translation;
  final String tip;
  final List<String> audioCues;
  final VoiceSpeechAttributes? speech;

  factory VoicePhrase.fromJson(Map<String, dynamic> json) => VoicePhrase(
    id: json['id'] as String? ?? '',
    text: json['text'] as String? ?? '',
    phonetic: json['phonetic'] as String? ?? '',
    translation: json['translation'] as String? ?? '',
    tip: json['tip'] as String? ?? '',
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'phonetic': phonetic,
    'translation': translation,
    'tip': tip,
    'audio_cues': audioCues,
    if (speech != null) 'speech': speech!.toJson(),
  };

  VoiceSpeechAttributes buildFallbackSpeech(
    VoiceLessonVoiceProfile voiceProfile,
  ) {
    final notes = [
      if (tip.isNotEmpty) tip,
      if (audioCues.isNotEmpty) 'Delivery cues: ${audioCues.join(', ')}.',
    ].join(' ');

    return voiceProfile.toSpeech(
      text: text,
      instructions: notes.isEmpty ? null : notes,
    );
  }

  @override
  List<Object?> get props => [id, text, audioCues, speech];
}

class VoiceExercise extends Equatable {
  const VoiceExercise({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.practicePrompt = '',
    this.audioCues = const [],
    this.speech,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String practicePrompt;
  final List<String> audioCues;
  final VoiceSpeechAttributes? speech;

  factory VoiceExercise.fromJson(Map<String, dynamic> json) => VoiceExercise(
    id: json['id'] as String? ?? '',
    question: json['question'] as String? ?? '',
    options: (json['options'] as List<dynamic>? ?? [])
        .map((o) => o as String)
        .toList(),
    correctIndex:
        (json['correctIndex'] as int?) ?? (json['correct_index'] as int?) ?? 0,
    practicePrompt:
        json['practicePrompt'] as String? ??
        json['practice_prompt'] as String? ??
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
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correct_index': correctIndex,
    'practice_prompt': practicePrompt,
    'audio_cues': audioCues,
    if (speech != null) 'speech': speech!.toJson(),
  };

  @override
  List<Object?> get props => [
    id,
    question,
    correctIndex,
    practicePrompt,
    audioCues,
    speech,
  ];
}

class VoicePronunciationTip extends Equatable {
  const VoicePronunciationTip({
    required this.category,
    required this.tip,
    required this.examples,
  });

  final String category;
  final String tip;
  final List<String> examples;

  factory VoicePronunciationTip.fromJson(Map<String, dynamic> json) =>
      VoicePronunciationTip(
        category: json['category'] as String? ?? '',
        tip: json['tip'] as String? ?? '',
        examples: (json['examples'] as List<dynamic>? ?? [])
            .map((example) => example as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'category': category,
    'tip': tip,
    'examples': examples,
  };

  @override
  List<Object?> get props => [category, tip, examples];
}
