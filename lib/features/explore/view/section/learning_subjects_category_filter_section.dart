import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/view/bloc/learning_subjects_bloc.dart';
import 'package:modern_learner_production/features/explore/view/bloc/learning_subjects_event.dart';
import 'package:modern_learner_production/features/explore/view/bloc/learning_subjects_state.dart';
import 'package:modern_learner_production/features/explore/view/widgets/learning_subjects_filter_chip.dart';

class LearningSubjectsCategoryFilter extends StatelessWidget {
  const LearningSubjectsCategoryFilter({super.key});

  static const _filters = <String, SubjectCategory?>{
    'All': null,
    'STEM': SubjectCategory.stem,
    'Humanities': SubjectCategory.humanities,
    'Arts': SubjectCategory.arts,
    'Languages': SubjectCategory.languages,
    'Social Sciences': SubjectCategory.socialSciences,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningSubjectsBloc, LearningSubjectsState>(
      builder: (context, state) {
        final active = state is LearningSubjectsLoaded
            ? state.activeCategory
            : null;
        final hPad = MediaQuery.sizeOf(context).width >= 600 ? 28.0 : 20.0;
        return SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            children: _filters.entries.map((entry) {
              final isActive = active == entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: LearningSubjectsFilterChip(
                  label: entry.key,
                  isActive: isActive,
                  onTap: () => context.read<LearningSubjectsBloc>().add(
                    FilterByCategory(entry.value),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
