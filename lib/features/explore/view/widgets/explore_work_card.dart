import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_subject.dart';
import 'package:modern_learner_production/features/explore/view/widgets/explore_work_info.dart';
import 'package:modern_learner_production/features/explore/view/widgets/explore_work_thumbnail.dart';

class ExploreWorkCard extends StatelessWidget {
  const ExploreWorkCard({
    super.key,
    required this.work,
    required this.subjectEmoji,
    required this.accentColor,
  });

  final ExploreWork work;
  final String subjectEmoji;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExploreWorkThumbnail(emoji: subjectEmoji, accentColor: accentColor),
          const SizedBox(width: 14),
          Expanded(
            child: ExploreWorkInfo(work: work, accentColor: accentColor),
          ),
        ],
      ),
    );
  }
}
