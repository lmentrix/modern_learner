import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/presentation/bloc/learning_subjects_bloc.dart';
import 'package:modern_learner_production/features/explore/presentation/bloc/learning_subjects_event.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/explore_header.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/learning_subjects_section.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LearningSubjectsBloc>(
      create: (_) =>
          getIt<LearningSubjectsBloc>()..add(const LoadLearningSubjects()),
      child: Container(
        color: AppColors.surface,
        child: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              const SliverToBoxAdapter(child: ExploreHeader()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.sizeOf(context).width >= 600 ? 28 : 20,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'LEARNING SUBJECTS · CURATED CATALOG',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.7,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 6)),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.sizeOf(context).width >= 600 ? 28 : 20,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Browse comprehensive subjects across science, humanities, arts, and more.',
                    style: GoogleFonts.inter(
                      fontSize: MediaQuery.sizeOf(context).width >= 600 ? 14 : 13,
                      height: 1.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverToBoxAdapter(child: LearningSubjectsCategoryFilter()),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              LearningSubjectsGrid(
                onSubjectTap: (ctx, subject) =>
                    ctx.push(Routes.learningSubjectDetail, extra: subject),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
