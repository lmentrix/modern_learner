import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class ProfileSheetHandle extends StatelessWidget {
  const ProfileSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.outlineVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
