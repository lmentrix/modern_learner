import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/features/lesson_detail/data/models/voice_lesson_model.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';
import 'package:modern_learner_production/features/lesson_detail/service/voice_lesson_supabase_service.dart';
import 'package:modern_learner_production/features/lesson_detail/service/voice_lesson_tts_service.dart';

part 'voice_lesson_event.dart';
part 'voice_lesson_state.dart';

class VoiceLessonBloc extends Bloc<VoiceLessonEvent, VoiceLessonState> {
  VoiceLessonBloc({
    VoiceLessonSupabaseService? supabaseService,
    VoiceLessonTtsService? ttsService,
  }) : _supabaseService = supabaseService,
       _ttsService = ttsService,
       super(const VoiceLessonState()) {
    on<VoiceLessonLoadRequested>(_onLoadRequested);
    on<VoiceLessonPlayToggled>(_onPlayToggled);
    on<VoiceLessonNextPhrase>(_onNextPhrase);
    on<VoiceLessonPreviousPhrase>(_onPreviousPhrase);
    on<VoiceLessonPhraseSelected>(_onPhraseSelected);
    on<VoiceLessonPlaybackStateChanged>(_onPlaybackStateChanged);
    on<VoiceLessonAnswerSelected>(_onAnswerSelected);
    on<VoiceLessonExercisesSubmitted>(_onExercisesSubmitted);
    on<VoiceLessonPreloadAudioRequested>(_onPreloadAudioRequested);

    _audioSubscription = _ttsService?.stateStream.listen((audioState) {
      add(VoiceLessonPlaybackStateChanged(audioState));
    });
  }

  final VoiceLessonSupabaseService? _supabaseService;
  final VoiceLessonTtsService? _ttsService;
  StreamSubscription<VoiceLessonAudioState>? _audioSubscription;

  /// Pre-loaded audio cache for the current lesson.
  Map<String, Uint8List>? _preloadedAudio;

  Future<void> _onLoadRequested(
    VoiceLessonLoadRequested event,
    Emitter<VoiceLessonState> emit,
  ) async {
    await _ttsService?.stop();
    _preloadedAudio = null;
    emit(state.copyWith(status: VoiceLessonStatus.loading));

    // 1. Try loading from Supabase (user-created lessons have UUID ids).
    final supabaseService = _supabaseService;
    if (supabaseService != null) {
      try {
        final lesson = await supabaseService.fetchByLessonId(event.lessonId);
        if (lesson != null) {
          emit(
            state.copyWith(
              status: VoiceLessonStatus.loaded,
              lesson: lesson,
              currentPhraseIndex: 0,
              isPlaying: false,
              isAudioLoading: false,
              activePlaybackId: null,
              clearAudioError: true,
              selectedAnswers: {},
              exercisesSubmitted: false,
            ),
          );
          return;
        }
      } catch (_) {}
    }

    // 2. Fall back to bundled static data (legacy / demo lessons).
    final lesson = VoiceLessonData.findById(event.lessonId);
    if (lesson == null) {
      emit(state.copyWith(status: VoiceLessonStatus.error));
      return;
    }
    emit(
      state.copyWith(
        status: VoiceLessonStatus.loaded,
        lesson: lesson,
        currentPhraseIndex: 0,
        isPlaying: false,
        isAudioLoading: false,
        activePlaybackId: null,
        clearAudioError: true,
        selectedAnswers: {},
        exercisesSubmitted: false,
      ),
    );
  }

  /// Pre-load all audio for the current lesson.
  /// This generates audio for all phrases and exercises using Qwen TTS.
  Future<void> _onPreloadAudioRequested(
    VoiceLessonPreloadAudioRequested event,
    Emitter<VoiceLessonState> emit,
  ) async {
    final lesson = state.lesson;
    final ttsService = _ttsService;
    if (lesson == null || ttsService == null) return;

    emit(state.copyWith(isAudioLoading: true, clearAudioError: true));

    try {
      _preloadedAudio = await ttsService.preloadLessonAudio(
        phrases: lesson.phrases,
        exercises: lesson.exercises,
        narratorTts: lesson.narratorTts.introText.isNotEmpty
            ? lesson.narratorTts
            : null,
        model: lesson.voiceProfile.model,
      );

      emit(
        state.copyWith(
          isAudioLoading: false,
          preloadedAudioCount: _preloadedAudio?.length ?? 0,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isAudioLoading: false,
          audioErrorMessage: 'Failed to preload audio. Using on-demand generation.',
        ),
      );
    }
  }

  Future<void> _onPlayToggled(
    VoiceLessonPlayToggled event,
    Emitter<VoiceLessonState> emit,
  ) async {
    final lesson = state.lesson;
    if (lesson == null) return;
    final ttsService = _ttsService;
    if (ttsService == null) {
      emit(
        state.copyWith(
          audioErrorMessage: 'Voice playback is unavailable right now.',
        ),
      );
      return;
    }

    final phrase = lesson.phrases[state.currentPhraseIndex];
    final playbackId = phrase.id.isEmpty
        ? 'phrase_${state.currentPhraseIndex + 1}'
        : phrase.id;

    // Try to use pre-loaded audio first
    if (_preloadedAudio != null && _preloadedAudio!.containsKey(phrase.id)) {
      await ttsService.playPreloadedAudio(
        playbackId: playbackId,
        audioBytes: _preloadedAudio![phrase.id]!,
      );
      return;
    }

    // Fall back to on-demand TTS
    final speech = lesson.resolvePhraseSpeech(phrase);
    await ttsService.togglePhrase(
      playbackId: playbackId,
      speech: speech,
    );
  }

  /// Play audio for a specific exercise (for practice prompts).
  Future<void> playExerciseAudio(String exerciseId) async {
    final lesson = state.lesson;
    if (lesson == null) return;
    final ttsService = _ttsService;
    if (ttsService == null) return;

    final exercise = lesson.exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => const VoiceExercise(
        id: '',
        question: '',
        options: [],
        correctIndex: 0,
      ),
    );

    if (exercise.id.isEmpty) return;

    // Try to use pre-loaded audio first
    if (_preloadedAudio != null && _preloadedAudio!.containsKey(exercise.id)) {
      await ttsService.playPreloadedAudio(
        playbackId: exercise.id,
        audioBytes: _preloadedAudio![exercise.id]!,
      );
      return;
    }

    // Fall back to on-demand TTS
    final tts = exercise.getTtsOrBuildFallback(lesson.voiceProfile);
    await ttsService.playPhrase(
      playbackId: exercise.id,
      speech: VoiceSpeechAttributes(
        provider: 'qwen',
        model: lesson.voiceProfile.model,
        voice: tts.voice,
        languageType: tts.languageType,
        text: tts.text,
        instructions: tts.instructions,
        optimizeInstructions: tts.optimizeInstructions,
      ),
    );
  }

  Future<void> _onNextPhrase(
    VoiceLessonNextPhrase event,
    Emitter<VoiceLessonState> emit,
  ) async {
    if (state.lesson == null) return;
    final next = state.currentPhraseIndex + 1;
    if (next < state.lesson!.phrases.length) {
      await _ttsService?.stop();
      emit(
        state.copyWith(
          currentPhraseIndex: next,
          isPlaying: false,
          isAudioLoading: false,
          activePlaybackId: null,
          clearAudioError: true,
        ),
      );
    }
  }

  Future<void> _onPreviousPhrase(
    VoiceLessonPreviousPhrase event,
    Emitter<VoiceLessonState> emit,
  ) async {
    final prev = state.currentPhraseIndex - 1;
    if (prev >= 0) {
      await _ttsService?.stop();
      emit(
        state.copyWith(
          currentPhraseIndex: prev,
          isPlaying: false,
          isAudioLoading: false,
          activePlaybackId: null,
          clearAudioError: true,
        ),
      );
    }
  }

  Future<void> _onPhraseSelected(
    VoiceLessonPhraseSelected event,
    Emitter<VoiceLessonState> emit,
  ) async {
    await _ttsService?.stop();
    emit(
      state.copyWith(
        currentPhraseIndex: event.index,
        isPlaying: false,
        isAudioLoading: false,
        activePlaybackId: null,
        clearAudioError: true,
      ),
    );
  }

  void _onPlaybackStateChanged(
    VoiceLessonPlaybackStateChanged event,
    Emitter<VoiceLessonState> emit,
  ) {
    emit(
      state.copyWith(
        activePlaybackId: event.audioState.activeId,
        isPlaying: event.audioState.isPlaying,
        isAudioLoading: event.audioState.isLoading,
        audioErrorMessage: event.audioState.errorMessage,
        clearAudioError: event.audioState.errorMessage == null,
      ),
    );
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

  @override
  Future<void> close() async {
    await _audioSubscription?.cancel();
    await _ttsService?.stop();
    _preloadedAudio = null;
    return super.close();
  }
}
