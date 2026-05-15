import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/features/progress/data/progress_course_snapshot.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';
import 'package:modern_learner_production/features/progress/data/progress_stat_item.dart';
import 'package:modern_learner_production/features/progress/data/progress_week_day.dart';

class ProgressPageData {
  const ProgressPageData({
    required this.course,
    required this.snapshot,
    required this.statItems,
    required this.weekDays,
    required this.moduleSteps,
  });

  final ProgressCourseSelection course;
  final ProgressCourseSnapshot snapshot;
  final List<ProgressStatItem> statItems;
  final List<ProgressWeekDay> weekDays;
  final List<ProgressModuleStep> moduleSteps;
}
