import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/home/data/home_data.dart';
import 'package:modern_learner_production/home/widgets/stat_card.dart';
import 'package:modern_learner_production/theme/theme.dart';

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({super.key, required this.animate});

  final bool animate;

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
            children: mockStats.map((stat) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: stat == mockStats.last ? 0 : EduSpacing.s3,
                  ),
                  child: StatCard(stat: stat, animate: animate),
                ),
              );
            }).toList(),
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
            size.width * 0.30, size.height * 0.1,
            size.width * 0.62, size.height * 0.7)
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
