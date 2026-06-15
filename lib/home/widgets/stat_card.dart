import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/home/model/home_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class StatCard extends StatefulWidget {
  const StatCard({super.key, required this.stat, required this.animate});

  final QuickStat stat;
  final bool animate;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<int> _counter;

  @override
  void initState() {
    super.initState();
    final target = int.tryParse(widget.stat.value) ?? 0;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _counter = IntTween(begin: 0, end: target).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(StatCard old) {
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
    final bg = Color(widget.stat.cardColor);

    return Container(
      padding: EduSpacing.cardPadding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: EduRadius.borderXl,
        boxShadow: EduColors.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: EduRadius.borderMd,
                  boxShadow: EduColors.shadowCard,
                ),
                child: Icon(
                  IconData(widget.stat.iconData, fontFamily: 'MaterialIcons'),
                  size: 20,
                  color: EduColors.textPrimary,
                ),
              ),
              const Icon(Icons.north_east_rounded,
                  size: 18, color: EduColors.textSecondary),
            ],
          ),
          const SizedBox(height: EduSpacing.s3),

          // Label in Caveat — the subtle sketch touch
          Text(
            widget.stat.label,
            style: GoogleFonts.caveat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: EduColors.textSecondary,
            ),
          ),
          const SizedBox(height: EduSpacing.s1),

          // Big number stays crisp (data should read cleanly)
          AnimatedBuilder(
            animation: _counter,
            builder: (context, _) => Text(
              '${_counter.value}',
              style: _dataNumber,
            ),
          ),

          // Unit in Caveat
          Text(
            widget.stat.unit,
            style: GoogleFonts.caveat(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: EduColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Data numbers stay in PlusJakartaSans — they should read as precise metrics
const _dataNumber = TextStyle(
  fontFamily: 'PlusJakartaSans',
  fontSize: 44,
  fontWeight: FontWeight.w700,
  height: 1.0,
  color: EduColors.textPrimary,
  fontFamilyFallback: ['sans-serif'],
);
