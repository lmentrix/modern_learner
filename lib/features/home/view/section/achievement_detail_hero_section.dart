import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';

class AchievementDetailHeroSection extends StatelessWidget {
  const AchievementDetailHeroSection({
    super.key,
    required this.achievement,
    required this.onBackTap,
  });

  final AchievementEntity achievement;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = achievement.isLocked;
    final displayColor = isLocked
        ? const Color(0xFF0E1020)
        : AchievementEntity.tierColor(achievement.currentLevel);

    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isLocked
                        ? const Color(0xFF0E1020)
                        : achievement.color.withValues(alpha: 0.28),
                    AppColors.surface,
                  ],
                ),
              ),
            ),
          ),
          if (!isLocked)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 220,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.2,
                    colors: [
                      displayColor.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBackTap,
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      color: AppColors.onSurface,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppColors.surfaceContainerHighest
                      : achievement.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isLocked
                        ? AppColors.outlineVariant.withValues(alpha: 0.15)
                        : displayColor.withValues(alpha: 0.50),
                    width: 1.5,
                  ),
                  boxShadow: isLocked
                      ? null
                      : [
                          BoxShadow(
                            color: displayColor.withValues(alpha: 0.40),
                            blurRadius: 48,
                            spreadRadius: 4,
                          ),
                        ],
                ),
                child: Center(
                  child: Opacity(
                    opacity: isLocked ? 0.35 : 1.0,
                    child: Text(
                      achievement.emoji,
                      style: const TextStyle(fontSize: 54),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  achievement.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isLocked
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppColors.surfaceContainerHighest
                      : displayColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isLocked
                        ? AppColors.outlineVariant.withValues(alpha: 0.15)
                        : displayColor.withValues(alpha: 0.40),
                  ),
                ),
                child: Text(
                  isLocked
                      ? 'Not Started'
                      : achievement.isMaxLevel
                      ? 'Diamond V · Max Level'
                      : '${AchievementEntity.tierName(achievement.currentLevel)} '
                            '${AchievementEntity.tierRoman(achievement.currentLevel)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isLocked ? AppColors.onSurfaceVariant : displayColor,
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
