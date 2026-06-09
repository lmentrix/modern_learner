import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/utils/responsive.dart';
import 'package:modern_learner_production/features/profile/data/profile_identity.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_constants.dart';

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({
    super.key,
    required this.identity,
    required this.totalXp,
    required this.onEditTap,
  });

  final ProfileIdentity identity;
  final int totalXp;
  final VoidCallback onEditTap;

  Color _letterColor(String name) {
    if (name.isEmpty) return AppColors.primary;

    final letter = name[0].toUpperCase();

    final colors = <Color>[
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.error,
      AppColors.primaryDim,
      AppColors.tertiaryContainer,
      Color.lerp(AppColors.primary, AppColors.secondary, 0.45) ??
          AppColors.primary,
      Color.lerp(AppColors.secondary, AppColors.tertiary, 0.38) ??
          AppColors.secondary,
      Color.lerp(AppColors.primaryDim, AppColors.error, 0.42) ??
          AppColors.primaryDim,
      Color.lerp(AppColors.tertiaryContainer, AppColors.primary, 0.36) ??
          AppColors.tertiaryContainer,
    ];

    final index = letter.codeUnitAt(0) % colors.length;

    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.hPad(context);
    final isWide = Responsive.isTabletOrDesktop(context);
    final avatarSize = isWide ? 64.0 : 52.0;
    final avatarFontSize = isWide ? 28.0 : 22.0;
    final nameFontSize = isWide ? 20.0 : 17.0;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 14),
          child: Row(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: _letterColor(identity.displayName),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    identity.displayName[0].toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: avatarFontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isWide ? 18 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      identity.displayName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          ProfilePageConstants.roleLabel,
                          style: GoogleFonts.inter(
                            fontSize: isWide ? 13.0 : 12.0,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            ProfilePageConstants.levelLabel,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1028),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEditTap,
                child: Container(
                  width: isWide ? 42 : 36,
                  height: isWide ? 42 : 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
