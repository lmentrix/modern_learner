import 'package:flutter/material.dart';
import 'package:modern_learner_production/progress/data/progress_data.dart';
import 'package:modern_learner_production/theme/theme.dart';

class ProgressHeaderSection extends StatefulWidget {
  const ProgressHeaderSection({super.key, required this.animate});

  final bool animate;

  @override
  State<ProgressHeaderSection> createState() => _ProgressHeaderSectionState();
}

class _ProgressHeaderSectionState extends State<ProgressHeaderSection>
    with TickerProviderStateMixin {
  late final AnimationController _xpCtrl;
  late final AnimationController _countCtrl;
  late final Animation<double> _xpFill;
  late final Animation<int> _xpCount;
  late final Animation<int> _lessonCount;
  late final Animation<int> _hoursCount;

  @override
  void initState() {
    super.initState();
    _xpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _xpFill = CurvedAnimation(parent: _xpCtrl, curve: Curves.easeOut);
    _xpCount = IntTween(begin: 0, end: totalXp)
        .animate(CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut));
    _lessonCount = IntTween(begin: 0, end: lessonsCompleted)
        .animate(CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut));
    _hoursCount = IntTween(begin: 0, end: hoursStudied)
        .animate(CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut));

    if (widget.animate) _start();
  }

  void _start() {
    _xpCtrl.forward();
    _countCtrl.forward();
  }

  @override
  void didUpdateWidget(ProgressHeaderSection old) {
    super.didUpdateWidget(old);
    if (!old.animate && widget.animate) _start();
  }

  @override
  void dispose() {
    _xpCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pct = totalXp / xpGoal;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: EduSpacing.s6),
      padding: EduSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C5CFC), Color(0xFFA78BFA), Color(0xFFBDB4FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: EduRadius.borderXl,
        boxShadow: [
          BoxShadow(
            color: EduColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Level $currentLevel',
                      style: tt.labelLarge?.copyWith(
                          color: Colors.white70, letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  AnimatedBuilder(
                    animation: _xpCount,
                    builder: (context, _) => Text(
                      '${_xpCount.value} XP',
                      style: tt.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Level badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$currentLevel',
                  style: tt.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: EduSpacing.s4),

          // XP bar
          Text('$totalXp / $xpGoal XP to next level',
              style: tt.labelMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: EduSpacing.s2),
          LayoutBuilder(
            builder: (context, constraints) => AnimatedBuilder(
              animation: _xpFill,
              builder: (context, _) {
                final w = constraints.maxWidth;
                if (w <= 0) return const SizedBox(height: 8);
                final filled = (w * pct * _xpFill.value).clamp(0.0, w);
                return Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: EduRadius.borderPill,
                      ),
                    ),
                    Container(
                      height: 8,
                      width: filled < 4 ? 0 : filled,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: EduRadius.borderPill,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: EduSpacing.s5),

          // Stats row
          Row(
            children: [
              _StatPill(
                animation: _lessonCount,
                suffix: ' lessons',
                icon: Icons.menu_book_rounded,
              ),
              const SizedBox(width: EduSpacing.s3),
              _StatPill(
                animation: _hoursCount,
                suffix: ' hours',
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.animation,
    required this.suffix,
    required this.icon,
  });

  final Animation<int> animation;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: EduRadius.borderPill,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) => Text(
              '${animation.value}$suffix',
              style: tt.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
