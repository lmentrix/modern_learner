import 'package:flutter/material.dart';

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
        const ProfileSectionLabel(text: 'ROADMAP'),
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
