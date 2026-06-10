import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class NewLessonActionSection extends StatefulWidget {
  const NewLessonActionSection({
    super.key,
    required this.canStart,
    required this.selectedLanguage,
    required this.selectedDifficulty,
    required this.onStart,
    this.isStarting = false,
  });

  final bool canStart;
  final bool isStarting;
  final String? selectedLanguage;
  final String selectedDifficulty;
  final VoidCallback onStart;

  @override
  State<NewLessonActionSection> createState() => _NewLessonActionSectionState();
}

class _NewLessonActionSectionState extends State<NewLessonActionSection> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.isStarting
        ? context.tr('Saving your course...')
        : widget.canStart
        ? '${context.tr(widget.selectedLanguage ?? '')} - ${context.tr(widget.selectedDifficulty)} ${context.tr('roadmap')}'
        : context.tr('Select a language to unlock generation');

    final actionLabel = widget.isStarting
        ? context.tr('Starting...')
        : widget.canStart
        ? '${context.tr('Generate')} ${context.tr(widget.selectedDifficulty)} ${context.tr('Roadmap')}'
        : context.tr('Choose a language first');

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.94),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.12),
            width: 0.6,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              summary,
              key: ValueKey(summary),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.canStart
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          MouseRegion(
            cursor: widget.canStart
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onEnter: widget.canStart
                ? (_) => setState(() => _isHovered = true)
                : null,
            onExit: widget.canStart
                ? (_) => setState(() => _isHovered = false)
                : null,
            child: GestureDetector(
              onTap: widget.canStart ? widget.onStart : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 58,
                decoration: BoxDecoration(
                  gradient: widget.canStart
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.secondary.withValues(alpha: 0.88),
                            AppColors.tertiary.withValues(alpha: 0.72),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            AppColors.surfaceContainerHigh,
                            AppColors.surfaceContainerHigh,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: widget.canStart
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: _isHovered ? 0.32 : 0.22,
                            ),
                            blurRadius: _isHovered ? 26 : 20,
                            offset: const Offset(0, 9),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.isStarting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            widget.canStart
                                ? Icons.auto_awesome_rounded
                                : Icons.lock_outline_rounded,
                            color: widget.canStart
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
                            size: 18,
                          ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        actionLabel,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: widget.canStart
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
