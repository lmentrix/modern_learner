import 'package:flutter/material.dart';
import 'package:modern_learner_production/profile/data/profile_data.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class ActivityGrid extends StatefulWidget {
  const ActivityGrid({super.key, required this.animate});

  final bool animate;

  @override
  State<ActivityGrid> createState() => _ActivityGridState();
}

class _ActivityGridState extends State<ActivityGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<ActivityDay> _days;

  @override
  void initState() {
    super.initState();
    _days = generateActivityGrid();
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
    final tt = Theme.of(context).textTheme;
    // Arrange into 10 columns of 7 rows (Mon–Sun)
    const cols = 10;
    const rows = 7;

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
                Text('Last 10 weeks', style: tt.labelMedium),
                Row(
                  children: [
                    Text('Less', style: tt.labelSmall),
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
                    Text('More', style: tt.labelSmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: EduSpacing.s3),
            SizedBox(
              height: rows * 14.0 + (rows - 1) * 3,
              child: Row(
                children: List.generate(cols, (col) {
                  // Each column reveals based on progress
                  final colProgress = ((progress * cols) - col).clamp(0.0, 1.0);
                  return Expanded(
                    child: Column(
                      children: List.generate(rows, (row) {
                        final idx = col * rows + row;
                        if (idx >= _days.length) return const SizedBox(height: 14);
                        final day = _days[idx];
                        final isLastRow = row == rows - 1;
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
