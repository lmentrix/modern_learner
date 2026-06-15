import 'package:flutter/material.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class AiActionBar extends StatefulWidget {
  const AiActionBar({
    super.key,
    required this.selectedText,
    required this.onAction,
    required this.visible,
  });

  final String selectedText;
  final ValueChanged<AiAction> onAction;
  final bool visible;

  @override
  State<AiActionBar> createState() => _AiActionBarState();
}

class _AiActionBarState extends State<AiActionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    if (widget.visible) _ctrl.forward();
  }

  @override
  void didUpdateWidget(AiActionBar old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) _ctrl.forward();
    if (!widget.visible && old.visible) _ctrl.reverse();
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: EduSpacing.s6),
          padding: const EdgeInsets.symmetric(horizontal: EduSpacing.s4, vertical: EduSpacing.s3),
          decoration: BoxDecoration(
            color: EduColors.textPrimary,
            borderRadius: EduRadius.borderXl,
            boxShadow: EduColors.shadowRaised,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AiChip(
                icon: Icons.auto_awesome_rounded,
                label: 'Explain',
                onTap: () => widget.onAction(AiAction.explain),
                tt: tt,
              ),
              Container(width: 1, height: 24, color: Colors.white12),
              _AiChip(
                icon: Icons.image_outlined,
                label: 'Imagine',
                onTap: () => widget.onAction(AiAction.imagine),
                tt: tt,
              ),
              Container(width: 1, height: 24, color: Colors.white12),
              _AiChip(
                icon: Icons.edit_note_rounded,
                label: 'Take note',
                onTap: () => widget.onAction(AiAction.takeNote),
                tt: tt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiChip extends StatelessWidget {
  const _AiChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tt,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: EduColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: tt.labelSmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
