part of 'voice_lesson_bloc.dart';

enum VoiceLessonStatus { initial, loading, loaded, error }

class VoiceLessonState extends Equatable {
  const VoiceLessonState({
    this.status = VoiceLessonStatus.initial,
    this.lesson,
    this.isPlaying = false,
    this.isAudioLoading = false,
    this.currentPhraseIndex = 0,
    this.activePlaybackId,
    this.audioErrorMessage,
    this.selectedAnswers = const {},
    this.exercisesSubmitted = false,
  });

  final VoiceLessonStatus status;
  final VoiceLessonEntity? lesson;
  final bool isPlaying;
  final bool isAudioLoading;
  final int currentPhraseIndex;
  final String? activePlaybackId;
  final String? audioErrorMessage;
  final Map<String, int> selectedAnswers;
  final bool exercisesSubmitted;

  bool get allExercisesAnswered =>
      lesson != null && selectedAnswers.length == lesson!.exercises.length;

  bool get isFirstPhrase => currentPhraseIndex == 0;
  bool get isLastPhrase =>
      lesson != null && currentPhraseIndex == lesson!.phrases.length - 1;
  bool get hasAudioError =>
      audioErrorMessage != null && audioErrorMessage!.isNotEmpty;
  VoicePhrase? get currentPhrase =>
      lesson == null ? null : lesson!.phrases[currentPhraseIndex];

  @override
  List<Object?> get props => [
    status,
    lesson,
    isPlaying,
    isAudioLoading,
    currentPhraseIndex,
    activePlaybackId,
    audioErrorMessage,
    selectedAnswers,
    exercisesSubmitted,
  ];

  VoiceLessonState copyWith({
    VoiceLessonStatus? status,
    VoiceLessonEntity? lesson,
    bool? isPlaying,
    bool? isAudioLoading,
    int? currentPhraseIndex,
    String? activePlaybackId,
    String? audioErrorMessage,
    bool clearAudioError = false,
    Map<String, int>? selectedAnswers,
    bool? exercisesSubmitted,
  }) {
    return VoiceLessonState(
      status: status ?? this.status,
      lesson: lesson ?? this.lesson,
      isPlaying: isPlaying ?? this.isPlaying,
      isAudioLoading: isAudioLoading ?? this.isAudioLoading,
      currentPhraseIndex: currentPhraseIndex ?? this.currentPhraseIndex,
      activePlaybackId: activePlaybackId ?? this.activePlaybackId,
      audioErrorMessage: clearAudioError
          ? null
          : audioErrorMessage ?? this.audioErrorMessage,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      exercisesSubmitted: exercisesSubmitted ?? this.exercisesSubmitted,
    );
  }
}
