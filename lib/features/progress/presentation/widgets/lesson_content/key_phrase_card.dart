import 'package:flutter/material.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/detail_card.dart';

class KeyPhraseCard extends StatelessWidget {
  const KeyPhraseCard({
    super.key,
    required this.phrase,
    required this.typeColor,
  });

  final KeyPhraseModel phrase;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      title: phrase.phrase,
      body: 'Meaning: ${phrase.translation}\n\nUsage: ${phrase.usage}',
      accentColor: typeColor,
    );
  }
}
