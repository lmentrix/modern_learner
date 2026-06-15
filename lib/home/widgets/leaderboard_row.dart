import 'package:flutter/material.dart';
import 'package:modern_learner_production/home/model/home_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.user,
    required this.maxXp,
  });

  final LeaderboardUser user;
  final int maxXp;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isMe = user.isCurrentUser;
    final pct = user.xp / maxXp;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? EduColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: EduRadius.borderMd,
        border: isMe
            ? Border.all(color: EduColors.primary.withValues(alpha: 0.22), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 24,
            child: Text(
              '#${user.rank}',
              style: tt.labelLarge?.copyWith(
                color: user.rank <= 3 ? EduColors.primary : EduColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: EduSpacing.s2),

          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(user.avatarColor),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              user.initials,
              style: tt.labelLarge?.copyWith(
                color: EduColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: EduSpacing.s3),

          // Name + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? 'You' : user.name,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                    color: isMe ? EduColors.primary : EduColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: EduRadius.borderPill,
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4,
                    backgroundColor: EduColors.border,
                    valueColor: AlwaysStoppedAnimation(
                      isMe ? EduColors.primary : Color(user.avatarColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: EduSpacing.s3),

          // XP
          Text(
            '${user.xp} xp',
            style: tt.labelLarge?.copyWith(
              color: isMe ? EduColors.primary : EduColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
