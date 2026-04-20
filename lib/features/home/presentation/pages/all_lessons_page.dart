import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/presentation/widgets/lesson_card.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';
import 'package:modern_learner_production/features/lesson_detail/presentation/pages/voice_lesson_page.dart';

enum LessonFilter { voice, school }

class AllLessonsPage extends StatefulWidget {
  const AllLessonsPage({super.key, required this.filter});

  final LessonFilter filter;

  @override
  State<AllLessonsPage> createState() => _AllLessonsPageState();
}

class _AllLessonsPageState extends State<AllLessonsPage> {
  List<_Lesson> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await SupabaseService.client
          .from('lessons')
          .select('id, lesson_type, content_type, difficulty, title, status, content')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final isVoice = widget.filter == LessonFilter.voice;
      final all = (response as List)
          .map((e) => _Lesson.fromMap(e as Map<String, dynamic>))
          .where((l) => isVoice ? l.lessonType == 'language' : l.lessonType != 'language')
          .toList();

      if (mounted) {
        setState(() {
          _lessons = all;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openLesson(_Lesson lesson) {
    if (lesson.lessonType == 'language') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VoiceLessonPage(lessonId: lesson.id)),
      );
    } else {
      context.go(Routes.progress, extra: lesson.toCourseSelection());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.filter == LessonFilter.voice
                          ? 'Voice Lessons'
                          : 'School Lessons',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_lessons.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No lessons yet. Start creating!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              // ── Filtered Lessons ───────────────────────────────────────────
              if (_lessons.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _sectionLabel(
                      widget.filter == LessonFilter.voice
                          ? 'VOICE LESSONS'
                          : 'SCHOOL LESSONS',
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.separated(
                    itemCount: _lessons.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final l = _lessons[i];
                      return LessonCard(
                        emoji: l.emoji,
                        title: l.title,
                        chapter: l.subtitle,
                        duration: l.duration,
                        progress: l.progress,
                        accentColor: widget.filter == LessonFilter.voice
                            ? AppColors.primary
                            : AppColors.secondary,
                        isNew: l.status == 'draft',
                        lessonType: widget.filter == LessonFilter.voice
                            ? 'language'
                            : 'school',
                        onTap: () => _openLesson(l),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.8,
        ),
      );
}

// ── Lesson model ──────────────────────────────────────────────────────────────

class _Lesson {
  const _Lesson({
    required this.id,
    required this.lessonType,
    required this.contentType,
    required this.difficulty,
    required this.title,
    required this.status,
    this.content,
  });

  factory _Lesson.fromMap(Map<String, dynamic> map) => _Lesson(
        id: map['id'] as String,
        lessonType: map['lesson_type'] as String? ?? 'school',
        contentType: map['content_type'] as String? ?? '',
        difficulty: map['difficulty'] as String? ?? 'Beginner',
        title: map['title'] as String? ?? '',
        status: map['status'] as String? ?? 'draft',
        content: map['content'] == null
            ? null
            : Map<String, dynamic>.from(map['content'] as Map),
      );

  final String id;
  final String lessonType;
  final String contentType;
  final String difficulty;
  final String title;
  final String status;
  final Map<String, dynamic>? content;

  String get topic {
    final value = content?['topic'] as String?;
    if (value != null && value.trim().isNotEmpty) return value.trim();
    return contentType;
  }

  String get subtitle => topic.isNotEmpty ? topic : contentType;

  String get emoji {
    if (lessonType == 'language') return '🎤';
    switch (contentType.toLowerCase()) {
      case 'science':
        return '🔬';
      case 'math':
      case 'mathematics':
        return '📐';
      case 'history':
        return '📜';
      case 'biology':
        return '🌱';
      case 'chemistry':
        return '⚗️';
      case 'physics':
        return '⚡';
      case 'english':
        return '✍️';
      case 'geography':
        return '🌍';
      case 'music':
        return '🎵';
      default:
        return '📚';
    }
  }

  String get duration {
    switch (difficulty) {
      case 'Advanced':
        return '30 min';
      case 'Intermediate':
        return '20 min';
      default:
        return '15 min';
    }
  }

  double get progress => status == 'completed' ? 1.0 : 0.0;

  ProgressCourseSelection toCourseSelection() {
    final roadmapJson = content?['roadmap'] is Map
        ? Map<String, dynamic>.from(content!['roadmap'] as Map)
        : null;
    return ProgressCourseSelection(
      title: title,
      topic: topic,
      roadmapLanguage:
          (content?['roadmapLanguage'] as String?)?.trim().isNotEmpty == true
              ? (content!['roadmapLanguage'] as String).trim()
              : contentType,
      level: ((content?['level'] as String?) ?? difficulty.toLowerCase())
          .toLowerCase(),
      nativeLanguage:
          (content?['nativeLanguage'] as String?)?.trim().isNotEmpty == true
              ? (content!['nativeLanguage'] as String).trim()
              : 'English',
      roadmapJson: roadmapJson,
    );
  }
}
