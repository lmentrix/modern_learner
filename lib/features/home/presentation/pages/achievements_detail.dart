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

  Widget _buildHero(BuildContext context) {
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
                    achievement.isLocked
                        ? const Color(0xFF0E1020)
                        : achievement.color.withValues(alpha: 0.28),
                    AppColors.surface,
                  ],
                ),
              ),
            ),
          ),
          // Radial glow for unlocked
          if (!achievement.isLocked)
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
                      achievement.color.withValues(alpha: 0.18),
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
              // Back button row
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
              const SizedBox(height: 12),
              // Large emoji container
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: achievement.isLocked
                      ? AppColors.surfaceContainerHighest
                      : achievement.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: achievement.isLocked
                        ? AppColors.outlineVariant.withValues(alpha: 0.15)
                        : achievement.color.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: achievement.isLocked
                      ? null
                      : [
                          BoxShadow(
                            color: achievement.color.withValues(alpha: 0.4),
                            blurRadius: 48,
                            spreadRadius: 4,
                          ),
                        ],
                ),
                child: Center(
                  child: Opacity(
                    opacity: achievement.isLocked ? 0.35 : 1.0,
                    child: Text(
                      achievement.emoji,
                      style: const TextStyle(fontSize: 54),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  achievement.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: achievement.isLocked
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: achievement.isLocked
                      ? AppColors.surfaceContainerHighest
                      : achievement.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: achievement.isLocked
                        ? AppColors.outlineVariant.withValues(alpha: 0.15)
                        : achievement.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  achievement.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: achievement.isLocked
                        ? AppColors.onSurfaceVariant
                        : achievement.color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.isLocked
              ? AppColors.outlineVariant.withValues(alpha: 0.12)
              : achievement.color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: achievement.isLocked
                  ? AppColors.surfaceContainerHighest
                  : achievement.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              achievement.isLocked
                  ? Icons.lock_rounded
                  : Icons.check_circle_rounded,
              color: achievement.isLocked
                  ? AppColors.onSurfaceVariant.withValues(alpha: 0.55)
                  : achievement.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.isLocked ? 'Locked' : 'Unlocked',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: achievement.isLocked
                        ? AppColors.onSurfaceVariant
                        : achievement.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.isLocked
                      ? 'Complete the requirements to unlock this.'
                      : 'You\'ve earned this achievement!',
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

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: achievement.isLocked
              ? AppColors.surfaceContainerHigh
              : AppColors.primary,
          foregroundColor: achievement.isLocked
              ? AppColors.onSurfaceVariant
              : const Color(0xFF1A1028),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: achievement.isLocked
                ? BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  )
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Text(
          achievement.isLocked ? 'Keep Learning!' : 'Awesome!',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
