import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class CreateCourseLanguageDropdownSection extends StatelessWidget {
  const CreateCourseLanguageDropdownSection({
    super.key,
    required this.languages,
    required this.selected,
    required this.accent,
    required this.onChanged,
  });

  final List<String> languages;
  final String selected;
  final Color accent;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          dropdownColor: AppColors.surfaceContainerHigh,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          icon: Icon(Icons.expand_more_rounded, color: accent),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          items: languages
              .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
              .toList(),
        ),
      ),
    );
  }
}
