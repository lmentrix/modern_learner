import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_section_label.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_data.dart';
import 'package:modern_learner_production/features/progress/service/model/chapter_subcontent_model.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_module_tile.dart';

class ProgressJourneySection extends StatelessWidget {
  const ProgressJourneySection({
    super.key,
    required this.data,
    required this.onChapterTap,
    this.isVip = false,
    this.selectedChapterId,
    this.chapterSubcontentResponse,
    this.isLoadingChapterSubcontent = false,
    this.isLoadingFromCache = false,
    this.chapterSubcontentError,
    this.onRetryTap,
    this.onSubcontentTap,
    this.completedSubcontentsInCurrentChapter = 0,
  });

  final ProgressPageData data;
  final ValueChanged<ProgressModuleStep> onChapterTap;
  final bool isVip;
  final String? selectedChapterId;
  final ChapterSubcontentResponseModel? chapterSubcontentResponse;
  final bool isLoadingChapterSubcontent;
  final bool isLoadingFromCache;
  final String? chapterSubcontentError;
  final VoidCallback? onRetryTap;
  final ValueChanged<ChapterSubcontentItemModel>? onSubcontentTap;
  final int completedSubcontentsInCurrentChapter;

  @override
  Widget build(BuildContext context) {
    final completed = data.moduleSteps
        .where((step) => !step.isLocked && step.progress >= 1)
        .length;
    final locked = data.moduleSteps.where((step) => step.isLocked).length;
    final active = data.moduleSteps.where((step) => step.isCurrent).length;
    final total = data.moduleSteps.length;
    final progress = total == 0 ? 0.0 : completed / total;
    final accent = data.snapshot.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ProfileSectionLabel(text: 'ROADMAP'),
            if (isVip) ...[const Spacer(), const _VipUnlockedBadge()],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'CHAPTER PATH 路 UNLOCKED EXERCISES',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.7,
          ),
        ),
        const SizedBox(height: 14),
        _RoadmapOverview(
          completed: completed,
          active: active,
          locked: locked,
          total: total,
          progress: progress,
          accent: accent,
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < data.moduleSteps.length; i++)
          ProgressModuleTile(
            step: data.moduleSteps[i],
            isSelected: data.moduleSteps[i].id == selectedChapterId,
            isLast: i == data.moduleSteps.length - 1,
            onTap: () => onChapterTap(data.moduleSteps[i]),
            chapterSubcontentResponse:
                data.moduleSteps[i].id == selectedChapterId
                ? chapterSubcontentResponse
                : null,
            isLoadingSubcontent:
                data.moduleSteps[i].id == selectedChapterId &&
                isLoadingChapterSubcontent,
            isLoadingFromCache:
                data.moduleSteps[i].id == selectedChapterId &&
                isLoadingFromCache,
            subcontentError: data.moduleSteps[i].id == selectedChapterId
                ? chapterSubcontentError
                : null,
            onRetrySubcontent: data.moduleSteps[i].id == selectedChapterId
                ? onRetryTap
                : null,
            onSubcontentTap: data.moduleSteps[i].id == selectedChapterId
                ? onSubcontentTap
                : null,
            completedSubcontents: data.moduleSteps[i].id == selectedChapterId
                ? completedSubcontentsInCurrentChapter
                : 0,
          ),
      ],
    );
  }
}

class _RoadmapOverview extends StatelessWidget {
  const _RoadmapOverview({
    required this.completed,
    required this.active,
    required this.locked,
    required this.total,
    required this.progress,
    required this.accent,
  });

  final int completed;
  final int active;
  final int locked;
  final int total;
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.18),
            AppColors.surfaceContainerLow,
            AppColors.surface.withValues(alpha: 0.90),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$completed of $total chapters complete',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OverviewChip(
                icon: Icons.play_circle_rounded,
                label: '$active active',
                color: accent,
              ),
              _OverviewChip(
                icon: Icons.check_circle_rounded,
                label: '$completed done',
                color: AppColors.tertiary,
              ),
              _OverviewChip(
                icon: Icons.lock_rounded,
                label: '$locked locked',
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewChip extends StatelessWidget {
  const _OverviewChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _VipUnlockedBadge extends StatelessWidget {
  const _VipUnlockedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 14,
            color: AppColors.tertiary,
          ),
          const SizedBox(width: 6),
          Text(
            'VIP · All unlocked',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
