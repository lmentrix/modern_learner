import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_activity_day.dart';
import 'package:modern_learner_production/features/profile/data/profile_contact_item.dart';
import 'package:modern_learner_production/features/profile/data/profile_faq_item.dart';
import 'package:modern_learner_production/features/profile/data/profile_option_item.dart';
import 'package:modern_learner_production/features/profile/data/profile_stat_item.dart';

abstract final class ProfilePageData {
  static const stats = <ProfileStatItem>[
    ProfileStatItem(
      icon: Icons.local_fire_department_rounded,
      label: 'Day Streak',
      value: '14',
      accentColor: Color(0xFFFF9500),
    ),
    ProfileStatItem(
      icon: Icons.star_rounded,
      label: 'Total XP',
      value: '2.4K',
      accentColor: AppColors.tertiaryContainer,
    ),
    ProfileStatItem(
      icon: Icons.check_circle_rounded,
      label: 'Completed',
      value: '47',
      accentColor: AppColors.primary,
    ),
  ];

  static const weekDays = <ProfileActivityDay>[
    ProfileActivityDay(label: 'M', minutes: 45),
    ProfileActivityDay(label: 'T', minutes: 62),
    ProfileActivityDay(label: 'W', minutes: 38),
    ProfileActivityDay(label: 'T', minutes: 55),
    ProfileActivityDay(label: 'F', minutes: 70),
    ProfileActivityDay(label: 'S', minutes: 25),
    ProfileActivityDay(label: 'S', minutes: 48),
  ];

  static const languages = <ProfileOptionItem>[
    ProfileOptionItem(emoji: '🇺🇸', label: 'English (US)'),
    ProfileOptionItem(emoji: '🇪🇸', label: 'Spanish'),
    ProfileOptionItem(emoji: '🇫🇷', label: 'French'),
    ProfileOptionItem(emoji: '🇩🇪', label: 'German'),
    ProfileOptionItem(emoji: '🇯🇵', label: 'Japanese'),
    ProfileOptionItem(emoji: '🇨🇳', label: 'Mandarin'),
    ProfileOptionItem(emoji: '🇮🇹', label: 'Italian'),
    ProfileOptionItem(emoji: '🇧🇷', label: 'Portuguese'),
  ];

  static const faqs = <ProfileFaqItem>[
    ProfileFaqItem(
      question: 'How is my profile saved?',
      answer:
          'Profile changes are stored on this device, so your name and preferences stay available the next time you open the app.',
    ),
    ProfileFaqItem(
      question: 'How does the streak system work?',
      answer:
          'Complete at least one lesson per day to maintain your streak. Missing a day resets it to zero unless you have a streak freeze.',
    ),
    ProfileFaqItem(
      question: 'Can I learn multiple languages at once?',
      answer:
          'Yes. Switch between language courses anytime from Explore. Progress for each course is stored separately.',
    ),
    ProfileFaqItem(
      question: 'How is XP calculated?',
      answer:
          'XP is based on lesson difficulty, accuracy, and speed. Harder challenge and boss lessons award more XP.',
    ),
  ];

  static const contacts = <ProfileContactItem>[
    ProfileContactItem(
      icon: Icons.email_outlined,
      label: 'Email Support',
      subtitle: 'support@modernlearner.app',
      color: Color(0xFFFF6B9D),
    ),
    ProfileContactItem(
      icon: Icons.star_outline_rounded,
      label: 'Rate the App',
      subtitle: 'Leave a review on the App Store',
      color: AppColors.tertiaryContainer,
    ),
  ];
}
