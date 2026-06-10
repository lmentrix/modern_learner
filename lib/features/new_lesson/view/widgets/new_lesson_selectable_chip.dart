import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class NewLessonSelectableChip extends StatefulWidget {
  const NewLessonSelectableChip({
    super.key,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
    required this.child,
  });

  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<NewLessonSelectableChip> createState() =>
      _NewLessonSelectableChipState();
}

class _NewLessonSelectableChipState extends State<NewLessonSelectableChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _scale = Tween<double>(begin: 1, end: 0.975).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapCancel: () => _pressController.reverse(),
        onTapUp: (_) => _pressController.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pressController,
          builder: (context, child) {
            return Transform.scale(scale: _scale.value, child: child);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.accentColor.withValues(alpha: 0.12)
                  : _isHovered
                  ? AppColors.surfaceContainer
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.isSelected
                    ? widget.accentColor.withValues(alpha: 0.42)
                    : _isHovered
                    ? widget.accentColor.withValues(alpha: 0.24)
                    : AppColors.outlineVariant.withValues(alpha: 0.14),
                width: widget.isSelected ? 1.4 : 1,
              ),
              boxShadow: widget.isSelected || _isHovered
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(
                          alpha: widget.isSelected ? 0.13 : 0.07,
                        ),
                        blurRadius: widget.isSelected ? 18 : 14,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
