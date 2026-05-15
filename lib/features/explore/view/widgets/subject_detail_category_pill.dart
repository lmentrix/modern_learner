import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectDetailCategoryPill extends StatelessWidget {
  const SubjectDetailCategoryPill({
    super.key,
    required this.category,
    required this.accent,
  });

  final String category;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.40)),
      ),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: accent,
        ),
      ),
    );
  }
}
