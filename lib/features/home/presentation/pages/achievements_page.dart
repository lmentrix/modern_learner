import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/domain/entities/achievement_entity.dart';
import 'package:modern_learner_production/features/home/presentation/bloc/achievement_bloc.dart';

// ── Category meta ─────────────────────────────────────────────────────────────

const _categoryMeta = {
  'All': ('🏅', AppColors.primary),
  'Streaks': ('🔥', Color(0xFFFF9500)),
  'Experience': ('⭐', Color(0xFFFFD700)),
  'Learning': ('📚', AppColors.primary),
  'Special': ('🚀', Color(0xFF7E51FF)),
};

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

  static const _tabs = ['All', 'Streaks', 'Experience', 'Learning', 'Special'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(_onTabChanged);
    // Trigger a load after the first frame so context.read is safe.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AchievementBloc>().add(const AchievementLoadRequested());
      }
    });
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
    // The singleton bloc is provided by MainLayout; access via context.
    context.read<AchievementBloc>().add(AchievementFilterChanged(filterKey));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) => _buildScaffold(context, state),
    );
  }

  Widget _buildScaffold(BuildContext context, AchievementState state) {
    return Material(
      color: AppColors.surface,
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _Header(state: state)),

          // ── Hero progress card ───────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverToBoxAdapter(child: _HeroCard(state: state)),
          ),

          // ── Recently unlocked spotlight ──────────────────────────────────────
          if (state.achievements.any((a) => !a.isLocked)) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _sectionLabel('RECENTLY UNLOCKED'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _RecentlyUnlockedRow(
                achievements: state.achievements
                    .where((a) => !a.isLocked)
                    .take(5)
                    .toList(),
                onTap: (a) => context.push(Routes.achievementDetail, extra: a),
              ),
            ),
          ],

          // ── Category tabs ────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _sectionLabel('BROWSE BY CATEGORY'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: _CategoryTabBar(controller: _tabCtrl, tabs: _tabs),
          ),

          // ── Grid ─────────────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          for (final entry in state.groupedFiltered.entries)
            if (entry.value.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: _CategoryGroupHeader(
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
                  itemBuilder: (context, i) => _AchievementCard(
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

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: AppColors.onSurfaceVariant,
      letterSpacing: 1.7,
    ),
  );
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.state});
  final AchievementState state;

  @override
  Widget build(BuildContext context) {
    final unlocked = state.unlockedCount;
    final total = state.achievements.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E1020), AppColors.surface],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Back + badge row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.tertiaryContainer.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: AppColors.tertiaryContainer,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$unlocked / $total',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Achievements',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Earn badges by completing lessons, building streaks and reaching milestones.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.55),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero progress card ────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.state});
  final AchievementState state;

  @override
  Widget build(BuildContext context) {
    final unlocked = state.unlockedCount;
    final total = state.achievements.length;
    final locked = total - unlocked;
    final progress = total == 0 ? 0.0 : unlocked / total;
    final pct = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C3FFF), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3FFF).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unlocked Unlocked',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '$locked remaining · $pct% complete',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Stats row
          Row(
            children: [
              _StatChip(emoji: '🔓', label: 'Unlocked', value: '$unlocked'),
              const SizedBox(width: 8),
              _StatChip(emoji: '🔒', label: 'Locked', value: '$locked'),
              const SizedBox(width: 8),
              _StatChip(
                emoji: '📂',
                label: 'Categories',
                value: '${AchievementBloc.categoryOrder.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recently unlocked row ─────────────────────────────────────────────────────

class _RecentlyUnlockedRow extends StatelessWidget {
  const _RecentlyUnlockedRow({required this.achievements, required this.onTap});

  final List<AchievementEntity> achievements;
  final void Function(AchievementEntity) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final a = achievements[i];
          final tierColor = AchievementEntity.tierColor(a.currentLevel);
          return GestureDetector(
            onTap: () => onTap(a),
            child: Container(
              width: 130,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tierColor.withValues(alpha: 0.22),
                    AppColors.surfaceContainerLow,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tierColor.withValues(alpha: 0.35)),
                boxShadow: [
                  BoxShadow(
                    color: tierColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tier pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: tierColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${AchievementEntity.tierName(a.currentLevel).toUpperCase()} ${AchievementEntity.tierRoman(a.currentLevel)}',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: tierColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(a.emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 8),
                  Text(
                    a.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    a.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Category tab bar ──────────────────────────────────────────────────────────

class _CategoryTabBar extends StatelessWidget {
  const _CategoryTabBar({required this.controller, required this.tabs});

  final TabController controller;
  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tabs.length,
        separatorBuilder: (_, _2) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final isSelected = controller.index == i;
              final meta = _categoryMeta[tabs[i]];
              final accent = meta?.$2 ?? AppColors.primary;
              return GestureDetector(
                onTap: () => controller.animateTo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent.withValues(alpha: 0.15)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? accent.withValues(alpha: 0.50)
                          : AppColors.outlineVariant.withValues(alpha: 0.2),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (meta != null) ...[
                        Text(meta.$1, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        tabs[i],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? accent
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Category group header ─────────────────────────────────────────────────────

class _CategoryGroupHeader extends StatelessWidget {
  const _CategoryGroupHeader({
    required this.category,
    required this.count,
    required this.unlocked,
  });

  final String category;
  final int count;
  final int unlocked;

  @override
  Widget build(BuildContext context) {
    final meta = _categoryMeta[category];
    final accent = meta?.$2 ?? AppColors.primary;
    final emoji = meta?.$1 ?? '🏅';

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 15)),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          category.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.6,
          ),
        ),
        const Spacer(),
        Text(
          '$unlocked/$count',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: unlocked == count ? accent : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 6),
        if (unlocked == count)
          Icon(Icons.check_circle_rounded, color: accent, size: 16)
        else
          Icon(
            Icons.radio_button_unchecked_rounded,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            size: 16,
          ),
      ],
    );
  }
}

// ── Achievement card ──────────────────────────────────────────────────────────

class _AchievementCard extends StatefulWidget {
  const _AchievementCard({required this.achievement, required this.onTap});

  final AchievementEntity achievement;
  final VoidCallback onTap;

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      value: 1.0,
    );
    _scale = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final isLocked = a.isLocked;
    final color = a.color;
    final tierColor = isLocked
        ? AppColors.outlineVariant
        : AchievementEntity.tierColor(a.currentLevel);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: isLocked
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surfaceContainerLow,
                      AppColors.surfaceContainerHigh,
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.18),
                      AppColors.surfaceContainerLow,
                      AppColors.surface.withValues(alpha: 0.9),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isLocked
                  ? AppColors.outlineVariant.withValues(alpha: 0.15)
                  : color.withValues(alpha: 0.32),
            ),
            boxShadow: isLocked
                ? []
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.16),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: emoji icon + level pip dots
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? AppColors.surfaceContainerHighest
                          : color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isLocked
                          ? null
                          : [
                              BoxShadow(
                                color: color.withValues(alpha: 0.30),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: isLocked ? 0.30 : 1.0,
                        child: Text(
                          a.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 5 level pip dots
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (i) {
                          final earned = i < a.currentLevel;
                          return Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(left: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: earned
                                  ? AchievementEntity.tierColor(i + 1)
                                  : AppColors.outlineVariant.withValues(
                                      alpha: 0.25,
                                    ),
                            ),
                          );
                        }),
                      ),
                      if (!isLocked) ...[
                        const SizedBox(height: 4),
                        Text(
                          a.isMaxLevel
                              ? 'MAX'
                              : AchievementEntity.tierName(a.currentLevel),
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: tierColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Title
              Text(
                a.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isLocked
                      ? AppColors.onSurfaceVariant.withValues(alpha: 0.40)
                      : AppColors.onSurface,
                  height: 1.15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 5),

              // Current level requirement pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppColors.surfaceContainerHighest
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isLocked
                      ? a.levelRequirements[0]
                      : a.isMaxLevel
                      ? 'Diamond V · Max'
                      : '${AchievementEntity.tierName(a.currentLevel)} ${AchievementEntity.tierRoman(a.currentLevel)}',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isLocked
                        ? AppColors.onSurfaceVariant.withValues(alpha: 0.35)
                        : tierColor,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Progress bar to next level (shown when a level is earned and not max)
              if (!isLocked && !a.isMaxLevel) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: a.progressToNextLevel,
                    minHeight: 3,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AchievementEntity.tierColor(a.currentLevel + 1),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
