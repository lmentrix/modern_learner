import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/learning_activity_summary.dart';
import 'package:modern_learner_production/features/profile/state/learning_activity_monitor.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_footer_stat.dart';

class ProfileActivityChart extends StatefulWidget {
  const ProfileActivityChart({super.key})
    : summary = null,
      onRefresh = null,
      isLoading = false;

  const ProfileActivityChart.fromSummary({
    super.key,
    required LearningActivitySummary this.summary,
    required VoidCallback this.onRefresh,
    this.isLoading = false,
  });

  final LearningActivitySummary? summary;
  final VoidCallback? onRefresh;
  final bool isLoading;

  @override
  State<ProfileActivityChart> createState() => _ProfileActivityChartState();
}

class _ProfileActivityChartState extends State<ProfileActivityChart> {
  @override
  void initState() {
    super.initState();
    // Only use monitor when not externally driven.
    if (widget.summary == null) {
      LearningActivityMonitor.instance.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    if (summary != null) {
      return _ActivityCard(
        summary: summary,
        isLoading: widget.isLoading,
        onRefresh: widget.onRefresh ?? () {},
      );
    }
    return ValueListenableBuilder<LearningActivityMonitorState>(
      valueListenable: LearningActivityMonitor.instance.state,
      builder: (context, state, child) {
        return _ActivityCard(
          summary: state.summary,
          isLoading: state.isLoading,
          onRefresh: LearningActivityMonitor.instance.refresh,
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.summary,
    required this.isLoading,
    required this.onRefresh,
  });

  final LearningActivitySummary summary;
  final bool isLoading;
  final VoidCallback onRefresh;

  static const _maxBarHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    final days = summary.days;
    final maxActivity = summary.bestDayMinutes > 0 ? summary.bestDayMinutes : 1;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        return Opacity(
          opacity: progress,
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
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Refresh',
                      onPressed: isLoading ? null : onRefresh,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.onSurfaceVariant,
                        size: 18,
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
                        summary.totalFormatted,
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
                    children: List.generate(days.length, (index) {
                      final day = days[index];
                      final isToday = index == summary.todayIndex;
                      final isMax =
                          day.minutes > 0 &&
                          day.minutes == summary.bestDayMinutes;
                      final barHeight =
                          (day.minutes / maxActivity) * _maxBarHeight;
                      final animatedHeight = barHeight * progress;
                      final count = (day.minutes * progress).round();

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
                                      height: animatedHeight,
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
                                  height: animatedHeight.clamp(
                                    4.0,
                                    _maxBarHeight,
                                  ),
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
                      value: LearningActivitySummary.formatMinutes(
                        summary.bestDayMinutes,
                      ),
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFFF9500),
                    ),
                    const SizedBox(width: 8),
                    ProfileFooterStat(
                      label: 'Daily avg',
                      value: LearningActivitySummary.formatMinutes(
                        summary.dailyAverageMinutes,
                      ),
                      icon: Icons.trending_up_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    ProfileFooterStat(
                      label: 'Days active',
                      value: '${summary.daysActive}/7',
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
