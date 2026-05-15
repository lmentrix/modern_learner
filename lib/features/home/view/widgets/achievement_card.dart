import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';

class AchievementCard extends StatefulWidget {
  const AchievementCard({
    super.key,
    required this.achievement,
    required this.onTap,
  });

  final AchievementEntity achievement;
  final VoidCallback onTap;

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      value: 1.0,
    );
    _scale = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievement;
    final isLocked = achievement.isLocked;
    final color = achievement.color;
    final tierColor = isLocked
        ? AppColors.outlineVariant
        : AchievementEntity.tierColor(achievement.currentLevel);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: isLocked
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surfaceContainerLow,
                      AppColors.surfaceContainerHigh,
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.18),
                      AppColors.surfaceContainerLow,
                      AppColors.surface.withValues(alpha: 0.9),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isLocked
                  ? AppColors.outlineVariant.withValues(alpha: 0.15)
                  : color.withValues(alpha: 0.32),
            ),
            boxShadow: isLocked
                ? []
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.16),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? AppColors.surfaceContainerHighest
                          : color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isLocked
                          ? null
                          : [
                              BoxShadow(
                                color: color.withValues(alpha: 0.30),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: isLocked ? 0.30 : 1.0,
                        child: Text(
                          achievement.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final earned = index < achievement.currentLevel;
                          return Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(left: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: earned
                                  ? AchievementEntity.tierColor(index + 1)
                                  : AppColors.outlineVariant.withValues(
                                      alpha: 0.25,
                                    ),
                            ),
                          );
                        }),
                      ),
                      if (!isLocked) ...[
                        const SizedBox(height: 4),
                        Text(
                          achievement.isMaxLevel
                              ? 'MAX'
                              : AchievementEntity.tierName(
                                  achievement.currentLevel,
                                ),
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: tierColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                achievement.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isLocked
                      ? AppColors.onSurfaceVariant.withValues(alpha: 0.40)
                      : AppColors.onSurface,
                  height: 1.15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppColors.surfaceContainerHighest
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isLocked
                      ? achievement.levelRequirements[0]
                      : achievement.isMaxLevel
                      ? 'Diamond V · Max'
                      : '${AchievementEntity.tierName(achievement.currentLevel)} ${AchievementEntity.tierRoman(achievement.currentLevel)}',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isLocked
                        ? AppColors.onSurfaceVariant.withValues(alpha: 0.35)
                        : tierColor,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isLocked && !achievement.isMaxLevel) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: achievement.progressToNextLevel,
                    minHeight: 3,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AchievementEntity.tierColor(achievement.currentLevel + 1),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
