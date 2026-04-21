part of 'voice_lesson_bloc.dart';

sealed class VoiceLessonEvent extends Equatable {
  const VoiceLessonEvent();

  @override
  List<Object?> get props => [];
}

final class VoiceLessonLoadRequested extends VoiceLessonEvent {
  const VoiceLessonLoadRequested(this.lessonId);
  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

final class VoiceLessonPreloadAudioRequested extends VoiceLessonEvent {
  const VoiceLessonPreloadAudioRequested();
}

final class VoiceLessonPlayToggled extends VoiceLessonEvent {
  const VoiceLessonPlayToggled();
}

final class VoiceLessonNextPhrase extends VoiceLessonEvent {
  const VoiceLessonNextPhrase();
}

final class VoiceLessonPreviousPhrase extends VoiceLessonEvent {
  const VoiceLessonPreviousPhrase();
}

final class VoiceLessonPhraseSelected extends VoiceLessonEvent {
  const VoiceLessonPhraseSelected(this.index);
  final int index;

  @override
  List<Object?> get props => [index];
}

final class VoiceLessonPlaybackStateChanged extends VoiceLessonEvent {
  const VoiceLessonPlaybackStateChanged(this.audioState);

  final VoiceLessonAudioState audioState;

  @override
  List<Object?> get props => [
    audioState.activeId,
    audioState.isLoading,
    audioState.isPlaying,
    audioState.errorMessage,
  ];
}

final class VoiceLessonAnswerSelected extends VoiceLessonEvent {
  const VoiceLessonAnswerSelected(this.exerciseId, this.answerIndex);
  final String exerciseId;
  final int answerIndex;

  @override
  List<Object?> get props => [exerciseId, answerIndex];
}

final class VoiceLessonExercisesSubmitted extends VoiceLessonEvent {
  const VoiceLessonExercisesSubmitted();
}
