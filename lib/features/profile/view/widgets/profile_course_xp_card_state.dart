import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_course_level_utils.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_course_xp_breakdown.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_course_xp_card.dart';

class ProfileCourseXpCardState extends State<ProfileCourseXpCard> {
  bool _expanded = false;

  String get _label {
    final title = widget.data.courseTitle;
    if (title != null && title.isNotEmpty) return title;
    // Fallback: parse the composite course_key for legacy rows without course_id.
    final parts = widget.data.courseKey.split('::');
    return parts.isNotEmpty ? parts.first : widget.data.courseKey;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final xp = widget.data.exerciseXp;
    final info = computeProfileCourseLevel(xp);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _expanded
              ? color.withValues(alpha: 0.06)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _expanded
                ? color.withValues(alpha: 0.50)
                : color.withValues(alpha: 0.20),
            width: _expanded ? 1.5 : 1,
          ),
          boxShadow: _expanded
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.55)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.38),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'LVL ${info.level}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.rank,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          _label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$xp',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: color,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'course XP',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: color,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TweenAnimationBuilder<double>(
                key: ValueKey(xp),
                tween: Tween(begin: 0.0, end: info.progress),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Stack(
                          children: [
                            Container(
                              height: 8,
                              width: double.infinity,
                              color: color.withValues(alpha: 0.12),
                            ),
                            FractionallySizedBox(
                              widthFactor: value,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color.withValues(alpha: 0.65),
                                      color,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.50),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${info.xpInLevel} / ${info.xpNeeded} XP',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${info.xpNeeded - info.xpInLevel} XP to LVL ${info.level + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: _expanded
                    ? ProfileCourseXpBreakdown(data: widget.data, color: color)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
