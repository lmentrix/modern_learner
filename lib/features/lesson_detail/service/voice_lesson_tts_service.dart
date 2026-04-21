import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';

import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';

/// Represents the state of audio playback for a voice lesson.
class VoiceLessonAudioState {
  const VoiceLessonAudioState({
    this.activeId,
    this.isLoading = false,
    this.isPlaying = false,
    this.errorMessage,
    this.audioBytes,
  });

  final String? activeId;
  final bool isLoading;
  final bool isPlaying;
  final String? errorMessage;
  final Uint8List? audioBytes;

  VoiceLessonAudioState copyWith({
    String? activeId,
    bool? isLoading,
    bool? isPlaying,
    String? errorMessage,
    bool clearError = false,
    Uint8List? audioBytes,
  }) {
    return VoiceLessonAudioState(
      activeId: activeId ?? this.activeId,
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      audioBytes: audioBytes ?? this.audioBytes,
    );
  }
}

/// Represents pre-generated audio for a voice lesson item.
class GeneratedLessonAudio {
  const GeneratedLessonAudio({
    required this.id,
    required this.audioBytes,
    this.mimeType = 'audio/wav',
  });

  final String id;
  final Uint8List audioBytes;
  final String mimeType;
}

/// Service for handling Text-to-Speech (TTS) functionality for voice lessons.
/// 
/// Supports both on-demand TTS generation and pre-generated audio from the backend.
class VoiceLessonTtsService {
  VoiceLessonTtsService({required this.dio}) {
    _player.onPlayerStateChanged.listen(_handlePlayerState);
    _player.onPlayerComplete.listen((_) {
      _publish(
        VoiceLessonAudioState(
          activeId: _state.activeId,
          isLoading: false,
          isPlaying: false,
        ),
      );
    });
  }

  final Dio dio;
  final AudioPlayer _player = AudioPlayer();
  final _stateController = StreamController<VoiceLessonAudioState>.broadcast();
  final Map<String, Uint8List> _audioCache = <String, Uint8List>{};
  VoiceLessonAudioState _state = const VoiceLessonAudioState();

  /// Stream of audio state changes for UI updates.
  Stream<VoiceLessonAudioState> get stateStream => _stateController.stream;

  /// Current audio state.
  VoiceLessonAudioState get currentState => _state;

  /// Pre-load multiple audio files for a complete voice lesson.
  /// 
  /// This method generates audio for all phrases and exercises using the
  /// backend's Qwen TTS API. Returns a map of item IDs to audio bytes.
  Future<Map<String, Uint8List>> preloadLessonAudio({
    required List<VoicePhrase> phrases,
    required List<VoiceExercise> exercises,
    LessonNarratorTts? narratorTts,
    String? model,
  }) async {
    final audioMap = <String, Uint8List>{};

    // Generate narrator audio if provided
    if (narratorTts != null && narratorTts.introText.isNotEmpty) {
      try {
        final narratorAudio = await _generateTts(
          tts: narratorTts.toRequestJson(model: model),
          cacheKey: 'narrator_intro',
        );
        if (narratorAudio != null) {
          audioMap['narrator'] = narratorAudio;
        }
      } catch (e) {
        // Continue even if narrator audio fails
      }
    }

    // Generate audio for all phrases
    for (final phrase in phrases) {
      final tts = phrase.getTtsOrBuildFallback(const VoiceLessonVoiceProfile.defaultProfile());
      final cacheKey = 'phrase_${phrase.id}';
      
      try {
        final audio = await _generateTts(
          tts: tts.toRequestJson(model: model),
          cacheKey: cacheKey,
        );
        if (audio != null) {
          audioMap[phrase.id] = audio;
        }
      } catch (e) {
        // Continue even if individual phrase fails
      }
    }

    // Generate audio for all exercises
    for (final exercise in exercises) {
      final tts = exercise.getTtsOrBuildFallback(const VoiceLessonVoiceProfile.defaultProfile());
      final cacheKey = 'exercise_${exercise.id}';
      
      try {
        final audio = await _generateTts(
          tts: tts.toRequestJson(model: model),
          cacheKey: cacheKey,
        );
        if (audio != null) {
          audioMap[exercise.id] = audio;
        }
      } catch (e) {
        // Continue even if individual exercise fails
      }
    }

    return audioMap;
  }

  /// Toggle playback for a phrase (play if stopped, stop if playing).
  Future<void> togglePhrase({
    required String playbackId,
    required VoiceSpeechAttributes speech,
  }) async {
    if (_state.activeId == playbackId && _state.isPlaying) {
      await stop();
      return;
    }

    await playPhrase(playbackId: playbackId, speech: speech);
  }

  /// Play audio for a phrase using TTS.
  Future<void> playPhrase({
    required String playbackId,
    required VoiceSpeechAttributes speech,
  }) async {
    try {
      _publish(
        VoiceLessonAudioState(
          activeId: playbackId,
          isLoading: true,
          isPlaying: false,
        ),
      );

      Uint8List bytes;
      final cached = _audioCache[playbackId];
      if (cached != null) {
        bytes = cached;
      } else {
        final response = await dio.post<Map<String, dynamic>>(
          ApiConstants.voiceLessonTts,
          data: speech.toRequestJson(),
        );
        final payload = _unwrapPayload(response.data);
        final encoded =
            payload['audioBase64'] as String? ??
            payload['audio_base64'] as String? ??
            '';
        if (encoded.isEmpty) {
          throw Exception('The TTS response did not include audio data.');
        }

        bytes = base64Decode(encoded);
        _audioCache[playbackId] = bytes;
      }

      await _player.stop();
      await _player.play(BytesSource(bytes));
      _publish(
        VoiceLessonAudioState(
          activeId: playbackId,
          isLoading: false,
          isPlaying: true,
        ),
      );
    } catch (error) {
      _publish(
        VoiceLessonAudioState(
          activeId: playbackId,
          isLoading: false,
          isPlaying: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  /// Play pre-generated audio for a lesson item.
  Future<void> playPreloadedAudio({
    required String playbackId,
    required Uint8List audioBytes,
  }) async {
    try {
      _publish(
        VoiceLessonAudioState(
          activeId: playbackId,
          isLoading: true,
          isPlaying: false,
        ),
      );

      await _player.stop();
      await _player.play(BytesSource(audioBytes));
      _publish(
        VoiceLessonAudioState(
          activeId: playbackId,
          isLoading: false,
          isPlaying: true,
        ),
      );
    } catch (error) {
      _publish(
        VoiceLessonAudioState(
          activeId: playbackId,
          isLoading: false,
          isPlaying: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  /// Stop current playback.
  Future<void> stop() async {
    await _player.stop();
    _publish(
      VoiceLessonAudioState(
        activeId: _state.activeId,
        isLoading: false,
        isPlaying: false,
      ),
    );
  }

  /// Clear the audio cache to free memory.
  void clearCache() {
    _audioCache.clear();
  }

  /// Dispose of resources.
  Future<void> dispose() async {
    await _audioSubscription?.cancel();
    await _player.dispose();
    await _stateController.close();
  }

  StreamSubscription<VoiceLessonAudioState>? _audioSubscription;

  /// Generate TTS audio and cache the result.
  Future<Uint8List?> _generateTts({
    required Map<String, dynamic> tts,
    required String cacheKey,
  }) async {
    // Check cache first
    final cached = _audioCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.voiceLessonTts,
        data: tts,
      );
      final payload = _unwrapPayload(response.data);
      final encoded =
          payload['audioBase64'] as String? ??
          payload['audio_base64'] as String? ??
          '';
      if (encoded.isEmpty) {
        return null;
      }

      final bytes = base64Decode(encoded);
      _audioCache[cacheKey] = bytes;
      return bytes;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _unwrapPayload(Map<String, dynamic>? raw) {
    if (raw == null) return <String, dynamic>{};
    final nested = raw['data'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }
    return raw;
  }

  void _handlePlayerState(PlayerState state) {
    switch (state) {
      case PlayerState.playing:
        _publish(
          _state.copyWith(isLoading: false, isPlaying: true, clearError: true),
        );
      case PlayerState.paused:
      case PlayerState.stopped:
      case PlayerState.completed:
      case PlayerState.disposed:
        _publish(_state.copyWith(isLoading: false, isPlaying: false));
    }
  }

  void _publish(VoiceLessonAudioState next) {
    _state = next;
    if (!_stateController.isClosed) {
      _stateController.add(next);
    }
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      final payload = error.response?.data;
      if (payload is Map<String, dynamic>) {
        final nested = payload['data'];
        if (nested is Map<String, dynamic>) {
          final nestedMessage = nested['message'];
          if (nestedMessage is String && nestedMessage.isNotEmpty) {
            return nestedMessage;
          }
        }

        final message = payload['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }

      if (error.message != null && error.message!.isNotEmpty) {
        return error.message!;
      }
    }

    return 'Voice playback is unavailable right now.';
  }
}
