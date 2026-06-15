import 'package:flutter/material.dart';
import 'package:modern_learner_production/profile/data/profile_data.dart';
import 'package:modern_learner_production/profile/widgets/settings_tile_widget.dart';
import 'package:modern_learner_production/theme/theme.dart';

class SettingsSection extends StatefulWidget {
  const SettingsSection({super.key, required this.animate});

  final bool animate;

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
    final tt = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EduSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: tt.headlineSmall),
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
                          style: tt.labelMedium?.copyWith(
                            letterSpacing: 1.3,
                            color: EduColors.textSecondary,
                            fontWeight: FontWeight.w700,
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
                              SettingsTileWidget(tile: tile),
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
