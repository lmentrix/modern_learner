import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/model/profile_moderl.dart';
import 'package:modern_learner_production/features/profile/service/profile_service.dart';

class ViewProfileSectionHeaderSection extends StatefulWidget {
  const ViewProfileSectionHeaderSection({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  State<ViewProfileSectionHeaderSection> createState() =>
      _ViewProfileSectionHeaderSectionState();
}

class _ViewProfileSectionHeaderSectionState
    extends State<ViewProfileSectionHeaderSection> {
  late final Future<ProfileModel?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getCurrentProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileModel?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final name = snapshot.data?.name ?? '';
        return Row(
          children: [
            Flexible(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: widget.onSeeAll,
              child: Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
