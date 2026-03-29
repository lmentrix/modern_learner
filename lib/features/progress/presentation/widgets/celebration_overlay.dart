import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CelebrationOverlay extends StatefulWidget {
  final int xpGained;
  final int gemsGained;
  final VoidCallback onComplete;

  const CelebrationOverlay({
    super.key,
    required this.xpGained,
    required this.gemsGained,
    required this.onComplete,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showRewards = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) {
      setState(() => _showRewards = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Particle effects
        CustomPaint(
          painter: ConfettiPainter(animation: _controller),
          size: Size.infinite,
        ),
        // Center celebration
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.primaryDim.withValues(alpha: 0.5),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDim.withValues(alpha: 0.6),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'LESSON COMPLETE!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                        letterSpacing: 2,
                      ),
                ),
              ),
              if (_showRewards) ...[
                const SizedBox(height: 32),
                _buildRewardsRow(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRewardItem(
          icon: '⭐',
          label: 'XP',
          value: '+${widget.xpGained}',
          color: AppColors.primary,
        ),
        const SizedBox(width: 24),
        _buildRewardItem(
          icon: '💎',
          label: 'Gems',
          value: '+${widget.gemsGained}',
          color: AppColors.tertiary,
        ),
      ],
    );
  }

  Widget _buildRewardItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final Random _random = Random();
  late List<ConfettiParticle> _particles;

  ConfettiPainter({required this.animation}) : super(repaint: animation) {
    _particles = List.generate(50, (i) => ConfettiParticle(
          x: _random.nextDouble(),
          y: 1.2 + _random.nextDouble() * 0.5,
          vx: (_random.nextDouble() - 0.5) * 0.02,
          vy: -0.01 - _random.nextDouble() * 0.02,
          size: 4 + _random.nextDouble() * 8,
          color: [
            AppColors.primary,
            AppColors.secondary,
            AppColors.tertiary,
            AppColors.error,
            Colors.amber,
          ][_random.nextInt(5)],
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
        ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      particle.update(animation.value);
      if (particle.y > 1.1) {
        particle.reset(_random);
      }

      final paint = Paint()
        ..color = particle.color.withValues(
          alpha: (1 - particle.y).clamp(0.0, 1.0) * 0.8,
        );

      canvas.save();
      canvas.translate(particle.x * size.width, particle.y * size.height);
      canvas.rotate(particle.rotation);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

class ConfettiParticle {
  double x, y, vx, vy, size, rotation, rotationSpeed;
  final Color color;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update(double progress) {
    x += vx;
    y += vy;
    vy += 0.001; // gravity
    rotation += rotationSpeed;
  }

  void reset(Random random) {
    x = random.nextDouble();
    y = 1.2;
    vx = (random.nextDouble() - 0.5) * 0.02;
    vy = -0.01 - random.nextDouble() * 0.02;
    rotation = random.nextDouble() * 2 * pi;
  }
}
