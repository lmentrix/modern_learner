import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LessonTopicCoverTile extends StatelessWidget {
  const LessonTopicCoverTile({
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
    final imageUrl = coverUrl;
    return Container(
      width: 82,
      height: 116,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.55),
            accentColor.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: imageUrl == null
          ? Center(child: Text(emoji, style: const TextStyle(fontSize: 34)))
          : Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: accentColor.withValues(alpha: 0.16),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: accentColor.withValues(alpha: 0.16),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.02),
                        Colors.black.withValues(alpha: 0.28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
