import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/auth/service/auth_service.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/new_lesson/data/new_lesson_page_data.dart';
import 'package:modern_learner_production/features/new_lesson/model/lesson_actions_model.dart';
import 'package:modern_learner_production/features/new_lesson/service/lesson_actions.dart';
import 'package:modern_learner_production/features/new_lesson/view/section/new_lesson_action_section.dart';
import 'package:modern_learner_production/features/new_lesson/view/section/new_lesson_difficulty_section.dart';
import 'package:modern_learner_production/features/new_lesson/view/section/new_lesson_header_section.dart';
import 'package:modern_learner_production/features/new_lesson/view/section/new_lesson_language_section.dart';
import 'package:modern_learner_production/features/new_lesson/view/section/new_lesson_preview_section.dart';

class NewLessonComposerSection extends StatefulWidget {
  const NewLessonComposerSection({
    super.key,
    this.lessons = const [],
    this.lessonsLoading = false,
    this.onLessonsRefresh,
  });

  final List<AddLesson> lessons;
  final bool lessonsLoading;
  final VoidCallback? onLessonsRefresh;

  @override
  State<NewLessonComposerSection> createState() =>
      _NewLessonComposerSectionState();
}

class _NewLessonComposerSectionState extends State<NewLessonComposerSection> {
  String? _selectedLanguage;
  String _selectedDifficulty = 'Beginner';

  bool get _canStart => _selectedLanguage != null;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NewLessonHeaderSection(onClose: () => Navigator.of(context).pop()),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NewLessonPreviewSection(
                    selectedLanguage: _selectedLanguage,
                    selectedDifficulty: _selectedDifficulty,
                  ),
                  const SizedBox(height: 28),
                  NewLessonLanguageSection(
                    options: NewLessonPageData.languages,
                    selectedLanguage: _selectedLanguage,
                    onLanguageSelected: (value) {
                      setState(() => _selectedLanguage = value);
                    },
                  ),
                  const SizedBox(height: 28),
                  NewLessonDifficultySection(
                    options: NewLessonPageData.difficulties,
                    selectedDifficulty: _selectedDifficulty,
                    onDifficultySelected: (value) {
                      setState(() => _selectedDifficulty = value);
                    },
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
          NewLessonActionSection(
            canStart: _canStart,
            selectedLanguage: _selectedLanguage,
            selectedDifficulty: _selectedDifficulty,
            onStart: () => _onStart(context).ignore(),
          ),
        ],
      ),
    );
  }

  Future<void> _onStart(BuildContext context) async {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);

    final course = ProgressCourseSelection(
      title: _selectedLanguage!,
      topic: _selectedLanguage!,
      roadmapLanguage: _selectedLanguage!,
      level: _selectedDifficulty.toLowerCase(),
      nativeLanguage: 'English',
      courseType: ProgressCourseType.voice,
    );

    ExploreCoursesService.instance.addCourse(course);

    final userId = AuthService.instance.currentUser?.id;
    if (userId != null) {
      try {
        await addLessonService(
          userId: userId,
          title: _selectedLanguage!,
          content: {
            'language': _selectedLanguage,
            'difficulty': _selectedDifficulty,
          },
          lessonType: LessonType.voice,
          contentType: 'language',
          difficulty: _selectedDifficulty,
          status: LessonStatus.active,
        );
      } catch (_) {
        // lesson save is best-effort; navigation proceeds regardless
      }
    }

    navigator.pop();
    router.go(Routes.progress, extra: course);
  }
}
