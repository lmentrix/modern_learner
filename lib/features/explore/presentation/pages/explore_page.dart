import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../widgets/explore_category_card.dart';
import '../widgets/lesson_topic_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _scrollCtrl = ScrollController();
  String _selectedCategory = 'All';

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

            // ── Category pills ──────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildCategoryPills()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Create new section ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _sectionLabel('CREATE NEW')),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Designed lessons & lectures ────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildCreateOptions()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Custom topics section ──────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _sectionLabel('CUSTOM TOPICS')),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Custom topic cards ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildCustomTopics()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Browse library section ─────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                  child: _sectionLabel('BROWSE LIBRARY')),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Topic cards grid ───────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: _topics.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final topic = _topics[i];
                  return LessonTopicCard(
                    emoji: topic.emoji,
                    title: topic.title,
                    subtitle: topic.subtitle,
                    count: topic.count,
                    accentColor: topic.color,
                    isPopular: topic.isPopular,
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
          Text(
            'Explore',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover new lessons or create your own',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPills() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final category = _categories[i];
          final isActive = _selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isActive ? AppColors.primaryGradient : null,
                color: isActive
                    ? null
                    : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(100),
                border: isActive
                    ? null
                    : Border.all(
                        color:
                            AppColors.outlineVariant.withValues(alpha: 0.15),
                        width: 1,
                      ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFF1A1028)
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateOptions() {
    return Column(
      children: [
        ExploreCategoryCard(
          emoji: '🎤',
          title: 'Voice Language Lesson',
          description: 'Designed pronunciation and speaking lessons',
          accentColor: AppColors.primary,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        ExploreCategoryCard(
          emoji: '📖',
          title: 'School Lecture',
          description: 'Structured academic lectures and courses',
          accentColor: AppColors.secondary,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCustomTopics() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDim.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryDim.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Lesson',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a lesson on any topic',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.tertiaryContainer.withValues(alpha: 0.2),
                  AppColors.tertiary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.tertiaryContainer.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.tertiaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF003320),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Lecture',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Design a full lecture series',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
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

const _categories = [
  'All',
  'Language',
  'Science',
  'Math',
  'History',
  'Arts',
  'Technology',
];

class _Topic {
  const _Topic({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.color,
    this.isPopular = false,
  });
  final String emoji, title, subtitle, count;
  final Color color;
  final bool isPopular;
}

const _topics = [
  _Topic(
    emoji: '🇪🇸',
    title: 'Spanish Basics',
    subtitle: 'Beginner · 24 lessons',
    count: '24',
    color: AppColors.primary,
    isPopular: true,
  ),
  _Topic(
    emoji: '🧬',
    title: 'Biology 101',
    subtitle: 'Intermediate · 18 lessons',
    count: '18',
    color: AppColors.secondary,
  ),
  _Topic(
    emoji: '📐',
    title: 'Algebra Fundamentals',
    subtitle: 'Beginner · 32 lessons',
    count: '32',
    color: AppColors.tertiaryContainer,
  ),
  _Topic(
    emoji: '🏛️',
    title: 'World History',
    subtitle: 'Intermediate · 45 lessons',
    count: '45',
    color: Color(0xFFFF9500),
    isPopular: true,
  ),
  _Topic(
    emoji: '🎨',
    title: 'Art Appreciation',
    subtitle: 'Beginner · 12 lessons',
    count: '12',
    color: Color(0xFFFF6B9D),
  ),
  _Topic(
    emoji: '💻',
    title: 'Programming Basics',
    subtitle: 'Beginner · 28 lessons',
    count: '28',
    color: Color(0xFF00DC82),
    isPopular: true,
  ),
];
