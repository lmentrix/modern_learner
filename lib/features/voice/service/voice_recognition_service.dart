import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Thin singleton wrapper around [SpeechToText].
/// Handles initialisation, locale resolution, and start/stop lifecycle.
class VoiceRecognitionService {
  VoiceRecognitionService._();
  static final VoiceRecognitionService instance = VoiceRecognitionService._();

  final _stt = SpeechToText();
  bool _ready = false;
  bool _listening = false;

  bool get isListening => _listening;
  bool get isAvailable => _ready && _stt.isAvailable;

  /// Must be called before the first [startListening].
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<bool> initialize() async {
    if (_ready) return true;
    _ready = await _stt.initialize(
      onError: (_) => _listening = false,
      onStatus: (status) {
        if (status == SpeechToText.notListeningStatus ||
            status == SpeechToText.doneStatus) {
          _listening = false;
        }
      },
    );
    return _ready;
  }

  /// Starts listening and streams results via [onResult].
  /// [onResult] receives the current transcription and STT confidence (0–1).
  /// [onDone] is called when the STT engine signals a final result.
  Future<void> startListening({
    required void Function(String words, double confidence) onResult,
    VoidCallback? onDone,
    String? localeId,
  }) async {
    if (!_ready) await initialize();
    if (!_ready || _listening) return;

    _listening = true;
    await _stt.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.confidence);
        if (result.finalResult) {
          _listening = false;
          onDone?.call();
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> stopListening() async {
    if (!_listening) return;
    await _stt.stop();
    _listening = false;
  }

  Future<void> cancelListening() async {
    await _stt.cancel();
    _listening = false;
  }

  Future<List<LocaleName>> availableLocales() async {
    if (!_ready) await initialize();
    return _stt.locales();
  }
}
