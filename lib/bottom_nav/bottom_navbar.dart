import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:modern_learner_production/theme/theme.dart';

// ── Nav item descriptor ──────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _items = [
  _NavItem(icon: Icons.home_outlined,      activeIcon: Icons.home_rounded,      label: 'Home'),
  _NavItem(icon: Icons.menu_book_outlined,  activeIcon: Icons.menu_book_rounded, label: 'Study'),
  _NavItem(icon: Icons.mic_none_rounded,   activeIcon: Icons.mic_rounded,       label: 'Mic'),
  _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Progress'),
  _NavItem(icon: Icons.person_outline,     activeIcon: Icons.person_rounded,    label: 'Profile'),
];

// ── Public widget ────────────────────────────────────────────────────────────

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            // frosted glass: white at ~70% opacity so content shows through
            color: EduColors.surface.withValues(alpha: 0.72),
            border: Border(
              top: BorderSide(
                color: EduColors.primary.withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: EduColors.primary.withValues(alpha: 0.06),
                blurRadius: 32,
                offset: const Offset(0, -4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(_items.length, (index) {
                  final selected = index == currentIndex;
                  return index == 2
                      ? _AiMicButton(selected: selected, onTap: () => onTap(index))
                      : Expanded(
                          child: _NavTab(
                            item: _items[index],
                            selected: selected,
                            onTap: () => onTap(index),
                          ),
                        );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Standard tab ────────────────────────────────────────────────────────────

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? EduColors.primary : EduColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: selected ? 1.18 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Icon(
              selected ? item.activeIcon : item.icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: EduSpacing.s1),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

// ── AI Mic button ────────────────────────────────────────────────────────────

class _AiMicButton extends StatefulWidget {
  const _AiMicButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  State<_AiMicButton> createState() => _AiMicButtonState();
}

class _AiMicButtonState extends State<_AiMicButton>
    with TickerProviderStateMixin {
  // Ripple rings that expand outward when active
  late final AnimationController _ripple1;
  late final AnimationController _ripple2;
  late final AnimationController _ripple3;

  // Idle "breathing" glow
  late final AnimationController _breath;

  // Tap press-and-release spring
  late final AnimationController _press;
  late final Animation<double> _pressScale;

  // Rotating arc segments (AI "thinking" ring)
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();

    _ripple1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _ripple2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _ripple3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeIn, reverseCurve: Curves.elasticOut),
    );

    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _syncAnimations();
  }

  void _syncAnimations() {
    if (widget.selected) {
      _startActive();
    } else {
      _startIdle();
    }
  }

  void _startActive() {
    _breath.stop();
    _orbit.repeat();
    _ripple1.repeat();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ripple2.repeat();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _ripple3.repeat();
    });
  }

  void _startIdle() {
    _ripple1.stop();
    _ripple2.stop();
    _ripple3.stop();
    _orbit.stop();
    _breath.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_AiMicButton old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      _syncAnimations();
    }
  }

  @override
  void dispose() {
    _ripple1.dispose();
    _ripple2.dispose();
    _ripple3.dispose();
    _breath.dispose();
    _press.dispose();
    _orbit.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _press.forward();
  void _onTapUp(TapUpDetails _) {
    _press.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _press.reverse();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Center(
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: ScaleTransition(
            scale: _pressScale,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Ripple rings (active only) ──────────────────────────
                  if (widget.selected) ...[
                    _RippleRing(controller: _ripple1, baseSize: 52),
                    _RippleRing(controller: _ripple2, baseSize: 52),
                    _RippleRing(controller: _ripple3, baseSize: 52),
                  ],

                  // ── Idle breath glow (inactive only) ───────────────────
                  if (!widget.selected)
                    AnimatedBuilder(
                      animation: _breath,
                      builder: (context, _) {
                        final t = Curves.easeInOut.transform(_breath.value);
                        return Container(
                          width: 52 + t * 8,
                          height: 52 + t * 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: EduColors.primary.withValues(alpha: 0.08 + t * 0.06),
                          ),
                        );
                      },
                    ),

                  // ── Orbiting AI arc (active only) ──────────────────────
                  if (widget.selected)
                    AnimatedBuilder(
                      animation: _orbit,
                      builder: (context, _) => CustomPaint(
                        size: const Size(60, 60),
                        painter: _OrbitArcPainter(
                          progress: _orbit.value,
                          color: EduColors.primary,
                        ),
                      ),
                    ),

                  // ── Core button ────────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.selected
                          ? const LinearGradient(
                              colors: [Color(0xFFBB9FFF), EduColors.primary, Color(0xFF8B6BFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [EduColors.primaryLight, Color(0xFFF3ECFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      boxShadow: widget.selected
                          ? [
                              BoxShadow(
                                color: EduColors.primary.withValues(alpha: 0.45),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: EduColors.primary.withValues(alpha: 0.15),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ]
                          : EduColors.shadowCard,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.selected ? Icons.mic_rounded : Icons.mic_none_rounded,
                        key: ValueKey(widget.selected),
                        color: widget.selected ? EduColors.textInverse : EduColors.primary,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ripple ring painter ───────────────────────────────────────────────────────

class _RippleRing extends StatelessWidget {
  const _RippleRing({required this.controller, required this.baseSize});

  final AnimationController controller;
  final double baseSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeOut.transform(controller.value);
        final size = baseSize + t * 28;
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: EduColors.primary.withValues(alpha: opacity * 0.5),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }
}

// ── Orbit arc custom painter ─────────────────────────────────────────────────

class _OrbitArcPainter extends CustomPainter {
  const _OrbitArcPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    final angle = progress * 2 * math.pi;

    // Three short arcs staggered 120° apart
    for (var i = 0; i < 3; i++) {
      final offset = (i / 3) * 2 * math.pi;
      final start = angle + offset;
      const sweep = math.pi * 0.3;
      final fade = (i == 0) ? 1.0 : (i == 1) ? 0.6 : 0.3;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: fade * 0.7);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitArcPainter old) => old.progress != progress;
}
