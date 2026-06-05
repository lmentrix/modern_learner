import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/utils/responsive.dart';
import 'package:modern_learner_production/features/progress/bloc/xp_bloc.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_data.dart';

class ProgressHeaderSection extends StatelessWidget {
  const ProgressHeaderSection({super.key, required this.data});

  final ProgressPageData data;

  static const _xpPerChapter = 200;
  static const _thresholds = [0, 500, 1200, 2200, 3500, 5000, 7000, 10000];
  static const _ranks = [
    'Starter',
    'Explorer',
    'Practitioner',
    'Achiever',
    'Expert',
    'Master',
    'Legend',
    'Grandmaster',
  ];

  _LevelData _level(int xp) {
    int lvl = 1;
    for (int i = 1; i < _thresholds.length; i++) {
      if (xp >= _thresholds[i]) lvl = i + 1;
      else break;
    }
    lvl = lvl.clamp(1, _ranks.length);
    final floor = _thresholds[lvl - 1];
    final ceil = lvl < _thresholds.length ? _thresholds[lvl] : _thresholds.last + 5000;
    final inLevel = xp - floor;
    final needed = ceil - floor;
    return _LevelData(
      level: lvl,
      rank: _ranks[lvl - 1],
      totalXp: xp,
      xpInLevel: inLevel,
      xpNeeded: needed,
      progress: (inLevel / needed).clamp(0.0, 1.0),
    );
  }

  int _chapterXp(List<ProgressModuleStep> steps) =>
      steps.fold(0, (s, st) => s + (st.progress * _xpPerChapter).round());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<XpBloc, XpState>(
      builder: (context, xpState) {
        final course = data.course;
        final color = data.snapshot.accentColor;
        final isVoice = course.courseType == ProgressCourseType.voice;
        final chXp = _chapterXp(data.moduleSteps);
        final d = _level(chXp + xpState.totalXp);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Course identity card ───────────────────────────────────────
            _CourseCard(
              course: course,
              color: color,
              isVoice: isVoice,
              level: d.level,
              totalXp: d.totalXp,
            ),
            const SizedBox(height: 10),
            // ── XP progress card ───────────────────────────────────────────
            _XpProgressCard(d: d, color: color),
          ],
        );
      },
    );
  }
}

// ── Course identity card ──────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.color,
    required this.isVoice,
    required this.level,
    required this.totalXp,
  });

  final ProgressCourseSelection course;
  final Color color;
  final bool isVoice;
  final int level;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isTabletOrDesktop(context);
    final iconSize = isWide ? 52.0 : 44.0;
    final iconFontSize = isWide ? 26.0 : 22.0;
    final titleFontSize = isWide ? 18.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(isWide ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                isVoice ? '🎙️' : '📘',
                style: TextStyle(fontSize: iconFontSize),
              ),
            ),
          ),
          SizedBox(width: isWide ? 16 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      course.level,
                      style: GoogleFonts.inter(
                        fontSize: isWide ? 13.0 : 12.0,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isVoice ? 'VOICE' : 'SCHOOL',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.60)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'LVL $level',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: isWide ? 12.0 : 11.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$totalXp XP',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isWide ? 16.0 : 14.0,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── XP progress card ──────────────────────────────────────────────────────────

class _XpProgressCard extends StatelessWidget {
  const _XpProgressCard({required this.d, required this.color});

  final _LevelData d;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                d.rank,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                '${d.xpNeeded - d.xpInLevel} XP → LVL ${d.level + 1}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            key: ValueKey(d.totalXp),
            tween: Tween(begin: 0.0, end: d.progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      color: color.withValues(alpha: 0.12),
                    ),
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withValues(alpha: 0.70),
                              color,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.45),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 7),
          Text(
            '${d.xpInLevel} / ${d.xpNeeded} XP',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _LevelData {
  const _LevelData({
    required this.level,
    required this.rank,
    required this.totalXp,
    required this.xpInLevel,
    required this.xpNeeded,
    required this.progress,
  });

  final int level;
  final String rank;
  final int totalXp;
  final int xpInLevel;
  final int xpNeeded;
  final double progress;
}
