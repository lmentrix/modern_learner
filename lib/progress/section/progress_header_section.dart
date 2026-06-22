import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/theme/theme.dart';

class ProgressHeaderSection extends StatefulWidget {
  const ProgressHeaderSection({
    super.key,
    required this.animate,
    required this.xp,
    required this.xpGoal,
    required this.level,
    required this.lessonsCompleted,
    required this.hoursStudied,
  });

  final bool animate;
  final int xp;
  final int xpGoal;
  final int level;
  final int lessonsCompleted;
  final int hoursStudied;

  @override
  State<ProgressHeaderSection> createState() => _ProgressHeaderSectionState();
}

class _ProgressHeaderSectionState extends State<ProgressHeaderSection>
    with TickerProviderStateMixin {
  late final AnimationController _xpCtrl;
  late final AnimationController _countCtrl;
  late final Animation<double> _xpFill;
  late final Animation<int> _xpCount;
  late final Animation<int> _lessonCount;
  late final Animation<int> _hoursCount;

  @override
  void initState() {
    super.initState();
    _xpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _xpFill = CurvedAnimation(parent: _xpCtrl, curve: Curves.easeOut);
    _xpCount = IntTween(
      begin: 0,
      end: widget.xp,
    ).animate(CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut));
    _lessonCount = IntTween(
      begin: 0,
      end: widget.lessonsCompleted,
    ).animate(CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut));
    _hoursCount = IntTween(
      begin: 0,
      end: widget.hoursStudied,
    ).animate(CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut));

    if (widget.animate) _start();
  }

  void _start() {
    _xpCtrl.forward();
    _countCtrl.forward();
  }

  @override
  void didUpdateWidget(ProgressHeaderSection old) {
    super.didUpdateWidget(old);
    if (!old.animate && widget.animate) _start();
  }

  @override
  void dispose() {
    _xpCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.xp / widget.xpGoal;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: EduSpacing.s6),
      padding: EduSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C5CFC), Color(0xFFA78BFA), Color(0xFFBDB4FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: EduRadius.borderXl,
        boxShadow: [
          BoxShadow(
            color: EduColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sketch scribble overlay — gives the card a hand-crafted feel
          Positioned.fill(
            child: ClipRRect(
              borderRadius: EduRadius.borderXl,
              child: CustomPaint(painter: _CardSketchOverlayPainter()),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${widget.level}',
                        style: GoogleFonts.caveat(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedBuilder(
                        animation: _xpCount,
                        builder: (context, _) => Text(
                          '${_xpCount.value} XP',
                          style: GoogleFonts.caveat(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Level badge — hand-inked circle
                  CustomPaint(
                    painter: _SketchCircleBadgePainter(),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: Text(
                          '${widget.level}',
                          style: GoogleFonts.caveat(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: EduSpacing.s4),

              // XP bar
              Text(
                '${widget.xp} / ${widget.xpGoal} XP to next level',
                style: GoogleFonts.caveat(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: EduSpacing.s2),
              LayoutBuilder(
                builder: (context, constraints) => AnimatedBuilder(
                  animation: _xpFill,
                  builder: (context, _) {
                    final w = constraints.maxWidth;
                    if (w <= 0) return const SizedBox(height: 8);
                    final filled = (w * pct * _xpFill.value).clamp(0.0, w);
                    return Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: EduRadius.borderPill,
                          ),
                        ),
                        Container(
                          height: 8,
                          width: filled < 4 ? 0 : filled,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: EduRadius.borderPill,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: EduSpacing.s5),

              // Stats row
              Row(
                children: [
                  _StatPill(
                    animation: _lessonCount,
                    suffix: ' lessons',
                    icon: Icons.menu_book_rounded,
                  ),
                  const SizedBox(width: EduSpacing.s3),
                  _StatPill(
                    animation: _hoursCount,
                    suffix: ' hours',
                    icon: Icons.schedule_rounded,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.animation,
    required this.suffix,
    required this.icon,
  });

  final Animation<int> animation;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: EduRadius.borderPill,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) => Text(
              '${animation.value}$suffix',
              style: GoogleFonts.caveat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sketch overlay — faint doodle lines on the card ─────────────────────────

class _CardSketchOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // A few wandering squiggle lines for texture
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.05, size.height * 0.15)
        ..quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.05,
          size.width * 0.45,
          size.height * 0.18,
        )
        ..quadraticBezierTo(
          size.width * 0.65,
          size.height * 0.30,
          size.width * 0.85,
          size.height * 0.12,
        ),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.10, size.height * 0.85)
        ..quadraticBezierTo(
          size.width * 0.35,
          size.height * 0.95,
          size.width * 0.60,
          size.height * 0.80,
        )
        ..quadraticBezierTo(
          size.width * 0.80,
          size.height * 0.70,
          size.width * 0.95,
          size.height * 0.88,
        ),
      paint,
    );

    // Small star doodle at top-right
    final cx = size.width - 20.0;
    const cy = 20.0;
    const r = 8.0;
    final inner = r * 0.42;
    final starPath = Path();
    for (var i = 0; i < 5; i++) {
      final outerAngle = -math.pi / 2 + i * 2 * math.pi / 5;
      final innerAngle = outerAngle + math.pi / 5;
      final px = cx + r * math.cos(outerAngle);
      final py = cy + r * math.sin(outerAngle);
      final ix = cx + inner * math.cos(innerAngle);
      final iy = cy + inner * math.sin(innerAngle);
      i == 0 ? starPath.moveTo(px, py) : starPath.lineTo(px, py);
      starPath.lineTo(ix, iy);
    }
    starPath.close();
    canvas.drawPath(
      starPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CardSketchOverlayPainter old) => false;
}

// ── Hand-inked circle badge ──────────────────────────────────────────────────

class _SketchCircleBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 26.0;

    // Outer ink ring with slight wobble (two overlapping arcs)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi * 0.55,
      math.pi * 1.85,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx + 0.8, cy - 0.8), radius: r - 2),
      math.pi * 0.80,
      math.pi * 0.60,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Faint fill
    canvas.drawCircle(
      Offset(cx, cy),
      r - 1,
      Paint()..color = Colors.white.withValues(alpha: 0.15),
    );
  }

  @override
  bool shouldRepaint(_SketchCircleBadgePainter old) => false;
}
