import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/new_lesson/data/new_lesson_page_data.dart';
import 'package:modern_learner_production/features/new_lesson/model/lesson_actions_model.dart';
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
                  _ContinueLearningSection(
                    lessons: widget.lessons,
                    loading: widget.lessonsLoading,
                    onRefresh: widget.onLessonsRefresh,
                  ),
                ],
              ),
            ),
          ),
          NewLessonActionSection(
            canStart: _canStart,
            selectedLanguage: _selectedLanguage,
            selectedDifficulty: _selectedDifficulty,
            onStart: () => _onStart(context),
          ),
        ],
      ),
    );
  }

  void _onStart(BuildContext context) {
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

    navigator.pop();
    router.go(Routes.progress, extra: course);
  }
}

class _ContinueLearningSection extends StatelessWidget {
  const _ContinueLearningSection({
    required this.lessons,
    required this.loading,
    this.onRefresh,
  });

  final List<AddLesson> lessons;
  final bool loading;
  final VoidCallback? onRefresh;

  static const _accentColors = [
    Color(0xFFB1A0FF),
    Color(0xFF929BFA),
    Color(0xFF7E51FF),
    Color(0xFFB1FFCE),
  ];

  static const _emojis = ['📚', '🎯', '✏️', '🧠', '🚀', '💡'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'CONTINUE LEARNING',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (onRefresh != null)
              GestureDetector(
                onTap: onRefresh,
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (lessons.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No lessons yet. Create your first one above!',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lessons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final lesson = lessons[i];
              final accent = _accentColors[i % _accentColors.length];
              final emoji = _emojis[i % _emojis.length];
              return _LessonTile(
                lesson: lesson,
                accent: accent,
                emoji: emoji,
              );
            },
          ),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.accent,
    required this.emoji,
  });

  final AddLesson lesson;
  final Color accent;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final isDraft = lesson.status == LessonStatus.draft;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title.isEmpty ? 'Untitled Lesson' : lesson.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lesson.lessonType.name[0].toUpperCase() +
                        lesson.lessonType.name.substring(1),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isDraft
                    ? AppColors.surfaceContainerHigh
                    : accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                isDraft ? 'Draft' : lesson.status.name,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDraft ? AppColors.onSurfaceVariant : accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
