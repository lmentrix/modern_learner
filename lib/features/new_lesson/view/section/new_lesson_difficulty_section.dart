import 'package:flutter/material.dart';

import 'package:modern_learner_production/features/new_lesson/data/new_lesson_option_item.dart';
import 'package:modern_learner_production/features/new_lesson/view/widgets/new_lesson_difficulty_tile.dart';
import 'package:modern_learner_production/features/new_lesson/view/widgets/new_lesson_section_heading.dart';

class NewLessonDifficultySection extends StatelessWidget {
  const NewLessonDifficultySection({
    super.key,
    required this.options,
    required this.selectedDifficulty,
    required this.onDifficultySelected,
  });

  final List<NewLessonOptionItem> options;
  final String selectedDifficulty;
  final ValueChanged<String> onDifficultySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NewLessonSectionHeading(
          eyebrow: 'DIFFICULTY',
          title: 'Set the stretch',
          subtitle:
              'Choose how hard the speaking roadmap should push. This affects pace, lesson density, and the kind of responses you will practice.',
        ),
        const SizedBox(height: 18),
        Row(
          children: options
              .map(
                (option) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: option == options.last ? 0 : 12,
                    ),
                    child: NewLessonDifficultyTile(
                      option: option,
                      isSelected: selectedDifficulty == option.label,
                      onTap: () => onDifficultySelected(option.label),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
