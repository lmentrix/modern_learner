import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_data.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_footer_stat.dart';

class ProfileActivityChart extends StatefulWidget {
  const ProfileActivityChart({super.key});

  @override
  State<ProfileActivityChart> createState() => _ProfileActivityChartState();
}

class _ProfileActivityChartState extends State<ProfileActivityChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _barAnimations;
  late final List<Animation<int>> _countAnimations;

  static const _maxBarHeight = 72.0;
  static const _todayIndex = 4;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    const weekDays = ProfilePageData.weekDays;
    final maxActivity = weekDays
        .map((day) => day.minutes)
        .reduce((left, right) => left > right ? left : right);

    _barAnimations = List.generate(weekDays.length, (index) {
      final start = (index * 0.08).clamp(0.0, 0.7);
      final end = (start + 0.55).clamp(0.0, 1.0);
      return Tween<double>(
        begin: 0,
        end: (weekDays[index].minutes / maxActivity) * _maxBarHeight,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _countAnimations = List.generate(weekDays.length, (index) {
      final start = (index * 0.08).clamp(0.0, 0.7);
      final end = (start + 0.55).clamp(0.0, 1.0);
      return IntTween(begin: 0, end: weekDays[index].minutes).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _totalMinutes =>
      ProfilePageData.weekDays.fold(0, (sum, day) => sum + day.minutes);

  String get _totalFormatted {
    final hours = _totalMinutes ~/ 60;
    final minutes = _totalMinutes % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    const weekDays = ProfilePageData.weekDays;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learning Activity',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'This week',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        _totalFormatted,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: _maxBarHeight + 52,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(weekDays.length, (index) {
                      final day = weekDays[index];
                      final isToday = index == _todayIndex;
                      final isMax =
                          day.minutes ==
                          weekDays
                              .map((item) => item.minutes)
                              .reduce(
                                (left, right) => left > right ? left : right,
                              );
                      final barHeight = _barAnimations[index].value;
                      final count = _countAnimations[index].value;

                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${count}m',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: isToday
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant.withValues(
                                          alpha: 0.7,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                if (isMax || isToday)
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: 28,
                                      height: barHeight,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.40,
                                            ),
                                            blurRadius: 12,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Container(
                                  width: 22,
                                  height: barHeight.clamp(4.0, _maxBarHeight),
                                  decoration: BoxDecoration(
                                    gradient: isToday || isMax
                                        ? const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xFF7C3AED),
                                              AppColors.primary,
                                            ],
                                          )
                                        : LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.primary.withValues(
                                                alpha: 0.5,
                                              ),
                                              AppColors.primary.withValues(
                                                alpha: 0.25,
                                              ),
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: isToday
                                  ? BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.40,
                                        ),
                                      ),
                                    )
                                  : null,
                              child: Center(
                                child: Text(
                                  day.label,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: isToday
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: isToday
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ProfileFooterStat(
                      label: 'Best day',
                      value: '${weekDays[_todayIndex].minutes}m',
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFFF9500),
                    ),
                    const SizedBox(width: 8),
                    ProfileFooterStat(
                      label: 'Daily avg',
                      value: '${(_totalMinutes / weekDays.length).round()}m',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    ProfileFooterStat(
                      label: 'Days active',
                      value:
                          '${weekDays.where((day) => day.minutes > 0).length}/7',
                      icon: Icons.calendar_today_rounded,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
