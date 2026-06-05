import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/utils/responsive.dart';
import 'package:modern_learner_production/features/course/model/course__service_model.dart';
import 'package:modern_learner_production/features/course/service/course_service.dart';
import 'package:modern_learner_production/features/explore/data/models/progress_course_model.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_course_list_skeleton.dart';
import 'package:modern_learner_production/features/home/view/widgets/lesson_card.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';

class HomeCourseList extends StatefulWidget {
  const HomeCourseList({
    super.key,
    required this.onCourseTap,
    required this.onCourseLongPress,
  });

  final Function(ProgressCourseSelection course) onCourseTap;
  final Function(ProgressCourseSelection course) onCourseLongPress;

  @override
  State<HomeCourseList> createState() => _HomeCourseListState();
}

class _HomeCourseListState extends State<HomeCourseList> {
  bool _loading = true;

  List<ProgressCourseSelection> get _courses =>
      ExploreCoursesService.instance.courses.value;

  @override
  void initState() {
    super.initState();
    ExploreCoursesService.instance.courses.addListener(_onCoursesChanged);
    _fetchCourses();
  }

  @override
  void dispose() {
    ExploreCoursesService.instance.courses.removeListener(_onCoursesChanged);
    super.dispose();
  }

  void _onCoursesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchCourses() async {
    try {
      final models = await CourseService.instance.fetchCourses();
      final courses = models.map(_toEntity).toList();
      if (mounted) {
        // Updating the ValueNotifier triggers _onCoursesChanged → rebuild.
        ExploreCoursesService.instance.courses.value = courses;
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static const int _totalChapters = 20;

  static double _courseProgress(
    ProgressCourseSelection course,
    CourseXpData xpData,
  ) {
    final chaptersCompleted = (xpData.chaptersUnlocked - 1).clamp(
      0,
      _totalChapters,
    );
    final partialFraction =
        xpData.subcontentProgressFor(xpData.chaptersUnlocked) / _totalChapters;
    return ((chaptersCompleted / _totalChapters) + partialFraction).clamp(
      0.0,
      1.0,
    );
  }

  Widget _buildGrid(
    BuildContext context,
    Widget Function(ProgressCourseSelection) buildCard,
  ) {
    final cols = Responsive.isDesktop(context) ? 3 : 2;
    final rows = <Widget>[];
    for (int i = 0; i < _courses.length; i += cols) {
      final rowItems = _courses.skip(i).take(cols).toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int j = 0; j < rowItems.length; j++) ...[
                if (j > 0) const SizedBox(width: 12),
                Expanded(child: buildCard(rowItems[j])),
              ],
              if (rowItems.length < cols)
                ...List.generate(
                  cols - rowItems.length,
                  (_) => const Expanded(child: SizedBox.shrink()),
                ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  static ProgressCourseSelection _toEntity(UserCourseModel m) =>
      ProgressCourseModel.fromRow({
        'id': m.id,
        'title': m.title,
        'topic': m.topic,
        'roadmap_language': m.roadmapLanguage,
        'level': m.level,
        'native_language': m.nativeLanguage,
        'roadmap_json': m.roadmapJson,
      }).toEntity();

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const HomeCourseListSkeleton();
    }

    if (_courses.isEmpty) return const SizedBox.shrink();

    final hPad = Responsive.hPad(context);
    final isWide = Responsive.isTabletOrDesktop(context);

    Widget buildCard(ProgressCourseSelection course) {
      final courseKey = progressCourseXpKey(course);
      return ValueListenableBuilder<CourseXpData>(
        valueListenable: CourseXpService.instance.notifierFor(courseKey),
        builder: (context, xpData, _) {
          final progress = _courseProgress(course, xpData);
          return GestureDetector(
            onLongPress: () => widget.onCourseLongPress(course),
            child: LessonCard(
              emoji: '🎓',
              title: course.topic,
              chapter: course.title,
              duration: course.level,
              progress: progress,
              accentColor: AppColors.primary,
              isNew: !course.roadmapGenerated,
              lessonType: course.roadmapGenerated
                  ? (course.title == 'Languages' ? 'language' : 'school')
                  : null,
              onTap: () => widget.onCourseTap(course),
            ),
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: isWide
              ? _buildGrid(context, buildCard)
              : Column(
                  children: _courses
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: buildCard(c),
                          ))
                      .toList(),
                ),
        ),
      ),
    );
  }
}
