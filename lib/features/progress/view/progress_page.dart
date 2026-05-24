import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/state/progress_navigation_state.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/profile/view/widgets/learning_activity_scope.dart';
import 'package:modern_learner_production/features/progress/bloc/xp_bloc.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_constants.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_seed.dart';
import 'package:modern_learner_production/features/progress/service/cache/roadmap_id_cache.dart';
import 'package:modern_learner_production/features/progress/service/model/chapter_subcontent_model.dart';
import 'package:modern_learner_production/features/progress/service/model/roadmap_model.dart';
import 'package:modern_learner_production/features/progress/service/request/chapter_subcontent.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/service/request/progress_request.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_empty_state_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_header.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_journey_section.dart';

class ProgressViewPage extends StatefulWidget {
  const ProgressViewPage({super.key, this.initialCourseSelection});

  final ProgressCourseSelection? initialCourseSelection;

  @override
  State<ProgressViewPage> createState() => _ProgressViewPageState();
}

class _ProgressViewPageState extends State<ProgressViewPage> {
  final Map<String, XpBloc> _xpBlocByCourse = {};

  bool _isLoadingChapterSubcontent = false;
  String? _chapterSubcontentError;
  String? _selectedCourseKey;
  String? _selectedChapterId;
  ChapterSubcontentResponseModel? _chapterSubcontentResponse;
  int _chapterSubcontentRequestToken = 0;
  final Map<String, ChapterSubcontentResponseModel> _chapterSubcontentCache =
      <String, ChapterSubcontentResponseModel>{};
  final Map<String, int> _unlockedChapterLimitByCourse = <String, int>{};

  @override
  void dispose() {
    for (final bloc in _xpBlocByCourse.values) {
      bloc.close();
    }
    super.dispose();
  }

  XpBloc _xpBlocFor(ProgressCourseSelection course) {
    final key = _courseKey(course);
    return _xpBlocByCourse.putIfAbsent(key, () => getIt<XpBloc>(param1: key));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProgressCourseSelection>>(
      valueListenable: ExploreCoursesService.instance.courses,
      builder: (context, courses, child) {
        final selectedCourse = _resolveSelectedCourse(courses);

        if (selectedCourse == null) {
          return const Material(
            color: AppColors.surface,
            child: ProgressEmptyStateSection(),
          );
        }

        _syncSelectedCourse(selectedCourse);

        final navState = getIt<ProgressNavigationState>();
        final pageData = buildProgressPageData(
          course: selectedCourse,
          unlockedChapterLimit: _unlockedChapterLimit(selectedCourse),
        );
        if (navState.hasSelection) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (navState.hasSelection) {
              navState.clearSelection();
            }
          });
        }

        return BlocProvider.value(
          value: _xpBlocFor(selectedCourse),
          child: LearningActivityScope(
            child: Material(
              color: AppColors.surface,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: ProgressPageConstants.sectionSpacing,
                    ),
                  ),
                  SliverPadding(
                    padding: ProgressPageConstants.pagePadding,
                    sliver: SliverToBoxAdapter(
                      child: ProgressHeaderSection(data: pageData),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: ProgressPageConstants.sectionSpacing,
                    ),
                  ),
                  SliverPadding(
                    padding: ProgressPageConstants.pagePadding,
                    sliver: SliverToBoxAdapter(
                      child: ProgressJourneySection(
                        data: pageData,
                        selectedChapterId: _selectedChapterId,
                        onChapterTap: (step) =>
                            _handleChapterTap(selectedCourse, step),
                        chapterSubcontentResponse: _chapterSubcontentResponse,
                        isLoadingChapterSubcontent: _isLoadingChapterSubcontent,
                        chapterSubcontentError: _chapterSubcontentError,
                        onRetryTap: _selectedChapterId == null
                            ? null
                            : () {
                                final step = pageData.moduleSteps
                                    .where((s) => s.id == _selectedChapterId)
                                    .cast<ProgressModuleStep?>()
                                    .firstOrNull;
                                if (step != null) {
                                  _retryChapterFetch(selectedCourse, step);
                                }
                              },
                        onSubcontentTap: (item) => _openChapterExercise(
                          selectedCourse,
                          item,
                          pageData.moduleSteps,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ProgressCourseSelection? _resolveSelectedCourse(
    List<ProgressCourseSelection> courses,
  ) {
    final initial = widget.initialCourseSelection;
    if (initial != null) {
      for (final course in courses) {
        if (_matchesCourse(course, initial)) {
          return course;
        }
      }
      return initial;
    }

    return switch (courses) {
      [final first, ...] => first,
      _ => null,
    };
  }

  void _syncSelectedCourse(ProgressCourseSelection course) {
    final courseKey = _courseKey(course);
    if (_selectedCourseKey == courseKey) {
      return;
    }

    _selectedCourseKey = courseKey;
    _resetChapterSubcontentState(clearCache: false);
  }

  Future<void> _handleChapterTap(
    ProgressCourseSelection course,
    ProgressModuleStep step,
  ) async {
    if (step.isLocked) {
      return;
    }

    // Tap the active chapter again → collapse the subcontent panel.
    if (_selectedChapterId == step.id) {
      setState(() => _resetChapterSubcontentState(clearCache: false));
      return;
    }

    final cacheEntryKey = _chapterCacheKey(course, step);
    final cachedResponse = _chapterSubcontentCache[cacheEntryKey];

    setState(() {
      _selectedChapterId = step.id;
      _chapterSubcontentError = null;
      _chapterSubcontentResponse = cachedResponse;
      _isLoadingChapterSubcontent = cachedResponse == null;
    });

    if (cachedResponse != null) {
      return;
    }

    await _fetchSubcontent(course, step);
  }

  Future<void> _retryChapterFetch(
    ProgressCourseSelection course,
    ProgressModuleStep step,
  ) async {
    final cacheKey = _chapterCacheKey(course, step);
    _chapterSubcontentCache.remove(cacheKey);

    setState(() {
      _chapterSubcontentError = null;
      _chapterSubcontentResponse = null;
      _isLoadingChapterSubcontent = true;
    });

    await _fetchSubcontent(course, step);
  }

  Future<void> _fetchSubcontent(
    ProgressCourseSelection course,
    ProgressModuleStep step,
  ) async {
    final cacheEntryKey = _chapterCacheKey(course, step);
    final requestToken = ++_chapterSubcontentRequestToken;

    try {
      final roadmapResponse = await _resolveOrGenerateRoadmap(course);
      final roadmapJson = roadmapResponse.roadmap.toJson();

      final response = await fetchChapterSubcontent(
        ChapterSubcontentGenerateRequestModel(
          roadmapId: roadmapResponse.roadmap.id,
          roadmapCacheKey: _roadmapCacheKey(course),
          chapterNumber: step.chapterNumber,
          model: roadmapResponse.model,
          roadmapJson: roadmapJson,
        ),
      );

      if (!mounted || requestToken != _chapterSubcontentRequestToken) {
        return;
      }

      _chapterSubcontentCache[cacheEntryKey] = response;
      setState(() {
        _chapterSubcontentResponse = response;
        _chapterSubcontentError = null;
        _isLoadingChapterSubcontent = false;
      });
    } catch (error) {
      if (!mounted || requestToken != _chapterSubcontentRequestToken) {
        return;
      }

      setState(() {
        _chapterSubcontentResponse = null;
        _chapterSubcontentError = error.toString();
        _isLoadingChapterSubcontent = false;
      });
    }
  }

  Future<RoadmapResponseModel> _resolveOrGenerateRoadmap(
    ProgressCourseSelection course,
  ) async {
    final existingResponse = _extractRoadmapResponse(course.roadmapJson);
    if (existingResponse != null) {
      return existingResponse;
    }

    final generatedResponse = await fetchProgress(
      RoadmapGenerateRequestModel(
        roadmapMode: course.courseType == ProgressCourseType.voice
            ? 'voice'
            : 'school',
        topic: course.topic,
        language: course.roadmapLanguage,
        level: course.level,
        nativeLanguage: course.nativeLanguage,
      ),
    );

    final updatedCourse = course.copyWith(
      roadmapJson: generatedResponse.toJson(),
      roadmapGenerated: true,
    );
    await ExploreCoursesService.instance.updateCourse(updatedCourse);

    return generatedResponse;
  }

  Future<void> _openChapterExercise(
    ProgressCourseSelection course,
    ChapterSubcontentItemModel item,
    List<ProgressModuleStep> steps,
  ) async {
    final response = _chapterSubcontentResponse;
    final chapterSubcontentId = response?.chapterSubcontent.id;
    if (chapterSubcontentId == null || chapterSubcontentId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generate the chapter build before opening exercises.'),
        ),
      );
      return;
    }
    final activeResponse = response!;

    final selectedStep = steps
        .where((step) => step.id == _selectedChapterId)
        .firstOrNull;
    final accentColor = selectedStep?.toneColor ?? AppColors.primary;
    final chapterNumber =
        selectedStep?.chapterNumber ??
        activeResponse.chapterSubcontent.chapterNumber;

    final completion = await context.push<ChapterExerciseCompletionResult>(
      Routes.chapterExercise,
      extra: ChapterExercisePageArgs(
        chapterSubcontentId: chapterSubcontentId,
        chapterNumber: chapterNumber,
        subcontentNumber: item.subcontentNumber,
        chapterTitle: activeResponse.chapterSubcontent.chapterTitle,
        subcontentTitle: item.title,
        accentColorValue: accentColor.toARGB32(),
        model: activeResponse.model,
      ),
    );

    if (!mounted || completion == null) {
      return;
    }

    _xpBlocFor(course).add(XpEarned(XpBloc.xpPerExercise));
    _markChapterComplete(course, completion.chapterNumber);
  }

  int _unlockedChapterLimit(ProgressCourseSelection course) {
    final key = _courseKey(course);
    return _unlockedChapterLimitByCourse.putIfAbsent(
      key,
      () => CourseXpService.instance.dataFor(key).chaptersUnlocked,
    );
  }

  void _markChapterComplete(ProgressCourseSelection course, int chapterNumber) {
    final courseKey = _courseKey(course);
    final currentLimit = _unlockedChapterLimitByCourse[courseKey] ?? 1;
    final nextLimit = chapterNumber + 1;
    if (nextLimit <= currentLimit) return;

    setState(() {
      _unlockedChapterLimitByCourse[courseKey] = nextLimit;
    });
    CourseXpService.instance.updateUnlockedLimit(courseKey, nextLimit);
  }

  bool _matchesCourse(
    ProgressCourseSelection left,
    ProgressCourseSelection right,
  ) {
    return left.title == right.title &&
        left.topic == right.topic &&
        left.level == right.level &&
        left.nativeLanguage == right.nativeLanguage;
  }

  String _courseKey(ProgressCourseSelection course) =>
      progressCourseXpKey(course);

  String _roadmapCacheKey(ProgressCourseSelection course) =>
      RoadmapIdCache.buildRoadmapCacheKey(
        roadmapMode: course.courseType == ProgressCourseType.voice
            ? 'voice'
            : 'school',
        topic: course.topic,
        language: course.roadmapLanguage,
        level: course.level,
        nativeLanguage: course.nativeLanguage,
      );

  // Key includes the backend chapter_number so each chapter gets its own cache slot.
  String _chapterCacheKey(
    ProgressCourseSelection course,
    ProgressModuleStep step,
  ) {
    return '${_courseKey(course)}::ch${step.chapterNumber}::${step.id}';
  }

  void _resetChapterSubcontentState({required bool clearCache}) {
    _selectedChapterId = null;
    _chapterSubcontentError = null;
    _chapterSubcontentResponse = null;
    _isLoadingChapterSubcontent = false;
    _chapterSubcontentRequestToken++;
    if (clearCache) {
      _chapterSubcontentCache.clear();
    }
  }
}

RoadmapResponseModel? _extractRoadmapResponse(Map<String, dynamic>? raw) {
  if (raw == null || raw.isEmpty || raw['roadmap'] is! Map) {
    return null;
  }

  try {
    return RoadmapResponseModel.fromJson(raw);
  } catch (_) {
    return null;
  }
}
