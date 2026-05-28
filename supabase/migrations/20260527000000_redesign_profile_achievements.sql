do $$
begin
  create type public.achievement_type as enum (
    'streak',
    'xp',
    'level',
    'lesson',
    'chapter',
    'gems'
  );
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.achievement_rarity as enum (
    'common',
    'rare',
    'epic',
    'legendary'
  );
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.achievement_scope as enum (
    'account',
    'course'
  );
exception
  when duplicate_object then null;
end $$;

create table if not exists public.achievement_definitions (
  key text primary key,
  title text not null,
  description text not null,
  emoji text not null default '',
  type public.achievement_type not null,
  rarity public.achievement_rarity not null default 'common',
  scope public.achievement_scope not null default 'account',
  requirement_value integer not null check (requirement_value >= 0),
  xp_reward integer not null default 0 check (xp_reward >= 0),
  sort_order integer not null default 0,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_achievement_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_key text not null
    references public.achievement_definitions(key) on delete cascade,
  course_key text not null default 'global' check (length(trim(course_key)) > 0),
  progress_value integer not null default 0 check (progress_value >= 0),
  unlocked_at timestamptz,
  seen_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, achievement_key, course_key)
);

create table if not exists public.profile_course_xp (
  user_id uuid not null references auth.users(id) on delete cascade,
  course_key text not null check (length(trim(course_key)) > 0),
  exercise_xp integer not null default 0 check (exercise_xp >= 0),
  exercises_completed integer not null default 0 check (exercises_completed >= 0),
  chapters_unlocked integer not null default 1 check (chapters_unlocked >= 0),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, course_key)
);

drop trigger if exists achievement_definitions_updated_at
  on public.achievement_definitions;
create trigger achievement_definitions_updated_at
  before update on public.achievement_definitions
  for each row execute function public.set_updated_at();

drop trigger if exists user_achievement_progress_updated_at
  on public.user_achievement_progress;
create trigger user_achievement_progress_updated_at
  before update on public.user_achievement_progress
  for each row execute function public.set_updated_at();

drop trigger if exists profile_course_xp_updated_at
  on public.profile_course_xp;
create trigger profile_course_xp_updated_at
  before update on public.profile_course_xp
  for each row execute function public.set_updated_at();

create index if not exists achievement_definitions_active_sort_idx
  on public.achievement_definitions (is_active, sort_order, key);

create index if not exists user_achievement_progress_user_idx
  on public.user_achievement_progress (user_id, achievement_key);

create index if not exists user_achievement_progress_course_idx
  on public.user_achievement_progress (user_id, course_key);

create index if not exists user_achievement_progress_unlocked_idx
  on public.user_achievement_progress (user_id, unlocked_at desc)
  where unlocked_at is not null;

create index if not exists user_achievement_progress_unseen_idx
  on public.user_achievement_progress (user_id, seen_at)
  where unlocked_at is not null and seen_at is null;

create index if not exists profile_course_xp_user_xp_idx
  on public.profile_course_xp (user_id, exercise_xp desc);

alter table public.achievement_definitions enable row level security;
alter table public.user_achievement_progress enable row level security;
alter table public.profile_course_xp enable row level security;

drop policy if exists "achievement definitions are readable"
  on public.achievement_definitions;
create policy "achievement definitions are readable"
  on public.achievement_definitions
  for select
  to authenticated
  using (is_active);

drop policy if exists "achievement progress owner select"
  on public.user_achievement_progress;
create policy "achievement progress owner select"
  on public.user_achievement_progress
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "achievement progress owner insert"
  on public.user_achievement_progress;
create policy "achievement progress owner insert"
  on public.user_achievement_progress
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "achievement progress owner update"
  on public.user_achievement_progress;
create policy "achievement progress owner update"
  on public.user_achievement_progress
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "achievement progress owner delete"
  on public.user_achievement_progress;
create policy "achievement progress owner delete"
  on public.user_achievement_progress
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "course xp owner select"
  on public.profile_course_xp;
create policy "course xp owner select"
  on public.profile_course_xp
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "course xp owner insert"
  on public.profile_course_xp;
create policy "course xp owner insert"
  on public.profile_course_xp
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "course xp owner update"
  on public.profile_course_xp;
create policy "course xp owner update"
  on public.profile_course_xp
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "course xp owner delete"
  on public.profile_course_xp;
create policy "course xp owner delete"
  on public.profile_course_xp
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

grant usage on schema public to authenticated;
grant select on public.achievement_definitions to authenticated;
grant all on public.user_achievement_progress to authenticated;
grant all on public.profile_course_xp to authenticated;

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
  ('streak_3', 'On a Roll', 'Maintain a 3-day learning streak', '🔥', 'streak', 'common', 'account', 3, 50, 10),
  ('streak_7', 'Week Warrior', 'Keep your streak alive for 7 days', '⚡', 'streak', 'rare', 'account', 7, 150, 20),
  ('streak_30', 'Unstoppable', 'Reach a 30-day learning streak', '🌟', 'streak', 'epic', 'account', 30, 500, 30),
  ('streak_100', 'Legend of Consistency', 'Maintain a 100-day streak', '👑', 'streak', 'legendary', 'account', 100, 2000, 40),
  ('xp_100', 'First Steps', 'Earn your first 100 XP', '✨', 'xp', 'common', 'course', 100, 20, 50),
  ('xp_500', 'Rising Star', 'Accumulate 500 XP', '🌟', 'xp', 'common', 'course', 500, 50, 60),
  ('xp_2000', 'Knowledge Hunter', 'Accumulate 2 000 XP', '🎯', 'xp', 'rare', 'course', 2000, 200, 70),
  ('xp_10000', 'Grand Scholar', 'Reach 10 000 total XP', '🏆', 'xp', 'legendary', 'course', 10000, 1000, 80),
  ('level_5', 'Apprentice', 'Reach level 5', '📘', 'level', 'common', 'account', 5, 100, 90),
  ('level_10', 'Journeyman', 'Reach level 10', '🎖️', 'level', 'rare', 'account', 10, 300, 100),
  ('level_25', 'Expert Learner', 'Reach level 25', '💎', 'level', 'epic', 'account', 25, 800, 110),
  ('lesson_1', 'First Lesson', 'Complete your very first lesson', '🌱', 'lesson', 'common', 'account', 1, 30, 120),
  ('lesson_10', 'Dedicated Student', 'Complete 10 lessons', '📚', 'lesson', 'common', 'account', 10, 100, 130),
  ('lesson_50', 'Learning Machine', 'Complete 50 lessons', '🤖', 'lesson', 'rare', 'account', 50, 400, 140),
  ('lesson_100', 'Century Scholar', 'Complete 100 lessons', '💯', 'lesson', 'epic', 'account', 100, 1000, 150),
  ('chapter_1', 'Chapter One', 'Complete your first chapter', '📑', 'chapter', 'common', 'course', 1, 75, 160),
  ('chapter_5', 'Chapter Master', 'Complete 5 chapters', '🗂️', 'chapter', 'rare', 'course', 5, 350, 170),
  ('chapter_20', 'Completionist', 'Complete 20 chapters', '🧭', 'chapter', 'epic', 'course', 20, 900, 180),
  ('gems_50', 'Gem Collector', 'Collect 50 gems', '💎', 'gems', 'common', 'account', 50, 40, 190),
  ('gems_200', 'Gem Hoarder', 'Collect 200 gems', '💰', 'gems', 'rare', 'account', 200, 150, 200)
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
