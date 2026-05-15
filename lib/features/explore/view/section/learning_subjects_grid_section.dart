import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/view/bloc/learning_subjects_bloc.dart';
import 'package:modern_learner_production/features/explore/view/bloc/learning_subjects_state.dart';
import 'package:modern_learner_production/features/explore/view/widgets/learning_subjects_empty_state.dart';
import 'package:modern_learner_production/features/explore/view/widgets/learning_subjects_grid_sliver.dart';
import 'package:modern_learner_production/features/explore/view/widgets/learning_subjects_loading_skeleton.dart';

class LearningSubjectsGrid extends StatelessWidget {
  const LearningSubjectsGrid({super.key, required this.onSubjectTap});

  final void Function(BuildContext context, LearningSubject subject)
  onSubjectTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningSubjectsBloc, LearningSubjectsState>(
      builder: (context, state) {
        if (state is LearningSubjectsLoading) {
          return const LearningSubjectsLoadingSkeleton();
        }
        if (state is LearningSubjectsLoaded) {
          final subjects = state.displayed;
          if (subjects.isEmpty) return const LearningSubjectsEmptyState();
          return LearningSubjectsGridSliver(
            subjects: subjects,
            onTap: (subject) => onSubjectTap(context, subject),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
