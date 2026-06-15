import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final maxXp = mockLeaderboard.first.xp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EduSpacing.pagePadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Leaderboard',
                    style: GoogleFonts.caveat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: EduColors.textPrimary,
                    ),
                  ),
                  CustomPaint(
                    painter: _ThinAccentLine(),
                    size: const Size(96, 5),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'See all →',
                  style: GoogleFonts.caveat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: EduColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: EduSpacing.s2),
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

class _ThinAccentLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.6)
        ..quadraticBezierTo(
            size.width * 0.30, size.height * 0.1,
            size.width * 0.62, size.height * 0.7)
        ..lineTo(size.width * 0.90, size.height * 0.3),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.40)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ThinAccentLine old) => false;
}
