class LessonContentModel {
  const LessonContentModel({
    required this.id,
    required this.lessonType,
    required this.introduction,
    required this.title,
    required this.explanation,
    required this.formula,
    required this.vocabularyItems,
    required this.grammarExamples,
    required this.commonMistakes,
    required this.practiceExercises,
    required this.keyPhrases,
    required this.dialogue,
    required this.comprehensionQuestions,
    required this.rolePlaySuggestions,
    required this.preReadingQuestions,
    required this.passage,
    required this.passageTranslation,
    required this.readingVocabulary,
    required this.discussionQuestions,
    required this.preListeningQuestions,
    required this.script,
    required this.scriptTranslation,
    required this.listeningVocabulary,
    required this.generatedQuestions,
    required this.instruction,
    required this.reviewKeyPoints,
    required this.reviewExamples,
    required this.summary,
  });

  factory LessonContentModel.fromJson(Map<String, dynamic> json) {
    final lessonType = json['lessonType'] as String? ?? '';
    final introduction =
        (json['introduction'] as String?) ??
        (json['scenario'] as String?) ??
        (json['instruction'] as String?) ??
        '';

    final practiceExercisesJson =
        (json['practiceExercises'] as List<dynamic>?) ?? const [];
    final comprehensionQuestionsJson =
        (json['comprehensionQuestions'] as List<dynamic>?) ?? const [];
    final generatedQuestionsJson =
        (json['questions'] as List<dynamic>?) ??
        (json['exercises'] as List<dynamic>?) ??
        const [];
    final reviewContent = json['reviewContent'] as Map<String, dynamic>?;

    return LessonContentModel(
      id: json['id'] as String,
      lessonType: lessonType,
      introduction: introduction,
      title: json['title'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      formula: json['formula'] as String? ?? '',
      vocabularyItems:
          (json['vocabularyItems'] as List<dynamic>?)
              ?.map(
                (e) => VocabularyItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      grammarExamples:
          (json['examples'] as List<dynamic>?)
              ?.map(
                (e) => GrammarExampleModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      commonMistakes:
          (json['commonMistakes'] as List<dynamic>?)
              ?.map(
                (e) => CommonMistakeModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      practiceExercises:
          (json['practiceExercises'] as List<dynamic>?)
              ?.map(
                (e) =>
                    PracticeExerciseModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      keyPhrases:
          (json['keyPhrases'] as List<dynamic>?)
              ?.map((e) => KeyPhraseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dialogue:
          (json['dialogue'] as List<dynamic>?)
              ?.map(
                (e) => DialogueLineModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      comprehensionQuestions: [
        ...practiceExercisesJson
            .map((e) => e as Map<String, dynamic>)
            .expand(
              (exercise) =>
                  ((exercise['questions'] as List<dynamic>?) ?? const []).map(
                    (question) => QuestionAnswerModel.fromJson(
                      question as Map<String, dynamic>,
                    ),
                  ),
            ),
        ...comprehensionQuestionsJson.map(
          (e) => QuestionAnswerModel.fromJson(e as Map<String, dynamic>),
        ),
      ],
      rolePlaySuggestions:
          (json['rolePlaySuggestions'] as List<dynamic>?)?.cast<String>() ?? [],
      preReadingQuestions:
          (json['preReadingQuestions'] as List<dynamic>?)?.cast<String>() ?? [],
      passage: json['passage'] as String? ?? '',
      passageTranslation: json['passageTranslation'] as String? ?? '',
      readingVocabulary:
          (json['vocabulary'] as List<dynamic>?)
              ?.map(
                (e) => ContextVocabularyItemModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      discussionQuestions:
          (json['discussionQuestions'] as List<dynamic>?)?.cast<String>() ?? [],
      preListeningQuestions:
          (json['preListeningQuestions'] as List<dynamic>?)?.cast<String>() ??
          [],
      script: json['script'] as String? ?? '',
      scriptTranslation: json['scriptTranslation'] as String? ?? '',
      listeningVocabulary:
          (json['vocabulary'] as List<dynamic>?)
              ?.map(
                (e) => ListeningVocabularyItemModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      generatedQuestions: generatedQuestionsJson
          .map(
            (e) => GeneratedQuestionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      instruction: json['instruction'] as String? ?? '',
      reviewKeyPoints:
          (reviewContent?['keyPoints'] as List<dynamic>?)?.cast<String>() ?? [],
      reviewExamples:
          (reviewContent?['examples'] as List<dynamic>?)
              ?.map(
                (e) => ReviewExampleModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      summary: json['summary'] as String? ?? '',
    );
  }

  final String id;
  final String lessonType;
  final String introduction;
  final String title;
  final String explanation;
  final String formula;
  final List<VocabularyItemModel> vocabularyItems;
  final List<GrammarExampleModel> grammarExamples;
  final List<CommonMistakeModel> commonMistakes;
  final List<PracticeExerciseModel> practiceExercises;
  final List<KeyPhraseModel> keyPhrases;
  final List<DialogueLineModel> dialogue;
  final List<QuestionAnswerModel> comprehensionQuestions;
  final List<String> rolePlaySuggestions;
  final List<String> preReadingQuestions;
  final String passage;
  final String passageTranslation;
  final List<ContextVocabularyItemModel> readingVocabulary;
  final List<String> discussionQuestions;
  final List<String> preListeningQuestions;
  final String script;
  final String scriptTranslation;
  final List<ListeningVocabularyItemModel> listeningVocabulary;
  final List<GeneratedQuestionModel> generatedQuestions;
  final String instruction;
  final List<String> reviewKeyPoints;
  final List<ReviewExampleModel> reviewExamples;
  final String summary;

  Map<String, dynamic> toJson() => {
    'id': id,
    'lessonType': lessonType,
    'introduction': introduction,
    'title': title,
    'explanation': explanation,
    'formula': formula,
    'vocabularyItems': vocabularyItems.map((e) => e.toJson()).toList(),
    'examples': grammarExamples.map((e) => e.toJson()).toList(),
    'commonMistakes': commonMistakes.map((e) => e.toJson()).toList(),
    'practiceExercises': practiceExercises.map((e) => e.toJson()).toList(),
    'keyPhrases': keyPhrases.map((e) => e.toJson()).toList(),
    'dialogue': dialogue.map((e) => e.toJson()).toList(),
    'comprehensionQuestions': comprehensionQuestions
        .map((e) => e.toJson())
        .toList(),
    'rolePlaySuggestions': rolePlaySuggestions,
    'preReadingQuestions': preReadingQuestions,
    'passage': passage,
    'passageTranslation': passageTranslation,
    'readingVocabulary': readingVocabulary.map((e) => e.toJson()).toList(),
    'discussionQuestions': discussionQuestions,
    'preListeningQuestions': preListeningQuestions,
    'script': script,
    'scriptTranslation': scriptTranslation,
    'listeningVocabulary': listeningVocabulary.map((e) => e.toJson()).toList(),
    'generatedQuestions': generatedQuestions.map((e) => e.toJson()).toList(),
    'instruction': instruction,
    'reviewKeyPoints': reviewKeyPoints,
    'reviewExamples': reviewExamples.map((e) => e.toJson()).toList(),
    'summary': summary,
  };
}

class GrammarExampleModel {
  const GrammarExampleModel({
    required this.sentence,
    required this.translation,
    required this.breakdown,
  });

  factory GrammarExampleModel.fromJson(Map<String, dynamic> json) {
    return GrammarExampleModel(
      sentence: json['sentence'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      breakdown: json['breakdown'] as String? ?? '',
    );
  }

  final String sentence;
  final String translation;
  final String breakdown;

  Map<String, dynamic> toJson() => {
    'sentence': sentence,
    'translation': translation,
    'breakdown': breakdown,
  };
}

class CommonMistakeModel {
  const CommonMistakeModel({
    required this.incorrect,
    required this.correct,
    required this.explanation,
  });

  factory CommonMistakeModel.fromJson(Map<String, dynamic> json) {
    return CommonMistakeModel(
      incorrect: json['incorrect'] as String? ?? '',
      correct: json['correct'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }

  final String incorrect;
  final String correct;
  final String explanation;

  Map<String, dynamic> toJson() => {
    'incorrect': incorrect,
    'correct': correct,
    'explanation': explanation,
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
    final items =
        (json['items'] as List<dynamic>?)
            ?.map((e) => ExerciseItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        ((json['questions'] as List<dynamic>?) ?? const [])
            .map(
              (e) => ExerciseItemModel.fromJson(
                e as Map<String, dynamic>,
                answerKey: 'answer',
              ),
            )
            .toList();

    return PracticeExerciseModel(
      type:
          json['type'] as String? ??
          (json.containsKey('questions') ? 'select_correct' : ''),
      instruction: json['instruction'] as String? ?? '',
      items: items,
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

  factory ExerciseItemModel.fromJson(
    Map<String, dynamic> json, {
    String answerKey = 'answer',
  }) {
    return ExerciseItemModel(
      question: json['question'] as String? ?? '',
      answer: json[answerKey]?.toString() ?? '',
    );
  }

  final String question;
  final String answer;

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
}

class KeyPhraseModel {
  const KeyPhraseModel({
    required this.phrase,
    required this.translation,
    required this.usage,
  });

  factory KeyPhraseModel.fromJson(Map<String, dynamic> json) {
    return KeyPhraseModel(
      phrase: json['phrase'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      usage: json['usage'] as String? ?? '',
    );
  }

  final String phrase;
  final String translation;
  final String usage;

  Map<String, dynamic> toJson() => {
    'phrase': phrase,
    'translation': translation,
    'usage': usage,
  };
}

class DialogueLineModel {
  const DialogueLineModel({
    required this.speaker,
    required this.line,
    required this.translation,
    required this.notes,
  });

  factory DialogueLineModel.fromJson(Map<String, dynamic> json) {
    return DialogueLineModel(
      speaker: json['speaker'] as String? ?? '',
      line: json['line'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  final String speaker;
  final String line;
  final String translation;
  final String notes;

  Map<String, dynamic> toJson() => {
    'speaker': speaker,
    'line': line,
    'translation': translation,
    'notes': notes,
  };
}

class QuestionAnswerModel {
  const QuestionAnswerModel({
    required this.question,
    required this.answer,
    required this.explanation,
    required this.type,
  });

  factory QuestionAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuestionAnswerModel(
      question: json['question'] as String? ?? '',
      answer: (json['answer'] ?? json['correctAnswer'])?.toString() ?? '',
      explanation: json['explanation'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }

  final String question;
  final String answer;
  final String explanation;
  final String type;

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    'explanation': explanation,
    'type': type,
  };
}

class ContextVocabularyItemModel {
  const ContextVocabularyItemModel({
    required this.word,
    required this.pronunciation,
    required this.translation,
    required this.context,
  });

  factory ContextVocabularyItemModel.fromJson(Map<String, dynamic> json) {
    return ContextVocabularyItemModel(
      word: json['word'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      context: json['context'] as String? ?? '',
    );
  }

  final String word;
  final String pronunciation;
  final String translation;
  final String context;

  Map<String, dynamic> toJson() => {
    'word': word,
    'pronunciation': pronunciation,
    'translation': translation,
    'context': context,
  };
}

class ListeningVocabularyItemModel {
  const ListeningVocabularyItemModel({
    required this.word,
    required this.translation,
  });

  factory ListeningVocabularyItemModel.fromJson(Map<String, dynamic> json) {
    return ListeningVocabularyItemModel(
      word: json['word'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
    );
  }

  final String word;
  final String translation;

  Map<String, dynamic> toJson() => {'word': word, 'translation': translation};
}

class GeneratedQuestionModel {
  const GeneratedQuestionModel({
    required this.question,
    required this.answer,
    required this.explanation,
    required this.type,
    required this.options,
    required this.difficulty,
  });

  factory GeneratedQuestionModel.fromJson(Map<String, dynamic> json) {
    return GeneratedQuestionModel(
      question: json['question'] as String? ?? '',
      answer: (json['answer'] ?? json['correctAnswer'])?.toString() ?? '',
      explanation: json['explanation'] as String? ?? '',
      type: json['type'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.cast<String>() ?? const [],
      difficulty: json['difficulty'] as String? ?? '',
    );
  }

  final String question;
  final String answer;
  final String explanation;
  final String type;
  final List<String> options;
  final String difficulty;

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    'explanation': explanation,
    'type': type,
    'options': options,
    'difficulty': difficulty,
  };
}

class ReviewExampleModel {
  const ReviewExampleModel({required this.example, required this.explanation});

  factory ReviewExampleModel.fromJson(Map<String, dynamic> json) {
    return ReviewExampleModel(
      example: json['example'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }

  final String example;
  final String explanation;

  Map<String, dynamic> toJson() => {
    'example': example,
    'explanation': explanation,
  };
}
