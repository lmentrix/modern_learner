import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/theme/theme.dart';

class TranscriptCard extends StatefulWidget {
  const TranscriptCard({
    super.key,
    required this.text,
    required this.wordCount,
    required this.isLive,
  });

  final String text;
  final int wordCount;
  final bool isLive;

  @override
  State<TranscriptCard> createState() => _TranscriptCardState();
}

class _TranscriptCardState extends State<TranscriptCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cursorCtrl;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 580),
    );
    if (widget.isLive) _cursorCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(TranscriptCard old) {
    super.didUpdateWidget(old);
    if (widget.isLive && !_cursorCtrl.isAnimating) {
      _cursorCtrl.repeat(reverse: true);
    } else if (!widget.isLive && _cursorCtrl.isAnimating) {
      _cursorCtrl
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TranscriptCardSketch(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: EduColors.surface,
          borderRadius: EduRadius.borderXl,
          boxShadow: EduColors.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                if (widget.isLive) ...[
                  AnimatedBuilder(
                    animation: _cursorCtrl,
                    builder: (_, __) => Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEF4444).withValues(
                          alpha: 0.35 + _cursorCtrl.value * 0.65,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Live Transcript',
                    style: GoogleFonts.caveat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ] else
                  Text(
                    'Transcript',
                    style: GoogleFonts.caveat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: EduColors.textPrimary,
                    ),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: EduColors.primaryLight,
                    borderRadius: EduRadius.borderPill,
                  ),
                  child: Text(
                    '${widget.wordCount} words',
                    style: GoogleFonts.caveat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: EduColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: EduSpacing.s3),

            // Transcript text with blinking cursor
            AnimatedBuilder(
              animation: _cursorCtrl,
              builder: (_, __) {
                return RichText(
                  text: TextSpan(
                    style: GoogleFonts.caveat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: EduColors.textPrimary,
                      height: 1.55,
                    ),
                    children: [
                      TextSpan(text: widget.text),
                      if (widget.isLive)
                        TextSpan(
                          text: ' |',
                          style: GoogleFonts.caveat(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: EduColors.primary
                                .withValues(alpha: _cursorCtrl.value),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TranscriptCardSketch extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const r = 20.0;
    // Top-left corner sketch mark
    canvas.drawPath(
      Path()
        ..moveTo(r + 10, 1.8)
        ..quadraticBezierTo(r * 0.4, 1.2, 1.8, r + 10),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.22)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Bottom-right corner sketch mark
    canvas.drawPath(
      Path()
        ..moveTo(size.width - r - 10, size.height - 1.8)
        ..quadraticBezierTo(
          size.width - r * 0.4, size.height - 1.2,
          size.width - 1.8, size.height - r - 10,
        ),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.12)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TranscriptCardSketch old) => false;
}
