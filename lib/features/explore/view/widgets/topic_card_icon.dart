import 'package:flutter/material.dart';

class TopicCardIcon extends StatelessWidget {
  const TopicCardIcon({super.key, required this.emoji, required this.accent});

  final String emoji;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.24),
            accent.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
    );
  }
}
