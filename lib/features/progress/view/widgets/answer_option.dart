import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class AnswerOption extends StatefulWidget {
  const AnswerOption({
    super.key,
    required this.label,
    required this.selected,
    required this.checked,
    required this.isCorrectAnswer,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool checked;
  final bool isCorrectAnswer;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final showCorrect = widget.checked && widget.isCorrectAnswer;
    final showWrong = widget.checked && widget.selected && !widget.isCorrectAnswer;
    final tone = showCorrect
        ? AppColors.tertiary
        : showWrong
        ? AppColors.error
        : widget.accentColor;
    final isActive = widget.selected || showCorrect || showWrong;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.985 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? tone.withValues(alpha: 0.12)
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? tone.withValues(alpha: 0.55)
                      : AppColors.outlineVariant.withValues(alpha: 0.14),
                  width: isActive ? 1.4 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: tone.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: isActive ? 0.18 : 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? tone.withValues(alpha: 0.45)
                            : AppColors.outlineVariant.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(
                      showCorrect
                          ? Icons.check_rounded
                          : showWrong
                          ? Icons.close_rounded
                          : widget.selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 16,
                      color: isActive ? tone : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        height: 1.35,
                      ),
                    ),
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
