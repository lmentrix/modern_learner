import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/detail_card.dart';

class ListeningVocabularyCard extends StatelessWidget {
  const ListeningVocabularyCard({super.key, required this.item});

  final ListeningVocabularyItemModel item;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      title: item.word,
      body: item.translation,
      accentColor: AppColors.primary,
    );
  }
}
