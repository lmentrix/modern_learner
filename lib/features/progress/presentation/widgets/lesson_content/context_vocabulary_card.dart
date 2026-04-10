import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/detail_card.dart';

class ContextVocabularyCard extends StatelessWidget {
  const ContextVocabularyCard({super.key, required this.item});

  final ContextVocabularyItemModel item;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      title:
          '${item.word} ${item.pronunciation.isNotEmpty ? '(${item.pronunciation})' : ''}',
      body: 'Meaning: ${item.translation}\n\nContext: ${item.context}',
      accentColor: AppColors.primary,
    );
  }
}
