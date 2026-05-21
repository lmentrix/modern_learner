import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_data.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';
import 'package:modern_learner_production/features/progress/service/model/chapter_subcontent_model.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_module_tile.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_section_heading.dart';

class ProgressJourneySection extends StatelessWidget {
  const ProgressJourneySection({
    super.key,
    required this.data,
    required this.onChapterTap,
    this.selectedChapterId,
    this.chapterSubcontentResponse,
    this.isLoadingChapterSubcontent = false,
    this.chapterSubcontentError,
    this.onRetryTap,
  });

  final ProgressPageData data;
  final ValueChanged<ProgressModuleStep> onChapterTap;
  final String? selectedChapterId;
  final ChapterSubcontentResponseModel? chapterSubcontentResponse;
  final bool isLoadingChapterSubcontent;
  final String? chapterSubcontentError;
  final VoidCallback? onRetryTap;

  @override
  Widget build(BuildContext context) {
    final selectedStep = data.moduleSteps
        .where((step) => step.id == selectedChapterId)
        .cast<ProgressModuleStep?>()
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProgressSectionHeading(
          eyebrow: 'ROADMAP',
          title: 'Where the next lift happens',
          subtitle:
              'Each chapter is sequenced to feel directional: what is done, what is active, and what unlocks next.',
          accentColor: AppColors.tertiary,
        ),
        const SizedBox(height: 18),
        Column(
          children: [
            for (int i = 0; i < data.moduleSteps.length; i++)
              ProgressModuleTile(
                step: data.moduleSteps[i],
                isSelected: data.moduleSteps[i].id == selectedChapterId,
                isLast: i == data.moduleSteps.length - 1,
                onTap: () => onChapterTap(data.moduleSteps[i]),
              ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _ChapterSubcontentPanel(
            key: ValueKey<String>(
              [
                selectedChapterId ?? 'idle',
                if (isLoadingChapterSubcontent) 'loading',
                if (chapterSubcontentError != null) 'error',
                chapterSubcontentResponse?.chapterSubcontent.id ?? 'empty',
              ].join('::'),
            ),
            selectedStep: selectedStep,
            response: chapterSubcontentResponse,
            isLoading: isLoadingChapterSubcontent,
            errorMessage: chapterSubcontentError,
            onRetryTap: onRetryTap,
          ),
        ),
      ],
    );
  }
}

class _ChapterSubcontentPanel extends StatelessWidget {
  const _ChapterSubcontentPanel({
    super.key,
    required this.selectedStep,
    required this.response,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetryTap,
  });

  final ProgressModuleStep? selectedStep;
  final ChapterSubcontentResponseModel? response;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetryTap;

  @override
  Widget build(BuildContext context) {
    if (selectedStep == null) {
      return const _PanelStatusCard(
        icon: Icons.touch_app_rounded,
        iconColor: AppColors.secondary,
        title: 'Tap a chapter to open the build',
        body:
            'Selecting a chapter generates the detailed subcontent blocks for that part of the roadmap and shows them here.',
      );
    }

    if (isLoading) {
      return _PanelStatusCard(
        icon: Icons.auto_awesome_rounded,
        iconColor: selectedStep!.toneColor,
        title: 'Building chapter ${selectedStep!.chapterNumber}',
        body:
            'Generating detailed subcontent for "${selectedStep!.title}" from the cached roadmap id.',
        showSpinner: true,
      );
    }

    if (errorMessage != null) {
      return _PanelStatusCard(
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
        title: 'Could not load chapter ${selectedStep!.chapterNumber}',
        body: errorMessage!,
        actionLabel: onRetryTap == null ? null : 'Try again',
        onAction: onRetryTap,
      );
    }

    final payload = response?.chapterSubcontent;
    if (payload == null) {
      return const _PanelStatusCard(
        icon: Icons.notes_rounded,
        iconColor: AppColors.tertiary,
        title: 'No chapter build returned',
        body:
            'The chapter was selected, but there is no subcontent payload to display yet.',
      );
    }

    final metaChips = <String>[
      'Chapter ${payload.chapterNumber}',
      '${payload.subcontents.length} study blocks',
      if ((payload.level ?? '').trim().isNotEmpty) payload.level!,
      if ((payload.targetLanguage ?? '').trim().isNotEmpty)
        payload.targetLanguage!,
      payload.courseType,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            selectedStep!.toneColor.withValues(alpha: 0.08),
            AppColors.surfaceContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: selectedStep!.toneColor.withValues(alpha: 0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: selectedStep!.toneColor.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chapter build',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            payload.chapterTitle,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            payload.overview,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.58,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: metaChips
                .map((c) => _MetaChip(c, color: selectedStep!.toneColor))
                .toList(),
          ),
          if ((response?.message ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              response!.message,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 22),
          Column(
            children: payload.subcontents
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _SubcontentCard(item: item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SubcontentCard extends StatelessWidget {
  const _SubcontentCard({required this.item});

  final ChapterSubcontentItemModel item;

  static Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'lesson':
        return AppColors.primary;
      case 'practice':
        return AppColors.secondary;
      case 'quiz':
      case 'review':
        return const Color(0xFFFF9500);
      case 'speaking':
        return const Color(0xFF26C6DA);
      default:
        return AppColors.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(item.subcontentType);
    final metaChips = <String>[
      'Block ${item.subcontentNumber}',
      _titleCase(item.subcontentType),
      '${item.estimatedMinutes} min',
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // colored type indicator line at top
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [typeColor, typeColor.withValues(alpha: 0.25)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: metaChips
                      .map((chip) => _MetaChip(chip, color: typeColor))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.summary,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
                if (item.focusSkills.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const _SectionLabel(label: 'Focus skills'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.focusSkills.map(_TagChip.new).toList(),
                  ),
                ],
                if (item.objectives.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const _SectionLabel(label: 'Objectives'),
                  const SizedBox(height: 8),
                  Column(
                    children: item.objectives
                        .map((objective) => _BulletLine(text: objective))
                        .toList(),
                  ),
                ],
                if (item.activities.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const _SectionLabel(label: 'Activities'),
                  const SizedBox(height: 8),
                  Column(
                    children: item.activities
                        .map((activity) => _BulletLine(text: activity))
                        .toList(),
                  ),
                ],
                if (item.sourceLessons.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const _SectionLabel(label: 'Source lessons'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.sourceLessons.map(_TagChip.new).toList(),
                  ),
                ],
                if ((item.teachingNote ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const _SectionLabel(label: 'Teaching note'),
                  const SizedBox(height: 6),
                  Text(
                    item.teachingNote!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
                if ((item.speakingFocus ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const _SectionLabel(label: 'Speaking focus'),
                  const SizedBox(height: 6),
                  Text(
                    item.speakingFocus!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
                if (item.audioCues.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const _SectionLabel(label: 'Audio cues'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.audioCues.map(_TagChip.new).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelStatusCard extends StatelessWidget {
  const _PanelStatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    this.showSpinner = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final bool showSpinner;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: iconColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // colored left accent stripe
            Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [iconColor, iconColor.withValues(alpha: 0.18)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // icon box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.20),
                        ),
                      ),
                      child: showSpinner
                          ? Padding(
                              padding: const EdgeInsets.all(11),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(iconColor),
                              ),
                            )
                          : Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            body,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          if (actionLabel != null && onAction != null) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: onAction,
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: Text(actionLabel!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.label, {this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c != null
            ? c.withValues(alpha: 0.12)
            : AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: c != null
            ? Border.all(color: c.withValues(alpha: 0.22))
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: c ?? AppColors.onSurface,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

String _titleCase(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return 'Untitled';
  }

  return trimmed
      .split('_')
      .expand((part) => part.split(' '))
      .where((part) => part.trim().isNotEmpty)
      .map((part) {
        final normalized = part.trim();
        return '${normalized[0].toUpperCase()}${normalized.substring(1).toLowerCase()}';
      })
      .join(' ');
}
