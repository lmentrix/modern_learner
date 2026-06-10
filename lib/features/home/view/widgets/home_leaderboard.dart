import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class HomeLeaderboard extends StatelessWidget {
  const HomeLeaderboard({super.key});

  static List<_LeaderboardSeed> get _entries => [
    _LeaderboardSeed(
      name: 'Maya Chen',
      initials: 'MC',
      track: 'Speaking',
      baseXp: 3820,
      dailyGain: 78,
      dailyPhase: 0,
      accent: AppColors.tertiary,
    ),
    _LeaderboardSeed(
      name: 'Noah Kim',
      initials: 'NK',
      track: 'Math',
      baseXp: 3910,
      dailyGain: 64,
      dailyPhase: 1,
      accent: AppColors.secondary,
    ),
    _LeaderboardSeed(
      name: 'Ava Patel',
      initials: 'AP',
      track: 'Science',
      baseXp: 3690,
      dailyGain: 91,
      dailyPhase: 2,
      accent: AppColors.primary,
    ),
    const _LeaderboardSeed(
      name: 'Leo Garcia',
      initials: 'LG',
      track: 'Writing',
      baseXp: 3560,
      dailyGain: 84,
      dailyPhase: 3,
      accent: Color(0xFFFFC857),
    ),
    const _LeaderboardSeed(
      name: 'You',
      initials: 'YO',
      track: 'Daily goal',
      baseXp: 3480,
      dailyGain: 97,
      dailyPhase: 4,
      accent: Color(0xFFFF7A90),
      highlighted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayEntries = _rankedEntriesFor(today);
    final yesterdayEntries = _rankedEntriesFor(
      today.subtract(const Duration(days: 1)),
    );
    final previousRankByName = {
      for (final entry in yesterdayEntries) entry.name: entry.rank,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= 720;
        final isCompact = width < 430;
        final topEntries = todayEntries.take(3).toList();

        return Container(
          padding: EdgeInsets.all(isCompact ? 12 : (isWide ? 20 : 16)),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LeaderboardHeader(
                totalLearners: todayEntries.length,
                leaderXp: todayEntries.first.xp,
              ),
              SizedBox(height: isWide ? 18 : 14),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _TopLearners(entries: topEntries)),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 4,
                      child: _LeaderboardList(
                        entries: todayEntries,
                        previousRankByName: previousRankByName,
                      ),
                    ),
                  ],
                )
              else ...[
                _TopLearners(entries: topEntries, compact: isCompact),
                const SizedBox(height: 14),
                _LeaderboardList(
                  entries: todayEntries,
                  previousRankByName: previousRankByName,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static List<_LeaderboardEntry> _rankedEntriesFor(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final seasonStart = DateTime(2026);
    final days = day.difference(seasonStart).inDays.clamp(0, 100000);
    final entries =
        _entries
            .map(
              (seed) => _LeaderboardEntry(
                seed: seed,
                xp:
                    seed.baseXp +
                    (seed.dailyGain * days) +
                    _dailyMomentumBonus(seed, days),
                rank: 0,
              ),
            )
            .toList()
          ..sort((a, b) => b.xp.compareTo(a.xp));

    return [
      for (var i = 0; i < entries.length; i++) entries[i].copyWith(rank: i + 1),
    ];
  }

  static int _dailyMomentumBonus(_LeaderboardSeed seed, int days) {
    return ((days + seed.dailyPhase) % _entries.length) * 1200;
  }
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader({
    required this.totalLearners,
    required this.leaderXp,
  });

  final int totalLearners;
  final int leaderXp;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 430;
        final iconSize = isCompact ? 38.0 : 44.0;
        final titleSize = isCompact ? 17.0 : 20.0;

        final title = Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.leaderboard_rounded,
                color: AppColors.primary,
                size: isCompact ? 21 : 24,
              ),
            ),
            SizedBox(width: isCompact ? 9 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily League',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$totalLearners learners reshuffle every day',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: isCompact ? 11 : 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: _XpPill(label: 'Top XP', value: leaderXp, compact: true),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 10),
            _XpPill(label: 'Top XP', value: leaderXp),
          ],
        );
      },
    );
  }
}

class _TopLearners extends StatelessWidget {
  const _TopLearners({required this.entries, this.compact = false});

  final List<_LeaderboardEntry> entries;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: [
          _PodiumCard(entry: entries.first, height: 130, featured: true),
          if (entries.length > 1) ...[
            const SizedBox(height: 8),
            _PodiumCard(entry: entries[1], height: 96, compact: true),
          ],
          if (entries.length > 2) ...[
            const SizedBox(height: 8),
            _PodiumCard(entry: entries[2], height: 96, compact: true),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (entries.length > 1)
          Expanded(child: _PodiumCard(entry: entries[1], height: 126)),
        const SizedBox(width: 10),
        Expanded(
          child: _PodiumCard(entry: entries.first, height: 152, featured: true),
        ),
        const SizedBox(width: 10),
        if (entries.length > 2)
          Expanded(child: _PodiumCard(entry: entries[2], height: 116)),
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.entry,
    required this.height,
    this.featured = false,
    this.compact = false,
  });

  final _LeaderboardEntry entry;
  final double height;
  final bool featured;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: entry.accent.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: entry.accent.withValues(alpha: 0.26)),
        ),
        child: Row(
          children: [
            _RankBadge(rank: entry.rank, color: entry.accent),
            const SizedBox(width: 10),
            _Avatar(entry: entry, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${entry.xp} XP',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: entry.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: entry.accent.withValues(alpha: featured ? 0.18 : 0.11),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.accent.withValues(alpha: featured ? 0.46 : 0.26),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RankBadge(rank: entry.rank, color: entry.accent),
          _Avatar(entry: entry, size: featured ? 46 : 38),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: featured ? 13 : 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${entry.xp} XP',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: entry.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({
    required this.entries,
    required this.previousRankByName,
  });

  final List<_LeaderboardEntry> entries;
  final Map<String, int> previousRankByName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in entries) ...[
          _LeaderboardRow(
            entry: entry,
            previousRank: previousRankByName[entry.name] ?? entry.rank,
          ),
          if (entry != entries.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry, required this.previousRank});

  final _LeaderboardEntry entry;
  final int previousRank;

  @override
  Widget build(BuildContext context) {
    final movement = previousRank - entry.rank;
    final movementColor = movement > 0
        ? AppColors.tertiary
        : movement < 0
        ? AppColors.error
        : AppColors.onSurfaceVariant;
    final movementIcon = movement > 0
        ? Icons.arrow_upward_rounded
        : movement < 0
        ? Icons.arrow_downward_rounded
        : Icons.remove_rounded;
    final movementLabel = movement == 0 ? '0' : movement.abs().toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: entry.highlighted
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.highlighted
              ? AppColors.primary.withValues(alpha: 0.36)
              : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${entry.rank}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _Avatar(entry: entry, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.track,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.xp}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(movementIcon, size: 13, color: movementColor),
                  const SizedBox(width: 2),
                  Text(
                    movementLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: movementColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.entry, required this.size});

  final _LeaderboardEntry entry;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: entry.accent.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(size / 2.8),
      ),
      alignment: Alignment.center,
      child: Text(
        entry.initials,
        style: GoogleFonts.inter(
          fontSize: size >= 40 ? 13 : 11,
          fontWeight: FontWeight.w900,
          color: entry.accent,
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.color});

  final int rank;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _XpPill extends StatelessWidget {
  const _XpPill({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final int value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '$value',
            style: GoogleFonts.inter(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardSeed {
  const _LeaderboardSeed({
    required this.name,
    required this.initials,
    required this.track,
    required this.baseXp,
    required this.dailyGain,
    required this.dailyPhase,
    required this.accent,
    this.highlighted = false,
  });

  final String name;
  final String initials;
  final String track;
  final int baseXp;
  final int dailyGain;
  final int dailyPhase;
  final Color accent;
  final bool highlighted;
}

class _LeaderboardEntry {
  _LeaderboardEntry({
    required _LeaderboardSeed seed,
    required this.xp,
    required this.rank,
  }) : name = seed.name,
       initials = seed.initials,
       track = seed.track,
       accent = seed.accent,
       highlighted = seed.highlighted;

  const _LeaderboardEntry._({
    required this.name,
    required this.initials,
    required this.track,
    required this.xp,
    required this.rank,
    required this.accent,
    required this.highlighted,
  });

  final String name;
  final String initials;
  final String track;
  final int xp;
  final int rank;
  final Color accent;
  final bool highlighted;

  _LeaderboardEntry copyWith({required int rank}) {
    return _LeaderboardEntry._(
      name: name,
      initials: initials,
      track: track,
      xp: xp,
      rank: rank,
      accent: accent,
      highlighted: highlighted,
    );
  }
}
