import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_constants.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_icon_box.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_panel.dart';

class ExerciseStateScaffold extends StatelessWidget {
  const ExerciseStateScaffold({
    super.key,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.message,
    required this.onBack,
    this.showSpinner = false,
    this.actionLabel,
    this.onAction,
  });

  final Color accentColor;
  final String title;
  final String subtitle;
  final IconData icon;
  final String message;
  final VoidCallback onBack;
  final bool showSpinner;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(
              gradient: ProfilePageConstants.headerGradient,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverPadding(
          padding: ProfilePageConstants.pagePadding,
          sliver: SliverToBoxAdapter(
            child: ExercisePanel(
              accentColor: accentColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExerciseIconBox(
                    icon: icon,
                    color: accentColor,
                    showSpinner: showSpinner,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtitle,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        if (actionLabel != null && onAction != null) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: onAction,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(actionLabel!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
