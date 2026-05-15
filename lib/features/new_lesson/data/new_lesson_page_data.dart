import 'package:modern_learner_production/features/new_lesson/data/new_lesson_option_item.dart';

abstract final class NewLessonPageData {
  static const languages = <NewLessonOptionItem>[
    NewLessonOptionItem(
      emoji: '🇺🇸',
      label: 'English',
      detail: 'Global speaking and listening',
    ),
    NewLessonOptionItem(
      emoji: '🇪🇸',
      label: 'Spanish',
      detail: 'Fast everyday conversation',
    ),
    NewLessonOptionItem(
      emoji: '🇫🇷',
      label: 'French',
      detail: 'Pronunciation and travel fluency',
    ),
    NewLessonOptionItem(
      emoji: '🇩🇪',
      label: 'German',
      detail: 'Structure, rhythm, and clarity',
    ),
    NewLessonOptionItem(
      emoji: '🇯🇵',
      label: 'Japanese',
      detail: 'Listening accuracy and response flow',
    ),
    NewLessonOptionItem(
      emoji: '🇨🇳',
      label: 'Mandarin',
      detail: 'Tone control and phrase recall',
    ),
    NewLessonOptionItem(
      emoji: '🇮🇹',
      label: 'Italian',
      detail: 'Melodic delivery and confidence',
    ),
    NewLessonOptionItem(
      emoji: '🇧🇷',
      label: 'Portuguese',
      detail: 'Warm speaking pace and dialogue',
    ),
  ];

  static const difficulties = <NewLessonOptionItem>[
    NewLessonOptionItem(
      emoji: '🌱',
      label: 'Beginner',
      detail: 'Core phrases and guided repetition',
    ),
    NewLessonOptionItem(
      emoji: '🔥',
      label: 'Intermediate',
      detail: 'Quicker recall and longer replies',
    ),
    NewLessonOptionItem(
      emoji: '🚀',
      label: 'Advanced',
      detail: 'Nuance, confidence, and real pace',
    ),
  ];
}
