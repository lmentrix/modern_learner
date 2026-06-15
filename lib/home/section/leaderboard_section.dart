import 'package:flutter/material.dart';
import 'package:modern_learner_production/home/data/home_data.dart';
import 'package:modern_learner_production/home/widgets/leaderboard_row.dart';
import 'package:modern_learner_production/theme/theme.dart';

class LeaderboardSection extends StatefulWidget {
  const LeaderboardSection({super.key, required this.animate});

  final bool animate;

  @override
  State<LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends State<LeaderboardSection>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _slides;
  late final List<Animation<double>> _fades;

  @override
  void initState() {
    super.initState();

    _ctrls = List.generate(
      mockLeaderboard.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );

    _slides = _ctrls
        .map((c) => Tween<double>(begin: 32, end: 0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOut),
            ))
        .toList();

    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    if (widget.animate) _launchStagger();
  }

  void _launchStagger() {
    for (var i = 0; i < _ctrls.length; i++) {
      Future.delayed(Duration(milliseconds: 80 * i), () {
        if (mounted) _ctrls[i].forward();
      });
    }
  }

  @override
  void didUpdateWidget(LeaderboardSection old) {
    super.didUpdateWidget(old);
    if (!old.animate && widget.animate) _launchStagger();
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final maxXp = mockLeaderboard.first.xp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EduSpacing.pagePadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Leaderboard', style: tt.headlineSmall),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See all',
                  style: tt.labelLarge?.copyWith(color: EduColors.primary),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: EduSpacing.s6),
          padding: const EdgeInsets.symmetric(vertical: EduSpacing.s3),
          decoration: BoxDecoration(
            color: EduColors.surface,
            borderRadius: EduRadius.borderXl,
            boxShadow: EduColors.shadowCard,
          ),
          child: Column(
            children: List.generate(mockLeaderboard.length, (i) {
              final user = mockLeaderboard[i];
              return AnimatedBuilder(
                animation: _ctrls[i],
                builder: (context, child) => Opacity(
                  opacity: _fades[i].value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(_slides[i].value, 0),
                    child: child,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: EduSpacing.s3,
                    vertical: EduSpacing.s1,
                  ),
                  child: LeaderboardRow(user: user, maxXp: maxXp),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
