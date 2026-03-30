import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/skill_node.dart';

class SkillNodeDetailSheet extends StatelessWidget {
  final SkillNode node;
  final VoidCallback onStart;
  final VoidCallback onClaim;
  final bool canClaim;

  const SkillNodeDetailSheet({
    super.key,
    required this.node,
    required this.onStart,
    required this.onClaim,
    required this.canClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge + XP reward
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TypeBadge(type: node.type),
                    Text(
                      '+${node.xpReward} XP',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Emoji + title + description
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(node.emoji, style: const TextStyle(fontSize: 36)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            node.title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            node.description,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick stats (duration + gems)
                if (node.duration != null) ...[
                  Row(
                    children: [
                      _QuickStat(
                        icon: Icons.timer_outlined,
                        label: _formatDuration(node.duration!),
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 16),
                      _QuickStat(
                        icon: Icons.diamond_outlined,
                        label: '+${node.rewards.where((r) => r.name == 'Gem').fold<int>(0, (s, r) => s + r.quantity)} gems',
                        color: AppColors.tertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: canClaim ? _ClaimButton(onTap: onClaim) : _StartButton(status: node.status, onTap: onStart),
                ),
              ],
            ),
          ),
          SafeArea(child: const SizedBox(height: 4)),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) return '${duration.inMinutes} min';
    return '${duration.inSeconds} sec';
  }
}

class _TypeBadge extends StatelessWidget {
  final SkillNodeType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      SkillNodeType.core => ('CORE', AppColors.primary),
      SkillNodeType.bonus => ('BONUS', AppColors.tertiary),
      SkillNodeType.challenge => ('CHALLENGE', AppColors.error),
      SkillNodeType.boss => ('BOSS', AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickStat({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  final SkillNodeStatus status;
  final VoidCallback onTap;

  const _StartButton({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      SkillNodeStatus.available => 'Start Lesson',
      SkillNodeStatus.inProgress => 'Continue',
      _ => 'Start',
    };

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text(label),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ClaimButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.tertiary,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉 ', style: TextStyle(fontSize: 18)),
          Text('Claim Rewards'),
        ],
      ),
    );
  }
}
