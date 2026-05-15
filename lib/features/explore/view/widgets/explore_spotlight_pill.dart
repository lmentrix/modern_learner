import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreSpotlightPill extends StatelessWidget {
  const ExploreSpotlightPill({super.key, required this.category});

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
