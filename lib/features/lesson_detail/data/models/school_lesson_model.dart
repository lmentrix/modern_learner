import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/school_lesson_entity.dart';

abstract final class SchoolLessonData {
  static const List<SchoolLessonEntity> lessons = [
    // ── Photosynthesis ────────────────────────────────────────────────────────
    SchoolLessonEntity(
      id: 'photosynthesis',
      title: 'Photosynthesis',
      subject: 'Biology',
      emoji: '🌱',
      color: Color(0xFF00DC82),
      duration: '25 min',
      difficulty: 'Intermediate',
      description:
          'Discover how plants convert sunlight into energy through the fascinating process of photosynthesis.',
      sections: [
        SchoolSection(
          id: 'intro',
          title: 'Introduction',
          icon: '📖',
          content:
              'Photosynthesis is the process by which green plants, algae, and some bacteria convert light energy into chemical energy stored as glucose. It is fundamental to life on Earth — producing the oxygen we breathe and forming the base of most food chains.',
          concepts: [
            SchoolConcept(
              term: 'Photosynthesis',
              definition:
                  'The process of converting light energy into chemical energy stored as glucose.',
              example: 'A leaf absorbing sunlight to produce sugar and oxygen.',
            ),
            SchoolConcept(
              term: 'Chloroplast',
              definition:
                  'The organelle in plant cells where photosynthesis takes place.',
              example: 'The green colour of leaves comes from chloroplasts.',
            ),
          ],
        ),
        SchoolSection(
          id: 'equation',
          title: 'The Chemical Equation',
          icon: '⚗️',
          content:
              'The overall equation for photosynthesis is:\n\n6CO₂ + 6H₂O + Light → C₆H₁₂O₆ + 6O₂\n\nSix molecules of carbon dioxide and six of water, powered by light, produce one glucose molecule and six oxygen molecules.',
          concepts: [
            SchoolConcept(
              term: 'Reactants',
              definition: 'CO₂ and H₂O are consumed as inputs.',
              example: 'Plants absorb CO₂ through stomata in their leaves.',
            ),
            SchoolConcept(
              term: 'Products',
              definition: 'Glucose and O₂ are released as outputs.',
              example: 'The oxygen released is what animals breathe.',
            ),
          ],
        ),
        SchoolSection(
          id: 'stages',
          title: 'Two Stages',
          icon: '🔄',
          content:
              'Photosynthesis occurs in two main stages:\n\n1. Light-Dependent Reactions — in the thylakoid membrane, use light to split water and produce ATP and NADPH.\n\n2. Calvin Cycle (Light-Independent) — in the stroma, use ATP and NADPH to fix CO₂ into glucose.',
          concepts: [
            SchoolConcept(
              term: 'Light Reactions',
              definition: 'Convert solar energy into chemical energy (ATP, NADPH).',
              example: 'Sunlight hits the leaf → splits water → releases O₂.',
            ),
            SchoolConcept(
              term: 'Calvin Cycle',
              definition: 'Uses ATP and NADPH to build glucose from CO₂.',
              example: 'Also called carbon fixation or the dark reactions.',
            ),
          ],
        ),
        SchoolSection(
          id: 'vocab',
          title: 'Key Vocabulary',
          icon: '📝',
          content: 'Master these essential terms to understand photosynthesis.',
          vocabulary: [
            VocabWord(
              word: 'Chlorophyll',
              definition: 'The green pigment that absorbs light energy.',
              partOfSpeech: 'noun',
            ),
            VocabWord(
              word: 'Stomata',
              definition: 'Tiny pores on leaves that allow gas exchange.',
              partOfSpeech: 'noun',
            ),
            VocabWord(
              word: 'Thylakoid',
              definition: 'Membrane-bound compartment inside chloroplasts.',
              partOfSpeech: 'noun',
            ),
            VocabWord(
              word: 'Stroma',
              definition: 'The fluid-filled space inside a chloroplast.',
              partOfSpeech: 'noun',
            ),
            VocabWord(
              word: 'ATP',
              definition: 'Adenosine triphosphate — the energy currency of cells.',
              partOfSpeech: 'noun',
            ),
            VocabWord(
              word: 'NADPH',
              definition: 'An electron carrier produced in the light reactions.',
              partOfSpeech: 'noun',
            ),
          ],
        ),
      ],
      quiz: [
        QuizQuestion(
          id: 'ps_q1',
          question: 'What is the main energy-storing product of photosynthesis?',
          options: ['Oxygen', 'Glucose', 'Carbon dioxide', 'Water'],
          correctIndex: 1,
          explanation:
              'Glucose (C₆H₁₂O₆) stores the chemical energy. Oxygen is a byproduct released into the atmosphere.',
        ),
        QuizQuestion(
          id: 'ps_q2',
          question: 'Where in the plant cell does photosynthesis occur?',
          options: ['Mitochondria', 'Nucleus', 'Chloroplast', 'Ribosome'],
          correctIndex: 2,
          explanation:
              'Photosynthesis occurs in the chloroplast — specifically the thylakoids and stroma.',
        ),
        QuizQuestion(
          id: 'ps_q3',
          question: 'Which gas do plants absorb during photosynthesis?',
          options: ['Oxygen (O₂)', 'Nitrogen (N₂)', 'Carbon Dioxide (CO₂)', 'Hydrogen (H₂)'],
          correctIndex: 2,
          explanation:
              'Plants absorb CO₂ through stomata. This carbon is fixed into glucose by the Calvin Cycle.',
        ),
        QuizQuestion(
          id: 'ps_q4',
          question: 'What provides the initial energy for photosynthesis?',
          options: ['Heat', 'Light', 'Glucose', 'ATP'],
          correctIndex: 1,
          explanation:
              'Light energy (from the sun) is captured by chlorophyll to drive the light-dependent reactions.',
        ),
        QuizQuestion(
          id: 'ps_q5',
          question: 'What happens during the Calvin Cycle?',
          options: [
            'Water is split and oxygen is released',
            'CO₂ is fixed into glucose',
            'ATP is broken down into ADP',
            'Chlorophyll absorbs photons',
          ],
          correctIndex: 1,
          explanation:
              'The Calvin Cycle uses ATP and NADPH to fix CO₂ into glucose in the stroma.',
        ),
      ],
    ),

    // ── The Water Cycle ───────────────────────────────────────────────────────
    SchoolLessonEntity(
      id: 'water_cycle',
      title: 'The Water Cycle',
      subject: 'Geography',
      emoji: '💧',
      color: Color(0xFF4FC3F7),
      duration: '20 min',
      difficulty: 'Beginner',
      description:
          'Explore how water continuously moves through Earth\'s environment in an endless, life-sustaining cycle.',
      sections: [
        SchoolSection(
          id: 'wc_intro',
          title: 'Introduction',
          icon: '📖',
          content:
              'The water cycle (hydrological cycle) describes the continuous movement of water within Earth and its atmosphere. It involves evaporation, condensation, precipitation, and collection — recycling the same water molecules over and over.',
          concepts: [
            SchoolConcept(
              term: 'Hydrological Cycle',
              definition: 'The continuous movement of water through land, ocean, and atmosphere.',
              example: 'Rain falls → flows to rivers → evaporates → forms clouds → rains again.',
            ),
          ],
        ),
        SchoolSection(
          id: 'wc_stages',
          title: 'Key Stages',
          icon: '🔄',
          content:
              'The four main stages are:\n\n1. Evaporation — water from oceans and lakes turns into vapour.\n2. Condensation — vapour cools and forms clouds.\n3. Precipitation — water falls as rain, snow, or hail.\n4. Collection — water gathers in rivers, lakes, and groundwater.',
          concepts: [
            SchoolConcept(
              term: 'Evaporation',
              definition: 'Liquid water becomes water vapour due to heat.',
              example: 'Puddles disappearing on a sunny day.',
            ),
            SchoolConcept(
              term: 'Condensation',
              definition: 'Water vapour cools and returns to liquid form.',
              example: 'Clouds forming high in the atmosphere.',
            ),
            SchoolConcept(
              term: 'Precipitation',
              definition: 'Water falling from clouds in any form.',
              example: 'Rain, snow, sleet, or hail.',
            ),
            SchoolConcept(
              term: 'Transpiration',
              definition: 'Water released by plants into the atmosphere.',
              example: 'Forests releasing moisture on warm days.',
            ),
          ],
        ),
        SchoolSection(
          id: 'wc_vocab',
          title: 'Key Vocabulary',
          icon: '📝',
          content: 'Learn the terminology used to describe the water cycle.',
          vocabulary: [
            VocabWord(
              word: 'Evaporation',
              definition: 'Conversion of liquid water to water vapour.',
              partOfSpeech: 'noun',
            ),
            VocabWord(
              word: 'Condensation',
              definition: 'Conversion of water vapour to liquid water.',
              partOfSpeech: 'noun',
            ),
            VocabWord(
              word: 'Precipitation',
              definition: 'Any form of water falling from the atmosphere.',
              partOfSpeech: 'noun',
            ),
            VocabWord(
              word: 'Aquifer',
              definition: 'Underground layer of rock that holds water.',
              partOfSpeech: 'noun',
            ),
            VocabWord(
              word: 'Runoff',
              definition: 'Water that flows over land into streams and rivers.',
              partOfSpeech: 'noun',
            ),
          ],
        ),
      ],
      quiz: [
        QuizQuestion(
          id: 'wc_q1',
          question: 'What process turns liquid water into water vapour?',
          options: ['Condensation', 'Precipitation', 'Evaporation', 'Transpiration'],
          correctIndex: 2,
          explanation:
              'Evaporation is driven by solar heat, converting surface water into atmospheric water vapour.',
        ),
        QuizQuestion(
          id: 'wc_q2',
          question: 'What forms when water vapour cools in the atmosphere?',
          options: ['Rain', 'Clouds', 'Ice', 'Rivers'],
          correctIndex: 1,
          explanation:
              'Water vapour condenses around tiny dust particles to form clouds (condensation nuclei).',
        ),
        QuizQuestion(
          id: 'wc_q3',
          question: 'Which stage involves water falling from the sky?',
          options: ['Evaporation', 'Collection', 'Condensation', 'Precipitation'],
          correctIndex: 3,
          explanation:
              'Precipitation includes all forms of water falling from clouds — rain, snow, sleet, or hail.',
        ),
        QuizQuestion(
          id: 'wc_q4',
          question: 'What is the release of water vapour by plants called?',
          options: ['Evaporation', 'Transpiration', 'Condensation', 'Runoff'],
          correctIndex: 1,
          explanation:
              'Transpiration is the process where plants release water vapour through their leaves.',
        ),
      ],
    ),

    // ── Quadratic Equations ───────────────────────────────────────────────────
    SchoolLessonEntity(
      id: 'quadratic_equations',
      title: 'Quadratic Equations',
      subject: 'Mathematics',
      emoji: '📐',
      color: AppColors.secondary,
      duration: '30 min',
      difficulty: 'Intermediate',
      description:
          'Learn how to solve quadratic equations using factoring, completing the square, and the quadratic formula.',
      sections: [
        SchoolSection(
          id: 'qe_intro',
          title: 'What is a Quadratic?',
          icon: '📖',
          content:
              'A quadratic equation has the standard form ax² + bx + c = 0, where a ≠ 0. The highest power of x is 2. Quadratics appear everywhere — from projectile motion to engineering design.',
          concepts: [
            SchoolConcept(
              term: 'Quadratic Equation',
              definition: 'An equation of the form ax² + bx + c = 0.',
              example: 'x² - 5x + 6 = 0',
            ),
            SchoolConcept(
              term: 'Roots / Solutions',
              definition: 'The values of x that satisfy the equation.',
              example: 'For x² - 5x + 6 = 0, the roots are x = 2 and x = 3.',
            ),
          ],
        ),
        SchoolSection(
          id: 'qe_methods',
          title: 'Solving Methods',
          icon: '🔧',
          content:
              '1. Factoring — rewrite ax² + bx + c as (x - p)(x - q) = 0.\n\n2. Completing the Square — rearrange to (x + h)² = k form.\n\n3. Quadratic Formula — x = (-b ± √(b² - 4ac)) / 2a.',
          concepts: [
            SchoolConcept(
              term: 'Discriminant',
              definition: 'b² - 4ac tells you how many real roots exist.',
              example: 'If b² - 4ac > 0: two roots. = 0: one root. < 0: no real roots.',
            ),
            SchoolConcept(
              term: 'Quadratic Formula',
              definition: 'x = (-b ± √(b² - 4ac)) / 2a — solves any quadratic.',
              example: 'For x² - 5x + 6 = 0: x = (5 ± √1) / 2 → x = 3 or x = 2.',
            ),
          ],
        ),
        SchoolSection(
          id: 'qe_vocab',
          title: 'Key Vocabulary',
          icon: '📝',
          content: 'Terms you must know for quadratic equations.',
          vocabulary: [
            VocabWord(word: 'Coefficient', definition: 'A numerical factor in an algebraic term.', partOfSpeech: 'noun'),
            VocabWord(word: 'Discriminant', definition: 'b² - 4ac; determines the nature of roots.', partOfSpeech: 'noun'),
            VocabWord(word: 'Parabola', definition: 'The U-shaped curve graph of a quadratic function.', partOfSpeech: 'noun'),
            VocabWord(word: 'Vertex', definition: 'The highest or lowest point of a parabola.', partOfSpeech: 'noun'),
            VocabWord(word: 'Axis of Symmetry', definition: 'The vertical line through the vertex of a parabola.', partOfSpeech: 'noun'),
          ],
        ),
      ],
      quiz: [
        QuizQuestion(
          id: 'qe_q1',
          question: 'What is the standard form of a quadratic equation?',
          options: ['ax + b = 0', 'ax² + bx + c = 0', 'ax³ + b = 0', 'a/x + b = 0'],
          correctIndex: 1,
          explanation: 'The standard form is ax² + bx + c = 0 where a ≠ 0.',
        ),
        QuizQuestion(
          id: 'qe_q2',
          question: 'If the discriminant (b² - 4ac) equals zero, how many real roots exist?',
          options: ['None', 'One', 'Two', 'Infinite'],
          correctIndex: 1,
          explanation: 'A discriminant of zero means the equation has exactly one repeated real root.',
        ),
        QuizQuestion(
          id: 'qe_q3',
          question: 'What are the roots of x² - 5x + 6 = 0?',
          options: ['x = 1 and x = 6', 'x = -2 and x = -3', 'x = 2 and x = 3', 'x = 5 and x = 1'],
          correctIndex: 2,
          explanation: 'Factoring: (x - 2)(x - 3) = 0, so x = 2 or x = 3.',
        ),
      ],
    ),
  ];

  static SchoolLessonEntity? findById(String id) {
    try {
      return lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
