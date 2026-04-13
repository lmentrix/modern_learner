import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/presentation/bloc/learning_subjects_bloc.dart';
import 'package:modern_learner_production/features/explore/presentation/bloc/learning_subjects_event.dart';
import 'package:modern_learner_production/features/explore/presentation/bloc/learning_subjects_state.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/learning_subject_card.dart';

// ── Category filter chips ─────────────────────────────────────────────────────

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
        final active =
            state is LearningSubjectsLoaded ? state.activeCategory : null;
        return SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: _filters.entries.map((entry) {
              final isActive = active == entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: entry.key,
                  isActive: isActive,
                  onTap: () => context
                      .read<LearningSubjectsBloc>()
                      .add(FilterByCategory(entry.value)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.primaryGradient : null,
          color: isActive
              ? null
              : AppColors.surfaceContainerHighest.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : AppColors.outlineVariant.withValues(alpha: 0.18),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive
                  ? const Color(0xFF1A1028)
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Grid (BlocBuilder) ────────────────────────────────────────────────────────

class LearningSubjectsGrid extends StatelessWidget {
  const LearningSubjectsGrid({super.key, required this.onSubjectTap});

  final void Function(BuildContext context, LearningSubject subject) onSubjectTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningSubjectsBloc, LearningSubjectsState>(
      builder: (context, state) {
        if (state is LearningSubjectsLoading) {
          return const _SubjectsLoadingSkeleton();
        }
        if (state is LearningSubjectsLoaded) {
          final subjects = state.displayed;
          if (subjects.isEmpty) return const _SubjectsEmptyState();
          return _SubjectsGridSliver(
            subjects: subjects,
            onTap: (s) => onSubjectTap(context, s),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

class _SubjectsLoadingSkeleton extends StatelessWidget {
  const _SubjectsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          childCount: 6,
        ),
      ),
    );
  }
}

class _SubjectsEmptyState extends StatelessWidget {
  const _SubjectsEmptyState();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Text('🔎', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 10),
              Text(
                'No subjects match that filter',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectsGridSliver extends StatelessWidget {
  const _SubjectsGridSliver({
    required this.subjects,
    required this.onTap,
  });

  final List<LearningSubject> subjects;
  final void Function(LearningSubject) onTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, index) => LearningSubjectCard(
            subject: subjects[index],
            onTap: () => onTap(subjects[index]),
          ),
          childCount: subjects.length,
        ),
      ),
    );
  }
}
