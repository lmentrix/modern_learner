import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/features/explore/service/explore_subject.dart';
import 'package:modern_learner_production/features/explore/utils/explore_utils.dart';
import 'package:modern_learner_production/features/explore/view/widgets/explore_open_collection_button.dart';
import 'package:modern_learner_production/features/explore/view/widgets/explore_spotlight_pill.dart';
import 'package:modern_learner_production/features/explore/view/widgets/spotlight_cover.dart';

class ExploreSpotlightCard extends StatelessWidget {
  const ExploreSpotlightCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  final ExploreSubject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final featuredWorks = subject.previewTitles.take(2).join('  •  ');

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF16203B),
            subject.accentColor.withValues(alpha: 0.28),
            const Color(0xFF0E1020),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: subject.accentColor.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExploreSpotlightPill(category: subject.category),
                const SizedBox(height: 16),
                Text(
                  '${subject.emoji} ${subject.name}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${formatCount(subject.workCount)} papers available to explore now.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.74),
                    height: 1.5,
                  ),
                ),
                if (featuredWorks.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    featuredWorks,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subject.accentColor.withValues(alpha: 0.98),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                ExploreOpenCollectionButton(onTap: onTap),
              ],
            ),
          ),
          const SizedBox(width: 18),
          SpotlightCover(
            emoji: subject.emoji,
            accentColor: subject.accentColor,
            coverUrl: subject.coverUrl,
          ),
        ],
      ),
    );
  }
}
