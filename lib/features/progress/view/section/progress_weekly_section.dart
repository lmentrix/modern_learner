import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_constants.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_data.dart';
import 'package:modern_learner_production/features/progress/data/progress_week_day.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_section_heading.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_week_bar.dart';

class ProgressWeeklySection extends StatefulWidget {
  const ProgressWeeklySection({super.key, required this.data});

  final ProgressPageData data;

  @override
  State<ProgressWeeklySection> createState() => _ProgressWeeklySectionState();
}

class _ProgressWeeklySectionState extends State<ProgressWeeklySection> {
  int? _selectedDayIndex;

  @override
  Widget build(BuildContext context) {
    final accent = widget.data.snapshot.accentColor;
    final mins = widget.data.snapshot.weeklyMinutes;
    final goal = widget.data.snapshot.weeklyGoalMinutes;
    final weekPct = (mins / goal).clamp(0.0, 1.0);
    final weekDays = widget.data.weekDays;

    final selectedDay =
        _selectedDayIndex != null && _selectedDayIndex! < weekDays.length
            ? weekDays[_selectedDayIndex!]
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressSectionHeading(
          eyebrow: 'RHYTHM',
          title: 'A week that actually looks alive',
          subtitle:
              'Daily minutes stay uneven on purpose. The goal is a sustainable cadence, not seven identical sessions.',
          accentColor: accent,
        ),
        const SizedBox(height: 18),
        // ── bar chart card ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius:
                BorderRadius.circular(ProgressPageConstants.cardRadius),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── bar chart ─────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < weekDays.length; i++)
                    Expanded(
                      child: Center(
                        child: ProgressWeekBar(
                          day: weekDays[i],
                          accentColor: accent,
                          isSelected: _selectedDayIndex == i,
                          onTap: () => setState(() {
                            _selectedDayIndex =
                                _selectedDayIndex == i ? null : i;
                          }),
                        ),
                      ),
                    ),
                ],
              ),
              // ── selected day detail ───────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: selectedDay != null
                    ? _SelectedDayDetail(
                        day: selectedDay,
                        accentColor: accent,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // ── weekly goal card ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bolt_rounded,
                        color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Weekly goal',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '$mins / $goal min',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: weekPct),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 7,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 12),
              Text(
                '$mins minutes logged this week. '
                'Your strongest days cluster around the middle of the week, '
                'which is a good sign that the routine is sticking.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Selected Day Detail ───────────────────────────────────────────────────────

class _SelectedDayDetail extends StatelessWidget {
  const _SelectedDayDetail({required this.day, required this.accentColor});

  final ProgressWeekDay day;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final pct = (day.minutes / day.goalMinutes).clamp(0.0, 1.0);
    final pctLabel = '${(pct * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.12),
                border: Border.all(
                    color: accentColor.withValues(alpha: 0.28)),
              ),
              child: Center(
                child: Text(
                  day.label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.minutes > 0
                        ? '${day.minutes} min studied'
                        : 'No session logged',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Goal: ${day.goalMinutes} min · $pctLabel of daily target',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              pctLabel,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
