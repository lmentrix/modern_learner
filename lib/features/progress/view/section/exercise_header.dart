import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_constants.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_header_pill.dart';

class ExerciseHeader extends StatelessWidget {
  const ExerciseHeader({
    super.key,
    required this.detail,
    required this.accentColor,
    required this.checked,
    required this.score,
    required this.total,
    required this.onBack,
  });

  final ChapterExerciseDetailModel detail;
  final Color accentColor;
  final bool checked;
  final int score;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        gradient: ProfilePageConstants.headerGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              const Spacer(),
              ExerciseHeaderPill(
                label: checked && total > 0 ? '$score/$total' : 'Exercise',
                color: accentColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Chapter ${detail.chapterNumber}.${detail.subcontentNumber}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.62),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail.subcontentTitle,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail.chapterTitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}
