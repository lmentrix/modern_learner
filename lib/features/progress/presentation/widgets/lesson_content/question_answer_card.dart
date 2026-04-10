import 'package:flutter/material.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/detail_card.dart';

class QuestionAnswerCard extends StatelessWidget {
  const QuestionAnswerCard({
    super.key,
    required this.item,
    required this.typeColor,
  });

  final QuestionAnswerModel item;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (item.type.isNotEmpty) 'Type: ${item.type}',
      'Answer: ${item.answer}',
      if (item.explanation.isNotEmpty) 'Why: ${item.explanation}',
    ];

    return DetailCard(
      title: item.question,
      body: details.join('\n\n'),
      accentColor: typeColor,
    );
  }
}
