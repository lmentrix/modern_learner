import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_chip.dart';
import 'package:modern_learner_production/features/voice/service/voice_pronunciation_scorer.dart';
import 'package:modern_learner_production/features/voice/service/voice_recognition_service.dart';
import 'package:modern_learner_production/features/voice/service/voice_tts_service.dart';

// ── Step state machine ────────────────────────────────────────────────────────

enum _Phase {
  /// No interaction yet.
  idle,

  /// Fetching TTS audio from backend.
  loadingTts,

  /// TTS is playing — karaoke word highlight is active.
  playing,

  /// TTS finished; user hasn't spoken yet (or just finished retry listen).
  ready,

  /// Microphone is active, STT streaming.
  listening,

  /// Scored result ready.
  scored,
}

// ── Widget ────────────────────────────────────────────────────────────────────

class VoiceStepRow extends StatefulWidget {
  const VoiceStepRow({
    super.key,
    required this.step,
    required this.accentColor,
    required this.onScored,
  });

  final VoicePracticeStepModel step;
  final Color accentColor;
  final ValueChanged<PronunciationResult> onScored;

  @override
  State<VoiceStepRow> createState() => _VoiceStepRowState();
}

class _VoiceStepRowState extends State<VoiceStepRow>
    with TickerProviderStateMixin {
  // ── Phase & data ───────────────────────────────────────────────────────────
  _Phase _phase = _Phase.idle;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  int _highlightedWordIdx = -1; // -1 = none highlighted
  String _liveTranscription = '';
  double _liveConfidence = 0;
  PronunciationResult? _result;
  bool _ttsErrored = false;

  // ── Stream subscriptions ───────────────────────────────────────────────────
  StreamSubscription<VoiceTtsEvent>? _eventSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _waveCtrl; // listening waveform
  late final AnimationController _scoreBarCtrl; // score fill on reveal
  late final Animation<double> _scoreBarAnim;
  late final AnimationController _wordPulseCtrl; // glow on highlighted word
  late final Animation<double> _wordPulseAnim;

  // Derived from the prompt text — split once and reused.
  late final List<String> _promptWords;

  @override
  void initState() {
    super.initState();
    _promptWords = widget.step.prompt
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scoreBarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scoreBarAnim = CurvedAnimation(
      parent: _scoreBarCtrl,
      curve: Curves.easeOutCubic,
    );

    _wordPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _wordPulseAnim = CurvedAnimation(
      parent: _wordPulseCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _cancelTtsSubscriptions();
    unawaited(VoiceTtsService.instance.stop());
    unawaited(VoiceRecognitionService.instance.cancelListening());
    _waveCtrl.dispose();
    _scoreBarCtrl.dispose();
    _wordPulseCtrl.dispose();
    super.dispose();
  }

  // ── TTS ────────────────────────────────────────────────────────────────────

  void _startListen() {
    _cancelTtsSubscriptions();

    setState(() {
      _phase = _Phase.loadingTts;
      _ttsErrored = false;
      _highlightedWordIdx = -1;
      _audioDuration = Duration.zero;
      _audioPosition = Duration.zero;
    });

    _eventSub = VoiceTtsService.instance.eventStream.listen(_onTtsEvent);
    _posSub = VoiceTtsService.instance.positionStream.listen(_onPosition);
    _durSub = VoiceTtsService.instance.durationStream.listen(_onDuration);

    unawaited(VoiceTtsService.instance.speak(widget.step.prompt));
  }

  void _onTtsEvent(VoiceTtsEvent event) {
    if (!mounted) return;
    switch (event.phase) {
      case VoiceTtsPhase.loading:
        setState(() => _phase = _Phase.loadingTts);
      case VoiceTtsPhase.playing:
        setState(() {
          _phase = _Phase.playing;
          _audioDuration = event.totalDuration ?? Duration.zero;
        });
      case VoiceTtsPhase.completed:
        setState(() {
          _phase = _Phase.ready;
          _highlightedWordIdx = -1;
        });
        _cancelTtsSubscriptions();
      case VoiceTtsPhase.error:
        setState(() {
          _phase = _Phase.idle;
          _ttsErrored = true;
        });
        _cancelTtsSubscriptions();
    }
  }

  void _onPosition(Duration pos) {
    if (!mounted) return;
    _audioPosition = pos;
    if (_audioDuration > Duration.zero && _promptWords.isNotEmpty) {
      final progress = pos.inMilliseconds / _audioDuration.inMilliseconds;
      final idx = (progress * _promptWords.length).floor().clamp(
        0,
        _promptWords.length - 1,
      );
      if (idx != _highlightedWordIdx) {
        setState(() => _highlightedWordIdx = idx);
      }
    }
  }

  void _onDuration(Duration dur) {
    if (!mounted || dur <= Duration.zero) return;
    setState(() => _audioDuration = dur);
  }

  Future<void> _stopTts() async {
    _cancelTtsSubscriptions();
    await VoiceTtsService.instance.stop();
    if (!mounted) return;
    setState(() {
      _phase = _Phase.ready;
      _highlightedWordIdx = -1;
    });
  }

  void _cancelTtsSubscriptions() {
    _eventSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _eventSub = null;
    _posSub = null;
    _durSub = null;
  }

  // ── STT ────────────────────────────────────────────────────────────────────

  Future<void> _startSpeak() async {
    HapticFeedback.mediumImpact();
    final ok = await VoiceRecognitionService.instance.initialize();
    if (!mounted) return;
    if (!ok) return;

    setState(() {
      _phase = _Phase.listening;
      _liveTranscription = '';
      _liveConfidence = 0;
    });
    _waveCtrl.repeat();

    await VoiceRecognitionService.instance.startListening(
      onResult: (words, confidence) {
        if (!mounted) return;
        setState(() {
          _liveTranscription = words;
          _liveConfidence = confidence;
        });
      },
      onDone: _finishSpeak,
    );
  }

  Future<void> _stopSpeak() async {
    await VoiceRecognitionService.instance.stopListening();
    _finishSpeak();
  }

  void _finishSpeak() {
    if (!mounted || _phase != _Phase.listening) return;
    _waveCtrl.stop();

    if (_liveTranscription.trim().isEmpty) {
      setState(() => _phase = _Phase.ready);
      return;
    }

    final result = VoicePronunciationScorer.score(
      expected: widget.step.prompt,
      spoken: _liveTranscription,
      sttConfidence: _liveConfidence,
    );

    setState(() {
      _phase = _Phase.scored;
      _result = result;
    });
    _scoreBarCtrl.forward(from: 0);
    HapticFeedback.lightImpact();
    widget.onScored(result);
  }

  void _retry() {
    _scoreBarCtrl.reset();
    setState(() {
      _phase = _Phase.ready;
      _result = null;
      _liveTranscription = '';
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _borderColor, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top accent strip ──────────────────────────────────────────
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.accentColor,
                  widget.accentColor.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step chip
                ExerciseChip(
                  'Step ${widget.step.stepNumber}',
                  color: widget.accentColor,
                ),
                const SizedBox(height: 12),

                // ── Phrase display (karaoke / score) ──────────────────
                _PhraseDisplay(
                  words: _promptWords,
                  phase: _phase,
                  highlightedIdx: _highlightedWordIdx,
                  matchedIndices: _result?.matchedIndices ?? const [],
                  accentColor: widget.accentColor,
                  pulseAnim: _wordPulseAnim,
                ),
                const SizedBox(height: 12),

                // Coaching tip (always visible)
                if (widget.step.coachingTip.trim().isNotEmpty)
                  _TipRow(tip: widget.step.coachingTip),

                const SizedBox(height: 16),

                // ── Phase-specific controls ───────────────────────────
                _buildPhaseControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseControls() {
    final result = _result;
    return switch (_phase) {
      _Phase.idle => _IdleControls(
        accentColor: widget.accentColor,
        onListen: _startListen,
        ttsErrored: _ttsErrored,
      ),
      _Phase.loadingTts => _LoadingTtsRow(accentColor: widget.accentColor),
      _Phase.playing => _PlayingControls(
        accentColor: widget.accentColor,
        position: _audioPosition,
        duration: _audioDuration,
        onStop: _stopTts,
      ),
      _Phase.ready => _ReadyControls(
        accentColor: widget.accentColor,
        hasResult: _result != null,
        onReplay: _startListen,
        onSpeak: _startSpeak,
      ),
      _Phase.listening => _ListeningControls(
        accentColor: widget.accentColor,
        waveCtrl: _waveCtrl,
        transcription: _liveTranscription,
        onStop: _stopSpeak,
      ),
      _Phase.scored when result != null => _ScoredControls(
        result: result,
        accentColor: widget.accentColor,
        scoreAnim: _scoreBarAnim,
        onReplay: _startListen,
        onRetry: _retry,
      ),
      _Phase.scored => _ReadyControls(
        accentColor: widget.accentColor,
        hasResult: false,
        onReplay: _startListen,
        onSpeak: _startSpeak,
      ),
    };
  }

  // ── Card appearance helpers ────────────────────────────────────────────────

  Color get _cardColor {
    final result = _result;
    if (_phase == _Phase.scored && result != null) {
      return result.score >= 0.62
          ? AppColors.tertiary.withValues(alpha: 0.04)
          : AppColors.error.withValues(alpha: 0.04);
    }
    if (_phase == _Phase.playing || _phase == _Phase.listening) {
      return widget.accentColor.withValues(alpha: 0.04);
    }
    return AppColors.surfaceContainerLow;
  }

  Color get _borderColor {
    final result = _result;
    if (_phase == _Phase.scored && result != null) {
      return result.score >= 0.62
          ? AppColors.tertiary.withValues(alpha: 0.28)
          : AppColors.error.withValues(alpha: 0.28);
    }
    if (_phase == _Phase.playing) {
      return widget.accentColor.withValues(alpha: 0.45);
    }
    if (_phase == _Phase.listening) {
      return AppColors.error.withValues(alpha: 0.45);
    }
    return widget.accentColor.withValues(alpha: 0.16);
  }

  Color get _shadowColor {
    if (_phase == _Phase.playing) {
      return widget.accentColor.withValues(alpha: 0.12);
    }
    if (_phase == _Phase.listening) {
      return AppColors.error.withValues(alpha: 0.10);
    }
    return Colors.transparent;
  }
}

// ── Phrase display (karaoke + score colouring) ────────────────────────────────

class _PhraseDisplay extends StatelessWidget {
  const _PhraseDisplay({
    required this.words,
    required this.phase,
    required this.highlightedIdx,
    required this.matchedIndices,
    required this.accentColor,
    required this.pulseAnim,
  });

  final List<String> words;
  final _Phase phase;
  final int highlightedIdx;
  final List<int> matchedIndices;
  final Color accentColor;
  final Animation<double> pulseAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, _) {
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(words.length, (i) => _wordChip(i)),
        );
      },
    );
  }

  Widget _wordChip(int i) {
    final word = words[i];

    // ── Scored mode: green = matched, muted = missed ──────────────────────
    if (phase == _Phase.scored) {
      final hit = matchedIndices.contains(i);
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: hit
              ? AppColors.tertiary.withValues(alpha: 0.14)
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hit
                ? AppColors.tertiary.withValues(alpha: 0.35)
                : AppColors.outlineVariant.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: hit ? AppColors.tertiary : AppColors.onSurfaceVariant,
              ),
            ),
            if (hit) ...[
              SizedBox(width: 3),
              Icon(Icons.check_rounded, size: 12, color: AppColors.tertiary),
            ],
          ],
        ),
      );
    }

    // ── Playing mode: karaoke highlight ──────────────────────────────────
    if (phase == _Phase.playing) {
      final isCurrent = i == highlightedIdx;
      final isPast = i < highlightedIdx;
      final glow = isCurrent ? pulseAnim.value : 0.0;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrent
              ? accentColor.withValues(alpha: 0.18 + glow * 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isCurrent
              ? Border.all(color: accentColor.withValues(alpha: 0.50))
              : null,
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.30 + glow * 0.15),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Text(
          word,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
            color: isCurrent
                ? accentColor
                : isPast
                ? AppColors.onSurfaceVariant.withValues(alpha: 0.55)
                : AppColors.onSurface.withValues(alpha: 0.75),
          ),
        ),
      );
    }

    // ── Default: plain text ───────────────────────────────────────────────
    return Text(
      word,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
    );
  }
}

// ── Coaching tip ──────────────────────────────────────────────────────────────

class _TipRow extends StatelessWidget {
  const _TipRow({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.tips_and_updates_rounded,
          size: 14,
          color: AppColors.onSurfaceVariant,
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            tip,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Idle controls ─────────────────────────────────────────────────────────────

class _IdleControls extends StatelessWidget {
  const _IdleControls({
    required this.accentColor,
    required this.onListen,
    required this.ttsErrored,
  });

  final Color accentColor;
  final VoidCallback onListen;
  final bool ttsErrored;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ttsErrored)
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Audio unavailable — you can still practice by speaking.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        FilledButton.icon(
          onPressed: onListen,
          icon: const Icon(Icons.volume_up_rounded, size: 17),
          label: Text(context.tr('Listen first')),
          style: FilledButton.styleFrom(
            backgroundColor: accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ── Loading TTS ───────────────────────────────────────────────────────────────

class _LoadingTtsRow extends StatelessWidget {
  const _LoadingTtsRow({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(accentColor),
          ),
        ),
        SizedBox(width: 10),
        Text(
          'Generating audio…',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── Playing controls ──────────────────────────────────────────────────────────

class _PlayingControls extends StatelessWidget {
  const _PlayingControls({
    required this.accentColor,
    required this.position,
    required this.duration,
    required this.onStop,
  });

  final Color accentColor;
  final Duration position;
  final Duration duration;
  final VoidCallback onStop;

  String _fmt(Duration d) {
    final s = d.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = duration > Duration.zero
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(accentColor),
          ),
        ),
        SizedBox(height: 6),
        Row(
          children: [
            Text(
              '${_fmt(position)} / ${_fmt(duration)}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onStop,
              icon: const Icon(Icons.stop_rounded, size: 15),
              label: Text(context.tr('Stop')),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor.withValues(alpha: 0.40)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Ready controls ────────────────────────────────────────────────────────────

class _ReadyControls extends StatelessWidget {
  const _ReadyControls({
    required this.accentColor,
    required this.hasResult,
    required this.onReplay,
    required this.onSpeak,
  });

  final Color accentColor;
  final bool hasResult;
  final VoidCallback onReplay;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: onReplay,
          icon: const Icon(Icons.replay_rounded, size: 15),
          label: Text(context.tr('Replay')),
          style: OutlinedButton.styleFrom(
            foregroundColor: accentColor,
            side: BorderSide(color: accentColor.withValues(alpha: 0.38)),
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: onSpeak,
            icon: const Icon(Icons.mic_rounded, size: 17),
            label: Text(context.tr(hasResult ? 'Speak again' : 'Speak now')),
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Listening controls ────────────────────────────────────────────────────────

class _ListeningControls extends StatelessWidget {
  const _ListeningControls({
    required this.accentColor,
    required this.waveCtrl,
    required this.transcription,
    required this.onStop,
  });

  final Color accentColor;
  final AnimationController waveCtrl;
  final String transcription;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Waveform(controller: waveCtrl, color: AppColors.error, bars: 8),
            SizedBox(width: 12),
            Text(
              'Listening…',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
            Spacer(),
            FilledButton.icon(
              onPressed: onStop,
              icon: Icon(Icons.stop_rounded, size: 15),
              label: Text(context.tr('Done')),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        if (transcription.isNotEmpty) ...[
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              transcription,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurface,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Scored controls ───────────────────────────────────────────────────────────

class _ScoredControls extends StatelessWidget {
  const _ScoredControls({
    required this.result,
    required this.accentColor,
    required this.scoreAnim,
    required this.onReplay,
    required this.onRetry,
  });

  final PronunciationResult result;
  final Color accentColor;
  final Animation<double> scoreAnim;
  final VoidCallback onReplay;
  final VoidCallback onRetry;

  Color get _scoreColor {
    if (result.score >= 0.78) return AppColors.tertiary;
    if (result.score >= 0.50) return Color(0xFFFFD580);
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grade + percent
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _scoreColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _scoreColor.withValues(alpha: 0.30)),
              ),
              child: Text(
                result.grade,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _scoreColor,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${result.scorePercent}%',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _scoreColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Animated score bar
        AnimatedBuilder(
          animation: scoreAnim,
          builder: (context, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: result.score * scoreAnim.value,
                minHeight: 6,
                backgroundColor: AppColors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(_scoreColor),
              ),
            );
          },
        ),
        SizedBox(height: 8),

        // Matched word count
        Text(
          '${result.matchedWords} of ${result.totalWords} words matched',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 6),

        // Feedback
        Text(
          result.feedback,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),

        // Action row
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onReplay,
              icon: const Icon(Icons.volume_up_rounded, size: 15),
              label: Text(context.tr('Listen again')),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor.withValues(alpha: 0.38)),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.mic_rounded, size: 15),
              label: Text(context.tr('Try again')),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor.withValues(alpha: 0.38)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Waveform ──────────────────────────────────────────────────────────────────

class _Waveform extends StatelessWidget {
  const _Waveform({
    required this.controller,
    required this.color,
    this.bars = 6,
  });

  final AnimationController controller;
  final Color color;
  final int bars;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SizedBox(
          width: bars * 5.0 + (bars - 1) * 3.0,
          height: 22,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(bars, (i) {
              final phase = controller.value + i / bars;
              final h = 4 + 16 * math.sin(phase * math.pi * 2).abs();
              return Container(
                width: 4,
                height: h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
