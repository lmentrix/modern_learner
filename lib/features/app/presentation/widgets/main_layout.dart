import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/domain/entities/achievement_entity.dart';
import 'package:modern_learner_production/features/home/presentation/bloc/achievement_bloc.dart';
import 'package:modern_learner_production/features/new_lesson/presentation/pages/new_lesson_page.dart';

/// 全局主布局 - 包含唯一的底部导航栏
class MainLayout extends StatelessWidget {

  const MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });
  final Widget child;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AchievementBloc, AchievementState>(
      listenWhen: (prev, curr) => curr.newlyUnlocked.isNotEmpty,
      listener: (context, state) {
        _showUnlockToast(context, state.newlyUnlocked.first);
        context
            .read<AchievementBloc>()
            .add(const AchievementNewlyUnlockedAcknowledged());
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar:
            _BottomNavigationBarWidget(currentIndex: currentIndex),
      ),
    );
  }

  void _showUnlockToast(BuildContext context, AchievementEntity achievement) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AchievementToast(
        achievement: achievement,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

/// 底部导航栏组件 - 全局唯一
class _BottomNavigationBarWidget extends StatelessWidget {

  const _BottomNavigationBarWidget({required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isActive: currentIndex == 0,
                    activeColor: AppColors.primary,
                    onTap: () => context.go(Routes.home),
                  ),
                  _NavItem(
                    icon: Icons.explore_rounded,
                    label: 'Explore',
                    isActive: currentIndex == 1,
                    activeColor: AppColors.primary,
                    onTap: () => context.go(Routes.explore),
                  ),
                  _NavItem(
                    icon: Icons.add_rounded,
                    label: 'New',
                    isActive: currentIndex == 2,
                    activeColor: AppColors.primary,
                    centerFab: true,
                    onTap: () => Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => const NewLessonPage(),
                      ),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Progress',
                    isActive: currentIndex == 3,
                    activeColor: AppColors.primary,
                    onTap: () => context.go(Routes.progress),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    isActive: currentIndex == 4,
                    activeColor: AppColors.primary,
                    onTap: () => context.go(Routes.profile),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    this.centerFab = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final bool centerFab;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (centerFab) {
      return GestureDetector(
        onTap: onTap ?? () {},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDim.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : AppColors.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? activeColor : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Achievement unlock toast ──────────────────────────────────────────────────

class _AchievementToast extends StatefulWidget {
  const _AchievementToast({
    required this.achievement,
    required this.onDismiss,
  });

  final AchievementEntity achievement;
  final VoidCallback onDismiss;

  @override
  State<_AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<_AchievementToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();
    _timer = Timer(const Duration(seconds: 3), _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.achievement.color;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Position above the bottom nav bar (~80dp) + safe area
    final bottomOffset = bottomInset + 90.0;

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomOffset,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: _dismiss,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.95),
                      accent.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.40),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          widget.achievement.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Achievement Unlocked!',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white.withValues(alpha: 0.80),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.achievement.title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            widget.achievement.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
