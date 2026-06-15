import 'package:flutter/material.dart';
import 'package:modern_learner_production/home/data/home_data.dart';
import 'package:modern_learner_production/home/widgets/xp_progress_bar.dart';
import 'package:modern_learner_production/theme/theme.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key, required this.animate});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        EduSpacing.s6, EduSpacing.s8, EduSpacing.s6, EduSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: EduColors.surface,
        borderRadius: const BorderRadius.vertical(bottom: EduRadius.xl),
        boxShadow: EduColors.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [EduColors.primaryLight, EduColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: EduColors.shadowCard,
                ),
                alignment: Alignment.center,
                child: Text(
                  'ME',
                  style: tt.labelLarge?.copyWith(
                    color: EduColors.textInverse,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: EduSpacing.s3),

              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $currentUserName 👋',
                      style: tt.titleMedium,
                    ),
                    Text(
                      '$currentUserStreak-day streak 🔥',
                      style: tt.labelLarge?.copyWith(color: EduColors.primary),
                    ),
                  ],
                ),
              ),

              // Bell
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: EduColors.bg,
                  shape: BoxShape.circle,
                  boxShadow: EduColors.shadowCard,
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: EduColors.textPrimary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: EduSpacing.s5),

          // XP progress
          XpProgressBar(
            xp: currentUserXp,
            goal: currentUserXpGoal,
            animate: animate,
          ),
        ],
      ),
    );
  }
}
