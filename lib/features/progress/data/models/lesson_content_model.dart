class LessonContentModel {
  const LessonContentModel({
    required this.id,
    required this.lessonType,
    required this.introduction,
    required this.vocabularyItems,
    required this.practiceExercises,
    required this.summary,
  });

  factory LessonContentModel.fromJson(Map<String, dynamic> json) {
    return LessonContentModel(
      id: json['id'] as String,
      lessonType: json['lessonType'] as String,
      introduction: json['introduction'] as String,
      vocabularyItems: (json['vocabularyItems'] as List<dynamic>?)
              ?.map((e) => VocabularyItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      practiceExercises: (json['practiceExercises'] as List<dynamic>?)
              ?.map((e) => PracticeExerciseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] as String? ?? '',
    );
  }

  final String id;
  final String lessonType;
  final String introduction;
  final List<VocabularyItemModel> vocabularyItems;
  final List<PracticeExerciseModel> practiceExercises;
  final String summary;

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonType': lessonType,
        'introduction': introduction,
        'vocabularyItems': vocabularyItems.map((e) => e.toJson()).toList(),
        'practiceExercises': practiceExercises.map((e) => e.toJson()).toList(),
        'summary': summary,
      };
}

class VocabularyItemModel {
  const VocabularyItemModel({
    required this.word,
    required this.pronunciation,
    required this.translation,
    required this.partOfSpeech,
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.memoryTip,
  });

  factory VocabularyItemModel.fromJson(Map<String, dynamic> json) {
    return VocabularyItemModel(
      word: json['word'] as String,
      pronunciation: json['pronunciation'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
      exampleSentence: json['exampleSentence'] as String? ?? '',
      exampleTranslation: json['exampleTranslation'] as String? ?? '',
      memoryTip: json['memoryTip'] as String? ?? '',
    );
  }

  final String word;
  final String pronunciation;
  final String translation;
  final String partOfSpeech;
  final String exampleSentence;
  final String exampleTranslation;
  final String memoryTip;

  Map<String, dynamic> toJson() => {
        'word': word,
        'pronunciation': pronunciation,
        'translation': translation,
        'partOfSpeech': partOfSpeech,
        'exampleSentence': exampleSentence,
        'exampleTranslation': exampleTranslation,
        'memoryTip': memoryTip,
      };
}

class PracticeExerciseModel {
  const PracticeExerciseModel({
    required this.type,
    required this.instruction,
    required this.items,
  });

  factory PracticeExerciseModel.fromJson(Map<String, dynamic> json) {
    return PracticeExerciseModel(
      type: json['type'] as String,
      instruction: json['instruction'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ExerciseItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final String type;
  final String instruction;
  final List<ExerciseItemModel> items;

  Map<String, dynamic> toJson() => {
        'type': type,
        'instruction': instruction,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class ExerciseItemModel {
  const ExerciseItemModel({required this.question, required this.answer});

  factory ExerciseItemModel.fromJson(Map<String, dynamic> json) {
    return ExerciseItemModel(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  final String question;
  final String answer;

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
}
