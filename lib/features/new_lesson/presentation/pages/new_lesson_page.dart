import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class NewLessonPage extends StatefulWidget {
  const NewLessonPage({super.key});

  @override
  State<NewLessonPage> createState() => _NewLessonPageState();
}

class _NewLessonPageState extends State<NewLessonPage> {
  String? _selectedLanguage;
  String? _selectedTopic;
  String _selectedDifficulty = 'Beginner';

  bool get _canStart => _selectedLanguage != null && _selectedTopic != null;

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
    ('📖', 'Vocabulary'),
    ('💬', 'Conversation'),
    ('✍️', 'Grammar'),
    ('🔊', 'Pronunciation'),
    ('📝', 'Writing'),
    ('👂', 'Listening'),
    ('📚', 'Reading'),
    ('🎭', 'Culture'),
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
                    _sectionLabel('LANGUAGE'),
                    const SizedBox(height: 12),
                    _buildLanguageGrid(),
                    const SizedBox(height: 28),
                    _sectionLabel('TOPIC'),
                    const SizedBox(height: 12),
                    _buildTopicGrid(),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _canStart ? 1.0 : 0.4,
        child: GestureDetector(
          onTap: _canStart ? () => _onStart(context) : null,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: _canStart
                  ? AppColors.primaryGradient
                  : const LinearGradient(
                      colors: [AppColors.outlineVariant, AppColors.outlineVariant]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _canStart
                      ? 'Start $_selectedDifficulty Lesson'
                      : 'Choose a language and topic',
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

  void _onStart(BuildContext context) {
    // Show a quick confirmation snackbar then close
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Starting $_selectedDifficulty $_selectedLanguage · $_selectedTopic',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.surfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }
}

// ── Reusable selectable card ──────────────────────────────────────────────────

class _SelectableCard extends StatelessWidget {
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;
  final Widget child;

  const _SelectableCard({
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
    required this.child,
  });

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
