import 'package:flutter/material.dart';

import 'package:modern_learner_production/features/new_lesson/view/widgets/new_lesson_preview_card.dart';
import 'package:modern_learner_production/features/new_lesson/view/widgets/new_lesson_section_heading.dart';

class NewLessonPreviewSection extends StatelessWidget {
  const NewLessonPreviewSection({
    super.key,
    required this.selectedLanguage,
    required this.selectedDifficulty,
  });

  final String? selectedLanguage;
  final String selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NewLessonSectionHeading(
          eyebrow: 'PREVIEW',
          title: 'A roadmap before you commit',
          subtitle:
              'The lesson opens as a structured speaking track, not a blank slate. Use the preview to shape the tone and ambition.',
        ),
        const SizedBox(height: 18),
        NewLessonPreviewCard(
          selectedLanguage: selectedLanguage,
          selectedDifficulty: selectedDifficulty,
        ),
      ],
    );
  }
}
