import 'dart:async';
import 'dart:math';

import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final _progressController = StreamController<UserProgress>.broadcast();

  UserProgress _userProgress = const UserProgress(
    totalXp: 0,
    level: 1,
    gems: 0,
    streak: 0,
    completedLessons: {},
    lessonProgress: {},
    completedChapters: {},
    unlockedAchievements: [],
    currentRoadmapId: 'roadmap_js_async',
  );

  @override
  Future<Roadmap> getRoadmap() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _getJavaScriptAsyncRoadmap();
  }

  @override
  Future<UserProgress> getUserProgress() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _userProgress;
  }

  @override
  Future<void> startLesson(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _userProgress = _userProgress.copyWith(
      lessonProgress: {
        ..._userProgress.lessonProgress,
        lessonId: 0.1,
      },
    );
    _progressController.add(_userProgress);
  }

  @override
  Future<void> completeLesson(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final random = Random();
    final gemsEarned = random.nextInt(10) + 5;

    _userProgress = _userProgress.copyWith(
      totalXp: _userProgress.totalXp + 100,
      level: (_userProgress.totalXp + 100) ~/ 500 + 1,
      gems: _userProgress.gems + gemsEarned,
      completedLessons: {
        ..._userProgress.completedLessons,
        lessonId: DateTime.now(),
      },
      lessonProgress: {
        ..._userProgress.lessonProgress..remove(lessonId),
      },
    );
    _progressController.add(_userProgress);
  }

  @override
  Future<void> updateLessonProgress(String lessonId, double progress) async {
    _userProgress = _userProgress.copyWith(
      lessonProgress: {
        ..._userProgress.lessonProgress,
        lessonId: progress,
      },
    );
    _progressController.add(_userProgress);
  }

  @override
  Stream<UserProgress> getProgressStream() => _progressController.stream;

  Roadmap _getJavaScriptAsyncRoadmap() {
    final chapters = [
      const Chapter(
        id: 'chapter_1',
        chapterNumber: 1,
        title: 'Introduction to JS Syntax',
        description: 'Learn the building blocks of JavaScript to prepare for data handling.',
        icon: '📝',
        type: ChapterType.lesson,
        xpReward: 100,
        gemReward: 10,
        prerequisites: [],
        skills: ['Variables declaration', 'Basic data types', 'Console logging', 'Expression evaluation'],
        lessons: [
          Lesson(id: 'ch1_lesson1', title: 'Variables basics', type: LessonType.vocabulary, description: 'Defining const and let keywords.', xpReward: 25, status: LessonStatus.completed),
          Lesson(id: 'ch1_lesson2', title: 'Data types', type: LessonType.grammar, description: 'Strings, numbers, and booleans.', xpReward: 25, status: LessonStatus.completed),
          Lesson(id: 'ch1_lesson3', title: 'Console practice', type: LessonType.exercise, description: 'Writing your first script.', xpReward: 50, status: LessonStatus.inProgress),
        ],
      ),
      const Chapter(
        id: 'chapter_2',
        chapterNumber: 2,
        title: 'Functions and Flow',
        description: 'Learn how small code blocks form the logic of asynchronous tasks.',
        icon: '🏗️',
        type: ChapterType.lesson,
        xpReward: 120,
        gemReward: 12,
        prerequisites: ['chapter_1'],
        skills: ['Function definitions', 'Return statements', 'Parameter passing', 'Scope rules'],
        lessons: [
          Lesson(id: 'ch2_lesson1', title: 'Defining functions', type: LessonType.vocabulary, description: 'The function keyword syntax.', xpReward: 30, status: LessonStatus.locked),
          Lesson(id: 'ch2_lesson2', title: 'Parameters', type: LessonType.grammar, description: 'Passing data into functions.', xpReward: 40, status: LessonStatus.locked),
          Lesson(id: 'ch2_lesson3', title: 'Logic flow', type: LessonType.listening, description: 'Ordering tasks for execution.', xpReward: 50, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_3',
        chapterNumber: 3,
        title: 'Data Structures in Async',
        description: 'Master arrays and objects to manage structured API data.',
        icon: '📦',
        type: ChapterType.lesson,
        xpReward: 140,
        gemReward: 14,
        prerequisites: ['chapter_2'],
        skills: ['Array methods', 'Object properties', 'JSON notation', 'Deep accessing'],
        lessons: [
          Lesson(id: 'ch3_lesson1', title: 'Arrays and loops', type: LessonType.exercise, description: 'Iterating over datasets.', xpReward: 50, status: LessonStatus.locked),
          Lesson(id: 'ch3_lesson2', title: 'Object keys', type: LessonType.grammar, description: 'Accessing nested object data.', xpReward: 40, status: LessonStatus.locked),
          Lesson(id: 'ch3_lesson3', title: 'JSON parsing', type: LessonType.reading, description: 'Understanding protocol data formats.', xpReward: 50, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_4',
        chapterNumber: 4,
        title: 'Events and Callbacks',
        description: 'Understand the browser event loop foundation.',
        icon: '🔔',
        type: ChapterType.lesson,
        xpReward: 160,
        gemReward: 16,
        prerequisites: ['chapter_3'],
        skills: ['Event listeners', 'Button clicks', 'Callback parameters', 'Execution timing'],
        lessons: [
          Lesson(id: 'ch4_lesson1', title: 'Event listeners', type: LessonType.conversation, description: 'Handling user interaction.', xpReward: 60, status: LessonStatus.locked),
          Lesson(id: 'ch4_lesson2', title: 'Callback concept', type: LessonType.grammar, description: 'Passing functions as arguments.', xpReward: 50, status: LessonStatus.locked),
          Lesson(id: 'ch4_lesson3', title: 'Order of operations', type: LessonType.exercise, description: 'Debugging timing issues.', xpReward: 50, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_5',
        chapterNumber: 5,
        title: 'Checkpoint: The Foundation',
        description: 'Reviewing core functions, variables, and early event basics.',
        icon: '🚩',
        type: ChapterType.checkpoint,
        xpReward: 270,
        gemReward: 25,
        prerequisites: ['chapter_4'],
        skills: ['Scope review', 'Callback pattern identification', 'Variable reassignment logic'],
        lessons: [
          Lesson(id: 'ch5_lesson1', title: 'Knowledge check 1', type: LessonType.exercise, description: 'Recap quiz on syntax.', xpReward: 90, status: LessonStatus.locked),
          Lesson(id: 'ch5_lesson2', title: 'Logic flow test', type: LessonType.exercise, description: 'Predicting output of functions.', xpReward: 90, status: LessonStatus.locked),
          Lesson(id: 'ch5_lesson3', title: 'Callback review', type: LessonType.reading, description: 'Case study of early callback patterns.', xpReward: 90, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_6',
        chapterNumber: 6,
        title: 'Timer Functions',
        description: 'Using setTimeout and setInterval for paced executions.',
        icon: '⏱️',
        type: ChapterType.lesson,
        xpReward: 200,
        gemReward: 20,
        prerequisites: ['chapter_5'],
        skills: ['setTimeout logic', 'setInterval timing', 'Cancelling timers', 'Delay execution'],
        lessons: [
          Lesson(id: 'ch6_lesson1', title: 'SetTimeout calls', type: LessonType.grammar, description: 'Non-blocking delays.', xpReward: 70, status: LessonStatus.locked),
          Lesson(id: 'ch6_lesson2', title: 'Managing intervals', type: LessonType.exercise, description: 'Looping with breaks.', xpReward: 70, status: LessonStatus.locked),
          Lesson(id: 'ch6_lesson3', title: 'Delay logic', type: LessonType.conversation, description: 'Dialogue on sync vs async.', xpReward: 60, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_7',
        chapterNumber: 7,
        title: 'Synchronous Callbacks',
        description: 'Differentiating between blocking and non-blocking arrays.',
        icon: '🔄',
        type: ChapterType.lesson,
        xpReward: 220,
        gemReward: 22,
        prerequisites: ['chapter_6'],
        skills: ['Array.forEach', 'Array.map', 'Higher-order logic', 'Function mutation'],
        lessons: [
          Lesson(id: 'ch7_lesson1', title: 'forEach logic', type: LessonType.reading, description: 'Functional iteration.', xpReward: 70, status: LessonStatus.locked),
          Lesson(id: 'ch7_lesson2', title: 'Mapping arrays', type: LessonType.exercise, description: 'Transforming datasets.', xpReward: 80, status: LessonStatus.locked),
          Lesson(id: 'ch7_lesson3', title: 'Functional purity', type: LessonType.grammar, description: 'Avoiding global state mutation.', xpReward: 70, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_8',
        chapterNumber: 8,
        title: 'Error Handling Basics',
        description: 'Preventing crashes during asynchronous callbacks.',
        icon: '🛡️',
        type: ChapterType.lesson,
        xpReward: 240,
        gemReward: 24,
        prerequisites: ['chapter_7'],
        skills: ['Try-catch blocks', 'Error throwing', 'Debugging callbacks', 'Validation'],
        lessons: [
          Lesson(id: 'ch8_lesson1', title: 'Try Catch', type: LessonType.grammar, description: 'Safe execution blocks.', xpReward: 80, status: LessonStatus.locked),
          Lesson(id: 'ch8_lesson2', title: 'Throwing errors', type: LessonType.vocabulary, description: 'Creating custom exceptions.', xpReward: 80, status: LessonStatus.locked),
          Lesson(id: 'ch8_lesson3', title: 'Fail-safe strategies', type: LessonType.exercise, description: 'Handling runtime issues.', xpReward: 80, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_9',
        chapterNumber: 9,
        title: 'XMLHttp Request (Legacy)',
        description: 'Understanding the origins of web requests.',
        icon: '🌐',
        type: ChapterType.lesson,
        xpReward: 260,
        gemReward: 26,
        prerequisites: ['chapter_8'],
        skills: ['Making XHR requests', 'Handling readyState', 'Parsing responses', 'Network simulation'],
        lessons: [
          Lesson(id: 'ch9_lesson1', title: 'XHR introduction', type: LessonType.vocabulary, description: 'Old-school web requests.', xpReward: 90, status: LessonStatus.locked),
          Lesson(id: 'ch9_lesson2', title: 'States and phases', type: LessonType.reading, description: 'Reading network life-cycle.', xpReward: 90, status: LessonStatus.locked),
          Lesson(id: 'ch9_lesson3', title: 'API calls', type: LessonType.exercise, description: 'Fetching remote text.', xpReward: 80, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_10',
        chapterNumber: 10,
        title: 'Checkpoint: Managing Delays',
        description: 'Consolidating timers, XHR, and functional callback skills.',
        icon: '🚦',
        type: ChapterType.checkpoint,
        xpReward: 435,
        gemReward: 40,
        prerequisites: ['chapter_9'],
        skills: ['Timer logic integration', 'XHR state lifecycle', 'Callback error handling'],
        lessons: [
          Lesson(id: 'ch10_lesson1', title: 'Flow quiz', type: LessonType.exercise, description: 'Reviewing async execution order.', xpReward: 145, status: LessonStatus.locked),
          Lesson(id: 'ch10_lesson2', title: 'Network review', type: LessonType.reading, description: 'Common networking pitfalls.', xpReward: 145, status: LessonStatus.locked),
          Lesson(id: 'ch10_lesson3', title: 'Debugging scenario', type: LessonType.exercise, description: 'Practical debugging test.', xpReward: 145, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_11',
        chapterNumber: 11,
        title: 'Promises Pattern',
        description: 'Transitioning from callbacks to modern Promise control.',
        icon: '🤝',
        type: ChapterType.lesson,
        xpReward: 300,
        gemReward: 30,
        prerequisites: ['chapter_10'],
        skills: ['Promise construction', 'Pending/Resolved/Rejected states', 'Chaining then()', 'Returning values'],
        lessons: [
          Lesson(id: 'ch11_lesson1', title: 'Promise constructor', type: LessonType.grammar, description: 'The logic of resolve/reject.', xpReward: 100, status: LessonStatus.locked),
          Lesson(id: 'ch11_lesson2', title: 'Thenable chains', type: LessonType.vocabulary, description: 'Chaining sequential tasks.', xpReward: 100, status: LessonStatus.locked),
          Lesson(id: 'ch11_lesson3', title: 'State transitions', type: LessonType.listening, description: 'How a Promise settles.', xpReward: 100, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_12',
        chapterNumber: 12,
        title: 'Chaining Promises',
        description: 'Executing sequential asynchronous flows without nesting.',
        icon: '🔗',
        type: ChapterType.lesson,
        xpReward: 320,
        gemReward: 32,
        prerequisites: ['chapter_11'],
        skills: ['Sequential execution', 'Promise batching', 'Flattening code', 'Avoiding pyramid of doom'],
        lessons: [
          Lesson(id: 'ch12_lesson1', title: 'Chaining flow', type: LessonType.grammar, description: 'The power of return.', xpReward: 110, status: LessonStatus.locked),
          Lesson(id: 'ch12_lesson2', title: 'Promise.all', type: LessonType.vocabulary, description: 'Concurrent execution.', xpReward: 110, status: LessonStatus.locked),
          Lesson(id: 'ch12_lesson3', title: 'Error bubbling', type: LessonType.reading, description: 'Catching sequence errors.', xpReward: 100, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_13',
        chapterNumber: 13,
        title: 'Fetch API',
        description: 'Modern data fetching with the Fetch protocol.',
        icon: '📥',
        type: ChapterType.lesson,
        xpReward: 340,
        gemReward: 34,
        prerequisites: ['chapter_12'],
        skills: ['Calling fetch', 'Response status handling', 'JSON headers', 'Request configuration'],
        lessons: [
          Lesson(id: 'ch13_lesson1', title: 'Fetch basics', type: LessonType.vocabulary, description: 'Request GET method.', xpReward: 120, status: LessonStatus.locked),
          Lesson(id: 'ch13_lesson2', title: 'Handling responses', type: LessonType.grammar, description: 'Parsing data stream.', xpReward: 110, status: LessonStatus.locked),
          Lesson(id: 'ch13_lesson3', title: 'Network errors', type: LessonType.exercise, description: '404 and connection errors.', xpReward: 110, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_14',
        chapterNumber: 14,
        title: 'Advanced Error Chains',
        description: 'Robust error handling using .catch() and .finally().',
        icon: '🚨',
        type: ChapterType.lesson,
        xpReward: 360,
        gemReward: 36,
        prerequisites: ['chapter_13'],
        skills: ['Catching reject', 'Finally blocks', 'Propagating errors', 'Global error logging'],
        lessons: [
          Lesson(id: 'ch14_lesson1', title: 'Catching failures', type: LessonType.grammar, description: 'Recovering from rejections.', xpReward: 120, status: LessonStatus.locked),
          Lesson(id: 'ch14_lesson2', title: 'Finally block', type: LessonType.vocabulary, description: 'Guaranteed cleanup task.', xpReward: 120, status: LessonStatus.locked),
          Lesson(id: 'ch14_lesson3', title: 'Debug session', type: LessonType.listening, description: 'Identifying silent errors.', xpReward: 120, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_15',
        chapterNumber: 15,
        title: 'Checkpoint: Promise Mastery',
        description: 'Consolidating promise chains, Fetch API, and catch-blocks.',
        icon: '⭐',
        type: ChapterType.checkpoint,
        xpReward: 570,
        gemReward: 50,
        prerequisites: ['chapter_14'],
        skills: ['Promise sequence design', 'Fetch lifecycle management', 'Robust catch strategy'],
        lessons: [
          Lesson(id: 'ch15_lesson1', title: 'Chaining test', type: LessonType.exercise, description: 'Refactor nested code.', xpReward: 190, status: LessonStatus.locked),
          Lesson(id: 'ch15_lesson2', title: 'API simulator', type: LessonType.exercise, description: 'Building a mock API call.', xpReward: 190, status: LessonStatus.locked),
          Lesson(id: 'ch15_lesson3', title: 'Promise logic', type: LessonType.reading, description: 'Advanced flow control theory.', xpReward: 190, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_16',
        chapterNumber: 16,
        title: 'Async/Await Syntax',
        description: 'Writing asynchronous code that looks synchronous.',
        icon: '✨',
        type: ChapterType.lesson,
        xpReward: 400,
        gemReward: 40,
        prerequisites: ['chapter_15'],
        skills: ['Async keyword', 'Await keyword', 'Syntactic sugar', 'Modern refactoring'],
        lessons: [
          Lesson(id: 'ch16_lesson1', title: 'Async functions', type: LessonType.vocabulary, description: 'Implicit promises.', xpReward: 140, status: LessonStatus.locked),
          Lesson(id: 'ch16_lesson2', title: 'Using await', type: LessonType.grammar, description: 'Pausing execution naturally.', xpReward: 130, status: LessonStatus.locked),
          Lesson(id: 'ch16_lesson3', title: 'Refactoring chains', type: LessonType.exercise, description: 'Cleaning up .then chains.', xpReward: 130, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_17',
        chapterNumber: 17,
        title: 'Async Error Patterns',
        description: 'Managing errors inside modern async/await workflows.',
        icon: '⚠️',
        type: ChapterType.lesson,
        xpReward: 420,
        gemReward: 42,
        prerequisites: ['chapter_16'],
        skills: ['Await try-catch', 'Scope management', 'Async middleware', 'Error propagation'],
        lessons: [
          Lesson(id: 'ch17_lesson1', title: 'Try-catch await', type: LessonType.grammar, description: 'Handling await crashes.', xpReward: 140, status: LessonStatus.locked),
          Lesson(id: 'ch17_lesson2', title: 'Centralized logs', type: LessonType.reading, description: 'Modern API error handling.', xpReward: 140, status: LessonStatus.locked),
          Lesson(id: 'ch17_lesson3', title: 'Clean architecture', type: LessonType.conversation, description: 'Best practices for clean code.', xpReward: 140, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_18',
        chapterNumber: 18,
        title: 'Parallel Async Tasks',
        description: 'Executing multiple tasks concurrently with modern methods.',
        icon: '⚡',
        type: ChapterType.lesson,
        xpReward: 440,
        gemReward: 44,
        prerequisites: ['chapter_17'],
        skills: ['Parallel execution', 'Promise.race', 'Promise.allSettled', 'Scaling requests'],
        lessons: [
          Lesson(id: 'ch18_lesson1', title: 'Concurrent fetching', type: LessonType.vocabulary, description: 'Parallel data fetching.', xpReward: 150, status: LessonStatus.locked),
          Lesson(id: 'ch18_lesson2', title: 'Racing tasks', type: LessonType.grammar, description: 'Utilizing fast responses.', xpReward: 150, status: LessonStatus.locked),
          Lesson(id: 'ch18_lesson3', title: 'AllSettled strategy', type: LessonType.exercise, description: 'Handling partial failures.', xpReward: 140, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_19',
        chapterNumber: 19,
        title: 'Real World Integration',
        description: 'Integrating async workflows into real web projects.',
        icon: '🏢',
        type: ChapterType.lesson,
        xpReward: 460,
        gemReward: 46,
        prerequisites: ['chapter_18'],
        skills: ['UI loading states', 'Data rendering', 'Event performance', 'Project integration'],
        lessons: [
          Lesson(id: 'ch19_lesson1', title: 'Loading UI', type: LessonType.exercise, description: 'Visualizing async waits.', xpReward: 160, status: LessonStatus.locked),
          Lesson(id: 'ch19_lesson2', title: 'Data streaming', type: LessonType.reading, description: 'Handling large asynchronous JSON.', xpReward: 150, status: LessonStatus.locked),
          Lesson(id: 'ch19_lesson3', title: 'User experience', type: LessonType.listening, description: 'Performance vs latency.', xpReward: 150, status: LessonStatus.locked),
        ],
      ),
      const Chapter(
        id: 'chapter_20',
        chapterNumber: 20,
        title: 'Boss Challenge: Async Architect',
        description: 'Demonstrate full mastery of asynchronous JavaScript in a simulated real-world application.',
        icon: '👑',
        type: ChapterType.bossChallenge,
        xpReward: 1440,
        gemReward: 150,
        prerequisites: ['chapter_19'],
        skills: ['Async/Await integration', 'Parallel optimization', 'Production-level error handling'],
        lessons: [
          Lesson(id: 'ch20_lesson1', title: 'App deployment', type: LessonType.exercise, description: 'Full app asynchronous logic.', xpReward: 480, status: LessonStatus.locked),
          Lesson(id: 'ch20_lesson2', title: 'Performance audit', type: LessonType.exercise, description: 'Optimizing async bottlenecks.', xpReward: 480, status: LessonStatus.locked),
          Lesson(id: 'ch20_lesson3', title: 'Final assessment', type: LessonType.exercise, description: 'Comprehensive knowledge test.', xpReward: 480, status: LessonStatus.locked),
        ],
      ),
    ];

    return Roadmap(
      id: 'roadmap_js_async',
      title: 'Roadmap to Asynchronous JavaScript',
      description: 'A structured journey from JavaScript fundamentals to understanding the mechanics of non-blocking I/O and asynchronous control flow.',
      targetLanguage: 'JavaScript',
      level: 'beginner',
      totalXp: 3860,
      estimatedHours: 85,
      chapters: chapters,
    );
  }
}
