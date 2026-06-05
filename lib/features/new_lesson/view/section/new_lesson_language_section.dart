import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/utils/responsive.dart';
import 'package:modern_learner_production/features/new_lesson/data/new_lesson_option_item.dart';
import 'package:modern_learner_production/features/new_lesson/view/widgets/new_lesson_language_tile.dart';
import 'package:modern_learner_production/features/new_lesson/view/widgets/new_lesson_section_heading.dart';

class NewLessonLanguageSection extends StatelessWidget {
  const NewLessonLanguageSection({
    super.key,
    required this.options,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  final List<NewLessonOptionItem> options;
  final String? selectedLanguage;
  final ValueChanged<String> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NewLessonSectionHeading(
          eyebrow: 'LANGUAGE',
          title: 'Pick the voice you want to train',
          subtitle:
              'Start with the language you want to speak more naturally, then let the roadmap shape listening, recall, and response speed.',
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.gridCols(context),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: Responsive.isTabletOrDesktop(context) ? 1.5 : 1.36,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            return NewLessonLanguageTile(
              option: option,
              isSelected: selectedLanguage == option.label,
              onTap: () => onLanguageSelected(option.label),
            );
          },
        ),
      ],
    );
  }
}
