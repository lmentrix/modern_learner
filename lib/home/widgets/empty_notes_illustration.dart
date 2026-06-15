import 'package:flutter/material.dart';
import 'package:modern_learner_production/theme/theme.dart';

class EmptyNotesIllustration extends StatefulWidget {
  const EmptyNotesIllustration({super.key});

  @override
  State<EmptyNotesIllustration> createState() => _EmptyNotesIllustrationState();
}

class _EmptyNotesIllustrationState extends State<EmptyNotesIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        AnimatedBuilder(
          animation: CurvedAnimation(parent: _float, curve: Curves.easeInOut),
          builder: (context, child) {
            final dy = -6 + _float.value * 12;
            return Transform.translate(
              offset: Offset(0, dy),
              child: child,
            );
          },
          child: _NotesStack(),
        ),
        const SizedBox(height: EduSpacing.s6),
        Text(
          'No notes yet',
          style: tt.titleMedium?.copyWith(color: EduColors.textPrimary),
        ),
        const SizedBox(height: EduSpacing.s1),
        Text(
          'Start a lesson and your notes\nwill appear here.',
          style: tt.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: EduSpacing.s5),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: EduColors.primary,
            foregroundColor: EduColors.textInverse,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: const StadiumBorder(),
          ),
          onPressed: () {},
          child: Text('Browse lessons', style: tt.titleSmall?.copyWith(color: EduColors.textInverse)),
        ),
      ],
    );
  }
}

class _NotesStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back card — rotated right
          Transform.rotate(
            angle: 0.18,
            child: _NoteCard(color: EduColors.accentTeal, lines: 3),
          ),
          // Middle card — rotated left
          Transform.rotate(
            angle: -0.12,
            child: _NoteCard(color: EduColors.primaryLight, lines: 4),
          ),
          // Front card — straight
          _NoteCard(color: EduColors.surface, lines: 5, showIcon: true),
          // Sparkles
          Positioned(
            top: 8,
            right: 12,
            child: _Sparkle(size: 10, color: EduColors.primary),
          ),
          Positioned(
            bottom: 16,
            left: 8,
            child: _Sparkle(size: 7, color: EduColors.accentGreen),
          ),
          Positioned(
            top: 28,
            left: 18,
            child: _Sparkle(size: 6, color: EduColors.star),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.color, required this.lines, this.showIcon = false});

  final Color color;
  final int lines;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 120,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: EduRadius.borderLg,
        boxShadow: EduColors.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(Icons.sticky_note_2_outlined, size: 20, color: EduColors.primary),
            const SizedBox(height: 8),
          ],
          ...List.generate(lines, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Container(
              height: 4,
              width: i == lines - 1 ? 40 : double.infinity,
              decoration: BoxDecoration(
                color: EduColors.border,
                borderRadius: EduRadius.borderPill,
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparkPainter(color: color),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.7);
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 4-point star
    final path = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx + size.width * 0.15, cy)
      ..lineTo(size.width, cy)
      ..lineTo(cx + size.width * 0.15, cy + size.height * 0.15)
      ..lineTo(cx, size.height)
      ..lineTo(cx - size.width * 0.15, cy + size.height * 0.15)
      ..lineTo(0, cy)
      ..lineTo(cx - size.width * 0.15, cy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.color != color;
}
