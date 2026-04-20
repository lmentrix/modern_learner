import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';

/// Args passed via [GoRouterState.extra].
class CreateCourseArgs {
  const CreateCourseArgs({required this.subject, this.topic});

  final LearningSubject subject;

  /// If null, the course covers the whole subject (first topic as entry point).
  final LearningTopic? topic;
}

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({
    super.key,
    required this.subject,
    this.topic,
  });

  final LearningSubject subject;
  final LearningTopic? topic;

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  static const _levels = ['beginner', 'intermediate', 'advanced'];
  static const _languages = ['English', 'Spanish', 'French', 'German', 'Arabic'];

  late String _selectedLevel;
  late String _selectedLanguage;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    final source = widget.topic ?? _fakeTopicFromSubject();
    _selectedLevel = source.difficulty.label.toLowerCase();
    _selectedLanguage = 'English';
  }

  LearningTopic _fakeTopicFromSubject() => widget.subject.topics.isNotEmpty
      ? widget.subject.topics.first
      : LearningTopic(
          id: widget.subject.id,
          name: widget.subject.name,
          description: widget.subject.description,
          emoji: widget.subject.emoji,
          difficulty: widget.subject.difficulty,
          estimatedMinutes: 30,
        );

  Color get _accent => widget.subject.accentColor;
  String get _topicName =>
      widget.topic?.name ??
      (widget.subject.topics.isNotEmpty
          ? widget.subject.topics.first.name
          : widget.subject.name);

  Future<void> _createCourse() async {
    setState(() => _creating = true);

    // Brief pause for feedback
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final course = ProgressCourseSelection(
      title: widget.subject.name,
      topic: _topicName,
      roadmapLanguage: _topicName,
      level: _selectedLevel,
      nativeLanguage: _selectedLanguage,
    );

    ExploreCoursesService.instance.addCourse(course);

    if (!mounted) return;
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final isTopic = widget.topic != null;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w < 360 ? 16.0 : w >= 600 ? 28.0 : 20.0;

    return Material(
      color: AppColors.surface,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              subject: widget.subject,
              topic: widget.topic,
              accent: _accent,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 40),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Course preview card ──────────────────────────────────
                  _CoursePreviewCard(
                    subject: widget.subject,
                    topic: widget.topic,
                    accent: _accent,
                    isTopic: isTopic,
                  ),

                  const SizedBox(height: 32),

                  // ── Difficulty ───────────────────────────────────────────
                  _SectionLabel(label: 'DIFFICULTY LEVEL'),
                  const SizedBox(height: 12),
                  _LevelSelector(
                    levels: _levels,
                    selected: _selectedLevel,
                    accent: _accent,
                    onChanged: (v) => setState(() => _selectedLevel = v),
                  ),

                  const SizedBox(height: 28),

                  // ── Native language ──────────────────────────────────────
                  _SectionLabel(label: 'YOUR NATIVE LANGUAGE'),
                  const SizedBox(height: 12),
                  _LanguageDropdown(
                    languages: _languages,
                    selected: _selectedLanguage,
                    accent: _accent,
                    onChanged: (v) => setState(() => _selectedLanguage = v),
                  ),

                  const SizedBox(height: 40),

                  // ── Create button ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _creating ? null : _createCourse,
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        disabledBackgroundColor: _accent.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _creating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_outline_rounded),
                                const SizedBox(width: 10),
                                Text(
                                  'Create Course',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Center(
                    child: Text(
                      'Course will appear on your Home page',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.subject,
    required this.topic,
    required this.accent,
  });

  final LearningSubject subject;
  final LearningTopic? topic;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final displayEmoji = topic?.emoji ?? subject.emoji;
    final displayName = topic?.name ?? subject.name;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w < 360 ? 16.0 : w >= 600 ? 28.0 : 20.0;
    final emojiSize = w < 360 ? 34.0 : w >= 600 ? 50.0 : 42.0;
    final titleSize = w < 360 ? 20.0 : w >= 600 ? 32.0 : 26.0;

    return Stack(
      children: [
        // Decorative circle (clipped by the Stack's own bounds)
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.10),
            ),
          ),
        ),
        // Content drives the height
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accent.withValues(alpha: 0.32), AppColors.surface],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Label pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: accent.withValues(alpha: 0.40)),
                    ),
                    child: Text(
                      'CREATE COURSE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        displayEmoji,
                        style: TextStyle(fontSize: emojiSize),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          displayName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (topic != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'in ${subject.name}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Course preview card ───────────────────────────────────────────────────────

class _CoursePreviewCard extends StatelessWidget {
  const _CoursePreviewCard({
    required this.subject,
    required this.topic,
    required this.accent,
    required this.isTopic,
  });

  final LearningSubject subject;
  final LearningTopic? topic;
  final Color accent;
  final bool isTopic;

  @override
  Widget build(BuildContext context) {
    final mins = topic?.estimatedMinutes ?? 30;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COURSE SUMMARY',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: accent,
            ),
          ),
          const SizedBox(height: 14),
          _PreviewRow(
            icon: Icons.auto_stories_rounded,
            label: 'Subject',
            value: subject.name,
            accent: accent,
          ),
          const SizedBox(height: 10),
          _PreviewRow(
            icon: Icons.topic_rounded,
            label: isTopic ? 'Topic' : 'Starting topic',
            value: topic?.name ??
                (subject.topics.isNotEmpty
                    ? subject.topics.first.name
                    : subject.name),
            accent: accent,
          ),
          const SizedBox(height: 10),
          _PreviewRow(
            icon: Icons.schedule_rounded,
            label: 'Estimated time',
            value: '$mins min per session',
            accent: accent,
          ),
          const SizedBox(height: 10),
          _PreviewRow(
            icon: Icons.psychology_rounded,
            label: 'Roadmap',
            value: 'AI-generated · adaptive',
            accent: accent,
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: accent),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

// ── Level selector ────────────────────────────────────────────────────────────

class _LevelSelector extends StatelessWidget {
  const _LevelSelector({
    required this.levels,
    required this.selected,
    required this.accent,
    required this.onChanged,
  });

  final List<String> levels;
  final String selected;
  final Color accent;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: levels.map((level) {
        final isSelected = level == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: level != levels.last ? 10 : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accent
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? accent
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _emoji(level),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _capitalize(level),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _emoji(String level) {
    switch (level) {
      case 'beginner':
        return '🌱';
      case 'intermediate':
        return '🔥';
      case 'advanced':
        return '🚀';
      default:
        return '📚';
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Language dropdown ─────────────────────────────────────────────────────────

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    required this.languages,
    required this.selected,
    required this.accent,
    required this.onChanged,
  });

  final List<String> languages;
  final String selected;
  final Color accent;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          dropdownColor: AppColors.surfaceContainerHigh,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          icon: Icon(
            Icons.expand_more_rounded,
            color: accent,
          ),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: languages
              .map(
                (lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
