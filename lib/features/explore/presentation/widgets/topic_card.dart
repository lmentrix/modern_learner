import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/difficulty_badge.dart';

class TopicCard extends StatefulWidget {
  const TopicCard({super.key, required this.topic, required this.accent});

  final LearningTopic topic;
  final Color accent;

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      value: 1.0,
    );
    _scale = Tween<double>(begin: 0.97, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final accent = widget.accent;

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              _TopicIcon(emoji: topic.emoji, accent: accent),
              const SizedBox(width: 14),
              Expanded(child: _TopicText(topic: topic)),
              const SizedBox(width: 12),
              _TopicMeta(topic: topic, accent: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicIcon extends StatelessWidget {
  const _TopicIcon({required this.emoji, required this.accent});

  final String emoji;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.24),
            accent.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}

class _TopicText extends StatelessWidget {
  const _TopicText({required this.topic});

  final LearningTopic topic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          topic.name,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          topic.description,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TopicMeta extends StatelessWidget {
  const _TopicMeta({required this.topic, required this.accent});

  final LearningTopic topic;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        LevelPill(level: topic.difficulty, accent: accent),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 12,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 3),
            Text(
              '${topic.estimatedMinutes}m',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
