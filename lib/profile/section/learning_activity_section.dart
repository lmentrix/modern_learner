import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:modern_learner_production/profile/widgets/activity_grid.dart';
import 'package:modern_learner_production/theme/theme.dart';

class LearningActivitySection extends StatefulWidget {
  const LearningActivitySection({
    super.key,
    required this.animate,
    required this.bestWeekDays,
    required this.thisWeekDays,
    required this.totalActiveDays,
    required this.activityDays,
    required this.weeksTracked,
    required this.todayActiveSeconds,
    required this.isTracking,
  });

  final bool animate;
  final int bestWeekDays;
  final int thisWeekDays;
  final int totalActiveDays;
  final List<ActivityDay> activityDays;
  final int weeksTracked;
  final int todayActiveSeconds;
  final bool isTracking;

  @override
  State<LearningActivitySection> createState() =>
      _LearningActivitySectionState();
}

class _LearningActivitySectionState extends State<LearningActivitySection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(LearningActivitySection old) {
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
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EduSpacing.pagePadding,
          child: Container(
            padding: EduSpacing.cardPadding,
            decoration: BoxDecoration(
              color: EduColors.surface,
              borderRadius: EduRadius.borderXl,
              boxShadow: EduColors.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 40% sketch: Caveat title + very subtle underline (alpha at 40% of normal)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Learning Activity',
                          style: GoogleFonts.caveat(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: EduColors.textPrimary,
                          ),
                        ),
                        CustomPaint(
                          painter: _LightAccentLine(),
                          size: const Size(130, 4),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: EduColors.primaryLight,
                        borderRadius: EduRadius.borderPill,
                        border: Border.all(
                          color: EduColors.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        '${widget.weeksTracked} week${widget.weeksTracked == 1 ? '' : 's'}',
                        style: GoogleFonts.caveat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: EduColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: EduSpacing.s4),
                _OnlineTimeStatus(
                  activeSeconds: widget.todayActiveSeconds,
                  isTracking: widget.isTracking,
                ),
                const SizedBox(height: EduSpacing.s5),
                ActivityGrid(
                  animate: widget.animate,
                  activityDays: widget.activityDays,
                ),
                const SizedBox(height: EduSpacing.s5),

                // Weekly summary pills
                Row(
                  children: [
                    _SummaryPill(
                      label: 'Best week',
                      value: '${widget.bestWeekDays} days',
                      color: EduColors.accentGreen,
                    ),
                    const SizedBox(width: EduSpacing.s2),
                    _SummaryPill(
                      label: 'This week',
                      value: '${widget.thisWeekDays} days',
                      color: EduColors.primaryLight,
                    ),
                    const SizedBox(width: EduSpacing.s2),
                    _SummaryPill(
                      label: 'Total days',
                      value: '${widget.totalActiveDays}',
                      color: EduColors.accentYellow,
                    ),
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

class _OnlineTimeStatus extends StatelessWidget {
  const _OnlineTimeStatus({
    required this.activeSeconds,
    required this.isTracking,
  });

  final int activeSeconds;
  final bool isTracking;

  @override
  Widget build(BuildContext context) {
    final hours = activeSeconds ~/ 3600;
    final minutes = (activeSeconds % 3600) ~/ 60;
    final seconds = activeSeconds % 60;
    final timeLabel = hours > 0
        ? '${hours}h ${minutes}m'
        : minutes > 0
        ? '${minutes}m ${seconds}s'
        : '${seconds}s';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EduSpacing.s3,
        vertical: EduSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: EduColors.primaryLight.withValues(alpha: 0.35),
        borderRadius: EduRadius.borderMd,
        border: Border.all(color: EduColors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: isTracking
                  ? const Color(0xFF10B981)
                  : EduColors.textSecondary,
              shape: BoxShape.circle,
              boxShadow: isTracking
                  ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: EduSpacing.s2),
          Expanded(
            child: Text(
              isTracking ? 'Online time is being recorded' : 'Tracking paused',
              style: GoogleFonts.caveat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: EduColors.textSecondary,
              ),
            ),
          ),
          Text(
            '$timeLabel today',
            style: GoogleFonts.caveat(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: EduColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: EduRadius.borderMd,
        ),
        child: Column(
          children: [
            // 40% sketch: Caveat for value, plain for label
            Text(
              value,
              style: GoogleFonts.caveat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: EduColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.caveat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: EduColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 40% sketch accent — only 16% opacity (40% of the normal 40% = ~16%)
class _LightAccentLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.6)
        ..quadraticBezierTo(
          size.width * 0.30,
          size.height * 0.1,
          size.width * 0.62,
          size.height * 0.7,
        )
        ..lineTo(size.width * 0.90, size.height * 0.3),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.16)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LightAccentLine old) => false;
}
