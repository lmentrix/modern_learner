part of 'school_lesson_bloc.dart';

enum SchoolLessonStatus { initial, loading, loaded, error }

class SchoolLessonState extends Equatable {
  const SchoolLessonState({
    this.status = SchoolLessonStatus.initial,
    this.lesson,
    this.expandedSectionIds = const {},
    this.selectedAnswers = const {},
    this.quizSubmitted = false,
    this.score,
  });

  final SchoolLessonStatus status;
  final SchoolLessonEntity? lesson;
  final Set<String> expandedSectionIds;
  final Map<String, int> selectedAnswers;
  final bool quizSubmitted;
  final int? score;

  bool get allAnswered =>
      lesson != null && selectedAnswers.length == lesson!.quiz.length;

  @override
  List<Object?> get props => [
        status,
        lesson,
        expandedSectionIds,
        selectedAnswers,
        quizSubmitted,
        score,
      ];

  SchoolLessonState copyWith({
    SchoolLessonStatus? status,
    SchoolLessonEntity? lesson,
    Set<String>? expandedSectionIds,
    Map<String, int>? selectedAnswers,
    bool? quizSubmitted,
    int? score,
  }) {
    return SchoolLessonState(
      status: status ?? this.status,
      lesson: lesson ?? this.lesson,
      expandedSectionIds: expandedSectionIds ?? this.expandedSectionIds,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      quizSubmitted: quizSubmitted ?? this.quizSubmitted,
      score: score ?? this.score,
    );
  }
}
