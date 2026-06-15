import 'package:flutter/material.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class StatChip extends StatefulWidget {
  const StatChip({super.key, required this.stat, required this.animate});

  final StatItem stat;
  final bool animate;

  @override
  State<StatChip> createState() => _StatChipState();
}

class _StatChipState extends State<StatChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<int> _count;

  @override
  void initState() {
    super.initState();
    final raw = widget.stat.value.replaceAll(RegExp(r'[^0-9]'), '');
    final target = int.tryParse(raw) ?? 0;

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _count = IntTween(begin: 0, end: target)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(StatChip old) {
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
    final bg = Color(widget.stat.accentColor);
    final suffix = widget.stat.value.replaceAll(RegExp(r'[0-9]'), '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: EduColors.surface,
        borderRadius: EduRadius.borderXl,
        boxShadow: EduColors.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: EduRadius.borderMd),
            child: Icon(
              IconData(widget.stat.icon, fontFamily: 'MaterialIcons'),
              size: 18,
              color: EduColors.textPrimary,
            ),
          ),
          const SizedBox(height: EduSpacing.s3),
          AnimatedBuilder(
            animation: _count,
            builder: (context, _) => Text(
              '${_count.value}$suffix',
              style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(widget.stat.label, style: tt.labelLarge),
        ],
      ),
    );
  }
}
