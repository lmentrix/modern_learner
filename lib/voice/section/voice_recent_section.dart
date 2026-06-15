import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/voice/data/voice_data.dart';
import 'package:modern_learner_production/voice/widgets/voice_note_card.dart';
import 'package:modern_learner_production/theme/theme.dart';

class VoiceRecentSection extends StatelessWidget {
  const VoiceRecentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EduSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Recent Notes',
                    style: GoogleFonts.caveat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: EduColors.textPrimary,
                    ),
                  ),
                  CustomPaint(
                    painter: _SketchAccentLine(width: 112),
                    size: const Size(112, 5),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'See all',
                style: GoogleFonts.caveat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: EduColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: EduSpacing.s4),
          ...mockVoiceNotes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: EduSpacing.s3),
              child: VoiceNoteCard(note: note),
            ),
          ),
        ],
      ),
    );
  }
}

class _SketchAccentLine extends CustomPainter {
  const _SketchAccentLine({required this.width});
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.60)
        ..quadraticBezierTo(
          width * 0.30, size.height * 0.10,
          width * 0.62, size.height * 0.70,
        )
        ..lineTo(width * 0.90, size.height * 0.30),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.40)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SketchAccentLine old) => false;
}
