import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/bloc/xp_bloc.dart';
import 'package:modern_learner_production/features/progress/data/progress_course_snapshot.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';

class ProgressXpBar extends StatelessWidget {
  const ProgressXpBar({
    super.key,
    required this.snapshot,
    required this.courseTitle,
    required this.moduleSteps,
  });

  final ProgressCourseSnapshot snapshot;
  final String courseTitle;
  final List<ProgressModuleStep> moduleSteps;

  static const int _xpPerChapter = 200;

  static const List<int> _thresholds = [
    0,
    500,
    1200,
    2200,
    3500,
    5000,
    7000,
    10000,
  ];
  static const List<String> _rankTitles = [
    'Starter',
    'Explorer',
    'Practitioner',
    'Achiever',
    'Expert',
    'Master',
    'Legend',
    'Grandmaster',
  ];

  _LevelData _levelData(int xp) {
    int level = 1;
    for (int i = 1; i < _thresholds.length; i++) {
      if (xp >= _thresholds[i]) {
        level = i + 1;
      } else {
        break;
      }
    }
    level = level.clamp(1, _rankTitles.length);
    final floor = _thresholds[level - 1];
    final ceil = level < _thresholds.length
        ? _thresholds[level]
        : _thresholds.last + 5000;
    final xpInLevel = xp - floor;
    final xpNeeded = ceil - floor;
    return _LevelData(
      level: level,
      title: _rankTitles[level - 1],
      totalXp: xp,
      xpInLevel: xpInLevel,
      xpNeeded: xpNeeded,
      progress: (xpInLevel / xpNeeded).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<XpBloc, XpState>(
      builder: (context, xpState) => _buildContent(context, xpState),
    );
  }

  int _chapterXp() {
    return moduleSteps.fold(0, (sum, step) {
      return sum + (step.progress * _xpPerChapter).round();
    });
  }

  Widget _buildContent(BuildContext context, XpState xpState) {
    final totalXp = _chapterXp() + xpState.totalXp;
    final d = _levelData(totalXp);
    final color = snapshot.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── top row: level badge + rank + total XP ─────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.55)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.40),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'LVL ${d.level}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    courseTitle,
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
                  '${d.totalXp}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
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
          ],
        ),

        const SizedBox(height: 18),

        // ── animated XP bar ─────────────────────────────────────────────
        TweenAnimationBuilder<double>(
          key: ValueKey(d.totalXp),
          tween: Tween(begin: 0.0, end: d.progress),
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
                        height: 9,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          height: 9,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color.withValues(alpha: 0.65), color],
                            ),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.50),
                                blurRadius: 7,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${d.xpInLevel} / ${d.xpNeeded} XP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${d.xpNeeded - d.xpInLevel} XP to LVL ${d.level + 1}',
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

        const SizedBox(height: 14),

        // ── XP source breakdown chips ───────────────────────────────────
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _XpChip(
              icon: Icons.layers_rounded,
              label: 'Chapter XP ${_chapterXp()}',
              color: color,
            ),
            _XpChip(
              icon: Icons.fitness_center_rounded,
              label: 'Exercise XP ${xpState.totalXp}',
              color: Color(0xFFFF9F43),
            ),
            _XpChip(
              icon: Icons.trending_up_rounded,
              label: 'Level XP ${d.xpInLevel}/${d.xpNeeded}',
              color: AppColors.tertiary,
            ),
          ],
        ),
      ],
    );
  }
}

class _XpChip extends StatelessWidget {
  const _XpChip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
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

class _LevelData {
  const _LevelData({
    required this.level,
    required this.title,
    required this.totalXp,
    required this.xpInLevel,
    required this.xpNeeded,
    required this.progress,
  });

  final int level;
  final String title;
  final int totalXp;
  final int xpInLevel;
  final int xpNeeded;
  final double progress;
}
