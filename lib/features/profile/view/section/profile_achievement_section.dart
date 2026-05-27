import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/theme/app_text_styles.dart';
import 'package:modern_learner_production/features/achievement/data/achievemenet_data.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_section_label.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';

class ProfileAchievementSection extends StatelessWidget {
  const ProfileAchievementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: CourseXpService.instance.version,
      builder: (context, _, __) => ValueListenableBuilder<int>(
        valueListenable: CourseXpService.instance.totalExerciseXp,
        builder: (context, totalXp, _) {
          final achievements = _evaluateAchievements(totalXp);
          final unlocked = achievements.where((a) => a.isUnlocked).length;
          final progress =
              achievements.isEmpty ? 0.0 : unlocked / achievements.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileSectionLabel(text: 'ACHIEVEMENTS'),
              const SizedBox(height: 14),
              _AchievementProgressBar(
                unlocked: unlocked,
                total: achievements.length,
                progress: progress,
              ),
              const SizedBox(height: 16),
              _AchievementBadgeRow(achievements: achievements),
              const SizedBox(height: 20),
              const ProfileSectionLabel(text: 'COURSE XP'),
              const SizedBox(height: 14),
              _CourseXpList(totalXp: totalXp),
            ],
          );
        },
      ),
    );
  }

  List<Achievement> _evaluateAchievements(int totalXp) {
    final courseData = Map.fromEntries(
      CourseXpService.instance.courseNotifiers.entries
          .map((e) => MapEntry(e.key, e.value.value)),
    );
    return AchievementCatalogue.all.map((a) {
      final courses = _unlockedBy(a, courseData);
      return a.copyWith(unlockedByCourses: courses);
    }).toList();
  }

  List<String> _unlockedBy(Achievement a, Map<String, CourseXpData> courseData) {
    switch (a.type) {
      case AchievementType.xp:
        return courseData.entries
            .where((e) => e.value.exerciseXp >= a.requirement)
            .map((e) => e.key)
            .toList();
      case AchievementType.chapter:
        return courseData.entries
            .where((e) => e.value.chaptersUnlocked >= a.requirement)
            .map((e) => e.key)
            .toList();
      // streak / level / gems / lesson are account-wide — not per-course in profile view
      default:
        return [];
    }
  }
}

class _AchievementProgressBar extends StatelessWidget {
  const _AchievementProgressBar({
    required this.unlocked,
    required this.total,
    required this.progress,
  });

  final int unlocked;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$unlocked / $total unlocked',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadgeRow extends StatelessWidget {
  const _AchievementBadgeRow({required this.achievements});

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final a = achievements[index];
          return _AchievementBadge(achievement: a);
        },
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});

  final Achievement achievement;

  Color get _rarityColor => switch (achievement.rarity) {
        AchievementRarity.common => AppColors.onSurfaceVariant,
        AchievementRarity.rare => AppColors.secondary,
        AchievementRarity.epic => AppColors.primary,
        AchievementRarity.legendary => AppColors.tertiaryContainer,
      };

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AchievementDetailSheet(
        achievement: achievement,
        rarityColor: _rarityColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    final courseCount = achievement.unlockedByCourses
        .where((c) => c != 'global')
        .length;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 64,
            decoration: BoxDecoration(
              color: unlocked
                  ? _rarityColor.withValues(alpha: 0.10)
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unlocked
                    ? _rarityColor.withValues(alpha: 0.55)
                    : AppColors.outlineVariant,
                width: unlocked ? 1.5 : 1,
              ),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: _rarityColor.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievement.emoji,
                  style: TextStyle(
                    fontSize: 24,
                    color: unlocked ? null : Colors.white.withAlpha(50),
                  ),
                ),
                const SizedBox(height: 4),
                if (unlocked)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _rarityColor,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          // course-count badge (top-right corner)
          if (courseCount > 1)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: _rarityColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.surfaceContainerLow,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '×$courseCount',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Achievement detail bottom sheet ───────────────────────────────────────────

class _AchievementDetailSheet extends StatelessWidget {
  const _AchievementDetailSheet({
    required this.achievement,
    required this.rarityColor,
  });

  final Achievement achievement;
  final Color rarityColor;

  String get _rarityLabel => switch (achievement.rarity) {
        AchievementRarity.common => 'Common',
        AchievementRarity.rare => 'Rare',
        AchievementRarity.epic => 'Epic',
        AchievementRarity.legendary => 'Legendary',
      };

  String get _typeLabel => switch (achievement.type) {
        AchievementType.xp => 'XP',
        AchievementType.streak => 'Streak',
        AchievementType.level => 'Level',
        AchievementType.lesson => 'Lessons',
        AchievementType.chapter => 'Chapters',
        AchievementType.gems => 'Gems',
      };

  String _formatCourseKey(String key) {
    if (key == 'global') return 'Account';
    return key
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    final courses = achievement.unlockedByCourses;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: unlocked
              ? rarityColor.withValues(alpha: 0.35)
              : AppColors.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // emoji + title row
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? rarityColor.withValues(alpha: 0.12)
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: unlocked
                              ? rarityColor.withValues(alpha: 0.40)
                              : AppColors.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          achievement.emoji,
                          style: TextStyle(
                            fontSize: 28,
                            color: unlocked
                                ? null
                                : Colors.white.withAlpha(50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _Chip(
                                label: _rarityLabel,
                                color: rarityColor,
                              ),
                              const SizedBox(width: 6),
                              _Chip(
                                label: _typeLabel,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  achievement.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 14),

                // XP reward chip
                Row(
                  children: [
                    _Chip(
                      icon: Icons.auto_awesome_rounded,
                      label: '+${achievement.xpReward} XP reward',
                      color: AppColors.tertiaryContainer,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        rarityColor.withValues(alpha: 0.30),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // unlock status
                if (!unlocked) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Not yet unlocked',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Unlocked by',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: courses.map((courseKey) {
                      final isGlobal = courseKey == 'global';
                      return _Chip(
                        icon: isGlobal
                            ? Icons.person_outline_rounded
                            : Icons.school_outlined,
                        label: _formatCourseKey(courseKey),
                        color: isGlobal ? AppColors.tertiary : rarityColor,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Course colour palette (cycles by index) ───────────────────────────────────

const _kCourseColors = [
  AppColors.primary,
  AppColors.secondary,
  AppColors.tertiary,
  Color(0xFFFF9F43),
  Color(0xFF26C6DA),
  Color(0xFFCE93D8),
];

// ── Level thresholds (mirrors ProgressXpBar) ──────────────────────────────────

const _kThresholds = [0, 500, 1200, 2200, 3500, 5000, 7000, 10000];
const _kRankTitles = [
  'Starter',
  'Explorer',
  'Practitioner',
  'Achiever',
  'Expert',
  'Master',
  'Legend',
  'Grandmaster',
];

class _LevelInfo {
  const _LevelInfo({
    required this.level,
    required this.rank,
    required this.xpInLevel,
    required this.xpNeeded,
    required this.progress,
  });
  final int level;
  final String rank;
  final int xpInLevel;
  final int xpNeeded;
  final double progress;
}

_LevelInfo _computeLevel(int xp) {
  int level = 1;
  for (int i = 1; i < _kThresholds.length; i++) {
    if (xp >= _kThresholds[i]) {
      level = i + 1;
    } else {
      break;
    }
  }
  level = level.clamp(1, _kRankTitles.length);
  final floor = _kThresholds[level - 1];
  final ceil =
      level < _kThresholds.length ? _kThresholds[level] : _kThresholds.last + 5000;
  final xpInLevel = xp - floor;
  final xpNeeded = ceil - floor;
  return _LevelInfo(
    level: level,
    rank: _kRankTitles[level - 1],
    xpInLevel: xpInLevel,
    xpNeeded: xpNeeded,
    progress: (xpInLevel / xpNeeded).clamp(0.0, 1.0),
  );
}

// ── Course XP List ────────────────────────────────────────────────────────────

class _CourseXpList extends StatelessWidget {
  const _CourseXpList({required this.totalXp});

  final int totalXp;

  @override
  Widget build(BuildContext context) {
    final notifiers = CourseXpService.instance.courseNotifiers;

    if (notifiers.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(
              Icons.auto_awesome_outlined,
              color: AppColors.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete exercises to start tracking\ncourse XP',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    final entries = notifiers.entries.toList();
    return Column(
      children: [
        for (int i = 0; i < entries.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < entries.length - 1 ? 12 : 0),
            child: ValueListenableBuilder<CourseXpData>(
              valueListenable: entries[i].value,
              builder: (context, data, _) => _CourseXpCard(
                courseKey: entries[i].key,
                data: data,
                color: _kCourseColors[i % _kCourseColors.length],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Course XP Card (interactive, animated) ────────────────────────────────────

class _CourseXpCard extends StatefulWidget {
  const _CourseXpCard({
    required this.courseKey,
    required this.data,
    required this.color,
  });

  final String courseKey;
  final CourseXpData data;
  final Color color;

  @override
  State<_CourseXpCard> createState() => _CourseXpCardState();
}

class _CourseXpCardState extends State<_CourseXpCard> {
  bool _expanded = false;

  String get _label => widget.courseKey
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final xp = widget.data.exerciseXp;
    final info = _computeLevel(xp);

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
              // ── header row ───────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
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
                  // rank + course name
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
                  // total XP + chevron
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

              // ── animated gradient progress bar ───────────────────────────
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

              // ── expandable breakdown ─────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: _expanded
                    ? _CourseXpBreakdown(data: widget.data, color: color)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Expanded breakdown ────────────────────────────────────────────────────────

class _CourseXpBreakdown extends StatelessWidget {
  const _CourseXpBreakdown({required this.data, required this.color});

  final CourseXpData data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.35), Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _XpChip(
              icon: Icons.fitness_center_rounded,
              label: 'Exercise XP  ${data.exerciseXp}',
              color: color,
            ),
            _XpChip(
              icon: Icons.check_circle_outline_rounded,
              label: '${data.exercisesCompleted} exercises done',
              color: AppColors.tertiary,
            ),
            _XpChip(
              icon: Icons.layers_rounded,
              label: '${data.chaptersUnlocked} chapters unlocked',
              color: AppColors.secondary,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Shared XP chip ────────────────────────────────────────────────────────────

class _XpChip extends StatelessWidget {
  const _XpChip({
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
