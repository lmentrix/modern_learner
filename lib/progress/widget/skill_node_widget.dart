import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/progress/model/progress_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tier palette
// ─────────────────────────────────────────────────────────────────────────────

Color tierInk(SkillTier tier) {
  switch (tier) {
    case SkillTier.beginner:     return const Color(0xFF059669);
    case SkillTier.intermediate: return const Color(0xFF7C3AED);
    case SkillTier.advanced:     return const Color(0xFFD97706);
    case SkillTier.master:       return const Color(0xFFEA580C);
  }
}

Color tierFill(SkillTier tier) {
  switch (tier) {
    case SkillTier.beginner:     return const Color(0xFFD1FAE5);
    case SkillTier.intermediate: return const Color(0xFFEDE9FE);
    case SkillTier.advanced:     return const Color(0xFFFEF3C7);
    case SkillTier.master:       return const Color(0xFFFFF0E9);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sketch node card
// ─────────────────────────────────────────────────────────────────────────────

class SkillNodeWidget extends StatefulWidget {
  const SkillNodeWidget({
    super.key,
    required this.node,
    required this.animate,
    this.tilt = 0.0,
    this.index = 0,
    this.onTap,
  });

  final SkillNode node;
  final bool animate;
  final double tilt;
  final int index;
  final VoidCallback? onTap;

  @override
  State<SkillNodeWidget> createState() => _SkillNodeWidgetState();
}

class _SkillNodeWidgetState extends State<SkillNodeWidget>
    with SingleTickerProviderStateMixin {
  // Nullable so hot-reload never hits LateInitializationError when the old
  // State object is reused before initState re-runs.
  AnimationController? _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.node.state == NodeState.unlocked ||
        widget.node.state == NodeState.inProgress) {
      _pulse!.repeat();
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final locked     = node.state == NodeState.locked;
    final unlocked   = node.state == NodeState.unlocked;
    final inProgress = node.state == NodeState.inProgress;
    final available  = node.state == NodeState.available;

    final ink  = locked ? const Color(0xFFB0BAC8) : tierInk(node.tier);
    final fill = locked ? const Color(0xFFF1F4F8) : tierFill(node.tier);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      opacity: locked ? 0.50 : 1.0,
      child: Transform.rotate(
        angle: widget.tilt,
        child: GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
          width: 92,
          height: 108,
          child: CustomPaint(
            painter: _SketchBorderPainter(
              inkColor:    ink,
              paperColor:  fill,
              strokeWidth: locked ? 1.2 : (inProgress ? 2.2 : 1.8),
              dashed:      locked,
              seed:        widget.index,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(
                children: [
                  // ── Icon in a sketched circle ─────────────────────────
                  _SketchIconBubble(
                    node:       node,
                    ink:        ink,
                    pulse:      _pulse,   // nullable — handled inside
                    locked:     locked,
                    unlocked:   unlocked,
                    inProgress: inProgress,
                  ),
                  const SizedBox(height: 4),

                  // ── Title ─────────────────────────────────────────────
                  Text(
                    node.title,
                    style: GoogleFonts.caveat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: locked
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1A1A2E),
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // ── XP badge ─────────────────────────────────────────
                  const SizedBox(height: 2),
                  _XpAnnotation(
                    node: node,
                    ink: ink,
                    unlocked: unlocked,
                    locked: locked,
                    available: available,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icon bubble
// ─────────────────────────────────────────────────────────────────────────────

class _SketchIconBubble extends StatelessWidget {
  const _SketchIconBubble({
    required this.node,
    required this.ink,
    required this.pulse,
    required this.locked,
    required this.unlocked,
    required this.inProgress,
  });

  final SkillNode node;
  final Color ink;
  final AnimationController? pulse;  // nullable — safe on hot reload
  final bool locked, unlocked, inProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated sketch circle behind icon
          if (pulse != null)
            AnimatedBuilder(
              animation: pulse!,
              builder: (context, _) => CustomPaint(
                size: const Size(46, 46),
                painter: _SketchCirclePainter(
                  color:   ink,
                  phase:   pulse!.value,
                  animate: unlocked || inProgress,
                ),
              ),
            )
          else
            CustomPaint(
              size: const Size(46, 46),
              painter: _SketchCirclePainter(
                color: ink, phase: 0, animate: false,
              ),
            ),

          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: locked
                  ? const Color(0xFFE2E8F0)
                  : ink.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconData(node.icon, fontFamily: 'MaterialIcons'),
              size: 18,
              color: locked ? const Color(0xFF94A3B8) : ink,
            ),
          ),

          // State badge
          Positioned(
            bottom: 0,
            right: 0,
            child: _StateBadge(
              locked: locked,
              unlocked: unlocked,
              inProgress: inProgress,
              ink: ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({
    required this.locked,
    required this.unlocked,
    required this.inProgress,
    required this.ink,
  });

  final bool locked, unlocked, inProgress;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    if (!locked && !unlocked && !inProgress) return const SizedBox.shrink();

    final (icon, color) = locked
        ? (Icons.lock_rounded, const Color(0xFF94A3B8))
        : inProgress
            ? (Icons.play_arrow_rounded, EduColors.primary)
            : (Icons.check_rounded, ink);

    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Icon(icon, size: 8, color: Colors.white),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// XP annotation (written like a pencil note)
// ─────────────────────────────────────────────────────────────────────────────

class _XpAnnotation extends StatelessWidget {
  const _XpAnnotation({
    required this.node,
    required this.ink,
    required this.unlocked,
    required this.locked,
    required this.available,
  });

  final SkillNode node;
  final Color ink;
  final bool unlocked, locked, available;

  @override
  Widget build(BuildContext context) {
    final label = unlocked
        ? '+${node.xpReward} XP'
        : '${node.requiredXp} XP';

    return Text(
      label,
      style: GoogleFonts.caveat(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: locked
            ? const Color(0xFFB0BAC8)
            : unlocked
                ? ink
                : ink.withValues(alpha: 0.60),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — wobbly ink border with paper fill
// ─────────────────────────────────────────────────────────────────────────────

class _SketchBorderPainter extends CustomPainter {
  const _SketchBorderPainter({
    required this.inkColor,
    required this.paperColor,
    required this.strokeWidth,
    required this.seed,
    this.dashed = false,
  });

  final Color inkColor;
  final Color paperColor;
  final double strokeWidth;
  final int seed;
  final bool dashed;

  static const _ink = Color(0xFF1A1A2E);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 13.0;

    // 1. Paper fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3),
        const Radius.circular(r),
      ),
      Paint()..color = paperColor,
    );

    final inkPaint = Paint()
      ..style     = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin= StrokeJoin.round
      ..strokeWidth = strokeWidth;

    if (dashed) {
      // 2a. Dashed border for locked nodes
      inkPaint.color = inkColor.withValues(alpha: 0.55);
      _drawDashedRRect(canvas, size, r, inkPaint);

      // Cross-hatch fill to signal locked
      _drawCrossHatch(canvas, size, r);
    } else {
      // 2b. Primary sketch line (outer)
      final outer = _wobblyPath(size, r, seed, 1.5);
      inkPaint.color = _ink.withValues(alpha: 0.75);
      canvas.drawPath(outer, inkPaint);

      // 3. Shadow line — slightly inset, lower opacity (double-pencil effect)
      final inner = _wobblyPath(size, r, seed + 11, 3.8);
      inkPaint
        ..color      = inkColor.withValues(alpha: 0.22)
        ..strokeWidth = strokeWidth * 0.55;
      canvas.drawPath(inner, inkPaint);

      // 4. Tier accent strip along the top
      _drawTopAccent(canvas, size, r);
    }
  }

  void _drawTopAccent(Canvas canvas, Size size, double r) {
    final path = Path()
      ..moveTo(r, 1.5)
      ..lineTo(size.width - r, 1.5)
      ..arcToPoint(
        Offset(size.width - 1.5, r),
        radius: const Radius.circular(13),
        clockwise: true,
      )
      ..lineTo(size.width - 1.5, r + 7)
      ..lineTo(1.5, r + 7)
      ..lineTo(1.5, r)
      ..arcToPoint(Offset(r, 1.5), radius: const Radius.circular(13), clockwise: true)
      ..close();
    canvas.drawPath(path, Paint()..color = inkColor.withValues(alpha: 0.18));
  }

  /// Build a rounded-rectangle path with tiny sine-based perturbations to
  /// simulate a hand-drawn line.
  Path _wobblyPath(Size size, double r, int seed, double inset) {
    final s = seed * 1.37;
    const amp = 1.2;

    double w(double phase) => amp * math.sin(s + phase);

    final l = inset, t = inset;
    final rw = size.width  - inset * 2;
    final rh = size.height - inset * 2;
    final cr = r * 0.78;

    return Path()
      // Start: top-left arc exit
      ..moveTo(l + cr + w(0.0), t + w(1.0))
      // Top edge — quadratic through midpoint with a hint of wobble
      ..quadraticBezierTo(
        l + rw * 0.50 + w(2.1), t + w(3.4),
        l + rw - cr + w(4.2),   t + w(2.7),
      )
      // Top-right corner
      ..arcToPoint(
        Offset(l + rw + w(1.5), t + cr + w(0.9)),
        radius: Radius.circular(cr), clockwise: true,
      )
      // Right edge
      ..quadraticBezierTo(
        l + rw + w(2.3), t + rh * 0.50 + w(4.0),
        l + rw + w(1.1), t + rh - cr + w(3.2),
      )
      // Bottom-right corner
      ..arcToPoint(
        Offset(l + rw - cr + w(3.5), t + rh + w(1.8)),
        radius: Radius.circular(cr), clockwise: true,
      )
      // Bottom edge
      ..quadraticBezierTo(
        l + rw * 0.50 + w(5.1), t + rh + w(2.9),
        l + cr + w(4.7),         t + rh + w(0.5),
      )
      // Bottom-left corner
      ..arcToPoint(
        Offset(l + w(2.2), t + rh - cr + w(1.3)),
        radius: Radius.circular(cr), clockwise: true,
      )
      // Left edge
      ..quadraticBezierTo(
        l + w(3.8), t + rh * 0.50 + w(4.6),
        l + w(1.6), t + cr + w(5.2),
      )
      // Top-left corner (close)
      ..arcToPoint(
        Offset(l + cr + w(0.0), t + w(1.0)),
        radius: Radius.circular(cr), clockwise: true,
      )
      ..close();
  }

  void _drawDashedRRect(Canvas canvas, Size size, double r, Paint paint) {
    final outline = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3),
        Radius.circular(r),
      ));
    const dash = 5.5;
    const gap  = 3.5;
    for (final m in outline.computeMetrics()) {
      var d = 0.0;
      var on = true;
      while (d < m.length) {
        final seg = on ? dash : gap;
        final next = (d + seg).clamp(0.0, m.length);
        if (on) canvas.drawPath(m.extractPath(d, next), paint);
        d += seg;
        on = !on;
      }
    }
  }

  void _drawCrossHatch(Canvas canvas, Size size, double r) {
    final hatch = Paint()
      ..color       = const Color(0xFF94A3B8).withValues(alpha: 0.12)
      ..strokeWidth = 0.8;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      Radius.circular(r),
    ));
    const step = 8.0;
    for (double d = -size.height; d < size.width + size.height; d += step) {
      canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), hatch);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SketchBorderPainter old) =>
      old.inkColor   != inkColor   ||
      old.paperColor != paperColor ||
      old.dashed     != dashed;
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — animated sketch circle for icon background
// ─────────────────────────────────────────────────────────────────────────────

class _SketchCirclePainter extends CustomPainter {
  const _SketchCirclePainter({
    required this.color,
    required this.phase,
    required this.animate,
  });

  final Color color;
  final double phase;
  final bool animate;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2 - 2;

    final paint = Paint()
      ..color       = color.withValues(alpha: animate ? 0.40 : 0.22)
      ..strokeWidth = animate ? 1.5 : 1.1
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    // Base circle
    canvas.drawCircle(Offset(cx, cy), r, paint);

    if (animate) {
      // Rotating arc overlay for the "alive" feel
      final arcPaint = Paint()
        ..color       = color.withValues(alpha: 0.55)
        ..strokeWidth = 1.8
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round;
      final startAngle = phase * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        math.pi * 0.55,
        false,
        arcPaint,
      );
      // Opposite dim arc
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle + math.pi,
        math.pi * 0.35,
        false,
        arcPaint..color = color.withValues(alpha: 0.22),
      );
    }
  }

  @override
  bool shouldRepaint(_SketchCirclePainter old) =>
      old.phase != phase || old.animate != animate;
}
