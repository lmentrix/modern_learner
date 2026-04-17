import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/domain/entities/achievement_entity.dart';

class AchievementsDetailPage extends StatelessWidget {
  const AchievementsDetailPage({super.key, required this.achievement});

  final AchievementEntity achievement;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHero(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 12),
                    _buildLevelProgressionCard(),
                    const SizedBox(height: 12),
                    _buildDescriptionCard(),
                    const SizedBox(height: 32),
                    _buildActionButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context) {
    final isLocked = achievement.isLocked;
    final displayColor = isLocked
        ? const Color(0xFF0E1020)
        : AchievementEntity.tierColor(achievement.currentLevel);

    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          // Background gradient
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
          // Radial glow for earned achievements
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
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      color: AppColors.onSurface,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Emoji container
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
              // Title
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
              // Tier pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    color: isLocked
                        ? AppColors.onSurfaceVariant
                        : displayColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Status card ────────────────────────────────────────────────────────────

  Widget _buildStatusCard() {
    final isLocked = achievement.isLocked;
    final tierColor = isLocked
        ? AppColors.onSurfaceVariant
        : AchievementEntity.tierColor(achievement.currentLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLocked
              ? AppColors.outlineVariant.withValues(alpha: 0.12)
              : tierColor.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isLocked
                  ? AppColors.surfaceContainerHighest
                  : tierColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isLocked ? Icons.lock_rounded : Icons.emoji_events_rounded,
              color: isLocked
                  ? AppColors.onSurfaceVariant.withValues(alpha: 0.55)
                  : tierColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLocked
                      ? 'Not Started'
                      : achievement.isMaxLevel
                          ? 'Fully Mastered! 🎉'
                          : '${AchievementEntity.tierName(achievement.currentLevel)} '
                              '${AchievementEntity.tierRoman(achievement.currentLevel)} Earned',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isLocked ? AppColors.onSurfaceVariant : tierColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLocked
                      ? 'Start learning to earn your first level!'
                      : achievement.isMaxLevel
                          ? 'You\'ve reached the Diamond tier. Legendary!'
                          : 'Keep going to reach '
                              '${AchievementEntity.tierName(achievement.currentLevel + 1)} '
                              '${AchievementEntity.tierRoman(achievement.currentLevel + 1)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Level progression card ─────────────────────────────────────────────────

  Widget _buildLevelProgressionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEVEL PROGRESSION',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (i) {
            final levelNum = i + 1;
            final isEarned = levelNum <= achievement.currentLevel;
            final isCurrent = levelNum == achievement.currentLevel;
            final isNext = levelNum == achievement.currentLevel + 1;
            final tierColor = AchievementEntity.tierColor(levelNum);
            final tierName = AchievementEntity.tierName(levelNum);
            final tierRoman = AchievementEntity.tierRoman(levelNum);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  // Level icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isEarned
                          ? tierColor.withValues(alpha: 0.18)
                          : AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isEarned
                            ? tierColor.withValues(alpha: 0.50)
                            : AppColors.outlineVariant.withValues(alpha: 0.20),
                        width: isCurrent ? 2.0 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tierRoman,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isEarned
                              ? tierColor
                              : AppColors.onSurfaceVariant
                                  .withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$tierName $tierRoman',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isEarned
                                    ? AppColors.onSurface
                                    : AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.45),
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tierColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CURRENT',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: tierColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          achievement.levelRequirements[i],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isEarned
                                ? AppColors.onSurfaceVariant
                                : AppColors.onSurfaceVariant
                                    .withValues(alpha: 0.35),
                          ),
                        ),
                        // Progress bar only for the next unearned level
                        if (isNext && !achievement.isMaxLevel) ...[
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: achievement.progressToNextLevel,
                              minHeight: 4,
                              backgroundColor:
                                  tierColor.withValues(alpha: 0.14),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(tierColor),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(achievement.progressToNextLevel * 100).toStringAsFixed(0)}% to $tierName $tierRoman',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: tierColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isEarned)
                    Icon(
                      Icons.check_circle_rounded,
                      color: tierColor,
                      size: 18,
                    )
                  else
                    Icon(
                      Icons.radio_button_unchecked_rounded,
                      color: AppColors.outlineVariant.withValues(alpha: 0.30),
                      size: 18,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Description card ───────────────────────────────────────────────────────

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW TO EARN',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            achievement.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurface,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action button ──────────────────────────────────────────────────────────

  Widget _buildActionButton(BuildContext context) {
    final isLocked = achievement.isLocked;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLocked
              ? AppColors.surfaceContainerHigh
              : AppColors.primary,
          foregroundColor: isLocked
              ? AppColors.onSurfaceVariant
              : const Color(0xFF1A1028),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isLocked
                ? BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  )
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Text(
          isLocked
              ? 'Start Learning!'
              : achievement.isMaxLevel
                  ? 'Legendary! 💎'
                  : 'Keep Going!',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
