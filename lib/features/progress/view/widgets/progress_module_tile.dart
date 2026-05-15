import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';

class ProgressModuleTile extends StatelessWidget {
  const ProgressModuleTile({super.key, required this.step});

  final ProgressModuleStep step;

  @override
  Widget build(BuildContext context) {
    final statusColor = step.isLocked
        ? AppColors.onSurfaceVariant
        : step.isCurrent
        ? step.toneColor
        : AppColors.tertiary;
    final statusLabel = step.isLocked
        ? 'Locked'
        : step.isCurrent
        ? 'Current focus'
        : 'Completed';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: step.isLocked ? 0.66 : 1,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: step.isCurrent
                ? step.toneColor.withValues(alpha: 0.38)
                : AppColors.outlineVariant.withValues(alpha: 0.14),
            width: step.isCurrent ? 1.4 : 1,
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
                    color: step.toneColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      step.icon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.eyebrow,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              step.detail,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: step.progress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(step.toneColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${(step.progress * 100).round()}% complete',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: step.isLocked
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  step.lessonCountLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  step.durationLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
