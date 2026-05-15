import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_section_label.dart';

class HomeContinueLearningHeaderSection extends StatelessWidget {
  const HomeContinueLearningHeaderSection({
    super.key,
    required this.onDeleteAllTap,
  });

  final VoidCallback onDeleteAllTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProgressCourseSelection>>(
      valueListenable: ExploreCoursesService.instance.courses,
      builder: (context, courses, _) {
        return Row(
          children: [
            const Expanded(child: HomeSectionLabel(text: 'CONTINUE LEARNING')),
            if (courses.isNotEmpty)
              TextButton.icon(
                onPressed: onDeleteAllTap,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                label: Text(
                  'Delete All',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
