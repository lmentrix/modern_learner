import 'package:flutter/material.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, required this.onTap});

  final StudyNote note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final tagBg = Color(note.tagColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EduSpacing.cardPadding,
        decoration: BoxDecoration(
          color: EduColors.surface,
          borderRadius: EduRadius.borderXl,
          boxShadow: EduColors.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: EduRadius.borderPill,
                  ),
                  child: Text(note.subject, style: tt.labelLarge),
                ),
                const Spacer(),
                Icon(Icons.schedule_rounded, size: 14, color: EduColors.textSecondary),
                const SizedBox(width: 4),
                Text('${note.readMinutes} min', style: tt.labelMedium),
              ],
            ),
            const SizedBox(height: EduSpacing.s3),
            Text(note.title, style: tt.titleLarge),
            const SizedBox(height: EduSpacing.s1),
            Text(
              note.preview,
              style: tt.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: EduSpacing.s4),
            Row(
              children: [
                Text(note.createdAt, style: tt.labelMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: EduColors.primaryLight,
                    borderRadius: EduRadius.borderPill,
                  ),
                  child: Row(
                    children: [
                      Text('Open', style: tt.labelLarge?.copyWith(color: EduColors.primary)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 12, color: EduColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
