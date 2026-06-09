import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_subject.dart';
import 'package:modern_learner_production/features/explore/view/widgets/explore_work_card.dart';
import 'package:modern_learner_production/features/explore/view/widgets/library_subject_sheet_header.dart';

class LibrarySubjectSheet extends StatelessWidget {
  const LibrarySubjectSheet({super.key, required this.subject});

  final ExploreSubject subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: LibrarySubjectSheetHeader(subject: subject),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.separated(
                    itemCount: subject.works.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) => ExploreWorkCard(
                      work: subject.works[index],
                      subjectEmoji: subject.emoji,
                      accentColor: subject.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
