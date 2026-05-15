import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/view/widgets/topic_card_icon.dart';
import 'package:modern_learner_production/features/explore/view/widgets/topic_card_meta.dart';
import 'package:modern_learner_production/features/explore/view/widgets/topic_card_text.dart';

class TopicCard extends StatefulWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.accent,
    this.onTap,
  });

  final LearningTopic topic;
  final Color accent;
  final VoidCallback? onTap;

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
    _scale = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
      onTap: widget.onTap,
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
              TopicCardIcon(emoji: topic.emoji, accent: accent),
              const SizedBox(width: 14),
              Expanded(child: TopicCardText(topic: topic)),
              const SizedBox(width: 12),
              TopicCardMeta(topic: topic, accent: accent),
            ],
          ),
        ),
      ),
    );
  }
}
