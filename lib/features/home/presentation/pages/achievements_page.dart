import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/domain/entities/achievement_entity.dart';
import 'package:modern_learner_production/features/home/presentation/bloc/achievement_bloc.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AchievementBloc()..add(const AchievementLoadRequested()),
      child: BlocBuilder<AchievementBloc, AchievementState>(
        builder: (context, state) => _buildContent(context, state),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AchievementState state) {
    return Material(
          color: AppColors.surface,
          child: SafeArea(
            child: CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, state)),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: _buildProgressCard(state)),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _buildFilterChips(context, state),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _sectionLabel('ALL ACHIEVEMENTS'),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: state.filtered.length,
                    itemBuilder: (context, i) => _AchievementCard(
                      achievement: state.filtered[i],
                      onTap: () => context.push(
                        Routes.achievementDetail,
                        extra: state.filtered[i],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
  }

  Widget _buildHeader(BuildContext context, AchievementState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E1020), AppColors.surface],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: AppColors.onSurface,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'Achievements',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.tertiaryContainer,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${state.unlockedCount}/${state.achievements.length}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(AchievementState state) {
    final unlocked = state.unlockedCount;
    final total = state.achievements.length;
    final progress = total == 0 ? 0.0 : unlocked / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unlocked / $total Unlocked',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Keep learning to earn more!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, AchievementState state) {
    const filters = [('All', 'all'), ('Unlocked', 'unlocked'), ('Locked', 'locked')];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in filters)
          FilterChip(
            label: Text(
              filter.$1,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: state.selectedFilter == filter.$2
                    ? Colors.white
                    : AppColors.onSurfaceVariant,
              ),
            ),
            selected: state.selectedFilter == filter.$2,
            onSelected: (_) => context
                .read<AchievementBloc>()
                .add(AchievementFilterChanged(filter.$2)),
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            backgroundColor: AppColors.surfaceContainerHighest,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

// ── Achievement Card ──────────────────────────────────────────────────────────

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.achievement,
    required this.onTap,
  });

  final AchievementEntity achievement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = achievement.color;
    final isLocked = achievement.isLocked;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isLocked
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surfaceContainerHigh,
                    AppColors.surfaceContainerHighest,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.14),
                    AppColors.surfaceContainerHigh,
                    AppColors.surfaceContainerHigh,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLocked
                ? AppColors.outlineVariant.withValues(alpha: 0.12)
                : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? AppColors.surfaceContainerHighest
                          : color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isLocked
                          ? null
                          : [
                              BoxShadow(
                                color: color.withValues(alpha: 0.35),
                                blurRadius: 18,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: isLocked ? 0.35 : 1.0,
                        child: Text(
                          achievement.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? AppColors.surfaceContainerHighest
                          : color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_rounded : Icons.check_rounded,
                      size: 13,
                      color: isLocked
                          ? AppColors.onSurfaceVariant.withValues(alpha: 0.45)
                          : color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                achievement.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isLocked
                      ? AppColors.onSurfaceVariant.withValues(alpha: 0.45)
                      : AppColors.onSurface,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppColors.surfaceContainerHighest
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  achievement.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isLocked
                        ? AppColors.onSurfaceVariant.withValues(alpha: 0.4)
                        : color,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
