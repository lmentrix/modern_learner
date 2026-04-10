import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class LessonTopicCard extends StatefulWidget {
  const LessonTopicCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.accentColor,
    required this.category,
    required this.previewTitles,
    this.coverUrl,
    this.isPopular = false,
    this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String count;
  final Color accentColor;
  final String category;
  final List<String> previewTitles;
  final String? coverUrl;
  final bool isPopular;
  final VoidCallback? onTap;

  @override
  State<LessonTopicCard> createState() => _LessonTopicCardState();
}

class _LessonTopicCardState extends State<LessonTopicCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.985,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accentColor.withValues(alpha: 0.16),
                    AppColors.surfaceContainerLow,
                    AppColors.surfaceContainerLow,
                  ],
                  stops: const [0.0, 0.22, 1.0],
                ),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Pill(
                              label: widget.category.toUpperCase(),
                              foreground: widget.accentColor,
                              background: widget.accentColor.withValues(
                                alpha: 0.14,
                              ),
                            ),
                            if (widget.isPopular)
                              const _Pill(
                                label: 'TRENDING',
                                foreground: Color(0xFF1A1028),
                                background: Color(0xFFF8D66D),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.45,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        if (widget.previewTitles.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.previewTitles
                                .take(3)
                                .map(
                                  (title) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHighest
                                          .withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      title,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: widget.accentColor.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                widget.count,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: widget.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Open collection',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: widget.accentColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _CoverTile(
                    emoji: widget.emoji,
                    accentColor: widget.accentColor,
                    coverUrl: widget.coverUrl,
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

class _CoverTile extends StatelessWidget {
  const _CoverTile({
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
      width: 82,
      height: 116,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.55),
            accentColor.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: coverUrl == null
          ? Center(child: Text(emoji, style: const TextStyle(fontSize: 34)))
          : Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: coverUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: accentColor.withValues(alpha: 0.16),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: accentColor.withValues(alpha: 0.16),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.02),
                        Colors.black.withValues(alpha: 0.28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: foreground,
        ),
      ),
    );
  }
}
