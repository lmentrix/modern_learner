import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class ActivityGrid extends StatefulWidget {
  const ActivityGrid({
    super.key,
    required this.animate,
    required this.activityDays,
  });

  final bool animate;
  final List<ActivityDay> activityDays;

  @override
  State<ActivityGrid> createState() => _ActivityGridState();
}

class _ActivityGridState extends State<ActivityGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(ActivityGrid old) {
    super.didUpdateWidget(old);
    if (!old.animate && widget.animate) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _cellColor(int intensity, double progress) {
    // Cells reveal progressively from oldest to newest
    if (intensity == 0) return EduColors.border.withValues(alpha: 0.5);
    final colors = [
      EduColors.primaryLight,
      EduColors.primary.withValues(alpha: 0.45),
      EduColors.primary.withValues(alpha: 0.75),
      EduColors.primary,
    ];
    return colors[intensity.clamp(0, 3)];
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.activityDays;
    final cols = days.isEmpty ? 0 : (days.length / 7).ceil();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final progress = _ctrl.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cols == 0 ? 'No activity yet' : 'Last $cols week${cols == 1 ? '' : 's'}',
                  style: GoogleFonts.caveat(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: EduColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Less',
                      style: GoogleFonts.caveat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: EduColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    ...List.generate(4, (i) => Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(left: 3),
                          decoration: BoxDecoration(
                            color: _cellColor(i, 1.0),
                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                          ),
                        )),
                    const SizedBox(width: 4),
                    Text(
                      'More',
                      style: GoogleFonts.caveat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: EduColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: EduSpacing.s3),
            if (cols == 0)
              SizedBox(
                height: 7 * 14.0 + 6 * 3,
                child: Row(
                  children: List.generate(10, (_) => Expanded(
                    child: Column(
                      children: List.generate(7, (row) => Padding(
                        padding: EdgeInsets.only(bottom: row == 6 ? 0 : 3),
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: EduColors.border.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.all(Radius.circular(3)),
                          ),
                        ),
                      )),
                    ),
                  )),
                ),
              )
            else
            SizedBox(
              height: 7 * 14.0 + 6 * 3,
              child: Row(
                children: List.generate(cols, (col) {
                  final colProgress = ((progress * cols) - col).clamp(0.0, 1.0);
                  return Expanded(
                    child: Column(
                      children: List.generate(7, (row) {
                        final idx = col * 7 + row;
                        if (idx >= days.length) return const SizedBox(height: 14);
                        final day = days[idx];
                        final isLastRow = row == 6;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLastRow ? 0 : 3),
                          child: Opacity(
                            opacity: colProgress,
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: _cellColor(day.intensity, colProgress),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(3)),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}
