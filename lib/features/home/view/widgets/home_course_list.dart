import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/course/model/course__service_model.dart';
import 'package:modern_learner_production/features/course/service/course_service.dart';
import 'package:modern_learner_production/features/explore/data/models/progress_course_model.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_course_list_skeleton.dart';
import 'package:modern_learner_production/features/home/view/widgets/lesson_card.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _courses
            .map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onLongPress: () => widget.onCourseLongPress(course),
                  child: LessonCard(
                    emoji: '🎓',
                    title: course.topic,
                    chapter: course.title,
                    duration: course.level,
                    progress: 0.0,
                    accentColor: AppColors.primary,
                    isNew: !course.roadmapGenerated,
                    lessonType: course.roadmapGenerated
                        ? (course.title == 'Languages' ? 'language' : 'school')
                        : null,
                    onTap: () => widget.onCourseTap(course),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
