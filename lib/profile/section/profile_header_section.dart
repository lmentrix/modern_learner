import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/profile/data/profile_data.dart';
import 'package:modern_learner_production/profile/widgets/stat_chip.dart';
import 'package:modern_learner_production/theme/theme.dart';

class ProfileHeaderSection extends StatefulWidget {
  const ProfileHeaderSection({super.key, required this.animate});

  final bool animate;

  @override
  State<ProfileHeaderSection> createState() => _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends State<ProfileHeaderSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _avatarCtrl;
  late final Animation<double> _avatarScale;
  late final Animation<double> _avatarFade;

  @override
  void initState() {
    super.initState();
    _avatarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _avatarScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _avatarCtrl, curve: Curves.elasticOut),
    );
    _avatarFade = CurvedAnimation(parent: _avatarCtrl, curve: Curves.easeOut);
    if (widget.animate) _avatarCtrl.forward();
  }

  @override
  void didUpdateWidget(ProfileHeaderSection old) {
    super.didUpdateWidget(old);
    if (!old.animate && widget.animate) _avatarCtrl.forward();
  }

  @override
  void dispose() {
    _avatarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = mockUser;

    return Column(
      children: [
        // ── Avatar + identity ──────────────────────────────────────────────
        FadeTransition(
          opacity: _avatarFade,
          child: ScaleTransition(
            scale: _avatarScale,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Hand-drawn sketch ring around avatar
                    CustomPaint(
                      painter: _AvatarSketchRingPainter(
                        Color(user.avatarGradient.first),
                      ),
                      child: const SizedBox(width: 108, height: 108),
                    ),
                    // Avatar
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: user.avatarGradient.map((c) => Color(c)).toList(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(user.avatarGradient.first)
                                .withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user.avatarInitials,
                        style: GoogleFonts.caveat(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Level badge
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: EduColors.primary,
                          borderRadius: EduRadius.borderPill,
                          border: Border.all(color: EduColors.surface, width: 2),
                        ),
                        child: Text(
                          'Lv ${user.level}',
                          style: GoogleFonts.caveat(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: EduSpacing.s4),
                Text(
                  user.name,
                  style: GoogleFonts.caveat(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: EduColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.username,
                  style: GoogleFonts.caveat(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: EduColors.primary,
                  ),
                ),
                const SizedBox(height: EduSpacing.s3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: EduSpacing.s12),
                  child: Text(
                    user.bio,
                    style: GoogleFonts.caveat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: EduColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: EduSpacing.s3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: EduColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Member since ${user.joinedDate}',
                      style: GoogleFonts.caveat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: EduColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: EduSpacing.s4),
                    const Icon(Icons.local_fire_department_rounded,
                        size: 13, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      '${user.streak}-day streak',
                      style: GoogleFonts.caveat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: EduSpacing.s6),

        // ── Stat chips grid ────────────────────────────────────────────────
        Padding(
          padding: EduSpacing.pagePadding,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: StatChip(stat: mockStats[0], animate: widget.animate)),
                  const SizedBox(width: EduSpacing.s3),
                  Expanded(child: StatChip(stat: mockStats[1], animate: widget.animate)),
                ],
              ),
              const SizedBox(height: EduSpacing.s3),
              Row(
                children: [
                  Expanded(child: StatChip(stat: mockStats[2], animate: widget.animate)),
                  const SizedBox(width: EduSpacing.s3),
                  Expanded(child: StatChip(stat: mockStats[3], animate: widget.animate)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Hand-drawn double ring around the avatar ──────────────────────────────────

class _AvatarSketchRingPainter extends CustomPainter {
  const _AvatarSketchRingPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer imperfect ink ring
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: 50),
      -math.pi * 0.60,
      math.pi * 1.85,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.40)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Gap arc — makes it look hand-drawn
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx + 0.8, cy - 0.8), radius: 48),
      math.pi * 0.82,
      math.pi * 0.52,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Inner echo ring (very faint)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx - 0.5, cy + 0.5), radius: 46),
      -math.pi * 0.20,
      math.pi * 1.25,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.10)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_AvatarSketchRingPainter old) => old.color != color;
}
