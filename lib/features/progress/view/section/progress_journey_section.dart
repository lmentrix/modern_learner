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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ProfileSectionLabel(text: 'ROADMAP'),
            if (isVip) ...[const Spacer(), _VipUnlockedBadge()],
          ],
        ),
        const SizedBox(height: 14),
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

class _VipUnlockedBadge extends StatelessWidget {
  _VipUnlockedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          SizedBox(width: 6),
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
