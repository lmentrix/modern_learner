import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/exercise/models/exercise.dart';
import 'package:modern_learner_production/features/exercise/pages/exercise_page.dart';
import 'package:modern_learner_production/features/home/data/all_lessons_lesson.dart';
import 'package:modern_learner_production/features/home/data/home_lesson_filter.dart';
import 'package:modern_learner_production/features/home/view/section/all_lessons_empty_state_section.dart';
import 'package:modern_learner_production/features/home/view/section/all_lessons_header_section.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_section_label.dart';
import 'package:modern_learner_production/features/home/view/widgets/lesson_card.dart';

class AllLessonsPage extends StatefulWidget {
  const AllLessonsPage({super.key, required this.filter});

  final LessonFilter filter;

  @override
  State<AllLessonsPage> createState() => _AllLessonsPageState();
}

class _AllLessonsPageState extends State<AllLessonsPage> {
  final List<AllLessonsLesson> _lessons = [];

  void _openLesson(AllLessonsLesson lesson) {
    if (lesson.lessonType == 'language') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExercisePage(
            lessonType: LessonType.voice,
            title: lesson.title,
            sectionTitle: lesson.subtitle,
            accentColor: AppColors.primary,
            emoji: lesson.emoji,
          ),
        ),
      );
    } else {
      context.go(Routes.progress, extra: lesson.toCourseSelection());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = widget.filter == LessonFilter.voice
        ? 'Voice Lessons'
        : 'School Lessons';
    final sectionTitle = widget.filter == LessonFilter.voice
        ? 'VOICE LESSONS'
        : 'SCHOOL LESSONS';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AllLessonsHeaderSection(
                title: pageTitle,
                onBackTap: () => Navigator.pop(context),
              ),
            ),
            if (_lessons.isEmpty)
              const SliverFillRemaining(child: AllLessonsEmptyStateSection())
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: HomeSectionLabel(text: sectionTitle),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: _lessons.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final lesson = _lessons[i];
                    return LessonCard(
                      emoji: lesson.emoji,
                      title: lesson.title,
                      chapter: lesson.subtitle,
                      duration: lesson.duration,
                      progress: lesson.progress,
                      accentColor: widget.filter == LessonFilter.voice
                          ? AppColors.primary
                          : AppColors.secondary,
                      isNew: lesson.status == 'draft',
                      lessonType: widget.filter == LessonFilter.voice
                          ? 'language'
                          : 'school',
                      onTap: () => _openLesson(lesson),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ],
        ),
      ),
    );
  }
}
