create table if not exists public.learning_subjects (
  id text primary key,
  name text not null,
  category text not null,
  category_key text not null,
  description text not null default '',
  emoji text not null default '',
  accent_color_value bigint not null default 8155085,
  difficulty text not null default 'All Levels',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.learning_topics (
  id text primary key,
  subject_id text not null references public.learning_subjects(id) on delete cascade,
  name text not null,
  description text not null default '',
  emoji text not null default '',
  difficulty text not null default 'Beginner',
  estimated_minutes integer not null default 45,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists learning_subjects_category_idx
  on public.learning_subjects (category_key, sort_order);

create index if not exists learning_topics_subject_idx
  on public.learning_topics (subject_id, sort_order);

alter table public.learning_subjects enable row level security;
alter table public.learning_topics enable row level security;

drop policy if exists "learning subjects public select" on public.learning_subjects;
create policy "learning subjects public select"
  on public.learning_subjects
  for select
  to anon, authenticated
  using (true);

drop policy if exists "learning topics public select" on public.learning_topics;
create policy "learning topics public select"
  on public.learning_topics
  for select
  to anon, authenticated
  using (true);

grant select on public.learning_subjects to anon, authenticated;
grant select on public.learning_topics to anon, authenticated;

alter table public.profiles
  add column if not exists topic text default 'general programming',
  add column if not exists target_language text default 'English',
  add column if not exists proficiency_level text default 'beginner',
  add column if not exists native_language text default 'English',
  add column if not exists push_notifications_enabled boolean not null default true,
  add column if not exists daily_reminder_notifications boolean not null default true,
  add column if not exists achievement_alert_notifications boolean not null default true,
  add column if not exists streak_alert_notifications boolean not null default true,
  add column if not exists weekly_digest_notifications boolean not null default false,
  add column if not exists school_course_creation_notifications boolean not null default true,
  add column if not exists voice_lesson_creation_notifications boolean not null default true,
  add column if not exists share_progress boolean not null default true,
  add column if not exists show_in_leaderboard boolean not null default true,
  add column if not exists analytics_enabled boolean not null default true,
  add column if not exists selected_language text not null default 'English (US)';

drop trigger if exists learning_subjects_updated_at on public.learning_subjects;
create trigger learning_subjects_updated_at
  before update on public.learning_subjects
  for each row execute function public.set_updated_at();

drop trigger if exists learning_topics_updated_at on public.learning_topics;
create trigger learning_topics_updated_at
  before update on public.learning_topics
  for each row execute function public.set_updated_at();
