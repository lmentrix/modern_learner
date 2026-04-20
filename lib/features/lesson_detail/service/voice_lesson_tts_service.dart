import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';

import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';

class VoiceLessonAudioState {
  const VoiceLessonAudioState({
    this.activeId,
    this.isLoading = false,
    this.isPlaying = false,
    this.errorMessage,
  });

  final String? activeId;
  final bool isLoading;
  final bool isPlaying;
  final String? errorMessage;

  VoiceLessonAudioState copyWith({
    String? activeId,
    bool? isLoading,
    bool? isPlaying,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VoiceLessonAudioState(
      activeId: activeId ?? this.activeId,
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

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

  Stream<VoiceLessonAudioState> get stateStream => _stateController.stream;

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
