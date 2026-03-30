import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// 全局主布局 - 包含唯一的底部导航栏
class MainLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavigationBarWidget(currentIndex: currentIndex),
    );
  }
}

/// 底部导航栏组件 - 全局唯一
class _BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;

  const _BottomNavigationBarWidget({required this.currentIndex});

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
                    onTap: () => context.go('/'),
                  ),
                  _NavItem(
                    icon: Icons.explore_rounded,
                    label: 'Explore',
                    isActive: currentIndex == 1,
                    activeColor: AppColors.primary,
                    onTap: () => context.go('/explore'),
                  ),
                  _NavItem(
                    icon: Icons.mic_rounded,
                    label: 'Voice',
                    isActive: currentIndex == 2,
                    activeColor: AppColors.primary,
                    centerFab: true,
                    onTap: () {},
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Progress',
                    isActive: currentIndex == 3,
                    activeColor: AppColors.primary,
                    onTap: () => context.go('/progress'),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    isActive: currentIndex == 4,
                    activeColor: AppColors.primary,
                    onTap: () {},
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
