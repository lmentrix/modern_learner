import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import 'package:modern_learner_production/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:modern_learner_production/features/profile/presentation/widgets/achievement_badge.dart';
import 'package:modern_learner_production/features/profile/presentation/widgets/stats_card.dart';

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({super.key});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
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
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildUserInfo()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildStatsRow()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _sectionLabel('ACHIEVEMENTS')),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildAchievements()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildActionButtons(),
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
            'Profile',
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

  Widget _buildUserInfo() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final displayName = user?.name ?? 'User';
        final email = user?.email ?? '';
        final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDim.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'LVL 8 · Advanced Learner',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1028),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (user?.isVip == true) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'VIP',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1028),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return const Row(
      children: [
        Expanded(
          child: StatsCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Day Streak',
            value: '14',
            accentColor: Color(0xFFFF9500),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            icon: Icons.star_rounded,
            label: 'Total XP',
            value: '2.4K',
            accentColor: AppColors.tertiaryContainer,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            icon: Icons.check_circle_rounded,
            label: 'Completed',
            value: '47',
            accentColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _achievements.length,
        separatorBuilder: (_, i) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final a = _achievements[i];
          return AchievementBadge(
            emoji: a.emoji,
            title: a.title,
            subtitle: a.subtitle,
            color: a.color,
            isLocked: a.isLocked,
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/profile');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF1A1028),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'View Full Profile',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/profile');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.tertiaryContainer,
              side: BorderSide(
                color: AppColors.tertiaryContainer.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'View All Achievements',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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

class _Achievement {
  const _Achievement({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isLocked = false,
  });

  final String emoji, title, subtitle;
  final Color color;
  final bool isLocked;
}

const _achievements = [
  _Achievement(
    emoji: '🔥',
    title: 'Week Streak',
    subtitle: '7 day streak',
    color: Color(0xFFFF9500),
  ),
  _Achievement(
    emoji: '⭐',
    title: 'XP Master',
    subtitle: '2000 XP earned',
    color: AppColors.tertiaryContainer,
  ),
  _Achievement(
    emoji: '📚',
    title: 'Bookworm',
    subtitle: '25 lessons done',
    color: AppColors.primary,
  ),
  _Achievement(
    emoji: '🎯',
    title: 'Perfectionist',
    subtitle: '100% accuracy',
    color: AppColors.secondary,
  ),
  _Achievement(
    emoji: '🏆',
    title: 'Champion',
    subtitle: 'Top 10 leaderboard',
    color: Color(0xFFFF6B9D),
    isLocked: true,
  ),
];
