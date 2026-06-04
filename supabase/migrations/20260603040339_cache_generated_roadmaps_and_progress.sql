create table if not exists public.user_courses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  topic text not null,
  roadmap_language text not null,
  level text not null,
  native_language text not null default 'English',
  roadmap_json jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.roadmaps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid references public.user_courses(id) on delete cascade,
  roadmap_mode text not null default 'school',
  topic text not null,
  roadmap_language text not null,
  level text not null,
  native_language text not null default 'English',
  model text,
  request_id text,
  status_code integer,
  mocked boolean not null default false,
  roadmap_json jsonb not null,
  usage jsonb,
  raw_content text,
  prompt text,
  code text,
  message text,
  temperature double precision,
  max_tokens integer,
  top_p double precision,
  generated_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '7 days'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, course_id)
);

alter table if exists public.profile_course_xp
  add column if not exists course_id uuid references public.user_courses(id) on delete cascade;

create table if not exists public.roadmap_chapter_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  roadmap_id text not null check (length(trim(roadmap_id)) > 0),
  course_id uuid references public.user_courses(id) on delete cascade,
  course_key text not null check (length(trim(course_key)) > 0),
  chapter_number integer not null check (chapter_number > 0),
  chapter_title text not null default '',
  overview text not null default '',
  is_completed boolean not null default false,
  completed_at timestamptz,
  chapter_subcontent_json jsonb,
  subcontent_api_id text,
  generated_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '7 days'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, roadmap_id, chapter_number)
);

create table if not exists public.generated_chapter_exercises (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid references public.user_courses(id) on delete cascade,
  course_key text not null check (length(trim(course_key)) > 0),
  chapter_subcontent_id text not null check (length(trim(chapter_subcontent_id)) > 0),
  chapter_number integer not null check (chapter_number > 0),
  subcontent_number integer not null check (subcontent_number > 0),
  exercise_json jsonb not null,
  generated_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '7 days'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, chapter_subcontent_id, subcontent_number)
);

create table if not exists public.chapter_exercise_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid references public.user_courses(id) on delete cascade,
  course_key text not null check (length(trim(course_key)) > 0),
  chapter_subcontent_id text not null check (length(trim(chapter_subcontent_id)) > 0),
  chapter_number integer not null check (chapter_number > 0),
  subcontent_number integer not null check (subcontent_number > 0),
  progress_json jsonb not null default '{}'::jsonb,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, chapter_subcontent_id, subcontent_number)
);

alter table if exists public.roadmaps
  add column if not exists generated_at timestamptz not null default now(),
  add column if not exists expires_at timestamptz not null default (now() + interval '7 days');

alter table if exists public.roadmap_chapter_progress
  add column if not exists generated_at timestamptz not null default now(),
  add column if not exists expires_at timestamptz not null default (now() + interval '7 days');

drop trigger if exists user_courses_updated_at
  on public.user_courses;
create trigger user_courses_updated_at
  before update on public.user_courses
  for each row execute function public.set_updated_at();

drop trigger if exists roadmaps_updated_at
  on public.roadmaps;
create trigger roadmaps_updated_at
  before update on public.roadmaps
  for each row execute function public.set_updated_at();

drop trigger if exists roadmap_chapter_progress_updated_at
  on public.roadmap_chapter_progress;
create trigger roadmap_chapter_progress_updated_at
  before update on public.roadmap_chapter_progress
  for each row execute function public.set_updated_at();

drop trigger if exists generated_chapter_exercises_updated_at
  on public.generated_chapter_exercises;
create trigger generated_chapter_exercises_updated_at
  before update on public.generated_chapter_exercises
  for each row execute function public.set_updated_at();

drop trigger if exists chapter_exercise_progress_updated_at
  on public.chapter_exercise_progress;
create trigger chapter_exercise_progress_updated_at
  before update on public.chapter_exercise_progress
  for each row execute function public.set_updated_at();

create index if not exists generated_chapter_exercises_user_course_idx
  on public.generated_chapter_exercises (user_id, course_key);

create index if not exists user_courses_user_idx
  on public.user_courses (user_id, created_at);

create index if not exists profile_course_xp_course_id_idx
  on public.profile_course_xp (course_id)
  where course_id is not null;

create index if not exists roadmaps_user_course_idx
  on public.roadmaps (user_id, course_id);

create index if not exists roadmaps_expiry_idx
  on public.roadmaps (user_id, expires_at);

create index if not exists roadmap_chapter_progress_course_idx
  on public.roadmap_chapter_progress (user_id, course_id, chapter_number);

create index if not exists roadmap_chapter_progress_expiry_idx
  on public.roadmap_chapter_progress (user_id, expires_at);

create index if not exists generated_chapter_exercises_expiry_idx
  on public.generated_chapter_exercises (user_id, expires_at);

create index if not exists chapter_exercise_progress_user_course_idx
  on public.chapter_exercise_progress (user_id, course_key);

alter table public.user_courses enable row level security;
alter table public.roadmaps enable row level security;
alter table public.roadmap_chapter_progress enable row level security;
alter table public.generated_chapter_exercises enable row level security;
alter table public.chapter_exercise_progress enable row level security;

drop policy if exists "user courses owner select"
  on public.user_courses;
create policy "user courses owner select"
  on public.user_courses
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "user courses owner insert"
  on public.user_courses;
create policy "user courses owner insert"
  on public.user_courses
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "user courses owner update"
  on public.user_courses;
create policy "user courses owner update"
  on public.user_courses
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "user courses owner delete"
  on public.user_courses;
create policy "user courses owner delete"
  on public.user_courses
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "roadmaps owner select"
  on public.roadmaps;
create policy "roadmaps owner select"
  on public.roadmaps
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "roadmaps owner insert"
  on public.roadmaps;
create policy "roadmaps owner insert"
  on public.roadmaps
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "roadmaps owner update"
  on public.roadmaps;
create policy "roadmaps owner update"
  on public.roadmaps
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "roadmaps owner delete"
  on public.roadmaps;
create policy "roadmaps owner delete"
  on public.roadmaps
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "roadmap chapter progress owner select"
  on public.roadmap_chapter_progress;
create policy "roadmap chapter progress owner select"
  on public.roadmap_chapter_progress
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "roadmap chapter progress owner insert"
  on public.roadmap_chapter_progress;
create policy "roadmap chapter progress owner insert"
  on public.roadmap_chapter_progress
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "roadmap chapter progress owner update"
  on public.roadmap_chapter_progress;
create policy "roadmap chapter progress owner update"
  on public.roadmap_chapter_progress
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "roadmap chapter progress owner delete"
  on public.roadmap_chapter_progress;
create policy "roadmap chapter progress owner delete"
  on public.roadmap_chapter_progress
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "generated exercises owner select"
  on public.generated_chapter_exercises;
create policy "generated exercises owner select"
  on public.generated_chapter_exercises
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "generated exercises owner insert"
  on public.generated_chapter_exercises;
create policy "generated exercises owner insert"
  on public.generated_chapter_exercises
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "generated exercises owner update"
  on public.generated_chapter_exercises;
create policy "generated exercises owner update"
  on public.generated_chapter_exercises
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "generated exercises owner delete"
  on public.generated_chapter_exercises;
create policy "generated exercises owner delete"
  on public.generated_chapter_exercises
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "chapter exercise progress owner select"
  on public.chapter_exercise_progress;
create policy "chapter exercise progress owner select"
  on public.chapter_exercise_progress
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "chapter exercise progress owner insert"
  on public.chapter_exercise_progress;
create policy "chapter exercise progress owner insert"
  on public.chapter_exercise_progress
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "chapter exercise progress owner update"
  on public.chapter_exercise_progress;
create policy "chapter exercise progress owner update"
  on public.chapter_exercise_progress
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "chapter exercise progress owner delete"
  on public.chapter_exercise_progress;
create policy "chapter exercise progress owner delete"
  on public.chapter_exercise_progress
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

grant all on public.generated_chapter_exercises to authenticated;
grant all on public.chapter_exercise_progress to authenticated;
grant all on public.user_courses to authenticated;
grant all on public.roadmaps to authenticated;
grant all on public.roadmap_chapter_progress to authenticated;

update public.user_courses
set roadmap_json = null,
    updated_at = now()
where roadmap_json is not null
  and (
    roadmap_json ->> 'mocked' = 'true'
    or lower(roadmap_json::text) like '%mock roadmap%'
    or lower(roadmap_json::text) like '%offline_fallback%'
    or lower(roadmap_json::text) like '%offline-fallback%'
    or lower(roadmap_json::text) like '%deterministic offline%'
  );

delete from public.roadmaps
where mocked = true
   or lower(roadmap_json::text) like '%mock roadmap%'
   or lower(roadmap_json::text) like '%offline_fallback%'
   or lower(roadmap_json::text) like '%offline-fallback%'
   or lower(roadmap_json::text) like '%deterministic offline%';
