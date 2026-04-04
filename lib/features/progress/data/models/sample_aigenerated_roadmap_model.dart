//sample api response
// http://localhost:3000/api/v1/ai/roadmap/generate
class RoadmapResponse {

  factory RoadmapResponse.fromJson(Map<String, dynamic> json) {
    return RoadmapResponse(
      data: Roadmap.fromJson(json['data']),
      statusCode: json['statusCode'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  RoadmapResponse({
    required this.data,
    required this.statusCode,
    required this.timestamp,
  });
  final Roadmap data;
  final int statusCode;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'statusCode': statusCode,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Roadmap {

  Roadmap({
    required this.id,
    required this.title,
    required this.description,
    required this.targetLanguage,
    required this.level,
    required this.totalXp,
    required this.estimatedHours,
    required this.chapters,
  });

  factory Roadmap.fromJson(Map<String, dynamic> json) {
    return Roadmap(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetLanguage: json['targetLanguage'],
      level: json['level'],
      totalXp: json['totalXp'],
      estimatedHours: json['estimatedHours'],
      chapters: (json['chapters'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList(),
    );
  }
  final String id;
  final String title;
  final String description;
  final String targetLanguage;
  final String level;
  final int totalXp;
  final int estimatedHours;
  final List<Chapter> chapters;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetLanguage': targetLanguage,
      'level': level,
      'totalXp': totalXp,
      'estimatedHours': estimatedHours,
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
    };
  }
}

class Chapter {

  Chapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.xpReward,
    required this.gemReward,
    required this.prerequisites,
    required this.skills,
    required this.lessons,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      chapterNumber: json['chapterNumber'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      type: json['type'],
      xpReward: json['xpReward'],
      gemReward: json['gemReward'],
      prerequisites: List<String>.from(json['prerequisites']),
      skills: List<String>.from(json['skills']),
      lessons: (json['lessons'] as List)
          .map((lesson) => Lesson.fromJson(lesson))
          .toList(),
    );
  }
  final String id;
  final int chapterNumber;
  final String title;
  final String description;
  final String icon;
  final String type;
  final int xpReward;
  final int gemReward;
  final List<String> prerequisites;
  final List<String> skills;
  final List<Lesson> lessons;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapterNumber': chapterNumber,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type,
      'xpReward': xpReward,
      'gemReward': gemReward,
      'prerequisites': prerequisites,
      'skills': skills,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}

class Lesson {

  Lesson({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.xpReward,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      description: json['description'],
      xpReward: json['xpReward'],
    );
  }
  final String id;
  final String title;
  final String type;
  final String description;
  final int xpReward;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'xpReward': xpReward,
    };
  }
}




// {
//     "data": {
//         "id": "roadmap_1775285435447_xe36gqs",
//         "title": "TypeScript Mastery for NestJS Developers",
//         "description": "A comprehensive journey from intermediate TypeScript fundamentals to building enterprise-grade backend systems with NestJS.",
//         "targetLanguage": "TypeScript",
//         "level": "intermediate",
//         "totalXp": 3960,
//         "estimatedHours": 60,
//         "chapters": [
//             {
//                 "id": "chapter_1",
//                 "chapterNumber": 1,
//                 "title": "TypeScript Fundamentals",
//                 "description": "Mastering basic types and variable declarations.",
//                 "icon": "📝",
//                 "type": "lesson",
//                 "xpReward": 100,
//                 "gemReward": 10,
//                 "prerequisites": [],
//                 "skills": [
//                     "Primitive types",
//                     "Type inference",
//                     "Variable scoping"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch1_lesson1",
//                         "title": "Understanding Types",
//                         "type": "vocabulary",
//                         "description": "Defining strings numbers and booleans.",
//                         "xpReward": 25
//                     },
//                     {
//                         "id": "ch1_lesson2",
//                         "title": "Implicit vs Explicit",
//                         "type": "grammar",
//                         "description": "Learning when to define types manually.",
//                         "xpReward": 25
//                     },
//                     {
//                         "id": "ch1_lesson3",
//                         "title": "Basic Constants",
//                         "type": "exercise",
//                         "description": "Practicing let and const.",
//                         "xpReward": 50
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_2",
//                 "chapterNumber": 2,
//                 "title": "Interfaces and Shapes",
//                 "description": "Defining data structures for objects.",
//                 "icon": "🏗️",
//                 "type": "lesson",
//                 "xpReward": 120,
//                 "gemReward": 12,
//                 "prerequisites": [
//                     "chapter_1"
//                 ],
//                 "skills": [
//                     "Interface definition",
//                     "Optional properties",
//                     "Readonly types"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch2_lesson1",
//                         "title": "Creating Interfaces",
//                         "type": "vocabulary",
//                         "description": "Designing user entity structures.",
//                         "xpReward": 40
//                     },
//                     {
//                         "id": "ch2_lesson2",
//                         "title": "Using Optional Props",
//                         "type": "grammar",
//                         "description": "Handling missing data fields.",
//                         "xpReward": 40
//                     },
//                     {
//                         "id": "ch2_lesson3",
//                         "title": "Readonly Records",
//                         "type": "exercise",
//                         "description": "Preventing mutation of configs.",
//                         "xpReward": 40
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_3",
//                 "chapterNumber": 3,
//                 "title": "Functions and Arrow Syntax",
//                 "description": "Structuring logic in TypeScript.",
//                 "icon": "⚙️",
//                 "type": "lesson",
//                 "xpReward": 140,
//                 "gemReward": 14,
//                 "prerequisites": [
//                     "chapter_2"
//                 ],
//                 "skills": [
//                     "Function types",
//                     "Arrow functions",
//                     "Rest parameters"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch3_lesson1",
//                         "title": "Typing Arguments",
//                         "type": "vocabulary",
//                         "description": "Adding types to function inputs.",
//                         "xpReward": 50
//                     },
//                     {
//                         "id": "ch3_lesson2",
//                         "title": "Return Type Hints",
//                         "type": "grammar",
//                         "description": "Explicit function exit types.",
//                         "xpReward": 40
//                     },
//                     {
//                         "id": "ch3_lesson3",
//                         "title": "Clean Arrow Functions",
//                         "type": "exercise",
//                         "description": "Writing concise logic.",
//                         "xpReward": 50
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_4",
//                 "chapterNumber": 4,
//                 "title": "Enums and Union Types",
//                 "description": "Defining finite sets of options.",
//                 "icon": "🗂️",
//                 "type": "lesson",
//                 "xpReward": 160,
//                 "gemReward": 16,
//                 "prerequisites": [
//                     "chapter_3"
//                 ],
//                 "skills": [
//                     "Numeric enums",
//                     "String literals",
//                     "Union types"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch4_lesson1",
//                         "title": "Defining Status Enums",
//                         "type": "vocabulary",
//                         "description": "Categorizing status codes.",
//                         "xpReward": 50
//                     },
//                     {
//                         "id": "ch4_lesson2",
//                         "title": "Union Logic",
//                         "type": "grammar",
//                         "description": "Using pipes to define options.",
//                         "xpReward": 50
//                     },
//                     {
//                         "id": "ch4_lesson3",
//                         "title": "Validation Patterns",
//                         "type": "exercise",
//                         "description": "Validating input against unions.",
//                         "xpReward": 60
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_5",
//                 "chapterNumber": 5,
//                 "title": "Checkpoint: TS Core",
//                 "description": "Reviewing core TS patterns before NestJS.",
//                 "icon": "🏁",
//                 "type": "checkpoint",
//                 "xpReward": 270,
//                 "gemReward": 27,
//                 "prerequisites": [
//                     "chapter_4"
//                 ],
//                 "skills": [
//                     "Refactoring types",
//                     "Identifying incorrect patterns",
//                     "Syntactic analysis"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch5_lesson1",
//                         "title": "TypeScript Recap",
//                         "type": "reading",
//                         "description": "Synthesizing early concepts.",
//                         "xpReward": 90
//                     },
//                     {
//                         "id": "ch5_lesson2",
//                         "title": "Error Finding",
//                         "type": "exercise",
//                         "description": "Fixing type errors.",
//                         "xpReward": 90
//                     },
//                     {
//                         "id": "ch5_lesson3",
//                         "title": "Conceptual Quiz",
//                         "type": "reading",
//                         "description": "Testing comprehension.",
//                         "xpReward": 90
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_6",
//                 "chapterNumber": 6,
//                 "title": "Classes and Decorator Basics",
//                 "description": "Understanding the foundation of NestJS.",
//                 "icon": "🏰",
//                 "type": "lesson",
//                 "xpReward": 200,
//                 "gemReward": 20,
//                 "prerequisites": [
//                     "chapter_5"
//                 ],
//                 "skills": [
//                     "Class structure",
//                     "Access modifiers",
//                     "Constructor signatures"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch6_lesson1",
//                         "title": "Class Basics",
//                         "type": "vocabulary",
//                         "description": "Defining service classes.",
//                         "xpReward": 60
//                     },
//                     {
//                         "id": "ch6_lesson2",
//                         "title": "Public vs Private",
//                         "type": "grammar",
//                         "description": "Encapsulating logic.",
//                         "xpReward": 70
//                     },
//                     {
//                         "id": "ch6_lesson3",
//                         "title": "Constructor Injection",
//                         "type": "exercise",
//                         "description": "Passing dependencies.",
//                         "xpReward": 70
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_7",
//                 "chapterNumber": 7,
//                 "title": "Dependency Injection Concepts",
//                 "description": "How NestJS handles providers.",
//                 "icon": "💉",
//                 "type": "lesson",
//                 "xpReward": 220,
//                 "gemReward": 22,
//                 "prerequisites": [
//                     "chapter_6"
//                 ],
//                 "skills": [
//                     "Inversion of control",
//                     "Providers",
//                     "Scope management"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch7_lesson1",
//                         "title": "What is DI",
//                         "type": "listening",
//                         "description": "Understanding object decoupling.",
//                         "xpReward": 70
//                     },
//                     {
//                         "id": "ch7_lesson2",
//                         "title": "Singleton Patterns",
//                         "type": "grammar",
//                         "description": "Sharing instances.",
//                         "xpReward": 80
//                     },
//                     {
//                         "id": "ch7_lesson3",
//                         "title": "Service Implementation",
//                         "type": "exercise",
//                         "description": "Creating injectable services.",
//                         "xpReward": 70
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_8",
//                 "chapterNumber": 8,
//                 "title": "Modules and Architecture",
//                 "description": "Organizing NestJS applications.",
//                 "icon": "📦",
//                 "type": "lesson",
//                 "xpReward": 240,
//                 "gemReward": 24,
//                 "prerequisites": [
//                     "chapter_7"
//                 ],
//                 "skills": [
//                     "Module metadata",
//                     "Exports and imports",
//                     "Feature structuring"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch8_lesson1",
//                         "title": "Root Module Scope",
//                         "type": "vocabulary",
//                         "description": "App setup.",
//                         "xpReward": 80
//                     },
//                     {
//                         "id": "ch8_lesson2",
//                         "title": "Importing Modules",
//                         "type": "reading",
//                         "description": "Module communication.",
//                         "xpReward": 80
//                     },
//                     {
//                         "id": "ch8_lesson3",
//                         "title": "Shared Features",
//                         "type": "exercise",
//                         "description": "Building a feature folder.",
//                         "xpReward": 80
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_9",
//                 "chapterNumber": 9,
//                 "title": "Controllers & Routing",
//                 "description": "Handling HTTP requests.",
//                 "icon": "🌐",
//                 "type": "lesson",
//                 "xpReward": 260,
//                 "gemReward": 26,
//                 "prerequisites": [
//                     "chapter_8"
//                 ],
//                 "skills": [
//                     "Decorator routes",
//                     "Request handling",
//                     "Status codes"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch9_lesson1",
//                         "title": "Get Method",
//                         "type": "vocabulary",
//                         "description": "Fetching data.",
//                         "xpReward": 90
//                     },
//                     {
//                         "id": "ch9_lesson2",
//                         "title": "Params and Body",
//                         "type": "grammar",
//                         "description": "Reading input.",
//                         "xpReward": 80
//                     },
//                     {
//                         "id": "ch9_lesson3",
//                         "title": "Status Codes",
//                         "type": "exercise",
//                         "description": "Returning 201s.",
//                         "xpReward": 90
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_10",
//                 "chapterNumber": 10,
//                 "title": "Checkpoint: Basics",
//                 "description": "Reviewing NestJS architectural patterns.",
//                 "icon": "🛣️",
//                 "type": "checkpoint",
//                 "xpReward": 390,
//                 "gemReward": 39,
//                 "prerequisites": [
//                     "chapter_9"
//                 ],
//                 "skills": [
//                     "Decorator usage",
//                     "DI flow",
//                     "Module structure"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch10_lesson1",
//                         "title": "DI Logic Review",
//                         "type": "listening",
//                         "description": "Concept recall.",
//                         "xpReward": 130
//                     },
//                     {
//                         "id": "ch10_lesson2",
//                         "title": "Code Reading",
//                         "type": "reading",
//                         "description": "Analyzing a controller.",
//                         "xpReward": 130
//                     },
//                     {
//                         "id": "ch10_lesson3",
//                         "title": "Architecture Quiz",
//                         "type": "exercise",
//                         "description": "Testing patterns.",
//                         "xpReward": 130
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_11",
//                 "chapterNumber": 11,
//                 "title": "Data Transfer Objects (DTOs)",
//                 "description": "Validating incoming data.",
//                 "icon": "🛡️",
//                 "type": "lesson",
//                 "xpReward": 300,
//                 "gemReward": 30,
//                 "prerequisites": [
//                     "chapter_10"
//                 ],
//                 "skills": [
//                     "Class-validator",
//                     "DTO design",
//                     "Schema validation"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch11_lesson1",
//                         "title": "Why DTOs",
//                         "type": "reading",
//                         "description": "Type safety input.",
//                         "xpReward": 100
//                     },
//                     {
//                         "id": "ch11_lesson2",
//                         "title": "Validation Decorators",
//                         "type": "vocabulary",
//                         "description": "IsEmail and IsEmpty.",
//                         "xpReward": 100
//                     },
//                     {
//                         "id": "ch11_lesson3",
//                         "title": "Transforming Input",
//                         "type": "exercise",
//                         "description": "Sanitizing data.",
//                         "xpReward": 100
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_12",
//                 "chapterNumber": 12,
//                 "title": "Exception Filters",
//                 "description": "Standardizing API errors.",
//                 "icon": "🚫",
//                 "type": "lesson",
//                 "xpReward": 320,
//                 "gemReward": 32,
//                 "prerequisites": [
//                     "chapter_11"
//                 ],
//                 "skills": [
//                     "Global filters",
//                     "Custom exceptions",
//                     "The HttpException"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch12_lesson1",
//                         "title": "Global Filters",
//                         "type": "vocabulary",
//                         "description": "Catching all.",
//                         "xpReward": 110
//                     },
//                     {
//                         "id": "ch12_lesson2",
//                         "title": "Custom Error Messages",
//                         "type": "grammar",
//                         "description": "Client feedback.",
//                         "xpReward": 110
//                     },
//                     {
//                         "id": "ch12_lesson3",
//                         "title": "Built-in Exceptions",
//                         "type": "exercise",
//                         "description": "Throwing errors.",
//                         "xpReward": 100
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_13",
//                 "chapterNumber": 13,
//                 "title": "Pipes and Transformation",
//                 "description": "Data shaping and transformation.",
//                 "icon": "⛓️",
//                 "type": "lesson",
//                 "xpReward": 340,
//                 "gemReward": 34,
//                 "prerequisites": [
//                     "chapter_12"
//                 ],
//                 "skills": [
//                     "ValidationPipe",
//                     "ParseIntPipe",
//                     "Custom pipes"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch13_lesson1",
//                         "title": "Pipe Pipelines",
//                         "type": "vocabulary",
//                         "description": "What they do.",
//                         "xpReward": 110
//                     },
//                     {
//                         "id": "ch13_lesson2",
//                         "title": "Parsing Types",
//                         "type": "grammar",
//                         "description": "Number casting.",
//                         "xpReward": 120
//                     },
//                     {
//                         "id": "ch13_lesson3",
//                         "title": "Building a Custom Pipe",
//                         "type": "exercise",
//                         "description": "Uppercase pipe.",
//                         "xpReward": 110
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_14",
//                 "chapterNumber": 14,
//                 "title": "Middleware and Guards",
//                 "description": "Protecting routes and intercepts.",
//                 "icon": "💂",
//                 "type": "lesson",
//                 "xpReward": 360,
//                 "gemReward": 36,
//                 "prerequisites": [
//                     "chapter_13"
//                 ],
//                 "skills": [
//                     "AuthGuard",
//                     "Middleware functions",
//                     "Execution context"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch14_lesson1",
//                         "title": "Guard Flow",
//                         "type": "listening",
//                         "description": "Auth cycles.",
//                         "xpReward": 120
//                     },
//                     {
//                         "id": "ch14_lesson2",
//                         "title": "Middleware Logger",
//                         "type": "grammar",
//                         "description": "Logging requests.",
//                         "xpReward": 120
//                     },
//                     {
//                         "id": "ch14_lesson3",
//                         "title": "Route Guards",
//                         "type": "exercise",
//                         "description": "Securing data.",
//                         "xpReward": 120
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_15",
//                 "chapterNumber": 15,
//                 "title": "Checkpoint: Validation",
//                 "description": "Reviewing data handling and security.",
//                 "icon": "🔐",
//                 "type": "checkpoint",
//                 "xpReward": 510,
//                 "gemReward": 51,
//                 "prerequisites": [
//                     "chapter_14"
//                 ],
//                 "skills": [
//                     "DTO integrity",
//                     "Error response codes",
//                     "Authentication flow"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch15_lesson1",
//                         "title": "Integrity Check",
//                         "type": "vocabulary",
//                         "description": "Quiz on validation.",
//                         "xpReward": 170
//                     },
//                     {
//                         "id": "ch15_lesson2",
//                         "title": "Security Review",
//                         "type": "reading",
//                         "description": "Guards vs Middleware.",
//                         "xpReward": 170
//                     },
//                     {
//                         "id": "ch15_lesson3",
//                         "title": "Validation Lab",
//                         "type": "exercise",
//                         "description": "Full app test.",
//                         "xpReward": 170
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_16",
//                 "chapterNumber": 16,
//                 "title": "Generics in NestJS",
//                 "description": "Writing flexible reusable types.",
//                 "icon": "🧬",
//                 "type": "lesson",
//                 "xpReward": 400,
//                 "gemReward": 40,
//                 "prerequisites": [
//                     "chapter_15"
//                 ],
//                 "skills": [
//                     "Generic classes",
//                     "Generic functions",
//                     "Constraint interfaces"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch16_lesson1",
//                         "title": "Generic Basics",
//                         "type": "grammar",
//                         "description": "T types.",
//                         "xpReward": 130
//                     },
//                     {
//                         "id": "ch16_lesson2",
//                         "title": "Repository Pattern",
//                         "type": "vocabulary",
//                         "description": "Generic repositories.",
//                         "xpReward": 140
//                     },
//                     {
//                         "id": "ch16_lesson3",
//                         "title": "Applying Constraints",
//                         "type": "exercise",
//                         "description": "Refining types.",
//                         "xpReward": 130
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_17",
//                 "chapterNumber": 17,
//                 "title": "Asynchronous Streams",
//                 "description": "Dealing with DB operations.",
//                 "icon": "⏳",
//                 "type": "lesson",
//                 "xpReward": 420,
//                 "gemReward": 42,
//                 "prerequisites": [
//                     "chapter_16"
//                 ],
//                 "skills": [
//                     "Async-await",
//                     "Promises",
//                     "Observable streams"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch17_lesson1",
//                         "title": "Observables vs Promises",
//                         "type": "vocabulary",
//                         "description": "RxJS intro.",
//                         "xpReward": 140
//                     },
//                     {
//                         "id": "ch17_lesson2",
//                         "title": "Async Services",
//                         "type": "grammar",
//                         "description": "Handling DB calls.",
//                         "xpReward": 140
//                     },
//                     {
//                         "id": "ch17_lesson3",
//                         "title": "Stream Transformation",
//                         "type": "exercise",
//                         "description": "Mapping data.",
//                         "xpReward": 140
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_18",
//                 "chapterNumber": 18,
//                 "title": "Configuration and Env",
//                 "description": "Managing app configurations.",
//                 "icon": "⚙️",
//                 "type": "lesson",
//                 "xpReward": 440,
//                 "gemReward": 44,
//                 "prerequisites": [
//                     "chapter_17"
//                 ],
//                 "skills": [
//                     "ConfigModule",
//                     "Env validation",
//                     "Dynamic modules"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch18_lesson1",
//                         "title": "Environment Setup",
//                         "type": "vocabulary",
//                         "description": "Dotenv usage.",
//                         "xpReward": 150
//                     },
//                     {
//                         "id": "ch18_lesson2",
//                         "title": "Config Validation",
//                         "type": "grammar",
//                         "description": "Joi checks.",
//                         "xpReward": 150
//                     },
//                     {
//                         "id": "ch18_lesson3",
//                         "title": "Dynamic Injection",
//                         "type": "exercise",
//                         "description": "Modular config.",
//                         "xpReward": 140
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_19",
//                 "chapterNumber": 19,
//                 "title": "Testing NestJS",
//                 "description": "Unit and integration tests.",
//                 "icon": "🧪",
//                 "type": "lesson",
//                 "xpReward": 460,
//                 "gemReward": 46,
//                 "prerequisites": [
//                     "chapter_18"
//                 ],
//                 "skills": [
//                     "Jest framework",
//                     "Mocking providers",
//                     "E2E testing"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch19_lesson1",
//                         "title": "Jest Foundations",
//                         "type": "vocabulary",
//                         "description": "Test basics.",
//                         "xpReward": 150
//                     },
//                     {
//                         "id": "ch19_lesson2",
//                         "title": "Mocking Dependencies",
//                         "type": "grammar",
//                         "description": "Fake injectables.",
//                         "xpReward": 160
//                     },
//                     {
//                         "id": "ch19_lesson3",
//                         "title": "Service Unit Test",
//                         "type": "exercise",
//                         "description": "Writing tests.",
//                         "xpReward": 150
//                     }
//                 ]
//             },
//             {
//                 "id": "chapter_20",
//                 "chapterNumber": 20,
//                 "title": "Boss Challenge: Enterprise API",
//                 "description": "Final build of a production API.",
//                 "icon": "🏆",
//                 "type": "boss_challenge",
//                 "xpReward": 1380,
//                 "gemReward": 138,
//                 "prerequisites": [
//                     "chapter_19"
//                 ],
//                 "skills": [
//                     "End-to-end orchestration",
//                     "Dependency graph management",
//                     "Production readiness"
//                 ],
//                 "lessons": [
//                     {
//                         "id": "ch20_lesson1",
//                         "title": "System Design",
//                         "type": "reading",
//                         "description": "Planning architecture.",
//                         "xpReward": 400
//                     },
//                     {
//                         "id": "ch20_lesson2",
//                         "title": "Code Implementation",
//                         "type": "exercise",
//                         "description": "Writing complex services.",
//                         "xpReward": 500
//                     },
//                     {
//                         "id": "ch20_lesson3",
//                         "title": "Final Review",
//                         "type": "exercise",
//                         "description": "Documentation & cleanup.",
//                         "xpReward": 480
//                     }
//                 ]
//             }
//         ]
//     },
//     "statusCode": 201,
//     "timestamp": "2026-04-04T06:50:35.447Z"
// }



//json input param
// {
//   "topic": "NestJS",
//   "language": "TypeScript",
//   "level": "Intermediate",
//   "nativeLanguage": "English"
// }