import 'package:flutter/material.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_course_xp_card_state.dart';

class ProfileCourseXpCard extends StatefulWidget {
  const ProfileCourseXpCard({
    required this.data,
    required this.color,
    super.key,
  });

  final ProfileCourseXpModel data;
  final Color color;

  @override
  State<ProfileCourseXpCard> createState() => ProfileCourseXpCardState();
}
