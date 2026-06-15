import 'package:flutter/material.dart';
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
    final tt = Theme.of(context).textTheme;
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
                    // Outer glow ring
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: user.avatarGradient
                              .map((c) => Color(c).withValues(alpha: 0.3))
                              .toList(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
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
                                .withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user.avatarInitials,
                        style: tt.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    // Level badge
                    Positioned(
                      bottom: 0,
                      right: 0,
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
                          style: tt.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: EduSpacing.s4),
                Text(user.name, style: tt.headlineMedium),
                const SizedBox(height: 2),
                Text(user.username,
                    style: tt.bodyMedium?.copyWith(color: EduColors.primary)),
                const SizedBox(height: EduSpacing.s3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: EduSpacing.s12),
                  child: Text(
                    user.bio,
                    style: tt.bodyMedium,
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
                    Text('Member since ${user.joinedDate}',
                        style: tt.labelMedium),
                    const SizedBox(width: EduSpacing.s4),
                    const Icon(Icons.local_fire_department_rounded,
                        size: 13, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text('${user.streak}-day streak',
                        style: tt.labelMedium
                            ?.copyWith(color: const Color(0xFFF59E0B))),
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
