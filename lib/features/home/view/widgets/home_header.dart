import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/view/widgets/streak_badge.dart';

class _VipBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👑', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            'VIP',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header widget for the home page showing greeting, avatar, and streak.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.displayName,
    required this.onAvatarTap,
    required this.onStreakTap,
    this.isVip = false,
  });

  final String displayName;
  final VoidCallback onAvatarTap;
  final VoidCallback onStreakTap;
  final bool isVip;

  String get _initial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E1020), AppColors.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning,',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            '$displayName 👋',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (isVip) ...[
                          const SizedBox(width: 8),
                          _VipBadge(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Avatar
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 44,
                  height: 44,
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
                      _initial,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(onTap: onStreakTap, child: const StreakBadge()),
        ],
      ),
    );
  }
}
