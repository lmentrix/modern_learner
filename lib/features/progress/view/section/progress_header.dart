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
    var lvl = 1;
    for (var i = 1; i < _thresholds.length; i++) {
      if (xp >= _thresholds[i]) {
        lvl = i + 1;
      } else {
        break;
      }
    }
    lvl = lvl.clamp(1, _ranks.length);
    final floor = _thresholds[lvl - 1];
    final ceil = lvl < _thresholds.length
        ? _thresholds[lvl]
        : _thresholds.last + 5000;
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

  int _chapterXp(List<ProgressModuleStep> steps) => steps.fold(
    0,
    (sum, step) => sum + (step.progress * _xpPerChapter).round(),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<XpBloc, XpState>(
      builder: (context, xpState) {
        final course = data.course;
        final color = data.snapshot.accentColor;
        final isVoice = course.courseType == ProgressCourseType.voice;
        final chapterXp = _chapterXp(data.moduleSteps);
        final levelData = _level(chapterXp + xpState.totalXp);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideHeader = constraints.maxWidth >= 720;
            final courseCard = _CourseCard(
              course: course,
              color: color,
              isVoice: isVoice,
              level: levelData.level,
              totalXp: levelData.totalXp,
            );
            final xpCard = _XpProgressCard(data: levelData, color: color);

            if (isWideHeader) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: courseCard),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: xpCard),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [courseCard, const SizedBox(height: 10), xpCard],
            );
          },
        );
      },
    );
  }
}

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
    final iconSize = isWide ? 56.0 : 46.0;
    final titleFontSize = isWide ? 19.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(isWide ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.22),
            AppColors.surfaceContainerLow,
            AppColors.surface.withValues(alpha: 0.90),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Icon(
              isVoice ? Icons.mic_rounded : Icons.school_rounded,
              color: color,
              size: isWide ? 27 : 23,
            ),
          ),
          SizedBox(width: isWide ? 16 : 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MetaChip(label: course.level, color: AppColors.secondary),
                    _MetaChip(
                      label: isVoice ? 'Voice' : 'School',
                      color: color,
                    ),
                    _MetaChip(
                      label: course.roadmapLanguage,
                      color: AppColors.tertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, AppColors.tertiary.withValues(alpha: 0.78)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'LVL $level',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: isWide ? 12.0 : 11.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.surfaceContainerLowest,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  '$totalXp XP',
                  key: ValueKey(totalXp),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: isWide ? 16.0 : 14.0,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1,
        ),
      ),
    );
  }
}

class _XpProgressCard extends StatelessWidget {
  const _XpProgressCard({required this.data, required this.color});

  final _LevelData data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            AppColors.surfaceContainerLow,
            AppColors.surface.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(Icons.auto_graph_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.rank,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.xpNeeded - data.xpInLevel} XP to LVL ${data.level + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            key: ValueKey(data.totalXp),
            tween: Tween(begin: 0, end: data.progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Stack(
                  children: [
                    Container(height: 9, color: color.withValues(alpha: 0.12)),
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 9,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withValues(alpha: 0.68),
                              color,
                              AppColors.tertiary.withValues(alpha: 0.80),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${data.xpInLevel} / ${data.xpNeeded} XP',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
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
