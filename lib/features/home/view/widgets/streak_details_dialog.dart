import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/view/widgets/streak_details_milestone_item.dart';
import 'package:modern_learner_production/features/home/view/widgets/streak_details_stat_box.dart';

class StreakDetailsDialog extends StatelessWidget {
  const StreakDetailsDialog({super.key, required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildStats(),
            ),
            const SizedBox(height: 20),
            _buildMilestones(),
            const SizedBox(height: 24),
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B2B), Color(0xFFFF9500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 4),
            Text(
              '$streak',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Day Streak',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.95),
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: StreakDetailsStatBox(
              emoji: '⏱️',
              label: 'Total Time',
              value: '12.5h',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: StreakDetailsStatBox(
              emoji: '📚',
              label: 'Lessons',
              value: '47',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MILESTONES',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const StreakDetailsMilestoneItem(
            days: 7,
            label: 'Week Warrior',
            achieved: true,
          ),
          const StreakDetailsMilestoneItem(
            days: 14,
            label: 'Two Week Streak',
            achieved: true,
            isCurrent: true,
          ),
          const StreakDetailsMilestoneItem(
            days: 30,
            label: 'Monthly Master',
            achieved: false,
          ),
          const StreakDetailsMilestoneItem(
            days: 60,
            label: 'Double Month',
            achieved: false,
          ),
          const StreakDetailsMilestoneItem(
            days: 90,
            label: 'Legendary Learner',
            achieved: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: 24, right: 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Keep Going!',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
