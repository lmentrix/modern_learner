import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/theme/app_theme_controller.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_appearance_option.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_handle.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_title.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_text_size_option.dart';

class ProfileAppearanceSheetSection extends StatelessWidget {
  ProfileAppearanceSheetSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: ProfileSheetHandle()),
          SizedBox(height: 20),
          ProfileSheetTitle(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            color: AppColors.tertiaryContainer,
          ),
          SizedBox(height: 24),
          Text(
            context.tr('THEME'),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<AppThemePreference>(
            valueListenable: AppThemeController.instance.preferenceListenable,
            builder: (context, preference, _) {
              return Row(
                children: [
                  Expanded(
                    child: ProfileAppearanceOption(
                      label: 'Dark',
                      emoji: 'D',
                      isSelected: preference == AppThemePreference.dark,
                      color: AppColors.primary,
                      onTap: () => AppThemeController.instance.setPreference(
                        AppThemePreference.dark,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ProfileAppearanceOption(
                      label: 'Light',
                      emoji: 'L',
                      isSelected: preference == AppThemePreference.light,
                      color: AppColors.primary,
                      onTap: () => AppThemeController.instance.setPreference(
                        AppThemePreference.light,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ProfileAppearanceOption(
                      label: 'System',
                      emoji: 'S',
                      isSelected: preference == AppThemePreference.system,
                      color: AppColors.primary,
                      onTap: () => AppThemeController.instance.setPreference(
                        AppThemePreference.system,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            context.tr('TEXT SIZE'),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: ProfileTextSizeOption(
                  label: 'Small',
                  sampleSize: 12,
                  isSelected: false,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ProfileTextSizeOption(
                  label: 'Medium',
                  sampleSize: 16,
                  isSelected: true,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ProfileTextSizeOption(
                  label: 'Large',
                  sampleSize: 22,
                  isSelected: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
