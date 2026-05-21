import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';

class ProgressModuleTile extends StatefulWidget {
  const ProgressModuleTile({
    super.key,
    required this.step,
    this.onTap,
    this.isSelected = false,
    this.isLast = false,
  });

  final ProgressModuleStep step;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isLast;

  @override
  State<ProgressModuleTile> createState() => _ProgressModuleTileState();
}

class _ProgressModuleTileState extends State<ProgressModuleTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.step.isCurrent) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ProgressModuleTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step.isCurrent && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.step.isCurrent && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final isSelected = widget.isSelected;

    final nodeColor = step.isLocked
        ? AppColors.onSurfaceVariant.withValues(alpha: 0.35)
        : step.isCurrent
        ? step.toneColor
        : AppColors.tertiary;

    final lineColor = step.isLocked
        ? AppColors.outlineVariant.withValues(alpha: 0.18)
        : AppColors.outlineVariant.withValues(alpha: 0.35);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: step.isLocked ? 0.60 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline rail ─────────────────────────────────────────────────
          SizedBox(
            width: 48,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepNode(
                  step: step,
                  nodeColor: nodeColor,
                  isSelected: isSelected,
                  pulseAnimation: step.isCurrent ? _pulseAnimation : null,
                ),
                if (!widget.isLast)
                  Container(
                    width: 2,
                    height: 20,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor,
                          lineColor.withValues(alpha: 0.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
          ),
          // ── Card content ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 10,
                bottom: widget.isLast ? 0 : 12,
              ),
              child: _TileCard(
                step: step,
                isSelected: isSelected,
                onTap: step.isLocked ? null : widget.onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Node ─────────────────────────────────────────────────────────────────

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.step,
    required this.nodeColor,
    required this.isSelected,
    this.pulseAnimation,
  });

  final ProgressModuleStep step;
  final Color nodeColor;
  final bool isSelected;
  final Animation<double>? pulseAnimation;

  @override
  Widget build(BuildContext context) {
    Widget node = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: step.isLocked
            ? AppColors.surfaceContainerHighest
            : isSelected
            ? step.toneColor
            : nodeColor.withValues(alpha: 0.14),
        border: Border.all(
          color: isSelected
              ? step.toneColor
              : nodeColor.withValues(alpha: step.isLocked ? 0.3 : 0.55),
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: step.toneColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Center(
        child: step.isLocked
            ? Icon(Icons.lock_rounded, size: 14, color: nodeColor)
            : !step.isCurrent && step.progress >= 1.0
            ? Icon(
                Icons.check_rounded,
                size: 16,
                color: isSelected ? Colors.white : AppColors.tertiary,
              )
            : Text(
                '${step.chapterNumber}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : nodeColor,
                ),
              ),
      ),
    );

    if (pulseAnimation != null) {
      node = AnimatedBuilder(
        animation: pulseAnimation!,
        builder: (context, child) => Transform.scale(
          scale: pulseAnimation!.value,
          child: child,
        ),
        child: node,
      );
    }

    return node;
  }
}

// ── Tile Card ─────────────────────────────────────────────────────────────────

class _TileCard extends StatelessWidget {
  const _TileCard({
    required this.step,
    required this.isSelected,
    required this.onTap,
  });

  final ProgressModuleStep step;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? step.toneColor.withValues(alpha: 0.65)
        : step.isCurrent
        ? step.toneColor.withValues(alpha: 0.28)
        : AppColors.outlineVariant.withValues(alpha: 0.12);

    final bgColor = isSelected
        ? step.toneColor.withValues(alpha: 0.07)
        : AppColors.surfaceContainerLow;

    final statusLabel = step.isLocked
        ? 'Locked'
        : step.isCurrent
        ? 'In progress'
        : 'Completed';
    final statusColor = step.isLocked
        ? AppColors.onSurfaceVariant
        : step.isCurrent
        ? step.toneColor
        : AppColors.tertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: isSelected || step.isCurrent ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: step.toneColor.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── header row ───────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: step.toneColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        step.icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.eyebrow,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          step.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        isSelected
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: step.isLocked
                            ? AppColors.onSurfaceVariant
                            : step.toneColor,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
              // ── progress bar ─────────────────────────────────────────────
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: step.progress,
                        minHeight: 5,
                        backgroundColor:
                            AppColors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          step.isLocked
                              ? AppColors.onSurfaceVariant
                                  .withValues(alpha: 0.3)
                              : step.toneColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(step.progress * 100).round()}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: step.isLocked
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              // ── expanded detail ───────────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: isSelected
                    ? _ExpandedDetail(step: step)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Expanded Detail ───────────────────────────────────────────────────────────

class _ExpandedDetail extends StatelessWidget {
  const _ExpandedDetail({required this.step});

  final ProgressModuleStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                step.toneColor.withValues(alpha: 0.35),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          step.detail,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _DetailChip(
              icon: Icons.schedule_rounded,
              label: step.durationLabel,
              color: step.toneColor,
            ),
            const SizedBox(width: 8),
            _DetailChip(
              icon: Icons.menu_book_rounded,
              label: step.lessonCountLabel,
              color: step.toneColor,
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
