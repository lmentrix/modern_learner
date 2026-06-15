import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/theme/theme.dart';

class XpProgressBar extends StatefulWidget {
  const XpProgressBar({
    super.key,
    required this.xp,
    required this.goal,
    required this.animate,
  });

  final int xp;
  final int goal;
  final bool animate;

  @override
  State<XpProgressBar> createState() => _XpProgressBarState();
}

class _XpProgressBarState extends State<XpProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fill;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fill = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(XpProgressBar old) {
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
    final pct = (widget.xp / widget.goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Caveat for the label — feels hand-annotated
            Text(
              '${widget.xp} XP',
              style: GoogleFonts.caveat(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: EduColors.primary,
              ),
            ),
            Text(
              'goal: ${widget.goal}',
              style: GoogleFonts.caveat(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: EduColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: EduSpacing.s1),
        LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedBuilder(
              animation: _fill,
              builder: (context, _) {
                final width = constraints.maxWidth;
                if (width <= 0) return const SizedBox(height: 8.0);
                final filled = (width * pct * _fill.value).clamp(0.0, width);
                return Stack(
                  children: [
                    // Track
                    Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        color: EduColors.primaryLight,
                        borderRadius: EduRadius.borderPill,
                      ),
                    ),
                    // Fill
                    if (filled >= 4)
                      Container(
                        height: 8,
                        width: filled,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [EduColors.primaryLight, EduColors.primary],
                          ),
                          borderRadius: EduRadius.borderPill,
                          boxShadow: [
                            BoxShadow(
                              color: EduColors.primary.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
