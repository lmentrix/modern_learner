import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_subject.dart';
import 'package:modern_learner_production/features/explore/utils/explore_utils.dart';
import 'package:modern_learner_production/features/explore/view/widgets/explore_work_detail_pill.dart';

class ExploreWorkInfo extends StatelessWidget {
  const ExploreWorkInfo({
    super.key,
    required this.work,
    required this.accentColor,
  });

  final ExploreWork work;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final sourceName = work.sourceName;
    final type = work.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          work.title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            height: 1.15,
          ),
        ),
        SizedBox(height: 6),
        Text(
          work.authors,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        if (sourceName != null && sourceName.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            sourceName,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (work.publicationYear != null)
              ExploreWorkDetailPill(
                label: '${work.publicationYear}',
                accentColor: accentColor,
              ),
            if (work.citationCount > 0)
              ExploreWorkDetailPill(
                label: '${formatCount(work.citationCount)} citations',
                accentColor: accentColor,
              ),
            if (type != null && type.isNotEmpty)
              ExploreWorkDetailPill(label: type, accentColor: accentColor),
            if (work.isOpenAccess)
              ExploreWorkDetailPill(
                label: 'Open access',
                accentColor: accentColor,
              ),
          ],
        ),
      ],
    );
  }
}
