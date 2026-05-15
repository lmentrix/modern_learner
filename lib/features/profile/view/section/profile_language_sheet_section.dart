import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_data.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_handle.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_title.dart';

class ProfileLanguageSheetSection extends StatefulWidget {
  const ProfileLanguageSheetSection({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  final String selectedLanguage;
  final ValueChanged<String> onLanguageSelected;

  @override
  State<ProfileLanguageSheetSection> createState() =>
      _ProfileLanguageSheetSectionState();
}

class _ProfileLanguageSheetSectionState
    extends State<ProfileLanguageSheetSection> {
  static const _languageAccent = Color(0xFFFF9500);

  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage;
  }

  void _selectLanguage(String language) {
    setState(() => _selectedLanguage = language);
    widget.onLanguageSelected(language);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.only(
            top: 12,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            const Center(child: ProfileSheetHandle()),
            const SizedBox(height: 20),
            const ProfileSheetTitle(
              title: 'Language',
              icon: Icons.language_rounded,
              color: _languageAccent,
            ),
            const SizedBox(height: 6),
            Text(
              'Choose your preferred app language',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            for (final language in ProfilePageData.languages)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => _selectLanguage(language.label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedLanguage == language.label
                          ? _languageAccent.withValues(alpha: 0.08)
                          : AppColors.surfaceContainerHighest.withValues(
                              alpha: 0.4,
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedLanguage == language.label
                            ? _languageAccent.withValues(alpha: 0.45)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          language.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          language.label,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: _selectedLanguage == language.label
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _selectedLanguage == language.label
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedLanguage == language.label)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: _languageAccent,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
