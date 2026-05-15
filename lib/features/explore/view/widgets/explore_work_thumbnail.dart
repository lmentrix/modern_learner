import 'package:flutter/material.dart';

class ExploreWorkThumbnail extends StatelessWidget {
  const ExploreWorkThumbnail({
    super.key,
    required this.emoji,
    required this.accentColor,
  });

  final String emoji;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 92,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accentColor.withValues(alpha: 0.12),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
    );
  }
}
