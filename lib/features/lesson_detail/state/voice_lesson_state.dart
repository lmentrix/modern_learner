import 'package:equatable/equatable.dart';

import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';

enum VoiceLessonUiStatus { initial, loading, loaded, error }

class VoiceLessonUiState extends Equatable {
  const VoiceLessonUiState({
    this.status = VoiceLessonUiStatus.initial,
    this.lesson,
    this.currentPhraseIndex = 0,
    this.isPlaying = false,
    this.selectedAnswers = const {},
    this.exercisesSubmitted = false,
    this.showSuccessSnackbar = false,
  });

  final VoiceLessonUiStatus status;
  final VoiceLessonEntity? lesson;
  final int currentPhraseIndex;
  final bool isPlaying;
  final Map<String, int> selectedAnswers;
  final bool exercisesSubmitted;
  final bool showSuccessSnackbar;

  bool get hasLesson => lesson != null;
  
  VoicePhrase? get currentPhrase {
    if (!hasLesson) return null;
    if (currentPhraseIndex >= lesson!.phrases.length) return null;
    return lesson!.phrases[currentPhraseIndex];
  }

  bool get isFirstPhrase => currentPhraseIndex == 0;
  
  bool get isLastPhrase => hasLesson && currentPhraseIndex == lesson!.phrases.length - 1;

  bool get allExercisesAnswered => 
      hasLesson && selectedAnswers.length == lesson!.exercises.length;

  int get correctAnswersCount {
    if (!hasLesson) return 0;
    int count = 0;
    for (final exercise in lesson!.exercises) {
      if (selectedAnswers[exercise.id] == exercise.correctIndex) {
        count++;
      }
    }
    return count;
  }

  double get exercisesProgress => hasLesson && lesson!.exercises.isNotEmpty
      ? selectedAnswers.length / lesson!.exercises.length
      : 0.0;

  @override
  List<Object?> get props => [
        status,
        lesson,
        currentPhraseIndex,
        isPlaying,
        selectedAnswers,
        exercisesSubmitted,
        showSuccessSnackbar,
      ];

  VoiceLessonUiState copyWith({
    VoiceLessonUiStatus? status,
    VoiceLessonEntity? lesson,
    int? currentPhraseIndex,
    bool? isPlaying,
    Map<String, int>? selectedAnswers,
    bool? exercisesSubmitted,
    bool? showSuccessSnackbar,
  }) {
    return VoiceLessonUiState(
      status: status ?? this.status,
      lesson: lesson ?? this.lesson,
      currentPhraseIndex: currentPhraseIndex ?? this.currentPhraseIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      exercisesSubmitted: exercisesSubmitted ?? this.exercisesSubmitted,
      showSuccessSnackbar: showSuccessSnackbar ?? this.showSuccessSnackbar,
    );
  }
}
