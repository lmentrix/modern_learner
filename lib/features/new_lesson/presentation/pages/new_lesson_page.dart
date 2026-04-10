import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/new_lesson/domain/entities/lesson.dart';
import 'package:modern_learner_production/features/new_lesson/domain/usecases/create_lesson.dart';

class NewLessonPage extends StatefulWidget {
  const NewLessonPage({super.key});

  @override
  State<NewLessonPage> createState() => _NewLessonPageState();
}

class _NewLessonPageState extends State<NewLessonPage> {
  String? _selectedLanguage;
  String? _selectedTopic;
  String _selectedDifficulty = 'Beginner';
  NewLessonType _lessonType = NewLessonType.language;
  bool _isLoading = false;

  bool get _canStart => _lessonType == NewLessonType.language
      ? _selectedLanguage != null
      : _selectedTopic != null;

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

  static const _topics = [
    ('➕', 'Mathematics'),
    ('🔬', 'Science'),
    ('🌍', 'Geography'),
    ('📜', 'History'),
    ('📖', 'Literature'),
    ('🎨', 'Art'),
    ('🎵', 'Music'),
    ('💻', 'Computer Science'),
    ('⚗️', 'Chemistry'),
    ('🧬', 'Biology'),
    ('⚡', 'Physics'),
    ('🏛️', 'Philosophy'),
  ];

  static const _difficulties = [
    ('🌱', 'Beginner'),
    ('🌿', 'Intermediate'),
    ('🌳', 'Advanced'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
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
                    _sectionLabel('LESSON TYPE'),
                    const SizedBox(height: 12),
                    _buildLessonTypeSelector(),
                    const SizedBox(height: 28),
                    if (_lessonType == NewLessonType.language) ...[
                      _sectionLabel('LANGUAGE'),
                      const SizedBox(height: 12),
                      _buildLanguageGrid(),
                      const SizedBox(height: 28),
                      _sectionLabel('DIFFICULTY'),
                      const SizedBox(height: 12),
                      _buildDifficultyRow(),
                    ] else ...[
                      _sectionLabel('SCHOOL LESSON'),
                      const SizedBox(height: 12),
                      _buildTopicGrid(),
                      const SizedBox(height: 28),
                      _sectionLabel('DIFFICULTY'),
                      const SizedBox(height: 12),
                      _buildDifficultyRow(),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildStartButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.onSurfaceVariant,
              size: 24,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'New Lesson',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.8,
      ),
    );
  }

  Widget _buildLessonTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _LessonTypeCard(
            icon: '🌍',
            label: 'Language',
            isSelected: _lessonType == NewLessonType.language,
            onTap: () => setState(() => _lessonType = NewLessonType.language),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LessonTypeCard(
            icon: '📚',
            label: 'School',
            isSelected: _lessonType == NewLessonType.school,
            onTap: () => setState(() => _lessonType = NewLessonType.school),
          ),
        ),
      ],
    );
  }

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
        return _SelectableCard(
          isSelected: isSelected,
          selectedColor: AppColors.primary,
          onTap: () => setState(() => _selectedLanguage = lang.$2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(lang.$1, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                lang.$2,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
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

  Widget _buildTopicGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _topics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, i) {
        final topic = _topics[i];
        final isSelected = _selectedTopic == topic.$2;
        return _SelectableCard(
          isSelected: isSelected,
          selectedColor: AppColors.secondary,
          onTap: () => setState(() => _selectedTopic = topic.$2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(topic.$1, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                topic.$2,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDifficultyRow() {
    return Row(
      children: _difficulties.map((d) {
        final isSelected = _selectedDifficulty == d.$2;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: d.$2 == _difficulties.last.$2 ? 0 : 10,
            ),
            child: _SelectableCard(
              isSelected: isSelected,
              selectedColor: AppColors.tertiary,
              onTap: () => setState(() => _selectedDifficulty = d.$2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 3),
                  Text(
                    d.$2,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
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

  Widget _buildStartButton(BuildContext context) {
    final displayText = _lessonType == NewLessonType.language
        ? _selectedLanguage ?? 'Choose a language'
        : _selectedTopic ?? 'Choose a topic';
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: (_canStart && !_isLoading) ? 1.0 : 0.4,
        child: GestureDetector(
          onTap: (_canStart && !_isLoading) ? () => _onStart(context) : null,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: _canStart
                  ? AppColors.primaryGradient
                  : const LinearGradient(
                      colors: [AppColors.outlineVariant, AppColors.outlineVariant]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _canStart
                            ? 'Start $_selectedDifficulty $displayText Lesson'
                            : _lessonType == NewLessonType.language
                                ? 'Choose a language'
                                : 'Choose a topic',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _canStart
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (_canStart) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _onStart(BuildContext context) async {
    final contentType = _lessonType == NewLessonType.language
        ? _selectedLanguage!
        : _selectedTopic!;

    final title = '$_selectedDifficulty $contentType Lesson';

    // Capture before async gap.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      await getIt<CreateLesson>().call(
        lessonType: _lessonType,
        contentType: contentType,
        difficulty: _selectedDifficulty,
        title: title,
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Lesson "$title" created!',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.surfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      navigator.pop(true); // return true so callers can refresh
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create lesson: $e',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ── Reusable selectable card ──────────────────────────────────────────────────

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
    required this.child,
  });
  final bool isSelected;
  final Color selectedColor;
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
              ? selectedColor.withValues(alpha: 0.1)
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.5)
                : AppColors.outlineVariant.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ── Lesson Type Card ──────────────────────────────────────────────────────────

class _LessonTypeCard extends StatelessWidget {
  const _LessonTypeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor =
        label == 'Language' ? AppColors.primary : AppColors.secondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.1)
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.5)
                : AppColors.outlineVariant.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? selectedColor : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
