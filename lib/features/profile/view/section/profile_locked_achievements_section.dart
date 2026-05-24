import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/achievemenet/bloc/achievement_bloc.dart';
import 'package:modern_learner_production/features/achievemenet/model/achievement_model.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_section_label.dart';

class ProfileLockedAchievementsSection extends StatelessWidget {
  const ProfileLockedAchievementsSection({super.key});

  static const _collapsedCount = 3;
  static const _expandedCount = 16;
  static final ValueNotifier<bool> _showMoreNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        final locked = _sortedLocked(
          state.achievements
              .where((achievement) => !achievement.isUnlocked)
              .toList(growable: false),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileSectionLabel(text: 'LOCKED ACHIEVEMENTS'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
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
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${locked.length} still locked',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        '${state.summary.unlocked}/${state.summary.total}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (state.status == AchievementStatus.loading &&
                      state.achievements.isEmpty)
                    const _LockedLoadingStrip()
                  else if (locked.isEmpty)
                    const _AllUnlockedMessage()
                  else
                    ValueListenableBuilder<bool>(
                      valueListenable: _showMoreNotifier,
                      builder: (context, showMore, _) {
                        final visibleLocked = locked
                            .take(showMore ? _expandedCount : _collapsedCount)
                            .toList(growable: false);

                        return Column(
                          children: [
                            for (
                              var index = 0;
                              index < visibleLocked.length;
                              index++
                            )
                              Padding(
                                padding: EdgeInsets.only(
                                  top: index == 0 ? 0 : 10,
                                ),
                                child: _LockedAchievementCard(
                                  achievement: visibleLocked[index],
                                ),
                              ),
                            if (locked.length > _collapsedCount) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showMoreNotifier.value = !showMore;
                                  },
                                  icon: Icon(
                                    showMore
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.lock_open_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    showMore
                                        ? 'Show fewer'
                                        : _moreLabel(locked.length),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.onSurfaceVariant,
                                    side: BorderSide(
                                      color: AppColors.outlineVariant
                                          .withValues(alpha: 0.22),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    textStyle: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<UserAchievement> _sortedLocked(List<UserAchievement> achievements) {
    final sorted = [...achievements]
      ..sort((a, b) {
        final progressCompare = b.completionRatio.compareTo(a.completionRatio);
        if (progressCompare != 0) return progressCompare;
        final levelCompare = a.definition.level.index.compareTo(
          b.definition.level.index,
        );
        if (levelCompare != 0) return levelCompare;
        return a.definition.target.compareTo(b.definition.target);
      });
    return sorted;
  }

  String _moreLabel(int lockedCount) {
    final nextCount = (lockedCount - _collapsedCount).clamp(
      0,
      _expandedCount - _collapsedCount,
    );
    if (nextCount == 0) return 'Show more locked';
    return 'Show $nextCount more locked';
  }
}

class _LockedAchievementCard extends StatelessWidget {
  const _LockedAchievementCard({required this.achievement});

  final UserAchievement achievement;

  @override
  Widget build(BuildContext context) {
    final definition = achievement.definition;
    final accent = Color(definition.colorHex);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_iconFor(definition.iconKey), color: accent, size: 21),
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
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.lock_rounded,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.68),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  definition.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    height: 1.25,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    value: achievement.completionRatio,
                    backgroundColor: AppColors.surfaceContainerLow,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${achievement.progress.progressValue}/${definition.target}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _LockedLoadingStrip extends StatelessWidget {
  const _LockedLoadingStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 142,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return Container(
            width: 172,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(18),
            ),
          );
        },
      ),
    );
  }
}

class _AllUnlockedMessage extends StatelessWidget {
  const _AllUnlockedMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Every achievement is unlocked.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.tertiaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
