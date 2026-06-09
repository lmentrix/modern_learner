import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_achievement_detail_sheet.dart';

class ProfileAchievementBadge extends StatelessWidget {
  ProfileAchievementBadge({required this.achievement, super.key});

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
      builder: (_) => ProfileAchievementDetailSheet(
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
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          if (courseCount > 1)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: _rarityColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.surfaceContainerLow,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'x$courseCount',
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
