import 'package:modern_learner_production/features/explore/data/models/learning_subject_model.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

abstract class LearningSubjectLocalDatasource {
  Future<List<LearningSubjectModel>> getAllSubjects();
  Future<List<LearningSubjectModel>> getByCategory(SubjectCategory category);
  Future<List<LearningSubjectModel>> search(String query);
}

class LearningSubjectLocalDatasourceImpl
    implements LearningSubjectLocalDatasource {
  static final List<LearningSubjectModel> _catalog = [
    // ── Mathematics ──────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'mathematics',
      name: 'Mathematics',
      category: 'STEM',
      categoryEnum: SubjectCategory.stem,
      description:
          'The language of the universe. From basic arithmetic to advanced calculus, mathematics underpins all of science and technology.',
      emoji: '∑',
      accentColorValue: 0xFF7C6FCD,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'math-algebra',
          name: 'Algebra',
          description: 'Variables, equations, and the structure of arithmetic.',
          emoji: '🔣',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'math-geometry',
          name: 'Geometry',
          description: 'Shapes, space, angles, and the properties of figures.',
          emoji: '📐',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'math-calculus',
          name: 'Calculus',
          description:
              'Derivatives, integrals, and the mathematics of change.',
          emoji: '📈',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 60,
        ),
        LearningTopicModel(
          id: 'math-statistics',
          name: 'Statistics & Probability',
          description:
              'Data analysis, distributions, and making predictions from evidence.',
          emoji: '📊',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'math-linear-algebra',
          name: 'Linear Algebra',
          description:
              'Vectors, matrices, and transformations — the backbone of modern AI.',
          emoji: '🧮',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'math-number-theory',
          name: 'Number Theory',
          description:
              'Primes, divisibility, and the deep properties of integers.',
          emoji: '🔢',
          difficulty: DifficultyLevel.advanced,
          estimatedMinutes: 60,
        ),
        LearningTopicModel(
          id: 'math-discrete',
          name: 'Discrete Mathematics',
          description:
              'Logic, sets, graphs, and combinatorics for computer science.',
          emoji: '🕸️',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
      ],
    ),

    // ── Computer Science ──────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'computer-science',
      name: 'Computer Science',
      category: 'STEM',
      categoryEnum: SubjectCategory.stem,
      description:
          'Computation, algorithms, and the principles that power software and systems.',
      emoji: '💻',
      accentColorValue: 0xFF4DB6AC,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'cs-algorithms',
          name: 'Algorithms & Complexity',
          description:
              'Sorting, searching, and analyzing the efficiency of computation.',
          emoji: '⚡',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 60,
        ),
        LearningTopicModel(
          id: 'cs-data-structures',
          name: 'Data Structures',
          description:
              'Arrays, trees, graphs, and how to organize information effectively.',
          emoji: '🌲',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'cs-os',
          name: 'Operating Systems',
          description:
              'Processes, memory management, scheduling, and file systems.',
          emoji: '🖥️',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'cs-networks',
          name: 'Computer Networks',
          description:
              'TCP/IP, protocols, security, and how the internet works.',
          emoji: '🌐',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'cs-databases',
          name: 'Databases',
          description:
              'Relational models, SQL, NoSQL, and data management at scale.',
          emoji: '🗄️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'cs-ai-ml',
          name: 'Artificial Intelligence & ML',
          description:
              'Machine learning, neural networks, and intelligent systems.',
          emoji: '🤖',
          difficulty: DifficultyLevel.advanced,
          estimatedMinutes: 70,
        ),
        LearningTopicModel(
          id: 'cs-compilers',
          name: 'Programming Languages & Compilers',
          description: 'Grammars, parsers, and how languages get executed.',
          emoji: '🔧',
          difficulty: DifficultyLevel.advanced,
          estimatedMinutes: 65,
        ),
      ],
    ),

    // ── Physics ──────────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'physics',
      name: 'Physics',
      category: 'STEM',
      categoryEnum: SubjectCategory.stem,
      description:
          'The fundamental laws governing matter, energy, space, and time.',
      emoji: '⚛️',
      accentColorValue: 0xFF42A5F5,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'physics-mechanics',
          name: 'Classical Mechanics',
          description:
              "Newton's laws, motion, forces, and conservation principles.",
          emoji: '🎯',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'physics-thermodynamics',
          name: 'Thermodynamics',
          description:
              'Heat, entropy, and the laws that govern energy transfer.',
          emoji: '🌡️',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'physics-electromagnetism',
          name: 'Electromagnetism',
          description:
              "Electric fields, magnetic fields, waves, and Maxwell's equations.",
          emoji: '⚡',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 60,
        ),
        LearningTopicModel(
          id: 'physics-quantum',
          name: 'Quantum Mechanics',
          description:
              'Wave-particle duality, uncertainty, and the physics of the very small.',
          emoji: '🔬',
          difficulty: DifficultyLevel.advanced,
          estimatedMinutes: 70,
        ),
        LearningTopicModel(
          id: 'physics-relativity',
          name: 'Special & General Relativity',
          description:
              "Space-time, gravity, and Einstein's revolutionary framework.",
          emoji: '🌌',
          difficulty: DifficultyLevel.advanced,
          estimatedMinutes: 65,
        ),
        LearningTopicModel(
          id: 'physics-optics',
          name: 'Optics & Waves',
          description:
              'Light, lenses, diffraction, and wave behavior.',
          emoji: '🔭',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 45,
        ),
      ],
    ),

    // ── Chemistry ─────────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'chemistry',
      name: 'Chemistry',
      category: 'STEM',
      categoryEnum: SubjectCategory.stem,
      description:
          'The science of matter, its properties, reactions, and transformations.',
      emoji: '🧪',
      accentColorValue: 0xFFEF6C00,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'chem-general',
          name: 'General Chemistry',
          description:
              'Atoms, periodic table, bonding, and chemical reactions.',
          emoji: '⚗️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'chem-organic',
          name: 'Organic Chemistry',
          description:
              'Carbon compounds, functional groups, and reaction mechanisms.',
          emoji: '🧬',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 60,
        ),
        LearningTopicModel(
          id: 'chem-inorganic',
          name: 'Inorganic Chemistry',
          description:
              'Coordination compounds, metals, and non-organic molecules.',
          emoji: '🪨',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'chem-physical',
          name: 'Physical Chemistry',
          description:
              'Thermodynamics, kinetics, and quantum chemistry principles.',
          emoji: '📐',
          difficulty: DifficultyLevel.advanced,
          estimatedMinutes: 65,
        ),
        LearningTopicModel(
          id: 'chem-biochemistry',
          name: 'Biochemistry',
          description:
              'Proteins, DNA, metabolism, and chemical processes in living systems.',
          emoji: '🦠',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'chem-analytical',
          name: 'Analytical Chemistry',
          description:
              'Spectroscopy, chromatography, and methods for identifying substances.',
          emoji: '🔍',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
      ],
    ),

    // ── Biology ──────────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'biology',
      name: 'Biology',
      category: 'STEM',
      categoryEnum: SubjectCategory.stem,
      description:
          'The study of life — from cells and genetics to ecosystems and evolution.',
      emoji: '🧬',
      accentColorValue: 0xFF66BB6A,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'bio-cell',
          name: 'Cell Biology',
          description:
              'Cell structure, organelles, division, and cellular processes.',
          emoji: '🔬',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'bio-genetics',
          name: 'Genetics & Genomics',
          description:
              'DNA, inheritance, mutation, and the human genome.',
          emoji: '🧬',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'bio-evolution',
          name: 'Evolution',
          description:
              'Natural selection, speciation, and the history of life on Earth.',
          emoji: '🦕',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'bio-ecology',
          name: 'Ecology',
          description:
              'Ecosystems, food webs, biodiversity, and environmental interactions.',
          emoji: '🌿',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'bio-anatomy',
          name: 'Human Anatomy & Physiology',
          description:
              'Organ systems, body structure, and how the human body functions.',
          emoji: '🫀',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'bio-microbiology',
          name: 'Microbiology',
          description:
              'Bacteria, viruses, fungi, and microscopic life.',
          emoji: '🦠',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
      ],
    ),

    // ── Engineering ──────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'engineering',
      name: 'Engineering',
      category: 'STEM',
      categoryEnum: SubjectCategory.stem,
      description:
          'Applying scientific principles to design, build, and solve real-world problems.',
      emoji: '⚙️',
      accentColorValue: 0xFF78909C,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'eng-civil',
          name: 'Civil Engineering',
          description:
              'Structures, bridges, roads, and infrastructure design.',
          emoji: '🏗️',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'eng-mechanical',
          name: 'Mechanical Engineering',
          description:
              'Machines, thermodynamics, mechanics, and manufacturing.',
          emoji: '🔩',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'eng-electrical',
          name: 'Electrical Engineering',
          description:
              'Circuits, signals, power systems, and electronics.',
          emoji: '⚡',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'eng-software',
          name: 'Software Engineering',
          description:
              'System design, architecture, testing, and software development practices.',
          emoji: '🖥️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'eng-chemical',
          name: 'Chemical Engineering',
          description:
              'Process design, reaction engineering, and chemical plant operations.',
          emoji: '🏭',
          difficulty: DifficultyLevel.advanced,
          estimatedMinutes: 60,
        ),
      ],
    ),

    // ── History ──────────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'history',
      name: 'History',
      category: 'Humanities',
      categoryEnum: SubjectCategory.humanities,
      description:
          'The human story — civilizations, empires, revolutions, and the events that shaped the modern world.',
      emoji: '📜',
      accentColorValue: 0xFFD4A017,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'hist-ancient',
          name: 'Ancient Civilizations',
          description:
              'Mesopotamia, Egypt, Greece, Rome, and the first great societies.',
          emoji: '🏛️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'hist-medieval',
          name: 'Medieval World',
          description:
              'Feudalism, the Crusades, the Black Death, and medieval kingdoms.',
          emoji: '⚔️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'hist-renaissance',
          name: 'Renaissance & Reformation',
          description:
              'Art, humanism, science, and religious upheaval in early modern Europe.',
          emoji: '🎨',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'hist-modern',
          name: 'Modern World History',
          description:
              'Revolutions, colonialism, industrialization, and the 19th century.',
          emoji: '🌍',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'hist-world-wars',
          name: 'World Wars',
          description:
              'WWI, WWII, causes, battles, and global consequences.',
          emoji: '🕊️',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'hist-cold-war',
          name: 'Cold War & Contemporary',
          description:
              'Superpower rivalry, decolonization, and the world since 1945.',
          emoji: '🚀',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'hist-asia',
          name: 'Asian History',
          description:
              'China, Japan, India, and the great civilizations of Asia.',
          emoji: '🏯',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
      ],
    ),

    // ── Philosophy ───────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'philosophy',
      name: 'Philosophy',
      category: 'Humanities',
      categoryEnum: SubjectCategory.humanities,
      description:
          'The love of wisdom — questions of existence, knowledge, morality, and reasoning.',
      emoji: '🏛️',
      accentColorValue: 0xFF9575CD,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'phil-logic',
          name: 'Logic & Critical Thinking',
          description:
              'Deductive and inductive reasoning, fallacies, and argumentation.',
          emoji: '🧩',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'phil-ethics',
          name: 'Ethics & Moral Philosophy',
          description:
              'Consequentialism, deontology, virtue ethics, and applied morality.',
          emoji: '⚖️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'phil-epistemology',
          name: 'Epistemology',
          description:
              'The nature, sources, and limits of human knowledge.',
          emoji: '💭',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'phil-metaphysics',
          name: 'Metaphysics',
          description:
              'Reality, existence, consciousness, time, and the nature of being.',
          emoji: '🌌',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'phil-political',
          name: 'Political Philosophy',
          description:
              'Justice, power, democracy, and theories of the ideal society.',
          emoji: '🏛️',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'phil-aesthetics',
          name: 'Aesthetics',
          description:
              'Beauty, art, taste, and philosophical theories of artistic value.',
          emoji: '🎭',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
      ],
    ),

    // ── Literature ───────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'literature',
      name: 'Literature',
      category: 'Humanities',
      categoryEnum: SubjectCategory.humanities,
      description:
          'Stories, poetry, and written art — the exploration of human experience through language.',
      emoji: '📚',
      accentColorValue: 0xFFE57373,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'lit-classical',
          name: 'Classical Literature',
          description:
              'Homer, Shakespeare, Dante, and the foundational works of Western literature.',
          emoji: '📖',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'lit-poetry',
          name: 'Poetry',
          description:
              'Form, meter, imagery, and the art of compressed meaning.',
          emoji: '🖊️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 35,
        ),
        LearningTopicModel(
          id: 'lit-fiction',
          name: 'Fiction Writing',
          description:
              'Narrative craft, character development, plot structure, and voice.',
          emoji: '✍️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'lit-analysis',
          name: 'Literary Analysis',
          description:
              'Critical reading, symbolism, themes, and literary theory.',
          emoji: '🔎',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'lit-world',
          name: 'World Literature',
          description:
              'Voices from Africa, Asia, Latin America, and beyond.',
          emoji: '🌍',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'lit-modern',
          name: 'Modern & Contemporary',
          description:
              'Modernism, postmodernism, and literature from the 20th–21st century.',
          emoji: '🏙️',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
      ],
    ),

    // ── Psychology ───────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'psychology',
      name: 'Psychology',
      category: 'Social Sciences',
      categoryEnum: SubjectCategory.socialSciences,
      description:
          'The scientific study of mind, behavior, and human experience.',
      emoji: '🧠',
      accentColorValue: 0xFFFF8A65,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'psych-cognitive',
          name: 'Cognitive Psychology',
          description:
              'Memory, attention, perception, language, and mental processes.',
          emoji: '💡',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'psych-developmental',
          name: 'Developmental Psychology',
          description:
              'Human growth across the lifespan — childhood, adolescence, and aging.',
          emoji: '👶',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'psych-social',
          name: 'Social Psychology',
          description:
              'Group dynamics, conformity, persuasion, and social influence.',
          emoji: '👥',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'psych-clinical',
          name: 'Clinical Psychology',
          description:
              'Mental disorders, therapy approaches, and psychological treatment.',
          emoji: '🛋️',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'psych-behavioral',
          name: 'Behavioral Psychology',
          description:
              'Conditioning, reinforcement, habits, and the science of behavior change.',
          emoji: '🎯',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'psych-neuroscience',
          name: 'Neuroscience',
          description:
              'The brain, neurons, neurotransmitters, and the biology of the mind.',
          emoji: '🧬',
          difficulty: DifficultyLevel.advanced,
          estimatedMinutes: 65,
        ),
      ],
    ),

    // ── Economics ────────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'economics',
      name: 'Economics',
      category: 'Social Sciences',
      categoryEnum: SubjectCategory.socialSciences,
      description:
          'How individuals, firms, and societies make decisions about scarce resources.',
      emoji: '📈',
      accentColorValue: 0xFF26A69A,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'econ-micro',
          name: 'Microeconomics',
          description:
              'Supply, demand, markets, pricing, and individual decision-making.',
          emoji: '🏪',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'econ-macro',
          name: 'Macroeconomics',
          description:
              'GDP, inflation, monetary policy, and national economies.',
          emoji: '🏦',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'econ-behavioral',
          name: 'Behavioral Economics',
          description:
              'Biases, heuristics, and how psychology shapes economic decisions.',
          emoji: '🧠',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'econ-international',
          name: 'International Trade',
          description:
              'Globalization, comparative advantage, tariffs, and trade policy.',
          emoji: '🌐',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'econ-finance',
          name: 'Finance & Investment',
          description:
              'Markets, valuation, portfolio theory, and financial instruments.',
          emoji: '💹',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'econ-development',
          name: 'Development Economics',
          description:
              'Poverty, inequality, growth, and economic development in emerging nations.',
          emoji: '🌱',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
      ],
    ),

    // ── Geography ────────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'geography',
      name: 'Geography',
      category: 'Social Sciences',
      categoryEnum: SubjectCategory.socialSciences,
      description:
          "The study of Earth's landscapes, environments, and human-environment relationships.",
      emoji: '🌍',
      accentColorValue: 0xFF43A047,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'geo-physical',
          name: 'Physical Geography',
          description:
              'Landforms, climate, rivers, oceans, and natural processes.',
          emoji: '⛰️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'geo-human',
          name: 'Human Geography',
          description:
              'Population, culture, cities, and how people shape the land.',
          emoji: '🏙️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'geo-cartography',
          name: 'Cartography & GIS',
          description:
              'Maps, spatial data, and geographic information systems.',
          emoji: '🗺️',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'geo-climate',
          name: 'Climate & Environment',
          description:
              'Weather, climate change, environmental systems, and sustainability.',
          emoji: '🌡️',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'geo-geopolitics',
          name: 'Geopolitics',
          description:
              'Borders, resources, power, and global political geography.',
          emoji: '🌐',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
      ],
    ),

    // ── Languages ────────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'languages',
      name: 'Languages',
      category: 'Languages',
      categoryEnum: SubjectCategory.languages,
      description:
          'Master a new language or deepen your understanding of linguistics and communication.',
      emoji: '🌐',
      accentColorValue: 0xFFAB47BC,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'lang-english',
          name: 'English',
          description:
              'Grammar, writing, vocabulary, and advanced communication in English.',
          emoji: '🇬🇧',
          difficulty: DifficultyLevel.allLevels,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'lang-spanish',
          name: 'Spanish',
          description:
              'Spoken by 500M+ people — grammar, vocabulary, and conversation.',
          emoji: '🇪🇸',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'lang-french',
          name: 'French',
          description:
              'The language of diplomacy, culture, and international affairs.',
          emoji: '🇫🇷',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'lang-mandarin',
          name: 'Mandarin Chinese',
          description:
              "Characters, tones, grammar, and the world's most spoken language.",
          emoji: '🇨🇳',
          difficulty: DifficultyLevel.advanced,
          estimatedMinutes: 65,
        ),
        LearningTopicModel(
          id: 'lang-german',
          name: 'German',
          description:
              'Grammar, cases, vocabulary, and the language of philosophy and science.',
          emoji: '🇩🇪',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
        LearningTopicModel(
          id: 'lang-japanese',
          name: 'Japanese',
          description:
              'Hiragana, Katakana, Kanji, and conversational Japanese.',
          emoji: '🇯🇵',
          difficulty: DifficultyLevel.advanced,
          estimatedMinutes: 65,
        ),
        LearningTopicModel(
          id: 'lang-arabic',
          name: 'Arabic',
          description:
              'The script, grammar, dialects, and Modern Standard Arabic.',
          emoji: '🇸🇦',
          difficulty: DifficultyLevel.advanced,
          estimatedMinutes: 65,
        ),
        LearningTopicModel(
          id: 'lang-linguistics',
          name: 'Linguistics',
          description:
              'The scientific study of language — phonology, syntax, and semantics.',
          emoji: '🗣️',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 55,
        ),
      ],
    ),

    // ── Arts & Music ─────────────────────────────────────────────────────────
    LearningSubjectModel(
      id: 'arts-music',
      name: 'Arts & Music',
      category: 'Arts',
      categoryEnum: SubjectCategory.arts,
      description:
          'Visual arts, music theory, performance, and the history of creative expression.',
      emoji: '🎨',
      accentColorValue: 0xFFEC407A,
      difficulty: DifficultyLevel.allLevels,
      topics: [
        LearningTopicModel(
          id: 'art-history',
          name: 'Art History',
          description:
              'From cave paintings to contemporary art — movements, artists, and meaning.',
          emoji: '🖼️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'art-drawing',
          name: 'Drawing & Illustration',
          description:
              'Fundamentals of line, form, perspective, and artistic technique.',
          emoji: '✏️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'art-music-theory',
          name: 'Music Theory',
          description:
              'Notes, scales, harmony, rhythm, and the structure of music.',
          emoji: '🎵',
          difficulty: DifficultyLevel.intermediate,
          estimatedMinutes: 50,
        ),
        LearningTopicModel(
          id: 'art-photography',
          name: 'Photography',
          description:
              'Composition, lighting, exposure, and visual storytelling.',
          emoji: '📸',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
        LearningTopicModel(
          id: 'art-film',
          name: 'Film & Cinema',
          description:
              'Film history, cinematography, directing, and visual narrative.',
          emoji: '🎬',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 45,
        ),
        LearningTopicModel(
          id: 'art-creative-writing',
          name: 'Creative Writing',
          description:
              'Storytelling, craft, voice, and the art of written expression.',
          emoji: '✍️',
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 40,
        ),
      ],
    ),
  ];

  @override
  Future<List<LearningSubjectModel>> getAllSubjects() async => _catalog;

  @override
  Future<List<LearningSubjectModel>> getByCategory(
    SubjectCategory category,
  ) async =>
      _catalog.where((s) => s.categoryEnum == category).toList();

  @override
  Future<List<LearningSubjectModel>> search(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _catalog;
    return _catalog.where((s) {
      if (s.name.toLowerCase().contains(q)) return true;
      if (s.description.toLowerCase().contains(q)) return true;
      if (s.category.toLowerCase().contains(q)) return true;
      return s.topics.any(
        (t) =>
            t.name.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q),
      );
    }).toList();
  }
}
