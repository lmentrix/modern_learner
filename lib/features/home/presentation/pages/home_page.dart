import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../lesson_detail/presentation/pages/lesson_detail_page.dart'
    as lesson_detail;
import '../../data/models/lesson_data.dart';
import '../widgets/lesson_card.dart';
import '../widgets/progress_overview_card.dart';
import '../widgets/streak_badge.dart';
import '../widgets/streak_details_dialog.dart';
import '../widgets/voice_lesson_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollCtrl = ScrollController();

  void _showStreakDetails() {
    showDialog(
      context: context,
      builder: (context) => const StreakDetailsDialog(streak: 14),
    );
  }

  void _showProfileQuickView() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          final displayName = user?.name ?? 'User';
          final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
          
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              top: 12,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Profile header
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Advanced Learner · LVL 8',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Stats row
                const Row(
                  children: [
                    Expanded(
                      child: _QuickStat(
                        emoji: '🔥',
                        label: 'Streak',
                        value: '14',
                        subtitle: 'days',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _QuickStat(
                        emoji: '⭐',
                        label: 'XP',
                        value: '2.4K',
                        subtitle: 'total',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _QuickStat(
                        emoji: '📚',
                        label: 'Lessons',
                        value: '47',
                        subtitle: 'done',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Quick actions
                Text(
                  'QUICK ACTIONS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _QuickActionRow(
                  icon: Icons.person_outline_rounded,
                  label: 'View Profile',
                  accentColor: AppColors.primary,
                  onTap: () {
                    Navigator.of(context).pop();
                    GoRouter.of(context).push('view-profile');
                  },
                ),
                const SizedBox(height: 8),
                _QuickActionRow(
                  icon: Icons.emoji_events_rounded,
                  label: 'Achievements',
                  accentColor: AppColors.tertiaryContainer,
                  onTap: () {
                    Navigator.of(context).pop();
                    GoRouter.of(context).push('achievements');
                  },
                ),
                const SizedBox(height: 8),
                _QuickActionRow(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  accentColor: AppColors.onSurfaceVariant,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openLessonDetail(_Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => lesson_detail.LessonDetailPage(
          type: lesson_detail.LessonType.continueLearning,
          title: lesson.title,
          subtitle: '${lesson.chapter} · ${lesson.duration}',
          emoji: lesson.emoji,
          duration: lesson.duration,
          accentColor: lesson.color,
          progress: lesson.progress,
          totalLessons: lesson.totalLessons,
          completedLessons: lesson.completedLessons,
          learningObjectives: lesson.learningObjectives,
          sections: lesson.sections,
          lessonContent: lesson.content,
        ),
      ),
    );
  }

  void _openVoiceLessonDetail(_VoiceLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => lesson_detail.LessonDetailPage(
          type: lesson_detail.LessonType.voice,
          title: lesson.title,
          subtitle: lesson.subtitle,
          emoji: lesson.emoji,
          duration: lesson.duration,
          accentColor: lesson.color,
          progress: lesson.progress,
          totalLessons: lesson.totalLessons,
          completedLessons: lesson.completedLessons,
          learningObjectives: lesson.learningObjectives,
          sections: lesson.sections,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Progress overview ──────────────────────────────────────────
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: ProgressOverviewCard(
                  level: 8,
                  xp: 2400,
                  xpToNext: 3000,
                  progress: 0.73,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Voice lessons label ────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _sectionLabel('VOICE LESSONS')),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Voice lessons horizontal scroll ────────────────────────────
            SliverToBoxAdapter(child: _buildVoiceLessons()),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Continue learning label ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _sectionLabel('CONTINUE LEARNING'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Lesson cards ───────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: _lessons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final l = _lessons[i];
                  return LessonCard(
                    emoji: l.emoji,
                    title: l.title,
                    chapter: l.chapter,
                    duration: l.duration,
                    progress: l.progress,
                    accentColor: l.color,
                    isNew: l.isNew,
                    onTap: () => _openLessonDetail(l),
                  );
                },
              ),
            ),

            // Add padding for bottom navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final displayName = user?.name ?? 'User';
        final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
        
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E1020), AppColors.surface],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning,',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$displayName 👋',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            height: 1.1,
                          ),
                        ),
                        if (user?.isVip == true) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '★ VIP Member',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1028),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Avatar
                  GestureDetector(
                    onTap: () => _showProfileQuickView(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDim.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showStreakDetails(),
                child: const StreakBadge(count: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceLessons() {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _voiceLessons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final v = _voiceLessons[i];
          return VoiceLessonCard(
            title: v.title,
            subtitle: v.subtitle,
            duration: v.duration,
            accentColor: v.color,
            emoji: v.emoji,
            isActive: i == 0,
            onTap: () => _openVoiceLessonDetail(v),
          );
        },
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
}

// ── Static data ─────────────────────────────────────────────────────────────

class _VoiceLesson {
  const _VoiceLesson({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.color,
    required this.emoji,
    this.progress = 0.3,
    this.totalLessons = 8,
    this.completedLessons = 2,
    this.learningObjectives = const [
      'Improve pronunciation and accent',
      'Build speaking confidence',
      'Master conversational flow',
      'Develop listening skills',
    ],
    this.sections = const [
      lesson_detail.LessonSection(
        title: 'Warm-up Exercises',
        emoji: '🎤',
        duration: '5 min',
        lessonCount: 2,
        status: lesson_detail.LessonSectionStatus.completed,
      ),
      lesson_detail.LessonSection(
        title: 'Vowel Sounds',
        emoji: '🅰️',
        duration: '12 min',
        lessonCount: 3,
        status: lesson_detail.LessonSectionStatus.current,
      ),
      lesson_detail.LessonSection(
        title: 'Consonant Clusters',
        emoji: '🔤',
        duration: '15 min',
        lessonCount: 2,
        status: lesson_detail.LessonSectionStatus.locked,
      ),
      lesson_detail.LessonSection(
        title: 'Conversation Practice',
        emoji: '💬',
        duration: '20 min',
        lessonCount: 1,
        status: lesson_detail.LessonSectionStatus.locked,
      ),
    ],
  });
  final String title, subtitle, duration, emoji;
  final Color color;
  final double progress;
  final int totalLessons;
  final int completedLessons;
  final List<String> learningObjectives;
  final List<lesson_detail.LessonSection> sections;
}

class _Lesson {
  const _Lesson({
    required this.emoji,
    required this.title,
    required this.chapter,
    required this.duration,
    required this.progress,
    required this.color,
    this.isNew = false,
    this.totalLessons = 12,
    this.completedLessons = 0,
    this.learningObjectives = const [
      'Master key concepts and fundamentals',
      'Apply knowledge through practical exercises',
      'Build confidence with hands-on practice',
      'Track progress and celebrate achievements',
    ],
    this.sections = const [
      lesson_detail.LessonSection(
        title: 'Introduction to Basics',
        emoji: '📖',
        duration: '10 min',
        lessonCount: 3,
        status: lesson_detail.LessonSectionStatus.completed,
      ),
      lesson_detail.LessonSection(
        title: 'Core Concepts',
        emoji: '🧠',
        duration: '15 min',
        lessonCount: 4,
        status: lesson_detail.LessonSectionStatus.current,
      ),
      lesson_detail.LessonSection(
        title: 'Advanced Topics',
        emoji: '🚀',
        duration: '20 min',
        lessonCount: 3,
        status: lesson_detail.LessonSectionStatus.locked,
      ),
      lesson_detail.LessonSection(
        title: 'Final Project',
        emoji: '🏆',
        duration: '30 min',
        lessonCount: 2,
        status: lesson_detail.LessonSectionStatus.locked,
      ),
    ],
    this.content,
  });
  final String emoji, title, chapter, duration;
  final double progress;
  final Color color;
  final bool isNew;
  final int totalLessons;
  final int completedLessons;
  final List<String> learningObjectives;
  final List<lesson_detail.LessonSection> sections;
  final LessonContent? content;
}

const _voiceLessons = [
  _VoiceLesson(
    title: 'Pronunciation\nMastery',
    subtitle: 'Chapter 3 · Vowels',
    duration: '12 min',
    color: AppColors.primary,
    emoji: '🎤',
  ),
  _VoiceLesson(
    title: 'Conversational\nFlow',
    subtitle: 'Session 5 · Dialogue',
    duration: '8 min',
    color: AppColors.tertiary,
    emoji: '🗣️',
  ),
  _VoiceLesson(
    title: 'Accent\nReduction',
    subtitle: 'Module 2 · Rhythm',
    duration: '15 min',
    color: AppColors.secondary,
    emoji: '🎯',
  ),
];

const _lessons = [
  _Lesson(
    emoji: '📚',
    title: 'Grammar Fundamentals',
    chapter: 'Chapter 4',
    duration: '12 min',
    progress: 0.78,
    color: AppColors.primary,
    completedLessons: 9,
  ),
  _Lesson(
    emoji: '🍽️',
    title: 'At the Restaurant',
    chapter: 'Vocabulary',
    duration: '15 min',
    progress: 0.45,
    color: AppColors.secondary,
    isNew: true,
    totalLessons: 10,
    completedLessons: 4,
    learningObjectives: [
      'Order food confidently in Spanish',
      'Master essential restaurant vocabulary',
      'Use polite phrases for dining out',
      'Understand menu items and drinks',
    ],
    content: LessonContent(
      lessonType: 'vocabulary',
      introduction:
          "Welcome to 'At the Restaurant'! Learning how to order food is one of the most practical and rewarding skills for any Spanish traveler. In this lesson, we will cover the essential food items, drinks, and useful phrases you need to dine out with confidence.",
      vocabularyItems: [
        VocabularyItem(
          word: 'la carta',
          pronunciation: 'la KAR-ta',
          translation: 'the menu',
          partOfSpeech: 'noun',
          exampleSentence: 'Por favor, ¿me trae la carta?',
          exampleTranslation: 'Please, could you bring me the menu?',
          memoryTip: "Think of a 'cart' of food options.",
        ),
        VocabularyItem(
          word: 'el agua',
          pronunciation: 'el AH-gwa',
          translation: 'the water',
          partOfSpeech: 'noun',
          exampleSentence: 'Quiero una botella de agua, por favor.',
          exampleTranslation: 'I want a bottle of water, please.',
          memoryTip: "Sounds like 'aqua' or aquarium.",
        ),
        VocabularyItem(
          word: 'quisiera',
          pronunciation: 'kee-SYEH-ra',
          translation: 'I would like',
          partOfSpeech: 'verb',
          exampleSentence: 'Quisiera el pescado, por favor.',
          exampleTranslation: 'I would like the fish, please.',
          memoryTip: "Sounds like a polite 'kiss' of a request.",
        ),
        VocabularyItem(
          word: 'la cuenta',
          pronunciation: 'la KWEN-ta',
          translation: 'the bill',
          partOfSpeech: 'noun',
          exampleSentence: 'La cuenta, por favor.',
          exampleTranslation: 'The bill, please.',
          memoryTip: "When you see the bill, you 'count' your money.",
        ),
        VocabularyItem(
          word: 'la ensalada',
          pronunciation: 'la en-sa-LA-da',
          translation: 'the salad',
          partOfSpeech: 'noun',
          exampleSentence: 'Voy a pedir una ensalada mixta.',
          exampleTranslation: 'I am going to order a mixed salad.',
          memoryTip: 'Looks just like the English word salad.',
        ),
        VocabularyItem(
          word: 'el postre',
          pronunciation: 'el POS-treh',
          translation: 'the dessert',
          partOfSpeech: 'noun',
          exampleSentence: 'No quiero postre hoy.',
          exampleTranslation: 'I do not want dessert today.',
          memoryTip: 'Posted after the meal.',
        ),
        VocabularyItem(
          word: 'el pollo',
          pronunciation: 'el PO-yo',
          translation: 'the chicken',
          partOfSpeech: 'noun',
          exampleSentence: 'El pollo está delicioso.',
          exampleTranslation: 'The chicken is delicious.',
          memoryTip: "Think of a chicken 'poking' around.",
        ),
        VocabularyItem(
          word: 'la mesa',
          pronunciation: 'la ME-sa',
          translation: 'the table',
          partOfSpeech: 'noun',
          exampleSentence: 'Una mesa para dos, por favor.',
          exampleTranslation: 'A table for two, please.',
          memoryTip: "Sounds like 'mess'-a (wipe the mess off the table).",
        ),
        VocabularyItem(
          word: 'pedir',
          pronunciation: 'pe-DEER',
          translation: 'to order/to ask for',
          partOfSpeech: 'verb',
          exampleSentence: 'Es hora de pedir la comida.',
          exampleTranslation: 'It is time to order the food.',
          memoryTip: "You 'ped' (petition) the waiter for food.",
        ),
        VocabularyItem(
          word: 'la bebida',
          pronunciation: 'la be-BEE-da',
          translation: 'the drink',
          partOfSpeech: 'noun',
          exampleSentence: '¿Qué bebida desea?',
          exampleTranslation: 'What drink would you like?',
          memoryTip: "Think of 'be' (to be) drinking.",
        ),
      ],
      practiceExercises: [
        PracticeExercise(
          type: 'match',
          instruction: 'Match the Spanish word to its correct English meaning.',
          items: [
            ExerciseItem(question: 'La cuenta', answer: 'The bill'),
            ExerciseItem(question: 'La mesa', answer: 'The table'),
            ExerciseItem(question: 'El postre', answer: 'The dessert'),
          ],
        ),
        PracticeExercise(
          type: 'fill_blank',
          instruction: 'Fill in the blank with the correct word.',
          items: [
            ExerciseItem(
              question: 'Quisiera _______ el agua, por favor.',
              answer: 'pedir',
            ),
            ExerciseItem(
              question: 'Por favor, ¿me trae la _______?',
              answer: 'carta',
            ),
          ],
        ),
        PracticeExercise(
          type: 'translate',
          instruction: 'Translate the phrases into Spanish.',
          items: [
            ExerciseItem(
              question: 'I would like the chicken.',
              answer: 'Quisiera el pollo.',
            ),
            ExerciseItem(
              question: 'The bill, please.',
              answer: 'La cuenta, por favor.',
            ),
          ],
        ),
      ],
      summary:
          "In this lesson, you mastered essential vocabulary for ordering food: 'la carta' (menu), 'pedir' (to order), 'la mesa' (table), 'la cuenta' (bill), and basic food items like 'pollo' and 'ensalada'. Using 'quisiera' is a polite way to place your order.",
    ),
  ),
  _Lesson(
    emoji: '✍️',
    title: 'Writing & Composition',
    chapter: 'Module 6',
    duration: '20 min',
    progress: 0.30,
    color: AppColors.tertiary,
    completedLessons: 3,
  ),
  _Lesson(
    emoji: '🌍',
    title: 'Cultural Context',
    chapter: 'Unit 1',
    duration: '10 min',
    progress: 0.10,
    color: Color(0xFFFF9500),
    isNew: true,
    completedLessons: 1,
  ),
];

// ── Quick Stat Widget ───────────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  final String emoji, label, value, subtitle;

  const _QuickStat({
    required this.emoji,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Row ────────────────────────────────────────────────────────

class _QuickActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickActionRow({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
