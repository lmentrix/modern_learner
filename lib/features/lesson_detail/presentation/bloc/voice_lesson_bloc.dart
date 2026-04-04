import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/features/lesson_detail/data/models/voice_lesson_model.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';

part 'voice_lesson_event.dart';
part 'voice_lesson_state.dart';

class VoiceLessonBloc extends Bloc<VoiceLessonEvent, VoiceLessonState> {
  VoiceLessonBloc() : super(const VoiceLessonState()) {
    on<VoiceLessonLoadRequested>(_onLoadRequested);
    on<VoiceLessonPlayToggled>(_onPlayToggled);
    on<VoiceLessonNextPhrase>(_onNextPhrase);
    on<VoiceLessonPreviousPhrase>(_onPreviousPhrase);
    on<VoiceLessonPhraseSelected>(_onPhraseSelected);
    on<VoiceLessonAnswerSelected>(_onAnswerSelected);
    on<VoiceLessonExercisesSubmitted>(_onExercisesSubmitted);
  }

  void _onLoadRequested(
    VoiceLessonLoadRequested event,
    Emitter<VoiceLessonState> emit,
  ) {
    emit(state.copyWith(status: VoiceLessonStatus.loading));
    final lesson = VoiceLessonData.findById(event.lessonId);
    if (lesson == null) {
      emit(state.copyWith(status: VoiceLessonStatus.error));
      return;
    }
    emit(state.copyWith(
      status: VoiceLessonStatus.loaded,
      lesson: lesson,
      currentPhraseIndex: 0,
      isPlaying: false,
      selectedAnswers: {},
      exercisesSubmitted: false,
    ));
  }

  void _onPlayToggled(
    VoiceLessonPlayToggled event,
    Emitter<VoiceLessonState> emit,
  ) {
    emit(state.copyWith(isPlaying: !state.isPlaying));
  }

  void _onNextPhrase(
    VoiceLessonNextPhrase event,
    Emitter<VoiceLessonState> emit,
  ) {
    if (state.lesson == null) return;
    final next = state.currentPhraseIndex + 1;
    if (next < state.lesson!.phrases.length) {
      emit(state.copyWith(currentPhraseIndex: next, isPlaying: false));
    }
  }

  void _onPreviousPhrase(
    VoiceLessonPreviousPhrase event,
    Emitter<VoiceLessonState> emit,
  ) {
    final prev = state.currentPhraseIndex - 1;
    if (prev >= 0) {
      emit(state.copyWith(currentPhraseIndex: prev, isPlaying: false));
    }
  }

  void _onPhraseSelected(
    VoiceLessonPhraseSelected event,
    Emitter<VoiceLessonState> emit,
  ) {
    emit(state.copyWith(currentPhraseIndex: event.index, isPlaying: false));
  }

  void _onAnswerSelected(
    VoiceLessonAnswerSelected event,
    Emitter<VoiceLessonState> emit,
  ) {
    if (state.exercisesSubmitted) return;
    final answers = Map<String, int>.from(state.selectedAnswers)
      ..[event.exerciseId] = event.answerIndex;
    emit(state.copyWith(selectedAnswers: answers));
  }

  void _onExercisesSubmitted(
    VoiceLessonExercisesSubmitted event,
    Emitter<VoiceLessonState> emit,
  ) {
    emit(state.copyWith(exercisesSubmitted: true));
  }
}
