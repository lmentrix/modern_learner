import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:modern_learner_production/features/explore/view/widgets/explore_emoji_cover.dart';

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
          ? ExploreEmojiCover(emoji: emoji, accentColor: accentColor, size: 40)
          : CachedNetworkImage(
              imageUrl: coverUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => ExploreEmojiCover(
                emoji: emoji,
                accentColor: accentColor,
                size: 36,
              ),
              errorWidget: (context, url, error) => ExploreEmojiCover(
                emoji: emoji,
                accentColor: accentColor,
                size: 36,
              ),
            ),
    );
  }
}
