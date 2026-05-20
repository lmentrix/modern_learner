import 'package:flutter/material.dart';

import 'package:modern_learner_production/features/auth/service/auth_service.dart';
import 'package:modern_learner_production/features/new_lesson/model/lesson_actions_model.dart';
import 'package:modern_learner_production/features/new_lesson/service/lesson_actions.dart';
import 'package:modern_learner_production/features/new_lesson/view/section/new_lesson_composer_section.dart';

class NewLessonPage extends StatefulWidget {
  const NewLessonPage({super.key});

  @override
  State<NewLessonPage> createState() => _NewLessonPageState();
}

class _NewLessonPageState extends State<NewLessonPage> {
  List<AddLesson> _lessons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final lessons = await getLessonsService(userId: userId);
      if (mounted) setState(() => _lessons = lessons);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NewLessonComposerSection(
      lessons: _lessons,
      lessonsLoading: _loading,
      onLessonsRefresh: _fetchLessons,
    );
  }
}
