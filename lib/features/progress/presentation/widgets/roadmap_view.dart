import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/domain/entities/achievement_entity.dart';
import 'package:modern_learner_production/features/home/presentation/bloc/achievement_bloc.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';

class RoadmapView extends StatelessWidget {
  const RoadmapView({
    super.key,
    required this.roadmap,
    required this.userProgress,
    this.selectedLessonId,
    this.expandedChapters = const {},
    this.scrollController,
    required this.onLessonTap,
    required this.onChapterTap,
    required this.onChapterToggle,
    required this.onExpandAll,
    required this.onCollapseAll,
    required this.onRegenerate,
    required this.onRefresh,
  });

  final Roadmap roadmap;
  final UserProgress userProgress;
  final String? selectedLessonId;
  final Set<String> expandedChapters;
  final ScrollController? scrollController;
  final Function(String lessonId) onLessonTap;
  final Function(String chapterId) onChapterTap;
  final Function(String chapterId, bool isExpanded) onChapterToggle;
  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;
  final VoidCallback onRegenerate;
  final Future<void> Function() onRefresh;

  int get _completedChapters => roadmap.chapters
      .where((c) => c.lessons.every((l) => l.status == LessonStatus.completed))
      .length;

  int get _completedLessons => roadmap.chapters
      .expand((c) => c.lessons)
      .where((l) => l.status == LessonStatus.completed)
      .length;

  int get _totalLessons =>
      roadmap.chapters.fold(0, (sum, c) => sum + c.lessons.length);

  bool get _allChaptersExpanded =>
      roadmap.chapters.isNotEmpty &&
      roadmap.chapters.every(
        (chapter) => expandedChapters.contains(chapter.id),
      );

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceContainerHigh,
      displacement: 60,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // ── Stats bar ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _StatsBar(progress: userProgress)),

          // ── Achievements section ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: _AchievementsSection(userProgress: userProgress),
          ),

          // ── Roadmap hero header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _RoadmapHeader(
              roadmap: roadmap,
              completedChapters: _completedChapters,
              completedLessons: _completedLessons,
              totalLessons: _totalLessons,
              onRegenerate: onRegenerate,
            ),
          ),

          // ── Chapter label ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'LEARNING PATH · ${roadmap.chapters.length} CHAPTERS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _allChaptersExpanded
                        ? onCollapseAll
                        : onExpandAll,
                    icon: Icon(
                      _allChaptersExpanded
                          ? Icons.unfold_less_rounded
                          : Icons.unfold_more_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      _allChaptersExpanded
                          ? 'Collapse all'
                          : 'Show all lessons',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Chapter list ───────────────────────────────────────────────────
          SliverList.builder(
            itemCount: roadmap.chapters.length,
            itemBuilder: (context, index) {
              final chapter = roadmap.chapters[index];
              final isExpanded = expandedChapters.contains(chapter.id);
              final isLast = index == roadmap.chapters.length - 1;

              return _ChapterSection(
                chapter: chapter,
                userProgress: userProgress,
                isExpanded: isExpanded,
                isLast: isLast,
                onHeaderTap: () => onChapterTap(chapter.id),
                onExpandToggle: (expanded) =>
                    onChapterToggle(chapter.id, expanded),
                onLessonTap: onLessonTap,
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Stats bar ────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.progress});
  final UserProgress progress;

  @override
  Widget build(BuildContext context) {
    final xpInLevel = progress.totalXp % 500;
    final xpFraction = (xpInLevel / 500.0).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 4,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StatChip(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFFF6B35),
                label: '${progress.streak}',
                sublabel: 'streak',
              ),
              const SizedBox(width: 10),
              _StatChip(
                icon: Icons.diamond_rounded,
                iconColor: AppColors.tertiary,
                label: '${progress.gems}',
                sublabel: 'gems',
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LVL ${progress.level}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '$xpInLevel / 500 XP',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                'Next level',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: xpFraction,
              minHeight: 5,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sublabel,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                TextSpan(
                  text: sublabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Roadmap hero header ───────────────────────────────────────────────────────

class _RoadmapHeader extends StatelessWidget {
  const _RoadmapHeader({
    required this.roadmap,
    required this.completedChapters,
    required this.completedLessons,
    required this.totalLessons,
    required this.onRegenerate,
  });

  final Roadmap roadmap;
  final int completedChapters;
  final int completedLessons;
  final int totalLessons;
  final VoidCallback onRegenerate;

  double get _overallProgress =>
      totalLessons > 0 ? completedLessons / totalLessons : 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F3A), Color(0xFF0E1020)],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: AI badge + regenerate ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        'AI GENERATED',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onRegenerate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Regenerate',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Title ──
            Text(
              roadmap.title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              roadmap.description,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // ── Language + level badges ──
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _HeaderBadge(
                  emoji: '💻',
                  label: roadmap.targetLanguage,
                  color: AppColors.secondary,
                ),
                _HeaderBadge(
                  emoji: '📊',
                  label: _capitalise(roadmap.level),
                  color: AppColors.tertiary,
                ),
                _HeaderBadge(
                  emoji: '⏱️',
                  label: '${roadmap.estimatedHours}h estimated',
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Overall progress ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedLessons/$totalLessons lessons',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '${(_overallProgress * 100).round()}% complete',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _overallProgress,
                minHeight: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── XP + gems summary ──
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${roadmap.totalXp} XP total',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.diamond_rounded,
                  size: 15,
                  color: AppColors.tertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${roadmap.chapters.fold(0, (s, c) => s + c.gemReward)} gems',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tertiary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$completedChapters/${roadmap.chapters.length} chapters',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({
    required this.emoji,
    required this.label,
    required this.color,
  });
  final String emoji;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chapter section ───────────────────────────────────────────────────────────

class _ChapterSection extends StatelessWidget {
  const _ChapterSection({
    required this.chapter,
    required this.userProgress,
    required this.isExpanded,
    required this.isLast,
    required this.onHeaderTap,
    required this.onExpandToggle,
    required this.onLessonTap,
  });

  final Chapter chapter;
  final UserProgress userProgress;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onHeaderTap;
  final Function(bool) onExpandToggle;
  final Function(String lessonId) onLessonTap;

  int get _completedCount => chapter.lessons
      .where((l) => userProgress.completedLessons.containsKey(l.id))
      .length;

  double get _progress =>
      chapter.lessons.isEmpty ? 0.0 : _completedCount / chapter.lessons.length;

  bool get _isCompleted => _completedCount == chapter.lessons.length;

  bool get _isSpecial =>
      chapter.type == ChapterType.checkpoint ||
      chapter.type == ChapterType.bossChallenge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, isLast ? 0 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Path line + chapter number bubble ──────────────────────────
          Column(
            children: [
              _ChapterBubble(
                number: chapter.chapterNumber,
                type: chapter.type,
                isCompleted: _isCompleted,
                progress: _progress,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: isExpanded
                      ? (chapter.lessons.length * 68.0 + 32)
                      : 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _isCompleted
                            ? AppColors.tertiary
                            : AppColors.outlineVariant.withValues(alpha: 0.3),
                        AppColors.outlineVariant.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // ── Chapter card ───────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _ChapterCard(
                  chapter: chapter,
                  isExpanded: isExpanded,
                  progress: _progress,
                  completedCount: _completedCount,
                  isCompleted: _isCompleted,
                  isSpecial: _isSpecial,
                  onTap: onHeaderTap,
                  onExpandToggle: onExpandToggle,
                ),
                if (isExpanded)
                  _LessonList(
                    lessons: chapter.lessons,
                    userProgress: userProgress,
                    onLessonTap: onLessonTap,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chapter bubble ─────────────────────────────────────────────────────────

class _ChapterBubble extends StatelessWidget {
  const _ChapterBubble({
    required this.number,
    required this.type,
    required this.isCompleted,
    required this.progress,
  });

  final int number;
  final ChapterType type;
  final bool isCompleted;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final isBoss = type == ChapterType.bossChallenge;
    final isCheckpoint = type == ChapterType.checkpoint;

    Color bubbleColor;
    if (isCompleted) {
      bubbleColor = AppColors.tertiary;
    } else if (isBoss) {
      bubbleColor = AppColors.error;
    } else if (isCheckpoint) {
      bubbleColor = AppColors.secondary;
    } else if (progress > 0) {
      bubbleColor = AppColors.primary;
    } else {
      bubbleColor = AppColors.surfaceContainerHigh;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bubbleColor,
        border: Border.all(
          color: isCompleted
              ? AppColors.tertiary
              : AppColors.outlineVariant.withValues(alpha: 0.3),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: progress > 0
            ? [
                BoxShadow(
                  color: bubbleColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : isBoss
            ? const Text('👑', style: TextStyle(fontSize: 16))
            : isCheckpoint
            ? const Text('🏁', style: TextStyle(fontSize: 15))
            : Text(
                '$number',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: progress > 0
                      ? Colors.white
                      : AppColors.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}

// ── Chapter card ──────────────────────────────────────────────────────────────

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.isExpanded,
    required this.progress,
    required this.completedCount,
    required this.isCompleted,
    required this.isSpecial,
    required this.onTap,
    required this.onExpandToggle,
  });

  final Chapter chapter;
  final bool isExpanded;
  final double progress;
  final int completedCount;
  final bool isCompleted;
  final bool isSpecial;
  final VoidCallback onTap;
  final Function(bool) onExpandToggle;

  Color get _accentColor {
    if (chapter.type == ChapterType.bossChallenge) return AppColors.error;
    if (chapter.type == ChapterType.checkpoint) return AppColors.secondary;
    if (isCompleted) return AppColors.tertiary;
    if (progress > 0) return AppColors.primary;
    return AppColors.outlineVariant;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSpecial
              ? _accentColor.withValues(alpha: 0.35)
              : isCompleted
              ? AppColors.tertiary.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _accentColor.withValues(alpha: 0.3),
                            _accentColor.withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          chapter.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Chapter ${chapter.chapterNumber}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _accentColor,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              if (isSpecial) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    chapter.type == ChapterType.bossChallenge
                                        ? 'BOSS'
                                        : 'CHECKPOINT',
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: _accentColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                              if (isCompleted) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: AppColors.tertiary,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            chapter.title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Expand toggle
                    GestureDetector(
                      onTap: () => onExpandToggle(!isExpanded),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppColors.outlineVariant.withValues(
                      alpha: 0.15,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                  ),
                ),

                const SizedBox(height: 7),

                // Stats row
                Row(
                  children: [
                    Text(
                      '$completedCount/${chapter.lessons.length} lessons',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+${chapter.xpReward} XP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.diamond_rounded,
                      size: 13,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+${chapter.gemReward}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
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
}

// ── Lesson list ───────────────────────────────────────────────────────────────

class _LessonList extends StatelessWidget {
  const _LessonList({
    required this.lessons,
    required this.userProgress,
    required this.onLessonTap,
  });

  final List<Lesson> lessons;
  final UserProgress userProgress;
  final Function(String lessonId) onLessonTap;

  LessonStatus _getStatus(Lesson lesson) {
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
      margin: const EdgeInsets.only(left: 4, bottom: 4),
      child: Column(
        children: lessons
            .asMap()
            .entries
            .map(
              (e) => _LessonRow(
                lesson: e.value,
                status: _getStatus(e.value),
                index: e.key,
                isLast: e.key == lessons.length - 1,
                onTap: () => onLessonTap(e.value.id),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson,
    required this.status,
    required this.index,
    required this.isLast,
    required this.onTap,
  });

  final Lesson lesson;
  final LessonStatus status;
  final int index;
  final bool isLast;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (status) {
      case LessonStatus.completed:
        return AppColors.tertiary;
      case LessonStatus.inProgress:
        return AppColors.primary;
      case LessonStatus.available:
        return AppColors.primary;
      case LessonStatus.locked:
        return AppColors.onSurfaceVariant.withValues(alpha: 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = status == LessonStatus.locked;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: status == LessonStatus.available
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.outlineVariant.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _statusColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: _statusColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Center(child: _buildStatusIcon()),
              ),

              const SizedBox(width: 10),

              // Title + badges
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
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _TypeBadge(type: lesson.type),
                        const SizedBox(width: 6),
                        Text(
                          '+${lesson.xpReward} XP',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action arrow (available only)
              if (status == LessonStatus.available)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case LessonStatus.completed:
        return const Icon(
          Icons.check_rounded,
          color: AppColors.tertiary,
          size: 16,
        );
      case LessonStatus.inProgress:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      case LessonStatus.available:
        return const Icon(
          Icons.play_arrow_rounded,
          color: AppColors.primary,
          size: 16,
        );
      case LessonStatus.locked:
        return Icon(
          Icons.lock_rounded,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          size: 14,
        );
    }
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Achievements section ──────────────────────────────────────────────────────

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.userProgress});

  final UserProgress userProgress;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        if (state.status == AchievementStatus.initial) return const SizedBox.shrink();

        final unlocked = state.achievements.where((a) => !a.isLocked).toList();
        final locked = state.achievements.where((a) => a.isLocked).toList();
        final nextMilestone = _nextMilestone(locked, userProgress);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section header ──────────────────────────────────────────────
              Row(
                children: [
                  Text(
                    'ACHIEVEMENTS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push(Routes.achievements),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${unlocked.length}/${state.achievements.length}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Badges row ──────────────────────────────────────────────────
              if (unlocked.isNotEmpty)
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: unlocked.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) =>
                        _AchievementBadge(achievement: unlocked[i]),
                  ),
                )
              else
                _EmptyBadgesHint(),

              // ── Next milestone ──────────────────────────────────────────────
              if (nextMilestone != null) ...[
                const SizedBox(height: 12),
                _NextMilestoneCard(
                  achievement: nextMilestone.achievement,
                  current: nextMilestone.current,
                  target: nextMilestone.target,
                  label: nextMilestone.label,
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  /// Returns the locked achievement the user is closest to earning.
  _MilestoneData? _nextMilestone(
    List<AchievementEntity> locked,
    UserProgress progress,
  ) {
    _MilestoneData? best;
    double bestFraction = -1;

    for (final a in locked) {
      final data = _milestoneFor(a, progress);
      if (data == null) continue;
      final fraction = (data.current / data.target).clamp(0.0, 1.0);
      if (fraction > bestFraction) {
        bestFraction = fraction;
        best = data;
      }
    }
    return best;
  }

  _MilestoneData? _milestoneFor(
    AchievementEntity a,
    UserProgress p,
  ) {
    final lessons = p.completedLessons.length;
    switch (a.id) {
      // Streaks
      case 'week_streak':
        return _MilestoneData(a, p.streak, 7, 'day streak');
      case 'fortnight_streak':
        return _MilestoneData(a, p.streak, 14, 'day streak');
      case 'month_streak':
        return _MilestoneData(a, p.streak, 30, 'day streak');
      case 'century_streak':
        return _MilestoneData(a, p.streak, 100, 'day streak');
      case 'year_streak':
        return _MilestoneData(a, p.streak, 365, 'day streak');
      // XP
      case 'first_xp':
        return _MilestoneData(a, p.totalXp, 100, 'XP');
      case 'xp_hunter':
        return _MilestoneData(a, p.totalXp, 500, 'XP');
      case 'xp_master':
        return _MilestoneData(a, p.totalXp, 2000, 'XP');
      case 'xp_legend':
        return _MilestoneData(a, p.totalXp, 10000, 'XP');
      case 'xp_champion':
        return _MilestoneData(a, p.totalXp, 50000, 'XP');
      // Lessons
      case 'first_lesson':
        return _MilestoneData(a, lessons, 1, 'lesson');
      case 'quick_learner':
        return null; // time-of-day tracking not shown
      case 'perfectionist':
        return _MilestoneData(a, lessons, 1, 'lesson');
      case 'no_mistakes':
        return _MilestoneData(a, lessons, 5, 'lessons');
      case 'bookworm':
        return _MilestoneData(a, lessons, 25, 'lessons');
      case 'scholar':
        return _MilestoneData(a, lessons, 50, 'lessons');
      case 'century_learner':
        return _MilestoneData(a, lessons, 100, 'lessons');
      case 'speed_demon':
        return _MilestoneData(a, lessons, 3, 'lessons');
      default:
        return null;
    }
  }
}

class _MilestoneData {
  const _MilestoneData(this.achievement, this.current, this.target, this.label);
  final AchievementEntity achievement;
  final int current;
  final int target;
  final String label;
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});
  final AchievementEntity achievement;

  @override
  Widget build(BuildContext context) {
    final accent = achievement.color;
    return GestureDetector(
      onTap: () => context.push(Routes.achievementDetail, extra: achievement),
      child: Container(
        width: 56,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.28),
              accent.withValues(alpha: 0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.40)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(achievement.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBadgesHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          const Text('🏅', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Text(
            'Complete lessons to unlock achievements',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Next milestone card ───────────────────────────────────────────────────────

class _NextMilestoneCard extends StatelessWidget {
  const _NextMilestoneCard({
    required this.achievement,
    required this.current,
    required this.target,
    required this.label,
  });

  final AchievementEntity achievement;
  final int current;
  final int target;
  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = achievement.color;
    final fraction = (current / target).clamp(0.0, 1.0);
    final remaining = (target - current).clamp(0, target);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(achievement.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT ACHIEVEMENT',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: accent,
                      ),
                    ),
                    Text(
                      achievement.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$current/$target $label',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: accent.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            remaining == 0
                ? 'Achievement unlocked! 🎉'
                : '$remaining more $label to unlock',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
