import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class ProgressAchievementCard extends StatefulWidget {
  const ProgressAchievementCard({
    super.key,
    required this.course,
    this.isSelected = false,
    this.onTap,
  });

  final ProgressCourseSelection course;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  State<ProgressAchievementCard> createState() =>
      _ProgressAchievementCardState();
}

class _ProgressAchievementCardState extends State<ProgressAchievementCard> {
  double get _levelFactor {
    switch (widget.course.level.toLowerCase().trim()) {
      case 'beginner':
        return 0.24;
      case 'advanced':
        return 0.82;
      default:
        return 0.56;
    }
  }

  double get _completion =>
      (0.18 + _levelFactor * 0.76).clamp(0.18, 0.94);

  int get _estimatedLessons =>
      (8 + (_levelFactor * 16)).round();

  int get _masteredLessons =>
      (_estimatedLessons * (0.34 + _levelFactor * 0.42)).round();

  int get _streakDays => (6 + (_levelFactor * 10)).round();

  int get _totalHours =>
      (_estimatedLessons * 0.55 + _levelFactor * 2.4).round();

  int get _totalXp =>
      _masteredLessons * 50 + _streakDays * 25 + _totalHours * 15;

  Color get _accent =>
      widget.course.courseType == ProgressCourseType.voice
          ? AppColors.primary
          : AppColors.secondary;

  static const List<int> _thresholds = [
    0, 500, 1200, 2200, 3500, 5000, 7000, 10000,
  ];
  static const List<String> _rankTitles = [
    'Starter', 'Explorer', 'Practitioner', 'Achiever',
    'Expert', 'Master', 'Legend', 'Grandmaster',
  ];

  String get _rankTitle {
    final xp = _totalXp;
    int level = 1;
    for (int i = 1; i < _thresholds.length; i++) {
      if (xp >= _thresholds[i]) {
        level = i + 1;
      } else {
        break;
      }
    }
    return _rankTitles[level.clamp(1, _rankTitles.length) - 1];
  }

  @override
  Widget build(BuildContext context) {
    final color = _accent;
    final completion = _completion;
    final isSelected = widget.isSelected;

    return GestureDetector(
      onTap: widget.onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // ── circular progress ring ────────────────────────────────────
            TweenAnimationBuilder<double>(
              key: ValueKey(widget.course.title),
              tween: Tween(begin: 0.0, end: completion),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 5.5,
                        backgroundColor: color.withValues(alpha: 0.14),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(value * 100).round()}%',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: color,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'done',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 16),
            // ── course info ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // type badge + level + rank
                  Row(
                    children: [
                      _Badge(
                        label: widget.course.courseType.badgeLabel,
                        color: color,
                      ),
                      const SizedBox(width: 6),
                      _Badge(
                        label: widget.course.level.toUpperCase(),
                        color: AppColors.onSurfaceVariant,
                        outlined: true,
                      ),
                      const Spacer(),
                      Text(
                        _rankTitle,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color.withValues(alpha: 0.80),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  // title
                  Text(
                    widget.course.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.course.topic,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // stat pills
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _StatPill(
                        icon: Icons.local_fire_department_rounded,
                        label: '${_streakDays}d streak',
                        color: const Color(0xFFFF9F43),
                      ),
                      _StatPill(
                        icon: Icons.menu_book_rounded,
                        label: '$_masteredLessons / $_estimatedLessons lessons',
                        color: color,
                      ),
                      _StatPill(
                        icon: Icons.auto_awesome_rounded,
                        label: '$_totalXp XP',
                        color: AppColors.tertiary,
                      ),
                    ],
                  ),
                  // expanded: extra detail when selected
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    child: isSelected
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _ExpandedStats(
                              masteredLessons: _masteredLessons,
                              totalLessons: _estimatedLessons,
                              totalHours: _totalHours,
                              completion: completion,
                              accent: color,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }
}

// ── Expanded stats (shown when card is selected) ──────────────────────────────

class _ExpandedStats extends StatelessWidget {
  const _ExpandedStats({
    required this.masteredLessons,
    required this.totalLessons,
    required this.totalHours,
    required this.completion,
    required this.accent,
  });

  final int masteredLessons;
  final int totalLessons;
  final int totalHours;
  final double completion;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
          _MiniStat(
            value: '$masteredLessons',
            label: 'mastered',
            color: accent,
          ),
          _Divider(),
          _MiniStat(
            value: '$totalHours h',
            label: 'deep work',
            color: AppColors.tertiary,
          ),
          _Divider(),
          _MiniStat(
            value: '${(completion * 100).round()}%',
            label: 'complete',
            color: const Color(0xFFFF9F43),
          ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.outlineVariant.withValues(alpha: 0.35),
    );
  }
}

// ── Small shared helpers ──────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: outlined
            ? Border.all(color: color.withValues(alpha: 0.35))
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
