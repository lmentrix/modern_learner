import 'dart:async';
import 'package:flutter/material.dart';
import 'package:modern_learner_production/theme/theme.dart';
import 'package:modern_learner_production/voice/data/voice_data.dart';
import 'package:modern_learner_production/voice/model/voice_models.dart';
import 'package:modern_learner_production/voice/section/voice_header_section.dart';
import 'package:modern_learner_production/voice/section/voice_recent_section.dart';
import 'package:modern_learner_production/voice/section/voice_transcript_section.dart';
import 'package:modern_learner_production/voice/section/voice_wave_section.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> with TickerProviderStateMixin {
  // ── Voice state ───────────────────────────────────────────────────────────
  VoiceState _voiceState = VoiceState.idle;
  int _elapsed = 0;
  Timer? _recordTimer;

  // ── Live transcript simulation ────────────────────────────────────────────
  String _transcript = '';
  int _wordCount = 0;
  int _chunkIndex = 0;
  Timer? _transcriptTimer;

  // ── Wave animation (always looping) ──────────────────────────────────────
  late final AnimationController _waveCtrl;
  late final Animation<double> _wavePhase;

  // ── Entrance stagger ──────────────────────────────────────────────────────
  static const _sectionCount = 3;
  late final List<AnimationController> _entranceCtrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;
  final List<bool> _started = List.filled(_sectionCount, false);

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _wavePhase = CurvedAnimation(parent: _waveCtrl, curve: Curves.linear);

    _entranceCtrls = List.generate(
      _sectionCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 420),
      ),
    );
    _fades = _entranceCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _entranceCtrls
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    _launchEntrance();
  }

  void _launchEntrance() {
    for (var i = 0; i < _sectionCount; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (!mounted) return;
        setState(() => _started[i] = true);
        _entranceCtrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    for (final c in _entranceCtrls) c.dispose();
    _recordTimer?.cancel();
    _transcriptTimer?.cancel();
    super.dispose();
  }

  // ── Mic tap logic ─────────────────────────────────────────────────────────

  void _onMicTap() {
    switch (_voiceState) {
      case VoiceState.idle:
      case VoiceState.done:
        _startRecording();
      case VoiceState.recording:
        _stopRecording();
      case VoiceState.processing:
        break;
    }
  }

  void _startRecording() {
    setState(() {
      _voiceState = VoiceState.recording;
      _elapsed = 0;
      _transcript = '';
      _wordCount = 0;
      _chunkIndex = 0;
    });

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });

    // Drip in mock transcript chunks every ~1.8 s
    _transcriptTimer =
        Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (!mounted) return;
      if (_chunkIndex < mockTranscriptChunks.length) {
        setState(() {
          _transcript +=
              (_transcript.isEmpty ? '' : ' ') + mockTranscriptChunks[_chunkIndex];
          _chunkIndex++;
          _wordCount = _transcript.trim().split(RegExp(r'\s+')).length;
        });
      }
    });
  }

  void _stopRecording() {
    _recordTimer?.cancel();
    _transcriptTimer?.cancel();
    setState(() => _voiceState = VoiceState.processing);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _voiceState = VoiceState.done);
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _wrap(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  double get _amplitude => switch (_voiceState) {
        VoiceState.recording  => 1.0,
        VoiceState.processing => 0.5,
        _                     => 0.0,
      };

  bool get _showTranscript =>
      _voiceState == VoiceState.recording ||
      _voiceState == VoiceState.processing ||
      _voiceState == VoiceState.done;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EduColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: _wrap(
                0,
                const Padding(
                  padding: EdgeInsets.only(top: EduSpacing.s6),
                  child: VoiceHeaderSection(),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s6)),

          // Wave + mic hero
          SliverToBoxAdapter(
            child: _wrap(
              1,
              AnimatedBuilder(
                animation: _wavePhase,
                builder: (_, __) => VoiceWaveSection(
                  state: _voiceState,
                  phase: _wavePhase.value,
                  amplitude: _amplitude,
                  elapsed: _elapsed,
                  onMicTap: _onMicTap,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s5)),

          // Transcript while recording/processing/done; recent notes while idle
          SliverToBoxAdapter(
            child: _wrap(
              2,
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _showTranscript
                    ? VoiceTranscriptSection(
                        key: const ValueKey('transcript'),
                        state: _voiceState,
                        transcript: _transcript,
                        wordCount: _wordCount,
                      )
                    : const VoiceRecentSection(key: ValueKey('recent')),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

