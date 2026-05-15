import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_profile_quick_action_row.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_profile_quick_stat.dart';

/// Profile quick view bottom sheet widget.
class HomeProfileSheet extends StatelessWidget {
  const HomeProfileSheet({
    super.key,
    required this.displayName,
    required this.onProfileTap,
    required this.onAchievementsTap,
    required this.onSettingsTap,
  });

  final String displayName;
  final VoidCallback onProfileTap;
  final VoidCallback onAchievementsTap;
  final VoidCallback onSettingsTap;

  String get _initial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Profile header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
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
                      'Advanced Learner · LVL 8',
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
          // Stats row
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
          const SizedBox(height: 24),
          // Quick actions
          Text(
            'QUICK ACTIONS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          HomeProfileQuickActionRow(
            icon: Icons.person_outline_rounded,
            label: 'View Profile',
            accentColor: AppColors.primary,
            onTap: onProfileTap,
          ),
          const SizedBox(height: 8),
          HomeProfileQuickActionRow(
            icon: Icons.emoji_events_rounded,
            label: 'Achievements',
            accentColor: AppColors.tertiaryContainer,
            onTap: onAchievementsTap,
          ),
          const SizedBox(height: 8),
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
