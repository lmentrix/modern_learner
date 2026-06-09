import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class NewLessonSelectableChip extends StatelessWidget {
  const NewLessonSelectableChip({
    super.key,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
    required this.child,
  });

  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.12)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.38)
                : AppColors.outlineVariant.withValues(alpha: 0.16),
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
