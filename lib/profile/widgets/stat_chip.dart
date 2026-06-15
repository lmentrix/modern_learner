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

class _StatChipState extends State<StatChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<int> _count;

  @override
  void initState() {
    super.initState();
    final raw = widget.stat.value.replaceAll(RegExp(r'[^0-9]'), '');
    final target = int.tryParse(raw) ?? 0;

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _count = IntTween(begin: 0, end: target)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(StatChip old) {
    super.didUpdateWidget(old);
    if (!old.animate && widget.animate) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Color(widget.stat.accentColor);
    final suffix = widget.stat.value.replaceAll(RegExp(r'[0-9]'), '');

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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: bg, borderRadius: EduRadius.borderMd),
              child: Icon(
                IconData(widget.stat.icon, fontFamily: 'MaterialIcons'),
                size: 18,
                color: EduColors.textPrimary,
              ),
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
            size.width - r * 0.5, size.height - 1.5,
            size.width - 2, size.height - r - 4),
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
