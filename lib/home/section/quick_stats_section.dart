import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/home/model/home_models.dart';
import 'package:modern_learner_production/home/widgets/stat_card.dart';
import 'package:modern_learner_production/theme/theme.dart';

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({
    super.key,
    required this.animate,
    required this.stats,
  });

  final bool animate;
  final List<QuickStat> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EduSpacing.pagePadding,
          child: _SketchSectionTitle(label: 'Quick stats'),
        ),
        const SizedBox(height: EduSpacing.s4),
        Padding(
          padding: EduSpacing.pagePadding,
          child: Row(
            children: [
              for (var i = 0; i < stats.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i < stats.length - 1 ? EduSpacing.s2 : 0,
                    ),
                    child: StatCard(animate: animate, stat: stats[i]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared sketch section title used across home sections ─────────────────────

class _SketchSectionTitle extends StatelessWidget {
  const _SketchSectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.caveat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: EduColors.textPrimary,
          ),
        ),
        // Very subtle wavy accent line — just a hint of the sketch style
        CustomPaint(
          painter: _ThinAccentLinePainter(),
          size: Size(label.length * 7.2, 5),
        ),
      ],
    );
  }
}

// ── Thin accent line (barely-there wave, not dramatic) ───────────────────────

class _ThinAccentLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.6)
        ..quadraticBezierTo(
          size.width * 0.30,
          size.height * 0.1,
          size.width * 0.62,
          size.height * 0.7,
        )
        ..lineTo(size.width * 0.90, size.height * 0.3),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.40)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ThinAccentLinePainter old) => false;
}
