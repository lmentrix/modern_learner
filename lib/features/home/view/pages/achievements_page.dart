import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/home_achievement_data.dart';
import 'package:modern_learner_production/features/home/view/section/achievements_category_group_header_section.dart';
import 'package:modern_learner_production/features/home/view/section/achievements_category_tab_bar_section.dart';
import 'package:modern_learner_production/features/home/view/section/achievements_header_section.dart';
import 'package:modern_learner_production/features/home/view/section/achievements_hero_section.dart';
import 'package:modern_learner_production/features/home/view/section/achievements_recently_unlocked_section.dart';
import 'package:modern_learner_production/features/home/view/widgets/achievement_card.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_section_label.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  late final TabController _tabCtrl;
  late AchievementState _state;

  static const _tabs = [
    'All',
    'Streaks',
    'Experience',
    'Learning',
    'Mastery',
    'Dedication',
    'Special',
  ];

  @override
  void initState() {
    super.initState();
    _state = buildAchievementState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _tabCtrl
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabCtrl.indexIsChanging) return;
    final filter = _tabs[_tabCtrl.index];
    final filterKey = filter == 'All' ? 'all' : filter;
    setState(() {
      _state = updateAchievementFilter(_state, filterKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: AchievementsHeaderSection(state: _state)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverToBoxAdapter(
              child: AchievementsHeroSection(state: _state),
            ),
          ),
          if (_state.achievements.any((a) => !a.isLocked)) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: HomeSectionLabel(text: 'RECENTLY UNLOCKED'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: AchievementsRecentlyUnlockedSection(
                achievements: _state.achievements
                    .where((a) => !a.isLocked)
                    .take(5)
                    .toList(),
                onTap: (a) => context.push(Routes.achievementDetail, extra: a),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: HomeSectionLabel(
                text: 'BROWSE BY CATEGORY',
                fontWeight: FontWeight.w800,
                letterSpacing: 1.7,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: AchievementsCategoryTabBarSection(
              controller: _tabCtrl,
              tabs: _tabs,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          for (final entry in _state.groupedFiltered.entries)
            if (entry.value.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: AchievementsCategoryGroupHeaderSection(
                    category: entry.key,
                    count: entry.value.length,
                    unlocked: entry.value.where((a) => !a.isLocked).length,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.80,
                  ),
                  itemCount: entry.value.length,
                  itemBuilder: (context, i) => AchievementCard(
                    achievement: entry.value[i],
                    onTap: () => context.push(
                      Routes.achievementDetail,
                      extra: entry.value[i],
                    ),
                  ),
                ),
              ),
            ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
