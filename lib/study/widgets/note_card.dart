import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Note card — hand-sketched index-card aesthetic
// ─────────────────────────────────────────────────────────────────────────────

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.index = 0,
  });

  final StudyNote note;
  final VoidCallback onTap;
  final int index;

  // Deterministic tiny tilt per card
  static const _tilts = [-0.013, 0.009, -0.016, 0.011, -0.008, 0.014];

  @override
  Widget build(BuildContext context) {
    final tilt = _tilts[index % _tilts.length];
    final accent = Color(note.tagColor);

    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: tilt,
        child: CustomPaint(
          painter: _NoteCardPainter(seed: index, accent: accent),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row ─────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SubjectStamp(subject: note.subject, color: accent),
                    const Spacer(),
                    _TimeAnnotation(minutes: note.readMinutes),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Title ────────────────────────────────────────────────
                Text(
                  note.title,
                  style: GoogleFonts.caveat(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 5),

                // ── Preview ──────────────────────────────────────────────
                Text(
                  note.preview,
                  style: GoogleFonts.caveat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: EduColors.textSecondary,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // ── Bottom row ───────────────────────────────────────────
                Row(
                  children: [
                    _DateAnnotation(date: note.createdAt),
                    const Spacer(),
                    _SketchOpenButton(accent: accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Subject stamp ────────────────────────────────────────────────────────────

class _SubjectStamp extends StatelessWidget {
  const _SubjectStamp({required this.subject, required this.color});

  final String subject;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.55),
          width: 1.4,
        ),
      ),
      child: Text(
        subject,
        style: GoogleFonts.caveat(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Time annotation ──────────────────────────────────────────────────────────

class _TimeAnnotation extends StatelessWidget {
  const _TimeAnnotation({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_outlined,
            size: 13, color: EduColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          '$minutes min',
          style: GoogleFonts.caveat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: EduColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Date annotation ──────────────────────────────────────────────────────────

class _DateAnnotation extends StatelessWidget {
  const _DateAnnotation({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Text(
      '✎  $date',
      style: GoogleFonts.caveat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: EduColors.textSecondary,
      ),
    );
  }
}

// ── Sketch "Open" button ─────────────────────────────────────────────────────

class _SketchOpenButton extends StatelessWidget {
  const _SketchOpenButton({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent.withValues(alpha: 0.55),
          width: 1.3,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Read',
            style: GoogleFonts.caveat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_rounded,
              size: 13, color: Color(0xFF1A1A2E)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — paper-style card background
// ─────────────────────────────────────────────────────────────────────────────

class _NoteCardPainter extends CustomPainter {
  const _NoteCardPainter({required this.seed, required this.accent});

  final int seed;
  final Color accent;

  static const _paper = Color(0xFFFEFCF5);
  static const _ink   = Color(0xFF1A1A2E);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 14.0;

    // 1. Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 4, size.width - 2, size.height - 2),
        const Radius.circular(r),
      ),
      Paint()..color = const Color(0xFF1A1A2E).withValues(alpha: 0.07),
    );

    // 2. Paper fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(r),
      ),
      Paint()..color = _paper,
    );

    // 3. Ruled lines
    final ruled = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.09)
      ..strokeWidth = 0.6;
    const lineStep = 22.0;
    const leftMargin = 18.0;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(r),
    ));
    for (double y = lineStep + 12; y < size.height - 8; y += lineStep) {
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width - 8, y), ruled);
    }

    // 4. Left margin line (colored accent)
    canvas.drawLine(
      const Offset(leftMargin - 3, 8),
      Offset(leftMargin - 3, size.height - 8),
      Paint()
        ..color = accent.withValues(alpha: 0.45)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // 5. Wobbly ink border (two passes)
    final outer = _wobblyPath(size, r, seed, 0.5);
    canvas.drawPath(
      outer,
      Paint()
        ..color = _ink.withValues(alpha: 0.68)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final inner = _wobblyPath(size, r, seed + 13, 2.5);
    canvas.drawPath(
      inner,
      Paint()
        ..color = _ink.withValues(alpha: 0.12)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path _wobblyPath(Size size, double r, int seed, double inset) {
    final s = seed * 1.61;
    const amp = 1.0;
    double w(double phase) => amp * math.sin(s + phase);

    final l = inset, t = inset;
    final rw = size.width  - inset * 2;
    final rh = size.height - inset * 2;
    final cr = r * 0.70;

    return Path()
      ..moveTo(l + cr + w(0.0),  t + w(0.8))
      ..quadraticBezierTo(l + rw * 0.5 + w(1.8), t + w(3.0),
          l + rw - cr + w(3.8),  t + w(2.3))
      ..arcToPoint(Offset(l + rw + w(1.2), t + cr + w(0.6)),
          radius: Radius.circular(cr), clockwise: true)
      ..quadraticBezierTo(l + rw + w(2.0), t + rh * 0.5 + w(3.6),
          l + rw + w(0.9),        t + rh - cr + w(2.8))
      ..arcToPoint(Offset(l + rw - cr + w(3.1), t + rh + w(1.5)),
          radius: Radius.circular(cr), clockwise: true)
      ..quadraticBezierTo(l + rw * 0.5 + w(4.8), t + rh + w(2.5),
          l + cr + w(4.2),        t + rh + w(0.4))
      ..arcToPoint(Offset(l + w(1.9), t + rh - cr + w(1.1)),
          radius: Radius.circular(cr), clockwise: true)
      ..quadraticBezierTo(l + w(3.4), t + rh * 0.5 + w(4.2),
          l + w(1.4),             t + cr + w(4.8))
      ..arcToPoint(Offset(l + cr + w(0.0), t + w(0.8)),
          radius: Radius.circular(cr), clockwise: true)
      ..close();
  }

  @override
  bool shouldRepaint(_NoteCardPainter old) =>
      old.seed != seed || old.accent != accent;
}
