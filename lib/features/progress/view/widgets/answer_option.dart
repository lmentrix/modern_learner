import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _AnswerOptionState extends State<AnswerOption>
    with TickerProviderStateMixin {
  // Spring bounce triggered on selection.
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  // Horizontal shake triggered on wrong reveal.
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  // Shimmer sweep triggered on correct reveal.
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    // Damped spring: expand → compress → small bounce → settle at 1.0.
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.07), weight: 18),
      TweenSequenceItem(tween: Tween(begin: 1.07, end: 0.95), weight: 22),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.03), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 0.98), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.98, end: 1.00), weight: 20),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.linear));

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -9.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -9.0, end: 9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 9.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _shimmerAnim = CurvedAnimation(
      parent: _shimmerCtrl,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(AnswerOption old) {
    super.didUpdateWidget(old);

    // Newly selected → spring bounce + light haptic.
    if (widget.selected && !old.selected && !widget.checked) {
      HapticFeedback.lightImpact();
      _bounceCtrl.forward(from: 0);
    }

    final nowCorrect = widget.checked && widget.isCorrectAnswer && widget.selected;
    final wasCorrect = old.checked && old.isCorrectAnswer && old.selected;
    if (nowCorrect && !wasCorrect) {
      HapticFeedback.mediumImpact();
      _shimmerCtrl.forward(from: 0);
    }

    final nowWrong = widget.checked && widget.selected && !widget.isCorrectAnswer;
    final wasWrong = old.checked && old.selected && !old.isCorrectAnswer;
    if (nowWrong && !wasWrong) {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _shakeCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showCorrect = widget.checked && widget.isCorrectAnswer;
    final showWrong   = widget.checked && widget.selected && !widget.isCorrectAnswer;
    final tone = showCorrect
        ? AppColors.tertiary
        : showWrong
        ? AppColors.error
        : widget.accentColor;
    final isActive = widget.selected || showCorrect || showWrong;

    return AnimatedBuilder(
      animation: Listenable.merge([_bounceCtrl, _shakeCtrl, _shimmerCtrl]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnim.value, 0),
          child: Transform.scale(
            scale: _bounceAnim.value * (_pressed ? 0.985 : 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.checked ? null : widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? tone.withValues(alpha: 0.11)
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? tone.withValues(alpha: 0.60)
                      : AppColors.outlineVariant.withValues(alpha: 0.14),
                  width: isActive ? 1.6 : 1.0,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: tone.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  // ── Content ─────────────────────────────────────────────
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: tone.withValues(alpha: isActive ? 0.20 : 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? tone.withValues(alpha: 0.50)
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
                          size: 15,
                          color: isActive ? tone : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ),
                      // Correct-answer star badge
                      if (showCorrect)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(Icons.auto_awesome_rounded, size: 14, color: tone),
                        ),
                    ],
                  ),
                  // ── Correct shimmer sweep ───────────────────────────────
                  // Positioned.fill keeps this out of Stack size computation,
                  // avoiding the unbounded-height layout assertion that occurs
                  // when FractionallySizedBox is a non-positioned Stack child.
                  if (showCorrect)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _shimmerAnim,
                        builder: (context, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _shimmerAnim.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.tertiary.withValues(alpha: 0.0),
                                        AppColors.tertiary.withValues(alpha: 0.18),
                                        AppColors.tertiary.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
