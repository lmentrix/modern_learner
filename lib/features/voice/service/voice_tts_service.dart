import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:modern_learner_production/core/constants/api_constants.dart';

// ── Events ────────────────────────────────────────────────────────────────────

enum VoiceTtsPhase { loading, playing, completed, error }

class VoiceTtsEvent {
  const VoiceTtsEvent._(this.phase, {this.totalDuration});

  factory VoiceTtsEvent.loading() =>
      const VoiceTtsEvent._(VoiceTtsPhase.loading);
  factory VoiceTtsEvent.playing({required Duration totalDuration}) =>
      VoiceTtsEvent._(VoiceTtsPhase.playing, totalDuration: totalDuration);
  factory VoiceTtsEvent.completed() =>
      const VoiceTtsEvent._(VoiceTtsPhase.completed);
  factory VoiceTtsEvent.error() => const VoiceTtsEvent._(VoiceTtsPhase.error);

  final VoiceTtsPhase phase;
  final Duration? totalDuration;
}

// ── Service ───────────────────────────────────────────────────────────────────

/// Two-path TTS service:
///
/// 1. **OpenRouter** (primary) — calls `google/gemini-3.1-flash-tts-preview`
///    directly when `OPENROUTER_API_KEY` is set in `.env`. Returns high-quality
///    audio; enables real-time position tracking for karaoke highlighting.
///
/// 2. **Device TTS** (fallback) — uses [FlutterTts] (AVSpeechSynthesizer on
///    iOS, Google TTS on Android). Always available without any API key or
///    backend. Word highlighting is driven by a timer-based position estimator.
///
/// Both paths emit the same [eventStream], [positionStream], and
/// [durationStream] so the UI is agnostic to which path ran.
class VoiceTtsService {
  VoiceTtsService._();
  static final VoiceTtsService instance = VoiceTtsService._();

  // ── Audio engines ─────────────────────────────────────────────────────────
  final _player = AudioPlayer();
  final _deviceTts = FlutterTts();
  bool _deviceTtsReady = false;

  // ── Unified output streams ─────────────────────────────────────────────────
  final _eventCtrl = StreamController<VoiceTtsEvent>.broadcast();
  final _positionCtrl = StreamController<Duration>.broadcast();
  final _durationCtrl = StreamController<Duration>.broadcast();

  Stream<VoiceTtsEvent> get eventStream => _eventCtrl.stream;
  Stream<Duration> get positionStream => _positionCtrl.stream;
  Stream<Duration> get durationStream => _durationCtrl.stream;

  bool _playing = false;
  bool get isPlaying => _playing;

  // Internal subscriptions / timers for the current speak() call.
  StreamSubscription<Duration>? _playerPosSub;
  StreamSubscription<Duration>? _playerDurSub;
  Timer? _estimatorTimer;

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> speak(
    String text, {
    String voice = 'Kore',
    String model = 'google/gemini-3.1-flash-tts-preview',
  }) async {
    await stop();
    _eventCtrl.add(VoiceTtsEvent.loading());

    // Path 1 — OpenRouter direct (requires OPENROUTER_API_KEY in .env).
    final apiKey = ApiConstants.openRouterApiKey.trim();
    if (apiKey.isNotEmpty) {
      final bytes = await _fetchOpenRouter(
        text,
        apiKey: apiKey,
        voice: voice,
        model: model,
      );
      if (bytes != null && bytes.isNotEmpty) {
        await _playWithAudioPlayer(bytes);
        return;
      }
    }

    // Path 2 — Device TTS (always available).
    await _playWithDeviceTts(text);
  }

  Future<void> stop() async {
    _playing = false;
    _estimatorTimer?.cancel();
    _playerPosSub?.cancel();
    _playerDurSub?.cancel();
    _estimatorTimer = null;
    _playerPosSub = null;
    _playerDurSub = null;
    await _player.stop();
    await _deviceTts.stop();
  }

  void dispose() {
    _eventCtrl.close();
    _positionCtrl.close();
    _durationCtrl.close();
    _player.dispose();
  }

  // ── Path 1: OpenRouter → audioplayers ─────────────────────────────────────

  Future<void> _playWithAudioPlayer(List<int> bytes) async {
    try {
      final tempFile = await _writeTempFile(bytes);

      // Forward real position/duration events into the unified controllers.
      _playerPosSub = _player.onPositionChanged.listen(_positionCtrl.add);
      _playerDurSub = _player.onDurationChanged.listen((d) {
        if (d > Duration.zero) _durationCtrl.add(d);
      });

      // Capture duration so we can emit playing(totalDuration).
      final durationCompleter = Completer<Duration>();
      final durCapSub = _player.onDurationChanged.listen((d) {
        if (!durationCompleter.isCompleted && d > Duration.zero) {
          durationCompleter.complete(d);
        }
      });

      _playing = true;
      await _player.play(DeviceFileSource(tempFile.path));

      final total = await durationCompleter.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => Duration.zero,
      );
      await durCapSub.cancel();

      _eventCtrl.add(VoiceTtsEvent.playing(totalDuration: total));

      // Await playback completion.
      final completer = Completer<void>();
      final playSub = _player.onPlayerComplete.listen((_) {
        if (!completer.isCompleted) completer.complete();
      });
      await completer.future.timeout(
        const Duration(seconds: 120),
        onTimeout: () {},
      );

      _playing = false;
      await playSub.cancel();
      _playerPosSub?.cancel();
      _playerDurSub?.cancel();
      _playerPosSub = null;
      _playerDurSub = null;

      _eventCtrl.add(VoiceTtsEvent.completed());
      unawaited(tempFile.delete().catchError((_) => tempFile));
    } catch (_) {
      _playing = false;
      _eventCtrl.add(VoiceTtsEvent.error());
    }
  }

  // ── Path 2: Device TTS + timer-based position estimator ───────────────────

  Future<void> _playWithDeviceTts(String text) async {
    try {
      await _ensureDeviceTtsReady();

      // Estimate total duration: ~420 ms per word at normal rate.
      final wordCount = math.max(
        1,
        text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
      );
      final totalMs = wordCount * 420;
      final totalDuration = Duration(milliseconds: totalMs);

      _durationCtrl.add(totalDuration);
      _eventCtrl.add(VoiceTtsEvent.playing(totalDuration: totalDuration));
      _playing = true;

      // Timer-based position emitter — drives karaoke highlighting.
      final start = DateTime.now();
      _estimatorTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
        final elapsed = DateTime.now().difference(start);
        if (elapsed < totalDuration) {
          _positionCtrl.add(elapsed);
        } else {
          _estimatorTimer?.cancel();
        }
      });

      // Speak and await completion via handlers.
      final completer = Completer<void>();
      _deviceTts.setCompletionHandler(() {
        if (!completer.isCompleted) completer.complete();
      });
      _deviceTts.setErrorHandler((msg) {
        if (!completer.isCompleted) completer.complete();
      });

      await _deviceTts.speak(text);

      // Timeout = estimated duration + 4 s buffer for slower voices.
      await completer.future.timeout(
        Duration(milliseconds: totalMs + 4000),
        onTimeout: () {},
      );

      _estimatorTimer?.cancel();
      _playing = false;
      _eventCtrl.add(VoiceTtsEvent.completed());
    } catch (_) {
      _estimatorTimer?.cancel();
      _playing = false;
      _eventCtrl.add(VoiceTtsEvent.error());
    }
  }

  Future<void> _ensureDeviceTtsReady() async {
    if (_deviceTtsReady) return;
    await _deviceTts.setLanguage('en-US');
    await _deviceTts.setSpeechRate(0.48);
    await _deviceTts.setVolume(1.0);
    await _deviceTts.setPitch(1.05);
    _deviceTtsReady = true;
  }

  // ── OpenRouter HTTP fetch ──────────────────────────────────────────────────

  Future<List<int>?> _fetchOpenRouter(
    String text, {
    required String apiKey,
    required String voice,
    required String model,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('https://openrouter.ai/api/v1/audio/speech'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'Accept': 'audio/mpeg',
            },
            body: jsonEncode({'model': model, 'input': text, 'voice': voice}),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) return response.bodyBytes;
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<File> _writeTempFile(List<int> bytes) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final file = File('${Directory.systemTemp.path}/ml_tts_$ts.mp3');
    await file.writeAsBytes(bytes);
    return file;
  }
}
