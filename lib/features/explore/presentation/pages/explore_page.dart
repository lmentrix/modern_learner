import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/lesson_topic_card.dart';
import 'package:modern_learner_production/features/explore/service/explore_subject.dart';
import 'package:modern_learner_production/features/explore/service/open_alex_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  late final OpenAlexService _libraryService;
  late Future<List<ExploreSubject>> _libraryFuture;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _libraryService = OpenAlexService(getIt<Dio>());
    _libraryFuture = _loadSubjects();
    _searchCtrl.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchDebounce?.cancel();
    _searchCtrl
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _libraryFuture = _loadSubjects());
    });
  }

  Future<List<ExploreSubject>> _loadSubjects({bool forceRefresh = false}) {
    return _libraryService.fetchSubjects(
      search: _searchCtrl.text.trim(),
      category: _selectedCategory,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _reloadLibrary() async {
    final future = _loadSubjects(forceRefresh: true);
    setState(() => _libraryFuture = future);
    await future;
  }

  List<String> _categoriesFor() {
    return OpenAlexService.categoryOrder;
  }

  void _showSubjectDetails(ExploreSubject subject) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LibrarySubjectSheet(subject: subject),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: FutureBuilder<List<ExploreSubject>>(
          future: _libraryFuture,
          builder: (context, snapshot) {
            final allSubjects = snapshot.data ?? const <ExploreSubject>[];
            final categories = _categoriesFor();
            final filteredSubjects = allSubjects;

            return RefreshIndicator(
              onRefresh: _reloadLibrary,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: CustomScrollView(
                controller: _scrollCtrl,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _buildSearchPanel(categories),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 22)),
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null)
                    ..._buildLoadingSlivers()
                  else if (snapshot.hasError)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: _ErrorState(onRetry: _reloadLibrary),
                      ),
                    )
                  else if (filteredSubjects.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: _EmptyState(
                          hasSearchQuery:
                              _searchCtrl.text.trim().isNotEmpty ||
                              _selectedCategory != 'All',
                          onClearFilters: () {
                            _searchDebounce?.cancel();
                            setState(() {
                              _selectedCategory = 'All';
                              _searchCtrl.clear();
                              _libraryFuture = _loadSubjects(
                                forceRefresh: true,
                              );
                            });
                          },
                        ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: _buildSpotlight(filteredSubjects.first),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: _buildMetrics(filteredSubjects, allSubjects),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 28)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: _sectionLabel(
                          'BROWSE RESEARCH · ${filteredSubjects.length} COLLECTIONS',
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList.separated(
                        itemCount: filteredSubjects.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final subject = filteredSubjects[index];
                          return LessonTopicCard(
                            emoji: subject.emoji,
                            title: subject.name,
                            subtitle:
                                '${subject.works.length} featured papers from ${_formatCount(subject.workCount)} OpenAlex works',
                            count: _formatCount(subject.workCount),
                            accentColor: subject.accentColor,
                            category: subject.category,
                            previewTitles: subject.previewTitles,
                            coverUrl: subject.coverUrl,
                            isPopular: subject.isPopular,
                            onTap: () => _showSubjectDetails(subject),
                          );
                        },
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              'LIVE FROM OPENALEX',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.tertiary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Browse research collections',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Live subject feeds from OpenAlex with search and category filtering for language, school, and research learning.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPanel(List<String> categories) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerHigh.withValues(alpha: 0.86),
            AppColors.surfaceContainerLow.withValues(alpha: 0.92),
          ],
        ),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filter the research feed',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Text(
                'Pull to refresh',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.onSurfaceVariant,
                ),
                hintText: 'Search subjects, categories, or paper titles',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isActive = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    _searchDebounce?.cancel();
                    setState(() {
                      _selectedCategory = category;
                      _libraryFuture = _loadSubjects();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: isActive ? AppColors.primaryGradient : null,
                      color: isActive
                          ? null
                          : AppColors.surfaceContainerHighest.withValues(
                              alpha: 0.52,
                            ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isActive
                            ? Colors.transparent
                            : AppColors.outlineVariant.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlight(ExploreSubject subject) {
    final featuredWorks = subject.previewTitles.take(2).join('  •  ');

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF16203B),
            subject.accentColor.withValues(alpha: 0.28),
            const Color(0xFF0E1020),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: subject.accentColor.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    '${subject.category.toUpperCase()} SPOTLIGHT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${subject.emoji} ${subject.name}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_formatCount(subject.workCount)} papers available to explore now.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.74),
                    height: 1.5,
                  ),
                ),
                if (featuredWorks.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    featuredWorks,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subject.accentColor.withValues(alpha: 0.98),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => _showSubjectDetails(subject),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Open collection',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF12192B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Color(0xFF12192B),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          _SpotlightCover(
            emoji: subject.emoji,
            accentColor: subject.accentColor,
            coverUrl: subject.coverUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(
    List<ExploreSubject> filteredSubjects,
    List<ExploreSubject> allSubjects,
  ) {
    final totalWorks = filteredSubjects.fold<int>(
      0,
      (sum, subject) => sum + subject.workCount,
    );

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Visible',
            value: '${filteredSubjects.length}',
            hint: 'collections',
            accentColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Papers',
            value: _formatCount(totalWorks),
            hint: 'papers tracked',
            accentColor: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Source',
            value: 'OpenAlex',
            hint: '${allSubjects.length} feeds',
            accentColor: AppColors.tertiary,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLoadingSlivers() {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.separated(
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) => Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(26),
            ),
          ),
        ),
      ),
    ];
  }

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
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.hint,
    required this.accentColor,
  });

  final String label;
  final String value;
  final String hint;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
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

class _SpotlightCover extends StatelessWidget {
  const _SpotlightCover({
    required this.emoji,
    required this.accentColor,
    this.coverUrl,
  });

  final String emoji;
  final Color accentColor;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 156,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: coverUrl == null
          ? DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.8),
                    accentColor.withValues(alpha: 0.22),
                  ],
                ),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 40)),
              ),
            )
          : CachedNetworkImage(
              imageUrl: coverUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.72),
                      accentColor.withValues(alpha: 0.22),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 36)),
                ),
              ),
              errorWidget: (context, url, error) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.72),
                      accentColor.withValues(alpha: 0.22),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 36)),
                ),
              ),
            ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Research feed unavailable',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'OpenAlex did not respond. Pull to refresh or retry below.',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasSearchQuery,
    required this.onClearFilters,
  });

  final bool hasSearchQuery;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Text('🔎', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 14),
          Text(
            hasSearchQuery
                ? 'No matching collections'
                : 'No collections available',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try another category or clear the current search to see more research fields.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onClearFilters,
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }
}

class _LibrarySubjectSheet extends StatelessWidget {
  const _LibrarySubjectSheet({required this.subject});

  final ExploreSubject subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${subject.emoji} ${subject.name}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${subject.category} · ${_formatCount(subject.workCount)} works on OpenAlex',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              if (subject.description.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  subject.description,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: subject.accentColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _formatCount(subject.workCount),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: subject.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.separated(
                    itemCount: subject.works.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final work = subject.works[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.12,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 68,
                              height: 92,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: subject.accentColor.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  subject.emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    work.title,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    work.authors,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  if (work.sourceName != null &&
                                      work.sourceName!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      work.sourceName!,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      if (work.publicationYear != null)
                                        _DetailPill(
                                          label: '${work.publicationYear}',
                                          accentColor: subject.accentColor,
                                        ),
                                      if (work.citationCount > 0)
                                        _DetailPill(
                                          label:
                                              '${_formatCount(work.citationCount)} citations',
                                          accentColor: subject.accentColor,
                                        ),
                                      if (work.type != null &&
                                          work.type!.isNotEmpty)
                                        _DetailPill(
                                          label: work.type!,
                                          accentColor: subject.accentColor,
                                        ),
                                      if (work.isOpenAccess)
                                        _DetailPill(
                                          label: 'Open access',
                                          accentColor: subject.accentColor,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: accentColor,
        ),
      ),
    );
  }
}

String _formatCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
  }
  return '$count';
}
