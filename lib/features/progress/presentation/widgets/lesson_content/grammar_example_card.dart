import 'package:flutter/material.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/detail_card.dart';

class GrammarExampleCard extends StatelessWidget {
  const GrammarExampleCard({
    super.key,
    required this.example,
    required this.typeColor,
  });

  final GrammarExampleModel example;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      title: example.sentence,
      body:
          'Translation: ${example.translation}\n\nBreakdown: ${example.breakdown}',
      accentColor: typeColor,
    );
  }
}
