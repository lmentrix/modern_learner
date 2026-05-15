enum ExerciseType {
  multipleChoice,
  fillBlank,
  speaking,
  matching,
  trueFalse,
  writing,
}

enum LessonType { voice, school, continueLearning }

class Exercise {
  const Exercise({
    required this.type,
    required this.question,
    this.content,
    this.options,
    this.pairs,
    this.correctAnswer,
    this.hint,
  });

  final ExerciseType type;
  final String question;
  final String? content;
  final List<String>? options;
  final List<Map<String, String>>? pairs;
  final String? correctAnswer;
  final String? hint;
}
