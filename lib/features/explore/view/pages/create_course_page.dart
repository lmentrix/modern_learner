import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/auth/service/auth_service.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/explore/view/section/create_course_header_section.dart';
import 'package:modern_learner_production/features/explore/view/section/create_course_language_dropdown_section.dart';
import 'package:modern_learner_production/features/explore/view/section/create_course_level_selector_section.dart';
import 'package:modern_learner_production/features/explore/view/section/create_course_preview_section.dart';
import 'package:modern_learner_production/features/explore/view/widgets/create_course_section_label.dart';
import 'package:modern_learner_production/features/new_lesson/model/lesson_actions_model.dart';
import 'package:modern_learner_production/features/new_lesson/service/lesson_actions.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key, required this.subject, this.topic});

  final LearningSubject subject;
  final LearningTopic? topic;

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  static const _levels = ['beginner', 'intermediate', 'advanced'];
  static const _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Arabic',
  ];

  late String _selectedLevel;
  late String _selectedLanguage;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    final source = widget.topic ?? _fallbackTopic();
    _selectedLevel = source.difficulty.label.toLowerCase();
    _selectedLanguage = 'English';
  }

  LearningTopic _fallbackTopic() => widget.subject.topics.isNotEmpty
      ? widget.subject.topics.first
      : LearningTopic(
          id: widget.subject.id,
          name: widget.subject.name,
          description: widget.subject.description,
          emoji: widget.subject.emoji,
          difficulty: widget.subject.difficulty,
          estimatedMinutes: 30,
        );

  Color get _accent => widget.subject.accentColor;
  String get _topicName =>
      widget.topic?.name ??
      (widget.subject.topics.isNotEmpty
          ? widget.subject.topics.first.name
          : widget.subject.name);

  Future<void> _createCourse() async {
    setState(() => _creating = true);

    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId != null) {
        final difficulty = _selectedLevel[0].toUpperCase() +
            _selectedLevel.substring(1);
        await addLessonService(
          userId: userId,
          title: widget.subject.name,
          content: {
            'topic': _topicName,
            'level': _selectedLevel,
            'nativeLanguage': _selectedLanguage,
            'subject': widget.subject.name,
          },
          lessonType: LessonType.school,
          contentType: 'school',
          difficulty: difficulty,
          status: LessonStatus.active,
        );
      }

      final course = ProgressCourseSelection(
        title: widget.subject.name,
        topic: _topicName,
        roadmapLanguage: _topicName,
        level: _selectedLevel,
        nativeLanguage: _selectedLanguage,
        courseType: ProgressCourseType.school,
      );
      ExploreCoursesService.instance.addCourse(course);

      if (!mounted) return;
      context.go(Routes.home);
    } catch (e) {
      debugPrint('[CreateCourse] addLessonService failed: $e');
      if (!mounted) return;
      setState(() => _creating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('relation')
                ? 'Table not found — run the Supabase migration first.'
                : e.toString().contains('row-level security')
                ? 'Permission denied — check RLS policies.'
                : e.toString().contains('JWT') || e.toString().contains('auth')
                ? 'Not authenticated — please sign in again.'
                : 'Failed to save: $e',
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTopic = widget.topic != null;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w < 360
        ? 16.0
        : w >= 600
        ? 28.0
        : 20.0;

    return Material(
      color: AppColors.surface,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: CreateCourseHeaderSection(
              subject: widget.subject,
              topic: widget.topic,
              accent: _accent,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 40),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CreateCoursePreviewSection(
                    subject: widget.subject,
                    topic: widget.topic,
                    accent: _accent,
                    isTopic: isTopic,
                  ),
                  const SizedBox(height: 32),
                  const CreateCourseSectionLabel(label: 'DIFFICULTY LEVEL'),
                  const SizedBox(height: 12),
                  CreateCourseLevelSelectorSection(
                    levels: _levels,
                    selected: _selectedLevel,
                    accent: _accent,
                    onChanged: (value) =>
                        setState(() => _selectedLevel = value),
                  ),
                  const SizedBox(height: 28),
                  const CreateCourseSectionLabel(label: 'YOUR NATIVE LANGUAGE'),
                  const SizedBox(height: 12),
                  CreateCourseLanguageDropdownSection(
                    languages: _languages,
                    selected: _selectedLanguage,
                    accent: _accent,
                    onChanged: (value) =>
                        setState(() => _selectedLanguage = value),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _creating ? null : _createCourse,
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        disabledBackgroundColor: _accent.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _creating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_outline_rounded),
                                const SizedBox(width: 10),
                                Text(
                                  'Create Course',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Course will appear on your Home page',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
