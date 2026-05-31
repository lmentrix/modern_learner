import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _letterColor(identity.displayName),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                identity.displayName[0].toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  identity.displayName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      ProfilePageConstants.roleLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
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
          const SizedBox(width: 10),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: AppColors.onSurfaceVariant,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
