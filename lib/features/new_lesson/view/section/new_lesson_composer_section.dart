import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modern_learner_production/core/utils/responsive.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/cache/generation_cache.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/new_lesson/data/new_lesson_page_data.dart';
import 'package:modern_learner_production/features/new_lesson/view/section/new_lesson_action_section.dart';
import 'package:modern_learner_production/features/new_lesson/view/section/new_lesson_difficulty_section.dart';
import 'package:modern_learner_production/features/new_lesson/view/section/new_lesson_header_section.dart';
import 'package:modern_learner_production/features/new_lesson/view/section/new_lesson_language_section.dart';
import 'package:modern_learner_production/features/new_lesson/view/section/new_lesson_preview_section.dart';
import 'package:modern_learner_production/features/profile/data/profile_preferences.dart';
import 'package:modern_learner_production/features/profile/service/profile_notification_preferences_service.dart';
import 'package:modern_learner_production/features/profile/view/widgets/notification_preference_switch.dart';
import 'package:modern_learner_production/features/progress/service/cache/roadmap_id_cache.dart';
import 'package:modern_learner_production/features/push_notification/service/push_notification_service_locator.dart';
import 'package:modern_learner_production/features/roadmap/service/roadmap_service.dart';

class NewLessonComposerSection extends StatefulWidget {
  const NewLessonComposerSection({
    super.key,
    this.showVoiceNotificationToggle = false,
  });

  final bool showVoiceNotificationToggle;

  @override
  State<NewLessonComposerSection> createState() =>
      _NewLessonComposerSectionState();
}

class _NewLessonComposerSectionState extends State<NewLessonComposerSection> {
  String? _selectedLanguage;
  String _selectedDifficulty = 'Beginner';

  /// True while the course is being saved to Supabase and the courseId is
  /// being resolved. The action button shows a spinner during this window.
  bool _isStarting = false;

  bool get _canStart => _selectedLanguage != null && !_isStarting;

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.hPad(context);

    return Material(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NewLessonHeaderSection(onClose: () => Navigator.of(context).pop()),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Responsive.maxContentWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NewLessonPreviewSection(
                          selectedLanguage: _selectedLanguage,
                          selectedDifficulty: _selectedDifficulty,
                        ),
                        if (widget.showVoiceNotificationToggle) ...[
                          const SizedBox(height: 18),
                          NotificationPreferenceSwitch(
                            icon: Icons.record_voice_over_outlined,
                            title: 'Voice lesson notifications',
                            subtitle:
                                'Notify me when a voice lesson is created.',
                            valueOf: (preferences) =>
                                preferences.voiceLessonCreationNotifications,
                            copyWithValue:
                                (ProfilePreferences preferences, bool value) =>
                                    preferences.copyWith(
                                      voiceLessonCreationNotifications: value,
                                    ),
                          ),
                        ],
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
              ),
            ),
          ),
          NewLessonActionSection(
            canStart: _canStart,
            isStarting: _isStarting,
            selectedLanguage: _selectedLanguage,
            selectedDifficulty: _selectedDifficulty,
            onStart: () => _onStart(context).ignore(),
          ),
        ],
      ),
    );
  }

  Future<void> _onStart(BuildContext context) async {
    final selectedLanguage = _selectedLanguage;
    if (selectedLanguage == null ||
        selectedLanguage.trim().isEmpty ||
        _isStarting) {
      return;
    }

    setState(() => _isStarting = true);

    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);

    final courseTemplate = ProgressCourseSelection(
      title: selectedLanguage,
      topic: selectedLanguage,
      roadmapLanguage: selectedLanguage,
      level: _selectedDifficulty.toLowerCase(),
      nativeLanguage: 'English',
      courseType: ProgressCourseType.voice,
    );

    // Await course creation so the Supabase row (and its courseId) exists
    // before navigating.
    await ExploreCoursesService.instance.addCourse(courseTemplate);

    // Retrieve the saved/existing course — it now carries a courseId.
    final savedCourse =
        ExploreCoursesService.instance.courses.value
            .cast<ProgressCourseSelection?>()
            .firstWhere(
              (c) =>
                  c != null &&
                  c.title == courseTemplate.title &&
                  c.topic == courseTemplate.topic &&
                  c.level == courseTemplate.level &&
                  c.nativeLanguage == courseTemplate.nativeLanguage,
              orElse: () => null,
            ) ??
        courseTemplate;

    // ── Wipe all three stale-data sources before navigating ──────────────
    // Every time the user taps "Generate" we want a fresh roadmap, not
    // whatever was cached or saved from a previous run of this same course.

    final roadmapCacheKey = RoadmapIdCache.buildRoadmapCacheKey(
      roadmapMode: 'voice',
      topic: selectedLanguage,
      language: selectedLanguage,
      level: _selectedDifficulty.toLowerCase(),
      nativeLanguage: 'English',
    );

    final courseId = savedCourse.courseId;

    // 1. Collect chapter/exercise keys from Supabase before deleting rows,
    //    so we can also purge the matching on-disk cache entries.
    List<int> chapterNumbers = const [];
    List<({String chapterSubcontentId, int subcontentNumber})> exerciseKeys =
        const [];
    if (courseId != null) {
      try {
        final results = await Future.wait([
          RoadmapService.instance.fetchChapterNumbersForCourse(courseId),
          RoadmapService.instance.fetchExerciseKeysForCourse(courseId),
        ]);
        chapterNumbers = results[0] as List<int>;
        exerciseKeys =
            results[1]
                as List<({String chapterSubcontentId, int subcontentNumber})>;
      } catch (_) {}
    }

    await Future.wait([
      // 2. Clear on-disk cache (roadmap + all subcontent + all exercises).
      const GenerationCache().clearCourseEntries(
        roadmapCacheKey: roadmapCacheKey,
        chapterNumbers: chapterNumbers,
        exerciseKeys: exerciseKeys,
      ),
      // 3. Clear the RoadmapIdCache entry so old roadmap IDs aren't reused.
      const RoadmapIdCache().clearRoadmapId(cacheKey: roadmapCacheKey),
      // 4. Delete all generated Supabase rows for this course so _loadFromDb
      //    cannot serve stale data.
      if (courseId != null)
        RoadmapService.instance.resetCourseGeneratedContent(courseId),
    ]);

    // 5. Clear in-memory roadmapJson so _syncSelectedCourse shows the
    //    skeleton and forces fresh generation on the progress page.
    if (courseId != null) {
      await ExploreCoursesService.instance.updateCourse(
        savedCourse.copyWith(clearRoadmapJson: true),
      );
    }

    // ─────────────────────────────────────────────────────────────────────

    if (ProfileNotificationPreferencesService
        .instance
        .preferences
        .voiceLessonCreationNotifications) {
      unawaited(
        pushNotificationService.notifyNewVoiceLesson(
          language: selectedLanguage,
          difficulty: _selectedDifficulty,
        ),
      );
    }

    if (!mounted) return;
    navigator.pop();
    // Navigate with the course that has a courseId but no roadmapJson so
    // the progress page starts the full: Supabase check → AI generate → cache flow.
    router.go(
      Routes.progress,
      extra: savedCourse.copyWith(clearRoadmapJson: true),
    );
  }
}
