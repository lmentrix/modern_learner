part of 'school_lesson_bloc.dart';

sealed class SchoolLessonEvent extends Equatable {
  const SchoolLessonEvent();

  @override
  List<Object?> get props => [];
}

final class SchoolLessonLoadRequested extends SchoolLessonEvent {
  const SchoolLessonLoadRequested(this.lessonId);
  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

final class SchoolLessonSectionToggled extends SchoolLessonEvent {
  const SchoolLessonSectionToggled(this.sectionId);
  final String sectionId;

  @override
  List<Object?> get props => [sectionId];
}

final class SchoolLessonAnswerSelected extends SchoolLessonEvent {
  const SchoolLessonAnswerSelected(this.questionId, this.answerIndex);
  final String questionId;
  final int answerIndex;

  @override
  List<Object?> get props => [questionId, answerIndex];
}

final class SchoolLessonQuizSubmitted extends SchoolLessonEvent {
  const SchoolLessonQuizSubmitted();
}
