import 'package:flutter/material.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class AiResponseSheet extends StatefulWidget {
  const AiResponseSheet({
    super.key,
    required this.action,
    required this.selectedText,
  });

  final AiAction action;
  final String selectedText;

  @override
  State<AiResponseSheet> createState() => _AiResponseSheetState();
}

class _AiResponseSheetState extends State<AiResponseSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _typeCtrl;
  late final Animation<int> _charCount;
  String get _fullResponse => _responseFor(widget.action);

  @override
  void initState() {
    super.initState();
    _typeCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_fullResponse.length * 18).clamp(800, 3000)),
    )..forward();
    _charCount = IntTween(begin: 0, end: _fullResponse.length)
        .animate(CurvedAnimation(parent: _typeCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    super.dispose();
  }

  String _responseFor(AiAction action) {
    switch (action) {
      case AiAction.explain:
        return 'The selected passage explains a foundational concept in the topic. '
            'In simpler terms: the idea is that systems learn by adjusting internal parameters '
            'based on feedback from their output. Think of it like learning to ride a bike — '
            'each fall teaches your body a small correction until balance becomes automatic. '
            'The key insight is that no one programs the corrections explicitly; they emerge from the process itself.';
      case AiAction.imagine:
        return '🎨 Generating a visual representation...\n\n'
            'Imagine a glowing web of nodes arranged in columns. '
            'Light pulses travel left to right, growing brighter or dimmer at each node. '
            'Where pulses are strong they activate the next layer; where weak they fade. '
            'The final column lights up with the answer — shaped entirely by how the pulses flowed.';
      case AiAction.takeNote:
        return '📝 Note saved!\n\n'
            '"${widget.selectedText.length > 80 ? widget.selectedText.substring(0, 80) + '...' : widget.selectedText}"\n\n'
            'Added to your notes with a highlight. You can review it in the Notes section.';
    }
  }

  IconData get _icon {
    switch (widget.action) {
      case AiAction.explain:   return Icons.auto_awesome_rounded;
      case AiAction.imagine:   return Icons.image_outlined;
      case AiAction.takeNote:  return Icons.edit_note_rounded;
    }
  }

  String get _title {
    switch (widget.action) {
      case AiAction.explain:  return 'AI Explanation';
      case AiAction.imagine:  return 'Visual Concept';
      case AiAction.takeNote: return 'Note Saved';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        EduSpacing.s6, EduSpacing.s4, EduSpacing.s6, EduSpacing.s8,
      ),
      decoration: const BoxDecoration(
        color: EduColors.surface,
        borderRadius: BorderRadius.vertical(top: EduRadius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: EduColors.border,
                borderRadius: EduRadius.borderPill,
              ),
            ),
          ),
          const SizedBox(height: EduSpacing.s5),

          // Header
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [EduColors.primaryLight, EduColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: EduRadius.borderMd,
                ),
                child: Icon(_icon, color: EduColors.textInverse, size: 18),
              ),
              const SizedBox(width: EduSpacing.s3),
              Text(_title, style: tt.titleLarge),
            ],
          ),
          const SizedBox(height: EduSpacing.s4),

          // Selected text chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: EduColors.bg,
              borderRadius: EduRadius.borderMd,
              border: Border.all(color: EduColors.border),
            ),
            child: Text(
              widget.selectedText.length > 60
                  ? '"${widget.selectedText.substring(0, 60)}…"'
                  : '"${widget.selectedText}"',
              style: tt.bodySmall?.copyWith(
                color: EduColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: EduSpacing.s5),

          // Typewriter response
          AnimatedBuilder(
            animation: _charCount,
            builder: (context, _) {
              final visible = _fullResponse.substring(0, _charCount.value);
              return Text(visible, style: tt.bodyLarge);
            },
          ),
          const SizedBox(height: EduSpacing.s6),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Dismiss'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EduColors.textSecondary,
                    side: const BorderSide(color: EduColors.border),
                    shape: const StadiumBorder(),
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
              const SizedBox(width: EduSpacing.s3),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                  label: const Text('Save'),
                  style: FilledButton.styleFrom(
                    backgroundColor: EduColors.primary,
                    foregroundColor: EduColors.textInverse,
                    shape: const StadiumBorder(),
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
