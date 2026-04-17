import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dio/dio.dart';
import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/service/lesson_refresh_notifier.dart';
import 'package:modern_learner_production/features/lesson_detail/presentation/pages/voice_lesson_page.dart';
import 'package:modern_learner_production/features/new_lesson/domain/entities/lesson.dart';
import 'package:modern_learner_production/features/new_lesson/domain/usecases/create_lesson.dart';

class NewLessonPage extends StatefulWidget {
  const NewLessonPage({super.key});

  @override
  State<NewLessonPage> createState() => _NewLessonPageState();
}

class _NewLessonPageState extends State<NewLessonPage> {
  String? _selectedLanguage;
  String? _selectedSubject;
  final TextEditingController _topicController = TextEditingController();
  String _selectedDifficulty = 'Beginner';
  NewLessonType _lessonType = NewLessonType.language;
  bool _isLoading = false;

  bool get _canStart => _lessonType == NewLessonType.language
      ? _selectedLanguage != null && _topicController.text.trim().isNotEmpty
      : _selectedSubject != null && _topicController.text.trim().isNotEmpty;

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

  static const _subjects = [
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
    ('🔥', 'Intermediate'),
    ('🚀', 'Advanced'),
  ];

  @override
  void initState() {
    super.initState();
    _topicController.addListener(_handleTopicChanged);
  }

  @override
  void dispose() {
    _topicController
      ..removeListener(_handleTopicChanged)
      ..dispose();
    super.dispose();
  }

  void _handleTopicChanged() {
    if (mounted) setState(() {});
  }

  Color get _typeAccent => _lessonType == NewLessonType.language
      ? AppColors.primary
      : AppColors.secondary;

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
                  _sectionLabel('LESSON TYPE'),
                  const SizedBox(height: 12),
                  _buildLessonTypeSelector(),
                  const SizedBox(height: 28),
                  if (_lessonType == NewLessonType.language) ...[
                    _sectionLabel('LANGUAGE'),
                    const SizedBox(height: 12),
                    _buildLanguageGrid(),
                    const SizedBox(height: 28),
                    _sectionLabel('TOPIC'),
                    const SizedBox(height: 12),
                    _buildTopicInput(
                      hintText:
                          'e.g. Ordering food, travel greetings, daily small talk',
                    ),
                  ] else ...[
                    _sectionLabel('SCHOOL SUBJECT'),
                    const SizedBox(height: 12),
                    _buildSubjectGrid(),
                    const SizedBox(height: 28),
                    _sectionLabel('TOPIC'),
                    const SizedBox(height: 12),
                    _buildTopicInput(
                      hintText: 'e.g. Fractions, photosynthesis, World War II',
                    ),
                  ],
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
          colors: [_typeAccent.withValues(alpha: 0.18), AppColors.surface],
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
              // Close button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(
                      alpha: 0.7,
                    ),
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
              // Badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _typeAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _typeAccent.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  _lessonType == NewLessonType.language
                      ? '🎤  VOICE LESSON'
                      : '📚  SCHOOL LESSON',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: _typeAccent,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'New Lesson',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a type, topic and difficulty to get started.',
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

  // ── Lesson type selector ───────────────────────────────────────────────────

  Widget _buildLessonTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _TypeTile(
            emoji: '🎤',
            label: 'Voice',
            subtitle: 'Speak & listen',
            isSelected: _lessonType == NewLessonType.language,
            accent: AppColors.primary,
            onTap: () => setState(() => _lessonType = NewLessonType.language),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeTile(
            emoji: '📚',
            label: 'School',
            subtitle: 'Study & learn',
            isSelected: _lessonType == NewLessonType.school,
            accent: AppColors.secondary,
            onTap: () => setState(() => _lessonType = NewLessonType.school),
          ),
        ),
      ],
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

  // ── Subject grid ───────────────────────────────────────────────────────────

  Widget _buildSubjectGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _subjects.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, i) {
        final subject = _subjects[i];
        final isSelected = _selectedSubject == subject.$2;
        return _SelectableChip(
          isSelected: isSelected,
          accent: AppColors.secondary,
          onTap: () => setState(() => _selectedSubject = subject.$2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(subject.$1, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 5),
              Text(
                subject.$2,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                      fontWeight: isSelected
                          ? FontWeight.w700
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

  // ── Topic input ────────────────────────────────────────────────────────────

  Widget _buildTopicInput({required String hintText}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: TextField(
        controller: _topicController,
        minLines: 1,
        maxLines: 2,
        textCapitalization: TextCapitalization.sentences,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.onSurface,
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Icon(
              Icons.edit_note_rounded,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(),
        ),
      ),
    );
  }

  // ── Start button ───────────────────────────────────────────────────────────

  Widget _buildStartButton(BuildContext context) {
    final canAct = _canStart && !_isLoading;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: GestureDetector(
        onTap: canAct ? () => _onStart(context) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: canAct
                ? LinearGradient(
                    colors: [_typeAccent, _typeAccent.withValues(alpha: 0.75)],
                  )
                : const LinearGradient(
                    colors: [
                      AppColors.surfaceContainerHigh,
                      AppColors.surfaceContainerHigh,
                    ],
                  ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: canAct
                ? [
                    BoxShadow(
                      color: _typeAccent.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
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
                    Icon(
                      canAct
                          ? Icons.rocket_launch_rounded
                          : Icons.lock_outline_rounded,
                      color: canAct ? Colors.white : AppColors.onSurfaceVariant,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      canAct
                          ? 'Create $_selectedDifficulty Lesson'
                          : _lessonType == NewLessonType.language
                          ? 'Choose a language and topic'
                          : 'Choose a subject and topic',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: canAct
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _onStart(BuildContext context) async {
    final contentType = _lessonType == NewLessonType.language
        ? _selectedLanguage!
        : _selectedSubject!;
    final topic = _topicController.text.trim();
    final title = '$_selectedDifficulty $contentType · $topic';

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final created = await getIt<CreateLesson>().call(
        lessonType: _lessonType,
        contentType: contentType,
        topic: topic,
        difficulty: _selectedDifficulty,
        title: title,
      );
      if (getIt.isRegistered<LessonRefreshNotifier>()) {
        getIt<LessonRefreshNotifier>().notifyLessonsChanged();
      }

      // For voice lessons, open the lesson immediately after creation.
      if (_lessonType == NewLessonType.language) {
        navigator.pop(true);
        navigator.push(
          MaterialPageRoute(
            builder: (_) => VoiceLessonPage(lessonId: created.id),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('✅', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '"$title" created!',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.surfaceContainerHigh,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
        navigator.pop(true);
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('❌', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _friendlyError(e),
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static String _friendlyError(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timed out. Check your connection and try again.';
        case DioExceptionType.connectionError:
          return 'Could not reach the server. Check your internet connection.';
        default:
          final status = e.response?.statusCode;
          if (status == 401 || status == 403) {
            return 'Not authorised. Please sign out and sign back in.';
          }
          if (status != null && status >= 500) {
            return 'Server error ($status). Please try again later.';
          }
      }
    }
    final msg = e.toString().replaceAll('Exception: ', '');
    if (msg.contains('not authenticated') || msg.contains('sign in')) {
      return 'You need to be signed in to create a lesson.';
    }
    if (msg.contains('already exists')) return msg;
    return 'Something went wrong. Please try again.';
  }
}

// ── Type tile ─────────────────────────────────────────────────────────────────

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.12)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.50)
                : AppColors.outlineVariant.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? accent : AppColors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: accent, size: 18),
          ],
        ),
      ),
    );
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
