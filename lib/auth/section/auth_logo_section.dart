import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/auth/widgets/auth_painters.dart';
import 'package:modern_learner_production/theme/theme.dart';

class AuthLogoSection extends StatelessWidget {
  const AuthLogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              painter: LogoRingPainter(),
              child: const SizedBox(width: 88, height: 88),
            ),
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF7C5CFC), Color(0xFFA78BFA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3FA78BFA),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'ML',
                style: GoogleFonts.caveat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: EduSpacing.s3),

        Text(
          'Modern Learner',
          style: GoogleFonts.caveat(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: EduColors.textPrimary,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 2),

        CustomPaint(
          painter: TitleUnderlinePainter(),
          size: const Size(160, 6),
        ),

        const SizedBox(height: EduSpacing.s2),

        Text(
          'Your intelligent study companion',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: EduColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
