import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/profile/data/profile_data.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:modern_learner_production/profile/widgets/stat_chip.dart';
import 'package:modern_learner_production/theme/theme.dart';

class ProfileHeaderSection extends StatefulWidget {
  const ProfileHeaderSection({
    super.key,
    required this.animate,
    required this.level,
    required this.xp,
    required this.xpGoal,
    required this.streak,
    required this.lessonsCompleted,
    required this.hoursStudied,
    required this.notesCount,
    required this.filesCount,
    required this.displayName,
    required this.avatarInitials,
    required this.joinedDate,
  });

  final bool animate;
  final int level;
  final int xp;
  final int xpGoal;
  final int streak;
  final int lessonsCompleted;
  final int hoursStudied;
  final int notesCount;
  final int filesCount;
  final String displayName;
  final String avatarInitials;
  final String joinedDate;

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
    _avatarScale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _avatarCtrl, curve: Curves.elasticOut));
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
    final stats = [
      StatItem(
        label: mockStats[0].label,
        value: '${widget.lessonsCompleted}',
        icon: mockStats[0].icon,
        accentColor: mockStats[0].accentColor,
      ),
      StatItem(
        label: mockStats[1].label,
        value: '${widget.hoursStudied}',
        icon: mockStats[1].icon,
        accentColor: mockStats[1].accentColor,
      ),
      StatItem(
        label: mockStats[2].label,
        value: '${widget.notesCount}',
        icon: mockStats[2].icon,
        accentColor: mockStats[2].accentColor,
      ),
      StatItem(
        label: mockStats[3].label,
        value: '${widget.streak}d',
        icon: mockStats[3].icon,
        accentColor: mockStats[3].accentColor,
      ),
    ];

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
                    const CustomPaint(
                      painter: _AvatarSketchRingPainter(EduColors.primary),
                      child: SizedBox(width: 108, height: 108),
                    ),
                    // Avatar
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [EduColors.primaryLight, EduColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: EduColors.primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.avatarInitials.isEmpty
                            ? '?'
                            : widget.avatarInitials,
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
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: EduColors.primary,
                          borderRadius: EduRadius.borderPill,
                          border: Border.all(
                            color: EduColors.surface,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Lv ${widget.level}',
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
                  widget.displayName.isEmpty ? 'Learner' : widget.displayName,
                  style: GoogleFonts.caveat(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: EduColors.textPrimary,
                  ),
                ),
                const SizedBox(height: EduSpacing.s3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: EduColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Member since ${widget.joinedDate}',
                      style: GoogleFonts.caveat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: EduColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: EduSpacing.s4),
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 13,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.streak}-day streak',
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

        const SizedBox(height: EduSpacing.s5),

        // ── XP progress ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: EduSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'XP',
                    style: GoogleFonts.caveat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: EduColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${widget.xp} / ${widget.xpGoal}',
                    style: GoogleFonts.caveat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: EduColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: EduSpacing.s1),
              ClipRRect(
                borderRadius: EduRadius.borderPill,
                child: LinearProgressIndicator(
                  value: widget.xpGoal > 0
                      ? (widget.xp / widget.xpGoal).clamp(0.0, 1.0)
                      : 0,
                  minHeight: 6,
                  backgroundColor: EduColors.primary.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation(EduColors.primary),
                ),
              ),
            ],
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
                  Expanded(
                    child: StatChip(stat: stats[0], animate: widget.animate),
                  ),
                  const SizedBox(width: EduSpacing.s3),
                  Expanded(
                    child: StatChip(stat: stats[1], animate: widget.animate),
                  ),
                ],
              ),
              const SizedBox(height: EduSpacing.s3),
              Row(
                children: [
                  Expanded(
                    child: StatChip(stat: stats[2], animate: widget.animate),
                  ),
                  const SizedBox(width: EduSpacing.s3),
                  Expanded(
                    child: StatChip(stat: stats[3], animate: widget.animate),
                  ),
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
