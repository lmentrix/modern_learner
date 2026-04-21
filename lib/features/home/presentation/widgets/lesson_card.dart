import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.lessonType});
  final String lessonType;

  @override
  Widget build(BuildContext context) {
    final isLanguage = lessonType == 'language';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: (isLanguage ? AppColors.primary : AppColors.secondary)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: (isLanguage ? AppColors.primary : AppColors.secondary)
              .withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        isLanguage ? '🎤 Voice' : '📚 School',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isLanguage ? AppColors.primary : AppColors.secondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class LessonCard extends StatefulWidget {
  const LessonCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.chapter,
    required this.duration,
    required this.progress,
    required this.accentColor,
    this.isNew = false,
    this.lessonType,
    this.onTap,
    this.onLongPress,
  });

  final String emoji;
  final String title;
  final String chapter;
  final String duration;
  final double progress;
  final Color accentColor;
  final bool isNew;

  /// 'language' or 'school' — shows a type badge when set
  final String? lessonType;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _barCtrl;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _barCtrl.forward();
    });
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            splashColor: widget.accentColor.withValues(alpha: 0.06),
            highlightColor: widget.accentColor.withValues(alpha: 0.03),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Emoji icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                            if (widget.lessonType != null) ...[
                              _TypeBadge(lessonType: widget.lessonType!),
                              const SizedBox(width: 6),
                            ],
                            if (widget.isNew)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.tertiaryGradient,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'NEW',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF003320),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.chapter} · ${widget.duration}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Progress bar
                        AnimatedBuilder(
                          animation: _barAnim,
                          builder: (_, _) => Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: LinearProgressIndicator(
                                  value: widget.progress * _barAnim.value,
                                  minHeight: 5,
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.accentColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${(widget.progress * 100).round()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: widget.accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (widget.onLongPress != null)
                    Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                    )
                  else
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
