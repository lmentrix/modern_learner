import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isMe = user.isCurrentUser;
    final pct  = user.xp / maxXp;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? EduColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: EduRadius.borderMd,
        border: isMe
            ? Border.all(
                color: EduColors.primary.withValues(alpha: 0.22), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Rank in Caveat — feels like a hand-written number
          SizedBox(
            width: 28,
            child: Text(
              '#${user.rank}',
              style: GoogleFonts.caveat(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: user.rank <= 3
                    ? EduColors.primary
                    : EduColors.textSecondary,
              ),
            ),
          ),

          // Avatar — unchanged structure
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
              style: GoogleFonts.caveat(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: EduColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: EduSpacing.s3),

          // Name + progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? 'You' : user.name,
                  style: GoogleFonts.caveat(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
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

          // XP annotation in Caveat
          Text(
            '${user.xp} xp',
            style: GoogleFonts.caveat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isMe ? EduColors.primary : EduColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
