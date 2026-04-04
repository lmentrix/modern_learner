import 'package:equatable/equatable.dart';

import 'package:modern_learner_production/features/lesson_detail/domain/entities/school_lesson_entity.dart';

enum SchoolLessonUiStatus { initial, loading, loaded, error }

class SchoolLessonUiState extends Equatable {
  const SchoolLessonUiState({
    this.status = SchoolLessonUiStatus.initial,
    this.lesson,
    this.expandedSectionIds = const {},
    this.selectedAnswers = const {},
    this.quizSubmitted = false,
    this.score = 0,
    this.showSuccessSnackbar = false,
  });

  final SchoolLessonUiStatus status;
  final SchoolLessonEntity? lesson;
  final Set<String> expandedSectionIds;
  final Map<String, int> selectedAnswers;
  final bool quizSubmitted;
  final int score;
  final bool showSuccessSnackbar;

  bool get hasLesson => lesson != null;
  
  int get totalSections => hasLesson ? lesson!.sections.length : 0;
  
  int get totalQuestions => hasLesson ? lesson!.quiz.length : 0;

  bool get allAnswered => hasLesson && selectedAnswers.length == totalQuestions;

  double get quizProgress => hasLesson && totalQuestions > 0
      ? selectedAnswers.length / totalQuestions
      : 0.0;

  double get scorePercentage => totalQuestions > 0
      ? (score / totalQuestions) * 100
      : 0.0;

  bool isSectionExpanded(String sectionId) => expandedSectionIds.contains(sectionId);

  @override
  List<Object?> get props => [
        status,
        lesson,
        expandedSectionIds,
        selectedAnswers,
        quizSubmitted,
        score,
        showSuccessSnackbar,
      ];

  SchoolLessonUiState copyWith({
    SchoolLessonUiStatus? status,
    SchoolLessonEntity? lesson,
    Set<String>? expandedSectionIds,
    Map<String, int>? selectedAnswers,
    bool? quizSubmitted,
    int? score,
    bool? showSuccessSnackbar,
  }) {
    return SchoolLessonUiState(
      status: status ?? this.status,
      lesson: lesson ?? this.lesson,
      expandedSectionIds: expandedSectionIds ?? this.expandedSectionIds,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      quizSubmitted: quizSubmitted ?? this.quizSubmitted,
      score: score ?? this.score,
      showSuccessSnackbar: showSuccessSnackbar ?? this.showSuccessSnackbar,
    );
  }
}
