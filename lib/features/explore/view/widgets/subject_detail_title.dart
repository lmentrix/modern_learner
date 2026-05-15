import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectDetailTitle extends StatelessWidget {
  const SubjectDetailTitle({
    super.key,
    required this.emoji,
    required this.name,
  });

  final String emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final emojiSize = w < 360
        ? 40.0
        : w >= 600
        ? 56.0
        : 48.0;
    final titleSize = w < 360
        ? 28.0
        : w >= 600
        ? 44.0
        : 36.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(emoji, style: TextStyle(fontSize: emojiSize)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.spaceGrotesk(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}
