import 'package:flutter/material.dart';

import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/view/widgets/learning_subject_card.dart';

class LearningSubjectsGridSliver extends StatelessWidget {
  const LearningSubjectsGridSliver({
    super.key,
    required this.subjects,
    required this.onTap,
  });

  final List<LearningSubject> subjects;
  final void Function(LearningSubject) onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 900
        ? 4
        : w >= 600
        ? 3
        : 2;
    final hPad = w >= 600 ? 28.0 : 20.0;
    final ratio = w >= 600 ? 0.88 : 0.85;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          childAspectRatio: ratio,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, index) => LearningSubjectCard(
            subject: subjects[index],
            onTap: () => onTap(subjects[index]),
          ),
          childCount: subjects.length,
        ),
      ),
    );
  }
}
