import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_profile_quick_action_row.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_profile_quick_stat.dart';

class HomeProfileSheet extends StatelessWidget {
  const HomeProfileSheet({
    super.key,
    required this.displayName,
    required this.onProfileTap,
    required this.onSettingsTap,
  });

  final String displayName;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;

  String get _initial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

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
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initial,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
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
                      displayName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '${context.tr('Advanced Learner')} · ${context.tr('LVL')} 8',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(
                child: HomeProfileQuickStat(
                  emoji: '🔥',
                  label: 'Streak',
                  value: '14',
                  subtitle: 'days',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: HomeProfileQuickStat(
                  emoji: '⭐',
                  label: 'XP',
                  value: '2.4K',
                  subtitle: 'total',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: HomeProfileQuickStat(
                  emoji: '📚',
                  label: 'Lessons',
                  value: '47',
                  subtitle: 'done',
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            context.tr('QUICK ACTIONS'),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),
          HomeProfileQuickActionRow(
            icon: Icons.person_outline_rounded,
            label: 'View Profile',
            accentColor: AppColors.primary,
            onTap: onProfileTap,
          ),
          SizedBox(height: 8),
          HomeProfileQuickActionRow(
            icon: Icons.settings_rounded,
            label: 'Settings',
            accentColor: AppColors.onSurfaceVariant,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}
