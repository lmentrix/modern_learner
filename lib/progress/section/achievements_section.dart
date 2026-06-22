import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/progress/model/progress_models.dart';
import 'package:modern_learner_production/progress/widget/achievement_badge.dart';
import 'package:modern_learner_production/theme/theme.dart';

class AchievementsSection extends StatefulWidget {
  const AchievementsSection({
    super.key,
    required this.animate,
    required this.achievements,
    required this.currentXp,
  });

  final bool animate;
  final List<Achievement> achievements;
  final int currentXp;

  @override
  State<AchievementsSection> createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends State<AchievementsSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(AchievementsSection old) {
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
    final unlockedCount = widget.achievements
        .where((achievement) => achievement.unlocked)
        .length;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EduSpacing.pagePadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Achievements',
                        style: GoogleFonts.caveat(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: EduColors.textPrimary,
                        ),
                      ),
                      const CustomPaint(
                        painter: _SketchAccentLine(width: 100),
                        size: Size(100, 5),
                      ),
                    ],
                  ),
                  const SizedBox(width: EduSpacing.s2),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE68A).withValues(alpha: 0.4),
                      borderRadius: EduRadius.borderPill,
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '$unlockedCount/${widget.achievements.length}',
                      style: GoogleFonts.caveat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: EduSpacing.s4),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EduSpacing.pagePadding,
                itemCount: widget.achievements.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: EduSpacing.s3),
                itemBuilder: (context, i) => AchievementBadge(
                  achievement: widget.achievements[i],
                  currentXp: widget.currentXp,
                ),
              ),
            ),
          ],
        ),
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
        ..moveTo(0, size.height * 0.6)
        ..quadraticBezierTo(
          width * 0.30,
          size.height * 0.1,
          width * 0.62,
          size.height * 0.7,
        )
        ..lineTo(width * 0.90, size.height * 0.3),
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
