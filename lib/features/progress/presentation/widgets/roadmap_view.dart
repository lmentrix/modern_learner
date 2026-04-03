import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';

class RoadmapView extends StatelessWidget {

  const RoadmapView({
    super.key,
    required this.roadmap,
    required this.userProgress,
    this.selectedLessonId,
    this.expandedChapters = const {},
    required this.onLessonTap,
    required this.onChapterTap,
    required this.onChapterToggle,
  });
  final Roadmap roadmap;
  final UserProgress userProgress;
  final String? selectedLessonId;
  final Set<String> expandedChapters;
  final Function(String lessonId) onLessonTap;
  final Function(String chapterId) onChapterTap;
  final Function(String chapterId, bool isExpanded) onChapterToggle;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: roadmap.chapters.length,
      itemBuilder: (context, index) {
        final chapter = roadmap.chapters[index];
        final isExpanded = expandedChapters.contains(chapter.id);

        return _ChapterSection(
          chapter: chapter,
          userProgress: userProgress,
          isExpanded: isExpanded,
          onHeaderTap: () => onChapterTap(chapter.id),
          onExpandToggle: (expanded) => onChapterToggle(chapter.id, expanded),
          onLessonTap: onLessonTap,
        );
      },
    );
  }
}

class _ChapterSection extends StatelessWidget {

  const _ChapterSection({
    required this.chapter,
    required this.userProgress,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.onExpandToggle,
    required this.onLessonTap,
  });
  final Chapter chapter;
  final UserProgress userProgress;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final Function(bool) onExpandToggle;
  final Function(String lessonId) onLessonTap;

  bool _isChapterCompleted() {
    return userProgress.completedChapters.containsKey(chapter.id);
  }

  int _completedLessonsCount() {
    return chapter.lessons
        .where((l) => userProgress.completedLessons.containsKey(l.id))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _isChapterCompleted();
    final completedCount = _completedLessonsCount();
    final totalCount = chapter.lessons.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChapterHeader(
          chapter: chapter,
          isExpanded: isExpanded,
          progress: progress,
          isCompleted: isCompleted,
          completedCount: completedCount,
          totalCount: totalCount,
          onTap: onHeaderTap,
          onExpandToggle: onExpandToggle,
        ),
        if (isExpanded)
          _ChapterLessons(
            lessons: chapter.lessons,
            userProgress: userProgress,
            onLessonTap: onLessonTap,
          ),
      ],
    );
  }
}

class _ChapterHeader extends StatelessWidget {

  const _ChapterHeader({
    required this.chapter,
    required this.isExpanded,
    required this.progress,
    required this.isCompleted,
    required this.completedCount,
    required this.totalCount,
    required this.onTap,
    required this.onExpandToggle,
  });
  final Chapter chapter;
  final bool isExpanded;
  final double progress;
  final bool isCompleted;
  final int completedCount;
  final int totalCount;
  final VoidCallback onTap;
  final Function(bool) onExpandToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCheckpointOrBoss
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icon + Title
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: _getChapterGradient(),
                            ),
                            child: Center(
                              child: Text(
                                chapter.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Chapter ${chapter.chapterNumber}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (_isCheckpointOrBoss) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.error
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _chapterTypeLabel,
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  chapter.title,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Expand/Collapse button
                    GestureDetector(
                      onTap: () => onExpandToggle(!isExpanded),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor:
                        AppColors.outlineVariant.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? AppColors.tertiary
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completedCount/$totalCount lessons',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${chapter.xpReward} XP',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.diamond_rounded,
                          size: 16,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${chapter.gemReward} gems',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _isCheckpointOrBoss =>
      chapter.type == ChapterType.checkpoint ||
      chapter.type == ChapterType.bossChallenge;

  String get _chapterTypeLabel => switch (chapter.type) {
        ChapterType.checkpoint => 'CHECKPOINT',
        ChapterType.bossChallenge => 'BOSS',
        ChapterType.lesson => 'LESSON',
      };

  LinearGradient _getChapterGradient() {
    if (_isCheckpointOrBoss) {
      return const LinearGradient(
        colors: [Color(0xFFBA1A1A), Color(0xFFF2B8B5)],
      );
    }
    return AppColors.primaryGradient;
  }
}

class _ChapterLessons extends StatelessWidget {

  const _ChapterLessons({
    required this.lessons,
    required this.userProgress,
    required this.onLessonTap,
  });
  final List<Lesson> lessons;
  final UserProgress userProgress;
  final Function(String lessonId) onLessonTap;

  LessonStatus _getLessonStatus(Lesson lesson) {
    if (userProgress.completedLessons.containsKey(lesson.id)) {
      return LessonStatus.completed;
    }
    if (userProgress.lessonProgress.containsKey(lesson.id)) {
      return LessonStatus.inProgress;
    }
    return lesson.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        children: lessons
            .asMap()
            .entries
            .map((entry) => _LessonItem(
                  lesson: entry.value,
                  status: _getLessonStatus(entry.value),
                  isLast: entry.key == lessons.length - 1,
                  onTap: () => onLessonTap(entry.value.id),
                ))
            .toList(),
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {

  const _LessonItem({
    required this.lesson,
    required this.status,
    required this.isLast,
    required this.onTap,
  });
  final Lesson lesson;
  final LessonStatus status;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Connecting line
          Column(
            children: [
              Container(
                width: 2,
                height: 20,
                color: AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 28,
                  color: AppColors.outlineVariant.withValues(alpha: 0.2),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Lesson node
          GestureDetector(
            onTap: onTap,
            child: _LessonNode(lesson: lesson, status: status),
          ),
          const SizedBox(width: 12),
          // Lesson info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _LessonTypeBadge(type: lesson.type),
                    const SizedBox(width: 8),
                    Text(
                      '+${lesson.xpReward} XP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {

  const _LessonNode({
    required this.lesson,
    required this.status,
  });
  final Lesson lesson;
  final LessonStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getNodeColor(),
        border: Border.all(
          color: _getBorderColor(),
          width: 2,
        ),
        boxShadow: _getShadow(),
      ),
      child: Center(
        child: _buildIcon(),
      ),
    );
  }

  Color _getNodeColor() {
    switch (status) {
      case LessonStatus.locked:
        return AppColors.surfaceContainer;
      case LessonStatus.available:
        return AppColors.primary;
      case LessonStatus.inProgress:
        return AppColors.surfaceContainerHighest;
      case LessonStatus.completed:
        return AppColors.tertiaryContainer.withValues(alpha: 0.3);
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case LessonStatus.locked:
        return AppColors.outlineVariant.withValues(alpha: 0.3);
      case LessonStatus.available:
        return AppColors.primary;
      case LessonStatus.inProgress:
        return AppColors.tertiary.withValues(alpha: 0.5);
      case LessonStatus.completed:
        return AppColors.tertiary;
    }
  }

  List<BoxShadow>? _getShadow() {
    if (status == LessonStatus.available) {
      return [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];
    }
    if (status == LessonStatus.completed) {
      return [
        BoxShadow(
          color: AppColors.tertiary.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return null;
  }

  Widget _buildIcon() {
    switch (status) {
      case LessonStatus.locked:
        return Icon(
          Icons.lock_rounded,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
          size: 18,
        );
      case LessonStatus.available:
        return const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 22,
        );
      case LessonStatus.inProgress:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.tertiary),
          ),
        );
      case LessonStatus.completed:
        return const Icon(
          Icons.check_rounded,
          color: AppColors.tertiary,
          size: 22,
        );
    }
  }
}

class _LessonTypeBadge extends StatelessWidget {

  const _LessonTypeBadge({required this.type});
  final LessonType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      LessonType.vocabulary => ('VOCAB', AppColors.primary),
      LessonType.grammar => ('GRAMMAR', AppColors.primary),
      LessonType.exercise => ('EXERCISE', AppColors.tertiary),
      LessonType.listening => ('LISTEN', AppColors.secondary),
      LessonType.reading => ('READ', AppColors.secondary),
      LessonType.conversation => ('TALK', AppColors.tertiary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
