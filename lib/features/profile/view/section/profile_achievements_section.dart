import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/achievemenet/bloc/achievement_bloc.dart';
import 'package:modern_learner_production/features/achievemenet/model/achievement_model.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_section_label.dart';

class ProfileAchievementsSection extends StatelessWidget {
  const ProfileAchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        final achievements = _featuredAchievements(state.visibleAchievements);
        final summary = state.summary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileSectionLabel(text: 'ACHIEVEMENTS'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.tertiaryContainer,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${summary.unlocked}/${summary.total} unlocked',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${summary.totalXpRewarded} reward XP earned',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (summary.unseen > 0)
                        _UnseenBadge(count: summary.unseen)
                      else
                        IconButton(
                          tooltip: 'Refresh achievements',
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            context.read<AchievementBloc>().add(
                              const AchievementsLoadRequested(),
                            );
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 19,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: summary.unlockedRatio,
                      backgroundColor: AppColors.surfaceContainerHighest
                          .withValues(alpha: 0.55),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.tertiaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CategoryFilters(selectedCategory: state.selectedCategory),
                  const SizedBox(height: 14),
                  if (state.status == AchievementStatus.loading &&
                      state.achievements.isEmpty)
                    const _AchievementLoadingRows()
                  else if (achievements.isEmpty)
                    const _EmptyAchievementState()
                  else
                    Column(
                      children: [
                        for (
                          var index = 0;
                          index < achievements.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(height: 10),
                          _AchievementRow(achievement: achievements[index]),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<UserAchievement> _featuredAchievements(List<UserAchievement> items) {
    final sorted = [...items]
      ..sort((a, b) {
        if (a.isUnseen != b.isUnseen) return a.isUnseen ? -1 : 1;
        if (a.isUnlocked != b.isUnlocked) return a.isUnlocked ? -1 : 1;
        return b.completionRatio.compareTo(a.completionRatio);
      });
    return sorted.take(3).toList(growable: false);
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.selectedCategory});

  final AchievementCategory? selectedCategory;

  @override
  Widget build(BuildContext context) {
    const categories = [
      null,
      AchievementCategory.consistency,
      AchievementCategory.mastery,
      AchievementCategory.exploration,
      AchievementCategory.focus,
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return ChoiceChip(
            label: Text(_categoryLabel(category)),
            selected: isSelected,
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            onSelected: (_) {
              context.read<AchievementBloc>().add(
                AchievementCategoryChanged(category),
              );
            },
            labelStyle: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? const Color(0xFF10131D)
                  : AppColors.onSurfaceVariant,
            ),
            backgroundColor: AppColors.surfaceContainerHighest.withValues(
              alpha: 0.42,
            ),
            selectedColor: AppColors.tertiaryContainer,
            side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : AppColors.outlineVariant.withValues(alpha: 0.18),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }

  String _categoryLabel(AchievementCategory? category) {
    switch (category) {
      case null:
        return 'All';
      case AchievementCategory.consistency:
        return 'Consistency';
      case AchievementCategory.mastery:
        return 'Mastery';
      case AchievementCategory.exploration:
        return 'Explore';
      case AchievementCategory.focus:
        return 'Focus';
      case AchievementCategory.foundations:
        return 'Foundations';
      case AchievementCategory.creation:
        return 'Creation';
      case AchievementCategory.collaboration:
        return 'Social';
      case AchievementCategory.wellbeing:
        return 'Wellbeing';
      case AchievementCategory.challenge:
        return 'Challenge';
      case AchievementCategory.career:
        return 'Career';
    }
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.achievement});

  final UserAchievement achievement;

  @override
  Widget build(BuildContext context) {
    final definition = achievement.definition;
    final accent = Color(definition.colorHex);
    final progressPercent = (achievement.completionRatio * 100).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: achievement.isUnseen
            ? () {
                context.read<AchievementBloc>().add(
                  AchievementUnlockedSeen([definition.id]),
                );
              }
            : null,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: achievement.isUnseen
                  ? accent.withValues(alpha: 0.45)
                  : AppColors.outlineVariant.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _iconFor(definition.iconKey),
                  color: accent,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            definition.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _LevelPill(level: definition.level, color: accent),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      achievement.isUnlocked
                          ? 'Unlocked · +${definition.xpReward} XP'
                          : '${achievement.progress.progressValue}/${definition.target} · $progressPercent%',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        value: achievement.completionRatio,
                        backgroundColor: AppColors.surfaceContainerLow,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ],
                ),
              ),
              if (achievement.isUnseen) ...[
                const SizedBox(width: 10),
                const Icon(
                  Icons.fiber_new_rounded,
                  color: AppColors.tertiaryContainer,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'school':
        return Icons.school_rounded;
      case 'dumbbell':
        return Icons.fitness_center_rounded;
      case 'zap':
        return Icons.bolt_rounded;
      case 'timer':
        return Icons.timer_rounded;
      case 'calendar':
        return Icons.calendar_month_rounded;
      case 'flame':
        return Icons.local_fire_department_rounded;
      case 'compass':
        return Icons.explore_rounded;
      case 'badge-check':
        return Icons.verified_rounded;
      case 'map':
        return Icons.map_rounded;
      case 'target':
        return Icons.gps_fixed_rounded;
      case 'refresh-cw':
        return Icons.refresh_rounded;
      case 'notebook':
        return Icons.edit_note_rounded;
      case 'layers':
        return Icons.layers_rounded;
      case 'mic':
        return Icons.mic_rounded;
      case 'list-checks':
        return Icons.checklist_rounded;
      case 'sunrise':
        return Icons.wb_sunny_rounded;
      case 'moon':
        return Icons.dark_mode_rounded;
      case 'radar':
        return Icons.radar_rounded;
      case 'hammer':
        return Icons.construction_rounded;
      case 'user-cog':
        return Icons.manage_accounts_rounded;
      case 'share-2':
        return Icons.share_rounded;
      case 'rotate-ccw':
        return Icons.restart_alt_rounded;
      case 'trophy':
        return Icons.emoji_events_rounded;
      case 'bookmark':
        return Icons.bookmark_rounded;
      case 'repeat':
        return Icons.repeat_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.level, required this.color});

  final AchievementLevel level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        level.name.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _UnseenBadge extends StatelessWidget {
  const _UnseenBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.tertiaryContainer.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        '$count new',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.tertiaryContainer,
        ),
      ),
    );
  }
}

class _AchievementLoadingRows extends StatelessWidget {
  const _AchievementLoadingRows();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyAchievementState extends StatelessWidget {
  const _EmptyAchievementState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Start a lesson to begin unlocking achievements.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
