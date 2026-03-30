import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../widgets/lesson_card.dart';
import '../widgets/progress_overview_card.dart';
import '../widgets/streak_badge.dart';
import '../widgets/voice_lesson_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollCtrl = ScrollController();

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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  child: _sectionLabel('CONTINUE LEARNING')),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0E1020),
            AppColors.surface,
          ],
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
                      'Alex 👋',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar
              Container(
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
                    'A',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const StreakBadge(count: 14),
        ],
      ),
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
  });
  final String title, subtitle, duration, emoji;
  final Color color;
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
  });
  final String emoji, title, chapter, duration;
  final double progress;
  final Color color;
  final bool isNew;
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
  ),
  _Lesson(
    emoji: '🧠',
    title: 'AI Conversation Partner',
    chapter: 'Session 2',
    duration: '8 min',
    progress: 0.45,
    color: AppColors.secondary,
    isNew: true,
  ),
  _Lesson(
    emoji: '✍️',
    title: 'Writing & Composition',
    chapter: 'Module 6',
    duration: '20 min',
    progress: 0.30,
    color: AppColors.tertiary,
  ),
  _Lesson(
    emoji: '🌍',
    title: 'Cultural Context',
    chapter: 'Unit 1',
    duration: '10 min',
    progress: 0.10,
    color: Color(0xFFFF9500),
    isNew: true,
  ),
];
