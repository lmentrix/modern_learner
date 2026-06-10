import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_chip.dart';

class ProfileAchievementDetailSheet extends StatelessWidget {
  const ProfileAchievementDetailSheet({
    required this.achievement,
    required this.rarityColor,
    super.key,
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
                            color: unlocked ? null : Colors.white.withAlpha(50),
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
                              ProfileChip(
                                label: _rarityLabel,
                                color: rarityColor,
                              ),
                              const SizedBox(width: 6),
                              ProfileChip(
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
                Row(
                  children: [
                    ProfileChip(
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
                if (!unlocked) ...[
                  Row(
                    children: [
                      Icon(
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
                ] else if (courses.isEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: rarityColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Previously unlocked',
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
                      return ProfileChip(
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
