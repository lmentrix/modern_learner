import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/features/auth/presentation/bloc/auth_bloc.dart';

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

  // ── Settings state ───────────────────────────────────────────────────────
  bool _dailyReminder = true;
  bool _streakAlerts = true;
  bool _weeklyDigest = false;
  bool _achievementAlerts = true;

  String _selectedLanguage = 'English (US)';

  bool _shareProgress = true;
  bool _showInLeaderboard = true;
  bool _analyticsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Load user info on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthLoadUserInfoRequested());
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Shared sheet helpers ─────────────────────────────────────────────────

  Widget _sheetHandle() {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.outlineVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _sheetTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _toggleRow({
    required String emoji,
    required String label,
    required String description,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          inactiveTrackColor: AppColors.surfaceContainerHighest,
          inactiveThumbColor: AppColors.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _onOffChip(bool on) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: on
            ? AppColors.tertiary.withValues(alpha: 0.12)
            : AppColors.outlineVariant.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        on ? 'On' : 'Off',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: on ? AppColors.tertiary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  // ── Account sheet ────────────────────────────────────────────────────────

  void _showAccountSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          final displayName = user?.name ?? 'User';
          final email = user?.email ?? '';
          final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
          
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
                _sheetHandle(),
                const SizedBox(height: 20),
                _sheetTitle('Account', Icons.person_outline_rounded, AppColors.primary),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Center(
                        child: Text(
                          initial,
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
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            email,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _accountInfoRow(Icons.badge_outlined, 'Username', '@${displayName.toLowerCase().replaceAll(' ', '')}'),
                const SizedBox(height: 8),
                _accountInfoRow(Icons.cake_outlined, 'Member since', 'January 2024'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSignOutDialog();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _accountInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ── Notifications sheet ──────────────────────────────────────────────────

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
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
              _sheetHandle(),
              const SizedBox(height: 20),
              _sheetTitle(
                  'Notifications', Icons.notifications_outlined, AppColors.secondary),
              const SizedBox(height: 24),
              _toggleRow(
                emoji: '🔔',
                label: 'Daily Reminder',
                description: 'Get reminded to practice each day',
                value: _dailyReminder,
                onChanged: (v) {
                  setSheetState(() {});
                  setState(() => _dailyReminder = v);
                },
              ),
              const _SheetDivider(),
              _toggleRow(
                emoji: '🔥',
                label: 'Streak Alerts',
                description: 'Know when your streak is at risk',
                value: _streakAlerts,
                onChanged: (v) {
                  setSheetState(() {});
                  setState(() => _streakAlerts = v);
                },
              ),
              const _SheetDivider(),
              _toggleRow(
                emoji: '📊',
                label: 'Weekly Digest',
                description: 'A summary of your weekly progress',
                value: _weeklyDigest,
                onChanged: (v) {
                  setSheetState(() {});
                  setState(() => _weeklyDigest = v);
                },
              ),
              const _SheetDivider(),
              _toggleRow(
                emoji: '🏆',
                label: 'Achievement Alerts',
                description: 'Celebrate when you earn badges',
                value: _achievementAlerts,
                onChanged: (v) {
                  setSheetState(() {});
                  setState(() => _achievementAlerts = v);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Appearance sheet ─────────────────────────────────────────────────────

  void _showAppearanceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _sheetHandle()),
            const SizedBox(height: 20),
            _sheetTitle(
                'Appearance', Icons.palette_outlined, AppColors.tertiaryContainer),
            const SizedBox(height: 24),
            Text(
              'THEME',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _AppearanceOption(
                    label: 'Dark',
                    emoji: '🌑',
                    isSelected: true,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AppearanceOption(
                    label: 'Light',
                    emoji: '☀️',
                    isSelected: false,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AppearanceOption(
                    label: 'System',
                    emoji: '⚙️',
                    isSelected: false,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'TEXT SIZE',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TextSizeOption(
                      label: 'Small', sampleSize: 12, isSelected: false),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TextSizeOption(
                      label: 'Medium', sampleSize: 16, isSelected: true),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TextSizeOption(
                      label: 'Large', sampleSize: 22, isSelected: false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Language sheet ───────────────────────────────────────────────────────

  void _showLanguageSheet() {
    final languages = [
      ('🇺🇸', 'English (US)'),
      ('🇪🇸', 'Spanish'),
      ('🇫🇷', 'French'),
      ('🇩🇪', 'German'),
      ('🇯🇵', 'Japanese'),
      ('🇨🇳', 'Mandarin'),
      ('🇮🇹', 'Italian'),
      ('🇧🇷', 'Portuguese'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.only(
                top: 12,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              children: [
                Center(child: _sheetHandle()),
                const SizedBox(height: 20),
                _sheetTitle(
                    'Language', Icons.language_rounded, const Color(0xFFFF9500)),
                const SizedBox(height: 6),
                Text(
                  'Choose your preferred app language',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                ...languages.map((lang) {
                  final isSelected = _selectedLanguage == lang.$2;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        setSheetState(() {});
                        setState(() => _selectedLanguage = lang.$2);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF9500).withValues(alpha: 0.08)
                              : AppColors.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF9500).withValues(alpha: 0.45)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(lang.$1,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Text(
                              lang.$2,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.onSurface
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFFFF9500), size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Privacy sheet ────────────────────────────────────────────────────────

  void _showPrivacySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
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
              _sheetHandle(),
              const SizedBox(height: 20),
              _sheetTitle(
                  'Privacy', Icons.shield_outlined, const Color(0xFF00DC82)),
              const SizedBox(height: 24),
              _toggleRow(
                emoji: '📈',
                label: 'Share Progress',
                description: 'Let friends see your learning stats',
                value: _shareProgress,
                onChanged: (v) {
                  setSheetState(() {});
                  setState(() => _shareProgress = v);
                },
              ),
              const _SheetDivider(),
              _toggleRow(
                emoji: '🏅',
                label: 'Show in Leaderboard',
                description: 'Appear in community rankings',
                value: _showInLeaderboard,
                onChanged: (v) {
                  setSheetState(() {});
                  setState(() => _showInLeaderboard = v);
                },
              ),
              const _SheetDivider(),
              _toggleRow(
                emoji: '📊',
                label: 'Usage Analytics',
                description: 'Help improve the app with usage data',
                value: _analyticsEnabled,
                onChanged: (v) {
                  setSheetState(() {});
                  setState(() => _analyticsEnabled = v);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurfaceVariant,
                    side: BorderSide(
                        color: AppColors.outlineVariant
                            .withValues(alpha: 0.35)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Download My Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Help & Support sheet ─────────────────────────────────────────────────

  void _showHelpSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: 12,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            children: [
              Center(child: _sheetHandle()),
              const SizedBox(height: 20),
              _sheetTitle('Help & Support', Icons.help_outline_rounded,
                  const Color(0xFFFF6B9D)),
              const SizedBox(height: 24),
              Text(
                'FREQUENTLY ASKED',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const _FaqTile(
                question: 'How do I reset my password?',
                answer:
                    'Go to the login screen and tap "Forgot Password". We\'ll send a reset link to your registered email address.',
              ),
              const _FaqTile(
                question: 'How does the streak system work?',
                answer:
                    'Complete at least one lesson per day to maintain your streak. Missing a day resets it to zero — use a streak freeze to protect it.',
              ),
              const _FaqTile(
                question: 'Can I learn multiple languages at once?',
                answer:
                    'Yes! Switch between language courses anytime from the Explore tab. Your progress in each course is saved separately.',
              ),
              const _FaqTile(
                question: 'How is XP calculated?',
                answer:
                    'XP is awarded based on lesson difficulty, accuracy, and speed. Harder challenge and boss lessons give significantly more XP.',
              ),
              const SizedBox(height: 20),
              Text(
                'CONTACT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _ContactRow(
                icon: Icons.email_outlined,
                label: 'Email Support',
                subtitle: 'support@modernlearner.app',
                color: const Color(0xFFFF6B9D),
              ),
              const SizedBox(height: 8),
              _ContactRow(
                icon: Icons.star_outline_rounded,
                label: 'Rate the App',
                subtitle: 'Leave a review on the App Store',
                color: AppColors.tertiaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sign out dialog ──────────────────────────────────────────────────────

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out?',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          'Your progress is safely saved. You can sign back in anytime.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              'Sign Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final anyNotifOn =
        _dailyReminder || _streakAlerts || _weeklyDigest || _achievementAlerts;

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
              sliver: SliverToBoxAdapter(child: _sectionLabel('THIS WEEK')),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildWeeklyActivity()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _sectionLabel('SETTINGS')),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final user = state.user;
                        final subtitle = user != null
                            ? '${user.name} · ${user.email}'
                            : 'Not signed in';
                        return SettingItem(
                          icon: Icons.person_outline_rounded,
                          title: 'Account',
                          subtitle: subtitle,
                          accentColor: AppColors.primary,
                          onTap: _showAccountSheet,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    SettingItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: anyNotifOn
                          ? 'Reminders active'
                          : 'All notifications off',
                      accentColor: AppColors.secondary,
                      trailing: _onOffChip(anyNotifOn),
                      onTap: _showNotificationsSheet,
                    ),
                    const SizedBox(height: 8),
                    SettingItem(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      subtitle: 'Dark · Medium text',
                      accentColor: AppColors.tertiaryContainer,
                      onTap: _showAppearanceSheet,
                    ),
                    const SizedBox(height: 8),
                    SettingItem(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: _selectedLanguage,
                      accentColor: const Color(0xFFFF9500),
                      onTap: _showLanguageSheet,
                    ),
                    const SizedBox(height: 8),
                    SettingItem(
                      icon: Icons.shield_outlined,
                      title: 'Privacy',
                      subtitle: 'Data & visibility controls',
                      accentColor: const Color(0xFF00DC82),
                      onTap: _showPrivacySheet,
                    ),
                    const SizedBox(height: 8),
                    SettingItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'FAQs and contact us',
                      accentColor: const Color(0xFFFF6B9D),
                      onTap: _showHelpSheet,
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: _showSignOutDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'Modern Learner · v1.0.0',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── Existing section builders (unchanged) ────────────────────────────────

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final displayName = user?.name ?? 'User';
        final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
        
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
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
                      displayName,
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
                          'Advanced Learner',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'LVL 8',
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
                onTap: _showAccountSheet,
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

  Widget _buildWeeklyActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
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

// ── Static data ──────────────────────────────────────────────────────────────

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

// ── Reusable sheet sub-widgets ───────────────────────────────────────────────

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 20,
      thickness: 1,
      color: AppColors.outlineVariant.withValues(alpha: 0.15),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final Color color;

  const _AppearanceOption({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.1)
            : AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? color.withValues(alpha: 0.45)
              : AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? color : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextSizeOption extends StatelessWidget {
  final String label;
  final double sampleSize;
  final bool isSelected;

  const _TextSizeOption({
    required this.label,
    required this.sampleSize,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Aa',
            style: GoogleFonts.inter(
              fontSize: sampleSize,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _expanded
              ? AppColors.surfaceContainerHighest.withValues(alpha: 0.6)
              : AppColors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? AppColors.outlineVariant.withValues(alpha: 0.3)
                : AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 10),
              Text(
                widget.answer,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}
