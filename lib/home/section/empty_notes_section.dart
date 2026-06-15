import 'package:flutter/material.dart';
import 'package:modern_learner_production/home/widgets/empty_notes_illustration.dart';
import 'package:modern_learner_production/theme/theme.dart';

class EmptyNotesSection extends StatelessWidget {
  const EmptyNotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: EduSpacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My notes', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: EduSpacing.s8),
          const Center(child: EmptyNotesIllustration()),
        ],
      ),
    );
  }
}
