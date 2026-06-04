import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';
import 'package:modern_learner_production/features/progress/service/model/chapter_subcontent_model.dart';

class ProgressModuleTile extends StatefulWidget {
  const ProgressModuleTile({
    super.key,
    required this.step,
    this.onTap,
    this.isSelected = false,
    this.isLast = false,
    this.chapterSubcontentResponse,
    this.isLoadingSubcontent = false,
    this.isLoadingFromCache = false,
    this.subcontentError,
    this.onRetrySubcontent,
    this.onSubcontentTap,
    this.completedSubcontents = 0,
  });

  final ProgressModuleStep step;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isLast;
  final ChapterSubcontentResponseModel? chapterSubcontentResponse;
  final bool isLoadingSubcontent;
  final bool isLoadingFromCache;
  final String? subcontentError;
  final VoidCallback? onRetrySubcontent;
  final ValueChanged<ChapterSubcontentItemModel>? onSubcontentTap;
  final int completedSubcontents;

  @override
  State<ProgressModuleTile> createState() => _ProgressModuleTileState();
}

class _ProgressModuleTileState extends State<ProgressModuleTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: step.isLocked ? 0.55 : 1.0,
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tile row ─────────────────────────────────────────────────
            GestureDetector(
              onTapDown: step.isLocked
                  ? null
                  : (_) => _pressCtrl.forward(),
              onTapUp: step.isLocked
                  ? null
                  : (_) {
                      _pressCtrl.reverse();
                      widget.onTap?.call();
                    },
              onTapCancel: step.isLocked
                  ? null
                  : () => _pressCtrl.reverse(),
              child: AnimatedBuilder(
                animation: _pressCtrl,
                builder: (context, child) =>
                    Transform.scale(scale: _scaleAnim.value, child: child),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? step.toneColor.withValues(alpha: 0.06)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isSelected
                          ? step.toneColor.withValues(alpha: 0.60)
                          : step.isCurrent
                          ? step.toneColor.withValues(alpha: 0.25)
                          : AppColors.outlineVariant.withValues(alpha: 0.10),
                      width: widget.isSelected || step.isCurrent ? 1.5 : 1,
                    ),
                    boxShadow: widget.isSelected
                        ? [
                            BoxShadow(
                              color: step.toneColor.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // ── Icon box ─────────────────────────────────────
                          _IconBox(step: step, isSelected: widget.isSelected),
                          const SizedBox(width: 14),
                          // ── Text column ──────────────────────────────────
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                    height: 1.1,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${step.durationLabel} · ${step.lessonCountLabel}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // ── Status + chevron ─────────────────────────────
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _StatusPill(step: step),
                              const SizedBox(height: 6),
                              AnimatedRotation(
                                turns: widget.isSelected ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutCubic,
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: step.isLocked
                                      ? AppColors.onSurfaceVariant
                                      : step.toneColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // ── Progress bar ────────────────────────────────────
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: step.progress,
                                minHeight: 4,
                                backgroundColor:
                                    AppColors.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  step.isLocked
                                      ? AppColors.onSurfaceVariant
                                          .withValues(alpha: 0.25)
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
                      // ── Expanded detail ─────────────────────────────────
                      AnimatedSize(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        child: widget.isSelected
                            ? _ExpandedDetail(step: step)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Subcontent panel ─────────────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: widget.isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _SubcontentPanel(
                        step: step,
                        response: widget.chapterSubcontentResponse,
                        isLoading: widget.isLoadingSubcontent,
                        isLoadingFromCache: widget.isLoadingFromCache,
                        errorMessage: widget.subcontentError,
                        onRetry: widget.onRetrySubcontent,
                        onSubcontentTap: widget.onSubcontentTap,
                        completedSubcontents: widget.completedSubcontents,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Icon Box ──────────────────────────────────────────────────────────────────

class _IconBox extends StatelessWidget {
  const _IconBox({required this.step, required this.isSelected});

  final ProgressModuleStep step;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = step.isLocked
        ? AppColors.onSurfaceVariant.withValues(alpha: 0.35)
        : step.toneColor;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isSelected
            ? step.toneColor.withValues(alpha: 0.18)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(color: step.toneColor.withValues(alpha: 0.35))
            : null,
      ),
      child: Center(
        child: step.isLocked
            ? Icon(Icons.lock_rounded, size: 18, color: color)
            : !step.isCurrent && step.progress >= 1.0
            ? Icon(
                Icons.check_rounded,
                size: 20,
                color: isSelected ? step.toneColor : AppColors.tertiary,
              )
            : Text(step.icon, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}

// ── Status Pill ───────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.step});

  final ProgressModuleStep step;

  @override
  Widget build(BuildContext context) {
    final label = step.isLocked
        ? 'Locked'
        : step.progress >= 1.0
        ? 'Done'
        : step.isCurrent
        ? 'Active'
        : 'Completed';
    final color = step.isLocked
        ? AppColors.onSurfaceVariant
        : step.progress >= 1.0
        ? AppColors.tertiary
        : step.toneColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
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
                step.toneColor.withValues(alpha: 0.30),
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
            height: 1.58,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Chip(
              icon: Icons.schedule_rounded,
              label: step.durationLabel,
              color: step.toneColor,
            ),
            const SizedBox(width: 8),
            _Chip(
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

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

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
        border: Border.all(color: color.withValues(alpha: 0.18)),
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

// ── Subcontent Panel ──────────────────────────────────────────────────────────

class _SubcontentPanel extends StatelessWidget {
  const _SubcontentPanel({
    required this.step,
    required this.response,
    required this.isLoading,
    this.isLoadingFromCache = false,
    required this.errorMessage,
    required this.onRetry,
    required this.onSubcontentTap,
    this.completedSubcontents = 0,
  });

  final ProgressModuleStep step;
  final ChapterSubcontentResponseModel? response;
  final bool isLoading;
  final bool isLoadingFromCache;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final ValueChanged<ChapterSubcontentItemModel>? onSubcontentTap;
  final int completedSubcontents;

  @override
  Widget build(BuildContext context) => _buildBody();

  Widget _buildBody() {
    if (isLoading) return _LoadingRow(step: step, isGenerating: !isLoadingFromCache);
    final error = errorMessage;
    if (error != null) return _ErrorRow(step: step, message: error, onRetry: onRetry);
    final payload = response?.chapterSubcontent;
    if (payload == null) {
      return _ErrorRow(
        step: step,
        message: 'Could not load the chapter build.',
        onRetry: onRetry,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < payload.subcontents.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i < payload.subcontents.length - 1 ? 6 : 0,
            ),
            child: _SubcontentRow(
              item: payload.subcontents[i],
              accent: step.toneColor,
              isCompleted:
                  payload.subcontents[i].subcontentNumber <= completedSubcontents,
              isLocked:
                  payload.subcontents[i].subcontentNumber >
                  completedSubcontents + 1,
              onTap: onSubcontentTap == null ||
                      payload.subcontents[i].subcontentNumber >
                          completedSubcontents + 1
                  ? null
                  : () => onSubcontentTap!(payload.subcontents[i]),
            ),
          ),
      ],
    );
  }
}

// ── Loading row ───────────────────────────────────────────────────────────────

class _LoadingRow extends StatelessWidget {
  const _LoadingRow({required this.step, this.isGenerating = true});

  final ProgressModuleStep step;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              valueColor: AlwaysStoppedAnimation<Color>(
                isGenerating ? step.toneColor : AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isGenerating
                ? 'Building chapter ${step.chapterNumber}…'
                : 'Loading…',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error row ─────────────────────────────────────────────────────────────────

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({
    required this.step,
    required this.message,
    required this.onRetry,
  });

  final ProgressModuleStep step;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 14,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: step.toneColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Subcontent Row ────────────────────────────────────────────────────────────

class _SubcontentRow extends StatelessWidget {
  const _SubcontentRow({
    required this.item,
    required this.accent,
    required this.onTap,
    this.isCompleted = false,
    this.isLocked = false,
  });

  final ChapterSubcontentItemModel item;
  final Color accent;
  final VoidCallback? onTap;
  final bool isCompleted;
  final bool isLocked;

  static Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'lesson':
      case 'foundation':
        return AppColors.primary;
      case 'practice':
      case 'guided_practice':
        return AppColors.secondary;
      case 'quiz':
      case 'review':
        return const Color(0xFFFF9500);
      case 'speaking':
        return const Color(0xFF26C6DA);
      case 'chapter_checkpoint':
        return const Color(0xFF9C27B0);
      default:
        return AppColors.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = isLocked
        ? AppColors.onSurfaceVariant.withValues(alpha: 0.40)
        : _typeColor(item.subcontentType);
    final effectiveAccent = isLocked
        ? AppColors.onSurfaceVariant.withValues(alpha: 0.35)
        : accent;

    return Opacity(
      opacity: isLocked ? 0.55 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCompleted
                    ? AppColors.tertiary.withValues(alpha: 0.30)
                    : typeColor.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                // Number / check / lock dot
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.tertiary.withValues(alpha: 0.14)
                        : typeColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: AppColors.tertiary,
                          )
                        : isLocked
                        ? Icon(
                            Icons.lock_rounded,
                            size: 11,
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          )
                        : Text(
                            '${item.subcontentNumber}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: typeColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                // Title
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isLocked
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Duration
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: effectiveAccent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 10,
                        color: effectiveAccent,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${item.estimatedMinutes} min',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: effectiveAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLocked && onTap != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: typeColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
