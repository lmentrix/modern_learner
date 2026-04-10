import 'package:flutter/material.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/detail_card.dart';

class GeneratedQuestionCard extends StatelessWidget {
  const GeneratedQuestionCard({
    super.key,
    required this.question,
    required this.typeColor,
  });

  final GeneratedQuestionModel question;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (question.type.isNotEmpty) 'Type: ${question.type}',
      if (question.difficulty.isNotEmpty) 'Difficulty: ${question.difficulty}',
      if (question.options.isNotEmpty)
        'Options: ${question.options.join(' | ')}',
      'Answer: ${question.answer}',
      if (question.explanation.isNotEmpty) 'Why: ${question.explanation}',
    ];

    return DetailCard(
      title: question.question,
      body: details.join('\n\n'),
      accentColor: typeColor,
    );
  }
}
