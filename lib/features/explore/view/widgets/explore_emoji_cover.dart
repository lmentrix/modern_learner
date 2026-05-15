import 'package:flutter/material.dart';

class ExploreEmojiCover extends StatelessWidget {
  const ExploreEmojiCover({
    super.key,
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
