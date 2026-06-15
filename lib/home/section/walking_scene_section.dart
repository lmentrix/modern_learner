import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/home/widgets/walking_student_painter.dart';
import 'package:modern_learner_production/theme/theme.dart';

/// Expands to fill whatever height its parent (AnimatedContainer) provides.
///
/// • Walk cycle always animates once mounted.
/// • When [isRefreshing] is true: walk speed doubles and the "Refreshing…"
///   label slides up from the bottom as a Flutter Text widget — guaranteed
///   to render above the CustomPaint, so nothing can block it.
class WalkingSceneSection extends StatefulWidget {
  const WalkingSceneSection({super.key, this.isRefreshing = false});

  final bool isRefreshing;

  @override
  State<WalkingSceneSection> createState() => _WalkingSceneSectionState();
}

class _WalkingSceneSectionState extends State<WalkingSceneSection>
    with TickerProviderStateMixin {

  // P9 Timing: 820 ms / cycle feels natural and weighted
  static const _normalDuration  = Duration(milliseconds: 820);
  static const _refreshDuration = Duration(milliseconds: 430);

  late AnimationController _walkCtrl;
  late final AnimationController _cloudCtrl;

  @override
  void initState() {
    super.initState();
    _walkCtrl = AnimationController(vsync: this, duration: _normalDuration)
      ..repeat();
    // 40 s per loop — drives cloud drift + all parallax layers
    _cloudCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void didUpdateWidget(WalkingSceneSection old) {
    super.didUpdateWidget(old);
    if (widget.isRefreshing == old.isRefreshing) return;
    // Swap speed without losing the current animation phase
    final phase = _walkCtrl.value;
    _walkCtrl.dispose();
    _walkCtrl = AnimationController(
      vsync: this,
      duration: widget.isRefreshing ? _refreshDuration : _normalDuration,
      value: phase,
    )..repeat();
    setState(() {});
  }

  @override
  void dispose() {
    _walkCtrl.dispose();
    _cloudCtrl.dispose();
    super.dispose();
  }

  bool get _isNight {
    final h = DateTime.now().hour;
    return h >= 21 || h < 5;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: EduRadius.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Animated scene (CustomPainter) ──────────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([_walkCtrl, _cloudCtrl]),
            builder: (context, child) => CustomPaint(
              painter: WalkingStudentPainter(
                walkPhase:    _walkCtrl.value,
                scrollPhase:  _cloudCtrl.value,
                isRefreshing: widget.isRefreshing,
                hour:         DateTime.now().hour,
              ),
              child: const SizedBox.expand(),
            ),
          ),

          // ── "Refreshing…" label ─────────────────────────────────────
          // Flutter widget rendered on top of the paint — nothing can
          // overlap it.  AnimatedOpacity fades it in/out smoothly.
          AnimatedOpacity(
            opacity: widget.isRefreshing ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: Align(
              alignment: const Alignment(0, 0.80), // lower third
              child: AnimatedBuilder(
                animation: _walkCtrl,
                builder: (context, _) {
                  final dots = (_walkCtrl.value * 3).floor() % 4;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: (_isNight
                              ? const Color(0xFF1E1B4B)
                              : Colors.white)
                          .withValues(alpha: 0.72),
                      borderRadius: EduRadius.borderPill,
                    ),
                    child: Text(
                      'Refreshing${'.' * dots}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: _isNight
                            ? const Color(0xFF818CF8)
                            : EduColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
