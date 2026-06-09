import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/utils/responsive.dart';
import 'package:modern_learner_production/features/home/view/widgets/arc_progress_painter.dart';
import 'package:modern_learner_production/features/home/view/widgets/glass_card.dart';

class ProgressOverviewCard extends StatefulWidget {
  const ProgressOverviewCard({
    super.key,
    required this.level,
    required this.xp,
    required this.xpToNext,
    required this.progress,
    this.rankTitle = 'Advanced Learner',
    this.onTap,
  });

  final int level;
  final int xp;
  final int xpToNext;
  final double progress;
  final String rankTitle;
  final VoidCallback? onTap;

  @override
  State<ProgressOverviewCard> createState() => _ProgressOverviewCardState();
}

class _ProgressOverviewCardState extends State<ProgressOverviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isTabletOrDesktop(context);
    final arcSize = isWide ? 140.0 : 120.0;
    final rankFontSize = isWide ? 26.0 : 22.0;
    final cardPadding = isWide ? 28.0 : 24.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: GlassCard(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          children: [
            // Arc progress
            SizedBox(
              width: arcSize,
              height: arcSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(arcSize, arcSize),
                    painter: ArcProgressPainter(
                      progress: widget.progress,
                      animation: _anim,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _anim,
                        builder: (_, _) => Text(
                          '${(widget.progress * _anim.value * 100).round()}%',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: isWide ? 26.0 : 22.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        'overall',
                        style: GoogleFonts.inter(
                          fontSize: isWide ? 12.0 : 11.0,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: isWide ? 28 : 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'LEVEL ${widget.level}',
                      style: GoogleFonts.inter(
                        fontSize: isWide ? 12.0 : 11.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.rankTitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: rankFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: widget.xp / widget.xpToNext,
                      minHeight: isWide ? 8 : 6,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.tertiary,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${widget.xp} XP',
                        style: GoogleFonts.inter(
                          fontSize: isWide ? 13.0 : 12.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiary,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          ' / ${widget.xpToNext} to Level ${widget.level + 1}',
                          style: GoogleFonts.inter(
                            fontSize: isWide ? 13.0 : 12.0,
                            color: AppColors.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
