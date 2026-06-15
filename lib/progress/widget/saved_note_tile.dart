import 'package:flutter/material.dart';
import 'package:modern_learner_production/progress/model/progress_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class SavedNoteTile extends StatelessWidget {
  const SavedNoteTile({super.key, required this.ref});

  final SavedNoteRef ref;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final tagBg = Color(ref.tagColor);

    return Container(
      padding: EduSpacing.cardPadding,
      decoration: BoxDecoration(
        color: EduColors.surface,
        borderRadius: EduRadius.borderXl,
        boxShadow: EduColors.shadowCard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: EduRadius.borderMd,
            ),
            child: const Icon(Icons.sticky_note_2_outlined,
                size: 22, color: EduColors.textPrimary),
          ),
          const SizedBox(width: EduSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: EduRadius.borderPill,
                      ),
                      child: Text(ref.subject, style: tt.labelSmall),
                    ),
                    const Spacer(),
                    Text(ref.savedDate, style: tt.labelSmall),
                  ],
                ),
                const SizedBox(height: EduSpacing.s1),
                Text(ref.title, style: tt.titleSmall),
                const SizedBox(height: EduSpacing.s1),
                Text(
                  ref.excerpt,
                  style: tt.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
