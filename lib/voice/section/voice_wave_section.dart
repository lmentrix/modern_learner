import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/voice/model/voice_models.dart';
import 'package:modern_learner_production/voice/widgets/mic_button.dart';
import 'package:modern_learner_production/voice/widgets/wave_ring_painter.dart';
import 'package:modern_learner_production/theme/theme.dart';

class VoiceWaveSection extends StatelessWidget {
  const VoiceWaveSection({
    super.key,
    required this.state,
    required this.phase,
    required this.amplitude,
    required this.elapsed,
    required this.onMicTap,
  });

  final VoiceState state;
  final double phase;     // 0.0 → 1.0 looping
  final double amplitude; // 0.0 → 1.0
  final int elapsed;      // seconds recording
  final VoidCallback onMicTap;

  String get _statusLabel => switch (state) {
        VoiceState.idle       => 'Tap to record',
        VoiceState.recording  => 'Recording...',
        VoiceState.processing => 'Processing...',
        VoiceState.done       => 'Done!  Tap to record again',
      };

  Color _statusColor(VoiceState s) => switch (s) {
        VoiceState.recording  => const Color(0xFFEF4444),
        VoiceState.processing => EduColors.star,
        _                     => EduColors.textSecondary,
      };

  String get _timerLabel {
    final m = elapsed ~/ 60;
    final s = elapsed % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated sketch wave rings
          CustomPaint(
            painter: WaveRingPainter(
              phase: phase,
              state: state,
              amplitude: amplitude,
            ),
            child: const SizedBox(width: 290, height: 290),
          ),

          // Central content: mic + labels
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MicButton(state: state, onTap: onMicTap),
              const SizedBox(height: EduSpacing.s4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _statusLabel,
                  key: ValueKey(state),
                  style: GoogleFonts.caveat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(state),
                  ),
                ),
              ),
              // Timer shown only while recording
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                child: state == VoiceState.recording
                    ? Padding(
                        padding: const EdgeInsets.only(top: EduSpacing.s2),
                        child: Text(
                          _timerLabel,
                          style: GoogleFonts.caveat(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: EduColors.textPrimary,
                            height: 1.0,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
