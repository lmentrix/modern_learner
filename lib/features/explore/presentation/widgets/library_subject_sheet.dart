import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_subject.dart';
import 'package:modern_learner_production/features/explore/utils/explore_utils.dart';

class LibrarySubjectSheet extends StatelessWidget {
  const LibrarySubjectSheet({super.key, required this.subject});

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
                  child: _SheetHeader(subject: subject),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.separated(
                    itemCount: subject.works.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => WorkCard(
                      work: subject.works[index],
                      subjectEmoji: subject.emoji,
                      accentColor: subject.accentColor,
                    ),
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

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.subject});

  final ExploreSubject subject;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  '${subject.category} · ${formatCount(subject.workCount)} works on OpenAlex',
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: subject.accentColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              formatCount(subject.workCount),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: subject.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkCard extends StatelessWidget {
  const WorkCard({
    super.key,
    required this.work,
    required this.subjectEmoji,
    required this.accentColor,
  });

  final ExploreWork work;
  final String subjectEmoji;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WorkThumbnail(emoji: subjectEmoji, accentColor: accentColor),
          const SizedBox(width: 14),
          Expanded(
            child: _WorkInfo(
              work: work,
              accentColor: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkThumbnail extends StatelessWidget {
  const _WorkThumbnail({required this.emoji, required this.accentColor});

  final String emoji;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 92,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accentColor.withValues(alpha: 0.12),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

class _WorkInfo extends StatelessWidget {
  const _WorkInfo({required this.work, required this.accentColor});

  final ExploreWork work;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        if (work.sourceName != null && work.sourceName!.isNotEmpty) ...[
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
              WorkDetailPill(
                label: '${work.publicationYear}',
                accentColor: accentColor,
              ),
            if (work.citationCount > 0)
              WorkDetailPill(
                label: '${formatCount(work.citationCount)} citations',
                accentColor: accentColor,
              ),
            if (work.type != null && work.type!.isNotEmpty)
              WorkDetailPill(label: work.type!, accentColor: accentColor),
            if (work.isOpenAccess)
              WorkDetailPill(label: 'Open access', accentColor: accentColor),
          ],
        ),
      ],
    );
  }
}

class WorkDetailPill extends StatelessWidget {
  const WorkDetailPill({
    super.key,
    required this.label,
    required this.accentColor,
  });

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
