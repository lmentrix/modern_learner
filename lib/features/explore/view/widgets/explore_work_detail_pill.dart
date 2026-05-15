import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreWorkDetailPill extends StatelessWidget {
  const ExploreWorkDetailPill({
    super.key,
    required this.label,
    required this.accentColor,
  });

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: accentColor,
        ),
      ),
    );
  }
}
