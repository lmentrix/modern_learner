import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/home/widgets/xp_progress_bar.dart';
import 'package:modern_learner_production/theme/theme.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    super.key,
    required this.animate,
    required this.displayName,
    required this.streak,
    required this.xp,
    required this.xpGoal,
  });

  final bool animate;
  final String displayName;
  final int streak;
  final int xp;
  final int xpGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        EduSpacing.s6,
        EduSpacing.s8,
        EduSpacing.s6,
        EduSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: EduColors.surface,
        borderRadius: const BorderRadius.vertical(bottom: EduRadius.xl),
        boxShadow: EduColors.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SketchAvatar(),
              const SizedBox(width: EduSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $displayName',
                      style: GoogleFonts.caveat(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: EduColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      '$streak-day streak 🔥',
                      style: GoogleFonts.caveat(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: EduColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: EduColors.bg,
                  shape: BoxShape.circle,
                  boxShadow: EduColors.shadowCard,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: EduColors.textPrimary,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: EduSpacing.s5),
          XpProgressBar(xp: xp, goal: xpGoal, animate: animate),
        ],
      ),
    );
  }
}

// ── Avatar with a very light hand-inked ring ──────────────────────────────────

class _SketchAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AvatarRingPainter(),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [EduColors.primaryLight, EduColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,

          //TODO
        ),
      ),
    );
  }
}

class _AvatarRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    const r = 22.5;

    // Single slightly imperfect ring — looks like a quick pen circle
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi * 0.55,
      math.pi * 1.80,
      false,
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.35)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Tiny gap makes it look hand-drawn (not a perfect circle)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx + 0.5, cy - 0.5), radius: r - 1.5),
      math.pi * 0.85,
      math.pi * 0.55,
      false,
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.15)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_AvatarRingPainter old) => false;
}
