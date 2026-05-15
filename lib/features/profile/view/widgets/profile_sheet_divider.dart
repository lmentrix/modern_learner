import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class ProfileSheetDivider extends StatelessWidget {
  const ProfileSheetDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 20,
      thickness: 1,
      color: AppColors.outlineVariant.withValues(alpha: 0.15),
    );
  }
}
