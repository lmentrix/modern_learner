import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class StatChip extends StatefulWidget {
  const StatChip({super.key, required this.stat, required this.animate});

  final StatItem stat;
  final bool animate;

  @override
  State<StatChip> createState() => _StatChipState();
}

class _StatChipState extends State<StatChip> with TickerProviderStateMixin {
  late final AnimationController _countCtrl;
  late final AnimationController _logoCtrl;
  late final Animation<int> _count;
  late int _target;

  @override
  void initState() {
    super.initState();
    _target = _valueTarget(widget.stat.value);

    _countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _count = IntTween(
      begin: 0,
      end: _target,
    ).animate(CurvedAnimation(parent: _countCtrl, curve: Curves.easeOutCubic));
    if (widget.animate) {
      _countCtrl.forward();
      _logoCtrl.repeat();
    }
  }

  @override
  void didUpdateWidget(StatChip old) {
    super.didUpdateWidget(old);
    if (old.stat.value != widget.stat.value) {
      final nextTarget = _valueTarget(widget.stat.value);
      _count = IntTween(begin: _count.value, end: nextTarget).animate(
        CurvedAnimation(parent: _countCtrl, curve: Curves.easeOutCubic),
      );
      _target = nextTarget;
      _countCtrl
        ..reset()
        ..forward();
    } else if (!old.animate && widget.animate) {
      _countCtrl.forward();
    }
    if (widget.animate && !_logoCtrl.isAnimating) {
      _logoCtrl.repeat();
    }
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    _logoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Color(widget.stat.accentColor);
    final suffix = widget.stat.value.replaceAll(RegExp(r'[0-9]'), '');
    final mark = _StatMarkKind.fromLabel(widget.stat.label);

    return CustomPaint(
      painter: _SketchChipBorder(inkColor: bg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: EduColors.surface,
          borderRadius: EduRadius.borderXl,
          boxShadow: EduColors.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _logoCtrl,
              builder: (context, _) {
                final t = _logoCtrl.value;
                final bob = math.sin(t * math.pi * 2) * 1.5;
                final scale = mark == _StatMarkKind.streak
                    ? 1.0 + math.sin(t * math.pi * 4) * 0.025
                    : 1.0 + math.sin(t * math.pi * 2) * 0.012;
                return Transform.translate(
                  offset: Offset(0, bob),
                  child: Transform.scale(
                    scale: scale,
                    child: _SketchStatLogo(kind: mark, accent: bg, progress: t),
                  ),
                );
              },
            ),
            const SizedBox(height: EduSpacing.s3),
            AnimatedBuilder(
              animation: _count,
              builder: (context, _) => Text(
                '${_count.value}$suffix',
                style: GoogleFonts.caveat(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: EduColors.textPrimary,
                  height: 1.1,
                ),
              ),
            ),
            Text(
              widget.stat.label,
              style: GoogleFonts.caveat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: EduColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int _valueTarget(String value) {
    final raw = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
  }
}

enum _StatMarkKind {
  lessons,
  hours,
  notes,
  streak;

  static _StatMarkKind fromLabel(String label) => switch (label.toLowerCase()) {
    'lessons' => _StatMarkKind.lessons,
    'hours' => _StatMarkKind.hours,
    'notes' => _StatMarkKind.notes,
    'streak' => _StatMarkKind.streak,
    _ => _StatMarkKind.lessons,
  };
}

class _SketchStatLogo extends StatelessWidget {
  const _SketchStatLogo({
    required this.kind,
    required this.accent,
    required this.progress,
  });

  final _StatMarkKind kind;
  final Color accent;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _SketchStatLogoPainter(kind, accent, progress),
        ),
      ),
    );
  }
}

class _SketchStatLogoPainter extends CustomPainter {
  const _SketchStatLogoPainter(this.kind, this.accent, this.progress);

  final _StatMarkKind kind;
  final Color accent;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const ink = EduColors.textPrimary;
    final wash = Paint()
      ..color = accent.withValues(alpha: 0.74)
      ..style = PaintingStyle.fill;
    final line = Paint()
      ..color = ink.withValues(alpha: 0.84)
      ..strokeWidth = 1.9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final faint = Paint()
      ..color = ink.withValues(alpha: 0.20)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(15),
      ).shift(const Offset(0.2, -0.2)),
      wash,
    );
    canvas.drawPath(
      Path()
        ..moveTo(10, 3.5)
        ..quadraticBezierTo(3.5, 8, 4, 17)
        ..quadraticBezierTo(5, 33, 15, 38)
        ..quadraticBezierTo(29, 44, 38, 31),
      faint,
    );

    switch (kind) {
      case _StatMarkKind.lessons:
        _paintBook(canvas, line, faint);
      case _StatMarkKind.hours:
        _paintClock(canvas, line, faint);
      case _StatMarkKind.notes:
        _paintNote(canvas, line, faint);
      case _StatMarkKind.streak:
        _paintFire(canvas, line, faint);
    }
  }

  void _paintBook(Canvas canvas, Paint line, Paint faint) {
    canvas.drawPath(
      Path()
        ..moveTo(11, 13)
        ..quadraticBezierTo(16, 10, 21, 13)
        ..lineTo(21, 30)
        ..quadraticBezierTo(16, 27, 11, 30)
        ..close(),
      line,
    );
    canvas.drawPath(
      Path()
        ..moveTo(21, 13)
        ..quadraticBezierTo(27, 10, 32, 13)
        ..lineTo(32, 30)
        ..quadraticBezierTo(27, 27, 21, 30),
      line,
    );
    canvas.drawPath(
      Path()
        ..moveTo(15, 17)
        ..quadraticBezierTo(17, 16, 19, 17)
        ..moveTo(24, 17)
        ..quadraticBezierTo(27, 16, 29, 17)
        ..moveTo(24, 21)
        ..quadraticBezierTo(27, 20, 29, 21),
      faint,
    );
    _paintSpark(canvas, const Offset(31.5, 9.5), line.color);
  }

  void _paintClock(Canvas canvas, Paint line, Paint faint) {
    canvas.drawOval(
      Rect.fromCircle(center: const Offset(21, 22), radius: 11.3),
      line,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(21.5, 22), radius: 13.0),
      -0.9,
      1.25,
      false,
      faint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(21, 22)
        ..lineTo(21, 15)
        ..moveTo(21, 22)
        ..lineTo(27, 25.5),
      line,
    );
    canvas.drawPath(
      Path()
        ..moveTo(15, 9.5)
        ..lineTo(13, 6)
        ..moveTo(27, 9.5)
        ..lineTo(29, 6),
      line..strokeWidth = 1.5,
    );
  }

  void _paintNote(Canvas canvas, Paint line, Paint faint) {
    canvas.drawPath(
      Path()
        ..moveTo(13, 10)
        ..lineTo(28, 10)
        ..quadraticBezierTo(32, 13, 32, 17)
        ..lineTo(32, 31)
        ..quadraticBezierTo(24, 33, 12, 31)
        ..lineTo(12, 13)
        ..quadraticBezierTo(12, 11, 13, 10),
      line,
    );
    canvas.drawPath(
      Path()
        ..moveTo(27, 10)
        ..lineTo(27, 16)
        ..lineTo(32, 16),
      faint,
    );
    for (final y in [18.0, 23.0, 28.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(16, y)
          ..quadraticBezierTo(22, y - 1, 28, y),
        faint,
      );
    }
  }

  void _paintFire(Canvas canvas, Paint line, Paint faint) {
    final flicker = math.sin(progress * math.pi * 4) * 0.8;
    final outer = Path()
      ..moveTo(21.5, 34)
      ..cubicTo(13, 31, 10.5, 24, 14 + flicker * 0.2, 18)
      ..cubicTo(15.5, 15, 17, 13, 17.2, 9)
      ..cubicTo(22.2 + flicker, 12, 24, 15.5, 24, 19)
      ..cubicTo(26.5, 17.8, 28.1, 15.8, 28.8, 13.5)
      ..cubicTo(34, 21, 31.5 + flicker * 0.4, 31, 21.5, 34)
      ..close();
    final inner = Path()
      ..moveTo(21.5, 31)
      ..cubicTo(17.4, 29, 16.6, 25, 18.6, 21.8)
      ..cubicTo(19.7, 20.1, 20.8, 18.6, 20.8, 16.2)
      ..cubicTo(24.8, 19.3, 26.7, 25.6, 21.5, 31)
      ..close();

    canvas.drawPath(
      outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFB020), Color(0xFFFF7A45)],
        ).createShader(const Rect.fromLTWH(10, 8, 24, 28))
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      inner,
      Paint()
        ..color = const Color(0xFFFFF1A8).withValues(alpha: 0.88)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(outer, line);
    canvas.drawPath(inner, faint);
    canvas.drawPath(
      Path()
        ..moveTo(13, 34)
        ..quadraticBezierTo(21, 37, 30, 34),
      faint,
    );
    final emberPaint = Paint()
      ..color = const Color(0xFFFF7A45).withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final emberY = 11 + (1 - progress) * 8;
    canvas.drawCircle(Offset(13.5, emberY), 1.2, emberPaint);
    canvas.drawCircle(
      Offset(30.5, 15 + math.sin(progress * math.pi * 2) * 3),
      0.9,
      emberPaint,
    );
  }

  void _paintSpark(Canvas canvas, Offset center, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.58)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center.translate(0, -3.5), center.translate(0, 3.5), paint);
    canvas.drawLine(center.translate(-3.5, 0), center.translate(3.5, 0), paint);
  }

  @override
  bool shouldRepaint(_SketchStatLogoPainter old) =>
      old.kind != kind || old.accent != accent || old.progress != progress;
}

class _SketchChipBorder extends CustomPainter {
  const _SketchChipBorder({required this.inkColor});
  final Color inkColor;

  @override
  void paint(Canvas canvas, Size size) {
    const r = 16.0;
    // Tiny top-left accent corner that looks like a pencil mark
    canvas.drawPath(
      Path()
        ..moveTo(r + 4, 2)
        ..quadraticBezierTo(r * 0.5, 1.5, 2, r + 4),
      Paint()
        ..color = inkColor.withValues(alpha: 0.30)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Bottom-right accent
    canvas.drawPath(
      Path()
        ..moveTo(size.width - r - 4, size.height - 2)
        ..quadraticBezierTo(
          size.width - r * 0.5,
          size.height - 1.5,
          size.width - 2,
          size.height - r - 4,
        ),
      Paint()
        ..color = inkColor.withValues(alpha: 0.18)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SketchChipBorder old) => old.inkColor != inkColor;
}
