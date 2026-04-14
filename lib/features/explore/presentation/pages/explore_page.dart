import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/presentation/bloc/learning_subjects_bloc.dart';
import 'package:modern_learner_production/features/explore/presentation/bloc/learning_subjects_event.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/explore_header.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/explore_metrics_row.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/explore_search_panel.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/explore_spotlight_card.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/explore_states.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/learning_subject_card.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/learning_subjects_section.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/lesson_topic_card.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/library_subject_sheet.dart';
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

  void _showSubjectDetails(ExploreSubject subject) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LibrarySubjectSheet(subject: subject),
    );
  }

  void _openLearningSubject(BuildContext ctx, LearningSubject subject) {
    ctx.push(Routes.learningSubjectDetail, extra: subject);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LearningSubjectsBloc>(
      create: (_) =>
          getIt<LearningSubjectsBloc>()..add(const LoadLearningSubjects()),
      child: _ExploreBody(
        scrollCtrl: _scrollCtrl,
        searchCtrl: _searchCtrl,
        libraryFuture: _libraryFuture,
        selectedCategory: _selectedCategory,
        onRefresh: _reloadLibrary,
        onCategorySelected: (cat) {
          _searchDebounce?.cancel();
          setState(() {
            _selectedCategory = cat;
            _libraryFuture = _loadSubjects();
          });
        },
        onClearFilters: () {
          _searchDebounce?.cancel();
          setState(() {
            _selectedCategory = 'All';
            _searchCtrl.clear();
            _libraryFuture = _loadSubjects(forceRefresh: true);
          });
        },
        onShowDetails: _showSubjectDetails,
        onOpenLearningSubject: _openLearningSubject,
        hasSearchQuery: _searchCtrl.text.trim().isNotEmpty ||
            _selectedCategory != 'All',
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _ExploreBody extends StatelessWidget {
  const _ExploreBody({
    required this.scrollCtrl,
    required this.searchCtrl,
    required this.libraryFuture,
    required this.selectedCategory,
    required this.onRefresh,
    required this.onCategorySelected,
    required this.onClearFilters,
    required this.onShowDetails,
    required this.onOpenLearningSubject,
    required this.hasSearchQuery,
  });

  final ScrollController scrollCtrl;
  final TextEditingController searchCtrl;
  final Future<List<ExploreSubject>> libraryFuture;
  final String selectedCategory;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onClearFilters;
  final void Function(ExploreSubject) onShowDetails;
  final void Function(BuildContext, LearningSubject) onOpenLearningSubject;
  final bool hasSearchQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: FutureBuilder<List<ExploreSubject>>(
          future: libraryFuture,
          builder: (context, snapshot) {
            final all = snapshot.data ?? const <ExploreSubject>[];

            return RefreshIndicator(
              onRefresh: onRefresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: CustomScrollView(
                controller: scrollCtrl,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const SliverToBoxAdapter(child: ExploreHeader()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: ExploreSearchPanel(
                        searchController: searchCtrl,
                        categories: OpenAlexService.categoryOrder,
                        selectedCategory: selectedCategory,
                        onCategorySelected: onCategorySelected,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 22)),
                  ..._buildResearchContent(context, snapshot, all),
                  // ── Learning Subjects ──────────────────────────────────
                  const SliverToBoxAdapter(child: SizedBox(height: 36)),
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _SectionLabel(
                        'LEARNING SUBJECTS · CURATED CATALOG',
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 6)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Browse comprehensive subjects across science, humanities, arts, and more.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  const SliverToBoxAdapter(
                    child: LearningSubjectsCategoryFilter(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  LearningSubjectsGrid(
                    onSubjectTap: onOpenLearningSubject,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildResearchContent(
    BuildContext context,
    AsyncSnapshot<List<ExploreSubject>> snapshot,
    List<ExploreSubject> all,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting &&
        snapshot.data == null) {
      return [const ExploreLoadingContent()];
    }

    if (snapshot.hasError) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: ExploreErrorState(onRetry: onRefresh),
          ),
        ),
      ];
    }

    if (all.isEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: ExploreEmptyState(
              hasSearchQuery: hasSearchQuery,
              onClearFilters: onClearFilters,
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: ExploreSpotlightCard(
            subject: all.first,
            onTap: () => onShowDetails(all.first),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: ExploreMetricsRow(
            filteredSubjects: all,
            allSubjects: all,
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 28)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child:
              _SectionLabel('BROWSE RESEARCH · ${all.length} COLLECTIONS'),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 14)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.separated(
          itemCount: all.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final subject = all[index];
            return LessonTopicCard(
              emoji: subject.emoji,
              title: subject.name,
              subtitle:
                  '${subject.works.length} featured papers from ${_fmt(subject.workCount)} OpenAlex works',
              count: _fmt(subject.workCount),
              accentColor: subject.accentColor,
              category: subject.category,
              previewTitles: subject.previewTitles,
              coverUrl: subject.coverUrl,
              isPopular: subject.isPopular,
              onTap: () => onShowDetails(subject),
            );
          },
        ),
      ),
    ];
  }

  String _fmt(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
    }
    return '$count';
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
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
