import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';

/// Vocabulary item model
class VocabularyItem {

  const VocabularyItem({
    required this.word,
    required this.pronunciation,
    required this.translation,
    required this.partOfSpeech,
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.memoryTip,
    this.speech,
  });
  final String word;
  final String pronunciation;
  final String translation;
  final String partOfSpeech;
  final String exampleSentence;
  final String exampleTranslation;
  final String memoryTip;
  final VoiceSpeechAttributes? speech;

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      partOfSpeech: json['partOfSpeech'] as String? ?? json['part_of_speech'] as String? ?? '',
      exampleSentence: json['exampleSentence'] as String? ?? json['example_sentence'] as String? ?? '',
      exampleTranslation: json['exampleTranslation'] as String? ?? json['example_translation'] as String? ?? '',
      memoryTip: json['memoryTip'] as String? ?? json['memory_tip'] as String? ?? '',
      speech: json['speech'] != null
          ? VoiceSpeechAttributes.fromJson(json['speech'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'word': word,
    'pronunciation': pronunciation,
    'translation': translation,
    'part_of_speech': partOfSpeech,
    'example_sentence': exampleSentence,
    'example_translation': exampleTranslation,
    'memory_tip': memoryTip,
    if (speech != null) 'speech': speech!.toJson(),
  };
}

/// Practice exercise item
class ExerciseItem {

  const ExerciseItem({
    required this.question,
    required this.answer,
  });
  final String question;
  final String answer;
}

/// Practice exercise model
class PracticeExercise {

  const PracticeExercise({
    required this.type,
    required this.instruction,
    required this.items,
  });
  final String type; // 'match', 'fill_blank', 'translate'
  final String instruction;
  final List<ExerciseItem> items;
}

/// Lesson content model
class LessonContent {

  const LessonContent({
    required this.lessonType,
    required this.introduction,
    required this.vocabularyItems,
    required this.practiceExercises,
    required this.summary,
  });
  final String lessonType;
  final String introduction;
  final List<VocabularyItem> vocabularyItems;
  final List<PracticeExercise> practiceExercises;
  final String summary;
}

/// Lesson section with content
class LessonSectionWithContent {

  const LessonSectionWithContent({
    required this.title,
    required this.emoji,
    required this.duration,
    required this.lessonCount,
    required this.status,
    this.content,
  });
  final String title;
  final String emoji;
  final String duration;
  final int lessonCount;
  final LessonSectionStatus status;
  final LessonContent? content;
}

enum LessonSectionStatus { locked, next, current, completed }
