alter table public.learning_subjects
  alter column accent_color_value type bigint;

insert into public.learning_subjects (
  id,
  name,
  category,
  category_key,
  description,
  emoji,
  accent_color_value,
  difficulty,
  sort_order
) values
  ('mathematics', 'Mathematics', 'Math', 'math', 'Build fluency in algebra, geometry, calculus, and problem solving.', 'MATH', 4283215696, 'All Levels', 10),
  ('computer-science', 'Computer Science', 'Technology', 'technology', 'Learn programming, algorithms, data structures, and software systems.', 'CS', 4278238420, 'All Levels', 20),
  ('physics', 'Physics', 'Science', 'science', 'Explore motion, energy, waves, electricity, and the physical world.', 'PHY', 4280391411, 'Intermediate', 30),
  ('chemistry', 'Chemistry', 'Science', 'science', 'Study atoms, reactions, bonding, acids, bases, and lab reasoning.', 'CHEM', 4281558732, 'Intermediate', 40),
  ('biology', 'Biology', 'Science', 'science', 'Understand cells, genetics, ecosystems, evolution, and body systems.', 'BIO', 4278228616, 'All Levels', 50),
  ('history', 'History', 'Humanities', 'humanities', 'Connect civilizations, primary sources, causes, effects, and timelines.', 'HIS', 4286509783, 'All Levels', 60),
  ('languages', 'Languages', 'Language', 'language', 'Practice vocabulary, grammar, conversation, reading, and writing.', 'LANG', 4282339765, 'Beginner', 70),
  ('arts-music', 'Arts and Music', 'Creative Arts', 'creative-arts', 'Develop visual art, design, music theory, and creative interpretation.', 'ART', 4290723993, 'All Levels', 80)
on conflict (id) do update set
  name = excluded.name,
  category = excluded.category,
  category_key = excluded.category_key,
  description = excluded.description,
  emoji = excluded.emoji,
  accent_color_value = excluded.accent_color_value,
  difficulty = excluded.difficulty,
  sort_order = excluded.sort_order;

insert into public.learning_topics (
  id,
  subject_id,
  name,
  description,
  emoji,
  difficulty,
  estimated_minutes,
  sort_order
) values
  ('algebra-foundations', 'mathematics', 'Algebra Foundations', 'Variables, expressions, equations, and graphing basics.', 'ALG', 'Beginner', 45, 10),
  ('geometry-essentials', 'mathematics', 'Geometry Essentials', 'Angles, shapes, proofs, area, volume, and coordinate geometry.', 'GEO', 'Beginner', 50, 20),
  ('calculus-intro', 'mathematics', 'Calculus Introduction', 'Limits, derivatives, integrals, and rates of change.', 'CALC', 'Advanced', 60, 30),
  ('programming-basics', 'computer-science', 'Programming Basics', 'Control flow, functions, data types, and debugging habits.', 'CODE', 'Beginner', 45, 10),
  ('data-structures', 'computer-science', 'Data Structures', 'Arrays, maps, stacks, queues, trees, and practical tradeoffs.', 'DS', 'Intermediate', 55, 20),
  ('algorithms', 'computer-science', 'Algorithms', 'Searching, sorting, recursion, complexity, and problem-solving patterns.', 'ALGOS', 'Intermediate', 60, 30),
  ('mechanics', 'physics', 'Mechanics', 'Forces, motion, energy, momentum, and Newton laws.', 'MECH', 'Intermediate', 55, 10),
  ('electricity-magnetism', 'physics', 'Electricity and Magnetism', 'Charge, circuits, fields, induction, and electromagnetic effects.', 'EM', 'Advanced', 60, 20),
  ('atomic-structure', 'chemistry', 'Atomic Structure', 'Atoms, isotopes, electron configuration, and periodic trends.', 'ATOM', 'Beginner', 45, 10),
  ('chemical-reactions', 'chemistry', 'Chemical Reactions', 'Balancing equations, stoichiometry, reaction types, and energy changes.', 'RXN', 'Intermediate', 55, 20),
  ('cell-biology', 'biology', 'Cell Biology', 'Organelles, membranes, respiration, photosynthesis, and cell division.', 'CELL', 'Beginner', 50, 10),
  ('genetics', 'biology', 'Genetics', 'DNA, inheritance, mutations, pedigrees, and genetic variation.', 'GEN', 'Intermediate', 55, 20),
  ('world-civilizations', 'history', 'World Civilizations', 'Early societies, empires, trade, culture, and historical change.', 'WORLD', 'Beginner', 45, 10),
  ('historical-analysis', 'history', 'Historical Analysis', 'Primary sources, bias, causation, continuity, and evidence.', 'SRC', 'Intermediate', 50, 20),
  ('conversation-practice', 'languages', 'Conversation Practice', 'Common phrases, listening, pronunciation, and everyday responses.', 'TALK', 'Beginner', 35, 10),
  ('grammar-writing', 'languages', 'Grammar and Writing', 'Sentence structure, verb patterns, paragraphs, and revision.', 'GRAM', 'Intermediate', 45, 20),
  ('music-theory', 'arts-music', 'Music Theory', 'Rhythm, melody, harmony, notation, and listening skills.', 'MUSIC', 'Beginner', 45, 10),
  ('visual-design', 'arts-music', 'Visual Design', 'Composition, color, contrast, typography, and visual critique.', 'DESIGN', 'Beginner', 45, 20)
on conflict (id) do update set
  subject_id = excluded.subject_id,
  name = excluded.name,
  description = excluded.description,
  emoji = excluded.emoji,
  difficulty = excluded.difficulty,
  estimated_minutes = excluded.estimated_minutes,
  sort_order = excluded.sort_order;

insert into public.achievement_definitions (
  key,
  title,
  description,
  emoji,
  type,
  rarity,
  scope,
  requirement_value,
  xp_reward,
  sort_order
) values
  ('streak_3', 'On a Roll', 'Maintain a 3-day learning streak', 'FIRE', 'streak', 'common', 'account', 3, 50, 10),
  ('streak_7', 'Week Warrior', 'Keep your streak alive for 7 days', 'BOLT', 'streak', 'rare', 'account', 7, 150, 20),
  ('streak_30', 'Unstoppable', 'Reach a 30-day learning streak', 'STAR', 'streak', 'epic', 'account', 30, 500, 30),
  ('streak_100', 'Legend of Consistency', 'Maintain a 100-day streak', 'CROWN', 'streak', 'legendary', 'account', 100, 2000, 40),
  ('xp_100', 'First Steps', 'Earn your first 100 XP', 'SPARK', 'xp', 'common', 'course', 100, 20, 50),
  ('xp_500', 'Rising Star', 'Accumulate 500 XP', 'STAR', 'xp', 'common', 'course', 500, 50, 60),
  ('xp_2000', 'Knowledge Hunter', 'Accumulate 2000 XP', 'TARGET', 'xp', 'rare', 'course', 2000, 200, 70),
  ('xp_10000', 'Grand Scholar', 'Reach 10000 total XP', 'TROPHY', 'xp', 'legendary', 'course', 10000, 1000, 80),
  ('level_5', 'Apprentice', 'Reach level 5', 'BOOK', 'level', 'common', 'account', 5, 100, 90),
  ('level_10', 'Journeyman', 'Reach level 10', 'CAP', 'level', 'rare', 'account', 10, 300, 100),
  ('level_25', 'Expert Learner', 'Reach level 25', 'GEM', 'level', 'epic', 'account', 25, 800, 110),
  ('lesson_1', 'First Lesson', 'Complete your very first lesson', 'SEED', 'lesson', 'common', 'account', 1, 30, 120),
  ('lesson_10', 'Dedicated Student', 'Complete 10 lessons', 'NOTE', 'lesson', 'common', 'account', 10, 100, 130),
  ('lesson_50', 'Learning Machine', 'Complete 50 lessons', 'GEAR', 'lesson', 'rare', 'account', 50, 400, 140),
  ('lesson_100', 'Century Scholar', 'Complete 100 lessons', '100', 'lesson', 'epic', 'account', 100, 1000, 150),
  ('chapter_1', 'Chapter One', 'Complete your first chapter', 'MAP', 'chapter', 'common', 'course', 1, 75, 160),
  ('chapter_5', 'Chapter Master', 'Complete 5 chapters', 'MEDAL', 'chapter', 'rare', 'course', 5, 350, 170),
  ('chapter_20', 'Completionist', 'Complete 20 chapters', 'CHECK', 'chapter', 'epic', 'course', 20, 900, 180),
  ('gems_50', 'Gem Collector', 'Collect 50 gems', 'GEM', 'gems', 'common', 'account', 50, 40, 190),
  ('gems_200', 'Gem Hoarder', 'Collect 200 gems', 'VAULT', 'gems', 'rare', 'account', 200, 150, 200)
on conflict (key) do update set
  title = excluded.title,
  description = excluded.description,
  emoji = excluded.emoji,
  type = excluded.type,
  rarity = excluded.rarity,
  scope = excluded.scope,
  requirement_value = excluded.requirement_value,
  xp_reward = excluded.xp_reward,
  sort_order = excluded.sort_order,
  is_active = true;

drop policy if exists "Service role can manage all profiles" on public.profiles;
create policy "Service role can manage all profiles"
  on public.profiles
  for all
  to service_role
  using (true)
  with check (true);

drop policy if exists "Service role can manage subscriptions" on public.subscriptions;
create policy "Service role can manage subscriptions"
  on public.subscriptions
  for all
  to service_role
  using (true)
  with check (true);

revoke execute on function public.handle_new_user() from public;
grant execute on function public.handle_new_user() to service_role;
