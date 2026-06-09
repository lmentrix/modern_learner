import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_constants.dart';

class ProgressSkeletonSection extends StatefulWidget {
  const ProgressSkeletonSection({super.key});

  @override
  State<ProgressSkeletonSection> createState() =>
      _ProgressSkeletonSectionState();
}

class _ProgressSkeletonSectionState extends State<ProgressSkeletonSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmer = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: ProgressPageConstants.sectionSpacing),
            ),
            SliverPadding(
              padding: ProgressPageConstants.pagePadding,
              sliver: SliverToBoxAdapter(
                child: _SkeletonHeader(shimmerValue: _shimmer.value),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: ProgressPageConstants.sectionSpacing),
            ),
            SliverPadding(
              padding: ProgressPageConstants.pagePadding,
              sliver: SliverToBoxAdapter(
                child: _SkeletonStatsRow(shimmerValue: _shimmer.value),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: ProgressPageConstants.sectionSpacing),
            ),
            SliverPadding(
              padding: ProgressPageConstants.pagePadding,
              sliver: SliverToBoxAdapter(
                child: _SkeletonJourney(shimmerValue: _shimmer.value),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 36)),
            const SliverToBoxAdapter(child: _LearningPathLoader()),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}

// ── Solar system loading animation ───────────────────────────────────────────

class _LearningPathLoader extends StatefulWidget {
  const _LearningPathLoader();

  @override
  State<_LearningPathLoader> createState() => _LearningPathLoaderState();
}

class _LearningPathLoaderState extends State<_LearningPathLoader>
    with TickerProviderStateMixin {
  late final AnimationController _sysCtrl;
  late final AnimationController _labelCtrl;

  static const _labels = [
    'Calibrating your orbit…',
    'Mapping chapter milestones…',
    'Assembling your roadmap…',
    'Almost there…',
  ];
  int _labelIndex = 0;

  @override
  void initState() {
    super.initState();
    // One controller drives the whole system — planets just use different
    // fractions of t to get independent orbital speeds.
    _sysCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _labelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scheduleLabelCycle();
  }

  void _scheduleLabelCycle() {
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      _labelCtrl.forward().then((_) {
        if (!mounted) return;
        setState(() => _labelIndex = (_labelIndex + 1) % _labels.length);
        _labelCtrl.reverse().then((_) => _scheduleLabelCycle());
      });
    });
  }

  @override
  void dispose() {
    _sysCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _sysCtrl,
            builder: (context, _) => CustomPaint(
              painter: _SolarSystemPainter(t: _sysCtrl.value),
              // A real child forces layout to fill the parent constraints,
              // so the painter receives the correct non-zero canvas size.
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _labelCtrl,
          builder: (context, _) {
            final opacity = (1.0 - _labelCtrl.value).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Text(
                _labels[_labelIndex],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Planet data ───────────────────────────────────────────────────────────────

class _PlanetData {
  const _PlanetData({
    required this.orbitRadius,
    required this.size,
    required this.speed,
    required this.color,
    required this.phase,
    this.hasRing = false,
    this.ringColor,
  });

  /// Distance from sun (canvas units).
  final double orbitRadius;

  /// Visual radius of the planet body.
  final double size;

  /// Full orbits completed per full controller loop (higher = faster).
  final double speed;

  final Color color;

  /// Initial angle offset (0..1 of a full turn).
  final double phase;

  /// Whether to draw a Saturn-style ring around this planet.
  final bool hasRing;
  final Color? ringColor;
}

// ── Solar system painter ──────────────────────────────────────────────────────

class _SolarSystemPainter extends CustomPainter {
  _SolarSystemPainter({required this.t});

  /// 0..1, repeating over 12 seconds.
  final double t;

  // Y-scale factor that gives the "seen from slightly above" perspective tilt.
  static const _yScale = 0.36;

  static const _sunColor = Color(0xFFFFD580);
  static const _sunCore = Color(0xFFFFFFCC);
  static const _coronaHue = Color(0xFFFF9900);

  static final _planets = <_PlanetData>[
    // Mercury-analog: tiny, grey, swift inner orbit
    const _PlanetData(
      orbitRadius: 38,
      size: 3.8,
      speed: 4.8,
      color: Color(0xFFBBB8B0),
      phase: 0.15,
    ),
    // Venus-analog: warm golden, medium orbit
    _PlanetData(
      orbitRadius: 60,
      size: 5.5,
      speed: 2.9,
      color: AppColors.primary,
      phase: 0.42,
    ),
    // Earth-analog: app tertiary (greenish glow)
    _PlanetData(
      orbitRadius: 86,
      size: 6.5,
      speed: 1.9,
      color: AppColors.tertiary,
      phase: 0.70,
    ),
    // Mars-analog: reddish-orange, slightly slower
    const _PlanetData(
      orbitRadius: 114,
      size: 5.0,
      speed: 1.2,
      color: Color(0xFFFF7B5E),
      phase: 0.05,
    ),
    // Saturn-analog: large, secondary purple, has a ring
    _PlanetData(
      orbitRadius: 152,
      size: 10.5,
      speed: 0.65,
      color: AppColors.secondary,
      phase: 0.58,
      hasRing: true,
      ringColor: AppColors.secondary.withValues(alpha: 0.45),
    ),
  ];

  // Fixed star field — deterministic positions so there's no per-frame jitter.
  static final _stars = _buildStars();

  static List<Offset> _buildStars() {
    const seeds = <double>[
      0.07,
      0.21,
      0.38,
      0.51,
      0.63,
      0.79,
      0.89,
      0.14,
      0.29,
      0.44,
      0.56,
      0.68,
      0.83,
      0.93,
      0.03,
      0.17,
      0.35,
      0.49,
      0.61,
      0.75,
      0.87,
      0.11,
      0.26,
      0.41,
      0.54,
      0.67,
      0.80,
      0.92,
    ];
    // Map each pair of seeds to a (dx, dy) in normalised [-0.5, 0.5] space.
    final result = <Offset>[];
    for (int i = 0; i + 1 < seeds.length; i += 2) {
      result.add(Offset(seeds[i] - 0.5, seeds[i + 1] - 0.5));
    }
    return result;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Scale the entire system so the outermost orbit (defined at radius 152)
    // always fits comfortably within the available width on any screen.
    final scale = (size.width * 0.44 / 152).clamp(0.6, 1.4);

    _drawStars(canvas, size, center);
    _drawNebulaGlow(canvas, center, scale);
    _drawOrbits(canvas, center, scale);

    // Draw back-halves of rings before the sun so they appear behind it.
    for (final p in _planets) {
      if (p.hasRing) _drawRingBack(canvas, center, p, scale);
    }

    _drawSun(canvas, center, scale);

    // Draw planets in back-to-front order based on current y position.
    final sorted = List<_PlanetData>.from(_planets)
      ..sort(
        (a, b) => _planetPos(
          center,
          a,
          scale,
        ).dy.compareTo(_planetPos(center, b, scale).dy),
      );

    for (final p in sorted) {
      _drawPlanet(canvas, center, p, scale);
    }
  }

  // ── Stars ─────────────────────────────────────────────────────────────────

  void _drawStars(Canvas canvas, Size size, Offset center) {
    // Slow drift: stars rotate very slightly with time so they don't look static.
    final drift = t * math.pi * 0.04;

    for (int i = 0; i < _stars.length; i++) {
      final raw = _stars[i];
      final dx =
          raw.dx * size.width * math.cos(drift) -
          raw.dy * size.height * math.sin(drift);
      final dy =
          raw.dx * size.width * math.sin(drift) +
          raw.dy * size.height * math.cos(drift);
      final pos = center + Offset(dx, dy);

      // Twinkle: each star has its own sinusoidal brightness phase.
      final twinkle = math.sin(t * math.pi * 4 + i * 1.37) * 0.3 + 0.7;
      final radius = (i % 3 == 0) ? 1.4 : 0.9;

      canvas.drawCircle(
        pos,
        radius,
        Paint()..color = Colors.white.withValues(alpha: twinkle * 0.55),
      );
    }
  }

  // ── Nebula background glow ────────────────────────────────────────────────

  void _drawNebulaGlow(Canvas canvas, Offset center, double scale) {
    final r1 = 110 * scale;
    final r2 = 90 * scale;
    final o1 = Offset(-30 * scale, 10 * scale);
    final o2 = Offset(40 * scale, -10 * scale);
    canvas.drawCircle(
      center + o1,
      r1,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primaryDim.withValues(alpha: 0.07),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center + o1, radius: r1)),
    );
    canvas.drawCircle(
      center + o2,
      r2,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center + o2, radius: r2)),
    );
  }

  // ── Orbital ellipses ──────────────────────────────────────────────────────

  void _drawOrbits(Canvas canvas, Offset center, double scale) {
    for (final p in _planets) {
      final r = p.orbitRadius * scale;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: r * 2, height: r * 2 * _yScale),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.055)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  // ── Sun ───────────────────────────────────────────────────────────────────

  void _drawSun(Canvas canvas, Offset center, double scale) {
    final haloR = 44 * scale;
    final bodyR = 15 * scale;
    final innerR = 16 * scale;

    // Outer diffuse corona halo
    canvas.drawCircle(
      center,
      haloR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _coronaHue.withValues(alpha: 0.30),
            _coronaHue.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: haloR)),
    );

    // Rotating corona rays
    final rayAngle = t * math.pi * 2;
    const rayCount = 8;
    for (int i = 0; i < rayCount; i++) {
      final angle = rayAngle + (i / rayCount) * math.pi * 2;
      final pulse = math.sin(t * math.pi * 6 + i) * 0.5 + 0.5;
      final outerR = (30.0 + pulse * 12.0) * scale;
      canvas.drawLine(
        center + Offset(math.cos(angle) * innerR, math.sin(angle) * innerR),
        center + Offset(math.cos(angle) * outerR, math.sin(angle) * outerR),
        Paint()
          ..color = _sunColor.withValues(alpha: 0.18 + pulse * 0.14)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
    }

    // Sun body
    canvas.drawCircle(
      center,
      bodyR,
      Paint()
        ..shader = const RadialGradient(
          colors: [_sunCore, _sunColor, _coronaHue],
          stops: [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: 15)),
    );

    canvas.drawCircle(
      center,
      bodyR,
      Paint()
        ..color = _coronaHue.withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  // ── Planet helpers ────────────────────────────────────────────────────────

  Offset _planetPos(Offset center, _PlanetData p, double scale) {
    final angle = (p.phase + p.speed * t) * math.pi * 2;
    final r = p.orbitRadius * scale;
    return center + Offset(math.cos(angle) * r, math.sin(angle) * r * _yScale);
  }

  void _drawRingBack(
    Canvas canvas,
    Offset center,
    _PlanetData p,
    double scale,
  ) {
    final pos = _planetPos(center, p, scale);
    final sz = p.size * scale;
    final rx = sz * 2.4;
    final ry = sz * 0.55;
    canvas.save();
    // Clip to the back half of the ring (above the planet centre).
    canvas.clipRect(
      Rect.fromLTRB(pos.dx - rx - 2, -9999, pos.dx + rx + 2, pos.dy),
    );
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: rx * 2, height: ry * 2),
      Paint()
        ..color = p.ringColor ?? AppColors.secondary.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 * scale,
    );
    canvas.restore();
  }

  void _drawPlanet(Canvas canvas, Offset center, _PlanetData p, double scale) {
    final pos = _planetPos(center, p, scale);
    final sz = p.size * scale;

    // Ambient glow
    canvas.drawCircle(
      pos,
      sz * 2.2,
      Paint()
        ..color = p.color.withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sz * 1.5),
    );

    // Planet body
    canvas.drawCircle(
      pos,
      sz,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(Colors.white, p.color, 0.45) ?? p.color,
            p.color,
            Color.lerp(p.color, Colors.black, 0.35) ?? p.color,
          ],
          stops: const [0.0, 0.55, 1.0],
          center: const Alignment(-0.4, -0.4),
        ).createShader(Rect.fromCircle(center: pos, radius: sz)),
    );

    // Ring front half — drawn over the planet body, clipped to the lower arc.
    if (p.hasRing) {
      final rx = sz * 2.4;
      final ry = sz * 0.55;
      canvas.save();
      canvas.clipRect(
        Rect.fromLTRB(pos.dx - rx - 2, pos.dy, pos.dx + rx + 2, 9999),
      );
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: rx * 2, height: ry * 2),
        Paint()
          ..color = p.ringColor ?? AppColors.secondary.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * scale,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SolarSystemPainter old) => old.t != t;
}

// ── Header skeleton ──────────────────────────────────────────────────────────

class _SkeletonHeader extends StatelessWidget {
  const _SkeletonHeader({required this.shimmerValue});
  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course identity card
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: double.infinity,
          height: 76,
          borderRadius: 20,
        ),
        const SizedBox(height: 10),
        // XP progress card
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: double.infinity,
          height: 72,
          borderRadius: 20,
        ),
      ],
    );
  }
}

class _SkeletonStatsRow extends StatelessWidget {
  const _SkeletonStatsRow({required this.shimmerValue});
  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ShimmerBox(
            shimmerValue: shimmerValue,
            width: double.infinity,
            height: 88,
            borderRadius: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ShimmerBox(
            shimmerValue: shimmerValue,
            width: double.infinity,
            height: 88,
            borderRadius: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ShimmerBox(
            shimmerValue: shimmerValue,
            width: double.infinity,
            height: 88,
            borderRadius: 20,
          ),
        ),
      ],
    );
  }
}

// ── Journey skeleton ─────────────────────────────────────────────────────────

class _SkeletonJourney extends StatelessWidget {
  const _SkeletonJourney({required this.shimmerValue});
  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: 80,
          height: 13,
          borderRadius: 6,
        ),
        const SizedBox(height: 14),
        for (int i = 0; i < 4; i++) ...[
          _SkeletonChapterTile(shimmerValue: shimmerValue),
          if (i < 3) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _SkeletonChapterTile extends StatelessWidget {
  const _SkeletonChapterTile({required this.shimmerValue});

  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ShimmerBox._colorFor(shimmerValue),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Icon box
          _ShimmerBox(
            shimmerValue: shimmerValue,
            width: 44,
            height: 44,
            borderRadius: 14,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  shimmerValue: shimmerValue,
                  width: double.infinity,
                  height: 15,
                  borderRadius: 6,
                ),
                const SizedBox(height: 7),
                _ShimmerBox(
                  shimmerValue: shimmerValue,
                  width: 110,
                  height: 12,
                  borderRadius: 6,
                ),
                const SizedBox(height: 14),
                _ShimmerBox(
                  shimmerValue: shimmerValue,
                  width: double.infinity,
                  height: 4,
                  borderRadius: 999,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ShimmerBox(
                shimmerValue: shimmerValue,
                width: 52,
                height: 22,
                borderRadius: 999,
              ),
              const SizedBox(height: 8),
              _ShimmerBox(
                shimmerValue: shimmerValue,
                width: 20,
                height: 20,
                borderRadius: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shimmer box primitive ─────────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.shimmerValue,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double shimmerValue;
  final double width;
  final double height;
  final double borderRadius;

  static Color _colorFor(double v) {
    final base = AppColors.surfaceContainerHigh;
    final highlight = AppColors.surfaceContainerHighest;
    return Color.lerp(base, highlight, v) ?? base;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(shimmerValue);
    return Container(
      width: width == double.infinity ? null : width,
      height: height == double.infinity ? null : height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
