import 'package:flutter/material.dart';
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
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 760
                ? 4
                : width >= 520
                ? 3
                : width >= 340
                ? 2
                : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 3.4 : 1.38,
              ),
              itemBuilder: (context, index) {
                final option = options[index];
                return NewLessonLanguageTile(
                  option: option,
                  isSelected: selectedLanguage == option.label,
                  onTap: () => onLanguageSelected(option.label),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
