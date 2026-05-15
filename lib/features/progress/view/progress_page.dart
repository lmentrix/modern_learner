import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/state/progress_navigation_state.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_constants.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_seed.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_empty_state_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_header_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_hero_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_journey_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_stats_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_weekly_section.dart';

class ProgressViewPage extends StatelessWidget {
  const ProgressViewPage({super.key, this.initialCourseSelection});

  final ProgressCourseSelection? initialCourseSelection;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProgressCourseSelection>>(
      valueListenable: ExploreCoursesService.instance.courses,
      builder: (context, courses, child) {
        final selectedCourse =
            initialCourseSelection ??
            switch (courses) {
              [final first, ...] => first,
              _ => null,
            };

        if (selectedCourse == null) {
          return const Material(
            color: AppColors.surface,
            child: ProgressEmptyStateSection(),
          );
        }

        final navState = getIt<ProgressNavigationState>();
        final pageData = buildProgressPageData(
          course: selectedCourse,
          selectedChapterId: navState.selectedChapterId,
        );

        if (navState.hasSelection) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (navState.hasSelection) {
              navState.clearSelection();
            }
          });
        }

        return Material(
          color: AppColors.surface,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: ProgressHeaderSection(data: pageData)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: ProgressHeroSection(data: pageData),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: ProgressPageConstants.sectionSpacing),
              ),
              SliverPadding(
                padding: ProgressPageConstants.pagePadding,
                sliver: SliverToBoxAdapter(
                  child: ProgressStatsSection(data: pageData),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: ProgressPageConstants.sectionSpacing),
              ),
              SliverPadding(
                padding: ProgressPageConstants.pagePadding,
                sliver: SliverToBoxAdapter(
                  child: ProgressWeeklySection(data: pageData),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: ProgressPageConstants.sectionSpacing),
              ),
              SliverPadding(
                padding: ProgressPageConstants.pagePadding,
                sliver: SliverToBoxAdapter(
                  child: ProgressJourneySection(data: pageData),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        );
      },
    );
  }
}
