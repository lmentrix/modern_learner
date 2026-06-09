import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/theme/app_text_styles.dart';

class ProfileAchievementErrorPlaceholder extends StatelessWidget {
  const ProfileAchievementErrorPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Text(
        'Could not load achievements',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
