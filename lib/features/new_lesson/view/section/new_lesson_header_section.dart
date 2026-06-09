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
    final titleSize = isWide ? 42.0 : 34.0;

    return Container(
      decoration: BoxDecoration(
        gradient: NewLessonPageConstants.headerGradient,
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
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
              child: Stack(
                children: [
                  Positioned(
                    right: -36,
                    top: -14,
                    child: Container(
                      width: isWide ? 200 : 150,
                      height: isWide ? 200 : 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.20),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 22),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Text(
                          context.tr('VOICE LESSON'),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        context.tr('New Voice Lesson'),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        context.tr(
                          'Choose the language and challenge level, then generate a roadmap built for short, focused speaking reps.',
                        ),
                        style: GoogleFonts.inter(
                          fontSize: Responsive.bodySize(context),
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
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
