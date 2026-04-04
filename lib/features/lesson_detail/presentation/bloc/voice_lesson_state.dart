part of 'voice_lesson_bloc.dart';

enum VoiceLessonStatus { initial, loading, loaded, error }

class VoiceLessonState extends Equatable {
  const VoiceLessonState({
    this.status = VoiceLessonStatus.initial,
    this.lesson,
    this.isPlaying = false,
    this.currentPhraseIndex = 0,
    this.selectedAnswers = const {},
    this.exercisesSubmitted = false,
  });

  final VoiceLessonStatus status;
  final VoiceLessonEntity? lesson;
  final bool isPlaying;
  final int currentPhraseIndex;
  final Map<String, int> selectedAnswers;
  final bool exercisesSubmitted;

  bool get allExercisesAnswered =>
      lesson != null && selectedAnswers.length == lesson!.exercises.length;

  bool get isFirstPhrase => currentPhraseIndex == 0;
  bool get isLastPhrase =>
      lesson != null && currentPhraseIndex == lesson!.phrases.length - 1;

  @override
  List<Object?> get props => [
        status,
        lesson,
        isPlaying,
        currentPhraseIndex,
        selectedAnswers,
        exercisesSubmitted,
      ];

  VoiceLessonState copyWith({
    VoiceLessonStatus? status,
    VoiceLessonEntity? lesson,
    bool? isPlaying,
    int? currentPhraseIndex,
    Map<String, int>? selectedAnswers,
    bool? exercisesSubmitted,
  }) {
    return VoiceLessonState(
      status: status ?? this.status,
      lesson: lesson ?? this.lesson,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPhraseIndex: currentPhraseIndex ?? this.currentPhraseIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      exercisesSubmitted: exercisesSubmitted ?? this.exercisesSubmitted,
    );
  }
}
