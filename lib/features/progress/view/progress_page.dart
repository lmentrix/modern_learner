import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/state/progress_navigation_state.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_constants.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_seed.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';
import 'package:modern_learner_production/features/progress/service/cache/roadmap_id_cache.dart';
import 'package:modern_learner_production/features/progress/service/model/chapter_subcontent_model.dart';
import 'package:modern_learner_production/features/progress/service/model/roadmap_model.dart';
import 'package:modern_learner_production/features/progress/service/request/chapter_subcontent.dart';
import 'package:modern_learner_production/features/progress/service/request/progress_request.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_empty_state_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_header_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_hero_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_journey_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_roadmap_response_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_stats_section.dart';
import 'package:modern_learner_production/features/progress/view/section/progress_weekly_section.dart';

class ProgressViewPage extends StatefulWidget {
  const ProgressViewPage({super.key, this.initialCourseSelection});

  final ProgressCourseSelection? initialCourseSelection;

  @override
  State<ProgressViewPage> createState() => _ProgressViewPageState();
}

class _ProgressViewPageState extends State<ProgressViewPage> {
  bool _isGeneratingRoadmap = false;
  bool _isLoadingChapterSubcontent = false;
  String? _generationError;
  String? _chapterSubcontentError;
  String? _selectedCourseKey;
  String? _requestCourseKey;
  String? _selectedChapterId;
  ChapterSubcontentResponseModel? _chapterSubcontentResponse;
  int _chapterSubcontentRequestToken = 0;
  final Map<String, ChapterSubcontentResponseModel> _chapterSubcontentCache =
      <String, ChapterSubcontentResponseModel>{};

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
          selectedChapterId: navState.selectedChapterId,
        );
        final roadmapResponse = _extractRoadmapResponse(
          selectedCourse.roadmapJson,
        );
        final roadmap =
            roadmapResponse?.roadmap ??
            _extractRoadmap(selectedCourse.roadmapJson);

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
                  child: ProgressRoadmapResponseSection(
                    courseLabel: selectedCourse.topic,
                    roadmap: roadmap,
                    response: roadmapResponse,
                    isLoading:
                        _isGeneratingRoadmap &&
                        _requestCourseKey == _courseKey(selectedCourse),
                    errorMessage: _generationError,
                    onRefresh: () =>
                        _generateRoadmap(selectedCourse, force: true),
                  ),
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
                  child: ProgressJourneySection(
                    data: pageData,
                    selectedChapterId: _selectedChapterId,
                    chapterSubcontentResponse: _chapterSubcontentResponse,
                    isLoadingChapterSubcontent: _isLoadingChapterSubcontent,
                    chapterSubcontentError: _chapterSubcontentError,
                    onChapterTap: (step) =>
                        _handleChapterTap(selectedCourse, step),
                    onRetryTap: _selectedChapterId == null
                        ? null
                        : () {
                            final selectedStep = pageData.moduleSteps
                                .where((step) => step.id == _selectedChapterId)
                                .cast<ProgressModuleStep?>()
                                .firstOrNull;
                            if (selectedStep == null) {
                              return;
                            }
                            _handleChapterTap(selectedCourse, selectedStep);
                          },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
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
    _generationError = null;
    _resetChapterSubcontentState(clearCache: false);

    if (_extractRoadmap(course.roadmapJson) != null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateRoadmap(course);
    });
  }

  Future<void> _generateRoadmap(
    ProgressCourseSelection course, {
    bool force = false,
  }) async {
    final courseKey = _courseKey(course);
    if (_isGeneratingRoadmap && _requestCourseKey == courseKey && !force) {
      return;
    }

    setState(() {
      _isGeneratingRoadmap = true;
      _requestCourseKey = courseKey;
      _generationError = null;
    });

    try {
      final response = await fetchProgress(_buildRequest(course));
      final latestCourse = _resolveSelectedCourse(
        ExploreCoursesService.instance.courses.value,
      );
      final baseCourse =
          latestCourse != null && _matchesCourse(latestCourse, course)
          ? latestCourse
          : course;

      await ExploreCoursesService.instance.updateCourse(
        baseCourse.copyWith(
          roadmapJson: response.toJson(),
          roadmapGenerated: true,
          courseType: response.roadmapMode == 'voice'
              ? ProgressCourseType.voice
              : ProgressCourseType.school,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _resetChapterSubcontentState(clearCache: true);
        _isGeneratingRoadmap = false;
        _requestCourseKey = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isGeneratingRoadmap = false;
        _requestCourseKey = null;
        _generationError = error.toString();
      });
    }
  }

  Future<void> _handleChapterTap(
    ProgressCourseSelection course,
    ProgressModuleStep step,
  ) async {
    if (step.isLocked) {
      return;
    }

    final cacheEntryKey = _chapterCacheKey(course, step.id);
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

    final requestToken = ++_chapterSubcontentRequestToken;

    try {
      final roadmapResponse = await _ensureRoadmapForCourse(course);
      final response = await fetchChapterSubcontent(
        ChapterSubcontentGenerateRequestModel(
          roadmapId: roadmapResponse.roadmap.id,
          roadmapCacheKey: _roadmapCacheKey(course),
          chapterNumber: step.chapterNumber,
          model: roadmapResponse.model,
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

  RoadmapGenerateRequestModel _buildRequest(ProgressCourseSelection course) {
    return RoadmapGenerateRequestModel(
      roadmapMode: course.courseType == ProgressCourseType.voice
          ? 'voice'
          : 'school',
      topic: course.topic,
      language: course.roadmapLanguage,
      level: course.level,
      nativeLanguage: course.nativeLanguage,
      temperature: 0.2,
      maxTokens: course.courseType == ProgressCourseType.voice ? 8000 : 16000,
      topP: 1,
    );
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

  String _courseKey(ProgressCourseSelection course) {
    return [
      course.title,
      course.topic,
      course.level,
      course.nativeLanguage,
      course.courseType.name,
    ].join('::');
  }

  String _roadmapCacheKey(ProgressCourseSelection course) {
    return RoadmapIdCache.buildRoadmapCacheKey(
      roadmapMode: course.courseType == ProgressCourseType.voice
          ? 'voice'
          : 'school',
      topic: course.topic,
      language: course.roadmapLanguage,
      level: course.level,
      nativeLanguage: course.nativeLanguage,
    );
  }

  String _chapterCacheKey(ProgressCourseSelection course, String chapterId) {
    return '${_courseKey(course)}::$chapterId';
  }

  Future<RoadmapResponseModel> _ensureRoadmapForCourse(
    ProgressCourseSelection course,
  ) async {
    final existing = _extractRoadmapResponse(course.roadmapJson);
    if (existing != null) {
      return existing;
    }

    if (_isGeneratingRoadmap && _requestCourseKey == _courseKey(course)) {
      throw StateError(
        'The roadmap is still generating. Wait a moment and try that chapter again.',
      );
    }

    await _generateRoadmap(course, force: true);
    final refreshedCourse = _findMatchingCourse(
      ExploreCoursesService.instance.courses.value,
      course,
    );
    final generated = _extractRoadmapResponse(refreshedCourse?.roadmapJson);
    if (generated != null) {
      return generated;
    }

    throw StateError(
      (_generationError ?? '').trim().isNotEmpty
          ? _generationError!
          : 'Could not generate the roadmap needed for this chapter.',
    );
  }

  ProgressCourseSelection? _findMatchingCourse(
    List<ProgressCourseSelection> courses,
    ProgressCourseSelection target,
  ) {
    for (final course in courses) {
      if (_matchesCourse(course, target)) {
        return course;
      }
    }
    return null;
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

RoadmapModel? _extractRoadmap(Map<String, dynamic>? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final response = _extractRoadmapResponse(raw);
  if (response != null) {
    return response.roadmap;
  }

  try {
    return RoadmapModel.fromJson(_extractBaseRoadmapPayload(raw));
  } catch (_) {
    return null;
  }
}

Map<String, dynamic> _extractBaseRoadmapPayload(Map<String, dynamic> raw) {
  final roadmap = _unwrapNestedMap(raw, 'roadmap');
  if (roadmap != null) {
    final nestedData = _unwrapNestedMap(roadmap, 'data');
    return nestedData ?? roadmap;
  }

  final data = _unwrapNestedMap(raw, 'data');
  return data ?? raw;
}

Map<String, dynamic>? _unwrapNestedMap(Map<String, dynamic> raw, String key) {
  final nested = raw[key];
  if (nested is Map<String, dynamic>) {
    return nested;
  }
  if (nested is Map) {
    return Map<String, dynamic>.from(nested);
  }

  return null;
}
