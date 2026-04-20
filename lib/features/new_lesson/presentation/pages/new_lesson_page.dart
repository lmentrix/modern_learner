import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';

class NewLessonPage extends StatefulWidget {
  const NewLessonPage({super.key});

  @override
  State<NewLessonPage> createState() => _NewLessonPageState();
}

class _NewLessonPageState extends State<NewLessonPage> {
  String? _selectedLanguage;
  String _selectedDifficulty = 'Beginner';

  bool get _canStart => _selectedLanguage != null;

  static const _languages = [
    ('🇺🇸', 'English'),
    ('🇪🇸', 'Spanish'),
    ('🇫🇷', 'French'),
    ('🇩🇪', 'German'),
    ('🇯🇵', 'Japanese'),
    ('🇨🇳', 'Mandarin'),
    ('🇮🇹', 'Italian'),
    ('🇧🇷', 'Portuguese'),
  ];

  static const _difficulties = [
    ('🌱', 'Beginner'),
    ('🔥', 'Intermediate'),
    ('🚀', 'Advanced'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('LANGUAGE'),
                  const SizedBox(height: 12),
                  _buildLanguageGrid(),
                  const SizedBox(height: 28),
                  _sectionLabel('DIFFICULTY'),
                  const SizedBox(height: 12),
                  _buildDifficultyRow(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _buildStartButton(context),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.surface,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '🎤  VOICE LESSON',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'New Voice Lesson',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a language and difficulty to generate your roadmap.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.7,
      ),
    );
  }

  // ── Language grid ──────────────────────────────────────────────────────────

  Widget _buildLanguageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _languages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, i) {
        final lang = _languages[i];
        final isSelected = _selectedLanguage == lang.$2;
        return _SelectableChip(
          isSelected: isSelected,
          accent: AppColors.primary,
          onTap: () => setState(() => _selectedLanguage = lang.$2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(lang.$1, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                lang.$2,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Difficulty ─────────────────────────────────────────────────────────────

  Widget _buildDifficultyRow() {
    return Row(
      children: _difficulties.map((d) {
        final isSelected = _selectedDifficulty == d.$2;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: d.$2 == _difficulties.last.$2 ? 0 : 10,
            ),
            child: _SelectableChip(
              isSelected: isSelected,
              accent: AppColors.tertiary,
              onTap: () => setState(() => _selectedDifficulty = d.$2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.$1, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 5),
                  Text(
                    d.$2,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.tertiary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Start button ───────────────────────────────────────────────────────────

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: GestureDetector(
        onTap: _canStart ? () => _onStart(context) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: _canStart
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.75),
                    ],
                  )
                : const LinearGradient(
                    colors: [
                      AppColors.surfaceContainerHigh,
                      AppColors.surfaceContainerHigh,
                    ],
                  ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: _canStart
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _canStart
                    ? Icons.map_rounded
                    : Icons.lock_outline_rounded,
                color: _canStart ? Colors.white : AppColors.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                _canStart
                    ? 'Generate $_selectedDifficulty Roadmap'
                    : 'Choose a language first',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _canStart ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onStart(BuildContext context) {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);

    final course = ProgressCourseSelection(
      title: _selectedLanguage!,
      topic: _selectedLanguage!,
      roadmapLanguage: _selectedLanguage!,
      level: _selectedDifficulty.toLowerCase(),
      nativeLanguage: 'English',
    );

    ExploreCoursesService.instance.addCourse(course);

    navigator.pop();
    router.go(Routes.progress, extra: course);
  }
}

// ── Selectable chip card ──────────────────────────────────────────────────────

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.isSelected,
    required this.accent,
    required this.onTap,
    required this.child,
  });

  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.10)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.45)
                : AppColors.outlineVariant.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
