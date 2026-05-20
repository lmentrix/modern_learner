import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/service/model/roadmap_model.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_section_heading.dart';

class ProgressRoadmapResponseSection extends StatelessWidget {
  const ProgressRoadmapResponseSection({
    super.key,
    required this.courseLabel,
    required this.isLoading,
    required this.onRefresh,
    this.roadmap,
    this.response,
    this.errorMessage,
  });

  final String courseLabel;
  final RoadmapModel? roadmap;
  final RoadmapResponseModel? response;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final hasRoadmap = roadmap != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressSectionHeading(
          eyebrow: 'AI ROADMAP',
          title: hasRoadmap ? 'Generated response' : 'Roadmap generation',
          subtitle: hasRoadmap
              ? 'This is the structured roadmap returned by the API for this course.'
              : 'Generate the roadmap here, then the rest of the progress page will adapt to the returned chapters and lessons.',
        ),
        const SizedBox(height: 18),
        if (isLoading) _LoadingCard(courseLabel: courseLabel),
        if (errorMessage != null)
          Padding(
            padding: EdgeInsets.only(bottom: hasRoadmap ? 14 : 0),
            child: _StatusCard(
              icon: Icons.error_outline_rounded,
              iconColor: AppColors.error,
              title: hasRoadmap
                  ? 'Could not refresh the roadmap'
                  : 'Could not generate the roadmap',
              body: errorMessage!,
              actionLabel: 'Try again',
              onAction: onRefresh,
            ),
          ),
        if (hasRoadmap)
          _RoadmapCard(
            roadmap: roadmap!,
            response: response,
            isLoading: isLoading,
            onRefresh: onRefresh,
          )
        else if (!isLoading && errorMessage == null)
          _StatusCard(
            icon: Icons.auto_awesome_rounded,
            iconColor: AppColors.secondary,
            title: 'Ready to generate',
            body:
                'No roadmap response has been saved for this course yet. Generate one to populate the chapter sequence and objectives.',
            actionLabel: 'Generate roadmap',
            onAction: onRefresh,
          ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.courseLabel});

  final String courseLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generating roadmap',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Requesting a structured plan for $courseLabel.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
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

class _RoadmapCard extends StatelessWidget {
  const _RoadmapCard({
    required this.roadmap,
    required this.response,
    required this.isLoading,
    required this.onRefresh,
  });

  final RoadmapModel roadmap;
  final RoadmapResponseModel? response;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final objectives = roadmap.objectives.take(4).toList(growable: false);
    final metaChips = <String>[
      '${roadmap.chapters.length} chapters',
      '${roadmap.estimatedHours} hrs',
      roadmap.level,
      if ((response?.roadmapMode ?? '').isNotEmpty) response!.roadmapMode,
      if ((response?.model ?? '').isNotEmpty) response!.model,
      if (response?.mocked == true) 'mocked',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roadmap.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      roadmap.summary,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: isLoading ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(isLoading ? 'Refreshing' : 'Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: metaChips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      chip,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                )
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
          if (objectives.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Objectives',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: objectives
                  .map(
                    (objective) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 7),
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              objective,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetaStat(
                  label: 'Target language',
                  value: roadmap.targetLanguage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetaStat(
                  label: 'Topic',
                  value: roadmap.topic ?? 'Not provided',
                ),
              ),
            ],
          ),
          if ((response?.requestId ?? '').trim().isNotEmpty ||
              response?.usage != null) ...[
            const SizedBox(height: 12),
            Text(
              _buildFooter(response),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildFooter(RoadmapResponseModel? response) {
    final parts = <String>[
      if ((response?.requestId ?? '').trim().isNotEmpty)
        'Request: ${response!.requestId}',
      if (response?.usage?.totalTokens != null)
        'Tokens: ${response!.usage!.totalTokens}',
    ];

    return parts.join('  •  ');
  }
}

class _MetaStat extends StatelessWidget {
  const _MetaStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 12),
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
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
