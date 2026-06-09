import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_subject.dart';
import 'package:modern_learner_production/features/explore/utils/explore_utils.dart';

class LibrarySubjectSheetHeader extends StatelessWidget {
  const LibrarySubjectSheetHeader({super.key, required this.subject});

  final ExploreSubject subject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${subject.emoji} ${subject.name}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '${subject.category} · ${formatCount(subject.workCount)} works on OpenAlex',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (subject.description.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Text(
                    subject.description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: subject.accentColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              formatCount(subject.workCount),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: subject.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
