import 'package:flutter/material.dart';
import 'package:modern_learner_production/progress/model/progress_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({super.key, required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final locked = !achievement.unlocked;
    final bg = Color(achievement.rarityColor);

    return Opacity(
      opacity: locked ? 0.4 : 1.0,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: locked ? EduColors.surface : bg.withValues(alpha: 0.18),
          borderRadius: EduRadius.borderXl,
          border: Border.all(
            color: locked ? EduColors.border : bg.withValues(alpha: 0.5),
            width: locked ? 1 : 1.5,
          ),
          boxShadow: locked
              ? null
              : [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: locked ? EduColors.border : bg,
                shape: BoxShape.circle,
              ),
              child: locked
                  ? const Icon(Icons.lock_rounded, size: 22, color: EduColors.textSecondary)
                  : Icon(
                      IconData(achievement.icon, fontFamily: 'MaterialIcons'),
                      size: 22,
                      color: EduColors.textPrimary,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: tt.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: locked ? EduColors.textSecondary : EduColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!locked) ...[
              const SizedBox(height: 4),
              Text(
                achievement.unlockedDate,
                style: tt.labelSmall?.copyWith(color: EduColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
