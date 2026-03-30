import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/setting_item.dart';
import '../widgets/stats_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
            // ── Profile Header ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Stats Cards ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildStatsRow()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Achievements Section ───────────────────────────────────────
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

            // ── Learning Activity ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _sectionLabel('THIS WEEK')),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildWeeklyActivity()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Settings Section ───────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _sectionLabel('SETTINGS')),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // Settings items
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: _settings.length,
                separatorBuilder: (__, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final s = _settings[i];
                  return SettingItem(
                    icon: s.icon,
                    title: s.title,
                    subtitle: s.subtitle,
                    accentColor: s.color,
                    onTap: () {},
                  );
                },
              ),
            ),

            // Add padding for bottom navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E1020), AppColors.surface],
        ),
      ),
      child: Column(
        children: [
          // Avatar and basic info
          Row(
            children: [
              // Large avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDim.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
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
                      'Alex Johnson',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Advanced Learner',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                        'LEVEL 8',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1028),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Edit button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bio
          Text(
            '📚 Language enthusiast | 🎯 Daily learner | 🌟 Goal: Fluent in 3 languages',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
        separatorBuilder: (__, _) => const SizedBox(width: 12),
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

  Widget _buildWeeklyActivity() {
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Learning Activity',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                '5.2h total',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.map((day) {
              final height = day.activity * 0.8;
              return Column(
                children: [
                  Text(
                    '${day.activity}m',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 8,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    day.name,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
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

// ── Static data ─────────────────────────────────────────────────────────────

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
    title: 'Week Warrior',
    subtitle: '7 day streak',
    color: AppColors.primary,
  ),
  _Achievement(
    emoji: '⭐',
    title: 'Rising Star',
    subtitle: 'Complete 25 lessons',
    color: AppColors.tertiaryContainer,
  ),
  _Achievement(
    emoji: '🎯',
    title: 'On Track',
    subtitle: '30 day streak',
    color: AppColors.secondary,
    isLocked: true,
  ),
  _Achievement(
    emoji: '🏆',
    title: 'Champion',
    subtitle: 'Complete 100 lessons',
    color: Color(0xFFFF9500),
    isLocked: true,
  ),
];

class _WeekDay {
  const _WeekDay({required this.name, required this.activity});
  final String name;
  final int activity;
}

const _weekDays = [
  _WeekDay(name: 'M', activity: 45),
  _WeekDay(name: 'T', activity: 62),
  _WeekDay(name: 'W', activity: 38),
  _WeekDay(name: 'T', activity: 55),
  _WeekDay(name: 'F', activity: 70),
  _WeekDay(name: 'S', activity: 25),
  _WeekDay(name: 'S', activity: 48),
];

class _Setting {
  const _Setting({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
  final IconData icon;
  final String title, subtitle;
  final Color color;
}

const _settings = [
  _Setting(
    icon: Icons.person_outline_rounded,
    title: 'Account',
    subtitle: 'Manage your account settings',
    color: AppColors.primary,
  ),
  _Setting(
    icon: Icons.notifications_outlined,
    title: 'Notifications',
    subtitle: 'Customize your reminders',
    color: AppColors.secondary,
  ),
  _Setting(
    icon: Icons.palette_outlined,
    title: 'Appearance',
    subtitle: 'Theme and display settings',
    color: AppColors.tertiaryContainer,
  ),
  _Setting(
    icon: Icons.language_rounded,
    title: 'Language',
    subtitle: 'English (US)',
    color: Color(0xFFFF9500),
  ),
  _Setting(
    icon: Icons.shield_outlined,
    title: 'Privacy',
    subtitle: 'Control your data',
    color: Color(0xFF00DC82),
  ),
  _Setting(
    icon: Icons.help_outline_rounded,
    title: 'Help & Support',
    subtitle: 'FAQs and contact us',
    color: Color(0xFFFF6B9D),
  ),
];
