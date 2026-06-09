import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class ViewProfileHeroSection extends StatelessWidget {
  const ViewProfileHeroSection({
    super.key,
    required this.initial,
    required this.displayName,
    required this.email,
    required this.isVip,
    required this.onBackTap,
  });

  final String initial;
  final String displayName;
  final String email;
  final bool isVip;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isVip
              ? [Color(0xFF1A1200), AppColors.surface]
              : [Color(0xFF0E1020), AppColors.surface],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBackTap,
                  icon: Icon(Icons.arrow_back_ios_rounded),
                  color: AppColors.onSurface,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: isVip
                      ? LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        )
                      : AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isVip ? Color(0xFFFFD700) : AppColors.primaryDim)
                          .withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: AppColors.surface, width: 3),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1028),
                    ),
                  ),
                ),
              ),
              if (isVip)
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('👑', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              displayName,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              email,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'LVL 8 · Advanced',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1028),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (isVip)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '★ VIP',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1028),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
