import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_subject.dart';
import 'package:modern_learner_production/features/explore/utils/explore_utils.dart';

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
                _SpotlightPill(category: subject.category),
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
                _OpenCollectionButton(onTap: onTap),
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

class _SpotlightPill extends StatelessWidget {
  const _SpotlightPill({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        '${category.toUpperCase()} SPOTLIGHT',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: Colors.white.withValues(alpha: 0.78),
        ),
      ),
    );
  }
}

class _OpenCollectionButton extends StatelessWidget {
  const _OpenCollectionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Open collection',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF12192B),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: Color(0xFF12192B),
            ),
          ],
        ),
      ),
    );
  }
}

class SpotlightCover extends StatelessWidget {
  const SpotlightCover({
    super.key,
    required this.emoji,
    required this.accentColor,
    this.coverUrl,
  });

  final String emoji;
  final Color accentColor;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 156,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: coverUrl == null
          ? _EmojiCover(emoji: emoji, accentColor: accentColor, size: 40)
          : CachedNetworkImage(
              imageUrl: coverUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  _EmojiCover(emoji: emoji, accentColor: accentColor, size: 36),
              errorWidget: (_, __, ___) =>
                  _EmojiCover(emoji: emoji, accentColor: accentColor, size: 36),
            ),
    );
  }
}

class _EmojiCover extends StatelessWidget {
  const _EmojiCover({
    required this.emoji,
    required this.accentColor,
    required this.size,
  });

  final String emoji;
  final Color accentColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.8),
            accentColor.withValues(alpha: 0.22),
          ],
        ),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size)),
      ),
    );
  }
}
