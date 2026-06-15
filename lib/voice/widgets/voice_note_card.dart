import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/voice/model/voice_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class VoiceNoteCard extends StatelessWidget {
  const VoiceNoteCard({super.key, required this.note});

  final VoiceNote note;

  @override
  Widget build(BuildContext context) {
    final accent = Color(note.subjectColor);

    return CustomPaint(
      painter: _CardCornerAccent(color: accent),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          color: EduColors.surface,
          borderRadius: EduRadius.borderXl,
          boxShadow: EduColors.shadowCard,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored left strip
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: EduRadius.borderPill,
              ),
            ),
            const SizedBox(width: EduSpacing.s3),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: GoogleFonts.caveat(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: EduColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: EduSpacing.s2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.30),
                          borderRadius: EduRadius.borderPill,
                        ),
                        child: Text(
                          note.subject,
                          style: GoogleFonts.caveat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: EduColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: EduSpacing.s1),

                  // Transcript preview
                  Text(
                    note.transcript,
                    style: GoogleFonts.caveat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: EduColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: EduSpacing.s2),

                  // Meta row
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: EduColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        note.duration,
                        style: GoogleFonts.caveat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: EduColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: EduSpacing.s3),
                      const Icon(Icons.text_fields_rounded,
                          size: 13, color: EduColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        '${note.wordCount} words',
                        style: GoogleFonts.caveat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: EduColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        note.createdAt,
                        style: GoogleFonts.caveat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: EduColors.textSecondary
                              .withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: EduSpacing.s2),

            // Play button
            CustomPaint(
              painter: _PlayRingPainter(color: accent),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.18),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        size: 20, color: EduColors.textPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardCornerAccent extends CustomPainter {
  const _CardCornerAccent({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(26, 1.8)
        ..quadraticBezierTo(8, 1.2, 1.8, 16),
      Paint()
        ..color = color.withValues(alpha: 0.32)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CardCornerAccent old) => old.color != color;
}

class _PlayRingPainter extends CustomPainter {
  const _PlayRingPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: 19.5),
      -math.pi * 0.60,
      math.pi * 1.82,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.42)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_PlayRingPainter old) => old.color != color;
}
