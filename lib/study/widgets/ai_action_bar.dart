import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class AiActionBar extends StatefulWidget {
  const AiActionBar({
    super.key,
    required this.selectedText,
    required this.onAction,
    required this.visible,
  });

  final String selectedText;
  final ValueChanged<AiAction> onAction;
  final bool visible;

  @override
  State<AiActionBar> createState() => _AiActionBarState();
}

class _AiActionBarState extends State<AiActionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.visible) _ctrl.forward();
  }

  @override
  void didUpdateWidget(AiActionBar old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible)  _ctrl.forward();
    if (!widget.visible && old.visible)  _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: EduSpacing.s6),
          child: CustomPaint(
            painter: _InkBarPainter(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: EduSpacing.s4, vertical: EduSpacing.s3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AiChip(
                    icon:  Icons.auto_awesome_rounded,
                    label: 'Explain',
                    onTap: () => widget.onAction(AiAction.explain),
                  ),
                  _SketchDivider(),
                  _AiChip(
                    icon:  Icons.image_outlined,
                    label: 'Imagine',
                    onTap: () => widget.onAction(AiAction.imagine),
                  ),
                  _SketchDivider(),
                  _AiChip(
                    icon:  Icons.edit_note_rounded,
                    label: 'Take note',
                    onTap: () => widget.onAction(AiAction.takeNote),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sketch divider ────────────────────────────────────────────────────────────

class _SketchDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WobblyLinePainter(),
      size: const Size(1.5, 28),
    );
  }
}

class _WobblyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width / 2, 0)
        ..quadraticBezierTo(
            size.width / 2 + 1.2, size.height * 0.5,
            size.width / 2,       size.height),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_WobblyLinePainter old) => false;
}

// ── AI chip ───────────────────────────────────────────────────────────────────

class _AiChip extends StatelessWidget {
  const _AiChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData  icon;
  final String    label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: EduColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.caveat(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CustomPainter — ink-dark bar with wobbly sketch border ────────────────────

class _InkBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const r = 16.0;

    // Dark ink fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(r),
      ),
      Paint()..color = const Color(0xFF1A1A2E),
    );

    // Subtle sketch border (lighter ink on dark background)
    canvas.drawPath(
      _wobblyPath(size, r),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  Path _wobblyPath(Size size, double r) {
    const inset = 1.5;
    const amp   = 0.8;
    const l = inset, t = inset;
    final rw = size.width  - inset * 2;
    final rh = size.height - inset * 2;
    final cr = r * 0.72;

    double w(double phase) => amp * math.sin(phase * 2.3);

    return Path()
      ..moveTo(l + cr,    t + w(0))
      ..quadraticBezierTo(l + rw * .5, t + w(1),   l + rw - cr, t + w(2))
      ..arcToPoint(Offset(l + rw, t + cr),
          radius: Radius.circular(cr), clockwise: true)
      ..quadraticBezierTo(l + rw, t + rh * .5, l + rw, t + rh - cr)
      ..arcToPoint(Offset(l + rw - cr, t + rh),
          radius: Radius.circular(cr), clockwise: true)
      ..quadraticBezierTo(l + rw * .5, t + rh + w(1), l + cr, t + rh + w(0))
      ..arcToPoint(Offset(l, t + rh - cr),
          radius: Radius.circular(cr), clockwise: true)
      ..quadraticBezierTo(l, t + rh * .5, l, t + cr)
      ..arcToPoint(Offset(l + cr, t + w(0)),
          radius: Radius.circular(cr), clockwise: true)
      ..close();
  }

  @override
  bool shouldRepaint(_InkBarPainter old) => false;
}
