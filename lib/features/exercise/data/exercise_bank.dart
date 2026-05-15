import '../models/exercise.dart';

List<Exercise> buildExercises(LessonType lessonType) {
  switch (lessonType) {
    case LessonType.voice:
      return _buildVoiceExercises();
    case LessonType.school:
      return _buildSchoolExercises();
    case LessonType.continueLearning:
      return _buildGeneralExercises();
  }
}

List<Exercise> _buildVoiceExercises() {
  return [
    const Exercise(
      type: ExerciseType.speaking,
      question: 'Listen and repeat the following phrase:',
      content: 'The quick brown fox jumps over the lazy dog',
      hint: 'Focus on clear pronunciation of each word',
      correctAnswer: 'speech recognition',
    ),
    const Exercise(
      type: ExerciseType.multipleChoice,
      question: 'Which word has a different vowel sound?',
      options: ['cat', 'bat', 'cake', 'mat'],
      correctAnswer: 'cake',
      hint: 'Think about the "a" sound in each word',
    ),
    const Exercise(
      type: ExerciseType.matching,
      question: 'Match the words with their pronunciations:',
      pairs: [
        {'word': 'Through', 'pronunciation': 'θruː'},
        {'word': 'Thought', 'pronunciation': 'θɔːt'},
        {'word': 'Tough', 'pronunciation': 'tʌf'},
      ],
      hint: 'Listen carefully to each sound',
    ),
    const Exercise(
      type: ExerciseType.fillBlank,
      question: 'Complete the tongue twister:',
      content: 'She sells _____ shells by the seashore',
      correctAnswer: 'seashell',
      hint: 'It rhymes with "treasure"',
    ),
    const Exercise(
      type: ExerciseType.trueFalse,
      question:
          'True or False: The "th" sound is made with the tongue between the teeth',
      correctAnswer: 'true',
      hint: 'Think about how you position your tongue',
    ),
  ];
}

List<Exercise> _buildSchoolExercises() {
  return [
    const Exercise(
      type: ExerciseType.multipleChoice,
      question: 'What is the capital of France?',
      options: ['London', 'Berlin', 'Paris', 'Madrid'],
      correctAnswer: 'Paris',
      hint: 'It\'s known for the Eiffel Tower',
    ),
    const Exercise(
      type: ExerciseType.trueFalse,
      question: 'The mitochondria is the powerhouse of the cell',
      correctAnswer: 'true',
      hint: 'Think about cellular respiration',
    ),
    const Exercise(
      type: ExerciseType.fillBlank,
      question: 'Complete the equation: E = _____',
      content: 'E = _____',
      correctAnswer: 'mc²',
      hint: 'Einstein\'s famous equation',
    ),
    const Exercise(
      type: ExerciseType.writing,
      question: 'Explain the water cycle in 2-3 sentences:',
      hint: 'Include evaporation, condensation, and precipitation',
      correctAnswer: 'written response',
    ),
    const Exercise(
      type: ExerciseType.matching,
      question: 'Match the historical events with their dates:',
      pairs: [
        {'event': 'Moon Landing', 'date': '1969'},
        {'event': 'WWII Ended', 'date': '1945'},
        {'event': 'Berlin Wall Fell', 'date': '1989'},
      ],
      hint: 'Think about the timeline',
    ),
  ];
}

List<Exercise> _buildGeneralExercises() {
  return [
    const Exercise(
      type: ExerciseType.multipleChoice,
      question: 'What does the prefix "un-" mean?',
      options: ['Again', 'Not', 'Before', 'After'],
      correctAnswer: 'Not',
      hint: 'Think about words like "unable" or "unhappy"',
    ),
    const Exercise(
      type: ExerciseType.fillBlank,
      question: 'Choose the correct word:',
      content: 'Their/There/They\'re going to the park',
      correctAnswer: 'They\'re',
      hint: 'It\'s a contraction of "they are"',
    ),
    const Exercise(
      type: ExerciseType.trueFalse,
      question: 'A noun is a person, place, thing, or idea',
      correctAnswer: 'true',
      hint: 'This is the basic definition',
    ),
    const Exercise(
      type: ExerciseType.writing,
      question: 'Write a sentence using a metaphor:',
      hint: 'Compare two things without using "like" or "as"',
      correctAnswer: 'written response',
    ),
    const Exercise(
      type: ExerciseType.matching,
      question: 'Match the synonyms:',
      pairs: [
        {'word': 'Happy', 'synonym': 'Joyful'},
        {'word': 'Sad', 'synonym': 'Melancholy'},
        {'word': 'Angry', 'synonym': 'Furious'},
      ],
      hint: 'Find words with similar meanings',
    ),
  ];
}
