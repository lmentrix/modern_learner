import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/profile/data/profile_data.dart';
import 'package:modern_learner_production/profile/widgets/settings_tile_widget.dart';
import 'package:modern_learner_production/theme/theme.dart';

class SettingsSection extends StatefulWidget {
  const SettingsSection({super.key, required this.animate, this.onSignOut});

  final bool animate;
  final VoidCallback? onSignOut;

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(SettingsSection old) {
    super.didUpdateWidget(old);
    if (!old.animate && widget.animate) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EduSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sketch section title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.caveat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: EduColors.textPrimary,
                    ),
                  ),
                  CustomPaint(
                    painter: _SketchAccentLine(width: 64),
                    size: const Size(64, 5),
                  ),
                ],
              ),
              const SizedBox(height: EduSpacing.s4),
              ...List.generate(settingsSections.length, (si) {
                final section = settingsSections[si];
                final title = settingsSectionTitles[si];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.only(
                            left: EduSpacing.s1,
                            bottom: EduSpacing.s2,
                            top: si == 0 ? 0 : EduSpacing.s4),
                        child: Text(
                          title.toUpperCase(),
                          style: GoogleFonts.caveat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: EduColors.textSecondary,
                          ),
                        ),
                      ),
                    ] else
                      const SizedBox(height: EduSpacing.s4),
                    Container(
                      decoration: BoxDecoration(
                        color: EduColors.surface,
                        borderRadius: EduRadius.borderXl,
                        boxShadow: EduColors.shadowCard,
                      ),
                      child: Column(
                        children: List.generate(section.length, (ti) {
                          final tile = section[ti];
                          final isLast = ti == section.length - 1;
                          return Column(
                            children: [
                              SettingsTileWidget(
                                tile: tile,
                                onTap: tile.isDestructive
                                    ? widget.onSignOut
                                    : null,
                              ),
                              if (!isLast)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 68, right: EduSpacing.s5),
                                  child: Divider(
                                    height: 1,
                                    color: EduColors.border,
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _SketchAccentLine extends CustomPainter {
  const _SketchAccentLine({required this.width});
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.6)
        ..quadraticBezierTo(
            width * 0.30, size.height * 0.1,
            width * 0.62, size.height * 0.7)
        ..lineTo(width * 0.90, size.height * 0.3),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.40)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SketchAccentLine old) => false;
}
