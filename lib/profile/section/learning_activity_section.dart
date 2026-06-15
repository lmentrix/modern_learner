import 'package:flutter/material.dart';
import 'package:modern_learner_production/profile/widgets/activity_grid.dart';
import 'package:modern_learner_production/theme/theme.dart';

class LearningActivitySection extends StatefulWidget {
  const LearningActivitySection({super.key, required this.animate});

  final bool animate;

  @override
  State<LearningActivitySection> createState() =>
      _LearningActivitySectionState();
}

class _LearningActivitySectionState extends State<LearningActivitySection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(LearningActivitySection old) {
    super.didUpdateWidget(old);
    if (!old.animate && widget.animate) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EduSpacing.pagePadding,
          child: Container(
            padding: EduSpacing.cardPadding,
            decoration: BoxDecoration(
              color: EduColors.surface,
              borderRadius: EduRadius.borderXl,
              boxShadow: EduColors.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Learning Activity', style: tt.titleLarge),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: EduColors.primaryLight,
                        borderRadius: EduRadius.borderPill,
                      ),
                      child: Text(
                        '10 weeks',
                        style: tt.labelMedium
                            ?.copyWith(color: EduColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: EduSpacing.s5),
                ActivityGrid(animate: widget.animate),
                const SizedBox(height: EduSpacing.s5),

                // Weekly summary pills
                Row(
                  children: [
                    _SummaryPill(
                      label: 'Best week',
                      value: '6 days',
                      color: EduColors.accentGreen,
                    ),
                    const SizedBox(width: EduSpacing.s2),
                    _SummaryPill(
                      label: 'This week',
                      value: '5 days',
                      color: EduColors.primaryLight,
                    ),
                    const SizedBox(width: EduSpacing.s2),
                    _SummaryPill(
                      label: 'Total days',
                      value: '58',
                      color: EduColors.accentYellow,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: EduRadius.borderMd,
        ),
        child: Column(
          children: [
            Text(value,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: tt.labelSmall),
          ],
        ),
      ),
    );
  }
}
