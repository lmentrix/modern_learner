import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class LearningSubjectsFilterChip extends StatefulWidget {
  const LearningSubjectsFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<LearningSubjectsFilterChip> createState() =>
      _LearningSubjectsFilterChipState();
}

class _LearningSubjectsFilterChipState extends State<LearningSubjectsFilterChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _lift;
  late final CurvedAnimation _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _glow = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _lift = Tween<double>(
      begin: 0.0,
      end: -2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _glow.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForLabel(widget.label);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final glowOpacity = 0.12 + (_glow.value * 0.22);
          return Transform.translate(
            offset: Offset(0, _lift.value),
            child: ScaleTransition(
              scale: _scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: widget.isActive
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.tertiaryContainer,
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.surfaceContainerHighest.withValues(
                              alpha: 0.64,
                            ),
                            accent.withValues(alpha: 0.08 + _glow.value * 0.16),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: widget.isActive
                        ? Colors.white.withValues(alpha: 0.18)
                        : Color.lerp(
                            AppColors.outlineVariant.withValues(alpha: 0.18),
                            accent.withValues(alpha: 0.72),
                            _glow.value,
                          )!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: glowOpacity),
                      blurRadius: 10 + (_glow.value * 12),
                      spreadRadius: _glow.value,
                      offset: Offset(0, 4 + (_glow.value * 2)),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: _glow.value * 0.28,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.42),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        widget.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: widget.isActive
                              ? const Color(0xFF160D24)
                              : Color.lerp(
                                  AppColors.onSurfaceVariant,
                                  accent,
                                  _glow.value * 0.55,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _accentForLabel(String label) {
    return switch (label) {
      'STEM' => AppColors.tertiaryContainer,
      'Humanities' => const Color(0xFFFFC857),
      'Arts' => const Color(0xFFFF7AB6),
      'Languages' => const Color(0xFF70D6FF),
      'Social Sciences' => const Color(0xFFFF9F6E),
      _ => AppColors.primary,
    };
  }
}
