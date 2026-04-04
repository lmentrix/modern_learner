import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';

abstract final class VoiceLessonData {
  static const List<VoiceLessonEntity> lessons = [
    // ── Daily Greetings ───────────────────────────────────────────────────────
    VoiceLessonEntity(
      id: 'daily_greetings',
      title: 'Daily Greetings',
      subtitle: 'Essential phrases for every day',
      topic: 'Social English',
      duration: '15 min',
      accentColor: AppColors.primary,
      emoji: '👋',
      level: 'Beginner',
      phrases: [
        VoicePhrase(
          id: 'dg_1',
          text: 'Good morning!',
          phonetic: '/ɡʊd ˈmɔːrnɪŋ/',
          translation: 'Xin chào buổi sáng',
          tip: 'Used from sunrise until around noon. Very common in formal and informal settings.',
        ),
        VoicePhrase(
          id: 'dg_2',
          text: 'How are you?',
          phonetic: '/haʊ ɑːr juː/',
          translation: 'Bạn có khỏe không?',
          tip: 'A standard greeting. The expected reply is "Fine, thanks!" or "Pretty good!"',
        ),
        VoicePhrase(
          id: 'dg_3',
          text: 'Nice to meet you.',
          phonetic: '/naɪs tə miːt juː/',
          translation: 'Rất vui được gặp bạn',
          tip: 'Said when meeting someone for the first time. Often replied with "Nice to meet you too!"',
        ),
        VoicePhrase(
          id: 'dg_4',
          text: 'Have a great day!',
          phonetic: '/hæv ə ɡreɪt deɪ/',
          translation: 'Chúc bạn một ngày tốt lành!',
          tip: 'A warm, friendly farewell phrase used at any time of day.',
        ),
        VoicePhrase(
          id: 'dg_5',
          text: 'See you later!',
          phonetic: '/siː juː ˈleɪtər/',
          translation: 'Hẹn gặp lại!',
          tip: 'Informal farewell. Doesn\'t necessarily mean you\'ll see them later — it\'s just a friendly goodbye.',
        ),
      ],
      exercises: [
        VoiceExercise(
          id: 'dg_ex1',
          question: 'Which phrase do you use when meeting someone for the first time?',
          options: [
            'Have a great day!',
            'See you later!',
            'Nice to meet you.',
            'Good morning!',
          ],
          correctIndex: 2,
        ),
        VoiceExercise(
          id: 'dg_ex2',
          question: '"Good morning" is appropriate until approximately what time?',
          options: ['6 AM', 'Noon', '3 PM', 'Sunset'],
          correctIndex: 1,
        ),
        VoiceExercise(
          id: 'dg_ex3',
          question: 'What is the correct phonetic for "How are you?"',
          options: ['/haʊ ɑːr juː/', '/hɑː ɑːr jʊ/', '/haʊ eɪr juː/', '/hʌw ɑːr jʊ/'],
          correctIndex: 0,
        ),
      ],
    ),

    // ── At the Coffee Shop ────────────────────────────────────────────────────
    VoiceLessonEntity(
      id: 'coffee_shop',
      title: 'At the Coffee Shop',
      subtitle: 'Order like a native speaker',
      topic: 'Everyday Conversations',
      duration: '20 min',
      accentColor: Color(0xFFFF9500),
      emoji: '☕',
      level: 'Beginner',
      phrases: [
        VoicePhrase(
          id: 'cs_1',
          text: 'Can I get a latte, please?',
          phonetic: '/kæn aɪ ɡɛt ə ˈlɑːteɪ pliːz/',
          translation: 'Cho tôi một ly latte, làm ơn?',
          tip: '"Can I get…" is more casual than "May I have…" — both are perfectly polite in a café.',
        ),
        VoicePhrase(
          id: 'cs_2',
          text: 'What size would you like?',
          phonetic: '/wɒt saɪz wʊd juː laɪk/',
          translation: 'Bạn muốn cỡ nào?',
          tip: 'Common sizes are small, medium, and large. Some cafés use tall, grande, venti.',
        ),
        VoicePhrase(
          id: 'cs_3',
          text: 'Is that for here or to go?',
          phonetic: '/ɪz ðæt fər hɪər ɔːr tə ɡəʊ/',
          translation: 'Dùng tại chỗ hay mang về?',
          tip: '"To go" = takeaway in American English. In British English you\'d hear "takeaway".',
        ),
        VoicePhrase(
          id: 'cs_4',
          text: 'Keep the change.',
          phonetic: '/kiːp ðə tʃeɪndʒ/',
          translation: 'Bạn giữ tiền thừa đi.',
          tip: 'Said when tipping or when the change amount is small.',
        ),
        VoicePhrase(
          id: 'cs_5',
          text: 'Could I have the Wi-Fi password?',
          phonetic: '/kʊd aɪ hæv ðə ˈwaɪfaɪ ˈpæswɜːrd/',
          translation: 'Cho tôi xin mật khẩu Wi-Fi được không?',
          tip: '"Could I have…" is very polite. Using "please" at the end makes it even more courteous.',
        ),
      ],
      exercises: [
        VoiceExercise(
          id: 'cs_ex1',
          question: 'What does "to go" mean in a coffee shop context?',
          options: ['Drink in the café', 'Takeaway', 'A special drink', 'Leave quickly'],
          correctIndex: 1,
        ),
        VoiceExercise(
          id: 'cs_ex2',
          question: 'Which phrase is the most polite way to ask for something?',
          options: [
            'Give me a coffee.',
            'I want a latte.',
            'Could I have a latte, please?',
            'Get me a coffee.',
          ],
          correctIndex: 2,
        ),
        VoiceExercise(
          id: 'cs_ex3',
          question: '"Keep the change" means you are…',
          options: ['Asking for your change back', 'Giving a tip', 'Paying with a card', 'Returning coins'],
          correctIndex: 1,
        ),
      ],
    ),

    // ── Business Phrases ──────────────────────────────────────────────────────
    VoiceLessonEntity(
      id: 'business_phrases',
      title: 'Business Meeting Phrases',
      subtitle: 'Sound professional in meetings',
      topic: 'Professional English',
      duration: '25 min',
      accentColor: Color(0xFF00DC82),
      emoji: '💼',
      level: 'Intermediate',
      phrases: [
        VoicePhrase(
          id: 'bp_1',
          text: 'Let\'s get started, shall we?',
          phonetic: '/lɛts ɡɛt ˈstɑːrtɪd ʃæl wiː/',
          translation: 'Chúng ta bắt đầu nhé?',
          tip: 'A polite way to open a meeting. "Shall we?" is a common British English tag question.',
        ),
        VoicePhrase(
          id: 'bp_2',
          text: 'I\'d like to take this offline.',
          phonetic: '/aɪd laɪk tə teɪk ðɪs ˈɒflaɪn/',
          translation: 'Tôi muốn thảo luận riêng vấn đề này.',
          tip: '"Taking something offline" means discussing it privately, outside the meeting.',
        ),
        VoicePhrase(
          id: 'bp_3',
          text: 'Let\'s circle back to that point.',
          phonetic: '/lɛts ˈsɜːrkəl bæk tə ðæt pɔɪnt/',
          translation: 'Hãy quay lại vấn đề đó sau.',
          tip: 'Common business idiom meaning to return to a topic later.',
        ),
        VoicePhrase(
          id: 'bp_4',
          text: 'Could you elaborate on that?',
          phonetic: '/kʊd juː ɪˈlæbəreɪt ɒn ðæt/',
          translation: 'Bạn có thể giải thích rõ hơn không?',
          tip: 'A professional way to ask for more detail without sounding confused.',
        ),
        VoicePhrase(
          id: 'bp_5',
          text: 'I\'ll follow up with an email.',
          phonetic: '/aɪl ˈfɒləʊ ʌp wɪð ən ˈiːmeɪl/',
          translation: 'Tôi sẽ gửi email theo dõi sau.',
          tip: 'Shows professionalism — always follow through on commitments made in meetings.',
        ),
      ],
      exercises: [
        VoiceExercise(
          id: 'bp_ex1',
          question: 'What does "take this offline" mean in a business context?',
          options: [
            'Turn off the internet',
            'Discuss privately outside the meeting',
            'Send an email instead',
            'Skip the topic entirely',
          ],
          correctIndex: 1,
        ),
        VoiceExercise(
          id: 'bp_ex2',
          question: '"Could you elaborate on that?" is used when you want someone to…',
          options: ['Stop talking', 'Speak louder', 'Provide more detail', 'Summarise'],
          correctIndex: 2,
        ),
        VoiceExercise(
          id: 'bp_ex3',
          question: 'Which phrase best opens a professional meeting?',
          options: [
            'OK guys, let\'s go.',
            'Let\'s get started, shall we?',
            'Can we please begin?',
            'Start the meeting.',
          ],
          correctIndex: 1,
        ),
      ],
    ),
  ];

  static VoiceLessonEntity? findById(String id) {
    try {
      return lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
