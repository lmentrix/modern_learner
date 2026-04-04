import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/features/lesson_detail/data/models/school_lesson_model.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/school_lesson_entity.dart';

part 'school_lesson_event.dart';
part 'school_lesson_state.dart';

class SchoolLessonBloc extends Bloc<SchoolLessonEvent, SchoolLessonState> {
  SchoolLessonBloc() : super(const SchoolLessonState()) {
    on<SchoolLessonLoadRequested>(_onLoadRequested);
    on<SchoolLessonSectionToggled>(_onSectionToggled);
    on<SchoolLessonAnswerSelected>(_onAnswerSelected);
    on<SchoolLessonQuizSubmitted>(_onQuizSubmitted);
  }

  void _onLoadRequested(
    SchoolLessonLoadRequested event,
    Emitter<SchoolLessonState> emit,
  ) {
    emit(state.copyWith(status: SchoolLessonStatus.loading));
    final lesson = SchoolLessonData.findById(event.lessonId);
    if (lesson == null) {
      emit(state.copyWith(status: SchoolLessonStatus.error));
      return;
    }
    // First section expanded by default
    final initialExpanded = lesson.sections.isNotEmpty
        ? {lesson.sections.first.id}
        : <String>{};
    emit(state.copyWith(
      status: SchoolLessonStatus.loaded,
      lesson: lesson,
      expandedSectionIds: initialExpanded,
      selectedAnswers: {},
      quizSubmitted: false,
    ));
  }

  void _onSectionToggled(
    SchoolLessonSectionToggled event,
    Emitter<SchoolLessonState> emit,
  ) {
    final expanded = Set<String>.from(state.expandedSectionIds);
    if (expanded.contains(event.sectionId)) {
      expanded.remove(event.sectionId);
    } else {
      expanded.add(event.sectionId);
    }
    emit(state.copyWith(expandedSectionIds: expanded));
  }

  void _onAnswerSelected(
    SchoolLessonAnswerSelected event,
    Emitter<SchoolLessonState> emit,
  ) {
    if (state.quizSubmitted) return;
    final answers = Map<String, int>.from(state.selectedAnswers)
      ..[event.questionId] = event.answerIndex;
    emit(state.copyWith(selectedAnswers: answers));
  }

  void _onQuizSubmitted(
    SchoolLessonQuizSubmitted event,
    Emitter<SchoolLessonState> emit,
  ) {
    if (state.lesson == null) return;
    int score = 0;
    for (final question in state.lesson!.quiz) {
      final selected = state.selectedAnswers[question.id];
      if (selected == question.correctIndex) score++;
    }
    emit(state.copyWith(quizSubmitted: true, score: score));
  }
}
