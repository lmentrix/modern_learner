/// Vocabulary item model
class VocabularyItem {
  final String word;
  final String pronunciation;
  final String translation;
  final String partOfSpeech;
  final String exampleSentence;
  final String exampleTranslation;
  final String memoryTip;

  const VocabularyItem({
    required this.word,
    required this.pronunciation,
    required this.translation,
    required this.partOfSpeech,
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.memoryTip,
  });
}

/// Practice exercise item
class ExerciseItem {
  final String question;
  final String answer;

  const ExerciseItem({
    required this.question,
    required this.answer,
  });
}

/// Practice exercise model
class PracticeExercise {
  final String type; // 'match', 'fill_blank', 'translate'
  final String instruction;
  final List<ExerciseItem> items;

  const PracticeExercise({
    required this.type,
    required this.instruction,
    required this.items,
  });
}

/// Lesson content model
class LessonContent {
  final String lessonType;
  final String introduction;
  final List<VocabularyItem> vocabularyItems;
  final List<PracticeExercise> practiceExercises;
  final String summary;

  const LessonContent({
    required this.lessonType,
    required this.introduction,
    required this.vocabularyItems,
    required this.practiceExercises,
    required this.summary,
  });
}

/// Lesson section with content
class LessonSectionWithContent {
  final String title;
  final String emoji;
  final String duration;
  final int lessonCount;
  final LessonSectionStatus status;
  final LessonContent? content;

  const LessonSectionWithContent({
    required this.title,
    required this.emoji,
    required this.duration,
    required this.lessonCount,
    required this.status,
    this.content,
  });
}

enum LessonSectionStatus { locked, next, current, completed }
