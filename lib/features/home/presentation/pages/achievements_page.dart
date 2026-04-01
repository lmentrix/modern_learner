import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/presentation/widgets/achievement_badge.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final _scrollCtrl = ScrollController();
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<_Achievement> get _filteredAchievements {
    if (_selectedFilter == 'unlocked') {
      return _achievements.where((a) => !a.isLocked).toList();
    } else if (_selectedFilter == 'locked') {
      return _achievements.where((a) => a.isLocked).toList();
    }
    return _achievements;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildProgressCard()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildFilterChips()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _sectionLabel('ALL ACHIEVEMENTS')),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _filteredAchievements.length,
                itemBuilder: (context, i) {
                  final a = _filteredAchievements[i];
                  return _AchievementCard(
                    emoji: a.emoji,
                    title: a.title,
                    subtitle: a.subtitle,
                    color: a.color,
                    isLocked: a.isLocked,
                    description: a.description,
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E1020), AppColors.surface],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: AppColors.onSurface,
          ),
          const SizedBox(width: 8),
          Text(
            'Achievements',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final unlocked = _achievements.where((a) => !a.isLocked).length;
    final total = _achievements.length;
    final progress = unlocked / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unlocked / $total Unlocked',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Keep learning to earn more!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1A1028),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('All', 'all'),
      ('Unlocked', 'unlocked'),
      ('Locked', 'locked'),
    ];

    return Row(
      children: [
        for (final filter in filters)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter.$1,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _selectedFilter == filter.$2
                      ? Colors.white
                      : AppColors.onSurfaceVariant,
                ),
              ),
              selected: _selectedFilter == filter.$2,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter.$2;
                });
              },
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              backgroundColor: AppColors.surfaceContainerHighest,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLocked,
    required this.description,
  });

  final String emoji, title, subtitle, description;
  final Color color;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => _AchievementDetailSheet(
            emoji: emoji,
            title: title,
            subtitle: subtitle,
            color: color,
            isLocked: isLocked,
            description: description,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked
              ? AppColors.surfaceContainerHighest
              : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLocked
                ? AppColors.outlineVariant.withValues(alpha: 0.2)
                : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isLocked
                    ? AppColors.surfaceContainerHigh
                    : color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 30,
                    color: isLocked ? AppColors.onSurfaceVariant : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isLocked
                    ? AppColors.onSurfaceVariant
                    : AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementDetailSheet extends StatelessWidget {
  const _AchievementDetailSheet({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLocked,
    required this.description,
  });

  final String emoji, title, subtitle, description;
  final Color color;
  final bool isLocked;

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
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isLocked
                  ? AppColors.surfaceContainerHigh
                  : color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: 44,
                  color: isLocked ? AppColors.onSurfaceVariant : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isLocked
                  ? AppColors.onSurfaceVariant
                  : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  isLocked ? Icons.lock_outline_rounded : Icons.check_circle_rounded,
                  color: isLocked ? AppColors.onSurfaceVariant : color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF1A1028),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isLocked ? 'Keep Learning!' : 'Awesome!',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Achievement {
  const _Achievement({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.description,
    this.isLocked = false,
  });

  final String emoji, title, subtitle, description;
  final Color color;
  final bool isLocked;
}

const _achievements = [
  _Achievement(
    emoji: '🔥',
    title: 'Week Streak',
    subtitle: '7 day streak',
    color: Color(0xFFFF9500),
    description: 'Maintain a 7-day learning streak without missing a day.',
  ),
  _Achievement(
    emoji: '⭐',
    title: 'XP Master',
    subtitle: '2000 XP earned',
    color: AppColors.tertiaryContainer,
    description: 'Earn 2000 XP points through lessons and exercises.',
  ),
  _Achievement(
    emoji: '📚',
    title: 'Bookworm',
    subtitle: '25 lessons done',
    color: AppColors.primary,
    description: 'Complete 25 lessons across all courses.',
  ),
  _Achievement(
    emoji: '🎯',
    title: 'Perfectionist',
    subtitle: '100% accuracy',
    color: AppColors.secondary,
    description: 'Complete a lesson with 100% accuracy on the first try.',
  ),
  _Achievement(
    emoji: '🌟',
    title: 'Quick Learner',
    subtitle: '5 lessons in a day',
    color: const Color(0xFF00DC82),
    description: 'Complete 5 lessons in a single day.',
  ),
  _Achievement(
    emoji: '💪',
    title: 'Dedicated',
    subtitle: '30 day streak',
    color: const Color(0xFFFF6B9D),
    description: 'Maintain a 30-day learning streak. True dedication!',
  ),
  _Achievement(
    emoji: '🏆',
    title: 'Champion',
    subtitle: 'Top 10 leaderboard',
    color: const Color(0xFFFFD700),
    description: 'Reach the top 10 on the weekly leaderboard.',
    isLocked: true,
  ),
  _Achievement(
    emoji: '🎓',
    title: 'Scholar',
    subtitle: 'Complete all courses',
    color: AppColors.primary,
    description: 'Finish all available courses and become a true scholar.',
    isLocked: true,
  ),
];
