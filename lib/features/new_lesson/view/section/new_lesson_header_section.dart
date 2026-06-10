import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/utils/responsive.dart';
import 'package:modern_learner_production/features/new_lesson/data/new_lesson_page_constants.dart';

class NewLessonHeaderSection extends StatelessWidget {
  const NewLessonHeaderSection({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.hPad(context);
    final isWide = Responsive.isTabletOrDesktop(context);
    final titleSize = isWide ? 38.0 : 31.0;

    return Container(
      decoration: BoxDecoration(
        gradient: NewLessonPageConstants.headerGradient,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.10),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Responsive.maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CloseButton(onClose: onClose),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.mic_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.tr('VOICE LESSON'),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wideText = constraints.maxWidth >= 720;
                      final title = Text(
                        context.tr('New Voice Lesson'),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          height: 1.02,
                        ),
                      );
                      final subtitle = Text(
                        context.tr(
                          'Choose a language and challenge level, then generate a focused speaking roadmap.',
                        ),
                        style: GoogleFonts.inter(
                          fontSize: Responsive.bodySize(context),
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      );

                      if (wideText) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: title),
                            const SizedBox(width: 28),
                            Expanded(flex: 6, child: subtitle),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [title, const SizedBox(height: 8), subtitle],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  const _CloseButton({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onClose,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.surfaceContainer
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.outlineVariant.withValues(alpha: 0.12),
            ),
          ),
          child: Icon(
            Icons.close_rounded,
            color: _isHovered ? AppColors.primary : AppColors.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }
}
