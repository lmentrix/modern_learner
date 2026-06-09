import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_locale_option.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_data.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_handle.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_title.dart';
import 'package:modern_learner_production/l10n/generated/app_localizations.dart';

class ProfileLanguageSheetSection extends StatefulWidget {
  const ProfileLanguageSheetSection({
    super.key,
    required this.selectedLocale,
    required this.onLanguageSelected,
  });

  final Locale selectedLocale;
  final ValueChanged<AppLocaleOption> onLanguageSelected;

  @override
  State<ProfileLanguageSheetSection> createState() =>
      _ProfileLanguageSheetSectionState();
}

class _ProfileLanguageSheetSectionState
    extends State<ProfileLanguageSheetSection> {
  static const _languageAccent = Color(0xFFFF9500);

  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.selectedLocale;
  }

  void _selectLanguage(AppLocaleOption option) {
    setState(() => _selectedLocale = option.locale);
    widget.onLanguageSelected(option);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
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
            Center(child: ProfileSheetHandle()),
            const SizedBox(height: 20),
            ProfileSheetTitle(
              title: l10n.language,
              icon: Icons.language_rounded,
              color: _languageAccent,
            ),
            SizedBox(height: 6),
            Text(
              l10n.choosePreferredLanguage,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            for (final language in ProfilePageData.languages)
              _LanguageOptionRow(
                option: appLocaleOptionForLabel(language.label),
                label: _localizedLanguageLabel(l10n, language.label),
                isSelected:
                    _selectedLocale.languageCode ==
                    appLocaleOptionForLabel(language.label).locale.languageCode,
                onTap: _selectLanguage,
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionRow extends StatelessWidget {
  const _LanguageOptionRow({
    required this.option,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final AppLocaleOption option;
  final String label;
  final bool isSelected;
  final ValueChanged<AppLocaleOption> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => onTap(option),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isSelected
                ? _ProfileLanguageSheetSectionState._languageAccent.withValues(
                    alpha: 0.08,
                  )
                : AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? _ProfileLanguageSheetSectionState._languageAccent
                        .withValues(alpha: 0.45)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Text(option.flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    option.nativeName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: _ProfileLanguageSheetSectionState._languageAccent,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _localizedLanguageLabel(AppLocalizations l10n, String label) {
  return switch (label) {
    'English (US)' => l10n.englishUs,
    'Spanish' => l10n.spanish,
    'French' => l10n.french,
    'German' => l10n.german,
    'Italian' => l10n.italian,
    'Portuguese' => l10n.portuguese,
    'Japanese' => l10n.japanese,
    'Korean' => l10n.korean,
    'Mandarin' => l10n.mandarin,
    _ => label,
  };
}
