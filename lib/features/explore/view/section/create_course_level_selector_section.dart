import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class CreateCourseLevelSelectorSection extends StatelessWidget {
  const CreateCourseLevelSelectorSection({
    super.key,
    required this.levels,
    required this.selected,
    required this.accent,
    required this.onChanged,
  });

  final List<String> levels;
  final String selected;
  final Color accent;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: levels.map((level) {
        final isSelected = level == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: level != levels.last ? 10 : 0),
            child: GestureDetector(
              onTap: () => onChanged(level),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? accent : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? accent
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(_emoji(level), style: const TextStyle(fontSize: 18)),
                    SizedBox(height: 6),
                    Text(
                      _capitalize(level),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _emoji(String level) {
    switch (level) {
      case 'beginner':
        return '🌱';
      case 'intermediate':
        return '🔥';
      case 'advanced':
        return '🚀';
      default:
        return '📚';
    }
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
