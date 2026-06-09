import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/utils/responsive.dart';
import 'package:modern_learner_production/features/explore/data/datasources/learning_subject_local_datasource.dart';
import 'package:modern_learner_production/features/explore/data/repositories/learning_subject_repository_impl.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/get_all_learning_subjects.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/get_subjects_by_category.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/search_learning_subjects.dart';
import 'package:modern_learner_production/features/explore/view/bloc/learning_subjects_bloc.dart';
import 'package:modern_learner_production/features/explore/view/bloc/learning_subjects_event.dart';
import 'package:modern_learner_production/features/explore/view/section/learning_subjects_category_filter_section.dart';
import 'package:modern_learner_production/features/explore/view/section/learning_subjects_grid_section.dart';
import 'package:modern_learner_production/features/explore/view/widgets/explore_header.dart';
import 'package:modern_learner_production/features/profile/data/profile_preferences.dart';
import 'package:modern_learner_production/features/profile/view/widgets/notification_preference_switch.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LearningSubjectsBloc>(
      create: (_) {
        final repo = LearningSubjectRepositoryImpl(
          LearningSubjectLocalDatasourceImpl(),
        );
        return LearningSubjectsBloc(
          getAllSubjects: GetAllLearningSubjects(repo),
          getByCategory: GetSubjectsByCategory(repo),
          searchSubjects: SearchLearningSubjects(repo),
        )..add(LoadLearningSubjects());
      },
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
                  horizontal: Responsive.hPad(context),
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
                  horizontal: Responsive.hPad(context),
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Browse comprehensive subjects across science, humanities, arts, and more.',
                    style: GoogleFonts.inter(
                      fontSize: Responsive.bodySize(context) - 1,
                      height: 1.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.hPad(context),
                ),
                sliver: SliverToBoxAdapter(
                  child: NotificationPreferenceSwitch(
                    icon: Icons.school_outlined,
                    title: 'School lesson notifications',
                    subtitle: 'Notify me when a school course is created.',
                    valueOf: (preferences) =>
                        preferences.schoolCourseCreationNotifications,
                    copyWithValue:
                        (ProfilePreferences preferences, bool value) =>
                            preferences.copyWith(
                              schoolCourseCreationNotifications: value,
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
