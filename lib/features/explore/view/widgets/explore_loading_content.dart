import 'package:flutter/material.dart';

import 'package:modern_learner_production/features/explore/view/widgets/explore_skeleton_box.dart';
import 'package:modern_learner_production/features/explore/view/widgets/explore_skeleton_list.dart';

class ExploreLoadingContent extends StatelessWidget {
  const ExploreLoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: ExploreSkeletonBox(height: 220, radius: 30),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          sliver: ExploreSkeletonList(),
        ),
      ],
    );
  }
}
